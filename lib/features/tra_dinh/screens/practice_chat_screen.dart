import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/theme/app_theme.dart';
import '../models/practice_message.dart';
import '../models/practice_session.dart';
import '../providers/tra_dinh_provider.dart';
import '../services/recording_service.dart';
import '../services/tra_dinh_api.dart';
import '../services/tts_service.dart';

TextStyle _muted(double size) => TextStyle(fontSize: size, color: Colors.white.withValues(alpha: 0.4));

/// Mã lỗi `{error: "..."}` trong response, nếu có.
String? _errorCode(DioException e) {
  final data = e.response?.data;
  return data is Map && data['error'] is String ? data['error'] as String : null;
}

enum _MicState { idle, recording, transcribing }

enum _SpeakState { loading, playing }

/// Ghi quá mức này thì tự dừng và chuyển chữ — tránh quên bấm dừng (Groq
/// Whisper nhận tối đa 25MB, bản ghi dài cũng chuyển chữ chậm).
const maxRecordingDuration = Duration(minutes: 3);

/// Port /tra-dinh/[sessionId] — tin nhắn văn bản, ghi âm thành chữ, đọc tin AI
/// thành tiếng, kết thúc buổi.
class PracticeChatScreen extends ConsumerStatefulWidget {
  const PracticeChatScreen({super.key, required this.sessionId});

  final String sessionId;

  @override
  ConsumerState<PracticeChatScreen> createState() => _PracticeChatScreenState();
}

class _PracticeChatScreenState extends ConsumerState<PracticeChatScreen> {
  final _input = TextEditingController();

  /// Tin đang gửi, hiện mờ cuối danh sách kèm "đang trả lời" — AI không stream,
  /// chờ vài giây.
  String? _pending;

  /// Đang PATCH kết thúc buổi (AI tóm tắt + chấm điểm cả buổi, có thể lâu).
  bool _ending = false;

  var _mic = _MicState.idle;
  int _recordSeconds = 0;
  Timer? _ticker;
  Timer? _autoStop;

  /// Giữ tham chiếu để huỷ ghi trong dispose (lúc đó không dùng ref được nữa).
  RecordingService? _recorder;

  /// Tin AI đang được đọc (null = không tin nào). Mỗi lần bấm tăng [_speakToken]
  /// để kết quả của lần bấm cũ (tải/phát xong muộn) không ghi đè trạng thái mới.
  String? _speakingId;
  _SpeakState? _speakState;
  int _speakToken = 0;
  TtsService? _tts;

  @override
  void initState() {
    super.initState();
    _input.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _stopTimers();
    // Rời màn khi đang ghi: huỷ và bỏ bản ghi (record tự xoá file khi cancel).
    if (_mic == _MicState.recording) _recorder?.cancelRecording();
    _input.dispose();
    super.dispose();
  }

  Future<void> _toggleMic() async {
    final recorder = _recorder!;
    switch (_mic) {
      case _MicState.idle:
        try {
          await recorder.startRecording();
        } on RecordingException catch (e) {
          if (mounted) _snack(e.message);
          return;
        }
        if (!mounted) return;
        setState(() {
          _mic = _MicState.recording;
          _recordSeconds = 0;
        });
        _ticker = Timer.periodic(const Duration(seconds: 1), (_) => setState(() => _recordSeconds++));
        _autoStop = Timer(maxRecordingDuration, () {
          _snack('Đã tự dừng ghi âm sau ${maxRecordingDuration.inMinutes} phút');
          _stopAndTranscribe(recorder);
        });
      case _MicState.recording:
        await _stopAndTranscribe(recorder);
      case _MicState.transcribing:
        return;
    }
  }

  void _stopTimers() {
    _ticker?.cancel();
    _autoStop?.cancel();
    _ticker = _autoStop = null;
  }

  /// Dùng chung cho bấm dừng và tự dừng: huỷ cả 2 timer trước, nên tự dừng
  /// không thể chạy lần nữa sau khi người dùng đã dừng tay (và ngược lại).
  Future<void> _stopAndTranscribe(RecordingService recorder) async {
    if (_mic != _MicState.recording) return;
    _stopTimers();
    setState(() => _mic = _MicState.transcribing);
    await _transcribe(recorder);
  }

  /// Dừng ghi → gửi transcribe → nối chữ vào ô nhập (không tự gửi, như web).
  /// File tạm luôn bị xoá, thành công hay lỗi.
  Future<void> _transcribe(RecordingService recorder) async {
    final path = await recorder.stopRecording();
    if (path == null) {
      if (mounted) {
        setState(() => _mic = _MicState.idle);
        _snack('Không lấy được bản ghi âm — thử ghi lại nhé.');
      }
      return;
    }
    try {
      final text = (await ref.read(traDinhApiProvider).transcribe(path, filename: recorder.fileName)).trim();
      if (!mounted) return;
      if (text.isEmpty) {
        _snack('Không nghe rõ câu nào — thử nói to, rõ hơn nhé.');
      } else {
        final prev = _input.text.trim();
        _input.text = prev.isEmpty ? text : '$prev $text';
        _input.selection = TextSelection.collapsed(offset: _input.text.length);
      }
    } on DioException catch (e) {
      if (mounted) {
        _snack('Không chuyển giọng nói thành chữ được (${e.response?.statusCode ?? e.type.name}) — thử lại nhé.');
      }
    } catch (_) {
      // Đọc file ghi âm lỗi (hiếm) — vẫn báo thay vì im lặng.
      if (mounted) _snack('Không đọc được bản ghi âm — thử ghi lại nhé.');
    } finally {
      await recorder.deleteFile(path);
      if (mounted) setState(() => _mic = _MicState.idle);
    }
  }

  void _snack(String message) => ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(content: Text(message)));

  Future<void> _send() async {
    final content = _input.text.trim();
    if (content.isEmpty || _pending != null) return;
    setState(() => _pending = content);
    _input.clear();

    final notifier = ref.read(sessionDetailProvider(widget.sessionId).notifier);
    try {
      await notifier.send(content);
      if (mounted) setState(() => _pending = null);
    } on DioException catch (e) {
      if (!mounted) return;
      setState(() => _pending = null);
      switch ((e.response?.statusCode, _errorCode(e))) {
        case (400, 'session_ended'):
          // Kết thúc từ thiết bị khác: tải lại để có archivedAt + tóm tắt thật.
          _snack('Buổi luyện này đã kết thúc — không gửi thêm được.');
          await _reloadQuietly();
        default:
          // Mọi lỗi khác (mạng, 502 AI lỗi, 500...): server không ghi gì khi AI
          // lỗi, nên trả lại chữ để người dùng gửi lại.
          _input.text = content;
          _snack('Không gửi được tin nhắn (${e.response?.statusCode ?? e.type.name}) — thử lại nhé.');
      }
    }
  }

  /// Bấm "Phát": dừng tin đang đọc (nếu có) rồi đọc tin này. Bấm lại đúng tin
  /// đang tải/đọc → dừng. Trạng thái luôn về nghỉ trong finally, kể cả khi lỗi.
  Future<void> _toggleSpeak(PracticeMessage message) async {
    final tts = _tts!;
    if (_speakingId == message.id) {
      _speakToken++;
      setState(() => _speakingId = _speakState = null);
      await tts.stop();
      return;
    }
    final token = ++_speakToken;
    setState(() {
      _speakingId = message.id;
      _speakState = _SpeakState.loading;
    });
    try {
      await tts.stop();
      final wav = await tts.fetchSpeech(message.content);
      if (token != _speakToken || !mounted) return;
      setState(() => _speakState = _SpeakState.playing);
      await tts.play(wav);
    } on DioException catch (e) {
      if (token == _speakToken && mounted) {
        _snack(
          e.response?.statusCode == 400
              ? 'Tin này quá dài để đọc thành tiếng (tối đa 2000 ký tự).'
              : 'Không tải được giọng đọc (${e.response?.statusCode ?? e.type.name}) — thử lại nhé.',
        );
      }
    } catch (_) {
      if (token == _speakToken && mounted) _snack('Không phát được âm thanh — thử lại nhé.');
    } finally {
      if (token == _speakToken && mounted) setState(() => _speakingId = _speakState = null);
    }
  }

  /// Xác nhận rồi kết thúc buổi. Lỗi → báo và giữ nguyên buổi mở (state chỉ
  /// đổi khi server trả về thành công), nút vẫn còn để thử lại.
  Future<void> _confirmEnd() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Kết thúc buổi luyện?'),
        content: const Text(
          'AI sẽ tóm tắt và chấm điểm cả buổi, điểm kỹ năng sẽ được cập nhật. '
          'Sau khi kết thúc, buổi này không nhận thêm tin nhắn — không hoàn tác được.',
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(false), child: const Text('Huỷ')),
          FilledButton(onPressed: () => Navigator.of(context).pop(true), child: const Text('Kết thúc')),
        ],
      ),
    );
    if (ok != true || !mounted) return;

    setState(() => _ending = true);
    try {
      await ref.read(sessionDetailProvider(widget.sessionId).notifier).endSession();
      // Trang chính Trà Đình: điểm kỹ năng mới + buổi này thành "Đã kết thúc".
      ref
        ..invalidate(skillScoresProvider)
        ..invalidate(practiceSessionsProvider);
    } on DioException catch (e) {
      if (mounted) {
        _snack('Không kết thúc được buổi (${e.response?.statusCode ?? e.type.name}) — buổi vẫn đang mở, thử lại nhé.');
      }
    } catch (_) {
      if (mounted) _snack('Không kết thúc được buổi — buổi vẫn đang mở, thử lại nhé.');
    } finally {
      if (mounted) setState(() => _ending = false);
    }
  }

  Future<void> _reloadQuietly() async {
    try {
      await ref.read(sessionDetailProvider(widget.sessionId).notifier).reload();
    } on DioException {
      // Giữ nguyên màn hình hiện tại; kéo xuống / mở lại sẽ tải lại.
    }
  }

  @override
  Widget build(BuildContext context) {
    final detail = ref.watch(sessionDetailProvider(widget.sessionId));
    final session = detail.value;
    // watch để giữ service (autoDispose) sống suốt màn hình.
    _recorder = ref.watch(recordingServiceProvider);
    // Rời màn → provider dispose AudioPlayer → tiếng tắt theo.
    _tts = ref.watch(ttsServiceProvider);

    return Scaffold(
      appBar: AppBar(
        title: session == null
            ? const Text('Buổi luyện')
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(session.name, maxLines: 1, overflow: TextOverflow.ellipsis),
                  Text(session.isEnded ? '${session.mode.label} · Đã kết thúc' : session.mode.label, style: _muted(12)),
                ],
              ),
        actions: [
          if (session != null && !session.isEnded)
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: TextButton(
                // Đang gửi/ghi âm/chuyển chữ thì chưa cho kết thúc — ô nhập sẽ biến
                // mất giữa chừng (vd mic còn ghi mà không còn nút dừng).
                onPressed: !_ending && _pending == null && _mic == _MicState.idle ? _confirmEnd : null,
                style: TextButton.styleFrom(foregroundColor: AppColors.shuiro500),
                child: Text(_ending ? 'Đang kết thúc...' : 'Kết thúc buổi'),
              ),
            ),
        ],
        bottom: _ending
            ? const PreferredSize(preferredSize: Size.fromHeight(2), child: LinearProgressIndicator(minHeight: 2))
            : null,
      ),
      body: switch (detail) {
        AsyncValue(value: final s?) => _ChatBody(
          session: s,
          pending: _pending,
          input: _input,
          onSend: _send,
          mic: _mic,
          recordSeconds: _recordSeconds,
          onMic: _toggleMic,
          speakingId: _speakingId,
          speakState: _speakState,
          onSpeak: _toggleSpeak,
          locked: _ending,
        ),
        AsyncValue(error: final e?) => _LoadError(
          message: e is DioException && e.response?.statusCode == 404
              ? 'Không tìm thấy buổi luyện này.'
              : 'Không tải được buổi luyện.',
          onRetry: () => ref.invalidate(sessionDetailProvider(widget.sessionId)),
        ),
        _ => const Center(child: CircularProgressIndicator()),
      },
    );
  }
}

class _ChatBody extends StatelessWidget {
  const _ChatBody({
    required this.session,
    required this.pending,
    required this.input,
    required this.onSend,
    required this.mic,
    required this.recordSeconds,
    required this.onMic,
    required this.speakingId,
    required this.speakState,
    required this.onSpeak,
    required this.locked,
  });

  final PracticeSession session;
  final String? pending;
  final TextEditingController input;
  final VoidCallback onSend;
  final _MicState mic;
  final int recordSeconds;
  final VoidCallback onMic;
  final String? speakingId;
  final _SpeakState? speakState;
  final void Function(PracticeMessage) onSpeak;

  /// Đang kết thúc buổi — khoá gửi và ghi âm.
  final bool locked;

  @override
  Widget build(BuildContext context) {
    final messages = session.messages;
    final sending = pending != null;
    // reverse: phần tử 0 nằm dưới cùng → luôn bám đáy, tin mới tự hiện mà
    // không cần cuộn tay. Thứ tự hiển thị: tin cũ trên, tin mới/đang gửi dưới.
    final items = <Widget>[
      if (sending) ...[const _TypingBubble(), _Bubble(text: pending!, isUser: true, dimmed: true)],
      for (final m in messages.reversed)
        _Bubble(
          key: ValueKey(m.id),
          text: m.content,
          isUser: m.isUser,
          speak: m.isUser
              ? null
              : _SpeakButton(state: speakingId == m.id ? speakState : null, onPressed: () => onSpeak(m)),
        ),
    ];

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 720),
        child: Column(
          children: [
            if (session.isEnded) _SummaryBox(summary: session.summary),
            Expanded(
              child: items.isEmpty
                  ? Center(child: Text('Bắt đầu trò chuyện bằng tiếng Anh nhé!', style: _muted(12)))
                  : ListView.separated(
                      reverse: true,
                      padding: const EdgeInsets.all(16),
                      itemCount: items.length,
                      separatorBuilder: (_, _) => const SizedBox(height: 12),
                      itemBuilder: (_, i) => items[i],
                    ),
            ),
            if (!session.isEnded)
              _InputBar(
                controller: input,
                sending: sending,
                onSend: onSend,
                mic: mic,
                recordSeconds: recordSeconds,
                onMic: onMic,
                locked: locked,
              ),
          ],
        ),
      ),
    );
  }
}

class _Bubble extends StatelessWidget {
  const _Bubble({super.key, required this.text, required this.isUser, this.dimmed = false, this.speak});

  final String text;
  final bool isUser;
  final bool dimmed;

  /// Nút đọc thành tiếng — chỉ tin AI có.
  final Widget? speak;

  @override
  Widget build(BuildContext context) {
    final bubble = Container(
      constraints: BoxConstraints(maxWidth: MediaQuery.sizeOf(context).width * 0.8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: isUser ? AppColors.kincha400.withValues(alpha: 0.1) : Colors.white.withValues(alpha: 0.05),
        border: Border.all(
          color: isUser ? AppColors.kincha400.withValues(alpha: 0.3) : Colors.white.withValues(alpha: 0.1),
        ),
        borderRadius: BorderRadius.circular(AppTheme.darkRadius),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          SelectableText(text, style: const TextStyle(fontSize: 13, height: 1.45)),
          ?speak,
        ],
      ),
    );
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: dimmed ? Opacity(opacity: 0.5, child: bubble) : bubble,
    );
  }
}

class _TypingBubble extends StatelessWidget {
  const _TypingBubble();

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.05),
          border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
          borderRadius: BorderRadius.circular(AppTheme.darkRadius),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          spacing: 8,
          children: [
            const SizedBox.square(dimension: 12, child: CircularProgressIndicator(strokeWidth: 1.5)),
            Text('Đang trả lời...', style: _muted(12)),
          ],
        ),
      ),
    );
  }
}

class _SummaryBox extends StatelessWidget {
  const _SummaryBox({required this.summary});

  final String? summary;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.kincha400.withValues(alpha: 0.05),
        border: Border.all(color: AppColors.kincha400.withValues(alpha: 0.3)),
        borderRadius: BorderRadius.circular(AppTheme.darkRadius),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 4,
        children: [
          const Text(
            'Tóm tắt buổi luyện',
            style: TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: AppColors.kincha400),
          ),
          // Web ẩn hẳn khung khi không có tóm tắt (AI lỗi) — ở đây vẫn hiện để
          // người dùng biết vì sao không còn ô nhập.
          Text(
            summary ?? 'Buổi luyện đã kết thúc (không có tóm tắt).',
            style: TextStyle(fontSize: 13, color: Colors.white.withValues(alpha: 0.8)),
          ),
        ],
      ),
    );
  }
}

class _InputBar extends StatelessWidget {
  const _InputBar({
    required this.controller,
    required this.sending,
    required this.onSend,
    required this.mic,
    required this.recordSeconds,
    required this.onMic,
    required this.locked,
  });

  final TextEditingController controller;
  final bool sending;
  final VoidCallback onSend;
  final _MicState mic;
  final int recordSeconds;
  final VoidCallback onMic;
  final bool locked;

  @override
  Widget build(BuildContext context) {
    // Đang ghi/chuyển chữ thì chưa gửi được (chữ sắp được điền vào ô); đang gửi
    // thì chưa ghi được.
    final canSend = !sending && !locked && mic == _MicState.idle && controller.text.trim().isNotEmpty;
    return DecoratedBox(
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: Colors.white.withValues(alpha: 0.1))),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Row(
            spacing: 8,
            children: [
              _MicButton(state: mic, seconds: recordSeconds, onPressed: sending || locked ? null : onMic),
              Expanded(
                child: TextField(
                  controller: controller,
                  minLines: 1,
                  maxLines: 4,
                  textInputAction: TextInputAction.send,
                  onSubmitted: (_) => onSend(),
                  style: const TextStyle(fontSize: 13),
                  decoration: const InputDecoration(hintText: 'Nhập câu tiếng Anh của bạn...', isDense: true),
                ),
              ),
              FilledButton(onPressed: canSend ? onSend : null, child: Text(sending ? '...' : 'Gửi')),
            ],
          ),
        ),
      ),
    );
  }
}

class _LoadError extends StatelessWidget {
  const _LoadError({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        spacing: 12,
        children: [
          Text(message, style: _muted(13)),
          OutlinedButton(onPressed: onRetry, child: const Text('Thử lại')),
        ],
      ),
    );
  }
}

/// Nút 🎙️: nghỉ → đang ghi (đỏ, nhấp nháy, đếm giây) → đang chuyển chữ (spinner).
class _MicButton extends StatefulWidget {
  const _MicButton({required this.state, required this.seconds, required this.onPressed});

  final _MicState state;
  final int seconds;
  final VoidCallback? onPressed;

  @override
  State<_MicButton> createState() => _MicButtonState();
}

class _MicButtonState extends State<_MicButton> with SingleTickerProviderStateMixin {
  late final _pulse = AnimationController(vsync: this, duration: const Duration(milliseconds: 900));

  @override
  void initState() {
    super.initState();
    _syncPulse();
  }

  @override
  void didUpdateWidget(_MicButton old) {
    super.didUpdateWidget(old);
    _syncPulse();
  }

  void _syncPulse() {
    if (widget.state == _MicState.recording) {
      if (!_pulse.isAnimating) _pulse.repeat(reverse: true);
    } else {
      _pulse
        ..stop()
        ..value = 0;
    }
  }

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final s = widget.seconds;
    return switch (widget.state) {
      _MicState.idle => IconButton(tooltip: 'Ghi âm', onPressed: widget.onPressed, icon: const Icon(Icons.mic_none)),
      _MicState.recording => Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          FadeTransition(
            opacity: Tween(begin: 1.0, end: 0.45).animate(_pulse),
            child: IconButton(
              tooltip: 'Dừng ghi',
              onPressed: widget.onPressed,
              style: IconButton.styleFrom(backgroundColor: AppColors.shuiro500.withValues(alpha: 0.2)),
              icon: const Icon(Icons.stop_rounded, color: AppColors.shuiro500),
            ),
          ),
          Text(
            '${s ~/ 60}:${(s % 60).toString().padLeft(2, '0')}',
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.shuiro500,
              fontFeatures: [FontFeature.tabularFigures()],
            ),
          ),
        ],
      ),
      _MicState.transcribing => const Tooltip(
        message: 'Đang chuyển giọng nói thành chữ',
        child: Padding(
          padding: EdgeInsets.all(12),
          child: SizedBox.square(dimension: 20, child: CircularProgressIndicator(strokeWidth: 2)),
        ),
      ),
    };
  }
}

/// Nút đọc tin AI: nghỉ "Phát" → "Đang tải..." (gọi /speak) → "Dừng" (đang phát).
class _SpeakButton extends StatelessWidget {
  const _SpeakButton({required this.state, required this.onPressed});

  /// null = nghỉ.
  final _SpeakState? state;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final (Widget icon, String label) = switch (state) {
      null => (const Icon(Icons.volume_up_outlined, size: 16), 'Phát'),
      _SpeakState.loading => (
        const SizedBox.square(dimension: 12, child: CircularProgressIndicator(strokeWidth: 1.5)),
        'Đang tải...',
      ),
      _SpeakState.playing => (const Icon(Icons.stop_circle_outlined, size: 16), 'Dừng'),
    };
    return TextButton.icon(
      onPressed: onPressed,
      icon: icon,
      label: Text(label),
      style: TextButton.styleFrom(
        foregroundColor: AppColors.kincha400,
        textStyle: const TextStyle(fontSize: 11),
        padding: const EdgeInsets.symmetric(horizontal: 4),
        minimumSize: const Size(0, 28),
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
    );
  }
}

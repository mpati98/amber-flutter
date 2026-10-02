import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/theme/app_theme.dart';
import '../models/practice_session.dart';
import '../providers/tra_dinh_provider.dart';

TextStyle _muted(double size) => TextStyle(fontSize: size, color: Colors.white.withValues(alpha: 0.4));

/// Mã lỗi `{error: "..."}` trong response, nếu có.
String? _errorCode(DioException e) {
  final data = e.response?.data;
  return data is Map && data['error'] is String ? data['error'] as String : null;
}

/// Port /tra-dinh/[sessionId] — phần tin nhắn văn bản. Chưa có ghi âm, phát
/// audio, kết thúc buổi.
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

  @override
  void initState() {
    super.initState();
    _input.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _input.dispose();
    super.dispose();
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
      ),
      body: switch (detail) {
        AsyncValue(value: final s?) => _ChatBody(session: s, pending: _pending, input: _input, onSend: _send),
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
  const _ChatBody({required this.session, required this.pending, required this.input, required this.onSend});

  final PracticeSession session;
  final String? pending;
  final TextEditingController input;
  final VoidCallback onSend;

  @override
  Widget build(BuildContext context) {
    final messages = session.messages;
    final sending = pending != null;
    // reverse: phần tử 0 nằm dưới cùng → luôn bám đáy, tin mới tự hiện mà
    // không cần cuộn tay. Thứ tự hiển thị: tin cũ trên, tin mới/đang gửi dưới.
    final items = <Widget>[
      if (sending) ...[const _TypingBubble(), _Bubble(text: pending!, isUser: true, dimmed: true)],
      for (final m in messages.reversed) _Bubble(text: m.content, isUser: m.isUser),
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
            if (!session.isEnded) _InputBar(controller: input, sending: sending, onSend: onSend),
          ],
        ),
      ),
    );
  }
}

class _Bubble extends StatelessWidget {
  const _Bubble({required this.text, required this.isUser, this.dimmed = false});

  final String text;
  final bool isUser;
  final bool dimmed;

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
      child: SelectableText(text, style: const TextStyle(fontSize: 13, height: 1.45)),
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
  const _InputBar({required this.controller, required this.sending, required this.onSend});

  final TextEditingController controller;
  final bool sending;
  final VoidCallback onSend;

  @override
  Widget build(BuildContext context) {
    final canSend = !sending && controller.text.trim().isNotEmpty;
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

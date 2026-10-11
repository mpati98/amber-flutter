import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/theme/app_theme.dart';
import '../../../shared/utils/api_error.dart';
import '../../../shared/widgets/scroll_card.dart';
import '../../../shared/widgets/tag.dart';
import '../models/training_log.dart';
import '../providers/training_log_provider.dart';
import '../services/training_log_api.dart';
import '../widgets/outcome_tag.dart';
import 'training_logs_screen.dart' show formatLogTime;

const _pretty = JsonEncoder.withIndent('  ');

/// Chuỗi hiển thị cho một giá trị JSON: chuỗi giữ nguyên, còn lại in đẹp.
String showJson(Object? v) => v == null ? '—' : (v is String ? v : _pretty.convert(v));

/// Chi tiết một dòng nhật ký. Chỉ ĐỌC nội dung; hành động duy nhất là đánh giá đúng/sai và bật/tắt loại khỏi dataset.
class TrainingLogDetailScreen extends ConsumerStatefulWidget {
  const TrainingLogDetailScreen({super.key, required this.logId});

  final String logId;

  @override
  ConsumerState<TrainingLogDetailScreen> createState() => _TrainingLogDetailScreenState();
}

class _TrainingLogDetailScreenState extends ConsumerState<TrainingLogDetailScreen> {
  bool _busy = false;

  Future<void> _act(Future<void> Function(TrainingLogApi api) call, String failure) async {
    setState(() => _busy = true);
    final messenger = ScaffoldMessenger.of(context);
    try {
      await call(ref.read(trainingLogApiProvider));
      ref.invalidate(trainingLogDetailProvider(widget.logId));
      ref.invalidate(trainingStatsProvider);   // đổi đánh giá/cờ loại làm đổi số mẫu đủ điều kiện
      ref.invalidate(logListProvider);
    } catch (e) {
      messenger.showSnackBar(SnackBar(content: Text(apiErrorMessage(e, failure))));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final detail = ref.watch(trainingLogDetailProvider(widget.logId));
    return Scaffold(
      appBar: AppBar(title: const Text('Chi tiết nhật ký')),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 640),
          child: detail.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (_, _) => Center(
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                const Text('Không tải được dòng nhật ký.'),
                TextButton(onPressed: () => ref.invalidate(trainingLogDetailProvider(widget.logId)), child: const Text('Thử lại')),
              ]),
            ),
            data: _body,
          ),
        ),
      ),
    );
  }

  Widget _body(TrainingLogDetail d) {
    final s = d.summary;
    final muted = TextStyle(fontSize: 12, color: Colors.white.withValues(alpha: 0.5));
    return ListView(padding: const EdgeInsets.all(16), children: [
      Wrap(spacing: 8, runSpacing: 4, crossAxisAlignment: WrapCrossAlignment.center, children: [
        Text(formatLogTime(s.createdAt), style: muted),
        Tag(label: agentLabel(s.agent), color: AppColors.shuiro500, foregroundColor: Colors.white.withValues(alpha: 0.8)),
        OutcomeTag(s.outcome),
        ToolStatus(toolName: s.toolName, toolOk: s.toolOk),
      ]),
      const SizedBox(height: 16),
      _Section('Câu gốc', child: SelectableText(s.userInput.isEmpty ? '(không có)' : s.userInput)),
      _Section('Đề xuất của model', child: _Code(showJson(d.parsedOutput))),
      if (d.correctedOutput != null)
        _Section('Bản đã sửa', note: d.correctedAt == null ? null : 'Sửa lúc ${formatLogTime(d.correctedAt!)}', child: _Code(showJson(d.correctedOutput))),
      if (d.error != null && d.error!.isNotEmpty)
        _Section('Lỗi', child: SelectableText(d.error!, style: const TextStyle(color: AppColors.shuiro500))),
      _Section('Thông số', child: Text(_metrics(d), style: muted.copyWith(fontSize: 13, height: 1.6))),
      _Collapsible('messages (gửi vào model)', showJson(d.messages)),
      _Collapsible('tools (gửi kèm)', showJson(d.tools)),
      _Collapsible('raw_output (output thô)', d.rawOutput ?? '—'),
      _Collapsible('Kết quả tool', showJson(d.json['toolResult'])),
      const SizedBox(height: 16),
      Text('Đánh giá', style: Theme.of(context).textTheme.titleSmall),
      const SizedBox(height: 8),
      Row(children: [
        Expanded(
          child: FilledButton.tonalIcon(
            onPressed: _busy ? null : () => _act((api) => api.feedback(s.id, correct: true), 'Không gửi được đánh giá.'),
            icon: Icon(s.outcome == LogOutcome.accepted ? Icons.thumb_up : Icons.thumb_up_outlined),
            label: const Text('Đúng'),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: FilledButton.tonalIcon(
            onPressed: _busy ? null : () => _act((api) => api.feedback(s.id, correct: false), 'Không gửi được đánh giá.'),
            icon: Icon(s.outcome == LogOutcome.rejected ? Icons.thumb_down : Icons.thumb_down_outlined),
            label: const Text('Sai'),
          ),
        ),
      ]),
      SwitchListTile(
        contentPadding: EdgeInsets.zero,
        title: const Text('Loại khỏi dataset'),
        subtitle: const Text('Mẫu này sẽ không được xuất để huấn luyện.'),
        value: s.excludeFromTraining,
        onChanged: _busy ? null : (v) => _act((api) => api.setExcluded(s.id, v), 'Không đổi được cờ loại khỏi dataset.'),
      ),
    ]);
  }

  static String _metrics(TrainingLogDetail d) {
    String v(Object? x) => x?.toString() ?? '—';
    return 'Độ trễ: ${d.latencyMs == null ? '—' : '${d.latencyMs} ms'}\n'
        'Token: vào ${v(d.promptTokens)} · ra ${v(d.completionTokens)}\n'
        'Model: ${v(d.modelName)} · adapter ${v(d.adapterVersion)} · prompt ${v(d.promptVersion)}\n'
        'Ngôn ngữ: ${v(d.lang)} · lượt ${v(d.turnIndex)}'
        '${d.entityId == null ? '' : '\nBản ghi tạo ra: ${v(d.entityType)} ${d.entityId}'}';
  }
}

class _Section extends StatelessWidget {
  const _Section(this.title, {required this.child, this.note});

  final String title;
  final String? note;
  final Widget child;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 16),
        child: ScrollCard(
          glow: ScrollCardGlow.yugen,
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(title.toUpperCase(), style: TextStyle(fontSize: 11, letterSpacing: 0.6, color: AppColors.kincha400.withValues(alpha: 0.8))),
            if (note != null) Text(note!, style: TextStyle(fontSize: 11, color: Colors.white.withValues(alpha: 0.4))),
            const SizedBox(height: 8),
            child,
          ]),
        ),
      );
}

class _Code extends StatelessWidget {
  const _Code(this.text);

  final String text;

  @override
  Widget build(BuildContext context) => SelectableText(text, style: const TextStyle(fontFamily: 'monospace', fontSize: 12, height: 1.5));
}

/// Khối lớn thu gọn: nội dung chỉ được dựng khi bấm mở.
class _Collapsible extends StatelessWidget {
  const _Collapsible(this.title, this.text);

  final String title;
  final String text;

  @override
  Widget build(BuildContext context) => ExpansionTile(
        tilePadding: EdgeInsets.zero,
        title: Text(title, style: const TextStyle(fontSize: 14)),
        expandedAlignment: Alignment.centerLeft,
        children: [Padding(padding: const EdgeInsets.only(bottom: 12), child: _Code(text))],
      );
}

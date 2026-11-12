import 'dart:convert';

import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/theme/design_tokens.dart';
import '../../../shared/utils/api_error.dart';
import '../../../shared/widgets/app_toast.dart';
import '../../../shared/widgets/design_page.dart';
import '../../../shared/widgets/form_bits.dart';
import '../../../shared/widgets/list_frame.dart';
import '../../../shared/widgets/overview_block.dart';
import '../models/training_log.dart';
import '../providers/training_log_provider.dart';
import '../services/training_log_api.dart';
import '../widgets/training_log_correction_sheet.dart';
import '../widgets/outcome_tag.dart';
import 'training_logs_screen.dart' show formatLogTime;

const _pretty = JsonEncoder.withIndent('  ');

/// Chuỗi hiển thị cho một giá trị JSON: chuỗi giữ nguyên, còn lại in đẹp.
String showJson(Object? v) =>
    v == null ? '—' : (v is String ? v : _pretty.convert(v));

/// Chi tiết một dòng nhật ký. Chỉ ĐỌC nội dung; hành động duy nhất là đánh giá đúng/sai và bật/tắt loại khỏi dataset.
class TrainingLogDetailScreen extends ConsumerStatefulWidget {
  const TrainingLogDetailScreen({super.key, required this.logId});

  final String logId;

  @override
  ConsumerState<TrainingLogDetailScreen> createState() =>
      _TrainingLogDetailScreenState();
}

class _TrainingLogDetailScreenState
    extends ConsumerState<TrainingLogDetailScreen> {
  bool _busy = false;

  Future<void> _act(
    Future<void> Function(TrainingLogApi api) call,
    String failure,
  ) async {
    setState(() => _busy = true);
    try {
      await call(ref.read(trainingLogApiProvider));
      ref.invalidate(trainingLogDetailProvider(widget.logId));
      ref.invalidate(
        trainingStatsProvider,
      ); // đổi đánh giá/cờ loại làm đổi số mẫu đủ điều kiện
      ref.invalidate(logListProvider);
    } catch (e) {
      if (mounted) showToast(context, apiErrorMessage(e, failure), type: ToastType.error);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _editCorrection(TrainingLogDetail detail) async {
    final updated = await showFinanceSheet<bool>(
      context,
      TrainingLogCorrectionSheet(
        logId: detail.summary.id,
        initialValue: detail.correctedOutput ?? detail.parsedOutput,
        hasCorrection: detail.correctedOutput != null,
      ),
    );
    if (!mounted || updated != true) return;
    ref.invalidate(trainingLogDetailProvider(widget.logId));
    ref.invalidate(trainingStatsProvider);
    ref.invalidate(logListProvider);
  }

  @override
  Widget build(BuildContext context) {
    final detail = ref.watch(trainingLogDetailProvider(widget.logId));
    final d = detail.value;
    return DesignPage(
      title: 'Chi tiết nhật ký',
      backFallback: '/tang-kinh-cac/du-lieu-huan-luyen',
      overview: d == null
          ? OverviewBlock(
              title: 'Nhật ký',
              labelWidth: 90,
              rows: [OverviewRow.muted(label: 'Trạng thái', text: detail.hasError ? 'Không tải được.' : 'Đang tải…')],
            )
          : _overview(d),
      content: (context, _) => ListFrame(
        child: detail.when(
          loading: () => const Padding(
            padding: EdgeInsets.all(24),
            child: Center(child: CircularProgressIndicator(color: DesignColors.gold)),
          ),
          error: (_, _) => Column(
            spacing: 8,
            children: [
              const Text('Không tải được dòng nhật ký.', style: DesignText.muted),
              DesignButton.outline(
                label: 'Thử lại',
                onPressed: () => ref.invalidate(trainingLogDetailProvider(widget.logId)),
              ),
            ],
          ),
          data: _body,
        ),
      ),
    );
  }

  /// Tổng quan: thời điểm, agent + kết quả + công cụ, tuyến, thông số.
  Widget _overview(TrainingLogDetail d) {
    final s = d.summary;
    return OverviewBlock(
      title: 'Nhật ký',
      labelWidth: 90,
      rows: [
        OverviewRow.muted(label: 'Thời điểm', text: formatLogTime(s.createdAt)),
        OverviewRow(
          label: 'Kết quả',
          child: Wrap(
            spacing: 6,
            runSpacing: 4,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              DesignPill(agentLabel(s.agent), color: DesignColors.muted),
              OutcomeTag(s.outcome),
              ToolStatus(toolName: s.toolName, toolOk: s.toolOk),
            ],
          ),
        ),
        if (s.route case final route?)
          OverviewRow(
            label: 'Tuyến',
            child: Align(
              alignment: Alignment.centerLeft,
              child: DesignPill(
                route == TrainingRoute.cloud && s.cloudModel != null ? 'CLOUD · ${s.cloudModel}' : route.apiValue,
                color: route == TrainingRoute.cloud ? DesignColors.info : DesignColors.gold,
              ),
            ),
          ),
        OverviewRow(
          label: 'Thông số',
          child: Text(_metrics(d), style: DesignText.muted.copyWith(height: 1.6)),
        ),
      ],
    );
  }

  Widget _body(TrainingLogDetail d) {
    final s = d.summary;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: 10,
      children: [
        _Section('Câu gốc', child: SelectableText(s.userInput.isEmpty ? '(không có)' : s.userInput, style: DesignText.body)),
        _Section('Đề xuất của model', child: _Code(showJson(d.parsedOutput))),
        if (d.correctedOutput != null)
          _Section(
            'Bản đã sửa',
            note: d.correctedAt == null ? null : 'Sửa lúc ${formatLogTime(d.correctedAt!)}',
            child: _Code(showJson(d.correctedOutput)),
          ),
        Align(
          alignment: Alignment.centerLeft,
          child: DesignButton.outline(label: 'Sửa đáp án', onPressed: _busy ? null : () => _editCorrection(d)),
        ),
        if (d.error != null && d.error!.isNotEmpty)
          _Section('Lỗi', child: SelectableText(d.error!, style: const TextStyle(color: DesignColors.danger))),
        _Collapsible('messages (gửi vào model)', showJson(d.messages)),
        _Collapsible('tools (gửi kèm)', showJson(d.tools)),
        _Collapsible('raw_output (output thô)', d.rawOutput ?? '—'),
        _Collapsible('Kết quả tool', showJson(d.json['toolResult'])),
        const Padding(
          padding: EdgeInsets.only(top: 6),
          child: Text('ĐÁNH GIÁ', style: TextStyle(fontSize: 13, letterSpacing: 1, color: DesignColors.gold)),
        ),
        Row(
          spacing: 10,
          children: [
            Expanded(
              child: _VoteButton(
                label: 'Đúng',
                icon: s.outcome == LogOutcome.accepted ? Icons.thumb_up : Icons.thumb_up_outlined,
                on: s.outcome == LogOutcome.accepted,
                onPressed: _busy ? null : () => _act((api) => api.feedback(s.id, correct: true), 'Không gửi được đánh giá.'),
              ),
            ),
            Expanded(
              child: _VoteButton(
                label: 'Sai',
                icon: s.outcome == LogOutcome.rejected ? Icons.thumb_down : Icons.thumb_down_outlined,
                on: s.outcome == LogOutcome.rejected,
                onPressed: _busy ? null : () => _act((api) => api.feedback(s.id, correct: false), 'Không gửi được đánh giá.'),
              ),
            ),
          ],
        ),
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          activeThumbColor: DesignColors.gold,
          title: Text('Loại khỏi dataset', style: DesignText.bold),
          subtitle: const Text('Mẫu này sẽ không được xuất để huấn luyện.', style: DesignText.muted),
          value: s.excludeFromTraining,
          onChanged: _busy
              ? null
              : (v) => _act((api) => api.setExcluded(s.id, v), 'Không đổi được cờ loại khỏi dataset.'),
        ),
      ],
    );
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
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
    decoration: BoxDecoration(
      color: DesignColors.panel,
      border: Border.all(color: DesignColors.panelBorder),
      borderRadius: BorderRadius.circular(8),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title.toUpperCase(), style: const TextStyle(fontSize: 12, letterSpacing: 1, color: DesignColors.gold)),
        if (note != null) Text(note!, style: DesignText.muted),
        const SizedBox(height: 8),
        child,
      ],
    ),
  );
}

class _Code extends StatelessWidget {
  const _Code(this.text);

  final String text;

  @override
  Widget build(BuildContext context) => SelectableText(
    text,
    style: const TextStyle(fontFamily: 'monospace', fontSize: 12, height: 1.5, color: DesignColors.text),
  );
}

/// Khối lớn thu gọn: nội dung chỉ được dựng khi bấm mở.
class _Collapsible extends StatelessWidget {
  const _Collapsible(this.title, this.text);

  final String title;
  final String text;

  @override
  Widget build(BuildContext context) => Material(
    color: DesignColors.panel,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(8),
      side: const BorderSide(color: DesignColors.panelBorder),
    ),
    clipBehavior: Clip.antiAlias,
    child: ExpansionTile(
      tilePadding: const EdgeInsets.symmetric(horizontal: 12),
      childrenPadding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
      shape: const Border(),
      collapsedShape: const Border(),
      iconColor: DesignColors.gold,
      collapsedIconColor: DesignColors.muted,
      title: Text(title, style: DesignText.body),
      expandedAlignment: Alignment.centerLeft,
      children: [_Code(text)],
    ),
  );
}

/// Nút Đúng / Sai: viền vàng; nền vàng nhạt khi đây là đánh giá hiện tại.
class _VoteButton extends StatelessWidget {
  const _VoteButton({required this.label, required this.icon, required this.on, required this.onPressed});

  final String label;
  final IconData icon;
  final bool on;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) => OutlinedButton.icon(
    onPressed: onPressed,
    icon: Icon(icon, size: 18),
    label: Text(label),
    style: OutlinedButton.styleFrom(
      foregroundColor: DesignColors.gold,
      backgroundColor: on ? DesignColors.gold.withValues(alpha: 0.12) : null,
      side: const BorderSide(color: DesignColors.gold),
      minimumSize: const Size(0, 40),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
      textStyle: DesignText.serif(fontSize: 14),
    ),
  );
}

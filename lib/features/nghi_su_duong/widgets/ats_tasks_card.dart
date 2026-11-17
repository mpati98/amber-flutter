import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/theme/app_theme.dart';
import '../../../shared/theme/design_tokens.dart';
import '../../../shared/utils/api_error.dart';
import '../../../shared/utils/date_format.dart';
import '../../../shared/widgets/app_toast.dart';
import '../../../shared/widgets/form_bits.dart';
import '../../../shared/widgets/list_frame.dart';
import '../../../shared/widgets/scroll_card.dart';
import '../../../shared/widgets/tag.dart';
import '../models/ats_task.dart';
import '../providers/ats_tasks_provider.dart';
import '../services/ats_tasks_api.dart';

/// Màu chip trạng thái — lấy từ theme: Chưa làm = chữ phụ, Đang làm = primary (vàng), Chờ = secondary, Xong = success.
Color atsStatusColor(BuildContext context, AtsTaskStatus s) {
  final theme = Theme.of(context);
  return switch (s) {
    AtsTaskStatus.prep => theme.textMuted,
    AtsTaskStatus.inProgress => theme.colorScheme.primary,
    AtsTaskStatus.waiting => theme.colorScheme.secondary,
    AtsTaskStatus.done => theme.success,
  };
}

/// "Tên dự án · Hội chợ" (bỏ phần trống); không có dự án → "Không thuộc dự án".
String atsProjectLine(AtsProject? p) {
  if (p == null) return 'Không thuộc dự án';
  final parts = [if (p.name.isNotEmpty) p.name, if (p.typeLabel.isNotEmpty) p.typeLabel];
  return parts.isEmpty ? 'Không rõ dự án' : parts.join(' · ');
}

/// Khối "Công việc ATS" trên màn Dự án: việc công ty đồng bộ một chiều từ ats-app, CHỈ ĐỌC (không sửa / xoá / tạo).
/// Thứ tự giữ nguyên như server trả (OVERDUE → theo hạn → DONE cuối).
class AtsTasksCard extends ConsumerStatefulWidget {
  const AtsTasksCard({super.key});

  @override
  ConsumerState<AtsTasksCard> createState() => _AtsTasksCardState();
}

class _AtsTasksCardState extends ConsumerState<AtsTasksCard> {
  bool _syncing = false;
  bool _showDone = false;

  Future<void> _sync() async {
    if (_syncing) return;
    setState(() => _syncing = true);
    try {
      final r = await ref.read(atsTasksApiProvider).syncNow();
      ref.invalidate(atsTasksProvider);
      if (!mounted) return;
      showToast(
        context,
        r.changed ? 'Đã đồng bộ: thêm ${r.inserted} · sửa ${r.updated} · xoá ${r.deleted}' : 'Đã đồng bộ, không có thay đổi',
        type: ToastType.success,
      );
    } catch (e) {
      if (!mounted) return;
      // Tải lại trong mọi trường hợp: 429 nghĩa là vừa có lần đồng bộ khác (vd đồng bộ nền khi mở màn lần đầu) —
      // danh sách đang hiện có thể đã cũ; lỗi khác thì server đã ghi lastError, dòng trạng thái cần cập nhật.
      ref.invalidate(atsTasksProvider);
      final wait = atsRetryAfterSeconds(e);
      if (wait != null) {
        showToast(context, 'Thử lại sau $wait giây', type: ToastType.warning);
      } else {
        showToast(context, apiErrorMessage(e, 'Không đồng bộ được, thử lại sau.'), type: ToastType.error);
      }
    } finally {
      if (mounted) setState(() => _syncing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final muted = TextStyle(fontSize: 12, color: theme.textMuted);
    final async = ref.watch(atsTasksProvider);
    final includeAll = ref.watch(atsIncludeAllProvider);
    // Có giá trị (kể cả cũ khi đang tải lại) → dữ liệu; chưa có mà đã lỗi → lỗi ngay (Riverpod tự thử lại trong nền).
    final data = async.value;
    final failed = data == null && async.hasError;

    final open = data?.tasks.where((t) => !t.isDone).toList();
    final done = data?.tasks.where((t) => t.isDone).toList();
    final showDone = includeAll || _showDone;

    return ScrollCard(
      key: const ValueKey('ats-tasks-card'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: 8,
        children: [
          // Wrap: khung hẹp / chữ phóng to thì nút xuống dòng dưới tiêu đề thay vì tràn.
          Wrap(
            spacing: 8,
            runSpacing: 6,
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Text.rich(
                TextSpan(
                  children: [
                    TextSpan(text: 'Công việc ATS', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: cs.primary)),
                    if (open != null) TextSpan(text: '  ${open.length} chưa xong', style: muted),
                  ],
                ),
              ),
              DesignButton.outline(
                key: const ValueKey('ats-sync'),
                label: _syncing ? 'Đang đồng bộ…' : 'Đồng bộ ngay',
                onPressed: _syncing ? null : _sync,
              ),
            ],
          ),
          if (data != null) _SyncLine(sync: data.sync),
          if (failed)
            Row(
              spacing: 8,
              children: [
                Expanded(child: Text('Không tải được việc ATS.', key: const ValueKey('ats-load-error'), style: muted)),
                TextButton(onPressed: () => ref.invalidate(atsTasksProvider), child: const Text('Thử lại')),
              ],
            )
          else if (data == null)
            Text('Đang tải...', style: muted)
          else if (data.tasks.isEmpty)
            Text('Không có việc ATS nào', key: const ValueKey('ats-empty'), style: muted)
          else ...[
            if (open!.isEmpty) Text('Không còn việc nào chưa xong.', style: muted),
            for (final t in open) AtsTaskRow(task: t),
            if (showDone) for (final t in done!) AtsTaskRow(task: t),
          ],
          if (data != null)
            Wrap(
              spacing: 4,
              children: [
                if (!includeAll && done!.isNotEmpty)
                  TextButton(
                    key: const ValueKey('ats-toggle-done'),
                    onPressed: () => setState(() => _showDone = !_showDone),
                    child: Text(_showDone ? 'Ẩn việc đã xong' : 'Xem cả việc đã xong (${done.length})'),
                  ),
                TextButton(
                  key: const ValueKey('ats-toggle-all'),
                  onPressed: () => ref.read(atsIncludeAllProvider.notifier).set(!includeAll),
                  child: Text(includeAll ? 'Chỉ việc hiện hành' : 'Xem tất cả (gồm lưu trữ)'),
                ),
              ],
            ),
        ],
      ),
    );
  }
}

/// Dòng phụ dưới tiêu đề: lỗi đồng bộ (màu cảnh báo) > "Cập nhật lúc HH:mm dd/MM" (giờ VN) > "Chưa đồng bộ".
class _SyncLine extends StatelessWidget {
  const _SyncLine({required this.sync});

  final AtsSyncState sync;

  @override
  Widget build(BuildContext context) {
    final muted = TextStyle(fontSize: 12, color: Theme.of(context).textMuted);
    final err = sync.lastError;
    if (err != null) {
      return Text(
        'Lỗi đồng bộ: $err',
        key: const ValueKey('ats-sync-error'),
        maxLines: 3,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(fontSize: 12, color: DesignColors.warning),
      );
    }
    final at = sync.lastSuccessAt;
    return Text(
      at == null ? 'Chưa đồng bộ' : 'Cập nhật lúc ${formatVnTimeDayMonth(at)}',
      key: const ValueKey('ats-sync-line'),
      style: muted,
    );
  }
}

/// Một việc ATS: tên, dự án + loại, hạn, chip trạng thái, nhãn "Quá hạn". Việc xong hiện mờ. Chạm → chi tiết chỉ đọc.
class AtsTaskRow extends StatelessWidget {
  const AtsTaskRow({super.key, required this.task});

  final AtsTask task;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final muted = TextStyle(fontSize: 12, color: theme.textMuted);
    final t = task;
    final meta = [
      atsProjectLine(t.project),
      if (t.dueDate != null) 'Hạn ${formatDayMonth(t.dueDate!)}',
    ].join(' · ');

    return Opacity(
      opacity: t.isDone ? 0.5 : 1,
      child: InkWell(
        key: ValueKey('ats-task-${t.id}'),
        onTap: () => showAtsTaskDetail(context, t),
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 48),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 4,
              children: [
                Text(
                  t.title.isEmpty ? '(Không có tên)' : t.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 14, color: cs.onSurface),
                ),
                Text(meta, maxLines: 2, overflow: TextOverflow.ellipsis, style: muted),
                // Nhãn của một dòng (không phải hàng chip lọc) — Wrap để chữ ×2 ở 320 px không tràn.
                Wrap(
                  spacing: 6,
                  runSpacing: 4,
                  children: [
                    Tag(label: t.status.label, color: atsStatusColor(context, t.status), variant: TagVariant.tonal),
                    if (t.overdue) Tag(key: ValueKey('ats-overdue-${t.id}'), label: 'Quá hạn', color: cs.error),
                    if (t.project?.archived == true) Tag(label: 'Lưu trữ', color: theme.textMuted),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Chi tiết một việc ATS — chỉ đọc, không có nút sửa / xoá. Mở bằng showFinanceSheet như chi tiết việc của dự án.
Future<void> showAtsTaskDetail(BuildContext context, AtsTask task) =>
    showFinanceSheet<void>(context, AtsTaskDetailPage(task: task));

class AtsTaskDetailPage extends StatelessWidget {
  const AtsTaskDetailPage({super.key, required this.task});

  final AtsTask task;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final muted = TextStyle(fontSize: 13, color: theme.textMuted);
    final t = task;
    Widget row(String label, Widget value) => Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 12,
        children: [
          SizedBox(width: 90, child: Text(label, style: muted)),
          Expanded(child: value),
        ],
      ),
    );
    Text text(String s) => Text(s, style: TextStyle(fontSize: 14, color: theme.colorScheme.onSurface));

    return FinanceSheetBody(
      title: 'Việc ATS',
      children: [
        Text(
          t.title.isEmpty ? '(Không có tên)' : t.title,
          key: const ValueKey('ats-detail-title'),
          style: TextStyle(fontSize: 18, color: theme.colorScheme.onSurface),
        ),
        const SizedBox(height: 8),
        row('Dự án', text(t.project == null ? 'Không thuộc dự án' : (t.project!.name.isEmpty ? 'Không rõ' : t.project!.name))),
        row('Loại', text(t.project?.typeLabel.isNotEmpty == true ? t.project!.typeLabel : '—')),
        row('Hạn', text(t.dueDate == null ? 'Không có hạn' : formatDayMonth(t.dueDate!))),
        row(
          'Trạng thái',
          Align(
            alignment: Alignment.centerLeft,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              spacing: 6,
              children: [
                Tag(label: t.status.label, color: atsStatusColor(context, t.status), variant: TagVariant.tonal),
                if (t.overdue) Tag(label: 'Quá hạn', color: theme.colorScheme.error),
              ],
            ),
          ),
        ),
        row('Ngày xong', text(t.doneAt == null ? '—' : formatVnDate(t.doneAt!))),
        if (t.project?.archived == true) row('Dự án', text('Đã lưu trữ trên ats-app')),
        const SizedBox(height: 16),
        Text('Sửa trên ats-app — trong Amber chỉ xem.', key: const ValueKey('ats-detail-note'), style: muted),
      ],
    );
  }
}

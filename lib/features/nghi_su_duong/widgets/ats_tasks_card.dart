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
import '../utils/ats_grouping.dart';

/// Số dòng việc hiện tối đa trước nút "Xem thêm N" (không tính tiêu đề nhóm).
const atsMaxLines = 6;

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

/// Chip trạng thái trên dòng gọn: chỉ Đang làm, Chờ, Xong. "Chưa làm" không có chip.
bool atsShowsStatusChip(AtsTaskStatus s) => s != AtsTaskStatus.prep;

/// Khối "Công việc ATS" trên màn Dự án: việc công ty đồng bộ một chiều từ ats-app, CHỈ ĐỌC (không sửa / xoá / tạo).
/// Gom theo dự án, mỗi việc một dòng, việc trùng gộp "×N", tối đa [atsMaxLines] dòng rồi "Xem thêm N".
///
/// [fill] (bố cục dashboard của màn Dự án): thẻ lấp chiều cao cha cấp; đầu thẻ cố định, danh sách cuộn bên trong,
/// không cắt 6 dòng. Mặc định false: cao theo nội dung (điện thoại / máy tính bảng / web thấp).
class AtsTasksCard extends ConsumerStatefulWidget {
  const AtsTasksCard({super.key, this.fill = false});

  final bool fill;

  @override
  ConsumerState<AtsTasksCard> createState() => _AtsTasksCardState();
}

enum _MenuAction { toggleDone, toggleAll }

class _AtsTasksCardState extends ConsumerState<AtsTasksCard> {
  bool _syncing = false;
  bool _showDone = false;
  bool _expanded = false;

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

  void _onMenu(_MenuAction a, bool includeAll) {
    switch (a) {
      case _MenuAction.toggleDone:
        setState(() => _showDone = !_showDone);
      case _MenuAction.toggleAll:
        ref.read(atsIncludeAllProvider.notifier).set(!includeAll);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final muted = TextStyle(fontSize: 12, color: theme.textMuted);
    final async = ref.watch(atsTasksProvider);
    final includeAll = ref.watch(atsIncludeAllProvider);
    // Có giá trị (kể cả cũ khi đang tải lại) → dữ liệu; chưa có mà đã lỗi → lỗi ngay.
    final data = async.value;
    final failed = data == null && async.hasError;

    final openCount = data?.openCount;
    final doneCount = data == null ? 0 : data.tasks.length - data.openCount;
    final showDone = includeAll || _showDone;
    final shown = data?.tasks.where((t) => showDone || !t.isDone).toList();
    final groups = shown == null ? null : groupAtsTasks(shown);
    // fill: danh sách cuộn trong thẻ nên không cần cắt 6 dòng / "Xem thêm".
    final limited = groups == null ? null : (_expanded || widget.fill ? (groups: groups, hidden: 0) : limitAtsLines(groups, atsMaxLines));
    final totalLines = groups?.fold<int>(0, (n, g) => n + g.lines.length) ?? 0;

    final syncState = data?.sync;
    final err = syncState?.lastError;

    // Đầu thẻ (luôn cố định ở chế độ fill): tiêu đề, cập nhật / lỗi đồng bộ, nút.
    final header = <Widget>[
      // Tiêu đề trái; "Cập nhật lúc…" + nút + ⋯ phải. Không đủ rộng thì cụm phải xuống dòng (Wrap).
      Wrap(
        spacing: 8,
        runSpacing: 6,
        alignment: WrapAlignment.spaceBetween,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          Text.rich(
            TextSpan(
              children: [
                TextSpan(
                  text: 'Công việc ATS',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: cs.primary),
                ),
                if (openCount != null) TextSpan(text: '  $openCount chưa xong', style: muted),
              ],
            ),
          ),
          Wrap(
            spacing: 6,
            runSpacing: 4,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              if (syncState != null && err == null)
                Text(
                  syncState.lastSuccessAt == null ? 'Chưa đồng bộ' : 'Cập nhật lúc ${formatVnTimeDayMonth(syncState.lastSuccessAt!)}',
                  key: const ValueKey('ats-sync-line'),
                  style: muted,
                ),
              Wrap(
                spacing: 2,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  DesignButton.outline(key: const ValueKey('ats-sync'), label: _syncing ? 'Đang đồng bộ…' : 'Đồng bộ ngay', onPressed: _syncing ? null : _sync),
                  if (data != null)
                    PopupMenuButton<_MenuAction>(
                      key: const ValueKey('ats-menu'),
                      tooltip: 'Tuỳ chọn',
                      icon: Icon(Icons.more_horiz, color: theme.textMuted, size: 20),
                      padding: EdgeInsets.zero,
                      onSelected: (a) => _onMenu(a, includeAll),
                      itemBuilder: (_) => [
                        if (!includeAll && doneCount > 0)
                          PopupMenuItem(
                            key: const ValueKey('ats-toggle-done'),
                            value: _MenuAction.toggleDone,
                            child: Text(_showDone ? 'Ẩn việc đã xong' : 'Xem cả việc đã xong ($doneCount)'),
                          ),
                        PopupMenuItem(
                          key: const ValueKey('ats-toggle-all'),
                          value: _MenuAction.toggleAll,
                          child: Text(includeAll ? 'Chỉ việc hiện hành' : 'Xem tất cả (gồm lưu trữ)'),
                        ),
                      ],
                    ),
                ],
              ),
            ],
          ),
        ],
      ),
      if (err != null)
        Text(
          'Lỗi đồng bộ: $err',
          key: const ValueKey('ats-sync-error'),
          maxLines: 3,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontSize: 12, color: DesignColors.warning),
        ),
    ];
    final body = <Widget>[
      if (failed)
        Row(
          spacing: 8,
          children: [
            Expanded(
              child: Text('Không tải được việc ATS.', key: const ValueKey('ats-load-error'), style: muted),
            ),
            TextButton(onPressed: () => ref.invalidate(atsTasksProvider), child: const Text('Thử lại')),
          ],
        )
      else if (data == null)
        Text('Đang tải...', style: muted)
      else if (data.tasks.isEmpty)
        Text('Không có việc ATS nào', key: const ValueKey('ats-empty'), style: muted)
      else if (shown!.isEmpty)
        Text('Không còn việc nào chưa xong.', style: muted)
      else ...[
        for (final g in limited!.groups) ...[
          Padding(
            padding: const EdgeInsets.only(top: 2),
            child: Text(
              atsGroupLabel(g.project),
              key: ValueKey('ats-group-${g.project?.atsId ?? 'none'}'),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: muted,
            ),
          ),
          for (final l in g.lines) AtsTaskRow(line: l),
        ],
        if (limited.hidden > 0)
          Align(
            alignment: Alignment.centerLeft,
            child: TextButton(key: const ValueKey('ats-more'), onPressed: () => setState(() => _expanded = true), child: Text('Xem thêm ${limited.hidden}')),
          )
        else if (_expanded && !widget.fill && totalLines > atsMaxLines)
          Align(
            alignment: Alignment.centerLeft,
            child: TextButton(key: const ValueKey('ats-less'), onPressed: () => setState(() => _expanded = false), child: const Text('Thu gọn')),
          ),
      ],
    ];

    return ScrollCard(
      key: const ValueKey('ats-tasks-card'),
      child: widget.fill
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              spacing: 6,
              children: [
                ...header,
                Expanded(
                  child: SingleChildScrollView(
                    key: const ValueKey('ats-scroll'),
                    child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, spacing: 6, children: body),
                  ),
                ),
              ],
            )
          : Column(crossAxisAlignment: CrossAxisAlignment.stretch, spacing: 6, children: [...header, ...body]),
    );
  }
}

/// Một dòng việc ATS: tên (cắt "…", kèm "×N" nếu gộp) bên trái; bên phải chip trạng thái (Đang làm / Chờ / Xong) và
/// "dd/MM" — việc quá hạn thay ngày bằng chip "Quá hạn" (màu error). Việc xong mờ. Chạm → chi tiết chỉ đọc.
/// Khung hẹp (chữ phóng to) thì chip xuống dòng dưới tên thay vì tràn.
class AtsTaskRow extends StatelessWidget {
  const AtsTaskRow({super.key, required this.line});

  final AtsTaskLine line;

  AtsTask get task => line.task;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final t = task;
    final scale = MediaQuery.textScalerOf(context).scale(14) / 14;

    final title = Text.rich(
      TextSpan(
        children: [
          TextSpan(text: t.title.isEmpty ? '(Không có tên)' : t.title),
          if (line.count > 1)
            TextSpan(
              text: ' ×${line.count}',
              style: TextStyle(color: theme.textMuted),
            ),
        ],
      ),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: TextStyle(fontSize: 14, color: cs.onSurface),
    );
    final trailing = <Widget>[
      if (atsShowsStatusChip(t.status))
        Tag(key: ValueKey('ats-status-${t.id}'), label: t.status.label, color: atsStatusColor(context, t.status), variant: TagVariant.tonal),
      if (t.overdue)
        Tag(key: ValueKey('ats-overdue-${t.id}'), label: 'Quá hạn', color: cs.error)
      else if (t.dueDate != null)
        Text(
          formatDayMonth(t.dueDate!),
          key: ValueKey('ats-due-${t.id}'),
          style: TextStyle(fontSize: 12, color: theme.textMuted),
        ),
    ];

    return Opacity(
      opacity: t.isDone ? 0.5 : 1,
      child: InkWell(
        key: ValueKey('ats-task-${t.id}'),
        onTap: () => showAtsTaskDetail(context, t, count: line.count),
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 36),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: LayoutBuilder(
              builder: (context, c) => c.maxWidth >= 260 * scale
                  ? Row(
                      spacing: 8,
                      children: [
                        Expanded(child: title),
                        ...trailing,
                      ],
                    )
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      spacing: 4,
                      children: [
                        title,
                        if (trailing.isNotEmpty) Wrap(spacing: 6, runSpacing: 4, crossAxisAlignment: WrapCrossAlignment.center, children: trailing),
                      ],
                    ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Chi tiết một việc ATS — chỉ đọc, không có nút sửa / xoá. Mở bằng showFinanceSheet như chi tiết việc của dự án.
/// [count] > 1: dòng gộp từ nhiều việc giống nhau.
Future<void> showAtsTaskDetail(BuildContext context, AtsTask task, {int count = 1}) =>
    showFinanceSheet<void>(context, AtsTaskDetailPage(task: task, count: count));

class AtsTaskDetailPage extends StatelessWidget {
  const AtsTaskDetailPage({super.key, required this.task, this.count = 1});

  final AtsTask task;
  final int count;

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
        if (count > 1) ...[const SizedBox(height: 4), Text('$count việc giống nhau trên ats-app', key: const ValueKey('ats-detail-count'), style: muted)],
        const SizedBox(height: 8),
        row('Dự án', text(t.project == null ? 'Không thuộc dự án' : (t.project!.name.isEmpty ? 'Không rõ' : t.project!.name))),
        row('Loại', text(t.project?.typeLabel.isNotEmpty == true ? t.project!.typeLabel : '—')),
        row('Hạn', text(t.dueDate == null ? 'Không có hạn' : formatDayMonth(t.dueDate!))),
        row(
          'Trạng thái',
          Align(
            alignment: Alignment.centerLeft,
            child: Wrap(
              spacing: 6,
              runSpacing: 4,
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

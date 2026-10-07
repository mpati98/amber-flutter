import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/utils/api_error.dart';
import '../../../shared/utils/date_format.dart';
import '../../../shared/widgets/form_bits.dart';
import '../../../shared/widgets/tag.dart';
import '../models/key_result.dart';
import '../models/task.dart';
import '../providers/nghi_su_duong_provider.dart';
import '../services/nghi_su_duong_api.dart';
import 'task_form.dart';

/// Trang chi tiết việc, mở bằng showFinanceSheet. Đọc việc từ [projectTasksProvider] theo
/// [taskId] nên tự cập nhật khi form sửa lưu xong hoặc khi tick checklist.
Future<void> showTaskDetail(BuildContext context, {required String projectId, required String taskId}) =>
    showFinanceSheet<void>(context, TaskDetailPage(projectId: projectId, taskId: taskId));

String notifyLabel(Task t) =>
    t.notifyDeadline ? 'Báo trước ${t.prepLeadDays ?? defaultNotifyLeadDays} ngày' : 'Tắt';

class TaskDetailPage extends ConsumerStatefulWidget {
  const TaskDetailPage({super.key, required this.projectId, required this.taskId});

  final String projectId;
  final String taskId;

  @override
  ConsumerState<TaskDetailPage> createState() => _TaskDetailPageState();
}

class _TaskDetailPageState extends ConsumerState<TaskDetailPage> {
  /// Id các mục checklist đang gửi PATCH (khoá ô tick của mục đó).
  final _sending = <String>{};
  bool _deleting = false;

  Future<void> _toggle(Task task, ChecklistItem item) async {
    if (_sending.contains(item.id)) return;
    setState(() => _sending.add(item.id));
    final notifier = ref.read(projectTasksProvider(widget.projectId).notifier);
    notifier.setChecklistDone(task.id, item.id, !item.done); // lạc quan
    try {
      await ref.read(nghiSuDuongApiProvider).patchChecklistItem(task.id, item.id, done: !item.done);
      refreshProjectData(ref.invalidate, widget.projectId);
    } catch (e) {
      notifier.setChecklistDone(task.id, item.id, item.done); // trả lại trạng thái cũ
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(apiErrorMessage(e, 'Không cập nhật được mục checklist, thử lại nhé.'))),
        );
      }
    } finally {
      if (mounted) setState(() => _sending.remove(item.id));
    }
  }

  Future<void> _delete(Task task) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xoá việc?'),
        content: const Text('Xoá việc này cùng nội dung và checklist?'),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(false), child: const Text('Huỷ')),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: Theme.of(context).colorScheme.error),
            child: const Text('Xoá'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    setState(() => _deleting = true);
    try {
      await ref.read(nghiSuDuongApiProvider).deleteTask(task.id);
      refreshProjectData(ref.invalidate, widget.projectId);
      if (mounted) Navigator.of(context).pop();
    } catch (e) {
      if (mounted) {
        setState(() => _deleting = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(apiErrorMessage(e, 'Không xoá được việc, thử lại nhé.'))),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final muted = TextStyle(fontSize: 12, color: cs.onSurface.withValues(alpha: 0.6));
    final tasks = ref.watch(projectTasksProvider(widget.projectId)).value;
    final keyResults = ref.watch(projectDetailProvider(widget.projectId)).value?.keyResults ?? const <KeyResult>[];
    final task = tasks?.where((t) => t.id == widget.taskId).firstOrNull;

    if (task == null) {
      return FinanceSheetBody(
        title: 'Chi tiết việc',
        children: [Text(tasks == null ? 'Đang tải...' : 'Không tìm thấy việc này.', style: muted)],
      );
    }

    final krIndex = task.krId == null ? -1 : keyResults.indexWhere((k) => k.id == task.krId);
    final items = task.checklistItems;
    final doneCount = items.where((i) => i.done).length;
    final description = task.description?.trim();

    Widget info(String label, String value) => Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(width: 110, child: Text(label, style: muted)),
            Expanded(child: Text(value, style: TextStyle(fontSize: 14, color: cs.onSurface))),
          ],
        );

    return FinanceSheetBody(
      title: 'Chi tiết việc',
      children: [
        Align(
          alignment: Alignment.centerLeft,
          child: Tag(
            label: krIndex >= 0 ? 'KR ${krIndex + 1} · ${keyResults[krIndex].name}' : 'Không gắn KR',
            color: krIndex >= 0 ? cs.secondary : cs.onSurface.withValues(alpha: 0.6),
          ),
        ),
        Text(task.title, style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontSize: 20, color: cs.onSurface)),
        if (task.attention != null)
          Align(alignment: Alignment.centerLeft, child: Tag(label: task.attention!.label, color: cs.error)),
        info('Trạng thái', task.status.label),
        info('Bắt đầu', task.startDate == null ? 'Chưa có' : formatDayMonth(task.startDate!)),
        info('Hạn', task.dueDate == null ? 'Chưa có' : formatDayMonth(task.dueDate!)),
        info('Loại', task.isMilestone ? 'Mốc' : 'Việc'),
        info('Thông báo hạn', notifyLabel(task)),
        Text('Nội dung', style: muted),
        Text(
          description == null || description.isEmpty ? 'Chưa có nội dung.' : description,
          style: TextStyle(fontSize: 14, color: cs.onSurface),
        ),
        Row(
          children: [
            Expanded(child: Text('Checklist', style: muted)),
            Text('$doneCount / ${items.length}', style: muted),
          ],
        ),
        if (items.isEmpty)
          Text('Chưa có mục nào.', style: muted)
        else
          for (final item in items)
            CheckboxListTile(
              key: ValueKey('check-${item.id}'),
              contentPadding: EdgeInsets.zero,
              controlAffinity: ListTileControlAffinity.leading,
              dense: true,
              value: item.done,
              onChanged: _sending.contains(item.id) ? null : (_) => _toggle(task, item),
              title: Text(
                item.text,
                style: TextStyle(
                  fontSize: 14,
                  color: cs.onSurface,
                  decoration: item.done ? TextDecoration.lineThrough : null,
                ),
              ),
            ),
        FilledButton(
          onPressed: _deleting
              ? null
              : () => showTaskForm(context, projectId: widget.projectId, keyResults: keyResults, task: task),
          child: const Text('Sửa'),
        ),
        OutlinedButton(
          onPressed: _deleting ? null : () => _delete(task),
          style: OutlinedButton.styleFrom(foregroundColor: cs.error, side: BorderSide(color: cs.error)),
          child: Text(_deleting ? 'Đang xoá...' : 'Xoá việc'),
        ),
      ],
    );
  }
}

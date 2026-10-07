import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/utils/api_error.dart';
import '../../../shared/utils/date_format.dart';
import '../../../shared/widgets/progress_bar.dart';
import '../../../shared/widgets/scroll_card.dart';
import '../../../shared/widgets/tag.dart';
import '../models/key_result.dart';
import '../models/task.dart';
import '../providers/nghi_su_duong_provider.dart';
import 'edit_task_modal.dart';

/// Giới hạn việc "Đang làm" cùng lúc (chỉ cảnh báo, không chặn thao tác).
const wipLimit = 2;

/// Bề rộng từ đó bảng xếp 4 cột cạnh nhau.
const boardWideBreakpoint = 900.0;

/// 4 nhóm cố định, theo thứ tự. Trạng thái lạ (unknown) xếp cùng "Chờ" để không mất việc.
const boardStatuses = [TaskStatus.prep, TaskStatus.inProgress, TaskStatus.review, TaskStatus.done];

String boardColumnLabel(TaskStatus s) => switch (s) {
      TaskStatus.inProgress => 'Đang làm',
      TaskStatus.review => 'Thẩm định',
      TaskStatus.done => 'Xong',
      _ => 'Chờ',
    };

TaskStatus _columnOf(TaskStatus s) => s == TaskStatus.unknown ? TaskStatus.prep : s;

/// Thứ tự trong nhóm: dueDate tăng dần, không có hạn xuống cuối, rồi theo createdAt.
int compareBoardTasks(Task a, Task b) {
  final ad = a.dueDate, bd = b.dueDate;
  if (ad != bd) {
    if (ad == null) return 1;
    if (bd == null) return -1;
    final c = ad.compareTo(bd);
    if (c != 0) return c;
  }
  final ac = a.createdAt, bc = b.createdAt;
  if (ac == null || bc == null) return ac == null && bc == null ? 0 : (ac == null ? 1 : -1);
  return ac.compareTo(bc);
}

List<Task> tasksOfColumn(List<Task> tasks, TaskStatus column) =>
    tasks.where((t) => _columnOf(t.status) == column).toList()..sort(compareBoardTasks);

/// Bảng Kanban 4 nhóm. Hẹp: xếp dọc; rộng (≥ [boardWideBreakpoint]): 4 cột cạnh nhau.
class TaskBoard extends StatelessWidget {
  const TaskBoard({super.key, required this.projectId, required this.tasks, required this.keyResults});

  final String projectId;
  final List<Task> tasks;
  final List<KeyResult> keyResults;

  @override
  Widget build(BuildContext context) {
    Widget column(TaskStatus s) =>
        _BoardColumn(status: s, tasks: tasksOfColumn(tasks, s), projectId: projectId, keyResults: keyResults);
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth >= boardWideBreakpoint) {
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 12,
            children: [for (final s in boardStatuses) Expanded(child: column(s))],
          );
        }
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          spacing: 16,
          children: [for (final s in boardStatuses) column(s)],
        );
      },
    );
  }
}

class _BoardColumn extends StatelessWidget {
  const _BoardColumn({required this.status, required this.tasks, required this.projectId, required this.keyResults});

  final TaskStatus status;
  final List<Task> tasks;
  final String projectId;
  final List<KeyResult> keyResults;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final muted = TextStyle(fontSize: 12, color: cs.onSurface.withValues(alpha: 0.6));
    final n = tasks.length;
    final overWip = status == TaskStatus.inProgress && n > wipLimit;
    final count = status == TaskStatus.inProgress ? (overWip ? 'Vượt WIP $n / $wipLimit' : '$n / $wipLimit') : '$n';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: 8,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                boardColumnLabel(status),
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: cs.primary),
              ),
            ),
            Text(
              count,
              style: overWip ? TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: cs.error) : muted,
            ),
          ],
        ),
        if (tasks.isEmpty)
          Text('Trống', style: muted)
        else
          for (final t in tasks)
            TaskCard(key: ValueKey('task-${t.id}'), task: t, projectId: projectId, keyResults: keyResults),
      ],
    );
  }
}

/// Thẻ việc ở bảng: nhãn KR / Mốc, tên, cảnh báo, checklist, hạn, hai nút chuyển nhóm.
class TaskCard extends ConsumerWidget {
  const TaskCard({super.key, required this.task, required this.projectId, required this.keyResults});

  final Task task;
  final String projectId;
  final List<KeyResult> keyResults;

  Future<void> _move(BuildContext context, WidgetRef ref, TaskStatus next) async {
    try {
      await ref.read(projectTasksProvider(projectId).notifier).move(task, next);
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(apiErrorMessage(e, 'Không chuyển được việc, thử lại nhé.'))),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = Theme.of(context).colorScheme;
    final muted = TextStyle(fontSize: 12, color: cs.onSurface.withValues(alpha: 0.6));
    final moving = ref.watch(movingTasksProvider).contains(task.id);
    final column = _columnOf(task.status);
    final i = boardStatuses.indexOf(column);
    final prev = i > 0 ? boardStatuses[i - 1] : null;
    final next = i < boardStatuses.length - 1 ? boardStatuses[i + 1] : null;

    final krIndex = task.krId == null ? -1 : keyResults.indexWhere((k) => k.id == task.krId);
    final items = task.checklistItems;
    final checked = items.where((c) => c.done).length;
    final attention = task.attention;
    final due = task.status == TaskStatus.done
        ? 'Xong'
        : task.dueDate != null
            ? (task.isMilestone ? formatDayMonth(task.dueDate!) : 'Hạn ${formatDayMonth(task.dueDate!)}')
            : 'Chưa có ngày';

    return InkWell(
      onTap: () => showEditTaskModal(context, task),
      borderRadius: BorderRadius.circular(6),
      child: ScrollCard(
        glow: attention != null ? ScrollCardGlow.shuiro : ScrollCardGlow.yugen,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          spacing: 8,
          children: [
            Wrap(
              spacing: 6,
              runSpacing: 4,
              children: [
                Tag(
                  label: krIndex >= 0 ? 'KR ${krIndex + 1}' : 'Không gắn KR',
                  color: krIndex >= 0 ? cs.secondary : cs.onSurface.withValues(alpha: 0.6),
                ),
                if (task.isMilestone) Tag(label: 'Mốc', color: cs.primary),
              ],
            ),
            Text(
              task.title,
              style: TextStyle(fontSize: 14, color: cs.onSurface),
            ),
            if (attention != null)
              Align(alignment: Alignment.centerLeft, child: Tag(label: attention.label, color: cs.error)),
            if (items.isNotEmpty) ...[
              ProgressBar(value: checked.toDouble(), max: items.length.toDouble()),
              Text('$checked / ${items.length}', style: muted),
            ],
            Row(
              children: [
                Expanded(child: Text(due, style: muted)),
                IconButton(
                  tooltip: prev == null ? 'Đã ở nhóm đầu' : 'Chuyển về ${boardColumnLabel(prev)}',
                  visualDensity: VisualDensity.compact,
                  onPressed: moving || prev == null ? null : () => _move(context, ref, prev),
                  icon: const Icon(Icons.chevron_left),
                ),
                IconButton(
                  tooltip: next == null ? 'Đã ở nhóm cuối' : 'Chuyển sang ${boardColumnLabel(next)}',
                  visualDensity: VisualDensity.compact,
                  onPressed: moving || next == null ? null : () => _move(context, ref, next),
                  icon: const Icon(Icons.chevron_right),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';

import '../../../shared/utils/date_format.dart';
import '../../../shared/widgets/scroll_card.dart';
import '../../../shared/widgets/tag.dart';
import '../models/project_detail.dart';
import '../models/project_summary.dart';
import '../models/task.dart';
import 'edit_project_modal.dart';

/// Nhãn trạng thái ở đầu trang: PAUSED "Tạm dừng"; DONE "Đã xong"; còn lại "{n} việc cần xử lý"
/// (n = số việc có attention) hoặc "Đúng nhịp" khi n = 0. [attentionCount] null (chưa tải việc) → không có nhãn.
({String label, bool warning})? detailBadge(ProjectStatus status, int? attentionCount) => switch (status) {
      ProjectStatus.paused => (label: 'Tạm dừng', warning: false),
      ProjectStatus.done => (label: 'Đã xong', warning: false),
      _ when attentionCount == null => null,
      _ when attentionCount > 0 => (label: '$attentionCount việc cần xử lý', warning: true),
      _ => (label: 'Đúng nhịp', warning: false),
    };

/// Việc isMilestone chưa DONE có hạn sớm nhất; không có → null.
Task? nextMilestone(List<Task> tasks) {
  final candidates = tasks.where((t) => t.isMilestone && t.status != TaskStatus.done && t.dueDate != null).toList()
    ..sort((a, b) => a.dueDate!.compareTo(b.dueDate!));
  return candidates.firstOrNull;
}

class ProjectHeader extends StatelessWidget {
  const ProjectHeader({super.key, required this.project, required this.tasks});

  final ProjectDetail project;

  /// null khi chưa tải xong việc.
  final List<Task>? tasks;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final muted = TextStyle(fontSize: 12, color: cs.onSurface.withValues(alpha: 0.6));
    final goal = project.goal?.trim();
    final badge = detailBadge(project.status, tasks?.where((t) => t.attention != null).length);
    final milestone = tasks == null ? null : nextMilestone(tasks!);

    return ScrollCard(
      glow: ScrollCardGlow.yugen,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: 8,
        children: [
          Wrap(
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              if (badge != null) Tag(label: badge.label, color: badge.warning ? cs.error : cs.secondary),
              TextButton.icon(
                onPressed: () => showEditProjectModal(context, project),
                icon: const Icon(Icons.edit_outlined, size: 18),
                label: const Text('Sửa dự án'),
              ),
            ],
          ),
          Text(project.name, style: theme.textTheme.headlineSmall?.copyWith(fontSize: 20, color: cs.onSurface)),
          Text(goal == null || goal.isEmpty ? 'Chưa ghi mục tiêu.' : goal, style: muted),
          Text(formatDateRange(project.startDate, project.endDate), style: muted),
          Text(
            milestone == null
                ? 'Chưa có mốc sắp tới'
                : 'Mốc kế tiếp: ${milestone.title} · ${formatDayMonth(milestone.dueDate!)}',
            style: muted,
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../shared/utils/currency.dart';
import '../../../shared/utils/date_format.dart';
import '../../../shared/widgets/progress_bar.dart';
import '../../../shared/widgets/scroll_card.dart';
import '../../../shared/widgets/tag.dart';
import '../models/project_summary.dart';

/// Nhãn trạng thái ở đầu thẻ dự án, theo thứ tự ưu tiên:
/// PAUSED → "Tạm dừng"; DONE → "Đã xong"; ACTIVE có việc cần xử lý → "{n} việc cần xử lý";
/// ACTIVE chưa có việc → "Mới tạo"; còn lại → "Đúng nhịp".
enum ProjectBadgeTone { warning, neutral, ok }

({String label, ProjectBadgeTone tone}) projectBadge(ProjectSummary p) => switch (p.status) {
      ProjectStatus.paused => (label: 'Tạm dừng', tone: ProjectBadgeTone.neutral),
      ProjectStatus.done => (label: 'Đã xong', tone: ProjectBadgeTone.neutral),
      _ when p.attentionCount > 0 => (label: '${p.attentionCount} việc cần xử lý', tone: ProjectBadgeTone.warning),
      _ when p.taskTotal == 0 => (label: 'Mới tạo', tone: ProjectBadgeTone.ok),
      _ => (label: 'Đúng nhịp', tone: ProjectBadgeTone.ok),
    };

/// Bề rộng tối đa của một thẻ trong lưới.
const projectCardMaxWidth = 420.0;
const _gap = 12.0;

/// Lưới thẻ dự án: 1 cột ở bề ngang điện thoại, nhiều cột khi rộng (mỗi thẻ ≤ [projectCardMaxWidth]).
class ProjectGrid extends StatelessWidget {
  const ProjectGrid({super.key, required this.projects});

  final List<ProjectSummary> projects;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = ((constraints.maxWidth + _gap) / (projectCardMaxWidth + _gap)).floor().clamp(1, 12);
        final width = ((constraints.maxWidth - _gap * (columns - 1)) / columns).clamp(0.0, projectCardMaxWidth);
        return Wrap(
          spacing: _gap,
          runSpacing: _gap,
          children: [for (final p in projects) SizedBox(width: width, child: ProjectCard(p, key: ValueKey('project-${p.id}')))],
        );
      },
    );
  }
}

class ProjectCard extends StatelessWidget {
  const ProjectCard(this.project, {super.key});

  final ProjectSummary project;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final muted = TextStyle(fontSize: 12, color: cs.onSurface.withValues(alpha: 0.6));
    final goal = project.goal?.trim();
    final kr = project.krProgress;
    final badge = projectBadge(project);
    final net = project.finance.net;

    return InkWell(
      onTap: () => context.push('/du-an/${project.id}'),
      borderRadius: BorderRadius.circular(6),
      child: ScrollCard(
        glow: switch (badge.tone) {
          ProjectBadgeTone.warning => ScrollCardGlow.shuiro,
          ProjectBadgeTone.ok => ScrollCardGlow.yugen,
          ProjectBadgeTone.neutral => ScrollCardGlow.kincha,
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          spacing: 8,
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: Tag(
                label: badge.label,
                color: switch (badge.tone) {
                  ProjectBadgeTone.warning => cs.error,
                  ProjectBadgeTone.ok => cs.secondary,
                  ProjectBadgeTone.neutral => cs.onSurface.withValues(alpha: 0.7),
                },
              ),
            ),
            Text(
              project.name,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.headlineSmall?.copyWith(fontSize: 17, color: cs.onSurface),
            ),
            Text(
              goal == null || goal.isEmpty ? 'Chưa ghi mục tiêu.' : goal,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: muted,
            ),
            Row(
              children: [
                Expanded(child: Text('Kết quả then chốt', style: muted)),
                Text(kr == null ? 'Chưa có KR' : '${(kr * 100).round()}%', style: muted),
              ],
            ),
            ProgressBar(value: kr ?? 0, max: 1),
            Wrap(
              spacing: 12,
              runSpacing: 2,
              children: [
                Text('Đang làm ${project.taskDoing}', style: muted),
                Text('Xong ${project.taskDone} / ${project.taskTotal}', style: muted),
                Text(formatDateRange(project.startDate, project.endDate), style: muted),
              ],
            ),
            Divider(height: 8, color: cs.onSurface.withValues(alpha: 0.1)),
            Row(
              spacing: 8,
              children: [
                Expanded(
                  child: Text(
                    project.nextMilestone == null
                        ? 'Chưa có mốc'
                        : '${project.nextMilestone!.title} · ${formatDayMonth(project.nextMilestone!.dueDate)}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: muted,
                  ),
                ),
                Text('Ròng ${formatVnd(net)}', style: muted.copyWith(color: cs.onSurface.withValues(alpha: 0.8))),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:material_ui/material_ui.dart';

import '../../../shared/theme/app_theme.dart';
import '../../../shared/utils/date_format.dart';
import '../../../shared/widgets/progress_bar.dart';
import '../../tra_dinh/hoc_tap/models/study_overview.dart';

/// "60 phút / ngày" hoặc "Chưa đặt mục tiêu".
String goalLabel(int? goalMinutes) =>
    goalMinutes == null ? 'Chưa đặt mục tiêu' : '$goalMinutes phút / ngày';

/// Thẻ kế hoạch của một môn: tên + mục tiêu, khóa đang học (nếu có) với thanh tiến độ, "N / M phần" và ngày dự kiến xong.
class SubjectPlanCard extends StatelessWidget {
  const SubjectPlanCard({
    super.key,
    required this.subject,
    required this.onTap,
  });

  final SubjectOverview subject;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final active = subject.activeCourse;
    final p = active?.progress;
    final forecast = active?.forecastFinishDate;

    return InkWell(
      key: ValueKey('plan-subject-${subject.subjectId}'),
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          border: Border.all(
            color: theme.colorScheme.onSurface.withValues(alpha: 0.12),
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          spacing: 8,
          children: [
            Row(
              spacing: 8,
              children: [
                Expanded(
                  child: Text(
                    subject.name,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                Text(
                  goalLabel(subject.goalMinutes),
                  style: TextStyle(fontSize: 13, color: theme.textMuted),
                ),
              ],
            ),
            if (active != null && p != null) ...[
              Text(
                'ĐANG HỌC',
                key: ValueKey('plan-label-${subject.subjectId}'),
                style: TextStyle(
                  fontSize: 11,
                  letterSpacing: 1.2,
                  fontWeight: FontWeight.w500,
                  color: theme.textMuted,
                ),
              ),
              Text(active.title, style: const TextStyle(fontSize: 14)),
              ProgressBar(
                value: p.doneMinutes.toDouble(),
                max: p.totalMinutes.toDouble(),
                fillColor: theme.colorScheme.primary,
              ),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      '${p.doneSections} / ${p.totalSections} phần',
                      style: TextStyle(fontSize: 12, color: theme.textMuted),
                    ),
                  ),
                  if (forecast != null)
                    Text(
                      'Dự kiến xong ${formatDayMonth(forecast)}',
                      style: TextStyle(fontSize: 12, color: theme.textMuted),
                    ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

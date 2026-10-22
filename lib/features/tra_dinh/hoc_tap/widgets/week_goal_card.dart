import 'package:flutter/material.dart';

import '../../../../shared/theme/app_theme.dart';
import '../../../../shared/utils/date_format.dart';
import '../../../../shared/utils/duration_format.dart';
import '../../../../shared/widgets/progress_bar.dart';
import '../../../../shared/widgets/scroll_card.dart';
import '../models/study_overview.dart';
import 'hoc_tap_common.dart';

/// Thẻ mục tiêu tuần: tiến độ, gợi ý mỗi ngày, biểu đồ 7 cột và từng môn.
class WeekGoalCard extends StatelessWidget {
  const WeekGoalCard({super.key, required this.overview});

  final StudyOverview overview;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final week = overview.week;
    final hasGoal = week.goalMinutes > 0;

    return ScrollCard(
      glow: ScrollCardGlow.kincha,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: 10,
        children: [
          const HocTapSectionTitle('Mục tiêu tuần này'),
          if (!hasGoal)
            Text('Đặt mục tiêu phút mỗi ngày cho một môn để theo dõi tuần.', style: TextStyle(fontSize: 13, color: theme.textMuted))
          else ...[
            Row(
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Text(formatDuration(week.minutes), key: const ValueKey('week-minutes'), style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w600)),
                Text(' / ${formatDuration(week.goalMinutes)}', style: TextStyle(fontSize: 14, color: theme.textMuted)),
              ],
            ),
            ProgressBar(value: week.minutes.toDouble(), max: week.goalMinutes.toDouble()),
            Text(
              week.remainingMinutes == 0
                  ? 'Đủ mục tiêu tuần rồi 🎉'
                  : 'Còn ${formatDuration(week.remainingMinutes)} trong ${week.remainingDays} ngày, '
                        'tối thiểu ${week.suggestedPerDay} phút mỗi ngày',
              key: const ValueKey('week-suggestion'),
              style: TextStyle(fontSize: 13, color: theme.textMuted),
            ),
            _WeekChart(week: week, today: overview.today),
            for (final s in week.bySubject) _SubjectRow(subject: s),
          ],
        ],
      ),
    );
  }
}

const _dayLabels = ['T2', 'T3', 'T4', 'T5', 'T6', 'T7', 'CN'];

/// 7 cột bằng Container: cột đủ mục tiêu → kincha đậm, chưa đủ → kincha nhạt, hôm nay có viền nổi;
/// vạch đứt ngang là mục tiêu ngày.
class _WeekChart extends StatelessWidget {
  const _WeekChart({required this.week, required this.today});

  final WeekSummary week;
  final String today;

  static const _height = 110.0;
  static const _todayMinHeight = 6.0; // 2px viền trên + 2px viền dưới + 2px ruột

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final goal = week.days.isEmpty ? 0 : week.days.first.goalMinutes;
    final peak = week.days.fold<int>(goal, (m, d) => d.minutes > m ? d.minutes : m);
    final scale = peak == 0 ? 1.0 : _height / peak;

    return SizedBox(
      key: const ValueKey('week-chart'),
      height: _height + 24,
      child: Stack(
        children: [
          // Vạch đứt mục tiêu ngày.
          Positioned(
            left: 0,
            right: 0,
            bottom: 20 + goal * scale,
            child: LayoutBuilder(
              key: const ValueKey('goal-line'),
              builder: (context, c) {
                final dashes = (c.maxWidth / 8).floor();
                return Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [for (var i = 0; i < dashes; i++) Container(width: 4, height: 1, color: theme.textFaint)],
                );
              },
            ),
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            spacing: 8,
            children: [
              for (final (i, d) in week.days.indexed)
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    spacing: 4,
                    children: [
                      Container(
                        key: ValueKey('week-bar-${d.date}'),
                        // Tối thiểu 2px cho cột trống; hôm nay có viền 2px mỗi cạnh nên cần ≥ 6px, nếu không cột chỉ còn là hai vạch viền.
                        height: (d.minutes * scale).clamp(d.date == today ? _todayMinHeight : 2.0, _height),
                        decoration: BoxDecoration(
                          color: d.done ? AppColors.kincha400 : AppColors.kincha400.withValues(alpha: 0.35),
                          borderRadius: BorderRadius.circular(3),
                          border: d.date == today ? Border.all(color: theme.colorScheme.onSurface, width: 2) : null,
                        ),
                      ),
                      Text(
                        _dayLabels[i % 7],
                        style: TextStyle(fontSize: 11, fontWeight: d.date == today ? FontWeight.w700 : FontWeight.w400, color: d.date == today ? theme.colorScheme.onSurface : theme.textMuted),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SubjectRow extends StatelessWidget {
  const _SubjectRow({required this.subject});

  final WeekSubject subject;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      key: ValueKey('week-subject-${subject.subjectId}'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: 4,
      children: [
        Row(
          children: [
            Expanded(child: Text(subject.name, style: const TextStyle(fontSize: 13))),
            Text('${formatDuration(subject.minutes)} / ${formatDuration(subject.goalMinutes)}', style: TextStyle(fontSize: 12, color: theme.textMuted)),
          ],
        ),
        ProgressBar(value: subject.minutes.toDouble(), max: subject.goalMinutes.toDouble()),
      ],
    );
  }
}

/// Ngày tuần dạng "T2 12/10" cho Semantics / test.
String weekDayLabel(WeekDay d, int index) => '${_dayLabels[index % 7]} ${formatDayMonth(d.date)}';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../shared/theme/app_theme.dart';
import '../../../../shared/utils/date_format.dart';
import '../../../../shared/utils/duration_format.dart';
import '../../../../shared/widgets/progress_ring.dart';
import '../../../../shared/widgets/scroll_card.dart';
import '../../../../shared/widgets/tag.dart';
import '../../../nghi_su_duong/models/routine.dart';
import '../../../nghi_su_duong/providers/nghi_su_duong_provider.dart';
import '../models/study_overview.dart';
import 'missing_reason_sheet.dart';
import 'subject_sheet.dart';

/// Routine STUDY của môn (nguồn chuỗi ngày và ngày thiếu lý do). null = chưa có routine hoặc chưa tải được.
Routine? studyRoutineOf(List<Routine>? routines, String subjectId) {
  for (final r in routines ?? const <Routine>[]) {
    if (r.isStudy && r.studySubjectId == subjectId) return r;
  }
  return null;
}

const _dayLabels = ['T2', 'T3', 'T4', 'T5', 'T6', 'T7', 'CN'];

/// Thẻ chính của màn Hôm nay: vòng tiến độ phút hôm nay, chuỗi ngày, dải 7 chấm, "Tuần này: X / Y", thiếu lý do.
class TodayMainCard extends ConsumerWidget {
  const TodayMainCard({
    super.key,
    required this.overview,
    required this.subject,
  });

  final StudyOverview overview;
  final SubjectOverview subject;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final today = subject.today;
    final goal = subject.goalMinutes;
    final week = overview.week;
    final routine = studyRoutineOf(
      ref.watch(routinesProvider).value,
      subject.subjectId,
    );
    final pending = [...?routine?.pendingReasonDates]
      ..sort((a, b) => b.compareTo(a));

    return ScrollCard(
      glow: ScrollCardGlow.kincha,
      child: Column(
        key: const ValueKey('today-main'),
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: 12,
        children: [
          if (goal == null)
            _NoGoal(subjectId: subject.subjectId, minutes: today.minutes)
          else
            Row(
              spacing: 16,
              children: [
                ProgressRing(
                  key: const ValueKey('today-ring'),
                  value: today.minutes.toDouble(),
                  max: goal.toDouble(),
                  size: 88,
                  label:
                      '${goal > 0 ? (today.minutes * 100 / goal).clamp(0, 100).round() : 0}%',
                  labelStyle: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: scheme.onSurface,
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    spacing: 2,
                    children: [
                      Text(
                        'Hôm nay',
                        style: TextStyle(fontSize: 12, color: theme.textMuted),
                      ),
                      Text(
                        '${today.minutes} / $goal phút',
                        key: const ValueKey('today-minutes'),
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      if (today.done)
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Tag(
                            label: 'Đủ mục tiêu',
                            color: theme.success,
                            variant: TagVariant.tonal,
                          ),
                        ),
                      if (routine != null)
                        Text(
                          'Chuỗi ${routine.streak} ngày',
                          key: const ValueKey('today-streak'),
                          style: TextStyle(
                            fontSize: 13,
                            color: theme.textMuted,
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          if (today.reason case final reason?)
            Align(
              alignment: Alignment.centerLeft,
              child: Tag(
                label: 'Dừng sớm: ${reason.label}',
                color: scheme.secondary,
                variant: TagVariant.tonal,
              ),
            ),
          if (week.goalMinutes > 0) ...[
            _WeekDots(week: week, today: overview.today),
            Text(
              'Tuần này: ${formatDuration(week.minutes)} / ${formatDuration(week.goalMinutes)}',
              key: const ValueKey('week-summary'),
              style: TextStyle(fontSize: 13, color: theme.textMuted),
            ),
          ],
          if (pending.isNotEmpty && routine?.studySubjectId != null)
            InkWell(
              key: const ValueKey('today-pending'),
              onTap: () => showMissingReasonSheet(
                context,
                subjectId: subject.subjectId,
                subjectName: subject.name,
                goalMinutes: goal ?? 0,
                dates: pending,
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  children: [
                    Icon(
                      Icons.warning_amber_rounded,
                      size: 16,
                      color: scheme.secondary,
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        'Thiếu lý do ngày ${pending.map(formatDayMonth).join(', ')}',
                        style: const TextStyle(fontSize: 13),
                      ),
                    ),
                    Icon(Icons.chevron_right, size: 18, color: theme.textFaint),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _NoGoal extends StatelessWidget {
  const _NoGoal({required this.subjectId, required this.minutes});

  final String subjectId;
  final int minutes;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 4,
      children: [
        Text('Hôm nay', style: TextStyle(fontSize: 12, color: theme.textMuted)),
        Text(
          '$minutes phút',
          key: const ValueKey('today-minutes'),
          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w600),
        ),
        Text(
          'Chưa đặt mục tiêu phút mỗi ngày cho môn này.',
          style: TextStyle(fontSize: 13, color: theme.textMuted),
        ),
        TextButton(
          key: const ValueKey('set-goal'),
          onPressed: () => showSubjectSheet(context, subjectId: subjectId),
          child: const Text('Đặt mục tiêu ›'),
        ),
      ],
    );
  }
}

/// Dải 7 chấm T2…CN: đủ mục tiêu = đặc, chưa đủ = rỗng, hôm nay có viền đậm; ngày chưa tới mờ đi.
class _WeekDots extends StatelessWidget {
  const _WeekDots({required this.week, required this.today});

  final WeekSummary week;
  final String today;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return Row(
      key: const ValueKey('week-dots'),
      children: [
        for (var i = 0; i < week.days.length; i++)
          Expanded(
            child: Column(
              spacing: 4,
              children: [
                Text(
                  _dayLabels[i % 7],
                  style: TextStyle(fontSize: 11, color: theme.textMuted),
                ),
                _Dot(
                  key: ValueKey('week-dot-${week.days[i].date}'),
                  done: week.days[i].done,
                  isToday: week.days[i].date == today,
                  future: week.days[i].date.compareTo(today) > 0,
                  color: scheme.primary,
                  outline: theme.textFaint,
                ),
              ],
            ),
          ),
      ],
    );
  }
}

class _Dot extends StatelessWidget {
  const _Dot({
    super.key,
    required this.done,
    required this.isToday,
    required this.future,
    required this.color,
    required this.outline,
  });

  final bool done;
  final bool isToday;
  final bool future;
  final Color color;
  final Color outline;

  @override
  Widget build(BuildContext context) => Opacity(
    opacity: future ? 0.5 : 1,
    child: Container(
      width: 18,
      height: 18,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: done ? color : Colors.transparent,
        border: Border.all(
          color: done || isToday ? color : outline,
          width: isToday ? 2.5 : 1.5,
        ),
      ),
    ),
  );
}

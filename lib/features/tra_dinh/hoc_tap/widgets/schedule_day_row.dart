import 'package:flutter/material.dart';

import '../../../../shared/theme/app_theme.dart';
import '../../../../shared/utils/date_format.dart';
import '../../../../shared/utils/duration_format.dart';
import '../../../../shared/widgets/progress_bar.dart';
import '../../../../shared/widgets/tag.dart';
import '../../../nghi_su_duong/models/routine.dart' show weekdayShort;
import '../models/study_schedule.dart';
import '../models/study_subject.dart';
import '../utils/schedule_range.dart';
import 'dashed_border.dart';
import 'log_sheet.dart';
import 'missing_reason_sheet.dart';

/// Rút gọn tên khóa cho dòng lịch.
String shortCourseName(String name, [int max = 22]) => name.length <= max ? name : '${name.substring(0, max - 1).trimRight()}…';

/// Gom các phần dự kiến theo khóa (giữ thứ tự xuất hiện).
List<({String courseTitle, List<String> sections, int minutes})> groupPlanned(List<PlannedItem> items) {
  final order = <String>[];
  final byCourse = <String, ({String courseTitle, List<String> sections, int minutes})>{};
  for (final i in items) {
    final cur = byCourse[i.courseId];
    if (cur == null) {
      order.add(i.courseId);
      byCourse[i.courseId] = (courseTitle: i.courseTitle, sections: [i.title], minutes: i.minutes);
    } else {
      byCourse[i.courseId] = (courseTitle: cur.courseTitle, sections: cur.sections.contains(i.title) ? cur.sections : [...cur.sections, i.title], minutes: cur.minutes + i.minutes);
    }
  }
  return [for (final id in order) byCourse[id]!];
}

/// Dòng một ngày của lịch — dùng chung cho xem tuần và chi tiết ngày trong xem tháng.
///
/// past / today: các buổi thật, thanh tiến độ, học vượt, lý do, "Thiếu lý do" (bấm → sheet lý do của ngày đó);
/// today bấm → sheet ghi buổi học. planned: viền đứt, kế hoạch gom theo khóa, "Xong khóa".
class ScheduleDayRow extends StatelessWidget {
  const ScheduleDayRow({super.key, required this.day, required this.subject, this.noCourses = false});

  final ScheduleDay day;
  final StudySubject subject;

  /// Môn chưa có khóa nào để xếp lịch.
  final bool noCourses;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final goal = day.goalMinutes;
    final hasPlan = (day.plannedItems ?? const []).isNotEmpty;
    final grouped = groupPlanned(day.plannedItems ?? const []);
    final minutes = day.actualMinutes;

    final content = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: 4,
      children: [
        if (day.hasActual) ...[
          for (final l in day.logs)
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    [l.courseTitle ?? 'Ôn tập', if (l.sections.isNotEmpty) l.sections.map((s) => s.markedDone ? '${s.title} ✓' : s.title).join(', ')].join(' · '),
                    style: const TextStyle(fontSize: 13),
                  ),
                ),
                Text('${l.minutes}p', style: TextStyle(fontSize: 12, color: theme.textMuted)),
              ],
            ),
          if (day.logs.isEmpty && minutes == 0 && !day.isToday) Text('Không học', style: TextStyle(fontSize: 13, color: theme.textFaint)),
          if (goal != null) ...[
            ProgressBar(value: minutes.toDouble(), max: goal.toDouble()),
            Text('${formatDuration(minutes)} / ${formatDuration(goal)}', key: ValueKey('day-minutes-${day.date}'), style: TextStyle(fontSize: 12, color: theme.textMuted)),
          ] else
            Text(formatDuration(minutes), key: ValueKey('day-minutes-${day.date}'), style: TextStyle(fontSize: 12, color: theme.textMuted)),
          Wrap(
            spacing: 6,
            runSpacing: 4,
            children: [
              if ((day.extraMinutes ?? 0) > 0) Tag(label: 'Học vượt ${day.extraMinutes} phút', color: theme.success, variant: TagVariant.tonal),
              if (day.reason case final r?) Tag(label: 'Dừng sớm: ${r.label}', color: theme.colorScheme.secondary, variant: TagVariant.tonal),
              if (day.missingReason)
                InkWell(
                  key: ValueKey('missing-reason-${day.date}'),
                  onTap: () => showMissingReasonSheet(context, subjectId: subject.id, subjectName: subject.name, goalMinutes: goal ?? 0, dates: [day.date]),
                  child: const Tag(label: 'Thiếu lý do', color: AppColors.shuiro500, variant: TagVariant.tonal),
                ),
            ],
          ),
          if (day.isToday && goal != null && day.done != true)
            Text('Còn ${formatDuration(goal - minutes < 0 ? 0 : goal - minutes)}', key: const ValueKey('today-remaining'), style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.kincha400)),
          if (day.isToday && hasPlan) _Plan(grouped: grouped, prefix: 'Gợi ý: '),
        ] else ...[
          Text(goal == null ? 'Dự kiến' : 'Dự kiến · $goal phút', style: TextStyle(fontSize: 13, color: theme.textMuted)),
          if (hasPlan) _Plan(grouped: grouped),
          if (!hasPlan && noCourses && !day.isReviewDay) Text('Chưa có khóa để xếp lịch', key: ValueKey('no-course-${day.date}'), style: TextStyle(fontSize: 12, color: theme.textFaint)),
        ],
        if (day.isReviewDay && !hasPlan && day.logs.isEmpty) Text('Ôn tập tuần', key: ValueKey('review-${day.date}'), style: TextStyle(fontSize: 12, color: theme.textFaint)),
        for (final m in day.milestones)
          Align(alignment: Alignment.centerLeft, child: Tag(key: ValueKey('milestone-${day.date}-${m.courseId}'), label: 'Xong khóa ${shortCourseName(m.courseTitle)}', color: theme.success, variant: TagVariant.tonal)),
      ],
    );

    final body = Padding(
      padding: const EdgeInsets.all(10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 52,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(weekdayShort(isoWeekdayOf(day.date)), style: TextStyle(fontSize: 13, fontWeight: day.isToday ? FontWeight.w700 : FontWeight.w500)),
                Text(formatDayMonth(day.date), style: TextStyle(fontSize: 12, color: theme.textMuted)),
              ],
            ),
          ),
          Expanded(child: content),
        ],
      ),
    );

    final decorated = day.isPlanned
        ? DashedBorder(color: theme.textFaint, child: body)
        : DecoratedBox(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppTheme.darkRadius),
              border: Border.all(color: day.isToday ? theme.colorScheme.onSurface : theme.colorScheme.onSurface.withValues(alpha: 0.12), width: day.isToday ? 2 : 1),
            ),
            child: body,
          );

    return InkWell(
      key: ValueKey('day-${day.date}'),
      borderRadius: BorderRadius.circular(AppTheme.darkRadius),
      onTap: day.isToday ? () => showLogSheet(context, subjectId: subject.id) : null,
      child: decorated,
    );
  }
}

class _Plan extends StatelessWidget {
  const _Plan({required this.grouped, this.prefix = ''});

  final List<({String courseTitle, List<String> sections, int minutes})> grouped;
  final String prefix;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      for (final g in grouped)
        Text(
          '$prefix${shortCourseName(g.courseTitle)}: ${g.sections.join(', ')} · ${g.minutes}p',
          key: ValueKey('plan-${g.courseTitle}'),
          style: const TextStyle(fontSize: 13),
        ),
    ],
  );
}

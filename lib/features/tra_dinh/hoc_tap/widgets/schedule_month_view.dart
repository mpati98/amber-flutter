import 'package:flutter/material.dart';

import '../../../../shared/theme/app_theme.dart';
import '../../../../shared/utils/date_format.dart';
import '../../../../shared/utils/duration_format.dart';
import '../../../../shared/widgets/scroll_card.dart';
import '../models/study_schedule.dart';
import '../models/study_subject.dart';
import '../utils/schedule_range.dart';
import 'dashed_border.dart';
import 'hoc_tap_common.dart';
import 'schedule_day_row.dart';

const _headers = ['T2', 'T3', 'T4', 'T5', 'T6', 'T7', 'CN'];

/// Nhãn đọc cho trình đọc màn hình: "15 tháng 10, 40 trên 60 phút, chưa đủ".
String monthCellLabel(ScheduleDay d) {
  final dt = parseDay(d.date);
  final head = '${dt.day} tháng ${dt.month}';
  if (d.isPlanned) {
    final plan = d.goalMinutes == null ? 'dự kiến' : 'dự kiến ${d.goalMinutes} phút';
    return [head, plan, if (d.milestones.isNotEmpty) 'xong khóa', if (d.isReviewDay) 'ngày ôn tập'].join(', ');
  }
  final minutes = d.actualMinutes;
  final goal = d.goalMinutes;
  final status = goal == null ? '$minutes phút' : '$minutes trên $goal phút, ${d.done == true ? 'đủ mục tiêu' : 'chưa đủ'}';
  return [head, status, if (d.isToday) 'hôm nay', if (d.milestones.isNotEmpty) 'xong khóa', if (d.isReviewDay) 'ngày ôn tập'].join(', ');
}

/// Xem tháng: lưới thứ Hai–Chủ nhật, chú thích, thẻ tóm tắt. Bấm ô → chi tiết ngày.
class ScheduleMonthView extends StatelessWidget {
  const ScheduleMonthView({super.key, required this.schedule, required this.subject, required this.monthStart, required this.monthEnd, required this.noCourses, required this.onAddCourse});

  final StudySchedule schedule;
  final StudySubject subject;
  final String monthStart;
  final String monthEnd;
  final bool noCourses;
  final VoidCallback onAddCourse;

  bool _inMonth(String d) => d.compareTo(monthStart) >= 0 && d.compareTo(monthEnd) <= 0;

  void _openDay(BuildContext context, ScheduleDay d) => showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    builder: (context) => SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          spacing: 10,
          children: [
            HocTapSectionTitle('Ngày ${formatDayMonth(d.date)}'),
            ScheduleDayRow(day: d, subject: subject, noCourses: noCourses),
          ],
        ),
      ),
    ),
  );

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final days = schedule.days;
    final rows = [for (var i = 0; i + 7 <= days.length; i += 7) days.sublist(i, i + 7)];

    final inMonthDays = days.where((d) => _inMonth(d.date)).toList();
    final learned = inMonthDays.where((d) => d.hasActual).fold<int>(0, (n, d) => n + d.actualMinutes);
    // Dự kiến các ngày còn lại trong tháng (kể cả gợi ý của hôm nay nếu hôm nay chưa có buổi nào).
    final planned = inMonthDays.fold<int>(0, (n, d) => n + d.plannedMinutes);
    final milestones = [for (final d in inMonthDays) for (final m in d.milestones) (date: d.date, title: m.courseTitle, planned: d.isPlanned)];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: 8,
      children: [
        Row(
          spacing: 4,
          children: [for (final h in _headers) Expanded(child: Center(child: Text(h, style: TextStyle(fontSize: 12, color: theme.textMuted))))],
        ),
        Column(
          key: const ValueKey('month-grid'),
          spacing: 4,
          children: [
            for (final row in rows)
              Row(
                spacing: 4,
                children: [for (final d in row) Expanded(child: _Cell(day: d, inMonth: _inMonth(d.date), onTap: () => _openDay(context, d)))],
              ),
          ],
        ),
        const _Legend(),
        ScrollCard(
          glow: ScrollCardGlow.kincha,
          child: Column(
            key: const ValueKey('month-summary'),
            crossAxisAlignment: CrossAxisAlignment.stretch,
            spacing: 6,
            children: [
              const HocTapSectionTitle('Tóm tắt tháng'),
              Text('Đã học: ${formatDuration(learned)}', key: const ValueKey('month-learned'), style: const TextStyle(fontSize: 14)),
              Text('Dự kiến tới hết tháng: ${formatDuration(learned + planned)}', key: const ValueKey('month-projected'), style: const TextStyle(fontSize: 14)),
              if (milestones.isEmpty)
                Text('Chưa có mốc xong khóa trong tháng này.', style: TextStyle(fontSize: 12, color: theme.textMuted))
              else
                for (final m in milestones)
                  Row(
                    key: ValueKey('month-milestone-${m.date}'),
                    children: [
                      Icon(Icons.circle, size: 8, color: theme.success),
                      const SizedBox(width: 8),
                      Expanded(child: Text('${m.planned ? 'Dự kiến xong' : 'Đã xong'} ${shortCourseName(m.title, 30)}', style: const TextStyle(fontSize: 13))),
                      Text(formatDayMonth(m.date), style: TextStyle(fontSize: 12, color: theme.textMuted)),
                    ],
                  ),
            ],
          ),
        ),
        if (noCourses) ...[
          Text('Chưa có khóa để xếp lịch.', style: TextStyle(fontSize: 13, color: theme.textMuted)),
          OutlinedButton.icon(key: const ValueKey('schedule-add-course'), onPressed: onAddCourse, icon: const Icon(Icons.add), label: const Text('Khóa học')),
        ],
      ],
    );
  }
}

class _Cell extends StatelessWidget {
  const _Cell({required this.day, required this.inMonth, required this.onTap});

  final ScheduleDay day;
  final bool inMonth;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final goal = day.goalMinutes;
    final minutes = day.actualMinutes;
    final isDone = day.hasActual && day.done == true;
    final isPartial = day.hasActual && minutes > 0 && !isDone;
    final short = isPartial && goal != null; // chưa đủ mục tiêu → thêm ký hiệu, không chỉ dựa vào màu
    Color? bg;
    Color fg = theme.colorScheme.onSurface;
    if (day.hasActual) {
      if (isDone) {
        bg = AppColors.kincha400;
        fg = AppColors.ink950;
      } else if (isPartial) {
        bg = AppColors.kincha400.withValues(alpha: 0.3);
      } else {
        bg = AppColors.ink800;
      }
    }
    final label = day.hasActual ? '$minutes' : (goal == null ? '' : '$goal');

    final inner = Container(
      height: 56,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(AppTheme.darkRadius),
        border: day.isToday ? Border.all(color: theme.colorScheme.onSurface, width: 2) : null,
      ),
      child: Stack(
        children: [
          Positioned(left: 0, top: 0, child: Text('${parseDay(day.date).day}', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: fg))),
          Align(alignment: Alignment.bottomLeft, child: Text(label, style: TextStyle(fontSize: 11, color: day.hasActual ? fg : theme.textMuted))),
          if (day.milestones.isNotEmpty) Positioned(right: 0, top: 0, child: Icon(Icons.circle, key: ValueKey('dot-${day.date}'), size: 8, color: theme.success)),
          if (day.isReviewDay) Positioned(right: 0, bottom: 0, child: Text('ôn', key: ValueKey('rev-${day.date}'), style: TextStyle(fontSize: 9, color: day.hasActual ? fg : theme.textFaint))),
          if (short) Positioned(right: 0, bottom: day.isReviewDay ? 11 : 0, child: Icon(Icons.timelapse, key: ValueKey('short-${day.date}'), size: 11, color: fg)),
        ],
      ),
    );

    Widget cell = Semantics(
      label: monthCellLabel(day),
      button: true,
      excludeSemantics: true,
      onTap: onTap,
      child: InkWell(key: ValueKey('cell-${day.date}'), borderRadius: BorderRadius.circular(AppTheme.darkRadius), onTap: onTap, child: day.isPlanned ? DashedBorder(color: theme.textFaint, child: inner) : inner),
    );
    if (!inMonth) cell = Opacity(key: ValueKey('dim-${day.date}'), opacity: 0.35, child: cell);
    return cell;
  }
}

class _Legend extends StatelessWidget {
  const _Legend();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    Widget swatch(Widget box, String text) => Row(mainAxisSize: MainAxisSize.min, spacing: 6, children: [box, Text(text, style: TextStyle(fontSize: 11, color: theme.textMuted))]);
    Widget box({Color? color, bool dashed = false, bool border = false}) {
      final c = Container(width: 16, height: 16, decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(3), border: border ? Border.all(color: theme.colorScheme.onSurface, width: 2) : null));
      return dashed ? DashedBorder(color: theme.textFaint, radius: 3, child: c) : c;
    }

    return Wrap(
      key: const ValueKey('month-legend'),
      spacing: 14,
      runSpacing: 6,
      children: [
        swatch(box(color: AppColors.kincha400), 'Đủ mục tiêu'),
        swatch(box(color: AppColors.kincha400.withValues(alpha: 0.3)), 'Chưa đủ'),
        swatch(box(color: AppColors.ink800), 'Chưa học'),
        swatch(box(dashed: true), 'Dự kiến'),
        swatch(box(border: true), 'Hôm nay'),
        swatch(Icon(Icons.circle, size: 10, color: theme.success), 'Xong khóa'),
        swatch(Text('ôn', style: TextStyle(fontSize: 10, color: theme.textFaint)), 'Ngày ôn tập'),
      ],
    );
  }
}

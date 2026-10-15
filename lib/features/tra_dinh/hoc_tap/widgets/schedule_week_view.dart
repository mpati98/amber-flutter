import 'package:flutter/material.dart';

import '../../../../shared/theme/app_theme.dart';
import '../../../../shared/utils/duration_format.dart';
import '../models/study_schedule.dart';
import '../models/study_subject.dart';
import 'hoc_tap_common.dart';
import 'schedule_day_row.dart';
import 'schedule_parts.dart';

/// Xem tuần: banner kế hoạch gốc, mỗi ngày một dòng, tổng kết tuần.
class ScheduleWeekView extends StatelessWidget {
  const ScheduleWeekView({super.key, required this.schedule, required this.subject, required this.noCourses});

  final StudySchedule schedule;
  final StudySubject subject;
  final bool noCourses;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: 8,
      children: [
        BaselineBanner(summary: schedule.summary, goalMinutes: subject.dailyGoalMinutes),
        for (final d in schedule.days) ScheduleDayRow(day: d, subject: subject, noCourses: noCourses),
        const SizedBox(height: 4),
        Text(
          'Tuần này: đã học ${formatDuration(schedule.summary.minutes)} · dự kiến thêm ${formatDuration(schedule.summary.plannedMinutes)}',
          key: const ValueKey('week-footer'),
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
        ),
        Text(
          'Ngày đã qua là buổi học thật. Ngày tới là dự kiến, tính từ các phần còn lại; học vượt thì lịch tự dời lên.',
          style: TextStyle(fontSize: 12, color: theme.textMuted),
        ),
      ],
    );
  }
}

/// Chân lịch khi môn chưa có khóa nào: nhắc + nút thêm khóa.
class NoCourseHint extends StatelessWidget {
  const NoCourseHint({super.key, required this.onAdd});

  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) => Column(
    key: const ValueKey('no-course-hint'),
    crossAxisAlignment: CrossAxisAlignment.stretch,
    spacing: 6,
    children: [
      Text('Chưa có khóa để xếp lịch. Thêm một khóa để lịch dự kiến các ngày tới.', style: TextStyle(fontSize: 13, color: Theme.of(context).textMuted)),
      OutlinedButton.icon(key: const ValueKey('schedule-add-course'), onPressed: onAdd, icon: const Icon(Icons.add), label: const Text('Khóa học')),
    ],
  );
}

/// Đặt trong file này để tái dùng: nút thử lại khi lỗi.
Widget scheduleError(VoidCallback retry) => HocTapLoadError(what: 'lịch học', onRetry: retry);

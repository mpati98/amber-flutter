import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../shared/theme/app_theme.dart';
import '../../../../shared/utils/date_format.dart';
import '../../../../shared/utils/vn_time.dart';
import '../models/study_enums.dart';
import '../models/study_subject.dart';
import '../providers/hoc_tap_provider.dart';
import '../utils/async_view.dart';
import '../utils/schedule_range.dart';
import '../widgets/course_form_sheet.dart';
import '../widgets/hoc_tap_common.dart';
import '../widgets/schedule_month_view.dart';
import '../widgets/schedule_parts.dart';
import '../widgets/schedule_week_view.dart';
import '../widgets/subject_sheet.dart';

/// Tab Lịch: xem tuần / tháng của môn đang chọn. Chế độ và mốc ngày nằm trên URL: `?tab=schedule&view=week|month&date=YYYY-MM-DD`.
class ScheduleTab extends ConsumerWidget {
  const ScheduleTab({super.key, this.view, this.date});

  final String? view;
  final String? date;

  bool get _month => view == 'month';

  void _go(BuildContext context, {bool? month, required String date}) =>
      context.go('/tra-dinh?tab=schedule&view=${(month ?? _month) ? 'month' : 'week'}&date=$date');

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final subjectsAsync = ref.watch(studySubjectsProvider);
    final selectedId = ref.watch(selectedSubjectIdProvider);
    final anchor = isValidIso(date) ? date! : vnToday();

    return HocTapBody(
      onRefresh: () async {
        ref.invalidate(studyScheduleProvider);
        ref.invalidate(studySubjectsProvider);
        await ref.read(studySubjectsProvider.future);
      },
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
        children: [
          switch (subjectsAsync) {
            AsyncData(:final value) when value.isEmpty => _NoSubject(),
            AsyncData(:final value) => _Loaded(
              subjects: value,
              subject: value.firstWhere((s) => s.id == selectedId, orElse: () => value.first),
              month: _month,
              anchor: anchor,
              onGo: (m, d) => _go(context, month: m, date: d),
            ),
            AsyncError() => HocTapLoadError(what: 'môn học', onRetry: () => ref.invalidate(studySubjectsProvider)),
            _ => const ScheduleSkeleton(),
          },
        ],
      ),
    );
  }
}

class _NoSubject extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Column(
    spacing: 10,
    children: [
      Text('Chưa có môn học nào. Tạo môn đầu tiên để xem lịch học.', style: TextStyle(color: Theme.of(context).textMuted)),
      FilledButton(key: const ValueKey('schedule-create-subject'), onPressed: () => showSubjectSheet(context), child: const Text('Tạo môn đầu tiên')),
    ],
  );
}

class _Loaded extends ConsumerWidget {
  const _Loaded({required this.subjects, required this.subject, required this.month, required this.anchor, required this.onGo});

  final List<StudySubject> subjects;
  final StudySubject subject;
  final bool month;
  final String anchor;
  final void Function(bool? month, String date) onGo;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final grid = monthGrid(anchor);
    final week = weekRange(anchor);
    final from = month ? grid.from : week.from;
    final to = month ? grid.to : week.to;
    final async = ref.watch(studyScheduleProvider(ScheduleQuery(subjectId: subject.id, from: from, to: to)));
    final liveCourses = ref.watch(studyCoursesProvider(CourseQuery(subjectId: subject.id, statuses: const [CourseStatus.active, CourseStatus.queued])));
    final noCourses = liveCourses.hasValue && liveCourses.value!.isEmpty;

    final title = month ? 'Tháng ${parseDay(grid.monthStart).month}/${parseDay(grid.monthStart).year}' : '${formatDayMonth(week.from)} – ${formatDayMonth(week.to)}';
    final prev = month ? firstOfMonth(anchor, -1) : addDays(anchor, -7);
    final next = month ? firstOfMonth(anchor, 1) : addDays(anchor, 7);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: 12,
      children: [
        if (subjects.length > 1)
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              for (final s in subjects)
                ChoiceChip(
                  key: ValueKey('schedule-subject-${s.id}'),
                  label: Text(s.name),
                  selected: s.id == subject.id,
                  showCheckmark: false,
                  selectedColor: AppColors.kincha400,
                  labelStyle: TextStyle(fontSize: 13, color: s.id == subject.id ? AppColors.ink950 : null),
                  onSelected: (_) => ref.read(selectedSubjectIdProvider.notifier).select(s.id),
                ),
            ],
          ),
        SegmentedButton<bool>(
          key: const ValueKey('view-toggle'),
          segments: const [ButtonSegment(value: false, label: Text('Tuần', key: ValueKey('view-week'))), ButtonSegment(value: true, label: Text('Tháng', key: ValueKey('view-month')))],
          selected: {month},
          showSelectedIcon: false,
          onSelectionChanged: (s) => onGo(s.first, anchor),
        ),
        Row(
          children: [
            IconButton(key: const ValueKey('nav-prev'), tooltip: month ? 'Tháng trước' : 'Tuần trước', onPressed: () => onGo(null, prev), icon: const Icon(Icons.chevron_left)),
            Expanded(child: Center(child: Text(title, key: const ValueKey('range-title'), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)))),
            IconButton(key: const ValueKey('nav-next'), tooltip: month ? 'Tháng sau' : 'Tuần sau', onPressed: () => onGo(null, next), icon: const Icon(Icons.chevron_right)),
            TextButton(key: const ValueKey('nav-today'), onPressed: () => onGo(null, vnToday()), child: const Text('Hôm nay')),
          ],
        ),
        switch (async.settled) {
          AsyncData(:final value) => month
              ? ScheduleMonthView(
                  schedule: value,
                  subject: subject,
                  monthStart: grid.monthStart,
                  monthEnd: grid.monthEnd,
                  noCourses: noCourses,
                  onAddCourse: () => showCourseFormSheet(context, subjectId: subject.id),
                )
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  spacing: 12,
                  children: [
                    ScheduleWeekView(schedule: value, subject: subject, noCourses: noCourses),
                    if (noCourses) NoCourseHint(onAdd: () => showCourseFormSheet(context, subjectId: subject.id)),
                  ],
                ),
          AsyncError() => scheduleError(() => ref.invalidate(studyScheduleProvider)),
          _ => ScheduleSkeleton(rows: month ? 5 : 7),
        },
      ],
    );
  }
}

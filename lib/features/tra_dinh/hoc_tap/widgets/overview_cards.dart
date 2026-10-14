import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../shared/theme/app_theme.dart';
import '../../../../shared/utils/duration_format.dart';
import '../../../../shared/utils/vn_time.dart';
import '../../../../shared/widgets/progress_bar.dart';
import '../../../../shared/widgets/scroll_card.dart';
import '../../../../shared/widgets/tag.dart';
import '../models/course.dart';
import '../models/study_log.dart';
import '../models/study_overview.dart';
import '../providers/hoc_tap_provider.dart';
import 'hoc_tap_common.dart';
import 'log_sheet.dart';

/// "09:41" theo giờ VN.
String vnClock(DateTime at) {
  final d = vnNow(at);
  return '${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';
}

/// Thẻ "Hôm nay" của môn đang chọn: phút / mục tiêu, số buổi, lý do dừng, các buổi đã ghi, phần kế tiếp, nút ghi buổi học.
class TodayCard extends ConsumerWidget {
  const TodayCard({super.key, required this.subject, required this.onLog});

  final SubjectOverview subject;
  final VoidCallback onLog;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final logs = ref.watch(studyTodayLogsProvider(subject.subjectId)).value ?? const <StudyLog>[];
    final theme = Theme.of(context);
    final today = subject.today;
    final goal = subject.goalMinutes;
    final next = subject.next;

    return ScrollCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: 10,
        children: [
          Row(
            children: [
              const Expanded(child: HocTapSectionTitle('Hôm nay')),
              if (today.done)
                Tag(
                  label: 'Đủ mục tiêu',
                  color: theme.success,
                  variant: TagVariant.tonal,
                ),
            ],
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                '${today.minutes}',
                key: const ValueKey('today-minutes'),
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                goal == null ? ' phút' : ' / $goal phút',
                style: TextStyle(fontSize: 14, color: theme.textMuted),
              ),
              const Spacer(),
              Text(
                today.logCount == 0
                    ? 'Chưa có buổi nào'
                    : '${today.logCount} buổi',
                style: TextStyle(fontSize: 12, color: theme.textMuted),
              ),
            ],
          ),
          if (goal != null)
            ProgressBar(value: today.minutes.toDouble(), max: goal.toDouble()),
          if (today.reason case final reason?)
            Align(
              alignment: Alignment.centerLeft,
              child: Tag(
                label: 'Dừng sớm: ${reason.label}',
                color: theme.colorScheme.secondary,
                variant: TagVariant.tonal,
              ),
            ),
          for (final l in logs) _LogRow(log: l),
          if (next != null)
            Text(
              'Tiếp theo: ${next.sectionTitle} · ${next.courseTitle}',
              key: const ValueKey('today-next'),
              style: TextStyle(fontSize: 13, color: theme.textMuted),
            ),
          FilledButton.icon(
            onPressed: onLog,
            icon: const Icon(Icons.edit_note),
            label: const Text('Ghi buổi học'),
          ),
        ],
      ),
    );
  }
}

class _LogRow extends StatelessWidget {
  const _LogRow({required this.log});

  final StudyLog log;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final sections = log.sections.map((s) => s.markedDone ? '${s.title} ✓' : s.title).join(', ');
    return InkWell(
      key: ValueKey('today-log-${log.id}'),
      onTap: () => showLogSheet(context, editing: log),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(width: 48, child: Text(vnClock(log.createdAt), style: TextStyle(fontSize: 12, color: theme.textMuted))),
            SizedBox(width: 44, child: Text('${log.minutes}p', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600))),
            Expanded(
              child: Text(
                [log.courseTitle ?? 'Ôn tập', if (sections.isNotEmpty) sections].join(' · '),
                style: TextStyle(fontSize: 12, color: theme.textMuted),
              ),
            ),
            Icon(Icons.edit_outlined, size: 14, color: theme.textFaint),
          ],
        ),
      ),
    );
  }
}

/// Thẻ khóa đang học: tiến độ, dự kiến xong, sớm/trễ; bấm → chi tiết.
class ActiveCourseCard extends StatelessWidget {
  const ActiveCourseCard({super.key, required this.course});

  final CourseView? course;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final c = course;
    if (c == null) {
      return ScrollCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: 6,
          children: [
            const HocTapSectionTitle('Khóa đang học'),
            Text(
              'Chưa có khóa đang học. Bắt đầu một khóa trong hàng chờ hoặc thêm khóa mới.',
              key: const ValueKey('no-active-course'),
              style: TextStyle(fontSize: 13, color: theme.textMuted),
            ),
          ],
        ),
      );
    }
    final p = c.progress;
    return InkWell(
      key: const ValueKey('active-course-card'),
      onTap: () => context.push('/tra-dinh/hoc-tap/courses/${c.id}'),
      child: ScrollCard(
        glow: ScrollCardGlow.kincha,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          spacing: 8,
          children: [
            const HocTapSectionTitle('Khóa đang học'),
            Text(
              c.title,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            if (c.byline.isNotEmpty)
              Text(
                c.byline,
                style: TextStyle(fontSize: 12, color: theme.textMuted),
              ),
            ProgressBar(
              value: p.doneMinutes.toDouble(),
              max: p.totalMinutes.toDouble(),
            ),
            Row(
              children: [
                Text(
                  '${p.doneSections}/${p.totalSections} phần · ${p.percent}%',
                  style: TextStyle(fontSize: 12, color: theme.textMuted),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    forecastLine(c.forecastFinishDate, c.deltaDays),
                    key: const ValueKey('active-forecast'),
                    textAlign: TextAlign.end,
                    style: TextStyle(
                      fontSize: 12,
                      color: c.deltaDays == null
                          ? theme.textMuted
                          : deltaColor(context, c.deltaDays!),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Hàng link tới Chờ học / Đã xong / Muốn mua, kèm số đếm.
class CourseLinksCard extends StatelessWidget {
  const CourseLinksCard({super.key, required this.subject});

  final SubjectOverview subject;

  @override
  Widget build(BuildContext context) {
    final id = subject.subjectId;
    final counts = subject.counts;
    return ScrollCard(
      child: Column(
        children: [
          _LinkRow(
            label: 'Chờ học',
            count: counts.queued,
            path: '/tra-dinh/hoc-tap/courses?subjectId=$id&status=QUEUED',
          ),
          _LinkRow(
            label: 'Đã xong',
            count: counts.done,
            path: '/tra-dinh/hoc-tap/courses?subjectId=$id&status=DONE',
          ),
          _LinkRow(
            label: 'Muốn mua',
            count: counts.wishlist,
            path: '/tra-dinh/hoc-tap/wishlist?subjectId=$id',
          ),
        ],
      ),
    );
  }
}

class _LinkRow extends StatelessWidget {
  const _LinkRow({
    required this.label,
    required this.count,
    required this.path,
  });

  final String label;
  final int count;
  final String path;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return InkWell(
      key: ValueKey('link-$label'),
      onTap: () => context.push(path),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Row(
          children: [
            Expanded(child: Text(label, style: const TextStyle(fontSize: 14))),
            Text(
              '$count',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.primary,
              ),
            ),
            Icon(Icons.chevron_right, color: theme.textFaint),
          ],
        ),
      ),
    );
  }
}

/// Mô tả ngắn thời lượng khóa: "5h 27p" hoặc "Chưa có phần".
String courseDurationLabel(CourseView c) => c.progress.totalMinutes == 0
    ? 'Chưa có phần'
    : formatDuration(c.progress.totalMinutes);

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../shared/theme/app_theme.dart';
import '../../../../shared/utils/date_format.dart';
import '../../../../shared/widgets/scroll_card.dart';
import '../models/course.dart';
import '../models/study_enums.dart';
import '../providers/hoc_tap_provider.dart';
import '../utils/async_view.dart';
import '../utils/hoc_tap_errors.dart';
import '../widgets/hoc_tap_common.dart';
import '../widgets/overview_cards.dart';
import '../../../../shared/widgets/app_bar_back.dart';

/// Danh sách khóa theo trạng thái (Chờ học / Đã xong...) của một môn. Chờ học có số thứ tự + nút lên/xuống.
class CourseListScreen extends ConsumerWidget {
  const CourseListScreen({super.key, this.subjectId, required this.statuses});

  final String? subjectId;
  final List<CourseStatus> statuses;

  String get _title {
    if (statuses.length == 1) return statuses.single.label;
    return 'Khóa học';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final query = CourseQuery(subjectId: subjectId, statuses: statuses);
    final async = ref.watch(studyCoursesProvider(query));
    final queued = statuses.length == 1 && statuses.single == CourseStatus.queued;

    return Scaffold(
      appBar: AppBar(leading: const AppBarBack(fallback: '/tra-dinh'), title: Text(_title)),
      body: HocTapBody(
        onRefresh: () => ref.refresh(studyCoursesProvider(query).future),
        child: switch (async.settled) {
          AsyncData(:final value) when value.isEmpty => ListView(children: [Padding(padding: const EdgeInsets.all(32), child: Center(child: Text('Chưa có khóa nào.', style: TextStyle(color: Theme.of(context).textMuted))))]),
          AsyncData(:final value) => ListView(
            padding: const EdgeInsets.all(16),
            children: [
              for (final (i, c) in value.indexed)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: _CourseTile(course: c, index: i, last: i == value.length - 1, ordered: queued),
                ),
            ],
          ),
          AsyncError() => ListView(children: [HocTapLoadError(what: 'danh sách khóa', onRetry: () => ref.invalidate(studyCoursesProvider(query)))]),
          _ => const Center(child: CircularProgressIndicator()),
        },
      ),
    );
  }
}

class _CourseTile extends ConsumerWidget {
  const _CourseTile({required this.course, required this.index, required this.last, required this.ordered});

  final CourseView course;
  final int index;
  final bool last;
  final bool ordered;

  Future<void> _move(BuildContext context, WidgetRef ref, bool up) async {
    try {
      await ref.read(hocTapActionsProvider).moveCourse(course.id, up: up);
    } catch (e) {
      if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(hocTapErrorMessage(e))));
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final c = course;
    final sub = [
      if (c.byline.isNotEmpty) c.byline,
      courseDurationLabel(c),
      if (c.status == CourseStatus.done && c.forecastFinishDate != null) 'xong ${formatDayMonth(c.forecastFinishDate!)}',
      if (c.status == CourseStatus.queued && c.forecastFinishDate != null) 'dự kiến ${formatDayMonth(c.forecastFinishDate!)}',
    ].join(' · ');

    return ScrollCard(
      child: Row(
        key: ValueKey('course-${c.id}'),
        children: [
          if (ordered) Padding(padding: const EdgeInsets.only(right: 12), child: Text('${index + 1}', key: ValueKey('order-${c.id}'), style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: AppColors.kincha400))),
          Expanded(
            child: InkWell(
              onTap: () => context.push('/tra-dinh/hoc-tap/courses/${c.id}'),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: 2,
                children: [
                  Text(c.title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
                  Text(sub, style: TextStyle(fontSize: 12, color: theme.textMuted)),
                ],
              ),
            ),
          ),
          if (ordered) ...[
            IconButton(key: ValueKey('up-${c.id}'), tooltip: 'Lên trước', visualDensity: VisualDensity.compact, onPressed: index == 0 ? null : () => _move(context, ref, true), icon: const Icon(Icons.arrow_upward, size: 20)),
            IconButton(key: ValueKey('down-${c.id}'), tooltip: 'Xuống sau', visualDensity: VisualDensity.compact, onPressed: last ? null : () => _move(context, ref, false), icon: const Icon(Icons.arrow_downward, size: 20)),
          ],
        ],
      ),
    );
  }
}

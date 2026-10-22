import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../shared/theme/app_theme.dart';
import '../../../../shared/widgets/scroll_card.dart';
import '../models/course.dart';
import '../models/study_enums.dart';
import '../providers/hoc_tap_provider.dart';
import '../utils/async_view.dart';
import '../utils/hoc_tap_errors.dart';
import '../utils/open_course_link.dart';
import '../widgets/course_form_sheet.dart';
import '../widgets/hoc_tap_common.dart';
import '../widgets/overview_cards.dart';
import '../../../../shared/widgets/app_bar_back.dart';

/// Muốn mua: các khóa chưa mua, kèm giá định mua, ghi chú; "Đã mua" chuyển vào hàng chờ.
class WishlistScreen extends ConsumerWidget {
  const WishlistScreen({super.key, this.subjectId});

  final String? subjectId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final query = CourseQuery(subjectId: subjectId, statuses: const [CourseStatus.wishlist]);
    final async = ref.watch(studyCoursesProvider(query));

    return Scaffold(
      appBar: AppBar(leading: const AppBarBack(fallback: '/tra-dinh'), title: const Text('Muốn mua')),
      floatingActionButton: FloatingActionButton.extended(
        key: const ValueKey('add-wishlist'),
        onPressed: () => showCourseFormSheet(context, subjectId: subjectId, initialStatus: CourseStatus.wishlist),
        icon: const Icon(Icons.add),
        label: const Text('Khóa muốn mua'),
      ),
      body: HocTapBody(
        onRefresh: () => ref.refresh(studyCoursesProvider(query).future),
        child: switch (async.settled) {
          AsyncData(:final value) when value.isEmpty => ListView(children: [Padding(padding: const EdgeInsets.all(32), child: Center(child: Text('Chưa có khóa nào muốn mua.', style: TextStyle(color: Theme.of(context).textMuted))))]),
          AsyncData(:final value) => ListView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
            children: [for (final c in value) Padding(padding: const EdgeInsets.only(bottom: 8), child: _WishCard(course: c))],
          ),
          AsyncError() => ListView(children: [HocTapLoadError(what: 'danh sách muốn mua', onRetry: () => ref.invalidate(studyCoursesProvider(query)))]),
          _ => const Center(child: CircularProgressIndicator()),
        },
      ),
    );
  }
}

class _WishCard extends ConsumerStatefulWidget {
  const _WishCard({required this.course});

  final CourseView course;

  @override
  ConsumerState<_WishCard> createState() => _WishCardState();
}

class _WishCardState extends ConsumerState<_WishCard> {
  bool _busy = false;

  Future<void> _bought() async {
    setState(() => _busy = true);
    try {
      await ref.read(hocTapActionsProvider).patchCourse(widget.course.id, {'status': CourseStatus.queued.api});
    } catch (e) {
      if (mounted) {
        setState(() => _busy = false);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(hocTapErrorMessage(e))));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final c = widget.course;
    final meta = [if (c.byline.isNotEmpty) c.byline, courseDurationLabel(c)].join(' · ');
    return ScrollCard(
      child: Column(
        key: ValueKey('wish-${c.id}'),
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: 6,
        children: [
          InkWell(onTap: () => context.push('/tra-dinh/hoc-tap/courses/${c.id}'), child: Text(c.title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600))),
          Text(meta, style: TextStyle(fontSize: 12, color: theme.textMuted)),
          if (c.targetPrice != null) Text('Giá định mua: ${c.targetPrice}', style: const TextStyle(fontSize: 13, color: AppColors.kincha400)),
          if (c.note != null) Text(c.note!, style: TextStyle(fontSize: 13, color: theme.textMuted)),
          Row(
            spacing: 8,
            children: [
              if (c.url != null) OutlinedButton(key: ValueKey('link-${c.id}'), onPressed: () => openCourseLink(context, c.url), child: const Text('Mở link')),
              FilledButton(key: ValueKey('bought-${c.id}'), onPressed: _busy ? null : _bought, child: const Text('Đã mua')),
            ],
          ),
        ],
      ),
    );
  }
}

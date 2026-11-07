import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../shared/theme/app_theme.dart';
import '../../../../shared/widgets/app_bar_back.dart';
import '../../../../shared/widgets/scroll_card.dart';
import '../models/study_overview.dart';
import '../providers/hoc_tap_provider.dart';
import '../utils/async_view.dart';
import '../widgets/course_form_sheet.dart';
import '../widgets/hoc_tap_common.dart';

/// Thư viện của môn: nơi quản lý (khóa học, thẻ từ vựng, trình độ), tách khỏi việc hằng ngày ở màn Hôm nay.
/// Các màn đích giữ nguyên; màn này chỉ là danh sách lối vào. `?subjectId=` thiếu thì dùng môn đang chọn.
class LibraryScreen extends ConsumerWidget {
  const LibraryScreen({super.key, this.subjectId});

  final String? subjectId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(studyOverviewProvider);
    final selected = ref.watch(selectedSubjectIdProvider);
    return Scaffold(
      appBar: AppBar(
        leading: const AppBarBack(fallback: '/tra-dinh'),
        title: const Text('Thư viện'),
      ),
      body: HocTapBody(
        onRefresh: () => ref.refresh(studyOverviewProvider.future),
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
          children: [
            switch (async.settled) {
              AsyncData(:final value) when value.subjects.isEmpty => const Text(
                'Chưa có môn học nào.',
              ),
              AsyncData(:final value) => _Sections(
                subject: value.subjects.firstWhere(
                  (s) => s.subjectId == (subjectId ?? selected),
                  orElse: () => value.subjects.first,
                ),
              ),
              AsyncError() => HocTapLoadError(
                what: 'thư viện',
                onRetry: () => ref.invalidate(studyOverviewProvider),
              ),
              _ => const Padding(
                padding: EdgeInsets.symmetric(vertical: 48),
                child: Center(child: CircularProgressIndicator()),
              ),
            },
          ],
        ),
      ),
    );
  }
}

class _Sections extends StatelessWidget {
  const _Sections({required this.subject});

  final SubjectOverview subject;

  @override
  Widget build(BuildContext context) {
    final id = subject.subjectId;
    final counts = subject.counts;
    final active = subject.activeCourse;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: 16,
      children: [
        Text(
          subject.name,
          key: const ValueKey('library-subject'),
          style: TextStyle(fontSize: 13, color: Theme.of(context).textMuted),
        ),
        _Group(
          title: 'Khóa học',
          rows: [
            _Row(
              keyName: 'active',
              label: 'Đang học',
              hint: active?.title,
              onTap: () => context.push(
                active == null
                    ? '/tra-dinh/hoc-tap/courses?subjectId=$id&status=ACTIVE'
                    : '/tra-dinh/hoc-tap/courses/${active.id}',
              ),
            ),
            _Row(
              keyName: 'queued',
              label: 'Chờ học',
              count: counts.queued,
              onTap: () => context.push(
                '/tra-dinh/hoc-tap/courses?subjectId=$id&status=QUEUED',
              ),
            ),
            _Row(
              keyName: 'done',
              label: 'Đã xong',
              count: counts.done,
              onTap: () => context.push(
                '/tra-dinh/hoc-tap/courses?subjectId=$id&status=DONE',
              ),
            ),
            _Row(
              keyName: 'wishlist',
              label: 'Muốn mua',
              count: counts.wishlist,
              onTap: () =>
                  context.push('/tra-dinh/hoc-tap/wishlist?subjectId=$id'),
            ),
            _Row(
              keyName: 'add-course',
              label: 'Thêm khóa',
              icon: Icons.add,
              onTap: () => showCourseFormSheet(context, subjectId: id),
            ),
          ],
        ),
        _Group(
          title: 'Thẻ từ vựng',
          rows: [
            _Row(
              keyName: 'cards',
              label: 'Kho thẻ',
              onTap: () => context.push('/tra-dinh/hoc-tap/the?subjectId=$id'),
            ),
            _Row(
              keyName: 'cards-import',
              label: 'Nhập thẻ mới',
              onTap: () =>
                  context.push('/tra-dinh/hoc-tap/the/them?subjectId=$id'),
            ),
            _Row(
              keyName: 'cards-hard',
              label: 'Thẻ khó',
              onTap: () =>
                  context.push('/tra-dinh/hoc-tap/the/thong-ke?subjectId=$id'),
            ),
          ],
        ),
        _Group(
          title: 'Trình độ',
          rows: [
            _Row(
              keyName: 'placement',
              label: 'Bài xếp trình độ',
              onTap: () => context.push('/tra-dinh/placement-test'),
            ),
          ],
        ),
      ],
    );
  }
}

class _Group extends StatelessWidget {
  const _Group({required this.title, required this.rows});

  final String title;
  final List<Widget> rows;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    spacing: 8,
    children: [
      HocTapSectionTitle(title),
      ScrollCard(child: Column(children: rows)),
    ],
  );
}

class _Row extends StatelessWidget {
  const _Row({
    required this.keyName,
    required this.label,
    required this.onTap,
    this.count,
    this.hint,
    this.icon,
  });

  final String keyName;
  final String label;
  final VoidCallback onTap;
  final int? count;
  final String? hint;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return InkWell(
      key: ValueKey('lib-$keyName'),
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          spacing: 8,
          children: [
            if (icon != null)
              Icon(icon, size: 18, color: theme.colorScheme.primary),
            Expanded(child: Text(label, style: const TextStyle(fontSize: 14))),
            if (hint != null)
              Flexible(
                child: Text(
                  hint!,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 12, color: theme.textMuted),
                ),
              ),
            if (count != null)
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

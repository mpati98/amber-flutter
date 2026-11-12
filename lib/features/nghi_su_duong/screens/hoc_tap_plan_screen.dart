import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../shared/theme/app_theme.dart';
import '../../../shared/theme/design_tokens.dart';
import '../../../shared/widgets/design_page.dart';
import '../../../shared/widgets/list_frame.dart';
import '../../../shared/widgets/overview_block.dart';
import '../../tra_dinh/hoc_tap/models/study_overview.dart';
import '../../tra_dinh/hoc_tap/providers/hoc_tap_provider.dart';
import '../../tra_dinh/hoc_tap/utils/async_view.dart';
import '../../tra_dinh/hoc_tap/widgets/course_form_sheet.dart';
import '../../tra_dinh/hoc_tap/widgets/hoc_tap_common.dart';
import '../../tra_dinh/hoc_tap/widgets/subject_sheet.dart';
import '../widgets/plan_widgets.dart';
import '../widgets/subject_plan_card.dart';

/// /hoc-tap: Học tập ở Nghị Sự Đường — lập kế hoạch học (môn, mục tiêu phút/ngày, khóa đang học, hàng chờ).
/// Dữ liệu từ studyOverviewProvider của Học tập (Trà Đình); các màn đích đều là màn Trà Đình hiện có.
class HocTapPlanScreen extends ConsumerWidget {
  const HocTapPlanScreen({super.key});

  /// Môn nhận khóa mới: môn đang chọn ở Trà Đình, không có thì môn đầu tiên.
  static String? _targetSubject(WidgetRef ref, List<SubjectOverview> subjects) {
    final selected = ref.read(selectedSubjectIdProvider);
    return subjects
            .where((s) => s.subjectId == selected)
            .firstOrNull
            ?.subjectId ??
        subjects.firstOrNull?.subjectId;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(studyOverviewProvider);
    final subjects = async.value?.subjects ?? const <SubjectOverview>[];

    final goal = subjects.fold<int>(0, (n, s) => n + (s.goalMinutes ?? 0));
    final active = subjects.where((s) => s.activeCourse != null).length;
    final queued = subjects.fold<int>(0, (n, s) => n + s.counts.queued);

    return DesignPage(
      title: 'Học tập',
      backFallback: '/nghi-su-duong',
      onRefresh: () => ref.refresh(studyOverviewProvider.future),
      overview: OverviewBlock(
        title: 'Tổng quan',
        labelWidth: 90,
        rows: [
          OverviewRow.muted(label: 'Kế hoạch', text: 'Học gì, bao nhiêu phút mỗi ngày'),
          if (async.hasValue) ...[
            OverviewRow.muted(
              label: 'Môn',
              text: subjects.isEmpty ? 'Chưa có môn nào' : '${subjects.length} môn · mục tiêu $goal phút/ngày',
            ),
            OverviewRow.muted(label: 'Khóa', text: '$active đang học · $queued chờ'),
          ],
        ],
      ),
      content: (context, _) => ListFrame(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Quản lý môn học (trước ở AppBar): thêm môn; sửa tên, mục tiêu phút/ngày, ngày ôn, xoá môn.
            Align(
              alignment: Alignment.centerRight,
              child: PopupMenuButton<String>(
                key: const ValueKey('plan-menu'),
                tooltip: 'Môn học',
                color: DesignColors.panel,
                onSelected: (v) => showSubjectSheet(context, subjectId: v == 'add' ? null : v),
                itemBuilder: (_) => [
                  const PopupMenuItem(value: 'add', key: ValueKey('menu-add-subject'), child: Text('+ Môn')),
                  for (final s in subjects)
                    PopupMenuItem(value: s.subjectId, key: ValueKey('menu-edit-${s.subjectId}'), child: Text('Cài đặt môn: ${s.name}')),
                ],
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    border: Border.all(color: DesignColors.gold),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Text('Môn học ⋯', style: TextStyle(fontSize: 13, color: DesignColors.gold)),
                ),
              ),
            ),
            const SizedBox(height: 10),
            switch (async.settled) {
              AsyncData(:final value) when value.subjects.isEmpty => _Empty(
                onAddCourse: () => showCourseFormSheet(context),
                onAddSubject: () => showSubjectSheet(context),
              ),
              AsyncData(:final value) => _Body(
                subjects: value.subjects,
                onAddCourse: () => showCourseFormSheet(context, subjectId: _targetSubject(ref, value.subjects)),
              ),
              AsyncError() => HocTapLoadError(
                what: 'kế hoạch học tập',
                onRetry: () => ref.invalidate(studyOverviewProvider),
              ),
              _ => const Padding(
                padding: EdgeInsets.symmetric(vertical: 32),
                child: Center(child: CircularProgressIndicator(color: DesignColors.gold)),
              ),
            },
            if (subjects.isNotEmpty || async.hasValue) ...[
              const SizedBox(height: 16),
              const Divider(color: DesignColors.rowDivider, height: 1),
              const SizedBox(height: 12),
              PlanNavRow(
                key: const ValueKey('plan-details'),
                label: 'Chi tiết kế hoạch',
                subtitle: 'Lịch dự kiến · Thống kê · Muốn mua · Đã xong · Thùng rác',
                onTap: () => context.push('/hoc-tap/chi-tiet'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _Body extends StatelessWidget {
  const _Body({required this.subjects, required this.onAddCourse});

  final List<SubjectOverview> subjects;
  final VoidCallback onAddCourse;

  @override
  Widget build(BuildContext context) {
    final queued = subjects.fold<int>(0, (n, s) => n + s.counts.queued);
    // Một môn: danh sách hàng chờ của môn đó; nhiều môn: hàng chờ của mọi môn (CourseListScreen không lọc môn).
    final queueRoute = subjects.length == 1
        ? '/tra-dinh/hoc-tap/courses?subjectId=${subjects.single.subjectId}&status=QUEUED'
        : '/tra-dinh/hoc-tap/courses?status=QUEUED';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: 12,
      children: [
        for (final s in subjects)
          SubjectPlanCard(
            subject: s,
            onTap: () => context.push(
              s.activeCourse == null
                  ? '/tra-dinh/hoc-tap/courses?subjectId=${s.subjectId}'
                  : '/tra-dinh/hoc-tap/courses/${s.activeCourse!.id}',
            ),
          ),
        PlanNavRow(
          key: const ValueKey('plan-queue'),
          label: 'Hàng chờ',
          trailing: '$queued khóa chờ',
          onTap: () => context.push(queueRoute),
        ),
        FilledButton(
          key: const ValueKey('plan-add-course'),
          style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(48)),
          onPressed: onAddCourse,
          child: const Text('+ Thêm khóa'),
        ),
      ],
    );
  }
}

class _Empty extends StatelessWidget {
  const _Empty({required this.onAddCourse, required this.onAddSubject});

  final VoidCallback onAddCourse;
  final VoidCallback onAddSubject;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    spacing: 12,
    children: [
      Text(
        'Chưa có môn học nào. Thêm môn và khóa đầu tiên để lập kế hoạch học.',
        key: const ValueKey('plan-empty'),
        style: TextStyle(color: Theme.of(context).textMuted),
      ),
      FilledButton(
        key: const ValueKey('plan-add-course'),
        style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(48)),
        onPressed: onAddCourse,
        child: const Text('+ Thêm khóa'),
      ),
      TextButton(
        key: const ValueKey('plan-add-subject'),
        onPressed: onAddSubject,
        child: const Text('Thêm môn học'),
      ),
    ],
  );
}

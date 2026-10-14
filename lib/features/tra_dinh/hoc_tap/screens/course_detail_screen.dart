import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../shared/theme/app_theme.dart';
import '../../../../shared/utils/api_error.dart';
import '../../../../shared/utils/date_format.dart';
import '../../../../shared/utils/duration_format.dart';
import '../../../../shared/utils/vn_time.dart';
import '../../../../shared/widgets/progress_bar.dart';
import '../../../../shared/widgets/scroll_card.dart';
import '../../../../shared/widgets/tag.dart';
import '../models/course.dart';
import '../models/study_enums.dart';
import '../providers/hoc_tap_provider.dart';
import '../utils/hoc_tap_errors.dart';
import '../utils/open_course_link.dart';
import '../widgets/course_form_sheet.dart';
import '../widgets/hoc_tap_common.dart';
import '../widgets/sections_editor_sheet.dart';

Color courseStatusColor(BuildContext context, CourseStatus s) => switch (s) {
  CourseStatus.active => AppColors.kincha400,
  CourseStatus.queued => AppColors.yugen500,
  CourseStatus.done => Theme.of(context).success,
  CourseStatus.wishlist => AppColors.yugen300,
  CourseStatus.unknown => Theme.of(context).textMuted,
};

/// Các đổi trạng thái hợp lệ từ [from]: (nhãn menu, trạng thái đích).
List<(String, CourseStatus)> statusChoices(CourseStatus from) => switch (from) {
  CourseStatus.active => const [('Về hàng chờ', CourseStatus.queued), ('Đánh dấu xong', CourseStatus.done), ('Chuyển sang Muốn mua', CourseStatus.wishlist)],
  CourseStatus.queued => const [('Bắt đầu học', CourseStatus.active), ('Đánh dấu xong', CourseStatus.done), ('Chuyển sang Muốn mua', CourseStatus.wishlist)],
  CourseStatus.wishlist => const [('Bắt đầu học', CourseStatus.active), ('Về hàng chờ', CourseStatus.queued)],
  CourseStatus.done => const [('Học lại (đang học)', CourseStatus.active), ('Về hàng chờ', CourseStatus.queued)],
  CourseStatus.unknown => const [],
};

enum _Menu { edit, sections, rebaseline, delete }

/// Chi tiết khóa học: tiến độ, các phần (tick), buổi học gần đây, menu thao tác.
class CourseDetailScreen extends ConsumerWidget {
  const CourseDetailScreen({super.key, required this.courseId});

  final String courseId;

  void _snack(BuildContext context, String text) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));

  Future<bool> _confirm(BuildContext context, String title, String body, String action) async =>
      await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(title),
          content: Text(body),
          actions: [
            TextButton(onPressed: () => Navigator.of(context).pop(false), child: const Text('Huỷ')),
            TextButton(onPressed: () => Navigator.of(context).pop(true), child: Text(action)),
          ],
        ),
      ) ??
      false;

  Future<void> _run(BuildContext context, Future<void> Function() action) async {
    try {
      await action();
    } catch (e) {
      if (context.mounted) _snack(context, hocTapErrorMessage(e));
    }
  }

  Future<void> _onMenu(BuildContext context, WidgetRef ref, _Menu m, CourseDetail d) async {
    final actions = ref.read(hocTapActionsProvider);
    switch (m) {
      case _Menu.edit:
        await showCourseFormSheet(context, course: d.course);
      case _Menu.sections:
        await showSectionsEditorSheet(context, courseId: courseId, sections: d.sections);
      case _Menu.rebaseline:
        if (await _confirm(context, 'Chốt lại kế hoạch?', 'Ngày xong dự kiến hiện tại của mọi khóa trong môn sẽ thành mốc mới để so sánh sớm/trễ.', 'Chốt lại') && context.mounted) {
          await _run(context, () async {
            await actions.rebaseline(d.course.subjectId);
            if (context.mounted) _snack(context, 'Đã chốt lại kế hoạch');
          });
        }
      case _Menu.delete:
        if (await _confirm(context, 'Xoá khóa học?', 'Xoá khóa "${d.course.title}" cùng các phần của nó? Nhật ký học vẫn được giữ.', 'Xoá') && context.mounted) {
          await _run(context, () async {
            await actions.deleteCourse(courseId);
            if (context.mounted) context.canPop() ? context.pop() : context.go('/tra-dinh');
          });
        }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(studyCourseDetailProvider(courseId));
    final detail = async.value;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Chi tiết khóa'),
        actions: [
          if (detail != null)
            PopupMenuButton<Object>(
              key: const ValueKey('course-menu'),
              onSelected: (v) {
                if (v is _Menu) _onMenu(context, ref, v, detail);
                if (v is CourseStatus) _run(context, () => ref.read(hocTapActionsProvider).patchCourse(courseId, {'status': v.api}));
              },
              itemBuilder: (context) => [
                const PopupMenuItem(value: _Menu.edit, child: Text('Sửa thông tin')),
                for (final (label, status) in statusChoices(detail.course.status)) PopupMenuItem(value: status, child: Text(label)),
                const PopupMenuItem(value: _Menu.sections, child: Text('Sửa các phần')),
                const PopupMenuItem(value: _Menu.rebaseline, child: Text('Chốt lại kế hoạch của môn')),
                const PopupMenuItem(value: _Menu.delete, child: Text('Xoá khóa học')),
              ],
            ),
        ],
      ),
      body: HocTapBody(
        onRefresh: () => ref.refresh(studyCourseDetailProvider(courseId).future),
        child: switch (async) {
          AsyncData(:final value) => _Detail(detail: value, onToggle: (id, done) => _toggle(context, ref, id, done)),
          AsyncError(:final error) =>
            apiErrorCode(error) == 'course_not_found'
                ? const Center(child: Text('Không tìm thấy khóa học'))
                : ListView(children: [HocTapLoadError(what: 'khóa học', onRetry: () => ref.invalidate(studyCourseDetailProvider(courseId)))]),
          _ => const Center(child: CircularProgressIndicator()),
        },
      ),
    );
  }

  Future<void> _toggle(BuildContext context, WidgetRef ref, String sectionId, bool done) async {
    try {
      await ref.read(studyCourseDetailProvider(courseId).notifier).setSectionDone(sectionId, done);
    } catch (e) {
      // Notifier đã hoàn tác state; chỉ báo lỗi.
      if (context.mounted) _snack(context, hocTapErrorMessage(e, 'Không cập nhật được phần học, thử lại'));
    }
  }
}

class _Detail extends StatelessWidget {
  const _Detail({required this.detail, required this.onToggle});

  final CourseDetail detail;
  final void Function(String sectionId, bool done) onToggle;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final c = detail.course;
    final p = c.progress;
    final finishedDate = c.finishedAt == null ? null : vnToday(c.finishedAt);
    final isWishlist = c.status == CourseStatus.wishlist;

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
      children: [
        Text(c.title, key: const ValueKey('course-title-text'), style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 4,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            Tag(label: c.status.label, color: courseStatusColor(context, c.status), variant: TagVariant.tonal),
            if (c.byline.isNotEmpty) Text(c.byline, style: TextStyle(fontSize: 13, color: theme.textMuted)),
          ],
        ),
        if (c.url != null) ...[
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerLeft,
            child: OutlinedButton.icon(key: const ValueKey('open-course'), onPressed: () => openCourseLink(context, c.url), icon: const Icon(Icons.open_in_new, size: 18), label: const Text('Mở khóa học')),
          ),
        ],
        if (isWishlist && (c.targetPrice != null || c.note != null)) ...[
          const SizedBox(height: 8),
          if (c.targetPrice != null) Text('Giá định mua: ${c.targetPrice}', style: const TextStyle(fontSize: 13)),
          if (c.note != null) Text(c.note!, style: TextStyle(fontSize: 13, color: theme.textMuted)),
        ],
        const SizedBox(height: 12),
        ScrollCard(
          glow: ScrollCardGlow.kincha,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            spacing: 8,
            children: [
              const HocTapSectionTitle('Tiến độ'),
              ProgressBar(value: p.doneMinutes.toDouble(), max: p.totalMinutes.toDouble()),
              Text('${p.doneSections}/${p.totalSections} phần · ${p.percent}%', key: const ValueKey('course-progress-text'), style: const TextStyle(fontSize: 13)),
              Text('Video còn ${formatDuration(p.remainingMinutes)}', key: const ValueKey('course-remaining'), style: TextStyle(fontSize: 13, color: theme.textMuted)),
              if (c.status == CourseStatus.done)
                Text(finishedDate == null ? 'Đã xong' : 'Xong ngày ${formatDayMonth(finishedDate)}', key: const ValueKey('course-finished'), style: TextStyle(fontSize: 13, color: theme.success))
              else if (c.status == CourseStatus.active || c.status == CourseStatus.queued)
                Text(
                  forecastLine(c.forecastFinishDate, c.deltaDays),
                  key: const ValueKey('course-forecast'),
                  style: TextStyle(fontSize: 13, color: c.deltaDays == null ? theme.textMuted : deltaColor(context, c.deltaDays!)),
                ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        const HocTapSectionTitle('Các phần'),
        const SizedBox(height: 4),
        if (detail.sections.isEmpty) Text('Chưa có phần nào. Thêm trong menu "Sửa các phần".', style: TextStyle(fontSize: 13, color: theme.textMuted)),
        for (final s in detail.sections) _SectionRow(section: s, isNext: s.id == c.nextSection?.id && !s.done, onToggle: onToggle),
        const SizedBox(height: 16),
        const HocTapSectionTitle('Buổi học gần đây'),
        const SizedBox(height: 4),
        if (detail.recentLogs.isEmpty)
          Text('Chưa có buổi học nào cho khóa này.', key: const ValueKey('no-logs'), style: TextStyle(fontSize: 13, color: theme.textMuted))
        else
          for (final l in detail.recentLogs)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(width: 56, child: Text(formatDayMonth(l.logDate), style: TextStyle(fontSize: 13, color: theme.textMuted))),
                  SizedBox(width: 56, child: Text(formatDuration(l.minutes), style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600))),
                  Expanded(child: Text(l.note ?? '', style: TextStyle(fontSize: 13, color: theme.textMuted))),
                ],
              ),
            ),
      ],
    );
  }
}

class _SectionRow extends StatelessWidget {
  const _SectionRow({required this.section, required this.isNext, required this.onToggle});

  final CourseSection section;
  final bool isNext;
  final void Function(String sectionId, bool done) onToggle;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      key: ValueKey('section-${section.id}'),
      margin: const EdgeInsets.symmetric(vertical: 2),
      decoration: BoxDecoration(
        color: isNext ? AppColors.kincha400.withValues(alpha: 0.12) : null,
        borderRadius: BorderRadius.circular(AppTheme.darkRadius),
        border: isNext ? Border.all(color: AppColors.kincha400.withValues(alpha: 0.6)) : null,
      ),
      child: Row(
        children: [
          Checkbox(key: ValueKey('check-${section.id}'), value: section.done, onChanged: (v) => onToggle(section.id, v ?? false)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  section.title,
                  style: TextStyle(fontSize: 14, color: section.done ? theme.textMuted : null, decoration: section.done ? TextDecoration.lineThrough : null),
                ),
                if (isNext) const Text('Đang học', key: ValueKey('now-label'), style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.kincha400)),
              ],
            ),
          ),
          Padding(padding: const EdgeInsets.only(right: 12), child: Text(formatDuration(section.durationMinutes), style: TextStyle(fontSize: 12, color: theme.textMuted))),
        ],
      ),
    );
  }
}

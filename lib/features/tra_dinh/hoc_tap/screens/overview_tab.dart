import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../shared/theme/app_theme.dart';
import '../../../../shared/widgets/scroll_card.dart';
import '../models/study_overview.dart';
import '../providers/hoc_tap_provider.dart';
import '../widgets/course_form_sheet.dart';
import '../widgets/hoc_tap_common.dart';
import '../widgets/overview_cards.dart';
import '../widgets/subject_sheet.dart';
import '../widgets/week_goal_card.dart';

/// Tab Tổng quan của Học tập.
class OverviewTab extends ConsumerWidget {
  const OverviewTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(studyOverviewProvider);
    final selectedId = ref.watch(selectedSubjectIdProvider);

    return HocTapBody(
      onRefresh: () => ref.refresh(studyOverviewProvider.future),
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
        children: [
          switch (async) {
            AsyncData(:final value) => _Loaded(overview: value, selectedId: selectedId),
            AsyncError() => HocTapLoadError(what: 'tổng quan học tập', onRetry: () => ref.invalidate(studyOverviewProvider)),
            _ => const Padding(padding: EdgeInsets.symmetric(vertical: 48), child: Center(child: CircularProgressIndicator())),
          },
          const SizedBox(height: 12),
          const _PracticeCard(),
        ],
      ),
    );
  }
}

class _Loaded extends ConsumerWidget {
  const _Loaded({required this.overview, required this.selectedId});

  final StudyOverview overview;
  final String? selectedId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (overview.subjects.isEmpty) return const _EmptyCard();
    final subject = overview.subjects.firstWhere((s) => s.subjectId == selectedId, orElse: () => overview.subjects.first);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: 12,
      children: [
        _SubjectChips(subjects: overview.subjects, selected: subject.subjectId),
        WeekGoalCard(overview: overview),
        TodayCard(
          subject: subject,
          onLog: () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Sắp có'))),
        ),
        ActiveCourseCard(course: subject.activeCourse),
        CourseLinksCard(subject: subject),
        OutlinedButton.icon(
          key: const ValueKey('add-course'),
          onPressed: () => showCourseFormSheet(context, subjectId: subject.subjectId),
          icon: const Icon(Icons.add),
          label: const Text('Khóa học'),
        ),
      ],
    );
  }
}

class _SubjectChips extends ConsumerWidget {
  const _SubjectChips({required this.subjects, required this.selected});

  final List<SubjectOverview> subjects;
  final String selected;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Wrap(
      spacing: 6,
      runSpacing: 6,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        for (final s in subjects)
          ChoiceChip(
            key: ValueKey('subject-chip-${s.subjectId}'),
            label: Text(s.name),
            selected: s.subjectId == selected,
            showCheckmark: false,
            selectedColor: AppColors.kincha400,
            labelStyle: TextStyle(fontSize: 13, color: s.subjectId == selected ? AppColors.ink950 : null),
            onSelected: (_) => ref.read(selectedSubjectIdProvider.notifier).select(s.subjectId),
          ),
        ActionChip(key: const ValueKey('add-subject'), label: const Text('+ Môn'), onPressed: () => showSubjectSheet(context)),
        IconButton(
          key: const ValueKey('edit-subject'),
          tooltip: 'Sửa môn học',
          visualDensity: VisualDensity.compact,
          icon: const Icon(Icons.tune, size: 20),
          onPressed: () => showSubjectSheet(context, subjectId: selected),
        ),
      ],
    );
  }
}

class _EmptyCard extends StatelessWidget {
  const _EmptyCard();

  @override
  Widget build(BuildContext context) => ScrollCard(
    glow: ScrollCardGlow.kincha,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: 10,
      children: [
        const HocTapSectionTitle('Học tập'),
        Text('Chưa có môn học nào. Tạo môn đầu tiên để đặt mục tiêu mỗi ngày và theo dõi các khóa học.', style: TextStyle(fontSize: 13, color: Theme.of(context).textMuted)),
        FilledButton(key: const ValueKey('create-first-subject'), onPressed: () => showSubjectSheet(context), child: const Text('Tạo môn đầu tiên')),
      ],
    ),
  );
}

class _PracticeCard extends StatelessWidget {
  const _PracticeCard();

  @override
  Widget build(BuildContext context) => InkWell(
    key: const ValueKey('practice-card'),
    onTap: () => context.push('/tra-dinh/luyen-tap'),
    child: ScrollCard(
      glow: ScrollCardGlow.yugen,
      child: Row(
        children: [
          const Text('🍵', style: TextStyle(fontSize: 24)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Luyện tập với AI', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
                Text('Trò chuyện, làm bài test, xem trình độ theo kỹ năng', style: TextStyle(fontSize: 12, color: Theme.of(context).textMuted)),
              ],
            ),
          ),
          Icon(Icons.chevron_right, color: Theme.of(context).textFaint),
        ],
      ),
    ),
  );
}

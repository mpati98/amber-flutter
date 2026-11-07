import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../shared/theme/app_theme.dart';
import '../../../../shared/widgets/scroll_card.dart';
import '../models/study_overview.dart';
import '../providers/hoc_tap_provider.dart';
import '../utils/async_view.dart';
import '../widgets/card_widgets.dart' show ChipScrollRow;
import '../widgets/hoc_tap_common.dart';
import '../widgets/today_main_card.dart';
import '../widgets/today_tasks_card.dart';
import '../widgets/subject_sheet.dart';

/// Tab Hôm nay của Học tập: thẻ chính, việc hôm nay, ô Thư viện.
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
          switch (async.settled) {
            AsyncData(:final value) => _Loaded(overview: value, selectedId: selectedId),
            AsyncError() => HocTapLoadError(what: 'tổng quan học tập', onRetry: () => ref.invalidate(studyOverviewProvider)),
            _ => const Padding(padding: EdgeInsets.symmetric(vertical: 48), child: Center(child: CircularProgressIndicator())),
          },
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
        // Chip chọn môn chỉ hiện khi có từ 2 môn; thêm môn / cài đặt môn nằm ở menu ⋯ của header.
        if (overview.subjects.length > 1) _SubjectChips(subjects: overview.subjects, selected: subject.subjectId),
        TodayMainCard(overview: overview, subject: subject),
        TodayTasksCard(subject: subject),
        _LibraryTile(subjectId: subject.subjectId),
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
    return ChipScrollRow(
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

class _LibraryTile extends StatelessWidget {
  const _LibraryTile({required this.subjectId});

  final String subjectId;

  @override
  Widget build(BuildContext context) => InkWell(
    key: const ValueKey('library-tile'),
    onTap: () => context.push('/tra-dinh/hoc-tap/thu-vien?subjectId=$subjectId'),
    child: ScrollCard(
      glow: ScrollCardGlow.yugen,
      child: Row(
        children: [
          const Icon(Icons.local_library_outlined, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Thư viện', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
                Text('Khóa học, thẻ từ vựng, trình độ', style: TextStyle(fontSize: 12, color: Theme.of(context).textMuted)),
              ],
            ),
          ),
          Icon(Icons.chevron_right, color: Theme.of(context).textFaint),
        ],
      ),
    ),
  );
}

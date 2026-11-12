import 'package:material_ui/material_ui.dart';
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
import '../widgets/log_sheet.dart';

/// Thân màn Hôm nay của Trà Đình: chip môn, thẻ chính, việc hôm nay, hàng Kho thẻ, liên kết ghi buổi học thủ công.
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
        _CardsTile(subjectId: subject.subjectId, total: subject.cards?.total),
        // Cuối màn, căn giữa: ghi buổi học thủ công.
        Center(
          child: TextButton(
            key: const ValueKey('manual-log'),
            style: TextButton.styleFrom(minimumSize: const Size(0, 44)),
            onPressed: () => showLogSheet(context, subjectId: subject.subjectId),
            child: const Text('Ghi buổi học thủ công'),
          ),
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
        Text('Chưa có môn học nào. Thêm môn và khóa đầu tiên ở kế hoạch học tập để đặt mục tiêu mỗi ngày.', style: TextStyle(fontSize: 13, color: Theme.of(context).textMuted)),
        FilledButton(key: const ValueKey('open-plan'), onPressed: () => context.push('/hoc-tap'), child: const Text('Mở kế hoạch học tập')),
      ],
    ),
  );
}

/// Hàng điều hướng "Kho thẻ": nhập thẻ, thẻ khó nằm trong màn Kho thẻ.
class _CardsTile extends StatelessWidget {
  const _CardsTile({required this.subjectId, this.total});

  final String subjectId;
  final int? total;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return InkWell(
      key: const ValueKey('cards-tile'),
      borderRadius: BorderRadius.circular(16),
      onTap: () => context.push('/tra-dinh/hoc-tap/the?subjectId=$subjectId'),
      child: Container(
        constraints: const BoxConstraints(minHeight: 56),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(color: scheme.surface, border: Border.all(color: scheme.onSurface.withValues(alpha: 0.12)), borderRadius: BorderRadius.circular(16)),
        child: Row(
          spacing: 12,
          children: [
            const Icon(Icons.style_outlined, size: 24),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Kho thẻ', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
                  Text(total == null ? 'Nhập thẻ, thẻ khó' : '$total thẻ · nhập thẻ, thẻ khó', key: const ValueKey('cards-tile-sub'), style: TextStyle(fontSize: 12, color: theme.textMuted)),
                ],
              ),
            ),
            Text('›', style: TextStyle(fontSize: 20, color: theme.textMuted)),
          ],
        ),
      ),
    );
  }
}

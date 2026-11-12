import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../shared/theme/design_tokens.dart';
import '../../../../shared/widgets/design_page.dart';
import '../../../../shared/widgets/list_frame.dart';
import '../../../../shared/widgets/overview_block.dart';
import '../models/study_overview.dart';
import '../providers/hoc_tap_provider.dart';
import '../utils/async_view.dart';
import '../widgets/hoc_tap_common.dart';
import '../widgets/log_sheet.dart';
import '../widgets/today_overview.dart';
import '../widgets/today_tasks_card.dart';

/// Màn Hôm nay của Trà Đình theo design/ref/tra-dinh.html: Tổng quan hôm nay → khung (chip môn · Ôn thẻ · Học bài tiếp ·
/// Luyện nói với AI · Kho thẻ) → "+ Ghi buổi học thủ công".
class OverviewTab extends ConsumerWidget {
  const OverviewTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(studyOverviewProvider).settled;
    final selectedId = ref.watch(selectedSubjectIdProvider);
    final overview = async.value;
    final subject = overview == null || overview.subjects.isEmpty
        ? null
        : overview.subjects.firstWhere((s) => s.subjectId == selectedId, orElse: () => overview.subjects.first);

    return DesignPage(
      title: 'Trà Đình',
      onRefresh: () => ref.refresh(studyOverviewProvider.future),
      overview: switch ((overview, subject)) {
        (final o?, final s?) => TodayOverview(overview: o, subject: s),
        _ => OverviewBlock(
          title: 'Tổng quan hôm nay',
          labelWidth: 90,
          rows: [
            OverviewRow.muted(
              label: 'Hôm nay',
              text: overview != null ? 'Chưa có môn học nào.' : (async.hasError ? 'Không tải được.' : 'Đang tải…'),
            ),
          ],
        ),
      },
      content: (context, _) => ListFrame(
        child: switch (async) {
          AsyncData(:final value) when subject != null => _Loaded(overview: value, subject: subject),
          AsyncData() => const _Empty(),
          AsyncError() => HocTapLoadError(what: 'tổng quan học tập', onRetry: () => ref.invalidate(studyOverviewProvider)),
          _ => const Padding(
            padding: EdgeInsets.symmetric(vertical: 32),
            child: Center(child: CircularProgressIndicator(color: DesignColors.gold)),
          ),
        },
      ),
      footer: subject == null
          ? null
          : Center(
              child: OutlinedButton(
                key: const ValueKey('manual-log'),
                onPressed: () => showLogSheet(context, subjectId: subject.subjectId),
                style: OutlinedButton.styleFrom(
                  foregroundColor: DesignColors.gold,
                  side: const BorderSide(color: DesignColors.gold),
                  minimumSize: const Size(0, 44),
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                  textStyle: DesignText.serif(fontSize: 13),
                ),
                child: const Text('+ Ghi buổi học thủ công'),
              ),
            ),
    );
  }
}

class _Loaded extends ConsumerWidget {
  const _Loaded({required this.overview, required this.subject});

  final StudyOverview overview;
  final SubjectOverview subject;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: 8,
      children: [
        // Chip chọn môn chỉ hiện khi có từ 2 môn; thêm môn / cài đặt môn nằm ở kế hoạch học tập (Nghị Sự Đường).
        if (overview.subjects.length > 1)
          DesignChipRow<String>(
            items: [for (final s in overview.subjects) (s.subjectId, s.name)],
            selected: subject.subjectId,
            keyOf: (id) => ValueKey('subject-chip-$id'),
            onSelected: (id) => ref.read(selectedSubjectIdProvider.notifier).select(id),
          ),
        TodayTasksCard(subject: subject),
        FrameRow(
          key: const ValueKey('cards-tile'),
          glyph: '庫',
          title: 'Kho thẻ',
          subtitle: subject.cards?.total == null ? 'Nhập thẻ, thẻ khó' : '${subject.cards!.total} thẻ · nhập thẻ, thẻ khó',
          trailing: const Text('›', style: TextStyle(fontSize: 20, color: DesignColors.gold)),
          onTap: () => context.push('/tra-dinh/hoc-tap/the?subjectId=${subject.subjectId}'),
        ),
      ],
    );
  }
}

class _Empty extends StatelessWidget {
  const _Empty();

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    spacing: 10,
    children: [
      const Text(
        'Chưa có môn học nào. Thêm môn và khóa đầu tiên ở kế hoạch học tập để đặt mục tiêu mỗi ngày.',
        style: DesignText.muted,
      ),
      FilledButton(
        key: const ValueKey('open-plan'),
        onPressed: () => context.push('/hoc-tap'),
        style: FilledButton.styleFrom(
          backgroundColor: DesignColors.gold,
          foregroundColor: const Color(0xFF1A1A1A),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
          textStyle: DesignText.serif(fontSize: 14),
        ),
        child: const Text('Mở kế hoạch học tập'),
      ),
    ],
  );
}

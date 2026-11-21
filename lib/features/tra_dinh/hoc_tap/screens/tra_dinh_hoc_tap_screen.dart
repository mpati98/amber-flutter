import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../shared/theme/design_tokens.dart';
import '../../../../shared/widgets/list_frame.dart';
import '../../../../shared/widgets/zone_frame.dart';
import '../../../../shared/widgets/zone_scaffold.dart';
import '../models/study_overview.dart';
import '../providers/card_provider.dart';
import '../providers/hoc_tap_provider.dart';
import '../utils/async_view.dart';
import '../widgets/card_library_panel.dart';
import '../widgets/card_sheet.dart';
import '../widgets/hoc_tap_common.dart';
import '../widgets/log_sheet.dart';
import '../widgets/today_overview.dart';
import '../widgets/today_tasks_card.dart';

/// /tra-dinh — MỘT màn cho Trà Đình ([ZoneScaffold], không cuộn trang): khung "Hôm nay" (chip môn ở đầu khung; tổng quan,
/// việc hôm nay với đúng một nút vàng theo `nextTodayAction`, buổi đã ghi, "+ Ghi buổi học thủ công") | khung "Kho thẻ"
/// (của môn đang chọn; tìm / lọc / chip giai đoạn, cuộn vô hạn; mở rộng toàn màn được). ≥ 600: hai cột 2 / 3; < 600: tab.
/// Các PHIÊN tập trung (ôn thẻ, học bài, luyện nói AI, bài test) vẫn là màn toàn màn hình riêng. Lịch, Thống kê, quản lý
/// khóa / môn ở Nghị Sự Đường (/hoc-tap…). Liên kết cũ `/tra-dinh?tab=…` được router chuyển hướng (xem app_router.dart).
///
/// - `?openLog=1&subjectId=…` (từ thẻ routine STUDY): chọn môn đó, tự mở sheet ghi buổi học MỘT lần rồi xoá query khỏi URL.
/// - `?kho=1[&subjectId=…]` (route cũ /tra-dinh/hoc-tap/the): chọn môn đó; điện thoại mở sẵn tab Kho thẻ.
class TraDinhHocTapScreen extends ConsumerStatefulWidget {
  const TraDinhHocTapScreen({super.key, this.openLog = false, this.subjectId, this.cards = false});

  final bool openLog;
  final String? subjectId;
  final bool cards;

  static const layout = ZoneRow([ZoneCell('today', flex: 2), ZoneCell('cards', flex: 3)]);

  @override
  ConsumerState<TraDinhHocTapScreen> createState() => _TraDinhHocTapScreenState();
}

class _TraDinhHocTapScreenState extends ConsumerState<TraDinhHocTapScreen> {
  @override
  void initState() {
    super.initState();
    if (widget.openLog) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _openLog());
    } else {
      _selectFromQuery();
    }
  }

  @override
  void didUpdateWidget(TraDinhHocTapScreen old) {
    super.didUpdateWidget(old);
    // Chỉ khi openLog vừa bật (false → true): sau khi mở sheet ta xoá query nên không lặp lại.
    if (widget.openLog && !old.openLog) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _openLog());
    } else if (widget.subjectId != old.subjectId) {
      _selectFromQuery();
    }
  }

  void _selectFromQuery() {
    final id = widget.subjectId;
    if (id != null) WidgetsBinding.instance.addPostFrameCallback((_) => ref.read(selectedSubjectIdProvider.notifier).select(id));
  }

  void _openLog() {
    if (!mounted) return;
    final subjectId = widget.subjectId;
    if (subjectId != null) ref.read(selectedSubjectIdProvider.notifier).select(subjectId);
    context.go('/tra-dinh'); // xoá openLog / subjectId khỏi URL → Hôm nay
    showLogSheet(context, subjectId: subjectId);
  }

  Future<void> _openImport(String subjectId) async {
    await context.push('/tra-dinh/hoc-tap/the/them?subjectId=$subjectId');
    if (!mounted) return;
    ref.invalidate(studyOverviewProvider); // số thẻ của khung Hôm nay
    await ref.read(cardLibraryProvider(subjectId).notifier).reload();
  }

  Future<void> _addCard(String subjectId) async {
    final changed = await showCardSheet(context, subjectId: subjectId);
    if (changed == true && mounted) await ref.read(cardLibraryProvider(subjectId).notifier).reload();
  }

  @override
  Widget build(BuildContext context) {
    final async = ref.watch(studyOverviewProvider).settled;
    final selectedId = ref.watch(selectedSubjectIdProvider);
    final overview = async.value;
    final subject = overview == null || overview.subjects.isEmpty
        ? null
        : overview.subjects.firstWhere((s) => s.subjectId == selectedId, orElse: () => overview.subjects.first);
    final subjectId = subject?.subjectId;

    final today = ZoneFrame(
      title: 'Hôm nay',
      onRefresh: () => ref.refresh(studyOverviewProvider.future),
      // Chip chọn môn chỉ hiện khi có từ 2 môn; thêm môn / cài đặt môn nằm ở kế hoạch học tập (Nghị Sự Đường).
      header: overview != null && overview.subjects.length > 1 && subject != null
          ? DesignChipRow<String>(
              items: [for (final s in overview.subjects) (s.subjectId, s.name)],
              selected: subject.subjectId,
              keyOf: (id) => ValueKey('subject-chip-$id'),
              onSelected: (id) => ref.read(selectedSubjectIdProvider.notifier).select(id),
            )
          : null,
      childBuilder: (_, _) => switch (async) {
        AsyncData(:final value) when subject != null => _Today(overview: value, subject: subject),
        AsyncData() => const _Empty(),
        AsyncError() => HocTapLoadError(what: 'tổng quan học tập', onRetry: () => ref.invalidate(studyOverviewProvider)),
        _ => const _Spinner(),
      },
    );

    final cards = ZoneFrame(
      title: 'Kho thẻ',
      expandable: true,
      // Panel có đầu cố định + danh sách cuộn vô hạn của riêng nó.
      scrollable: false,
      actions: [
        if (subjectId != null) ...[
          DesignButton.outline(key: const ValueKey('card-import'), label: '+ Nhập thẻ', onPressed: () => _openImport(subjectId)),
          IconButton(
            key: const ValueKey('card-add'),
            tooltip: 'Thêm một thẻ',
            color: DesignColors.gold,
            icon: const Icon(Icons.add),
            onPressed: () => _addCard(subjectId),
          ),
          IconButton(
            key: const ValueKey('card-stats'),
            tooltip: 'Thống kê',
            color: DesignColors.gold,
            icon: const Icon(Icons.insights_outlined),
            onPressed: () => context.push('/tra-dinh/hoc-tap/the/thong-ke?subjectId=$subjectId'),
          ),
        ],
      ],
      childBuilder: (_, _) => switch (async) {
        AsyncData() when subjectId != null => CardLibraryPanel(
          key: ValueKey('library-$subjectId'),
          subjectId: subjectId,
          onImport: () => _openImport(subjectId),
        ),
        AsyncData() => const Text('Chưa có môn học nào.', style: DesignText.muted),
        AsyncError() => HocTapLoadError(what: 'danh sách môn', onRetry: () => ref.invalidate(studyOverviewProvider)),
        _ => const _Spinner(),
      },
    );

    return ZoneScaffold(
      title: 'Trà Đình',
      wide: TraDinhHocTapScreen.layout,
      medium: TraDinhHocTapScreen.layout,
      initialPane: widget.cards ? 'cards' : null,
      panes: [
        ZonePane(id: 'today', label: 'Hôm nay', child: today),
        ZonePane(id: 'cards', label: 'Kho thẻ', child: cards),
      ],
    );
  }
}

/// Thân khung Hôm nay: tổng quan (phút / mục tiêu, chuỗi, tuần, ngày thiếu lý do) → việc hôm nay → ghi buổi thủ công.
class _Today extends StatelessWidget {
  const _Today({required this.overview, required this.subject});

  final StudyOverview overview;
  final SubjectOverview subject;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: 12,
      children: [
        TodayOverview(overview: overview, subject: subject),
        TodayTasksCard(subject: subject),
        Center(
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
      ],
    );
  }
}

class _Spinner extends StatelessWidget {
  const _Spinner();

  @override
  Widget build(BuildContext context) => const Padding(
    padding: EdgeInsets.symmetric(vertical: 32),
    child: Center(child: CircularProgressIndicator(color: DesignColors.gold)),
  );
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

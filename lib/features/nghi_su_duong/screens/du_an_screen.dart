import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/providers/auth_provider.dart';
import '../../../shared/theme/design_tokens.dart';
import '../../../shared/utils/vn_time.dart';
import '../../../shared/widgets/design_page.dart';
import '../../../shared/widgets/list_frame.dart';
import '../../../shared/widgets/overview_block.dart';
import '../models/project_summary.dart';
import '../providers/ats_tasks_provider.dart';
import '../providers/nghi_su_duong_provider.dart';
import '../widgets/ats_tasks_card.dart';
import '../widgets/attention_card.dart';
import '../widgets/new_project_modal.dart';
import '../widgets/project_card.dart';
import '../widgets/routines_card.dart';

const _weekdays = ['Thứ Hai', 'Thứ Ba', 'Thứ Tư', 'Thứ Năm', 'Thứ Sáu', 'Thứ Bảy', 'Chủ Nhật'];

/// Giờ VN, không theo múi giờ cài trên máy.
String _greeting() {
  final h = vnHour();
  if (h < 11) return 'Chào buổi sáng';
  if (h < 18) return 'Chào buổi chiều';
  return 'Chào buổi tối';
}

/// Như toLocaleDateString("vi-VN", {weekday: long, day, month: long}): "Thứ Tư, 30 tháng 9".
String _dateLabel() {
  final d = vnNow();
  return '${_weekdays[d.weekday - 1]}, ${d.day} tháng ${d.month}';
}

/// Tiêu đề nhỏ vàng in hoa của từng khu trong khung (như tiêu đề khối tổng quan).
class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.text);

  final String text;

  @override
  Widget build(BuildContext context) =>
      Text(text.toUpperCase(), style: const TextStyle(fontSize: 13, letterSpacing: 1, color: DesignColors.gold));
}

/// Màn Dự án theo bộ thiết kế mới: Tổng quan (lời chào + ngày, số dự án theo trạng thái, việc cần chú ý) → khung gồm
/// khu "Hôm nay" (Việc hằng ngày + Cần chú ý) và khu "Dự án" (chip trạng thái kèm số đếm + "+ Thêm dự án", lưới thẻ).
/// Khối "Công việc ATS": web rộng (2 cột) nằm dưới Tổng quan ở cột trái; điện thoại / máy tính bảng nằm giữa Hôm nay và Dự án.
/// Việc chỉ được tạo / xem bên trong một dự án (màn chi tiết), không có danh sách việc ở đây.
class DuAnScreen extends ConsumerWidget {
  const DuAnScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final summary = ref.watch(duAnSummaryProvider);
    final filter = ref.watch(duAnFilterProvider);
    final auth = ref.watch(authControllerProvider).value;
    final userName = auth is Authenticated ? auth.user['name'] as String? : null;
    final projects = summary.value?.projects;
    final attention = summary.value?.attention;
    int count(ProjectStatus s) => projects?.where((p) => p.status == s).length ?? 0;
    // Cùng cách DesignPage chọn bố cục (thân màn rộng đúng bằng màn hình; panel chat chỉ nổi đè, không làm hẹp).
    // Rộng (2 cột): khối ATS nằm dưới Tổng quan ở cột trái để cột phải chỉ còn Hôm nay + Dự án.
    final screen = MediaQuery.sizeOf(context);
    final split = DesignSize.of(screen.width) == DesignSize.wide;
    // Rộng và đủ cao: dashboard vừa đúng một màn (không cuộn trang, nội dung dài cuộn trong từng thẻ).
    // Thấp hơn [duAnDashboardMinHeight]: về bố cục cuộn trang của DesignPage.
    final dashboard = split && screen.height >= duAnDashboardMinHeight;

    final overview = OverviewBlock(
      title: 'Tổng quan',
      labelWidth: 90,
      rows: [
        OverviewRow.muted(
          label: 'Hôm nay',
          text: '${_greeting()}${userName != null && userName.isNotEmpty ? ', $userName' : ''} · ${_dateLabel()}',
        ),
        OverviewRow.muted(
          label: 'Dự án',
          text: projects == null
              ? (summary.hasError ? 'Không tải được.' : 'Đang tải…')
              : '${count(ProjectStatus.active)} đang triển khai · ${count(ProjectStatus.paused)} tạm dừng · '
                    '${count(ProjectStatus.done)} đã xong',
        ),
        OverviewRow(
          label: 'Chú ý',
          child: attention == null
              ? Text(summary.hasError ? 'Không tải được.' : 'Đang tải…', style: DesignText.muted)
              : attention.isEmpty
              ? const Text('Không có gì cần chú ý. Mọi thứ ổn.', style: TextStyle(color: DesignColors.success))
              : Text(
                  '${attention.where((a) => a.isOverdue).length} quá hạn · ${attention.where((a) => !a.isOverdue).length} nằm im',
                  style: const TextStyle(color: DesignColors.danger),
                ),
        ),
      ],
    );

    if (dashboard) {
      return DesignScaffold(
        title: 'Dự án',
        backFallback: '/nghi-su-duong',
        body: _Dashboard(overview: overview, summary: summary, filter: filter),
      );
    }

    return DesignPage(
      title: 'Dự án',
      backFallback: '/nghi-su-duong',
      onRefresh: () => Future.wait([
        ref.refresh(duAnSummaryProvider.future),
        ref.refresh(routinesProvider.future),
        // Khối ATS tự hiện lỗi của nó — lỗi ở đây không được làm hỏng lần kéo làm mới của cả màn.
        ref.refresh(atsTasksProvider.future).then<void>((_) {}, onError: (_) {}),
      ]),
      overview: split
          ? Column(
              key: const ValueKey('du-an-left-column'),
              crossAxisAlignment: CrossAxisAlignment.stretch,
              spacing: 14, // = khoảng cách giữa các khối của DesignPage
              children: [overview, const AtsTasksCard()],
            )
          : overview,
      // Khoảng cách giữa các khu = 12, như các màn khác (trước đây thêm SizedBox 4 → 28, thừa chỗ).
      content: (context, size) => ListFrame(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          spacing: 12,
          children: [
            const _SectionTitle('Hôm nay'),
            _TodayArea(summary: summary),
            if (!split) const AtsTasksCard(),
            _ProjectsArea(summary: summary, filter: filter),
          ],
        ),
      ),
    );
  }
}

/// Màn cao tối thiểu (px) để dùng dashboard vừa một màn; thấp hơn thì cuộn trang như DesignPage.
const duAnDashboardMinHeight = 640.0;

/// Khoảng cách giữa các khung của dashboard (giữa 2 cột và giữa các khung trong một cột) — một số cho cả màn.
const _dashGap = 16.0;

/// Lề đáy chừa cho nút chat nổi (như DesignPage).
const _dashBottom = 88.0;

/// Hàng "Việc hằng ngày" | "Cần chú ý" cao tối đa chừng này phần chiều cao cột phải.
const _todayRowMaxFraction = 0.35;

/// Bố cục dashboard (web rộng, đủ cao): khung trang cao đúng bằng màn (trừ thanh trên và lề đáy cho nút chat), 2 cột
/// `stretch` nên đáy bằng nhau.
/// - Trái: Tổng quan (cao theo nội dung) + Công việc ATS (lấp phần còn lại, danh sách cuộn trong thẻ).
/// - Phải: khung "Hôm nay" (2 thẻ luôn cao bằng nhau, tối đa ~35% cột, cuộn trong thẻ) + khung "Dự án" (lấp phần còn lại,
///   lưới cuộn trong khung). Hai khung riêng thay vì một khung bao chung để đỉnh "Hôm nay" = đỉnh "Tổng quan" và
///   đáy "Dự án" = đáy "Công việc ATS".
class _Dashboard extends StatelessWidget {
  const _Dashboard({required this.overview, required this.summary, required this.filter});

  final Widget overview;
  final AsyncValue<DuAnSummary> summary;
  final ProjectStatus filter;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, c) {
        final w = c.maxWidth;
        final gutter = DesignLayout.gutter(w);
        final columnHeight = (c.maxHeight - 24 - _dashBottom).clamp(0.0, double.infinity);
        return Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: DesignLayout.maxContentWidth(w)),
            child: Padding(
              padding: EdgeInsets.fromLTRB(gutter, 24, gutter, _dashBottom),
              child: SizedBox(
                height: columnHeight,
                child: Row(
                  key: const ValueKey('du-an-dashboard'),
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  spacing: _dashGap,
                  children: [
                    SizedBox(
                      width: 380,
                      child: Column(
                        key: const ValueKey('du-an-left-column'),
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        spacing: _dashGap,
                        children: [overview, const Expanded(child: AtsTasksCard(fill: true))],
                      ),
                    ),
                    Expanded(
                      child: Column(
                        key: const ValueKey('du-an-right-column'),
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        spacing: _dashGap,
                        children: [
                          ListFrame(
                            key: const ValueKey('du-an-today-frame'),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              spacing: 12,
                              children: [
                                const _SectionTitle('Hôm nay'),
                                _TodayRow(summary: summary, maxHeight: columnHeight * _todayRowMaxFraction),
                              ],
                            ),
                          ),
                          Expanded(
                            child: ListFrame(
                              key: const ValueKey('du-an-projects-frame'),
                              child: _ProjectsArea(summary: summary, filter: filter, fill: true),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

/// Hàng "Việc hằng ngày" | "Cần chú ý" của dashboard: luôn cạnh nhau, CAO BẰNG NHAU (IntrinsicHeight lấy thẻ cao hơn),
/// không vượt [maxHeight] — vượt thì mỗi thẻ cuộn bên trong. Không có LayoutBuilder bên trong (IntrinsicHeight không đo được).
class _TodayRow extends StatelessWidget {
  const _TodayRow({required this.summary, required this.maxHeight});

  final AsyncValue<DuAnSummary> summary;
  final double maxHeight;

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: BoxConstraints(maxHeight: maxHeight),
      child: IntrinsicHeight(
        child: Row(
          key: const ValueKey('du-an-today-row'),
          crossAxisAlignment: CrossAxisAlignment.stretch,
          spacing: 12,
          children: [
            const Expanded(child: RoutinesCard(fill: true)),
            Expanded(
              child: AttentionCard(
                items: summary.value?.attention,
                loading: summary.isLoading,
                failed: summary.hasError,
                fill: true,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Khu "Hôm nay": thẻ "Việc hằng ngày" và thẻ "Cần chú ý" — cạnh nhau khi khung rộng, hẹp hơn thì xếp dọc.
class _TodayArea extends StatelessWidget {
  const _TodayArea({required this.summary});

  final AsyncValue<DuAnSummary> summary;

  @override
  Widget build(BuildContext context) {
    const routines = RoutinesCard();
    final attention = AttentionCard(
      items: summary.value?.attention,
      loading: summary.isLoading,
      failed: summary.hasError,
    );
    return LayoutBuilder(
      builder: (context, c) => c.maxWidth >= 640
          ? Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 12,
              children: [const Expanded(child: routines), Expanded(child: attention)],
            )
          : Column(crossAxisAlignment: CrossAxisAlignment.stretch, spacing: 12, children: [routines, attention]),
    );
  }
}

/// Khu "Dự án": chip trạng thái kèm số đếm + "+ Thêm dự án", rồi lưới thẻ.
/// [fill] (dashboard): lấp chiều cao cha cấp, tiêu đề + thanh chip cố định, lưới cuộn bên trong.
class _ProjectsArea extends ConsumerWidget {
  const _ProjectsArea({required this.summary, required this.filter, this.fill = false});

  final AsyncValue<DuAnSummary> summary;
  final ProjectStatus filter;
  final bool fill;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final projects = summary.value?.projects;
    int count(ProjectStatus s) => projects?.where((p) => p.status == s).length ?? 0;
    String label(String name, ProjectStatus s) => '$name · ${projects == null ? '–' : count(s)}';
    final shown = projects?.where((p) => p.status == filter).toList();
    final Widget list = summary.hasError && projects == null
        ? const Text('Không tải được dự án.', style: DesignText.muted)
        : shown == null
        ? const Text('Đang tải...', style: DesignText.muted)
        : shown.isEmpty
        ? const Text('Không có dự án nào ở trạng thái này.', style: DesignText.muted)
        : ProjectGrid(projects: shown);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: 10,
      children: [
        const _SectionTitle('Dự án'),
        FrameToolbar(
          chips: DesignChipRow<ProjectStatus>(
            items: [
              (ProjectStatus.active, label('Đang triển khai', ProjectStatus.active)),
              (ProjectStatus.paused, label('Tạm dừng', ProjectStatus.paused)),
              (ProjectStatus.done, label('Đã xong', ProjectStatus.done)),
            ],
            selected: filter,
            onSelected: ref.read(duAnFilterProvider.notifier).select,
          ),
          action: DesignButton.outline(
            key: const ValueKey('add-project'),
            label: '+ Thêm dự án',
            onPressed: () => showNewProjectModal(context),
          ),
        ),
        if (fill)
          Expanded(child: SingleChildScrollView(key: const ValueKey('projects-scroll'), child: list))
        else
          list,
      ],
    );
  }
}

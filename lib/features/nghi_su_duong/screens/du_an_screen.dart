import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/providers/auth_provider.dart';
import '../../../shared/theme/design_tokens.dart';
import '../../../shared/utils/vn_time.dart';
import '../../../shared/widgets/design_page.dart';
import '../../../shared/widgets/list_frame.dart';
import '../../../shared/widgets/overview_block.dart';
import '../models/project_summary.dart';
import '../providers/nghi_su_duong_provider.dart';
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

    return DesignPage(
      title: 'Dự án',
      backFallback: '/nghi-su-duong',
      onRefresh: () => Future.wait([ref.refresh(duAnSummaryProvider.future), ref.refresh(routinesProvider.future)]),
      overview: OverviewBlock(
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
      ),
      content: (context, _) => ListFrame(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          spacing: 12,
          children: [
            const _SectionTitle('Hôm nay'),
            _TodayArea(summary: summary),
            const SizedBox(height: 4),
            _ProjectsArea(summary: summary, filter: filter),
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
class _ProjectsArea extends ConsumerWidget {
  const _ProjectsArea({required this.summary, required this.filter});

  final AsyncValue<DuAnSummary> summary;
  final ProjectStatus filter;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final projects = summary.value?.projects;
    int count(ProjectStatus s) => projects?.where((p) => p.status == s).length ?? 0;
    String label(String name, ProjectStatus s) => '$name · ${projects == null ? '–' : count(s)}';
    final shown = projects?.where((p) => p.status == filter).toList();

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
        if (summary.hasError && projects == null)
          const Text('Không tải được dự án.', style: DesignText.muted)
        else if (shown == null)
          const Text('Đang tải...', style: DesignText.muted)
        else if (shown.isEmpty)
          const Text('Không có dự án nào ở trạng thái này.', style: DesignText.muted)
        else
          ProjectGrid(projects: shown),
      ],
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/providers/auth_provider.dart';
import '../../../shared/theme/app_theme.dart';
import '../../../shared/utils/vn_time.dart';
import '../../../shared/widgets/form_bits.dart';
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

TextStyle _muted(double size) => TextStyle(fontSize: size, color: Colors.white.withValues(alpha: 0.4));

/// Màn Dự án: lời chào + khu "Dự án" (bộ lọc trạng thái + lưới thẻ từ GET /api/du-an/summary).
/// Việc chỉ được tạo / xem bên trong một dự án (màn chi tiết), không có danh sách việc ở đây.
class DuAnScreen extends ConsumerWidget {
  const DuAnScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final summary = ref.watch(duAnSummaryProvider);
    final filter = ref.watch(duAnFilterProvider);
    final auth = ref.watch(authControllerProvider).value;
    final userName = auth is Authenticated ? auth.user['name'] as String? : null;

    return Scaffold(
      appBar: AppBar(title: const Text('Dự án')),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1100),
          child: RefreshIndicator(
            onRefresh: () => Future.wait([ref.refresh(duAnSummaryProvider.future), ref.refresh(routinesProvider.future)]),
            child: ListView(
              // Luôn kéo-để-làm-mới được kể cả khi nội dung ngắn (danh sách rỗng).
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              children: [
                Text(
                  '${_greeting()}${userName != null && userName.isNotEmpty ? ', $userName' : ''}',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontSize: 14,
                        fontStyle: FontStyle.italic,
                        color: AppColors.kincha400,
                      ),
                ),
                const SizedBox(height: 4),
                Text(_dateLabel(), style: _muted(12)),
                const SizedBox(height: 24), // gap-6
                _TodayArea(summary: summary),
                const SizedBox(height: 24),
                _ProjectsArea(summary: summary, filter: filter),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Khu "Hôm nay": thẻ "Việc hằng ngày" và thẻ "Cần chú ý" — cạnh nhau từ ~900, hẹp hơn thì xếp dọc.
class _TodayArea extends StatelessWidget {
  const _TodayArea({required this.summary});

  final AsyncValue<DuAnSummary> summary;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    const routines = RoutinesCard();
    final attention = AttentionCard(
      items: summary.value?.attention,
      loading: summary.isLoading,
      failed: summary.hasError,
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: 12,
      children: [
        Text('Hôm nay', style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontSize: 18, color: cs.onSurface)),
        LayoutBuilder(
          builder: (context, c) => c.maxWidth >= 900
              ? Row(crossAxisAlignment: CrossAxisAlignment.start, spacing: 16, children: [const Expanded(child: routines), Expanded(child: attention)])
              : Column(crossAxisAlignment: CrossAxisAlignment.stretch, spacing: 16, children: [routines, attention]),
        ),
      ],
    );
  }
}

/// Khu "Dự án": tiêu đề + bộ lọc trạng thái kèm số đếm + nút thêm, rồi lưới thẻ.
class _ProjectsArea extends ConsumerWidget {
  const _ProjectsArea({required this.summary, required this.filter});

  final AsyncValue<DuAnSummary> summary;
  final ProjectStatus filter;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = Theme.of(context).colorScheme;
    final muted = TextStyle(fontSize: 12, color: cs.onSurface.withValues(alpha: 0.6));
    final projects = summary.value?.projects;
    int count(ProjectStatus s) => projects?.where((p) => p.status == s).length ?? 0;
    String label(String name, ProjectStatus s) => '$name · ${projects == null ? '–' : count(s)}';
    final shown = projects?.where((p) => p.status == filter).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: 12,
      children: [
        Wrap(
          spacing: 12,
          runSpacing: 8,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            Text('Dự án', style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontSize: 18, color: cs.onSurface)),
            ChoiceRow<ProjectStatus>(
              options: {
                ProjectStatus.active: label('Đang triển khai', ProjectStatus.active),
                ProjectStatus.paused: label('Tạm dừng', ProjectStatus.paused),
                ProjectStatus.done: label('Đã xong', ProjectStatus.done),
              },
              selected: filter,
              onSelected: ref.read(duAnFilterProvider.notifier).select,
            ),
            TextButton.icon(
              onPressed: () => showNewProjectModal(context),
              icon: const Icon(Icons.add, size: 18),
              label: const Text('Thêm dự án'),
            ),
          ],
        ),
        if (summary.hasError && projects == null)
          Text('Không tải được dự án.', style: muted)
        else if (shown == null)
          Text('Đang tải...', style: muted)
        else if (shown.isEmpty)
          Text('Không có dự án nào ở trạng thái này.', style: muted)
        else
          ProjectGrid(projects: shown),
      ],
    );
  }
}

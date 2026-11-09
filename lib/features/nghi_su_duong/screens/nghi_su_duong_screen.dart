import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../shared/theme/app_theme.dart';
import '../../../shared/utils/currency.dart';
import '../../../shared/widgets/progress_bar.dart';
import '../../../shared/widgets/scroll_card.dart';
import '../../tra_dinh/hoc_tap/providers/hoc_tap_provider.dart';
import '../providers/nghi_su_duong_provider.dart';
import '../../../shared/widgets/app_bar_back.dart';

/// Port /nghi-su-duong: trang chính 3 mảng Dự án / Tài chính / Học tập.
/// Xếp 1 cột thay cho lưới 1–3 cột bên web.
class NghiSuDuongScreen extends ConsumerWidget {
  const NghiSuDuongScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Đường dẫn cấp gốc như web (không nằm dưới /nghi-su-duong).
    void push(String path) => context.push(path);

    return Scaffold(
      appBar: AppBar(leading: const AppBarBack(), title: const Text('Nghị Sự Đường')),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 640),
          child: RefreshIndicator(
            onRefresh: () => Future.wait([
              ref.refresh(duAnOverviewProvider.future),
              ref.refresh(financeOverviewProvider.future),
              // Học tập: lỗi tải không được làm hỏng việc làm mới hai mảng kia.
              ref.refresh(studyOverviewProvider.future).then<void>((_) {}, onError: (_) {}),
            ]),
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _DuAnCard(onTap: () => push('/du-an')),
                const SizedBox(height: 20), // gap-5
                _FinanceCard(onTap: () => push('/finance')),
                const SizedBox(height: 20),
                _LearnCard(onTap: () => push('/hoc-tap')),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Khung chung của các card: tiêu đề serif + chữ nhỏ bên phải, thân tuỳ mảng ([child] null = chỉ tiêu đề).
class _HubCard extends StatelessWidget {
  const _HubCard({required this.title, this.trailing, required this.glow, required this.onTap, this.child});

  final String title;
  final String? trailing;
  final ScrollCardGlow glow;
  final VoidCallback onTap;
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: ScrollCard(
        glow: glow,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontSize: 18, color: Colors.white),
                  ),
                ),
                if (trailing != null) Text(trailing!, style: _muted(11)),
              ],
            ),
            if (child != null) ...[
              const SizedBox(height: 12), // mb-3
              child!,
            ],
          ],
        ),
      ),
    );
  }
}

TextStyle _muted(double size) => TextStyle(fontSize: size, color: Colors.white.withValues(alpha: 0.4));

/// Ngày "YYYY-MM-DD" → "d/M/yyyy" như toLocaleDateString("vi-VN").
String _viDate(String iso) {
  final p = iso.split('-');
  return '${int.parse(p[2])}/${int.parse(p[1])}/${p[0]}';
}

class _DuAnCard extends ConsumerWidget {
  const _DuAnCard({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final overview = ref.watch(duAnOverviewProvider);
    final data = overview.value;
    final upcoming = data?.upcomingProjects.firstOrNull;

    return _HubCard(
      title: '📋 Dự án thông thường',
      trailing: '${data?.completedThisYear ?? 0} xong năm nay',
      glow: ScrollCardGlow.yugen,
      onTap: onTap,
      child: overview.hasError
          ? Text('Không tải được số liệu.', style: _muted(14))
          : Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              spacing: 12, // gap-3
              children: [
                if (data == null)
                  Text('Đang tải...', style: _muted(14))
                else if (data.activeProjects.isEmpty)
                  Text('Chưa có dự án nào đang triển khai.', style: _muted(14))
                else
                  for (final p in data.activeProjects.take(3))
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      spacing: 4,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                p.name,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(fontSize: 12, color: Colors.white.withValues(alpha: 0.8)),
                              ),
                            ),
                            Text('${p.progressPct}%', style: _muted(12)),
                          ],
                        ),
                        ProgressBar(value: p.progressPct.toDouble(), max: 100),
                      ],
                    ),
                if (upcoming != null)
                  Text('Sắp tới: ${upcoming.name} (${_viDate(upcoming.startDate)})', style: _muted(12)),
              ],
            ),
    );
  }
}

class _FinanceCard extends ConsumerWidget {
  const _FinanceCard({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final overview = ref.watch(financeOverviewProvider);
    final data = overview.value;

    return _HubCard(
      title: '💰 Tài chính',
      trailing: data?.activeProjectName,
      glow: ScrollCardGlow.kincha,
      onTap: onTap,
      // Web hiện "0₫" trong lúc chờ (`currentBalance ?? 0`) — dễ tưởng nhầm là hết tiền.
      child: overview.hasError
          ? Text('Không tải được số liệu.', style: _muted(14))
          : data == null
          ? Text('Đang tải...', style: _muted(14))
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  formatVnd(data.currentBalance),
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(color: AppColors.kincha400),
                ),
                const SizedBox(height: 8), // mt-2
                Row(
                  spacing: 12,
                  children: [
                    Text(
                      '+${formatVnd(data.totalIncome)}',
                      style: const TextStyle(fontSize: 12, color: AppColors.emerald300),
                    ),
                    Text(
                      '−${formatVnd(data.totalExpense)}',
                      style: const TextStyle(fontSize: 12, color: AppColors.shuiro500),
                    ),
                  ],
                ),
              ],
            ),
    );
  }
}

/// Card Học tập (kế hoạch). Dòng phụ lấy từ studyOverviewProvider; đang tải hoặc lỗi thì chỉ có tiêu đề, không chặn card.
class _LearnCard extends ConsumerWidget {
  const _LearnCard({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final subjects = ref.watch(studyOverviewProvider).value?.subjects ?? const [];
    final active = subjects.map((s) => s.activeCourse).nonNulls.firstOrNull;
    final queued = subjects.fold<int>(0, (n, s) => n + s.counts.queued);
    final line = active != null ? 'Đang học: ${active.title}' : (queued > 0 ? '$queued khóa chờ' : null);

    return _HubCard(
      title: '🎓 Học tập',
      glow: ScrollCardGlow.shuiro,
      onTap: onTap,
      child: line == null ? null : Text(line, key: const ValueKey('learn-card-line'), maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 14, color: Colors.white.withValues(alpha: 0.8))),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/theme/app_theme.dart';
import '../../../shared/utils/currency.dart';
import '../../../shared/widgets/progress_bar.dart';
import '../../../shared/widgets/scroll_card.dart';
import '../providers/nghi_su_duong_provider.dart';
import 'du_an_screen.dart';
import 'finance_screen.dart';
import 'hoc_tap_screen.dart';

/// Port /nghi-su-duong: trang chính 3 mảng Dự án / Tài chính / Học tập.
/// Xếp 1 cột thay cho lưới 1–3 cột bên web.
class NghiSuDuongScreen extends ConsumerWidget {
  const NghiSuDuongScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    void push(Widget screen) => Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => screen));

    return Scaffold(
      appBar: AppBar(title: const Text('Nghị Sự Đường')),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 640),
          child: RefreshIndicator(
            onRefresh: () => Future.wait([
              ref.refresh(duAnOverviewProvider.future),
              ref.refresh(financeOverviewProvider.future),
              ref.refresh(learnOverviewProvider.future),
            ]),
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _DuAnCard(onTap: () => push(const DuAnScreen())),
                const SizedBox(height: 20), // gap-5
                _FinanceCard(onTap: () => push(const FinanceScreen())),
                const SizedBox(height: 20),
                _LearnCard(onTap: () => push(const HocTapScreen())),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Khung chung của 3 card: tiêu đề serif + chữ nhỏ bên phải, thân tuỳ mảng.
class _HubCard extends StatelessWidget {
  const _HubCard({required this.title, this.trailing, required this.glow, required this.onTap, required this.child});

  final String title;
  final String? trailing;
  final ScrollCardGlow glow;
  final VoidCallback onTap;
  final Widget child;

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
            const SizedBox(height: 12), // mb-3
            child,
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

class _LearnCard extends ConsumerWidget {
  const _LearnCard({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final overview = ref.watch(learnOverviewProvider);
    final data = overview.value;
    final course = data?.currentCourse;

    return _HubCard(
      title: '🎓 Học tập',
      trailing: '${data?.completedThisYear ?? 0} khóa xong năm nay',
      glow: ScrollCardGlow.shuiro,
      onTap: onTap,
      child: overview.hasError
          ? Text('Không tải được số liệu.', style: _muted(14))
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (course == null)
                  Text(data == null ? 'Đang tải...' : 'Chưa có khóa nào đang học.', style: _muted(14))
                else ...[
                  Text(
                    'Đang học: ${course.name}',
                    style: TextStyle(fontSize: 14, color: Colors.white.withValues(alpha: 0.8)),
                  ),
                  if (course.lastLessonTitle != null) ...[
                    const SizedBox(height: 4),
                    Text('Gần nhất: ${course.lastLessonTitle}', style: _muted(12)),
                  ],
                ],
                if (data?.nextPlannedCourseName != null) ...[
                  const SizedBox(height: 8),
                  Text('Sắp tới: ${data!.nextPlannedCourseName}', style: _muted(12)),
                ],
              ],
            ),
    );
  }
}

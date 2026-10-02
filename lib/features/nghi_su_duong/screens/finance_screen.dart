import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../shared/theme/app_theme.dart';
import '../../../shared/utils/currency.dart';
import '../../../shared/widgets/scroll_card.dart';
import '../../../shared/widgets/tag.dart';
import '../models/project.dart';
import '../providers/finance_provider.dart';
import '../providers/nghi_su_duong_provider.dart';
import '../services/finance_api.dart';
import '../utils/finance_month.dart';

TextStyle _muted(double size) => TextStyle(fontSize: size, color: Colors.white.withValues(alpha: 0.4));

/// "YYYY-MM-DD" → "d/M/yyyy" như toLocaleDateString("vi-VN").
String _viDate(String iso) {
  final p = iso.split('-');
  return '${int.parse(p[2])}/${int.parse(p[1])}/${p[0]}';
}

/// Port /finance: danh sách tháng tài chính, mới nhất trước.
class FinanceScreen extends ConsumerStatefulWidget {
  const FinanceScreen({super.key});

  @override
  ConsumerState<FinanceScreen> createState() => _FinanceScreenState();
}

class _FinanceScreenState extends ConsumerState<FinanceScreen> {
  bool _starting = false;

  void _openMonth(Project month) => context.push('/finance/${month.id}');

  Future<void> _startMonth() async {
    setState(() => _starting = true);
    try {
      final month = await ref.read(financeApiProvider).startNewMonth();
      ref.invalidate(financeProjectsProvider);
      ref.invalidate(financeOverviewProvider); // card Tài chính ở trang chính
      if (mounted) _openMonth(month);
    } on DioException {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text('Không bắt đầu được tháng mới, thử lại nhé.')));
      }
    } finally {
      if (mounted) setState(() => _starting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final months = ref.watch(financeProjectsProvider);
    // Chỉ hiện nút khi đã tải xong và tháng hiện tại (lịch VN) chưa có.
    final showStart = months.hasValue && !hasCurrentFinanceMonth(months.value!);

    return Scaffold(
      appBar: AppBar(title: const Text('Tài chính cá nhân')),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 640),
          child: RefreshIndicator(
            onRefresh: () => ref.refresh(financeProjectsProvider.future),
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                if (showStart) ...[
                  // Có thể mất vài giây (lần đầu backend tạo danh mục mặc định,
                  // chụp số dư mọi ví, lưu trữ tháng cũ) — khoá nút + spinner
                  // để không bấm 2 lần.
                  FilledButton.icon(
                    onPressed: _starting ? null : _startMonth,
                    icon: _starting
                        ? const SizedBox.square(dimension: 16, child: CircularProgressIndicator(strokeWidth: 2))
                        : const Icon(Icons.add),
                    label: Text(_starting ? 'Đang tạo tháng mới...' : 'Bắt đầu tháng mới'),
                  ),
                  const SizedBox(height: 16),
                ],
                ...months.when(
                  loading: () => [Text('Đang tải...', style: _muted(12))],
                  error: (_, _) => [Text('Không tải được danh sách tháng.', style: _muted(12))],
                  data: (items) => items.isEmpty
                      ? [
                          Text(
                            'Chưa có dự án tài chính nào — bấm "Bắt đầu tháng mới" để tạo dự án cho tháng hiện tại.',
                            style: _muted(12),
                          ),
                        ]
                      : [
                          for (final m in items) ...[
                            _MonthCard(month: m, onTap: () => _openMonth(m)),
                            const SizedBox(height: 12),
                          ],
                        ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _MonthCard extends ConsumerWidget {
  const _MonthCard({required this.month, required this.onTap});

  final Project month;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isOpen = month.archivedAt == null;
    final summary = ref.watch(financeSummaryProvider(month.id)).value;

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: ScrollCard(
        glow: isOpen ? ScrollCardGlow.kincha : ScrollCardGlow.yugen,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: 4,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(month.name, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
                ),
                if (isOpen)
                  Tag(label: 'Đang mở', color: AppColors.yugen500, foregroundColor: AppColors.yugen300, fontSize: 10),
              ],
            ),
            if (month.startDate != null && month.endDate != null)
              Text('${_viDate(month.startDate!)} → ${_viDate(month.endDate!)}', style: _muted(11)),
            // Không hiện "Tổng số dư": summary.totalBalance là số dư HIỆN TẠI,
            // sai với tháng cũ (lỗi backend đã biết).
            if (summary != null) ...[
              const SizedBox(height: 4),
              Row(
                spacing: 12,
                children: [
                  Text(
                    '+${formatVnd(summary.totalIncome)}',
                    style: const TextStyle(fontSize: 12, color: AppColors.emerald300),
                  ),
                  Text(
                    '−${formatVnd(summary.totalExpense)}',
                    style: const TextStyle(fontSize: 12, color: AppColors.shuiro500),
                  ),
                  const Spacer(),
                  Text(
                    'Chênh lệch ${formatVnd(summary.netThisMonth)}',
                    style: TextStyle(
                      fontSize: 12,
                      color: summary.netThisMonth >= 0 ? AppColors.emerald300 : AppColors.shuiro500,
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

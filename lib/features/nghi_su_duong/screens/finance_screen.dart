import 'package:dio/dio.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../shared/theme/design_tokens.dart';
import '../../../shared/utils/currency.dart';
import '../../../shared/widgets/app_toast.dart';
import '../../../shared/widgets/design_page.dart';
import '../../../shared/widgets/list_frame.dart';
import '../../../shared/widgets/overview_block.dart';
import '../models/project.dart';
import '../providers/finance_provider.dart';
import '../providers/nghi_su_duong_provider.dart';
import '../services/finance_api.dart';
import '../utils/finance_month.dart';

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
      if (mounted) showToast(context, 'Không bắt đầu được tháng mới, thử lại nhé.', type: ToastType.error);
    } finally {
      if (mounted) setState(() => _starting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final months = ref.watch(financeProjectsProvider);
    final overview = ref.watch(financeOverviewProvider);
    // Chỉ hiện nút khi đã tải xong và tháng hiện tại (lịch VN) chưa có.
    final showStart = months.hasValue && !hasCurrentFinanceMonth(months.value!);
    final o = overview.value;

    return DesignPage(
      title: 'Tài chính cá nhân',
      backFallback: '/nghi-su-duong',
      onRefresh: () => Future.wait([
        ref.refresh(financeProjectsProvider.future),
        ref.refresh(financeOverviewProvider.future).then<void>((_) {}, onError: (_) {}),
      ]),
      overview: OverviewBlock(
        title: 'Tổng quan',
        labelWidth: 90,
        rows: [
          OverviewRow(
            label: 'Số dư ví',
            child: o == null
                ? Text(overview.hasError ? 'Không tải được.' : 'Đang tải…', style: DesignText.muted)
                : Text(
                    formatVnd(o.currentBalance),
                    style: TextStyle(color: o.currentBalance < 0 ? DesignColors.danger : DesignColors.text),
                  ),
          ),
          OverviewRow(
            label: 'Năm nay',
            child: o == null
                ? Text(overview.hasError ? 'Không tải được.' : 'Đang tải…', style: DesignText.muted)
                : Text.rich(
                    TextSpan(
                      children: [
                        TextSpan(text: 'Thu ${formatVnd(o.totalIncome)}', style: const TextStyle(color: DesignColors.success)),
                        const TextSpan(text: ' · ', style: DesignText.muted),
                        TextSpan(text: 'Chi ${formatVnd(o.totalExpense)}', style: const TextStyle(color: DesignColors.danger)),
                      ],
                    ),
                  ),
          ),
        ],
      ),
      content: (context, _) => ListFrame(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          spacing: 8,
          children: [
            if (showStart)
              // Có thể mất vài giây (lần đầu backend tạo danh mục mặc định, chụp số dư mọi ví, lưu trữ tháng cũ) —
              // khoá nút + spinner để không bấm 2 lần.
              FilledButton.icon(
                onPressed: _starting ? null : _startMonth,
                style: FilledButton.styleFrom(
                  backgroundColor: DesignColors.gold,
                  foregroundColor: const Color(0xFF1A1A1A),
                  minimumSize: const Size(0, 44),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                  textStyle: DesignText.serif(fontSize: 14),
                ),
                icon: _starting
                    ? const SizedBox.square(dimension: 16, child: CircularProgressIndicator(strokeWidth: 2))
                    : const Icon(Icons.add),
                label: Text(_starting ? 'Đang tạo tháng mới...' : 'Bắt đầu tháng mới'),
              ),
            ...months.when(
              loading: () => [const Text('Đang tải...', style: DesignText.muted)],
              error: (_, _) => [const Text('Không tải được danh sách tháng.', style: DesignText.muted)],
              data: (items) => items.isEmpty
                  ? [
                      const Text(
                        'Chưa có dự án tài chính nào — bấm "Bắt đầu tháng mới" để tạo dự án cho tháng hiện tại.',
                        style: DesignText.muted,
                      ),
                    ]
                  : [for (final m in items) _MonthRow(month: m, onTap: () => _openMonth(m))],
            ),
          ],
        ),
      ),
      hint: 'Chạm vào một tháng để xem thu chi',
    );
  }
}

/// Một tháng tài chính: chữ 月 · tên + khoảng ngày · Thu / Chi / Chênh lệch · nhãn "Đang mở".
class _MonthRow extends ConsumerWidget {
  const _MonthRow({required this.month, required this.onTap});

  final Project month;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isOpen = month.archivedAt == null;
    final summary = ref.watch(financeSummaryProvider(month.id)).value;

    return FrameRow(
      key: ValueKey('month-${month.id}'),
      glyph: '月',
      title: month.name,
      borderColor: isOpen ? DesignColors.gold.withValues(alpha: 0.5) : null,
      trailing: isOpen ? const DesignPill('Đang mở', color: DesignColors.info) : null,
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (month.startDate != null && month.endDate != null)
            Text('${_viDate(month.startDate!)} → ${_viDate(month.endDate!)}', style: DesignText.muted),
          // Không hiện "Tổng số dư": summary.totalBalance là số dư HIỆN TẠI, sai với tháng cũ (lỗi backend đã biết).
          if (summary != null)
            Wrap(
              spacing: 10,
              runSpacing: 2,
              children: [
                Text('+${formatVnd(summary.totalIncome)}', style: const TextStyle(fontSize: 13, color: DesignColors.success)),
                Text('−${formatVnd(summary.totalExpense)}', style: const TextStyle(fontSize: 13, color: DesignColors.danger)),
                Text(
                  'Chênh lệch ${formatVnd(summary.netThisMonth)}',
                  style: TextStyle(
                    fontSize: 13,
                    color: summary.netThisMonth >= 0 ? DesignColors.success : DesignColors.danger,
                  ),
                ),
              ],
            ),
        ],
      ),
      onTap: onTap,
    );
  }
}

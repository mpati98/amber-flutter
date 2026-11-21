import 'package:dio/dio.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../shared/theme/design_tokens.dart';
import '../../../shared/utils/currency.dart';
import '../../../shared/utils/vn_time.dart';
import '../../../shared/widgets/app_toast.dart';
import '../../../shared/widgets/list_frame.dart';
import '../models/finance_summary.dart';
import '../models/finance_transaction.dart';
import '../models/finance_category.dart';
import '../models/project.dart';
import '../providers/finance_provider.dart';
import '../providers/nghi_su_duong_provider.dart';
import '../services/finance_api.dart';

// Phần hiển thị tài chính dùng chung giữa khung "Tài chính" của màn Nghị Sự Đường và màn chi tiết tháng.

/// Giờ VN: "12/9 09:29".
String _viDateTime(DateTime at) {
  final d = vnNow(at);
  return '${d.day}/${d.month} ${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';
}

/// "YYYY-MM-DD" → "d/M/yyyy" như toLocaleDateString("vi-VN").
String viDate(String iso) {
  final p = iso.split('-');
  return '${int.parse(p[2])}/${int.parse(p[1])}/${p[0]}';
}

/// Port BudgetProgressRow: kincha bình thường, shuiro khi vượt hạn mức.
class BudgetRow extends StatelessWidget {
  const BudgetRow(this.budget, {super.key});

  final BudgetProgress budget;

  @override
  Widget build(BuildContext context) {
    final over = budget.isOver;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: 4,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                '${budget.icon != null ? '${budget.icon} ' : ''}${budget.categoryName}',
                style: const TextStyle(fontSize: 12),
              ),
            ),
            Text(
              '${formatVnd(budget.spent)} / ${formatVnd(budget.limitAmount)}',
              style: over
                  ? const TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: DesignColors.danger)
                  : DesignText.muted,
            ),
          ],
        ),
        DesignProgressBar(budget.percent, color: over ? DesignColors.danger : DesignColors.gold),
      ],
    );
  }
}

class TransactionRow extends StatelessWidget {
  const TransactionRow(this.transaction, {super.key});

  final FinanceTransaction transaction;

  @override
  Widget build(BuildContext context) {
    final t = transaction;
    final isIncome = t.kind == MoneyKind.income;
    final subtitle = [
      if (t.note != null && t.note!.isNotEmpty) t.note!,
      if (t.accountName != null) t.accountName!,
      _viDateTime(t.occurredAt),
    ].join(' · ');

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8), // py-2
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: DesignColors.rowDivider)),
      ),
      child: Row(
        spacing: 8,
        children: [
          Text(t.categoryIcon ?? (isIncome ? '💰' : '💸'), style: const TextStyle(fontSize: 18)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  t.categoryName ?? 'Chưa phân loại',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 13),
                ),
                Text(subtitle, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 12, color: DesignColors.muted)),
              ],
            ),
          ),
          Text(
            '${isIncome ? '+' : '−'}${formatVnd(t.amount)}',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: isIncome ? DesignColors.success : DesignColors.danger,
            ),
          ),
        ],
      ),
    );
  }
}

/// Một tháng tài chính: chữ 月 · tên + khoảng ngày · Thu / Chi / Chênh lệch · nhãn "Đang mở".
/// [selected] = tháng đang xem trong modal Tài chính (viền vàng đậm). [trailing] thay nhãn "Đang mở" (vd nút "Chi tiết ›").
class FinanceMonthRow extends ConsumerWidget {
  const FinanceMonthRow({super.key, required this.month, required this.onTap, this.selected = false, this.trailing});

  final Project month;
  final VoidCallback onTap;
  final bool selected;
  final Widget? trailing;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isOpen = month.archivedAt == null;
    final summary = ref.watch(financeSummaryProvider(month.id)).value;

    return FrameRow(
      key: ValueKey('month-${month.id}'),
      glyph: '月',
      title: month.name,
      borderColor: selected ? DesignColors.gold : (isOpen ? DesignColors.gold.withValues(alpha: 0.5) : null),
      trailing: trailing ?? (isOpen ? const DesignPill('Đang mở', color: DesignColors.info) : null),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (month.startDate != null && month.endDate != null)
            Text('${viDate(month.startDate!)} → ${viDate(month.endDate!)}', style: DesignText.muted),
          // Không hiện "Tổng số dư": summary.totalBalance là số dư HIỆN TẠI, sai với tháng cũ (lỗi backend đã biết).
          if (summary != null) MonthTotals(summary),
        ],
      ),
      onTap: onTap,
    );
  }
}

/// "+thu  −chi  Chênh lệch …" của một tháng (xanh / đỏ).
class MonthTotals extends StatelessWidget {
  const MonthTotals(this.summary, {super.key});

  final FinanceSummary summary;

  @override
  Widget build(BuildContext context) {
    final net = summary.netThisMonth;
    return Wrap(
      spacing: 10,
      runSpacing: 2,
      children: [
        Text('+${formatVnd(summary.totalIncome)}', style: const TextStyle(fontSize: 13, color: DesignColors.success)),
        Text('−${formatVnd(summary.totalExpense)}', style: const TextStyle(fontSize: 13, color: DesignColors.danger)),
        Text(
          'Chênh lệch ${formatVnd(net)}',
          style: TextStyle(fontSize: 13, color: net >= 0 ? DesignColors.success : DesignColors.danger),
        ),
      ],
    );
  }
}

/// Nút "Bắt đầu tháng mới" (chuyển từ màn "Tài chính cá nhân" cũ): có thể mất vài giây (lần đầu backend tạo danh mục
/// mặc định, chụp số dư mọi ví, lưu trữ tháng cũ) — khoá nút + spinner để không bấm 2 lần; xong thì mở màn chi tiết tháng mới.
class StartMonthButton extends ConsumerStatefulWidget {
  const StartMonthButton({super.key});

  @override
  ConsumerState<StartMonthButton> createState() => _StartMonthButtonState();
}

class _StartMonthButtonState extends ConsumerState<StartMonthButton> {
  bool _starting = false;

  Future<void> _start() async {
    setState(() => _starting = true);
    try {
      final month = await ref.read(financeApiProvider).startNewMonth();
      ref.invalidate(financeProjectsProvider);
      ref.invalidate(financeOverviewProvider);
      if (mounted) await context.push('/finance/${month.id}');
    } on DioException {
      if (mounted) showToast(context, 'Không bắt đầu được tháng mới, thử lại nhé.', type: ToastType.error);
    } finally {
      if (mounted) setState(() => _starting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return FilledButton.icon(
      key: const ValueKey('start-month'),
      onPressed: _starting ? null : _start,
      style: FilledButton.styleFrom(
        backgroundColor: DesignColors.gold,
        foregroundColor: const Color(0xFF1A1A1A),
        minimumSize: const Size(0, 40),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
        textStyle: DesignText.serif(fontSize: 14),
      ),
      icon: _starting
          ? const SizedBox.square(dimension: 16, child: CircularProgressIndicator(strokeWidth: 2))
          : const Icon(Icons.add),
      label: Text(_starting ? 'Đang tạo tháng mới...' : 'Bắt đầu tháng mới'),
    );
  }
}

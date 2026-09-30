import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/theme/app_theme.dart';
import '../../../shared/utils/currency.dart';
import '../../../shared/utils/vn_time.dart';
import '../../../shared/widgets/progress_bar.dart';
import '../../../shared/widgets/scroll_card.dart';
import '../../../shared/widgets/tag.dart';
import '../models/finance_account.dart';
import '../models/finance_category.dart';
import '../models/finance_summary.dart';
import '../models/finance_transaction.dart';
import '../providers/finance_provider.dart';
import '../providers/nghi_su_duong_provider.dart';
import '../services/finance_api.dart';

TextStyle _muted(double size) => TextStyle(fontSize: size, color: Colors.white.withValues(alpha: 0.4));

/// Giờ VN: "12/9 09:29".
String _viDateTime(DateTime at) {
  final d = vnNow(at);
  return '${d.day}/${d.month} ${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';
}

/// Port /finance/[projectId]: số liệu tháng, ví, ngân sách, giao dịch.
class FinanceMonthScreen extends ConsumerStatefulWidget {
  const FinanceMonthScreen({super.key, required this.projectId});

  final String projectId;

  @override
  ConsumerState<FinanceMonthScreen> createState() => _FinanceMonthScreenState();
}

class _FinanceMonthScreenState extends ConsumerState<FinanceMonthScreen> {
  // Giao dịch vừa vuốt xoá: ẩn ngay khỏi danh sách trong lúc chờ tải lại —
  // Dismissible đã dismiss mà còn trong cây widget sẽ báo lỗi.
  final _deletedIds = <String>{};

  void _todo(String what) =>
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('TODO: $what')));

  void _refreshAfterWrite() {
    ref.invalidate(financeSummaryProvider(widget.projectId));
    ref.invalidate(financeTransactionsProvider(widget.projectId));
    ref.invalidate(financeAccountsProvider); // số dư ví đổi
    ref.invalidate(financeOverviewProvider); // card Tài chính ở trang chính
  }

  Future<bool> _confirmDelete(FinanceTransaction t) async {
    final sign = t.kind == MoneyKind.income ? '+' : '−';
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xoá giao dịch?'),
        content: Text(
          '$sign${formatVnd(t.amount)}${t.note != null ? ' · ${t.note}' : ''}\n'
          'Số dư ví${t.accountName != null ? ' "${t.accountName}"' : ''} sẽ được hoàn lại như trước giao dịch này.',
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(false), child: const Text('Huỷ')),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: AppColors.shuiro500),
            child: const Text('Xoá'),
          ),
        ],
      ),
    );
    if (confirmed != true) return false;
    try {
      await ref.read(financeApiProvider).deleteTransaction(t.id);
      return true;
    } on DioException {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Không xoá được giao dịch, thử lại nhé.')),
        );
      }
      return false; // dòng trượt về chỗ cũ
    }
  }

  @override
  Widget build(BuildContext context) {
    final summaryAsync = ref.watch(financeSummaryProvider(widget.projectId));
    final accounts = ref.watch(financeAccountsProvider);
    final transactions = ref.watch(financeTransactionsProvider(widget.projectId));
    final summary = summaryAsync.value;

    // Kết thúc khi đã lưu trữ HOẶC đã qua ngày cuối tháng theo lịch VN — backend
    // chỉ lưu trữ tháng cũ khi có người bấm "Bắt đầu tháng mới", nên tháng đã
    // qua vẫn có thể chưa archived.
    final ended = summary != null && (summary.archivedAt != null || summary.endDate.compareTo(vnToday()) < 0);
    final hasAccounts = accounts.value?.isNotEmpty ?? false;

    return Scaffold(
      appBar: AppBar(title: Text(summary?.projectName ?? 'Tháng tài chính')),
      floatingActionButton: summary == null || ended || !accounts.hasValue
          ? null
          : FloatingActionButton.extended(
              onPressed: () => _todo(hasAccounts ? 'AddTransactionModal' : 'AddAccountModal'),
              icon: const Icon(Icons.add),
              label: Text(hasAccounts ? 'Thêm giao dịch' : 'Thêm ví trước'),
            ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 640),
          child: summaryAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => Center(
              child: Text(
                e is DioException && e.response?.statusCode == 404
                    ? 'Không tìm thấy tháng tài chính này.'
                    : 'Không tải được số liệu tháng.',
                style: _muted(12),
              ),
            ),
            data: (s) => RefreshIndicator(
              onRefresh: () async => _refreshAfterWrite(),
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 96), // chừa chỗ cho FAB
                children: [
                  if (ended) ...[
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Tag(
                        label: 'Đã kết thúc',
                        color: Colors.white,
                        foregroundColor: Colors.white.withValues(alpha: 0.5),
                        borderAlpha: 0.15,
                        fontSize: 10,
                      ),
                    ),
                    const SizedBox(height: 12),
                  ],
                  _StatsGrid(summary: s, ended: ended),
                  const SizedBox(height: 24),
                  _Section(
                    title: 'Ví & tài khoản',
                    glow: ScrollCardGlow.yugen,
                    action: TextButton(onPressed: () => _todo('AddAccountModal'), child: const Text('+ Thêm ví')),
                    child: accounts.when(
                      loading: () => Text('Đang tải...', style: _muted(12)),
                      error: (_, _) => Text('Không tải được ví.', style: _muted(12)),
                      data: (items) => items.isEmpty
                          ? Text('Chưa có ví nào.', style: _muted(12))
                          : Wrap(spacing: 8, runSpacing: 8, children: [for (final a in items) _AccountChip(a)]),
                    ),
                  ),
                  const SizedBox(height: 24),
                  _Section(
                    title: 'Ngân sách',
                    glow: ScrollCardGlow.kincha,
                    action: ended
                        ? null
                        : TextButton(onPressed: () => _todo('SetBudgetModal'), child: const Text('+ Đặt ngân sách')),
                    child: s.budgetProgress.isEmpty
                        ? Text('Chưa đặt ngân sách cho danh mục nào.', style: _muted(12))
                        : Column(spacing: 12, children: [for (final b in s.budgetProgress) _BudgetRow(b)]),
                  ),
                  const SizedBox(height: 24),
                  _Section(
                    title: 'Giao dịch',
                    glow: ScrollCardGlow.shuiro,
                    action: TextButton(onPressed: () => _todo('AddCategoryModal'), child: const Text('+ Danh mục')),
                    child: transactions.when(
                      loading: () => Text('Đang tải...', style: _muted(12)),
                      error: (_, _) => Text('Không tải được giao dịch.', style: _muted(12)),
                      data: (items) {
                        final visible = items.where((t) => !_deletedIds.contains(t.id)).toList();
                        if (visible.isEmpty) return Text('Chưa có giao dịch nào.', style: _muted(12));
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Text('Vuốt sang trái để xoá', style: _muted(10)),
                            const SizedBox(height: 4),
                            for (final t in visible)
                              Dismissible(
                                key: ValueKey(t.id),
                                direction: DismissDirection.endToStart,
                                confirmDismiss: (_) => _confirmDelete(t),
                                onDismissed: (_) {
                                  setState(() => _deletedIds.add(t.id));
                                  _refreshAfterWrite();
                                },
                                background: Container(
                                  alignment: Alignment.centerRight,
                                  padding: const EdgeInsets.only(right: 16),
                                  color: AppColors.shuiro500.withValues(alpha: 0.25),
                                  child: const Icon(Icons.delete_outline, color: AppColors.shuiro500),
                                ),
                                child: _TransactionRow(t),
                              ),
                          ],
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _StatsGrid extends StatelessWidget {
  const _StatsGrid({required this.summary, required this.ended});

  final FinanceSummary summary;
  final bool ended;

  @override
  Widget build(BuildContext context) {
    final net = summary.netThisMonth;
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: 2,
      children: [
        _Stat(
          label: 'Tổng số dư (mọi ví)',
          value: formatVnd(summary.totalBalance),
          color: Colors.white,
          glow: ScrollCardGlow.kincha,
          // totalBalance là số dư HIỆN TẠI của mọi ví — đúng nghĩa với tháng
          // đang mở, nhưng với tháng đã qua thì không phải số dư cuối tháng đó.
          note: ended ? 'số dư hiện tại, không phải cuối tháng' : null,
        ),
        _Stat(
          label: 'Chênh lệch tháng',
          value: formatVnd(net),
          color: net >= 0 ? AppColors.emerald300 : AppColors.shuiro500,
          glow: ScrollCardGlow.kincha,
        ),
        _Stat(
          label: 'Thu tháng này',
          value: formatVnd(summary.totalIncome),
          color: AppColors.emerald300,
          glow: ScrollCardGlow.yugen,
        ),
        _Stat(
          label: 'Chi tháng này',
          value: formatVnd(summary.totalExpense),
          color: AppColors.shuiro500,
          glow: ScrollCardGlow.shuiro,
        ),
      ],
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat({required this.label, required this.value, required this.color, required this.glow, this.note});

  final String label;
  final String value;
  final Color color;
  final ScrollCardGlow glow;
  final String? note;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12), // p-3
      decoration: BoxDecoration(
        color: AppColors.ink900.withValues(alpha: 0.6),
        border: Border.all(color: glow.color),
        borderRadius: BorderRadius.circular(AppTheme.darkRadius),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(label, style: _muted(11), maxLines: 1, overflow: TextOverflow.ellipsis),
          const SizedBox(height: 4),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              value,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: color,
                  ),
            ),
          ),
          if (note != null) Text(note!, style: _muted(9), maxLines: 1, overflow: TextOverflow.ellipsis),
        ],
      ),
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({required this.title, required this.glow, this.action, required this.child});

  final String title;
  final ScrollCardGlow glow;
  final Widget? action;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return ScrollCard(
      glow: glow,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: AppColors.kincha400),
                ),
              ),
              ?action,
            ],
          ),
          const SizedBox(height: 8), // mb-2
          child,
        ],
      ),
    );
  }
}

class _AccountChip extends StatelessWidget {
  const _AccountChip(this.account);

  final FinanceAccount account;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minWidth: 120), // min-w-30
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
        borderRadius: BorderRadius.circular(2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(account.name, style: const TextStyle(fontSize: 12)),
          Text(account.type.label, style: _muted(10)),
          const SizedBox(height: 2),
          Text(
            formatVnd(account.currentBalance),
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: AppColors.kincha400),
          ),
        ],
      ),
    );
  }
}

/// Port BudgetProgressRow: kincha bình thường, shuiro khi vượt hạn mức.
class _BudgetRow extends StatelessWidget {
  const _BudgetRow(this.budget);

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
                  ? const TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: AppColors.shuiro500)
                  : _muted(12),
            ),
          ],
        ),
        ProgressBar(
          value: budget.percent.toDouble(),
          max: 100,
          fillColor: over ? AppColors.shuiro500 : AppColors.kincha400,
        ),
      ],
    );
  }
}

class _TransactionRow extends StatelessWidget {
  const _TransactionRow(this.transaction);

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
        border: Border(bottom: BorderSide(color: Colors.white.withValues(alpha: 0.1))),
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
                Text(subtitle, maxLines: 1, overflow: TextOverflow.ellipsis, style: _muted(11)),
              ],
            ),
          ),
          Text(
            '${isIncome ? '+' : '−'}${formatVnd(t.amount)}',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: isIncome ? AppColors.emerald300 : AppColors.shuiro500,
            ),
          ),
        ],
      ),
    );
  }
}

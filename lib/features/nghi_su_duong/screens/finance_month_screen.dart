import 'package:dio/dio.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/theme/design_tokens.dart';
import '../../../shared/utils/currency.dart';
import '../../../shared/utils/vn_time.dart';
import '../../../shared/widgets/app_toast.dart';
import '../../../shared/widgets/design_page.dart';
import '../../../shared/widgets/list_frame.dart';
import '../../../shared/widgets/overview_block.dart';
import '../../../shared/widgets/scroll_card.dart';
import '../models/finance_account.dart';
import '../models/finance_category.dart';
import '../models/finance_summary.dart';
import '../models/finance_transaction.dart';
import '../providers/finance_provider.dart';
import '../providers/nghi_su_duong_provider.dart';
import '../services/finance_api.dart';
import '../widgets/add_account_modal.dart';
import '../widgets/add_category_modal.dart';
import '../widgets/add_transaction_modal.dart';
import '../widgets/set_budget_modal.dart';

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

  void _addAccount() => showAddAccountModal(context, projectId: widget.projectId);

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
            style: TextButton.styleFrom(foregroundColor: DesignColors.danger),
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
      if (mounted) showToast(context, 'Không xoá được giao dịch, thử lại nhé.', type: ToastType.error);
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

    final canAdd = summary != null && !ended && accounts.hasValue;

    return DesignPage(
      title: summary?.projectName ?? 'Tháng tài chính',
      backFallback: '/finance',
      onRefresh: () async => _refreshAfterWrite(),
      overview: switch (summaryAsync) {
        AsyncData(:final value) => _overview(value, ended),
        AsyncError(:final error) => OverviewBlock(
          title: 'Tháng này',
          labelWidth: 90,
          rows: [
            OverviewRow.muted(
              label: 'Số liệu',
              text: error is DioException && error.response?.statusCode == 404
                  ? 'Không tìm thấy tháng tài chính này.'
                  : 'Không tải được số liệu tháng.',
            ),
          ],
        ),
        _ => OverviewBlock(title: 'Tháng này', labelWidth: 90, rows: [OverviewRow.muted(label: 'Số liệu', text: 'Đang tải…')]),
      },
      content: (context, _) => summary == null
          ? const SizedBox.shrink()
          : ListFrame(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                spacing: 12,
                children: [
                  if (canAdd)
                    Align(
                      alignment: Alignment.centerRight,
                      child: DesignButton.primary(
                        key: const ValueKey('month-add'),
                        label: hasAccounts ? '+ Thêm giao dịch' : '+ Thêm ví trước',
                        minHeight: 40,
                        onPressed: () =>
                            hasAccounts ? showAddTransactionModal(context, projectId: widget.projectId) : _addAccount(),
                      ),
                    ),
                  _Section(
                    title: 'Ví & tài khoản',
                    action: DesignButton.outline(label: '+ Thêm ví', onPressed: _addAccount),
                    child: accounts.when(
                      loading: () => const Text('Đang tải...', style: DesignText.muted),
                      error: (_, _) => const Text('Không tải được ví.', style: DesignText.muted),
                      data: (items) => items.isEmpty
                          ? const Text('Chưa có ví nào.', style: DesignText.muted)
                          : Wrap(spacing: 8, runSpacing: 8, children: [for (final a in items) _AccountChip(a)]),
                    ),
                  ),
                  _Section(
                    title: 'Ngân sách',
                    action: ended
                        ? null
                        : DesignButton.outline(
                            label: '+ Đặt ngân sách',
                            onPressed: () => showSetBudgetModal(
                              context,
                              projectId: widget.projectId,
                              projectName: summary.projectName,
                              currentLimits: {for (final b in summary.budgetProgress) b.categoryId: b.limitAmount},
                            ),
                          ),
                    child: summary.budgetProgress.isEmpty
                        ? const Text('Chưa đặt ngân sách cho danh mục nào.', style: DesignText.muted)
                        : Column(spacing: 12, children: [for (final b in summary.budgetProgress) _BudgetRow(b)]),
                  ),
                  _Section(
                    title: 'Giao dịch',
                    action: DesignButton.outline(label: '+ Danh mục', onPressed: () => showAddCategoryModal(context)),
                    child: transactions.when(
                      loading: () => const Text('Đang tải...', style: DesignText.muted),
                      error: (_, _) => const Text('Không tải được giao dịch.', style: DesignText.muted),
                      data: (items) {
                        final visible = items.where((t) => !_deletedIds.contains(t.id)).toList();
                        if (visible.isEmpty) return const Text('Chưa có giao dịch nào.', style: DesignText.muted);
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            const Text('Vuốt sang trái để xoá', style: TextStyle(fontSize: 11, color: DesignColors.muted)),
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
                                  color: DesignColors.danger.withValues(alpha: 0.2),
                                  child: const Icon(Icons.delete_outline, color: DesignColors.danger),
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
    );
  }

  /// Tổng quan tháng: số dư mọi ví (kèm lưu ý khi tháng đã qua), chênh lệch, thu, chi, nhãn "Đã kết thúc".
  Widget _overview(FinanceSummary s, bool ended) {
    final net = s.netThisMonth;
    TextStyle color(Color c) => TextStyle(color: c);
    return OverviewBlock(
      title: 'Tháng này',
      labelWidth: 90,
      rows: [
        OverviewRow(
          label: 'Số dư ví',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(formatVnd(s.totalBalance), style: color(s.totalBalance < 0 ? DesignColors.danger : DesignColors.text)),
              // totalBalance là số dư HIỆN TẠI của mọi ví — đúng với tháng đang mở, tháng đã qua thì không phải số dư cuối tháng.
              if (ended) const Text('số dư hiện tại, không phải cuối tháng', style: DesignText.muted),
            ],
          ),
        ),
        OverviewRow(
          label: 'Chênh lệch',
          child: Text(formatVnd(net), style: color(net >= 0 ? DesignColors.success : DesignColors.danger)),
        ),
        OverviewRow(label: 'Thu', child: Text(formatVnd(s.totalIncome), style: color(DesignColors.success))),
        OverviewRow(label: 'Chi', child: Text(formatVnd(s.totalExpense), style: color(DesignColors.danger))),
        if (ended)
          const OverviewRow(
            label: 'Trạng thái',
            child: Align(alignment: Alignment.centerLeft, child: DesignPill('Đã kết thúc', color: DesignColors.muted)),
          ),
      ],
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({required this.title, this.action, required this.child});

  final String title;
  final Widget? action;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return ScrollCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            spacing: 8,
            children: [
              Expanded(
                child: Text(
                  title.toUpperCase(),
                  style: const TextStyle(fontSize: 13, letterSpacing: 1, color: DesignColors.gold),
                ),
              ),
              ?action,
            ],
          ),
          const SizedBox(height: 10),
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
        color: DesignColors.frame,
        border: Border.all(color: DesignColors.panelBorder),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(account.name, style: const TextStyle(fontSize: 12)),
          Text(account.type.label, style: const TextStyle(fontSize: 11, color: DesignColors.muted)),
          const SizedBox(height: 2),
          Text(
            formatVnd(account.currentBalance),
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: DesignColors.gold),
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

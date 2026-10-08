import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/theme/app_theme.dart';
import '../../../shared/utils/api_error.dart';
import '../../../shared/utils/currency.dart';
import '../../../shared/utils/date_format.dart';
import '../../../shared/utils/vn_time.dart';
import '../../../shared/widgets/scroll_card.dart';
import '../models/finance_transaction.dart';
import '../models/finance_category.dart';
import '../providers/finance_provider.dart';
import '../services/finance_api.dart';
import '../utils/project_finance.dart';
import 'project_transaction_form.dart';

/// "dd/MM" của một thời điểm theo lịch VN.
String _vnDayMonth(DateTime at) => formatDayMonth(vnToday(at));

/// Dòng chính: ghi chú; trống thì tên danh mục; không có danh mục thì "Giao dịch".
String transactionTitle(FinanceTransaction t) {
  final note = t.note?.trim();
  if (note != null && note.isNotEmpty) return note;
  return t.categoryName ?? 'Giao dịch';
}

/// Dòng phụ: "dd/MM · Thu|Chi · {danh mục} · {ví}" (bỏ phần thiếu).
String transactionSubtitle(FinanceTransaction t) => [
      _vnDayMonth(t.occurredAt),
      t.kind == MoneyKind.income ? 'Thu' : 'Chi',
      ?t.categoryName,
      ?t.accountName,
    ].join(' · ');

/// Tab Thu-chi: dòng tổng, danh sách giao dịch gắn với dự án (mới trước), sửa / xoá từng dòng.
class ProjectFinanceTab extends ConsumerWidget {
  const ProjectFinanceTab({super.key, required this.projectId});

  final String projectId;

  Future<void> _delete(BuildContext context, WidgetRef ref, FinanceTransaction t) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xoá giao dịch?'),
        content: const Text('Xoá giao dịch này? Số dư ví sẽ được hoàn lại.'),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(false), child: const Text('Huỷ')),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: Theme.of(context).colorScheme.error),
            child: const Text('Xoá'),
          ),
        ],
      ),
    );
    if (confirmed != true || !context.mounted) return;
    try {
      await ref.read(financeApiProvider).deleteTransaction(t.id);
      refreshProjectFinance(ref.invalidate, projectId);
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(apiErrorMessage(e, 'Không xoá được giao dịch, thử lại nhé.'))),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final muted = TextStyle(fontSize: 12, color: cs.onSurface.withValues(alpha: 0.6));
    final async = ref.watch(projectTransactionsProvider(projectId));
    final txs = async.value;

    if (txs == null) {
      return Text(async.hasError ? 'Không tải được thu-chi.' : 'Đang tải...', style: muted);
    }
    final totals = FinanceTotals.of(txs);

    Widget total(String label, double value, {Color? color}) => Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: muted),
              Text(
                formatVnd(value),
                key: ValueKey('total-$label'),
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: color ?? cs.onSurface),
              ),
            ],
          ),
        );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: 12,
      children: [
        ScrollCard(
          glow: ScrollCardGlow.kincha,
          child: Row(
            spacing: 8,
            children: [
              total('Thu', totals.income, color: theme.success),
              total('Chi', totals.expense),
              total('Ròng', totals.net),
            ],
          ),
        ),
        if (txs.isEmpty)
          Text('Chưa có giao dịch nào gắn với dự án này.', style: muted)
        else
          for (final t in txs) _TransactionRow(key: ValueKey('tx-${t.id}'), tx: t, projectId: projectId, onDelete: () => _delete(context, ref, t)),
      ],
    );
  }
}

class _TransactionRow extends StatelessWidget {
  const _TransactionRow({super.key, required this.tx, required this.projectId, required this.onDelete});

  final FinanceTransaction tx;
  final String projectId;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final income = tx.kind == MoneyKind.income;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        spacing: 4,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(transactionTitle(tx), maxLines: 2, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 14, color: cs.onSurface)),
                Text(
                  transactionSubtitle(tx),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 12, color: cs.onSurface.withValues(alpha: 0.6)),
                ),
              ],
            ),
          ),
          Text(
            signedMoney(tx.kind, tx.amount),
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: income ? theme.success : cs.onSurface),
          ),
          IconButton(
            tooltip: 'Sửa giao dịch',
            visualDensity: VisualDensity.compact,
            onPressed: () => showProjectTransactionForm(context, projectId: projectId, tx: tx),
            icon: const Icon(Icons.edit_outlined),
          ),
          IconButton(
            tooltip: 'Xoá giao dịch',
            visualDensity: VisualDensity.compact,
            onPressed: onDelete,
            icon: const Icon(Icons.delete_outline),
          ),
        ],
      ),
    );
  }
}

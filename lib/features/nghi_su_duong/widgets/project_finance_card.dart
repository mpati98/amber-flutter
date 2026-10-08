import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/theme/app_theme.dart';
import '../../../shared/utils/currency.dart';
import '../../../shared/widgets/scroll_card.dart';
import '../providers/finance_provider.dart';
import '../utils/project_finance.dart';

/// Thẻ nhỏ "Thu-chi của dự án" ở đầu trang: Thu, Chi, Ròng, số giao dịch, nút chuyển sang tab Thu-chi.
class ProjectFinanceCard extends ConsumerWidget {
  const ProjectFinanceCard({super.key, required this.projectId, required this.onOpen});

  final String projectId;
  final VoidCallback onOpen;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final muted = TextStyle(fontSize: 12, color: cs.onSurface.withValues(alpha: 0.6));
    final async = ref.watch(projectTransactionsProvider(projectId));
    final txs = async.value;
    final totals = txs == null ? null : FinanceTotals.of(txs);

    Widget stat(String label, String value, {Color? color}) => Row(
          children: [
            Expanded(child: Text(label, style: muted)),
            Text(value, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: color ?? cs.onSurface)),
          ],
        );

    return ScrollCard(
      glow: ScrollCardGlow.yugen,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: 8,
        children: [
          Text('Thu-chi của dự án', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: cs.primary)),
          if (totals == null)
            Text(async.hasError ? 'Không tải được thu-chi.' : 'Đang tải...', style: muted)
          else ...[
            stat('Thu', formatVnd(totals.income), color: theme.success),
            stat('Chi', formatVnd(totals.expense)),
            stat('Ròng', formatVnd(totals.net)),
            Text('${txs!.length} giao dịch gắn với dự án', style: muted),
          ],
          Align(
            alignment: Alignment.centerLeft,
            child: TextButton(onPressed: onOpen, child: const Text('Xem và sửa')),
          ),
        ],
      ),
    );
  }
}

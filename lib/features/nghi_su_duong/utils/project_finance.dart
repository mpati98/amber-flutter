import '../../../shared/utils/currency.dart';
import '../models/finance_transaction.dart';
import '../models/finance_category.dart';

/// Tổng thu / chi / ròng của một danh sách giao dịch (số tiền trong danh sách luôn dương).
class FinanceTotals {
  const FinanceTotals({required this.income, required this.expense});

  factory FinanceTotals.of(Iterable<FinanceTransaction> transactions) {
    var income = 0.0, expense = 0.0;
    for (final t in transactions) {
      switch (t.kind) {
        case MoneyKind.income:
          income += t.amount;
        case MoneyKind.expense:
          expense += t.amount;
        case MoneyKind.unknown:
          break;
      }
    }
    return FinanceTotals(income: income, expense: expense);
  }

  final double income;
  final double expense;
  double get net => income - expense;
}

/// "+100.000₫" cho Thu, "−100.000₫" (dấu trừ U+2212) cho Chi.
String signedMoney(MoneyKind kind, double amount) =>
    '${kind == MoneyKind.income ? '+' : '−'}${formatVnd(amount)}';

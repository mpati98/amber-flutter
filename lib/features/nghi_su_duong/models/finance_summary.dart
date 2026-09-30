import 'money.dart';

class BudgetProgress {
  const BudgetProgress({
    required this.categoryId,
    required this.categoryName,
    this.icon,
    required this.limitAmount,
    required this.spent,
  });

  factory BudgetProgress.fromJson(Map<String, dynamic> json) => BudgetProgress(
        categoryId: json['categoryId'] as String,
        categoryName: json['categoryName'] as String,
        icon: json['icon'] as String?,
        limitAmount: parseMoney(json['limitAmount']),
        spent: parseMoney(json['spent']),
      );

  final String categoryId;
  final String categoryName;
  final String? icon;
  final double limitAmount;

  /// Tổng chi EXPENSE của danh mục trong tháng.
  final double spent;

  bool get isOver => spent > limitAmount;

  /// Giống BudgetProgressRow bên web: min(100, round(spent / limit × 100)).
  int get percent => limitAmount > 0 ? (spent / limitAmount * 100).round().clamp(0, 100) : 0;
}

/// GET /finance/summary?projectId= — số liệu 1 tháng.
class FinanceSummary {
  const FinanceSummary({
    required this.projectId,
    required this.projectName,
    required this.startDate,
    required this.endDate,
    this.archivedAt,
    required this.totalBalance,
    required this.totalIncome,
    required this.totalExpense,
    required this.netThisMonth,
    required this.budgetProgress,
  });

  factory FinanceSummary.fromJson(Map<String, dynamic> json) {
    final project = json['project'] as Map<String, dynamic>;
    return FinanceSummary(
      projectId: project['id'] as String,
      projectName: project['name'] as String,
      startDate: project['startDate'] as String,
      endDate: project['endDate'] as String,
      archivedAt: project['archivedAt'] == null ? null : DateTime.parse(project['archivedAt'] as String),
      totalBalance: parseMoney(json['totalBalance']),
      totalIncome: parseMoney(json['totalIncome']),
      totalExpense: parseMoney(json['totalExpense']),
      netThisMonth: parseMoney(json['netThisMonth']),
      budgetProgress: [
        for (final b in json['budgetProgress'] as List<dynamic>) BudgetProgress.fromJson(b as Map<String, dynamic>),
      ],
    );
  }

  final String projectId;
  final String projectName;
  final String startDate;
  final String endDate;
  final DateTime? archivedAt;

  /// ⚠️ Số dư HIỆN TẠI của mọi ví, không phải số dư của tháng này — kể cả khi
  /// xem tháng cũ (lỗi đã biết ở backend). Đừng hiện như "số dư tháng".
  final double totalBalance;
  final double totalIncome;
  final double totalExpense;
  final double netThisMonth;
  final List<BudgetProgress> budgetProgress;
}

import 'money.dart';

/// Hạn mức chi của 1 danh mục trong 1 tháng. GET /finance/budgets kèm
/// `category`; POST (upsert) chỉ trả dòng ngân sách — tên/icon khi đó null.
class FinanceBudget {
  const FinanceBudget({
    required this.id,
    required this.projectId,
    required this.categoryId,
    required this.limitAmount,
    this.categoryName,
    this.categoryIcon,
  });

  factory FinanceBudget.fromJson(Map<String, dynamic> json) {
    final category = json['category'] as Map<String, dynamic>?;
    return FinanceBudget(
      id: json['id'] as String,
      projectId: json['projectId'] as String,
      categoryId: json['categoryId'] as String,
      limitAmount: parseMoney(json['limitAmount']),
      categoryName: category?['name'] as String?,
      categoryIcon: category?['icon'] as String?,
    );
  }

  final String id;
  final String projectId;
  final String categoryId;
  final double limitAmount;
  final String? categoryName;
  final String? categoryIcon;
}

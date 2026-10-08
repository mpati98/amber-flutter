import 'finance_category.dart';
import 'money.dart';

/// Giao dịch thuộc 1 tháng tài chính. GET kèm `category`/`account` (để hiện
/// tên); POST chỉ trả dòng giao dịch — khi đó các field tên là null.
class FinanceTransaction {
  const FinanceTransaction({
    required this.id,
    required this.projectId,
    this.linkedProjectId,
    required this.accountId,
    this.categoryId,
    required this.kind,
    required this.amount,
    this.note,
    required this.occurredAt,
    this.categoryName,
    this.categoryIcon,
    this.accountName,
  });

  factory FinanceTransaction.fromJson(Map<String, dynamic> json) {
    final category = json['category'] as Map<String, dynamic>?;
    final account = json['account'] as Map<String, dynamic>?;
    return FinanceTransaction(
      id: json['id'] as String,
      projectId: json['projectId'] as String,
      linkedProjectId: json['linkedProjectId'] as String?,
      accountId: json['accountId'] as String,
      categoryId: json['categoryId'] as String?,
      kind: MoneyKind.fromApi(json['kind'] as String),
      amount: parseMoney(json['amount']),
      note: json['note'] as String?,
      occurredAt: DateTime.parse(json['occurredAt'] as String),
      categoryName: category?['name'] as String?,
      categoryIcon: category?['icon'] as String?,
      accountName: account?['name'] as String?,
    );
  }

  final String id;
  /// Tháng tài chính (project FINANCE) mà giao dịch thuộc về.
  final String projectId;

  /// Dự án STANDARD mà giao dịch được gắn vào (null = không gắn).
  final String? linkedProjectId;
  final String accountId;
  final String? categoryId;
  final MoneyKind kind;

  /// Luôn dương — thu hay chi do [kind] quyết định.
  final double amount;
  final String? note;
  final DateTime occurredAt;
  final String? categoryName;
  final String? categoryIcon;
  final String? accountName;
}

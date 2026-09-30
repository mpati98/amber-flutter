import 'money.dart';

enum AccountType {
  cash('CASH', 'Tiền mặt'),
  bank('BANK', 'Ngân hàng'),
  eWallet('E_WALLET', 'Ví điện tử'),
  creditCard('CREDIT_CARD', 'Thẻ tín dụng'),
  unknown('', 'Khác');

  const AccountType(this.apiValue, this.label);

  final String apiValue;

  /// Nhãn giống AddAccountModal bên web.
  final String label;

  static AccountType fromApi(String value) => values.firstWhere((t) => t.apiValue == value, orElse: () => unknown);
}

/// Ví/tài khoản — dùng chung cho mọi tháng. Số dư đổi theo từng giao dịch.
class FinanceAccount {
  const FinanceAccount({
    required this.id,
    required this.name,
    required this.type,
    required this.currentBalance,
    this.archivedAt,
  });

  factory FinanceAccount.fromJson(Map<String, dynamic> json) => FinanceAccount(
        id: json['id'] as String,
        name: json['name'] as String,
        type: AccountType.fromApi(json['type'] as String),
        currentBalance: parseMoney(json['currentBalance']),
        archivedAt: json['archivedAt'] == null ? null : DateTime.parse(json['archivedAt'] as String),
      );

  final String id;
  final String name;
  final AccountType type;
  final double currentBalance;

  /// GET /finance/accounts chỉ trả ví chưa lưu trữ.
  final DateTime? archivedAt;
}

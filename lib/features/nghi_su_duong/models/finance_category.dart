enum MoneyKind {
  income('INCOME'),
  expense('EXPENSE'),
  unknown('');

  const MoneyKind(this.apiValue);

  final String apiValue;

  static MoneyKind fromApi(String value) => values.firstWhere((k) => k.apiValue == value, orElse: () => unknown);
}

/// Danh mục thu/chi — dùng chung cho mọi tháng. Tháng đầu tiên backend tự tạo
/// sẵn 7 danh mục mặc định.
class FinanceCategory {
  const FinanceCategory({required this.id, required this.name, this.icon, required this.kind});

  factory FinanceCategory.fromJson(Map<String, dynamic> json) => FinanceCategory(
        id: json['id'] as String,
        name: json['name'] as String,
        icon: json['icon'] as String?,
        kind: MoneyKind.fromApi(json['kind'] as String),
      );

  final String id;
  final String name;

  /// Emoji, vd "🍜".
  final String? icon;
  final MoneyKind kind;
}

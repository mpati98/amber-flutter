/// Cảnh báo tự sinh từ GET /api/kieu-lau/notifications — tính lúc gọi, không lưu DB.
class Alert {
  const Alert({required this.id, required this.kind, required this.title, this.detail, required this.href});

  factory Alert.fromJson(Map<String, dynamic> json) => Alert(
        id: json['id'] as String,
        kind: json['kind'] as String,
        title: json['title'] as String,
        detail: json['detail'] as String?,
        href: json['href'] as String,
      );

  /// `task:<id>`, `budget:<id>`, `learn:<id>`, `finance:missing-month`.
  final String id;

  /// TASK_DUE | BUDGET_EXCEEDED | FINANCE_MONTH_MISSING | LEARN_INACTIVE
  final String kind;
  final String title;
  final String? detail;

  /// Đường dẫn bên web (vd `/du-an`, `/finance/<id>`) — trùng route của app
  /// (app_router.dart), điều hướng thẳng được.
  final String href;
}

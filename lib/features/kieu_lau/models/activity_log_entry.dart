/// 1 dòng bảng activity_logs (response còn có `userId`, `metadata` — chưa dùng).
class ActivityLogEntry {
  const ActivityLogEntry({
    required this.id,
    required this.source,
    required this.action,
    required this.title,
    required this.createdAt,
  });

  factory ActivityLogEntry.fromJson(Map<String, dynamic> json) => ActivityLogEntry(
        id: json['id'] as String,
        source: json['source'] as String,
        action: json['action'] as String,
        title: json['title'] as String,
        createdAt: DateTime.parse(json['createdAt'] as String),
      );

  final String id;

  /// DU_AN | FINANCE | LEARN | TRA_DINH | KIEU_LAU
  final String source;

  /// vd `task.created`, `feed_source.deleted`.
  final String action;
  final String title;
  final DateTime createdAt;
}

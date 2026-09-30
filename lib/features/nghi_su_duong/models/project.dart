// Enum Dart + `unknown` như Tàng Kinh Các. Khác pgEnum ở đó: cột `type` là
// varchar tự do ("mở rộng tự do" theo comment schema), nên càng cần fallback.
enum ProjectType {
  standard('STANDARD'),
  finance('FINANCE'),
  learn('LEARN'),

  /// Buổi luyện của Trà Đình — cũng nằm trong bảng projects.
  practice('PRACTICE'),
  unknown('');

  const ProjectType(this.apiValue);

  final String apiValue;

  static ProjectType fromApi(String value) => values.firstWhere((t) => t.apiValue == value, orElse: () => unknown);
}

/// 1 dòng bảng projects. Không có field rrule/occurrences (phần sót lại của
/// Lịch/Gantt đã bỏ, API không còn dùng).
class Project {
  const Project({
    required this.id,
    required this.name,
    required this.type,
    this.color,
    this.startDate,
    this.endDate,
    this.archivedAt,
  });

  factory Project.fromJson(Map<String, dynamic> json) => Project(
        id: json['id'] as String,
        name: json['name'] as String,
        type: ProjectType.fromApi(json['type'] as String),
        color: json['color'] as String?,
        startDate: json['startDate'] as String?,
        endDate: json['endDate'] as String?,
        archivedAt: json['archivedAt'] == null ? null : DateTime.parse(json['archivedAt'] as String),
      );

  final String id;
  final String name;
  final ProjectType type;
  final String? color;

  /// Cột `date` — "YYYY-MM-DD" (ngày lịch, không múi giờ), giữ dạng chuỗi để
  /// so sánh trực tiếp với vnToday(). Finance: ngày đầu/cuối tháng.
  final String? startDate;
  final String? endDate;

  /// Có giá trị = đã xong/lưu trữ (dùng chung cho mọi loại project).
  /// Timestamp có múi giờ, API trả ISO kèm `Z`.
  final DateTime? archivedAt;
}

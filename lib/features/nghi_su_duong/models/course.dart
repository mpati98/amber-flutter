import 'lesson.dart';

enum CourseStatus {
  planned('PLANNED', 'Dự định'),
  inProgress('IN_PROGRESS', 'Đang học'),
  completed('COMPLETED', 'Đã xong'),
  unknown('', 'Không rõ');

  const CourseStatus(this.apiValue, this.label);

  final String apiValue;

  /// Nhãn giống danh sách khóa học bên web.
  final String label;

  static CourseStatus fromApi(String? value) =>
      values.firstWhere((s) => s.apiValue == value, orElse: () => value == null ? planned : unknown);
}

/// Khóa học = 1 project type LEARN + learn_course_details. GET /learn/courses
/// kèm luôn toàn bộ bài học (`learnLessons`) — đủ cho khung xem nhanh, không
/// cần gọi thêm. POST/PATCH không kèm bài học → [lessons] rỗng.
class Course {
  const Course({
    required this.id,
    required this.name,
    this.source,
    this.field,
    this.outcome,
    this.startDate,
    this.endDate,
    required this.status,
    this.archivedAt,
    this.lessons = const [],
  });

  factory Course.fromJson(Map<String, dynamic> json) {
    final details = json['learnDetails'] as Map<String, dynamic>?;
    return Course(
      id: json['id'] as String,
      name: json['name'] as String,
      source: details?['source'] as String?,
      field: details?['field'] as String?,
      outcome: details?['outcome'] as String?,
      startDate: json['startDate'] as String?,
      endDate: json['endDate'] as String?,
      // Không có details (dữ liệu lỗi) → coi như Dự định, giống web.
      status: CourseStatus.fromApi(details?['status'] as String?),
      archivedAt: json['archivedAt'] == null ? null : DateTime.parse(json['archivedAt'] as String),
      lessons: sortLessonsRecentFirst([
        for (final l in json['learnLessons'] as List<dynamic>? ?? const []) Lesson.fromJson(l as Map<String, dynamic>),
      ]),
    );
  }

  /// = projectId.
  final String id;
  final String name;

  /// Nơi học, vd "Udemy", "Coursera".
  final String? source;

  /// Lĩnh vực.
  final String? field;

  /// "Kết quả đạt được" — chứng chỉ, điểm số, tổng kết.
  final String? outcome;
  final String? startDate;
  final String? endDate;
  final CourseStatus status;

  /// Có giá trị khi status = COMPLETED (backend lưu trữ project khi hoàn thành).
  final DateTime? archivedAt;

  /// Mới học trước (xem sortLessonsRecentFirst).
  final List<Lesson> lessons;

  int get lessonCount => lessons.length;
  Lesson? get lastLesson => lessons.firstOrNull;
  String? get lastLessonTitle => lastLesson?.title;
  String? get lastLessonDate => lastLesson?.studiedAt;
  int get totalMinutes => lessons.fold(0, (sum, l) => sum + (l.durationMinutes ?? 0));

  /// "Udemy · Lập trình web", hoặc null nếu không có cả hai.
  String? get sourceAndField {
    final parts = [source, field].whereType<String>().where((s) => s.isNotEmpty);
    return parts.isEmpty ? null : parts.join(' · ');
  }
}

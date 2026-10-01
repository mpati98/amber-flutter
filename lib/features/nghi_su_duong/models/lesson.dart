/// 1 buổi/bài đã học trong 1 khóa học.
class Lesson {
  const Lesson({
    required this.id,
    required this.courseId,
    required this.title,
    this.studiedAt,
    this.durationMinutes,
    this.note,
  });

  factory Lesson.fromJson(Map<String, dynamic> json) => Lesson(
        id: json['id'] as String,
        courseId: json['projectId'] as String,
        title: json['title'] as String,
        studiedAt: json['studiedAt'] as String?,
        durationMinutes: json['durationMinutes'] as int?,
        note: json['note'] as String?,
      );

  final String id;

  /// = projectId của khóa học (API trả field `projectId`).
  final String courseId;
  final String title;

  /// Cột `date` — "YYYY-MM-DD", có thể trống.
  final String? studiedAt;
  final int? durationMinutes;
  final String? note;
}

/// Mới học trước; bài chưa có ngày xếp cuối. (API GET lessons dùng
/// `ORDER BY studiedAt DESC` — Postgres để NULL lên ĐẦU, nên "bài gần nhất"
/// bên web có thể là 1 bài chưa ghi ngày.)
List<Lesson> sortLessonsRecentFirst(Iterable<Lesson> lessons) => lessons.toList()
  ..sort((a, b) {
    if (a.studiedAt == b.studiedAt) return 0;
    if (a.studiedAt == null) return 1;
    if (b.studiedAt == null) return -1;
    return b.studiedAt!.compareTo(a.studiedAt!);
  });

class StudyLogSection {
  const StudyLogSection({required this.sectionId, required this.title, required this.markedDone});

  factory StudyLogSection.fromJson(Map<String, dynamic> json) => StudyLogSection(
    sectionId: json['sectionId'] as String,
    title: json['title'] as String,
    markedDone: json['markedDone'] as bool? ?? false,
  );

  final String sectionId;
  final String title;
  final bool markedDone;
}

/// Một buổi học (GET /logs). Chưa có màn dùng — sheet ghi buổi học ở bước 6.
class StudyLog {
  const StudyLog({
    required this.id,
    required this.subjectId,
    this.courseId,
    this.courseTitle,
    required this.logDate,
    required this.minutes,
    this.note,
    required this.createdAt,
    this.sections = const [],
  });

  factory StudyLog.fromJson(Map<String, dynamic> json) => StudyLog(
    id: json['id'] as String,
    subjectId: json['subjectId'] as String,
    courseId: json['courseId'] as String?,
    courseTitle: json['courseTitle'] as String?,
    logDate: json['logDate'] as String,
    minutes: json['minutes'] as int,
    note: json['note'] as String?,
    createdAt: DateTime.parse(json['createdAt'] as String),
    sections: [for (final s in (json['sections'] as List? ?? const [])) StudyLogSection.fromJson(s as Map<String, dynamic>)],
  );

  final String id;
  final String subjectId;
  final String? courseId;
  final String? courseTitle;
  final String logDate;
  final int minutes;
  final String? note;
  final DateTime createdAt;
  final List<StudyLogSection> sections;
}

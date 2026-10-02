/// Giá trị `practice_session_details.mode` (zod enum của POST /tra-dinh/sessions).
enum PracticeMode {
  conversation('CONVERSATION', 'Trò chuyện tự do'),
  examPrep('EXAM_PREP', 'Luyện thi'),
  professional('PROFESSIONAL', 'Chuyên nghiệp'),
  unknown('', 'Không rõ');

  const PracticeMode(this.apiValue, this.label);

  final String apiValue;

  /// Nhãn giống MODE_LABEL bên web (tên mặc định do server đặt dùng
  /// "Tiếng Anh chuyên nghiệp" cho PROFESSIONAL — đó là tên buổi, không phải nhãn).
  final String label;

  static const selectable = [conversation, examPrep, professional];

  static PracticeMode fromApi(String? value) => values.firstWhere((m) => m.apiValue == value, orElse: () => unknown);
}

/// Buổi luyện = 1 project type PRACTICE + practice_session_details. GET list và
/// POST đều trả `{...project, practiceDetails: {projectId, mode, summary}}`.
class PracticeSession {
  const PracticeSession({
    required this.id,
    required this.name,
    required this.mode,
    this.summary,
    this.archivedAt,
    required this.createdAt,
  });

  factory PracticeSession.fromJson(Map<String, dynamic> json) {
    final details = json['practiceDetails'] as Map<String, dynamic>?;
    return PracticeSession(
      id: json['id'] as String,
      name: json['name'] as String,
      mode: PracticeMode.fromApi(details?['mode'] as String?),
      summary: details?['summary'] as String?,
      archivedAt: json['archivedAt'] == null ? null : DateTime.parse(json['archivedAt'] as String),
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  /// = projectId.
  final String id;
  final String name;
  final PracticeMode mode;

  /// AI tóm tắt khi kết thúc buổi (null nếu chưa kết thúc hoặc AI lỗi).
  final String? summary;

  /// Có giá trị = buổi đã kết thúc.
  final DateTime? archivedAt;
  final DateTime createdAt;

  bool get isEnded => archivedAt != null;
}

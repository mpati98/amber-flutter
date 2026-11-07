/// Trạng thái khóa học (study_course_status). Giá trị lạ → [unknown], không làm hỏng cả danh sách.
enum CourseStatus {
  wishlist('WISHLIST', 'Muốn mua'),
  queued('QUEUED', 'Chờ học'),
  active('ACTIVE', 'Đang học'),
  done('DONE', 'Đã xong'),
  unknown('', 'Không rõ');

  const CourseStatus(this.api, this.label);

  final String api;
  final String label;

  static CourseStatus fromApi(Object? value) => values.firstWhere((s) => s.api == value && s != unknown, orElse: () => unknown);
}

/// Lý do chưa đủ mục tiêu trong ngày (study_reason_code).
enum ReasonCode {
  busy('BUSY', 'Bận'),
  tired('TIRED', 'Mệt'),
  away('AWAY', 'Đi xa'),
  other('OTHER', 'Khác'),
  unknown('', 'Không rõ');

  const ReasonCode(this.api, this.label);

  final String api;
  final String label;

  static ReasonCode fromApi(Object? value) => values.firstWhere((r) => r.api == value && r != unknown, orElse: () => unknown);
}

/// Loại buổi học (study_log_activity). Thiếu trường (app / server cũ) → [lesson]; giá trị có mặt nhưng lạ
/// (ví dụ PRACTICE từ backend mới hơn bản app này) → [unknown], để danh sách bỏ qua thay vì hiểu nhầm là học bài.
enum LogActivity {
  lesson('LESSON'),
  cardReview('CARD_REVIEW'),
  unknown('');

  const LogActivity(this.api);

  final String api;

  static LogActivity fromApi(Object? value) => value == null ? lesson : values.firstWhere((a) => a.api == value && a != unknown, orElse: () => unknown);
}

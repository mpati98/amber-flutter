import 'course.dart';
import 'study_enums.dart';
import 'study_overview.dart';

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

/// Một buổi học (GET /logs, và `log` trong response POST / PATCH).
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

/// `today` trong response POST / PATCH / DELETE log: tổng hôm nay của môn.
class TodaySummary {
  const TodaySummary({required this.minutes, this.goalMinutes, required this.done, this.reason});

  factory TodaySummary.fromJson(Map<String, dynamic> json) => TodaySummary(
    minutes: json['minutes'] as int,
    goalMinutes: json['goalMinutes'] as int?,
    done: json['done'] as bool,
    reason: json['reason'] == null ? null : DayReason.fromJson(json['reason'] as Map<String, dynamic>),
  );

  final int minutes;
  final int? goalMinutes;
  final bool done;
  final DayReason? reason;
}

/// Response của POST / PATCH /logs: buổi vừa ghi, tổng hôm nay và khóa (cập nhật tiến độ / trạng thái; null nếu không gắn khóa).
class StudyLogResult {
  const StudyLogResult({required this.log, required this.today, this.course});

  factory StudyLogResult.fromJson(Map<String, dynamic> json) => StudyLogResult(
    log: StudyLog.fromJson(json['log'] as Map<String, dynamic>),
    today: TodaySummary.fromJson(json['today'] as Map<String, dynamic>),
    course: json['course'] == null ? null : CourseView.fromJson(json['course'] as Map<String, dynamic>),
  );

  final StudyLog log;
  final TodaySummary today;
  final CourseView? course;
}

/// Lý do một ngày (response PUT reasons: `{date, code, text}`).
class DayReasonEntry {
  const DayReasonEntry({required this.date, required this.code, this.text});

  factory DayReasonEntry.fromJson(Map<String, dynamic> json) =>
      DayReasonEntry(date: json['date'] as String, code: ReasonCode.fromApi(json['code']), text: json['text'] as String?);

  final String date;
  final ReasonCode code;
  final String? text;
}

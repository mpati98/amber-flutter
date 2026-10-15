import 'study_enums.dart';
import 'study_overview.dart';

/// Loại ngày trong lịch: đã qua / hôm nay / dự kiến. Giá trị lạ → [planned] (không có số liệu thật).
enum ScheduleKind {
  past('past'),
  today('today'),
  planned('planned');

  const ScheduleKind(this.api);

  final String api;

  static ScheduleKind fromApi(Object? value) => values.firstWhere((k) => k.api == value, orElse: () => planned);
}

class ScheduleLogSection {
  const ScheduleLogSection({required this.title, required this.markedDone});

  factory ScheduleLogSection.fromJson(Map<String, dynamic> json) =>
      ScheduleLogSection(title: json['title'] as String, markedDone: json['markedDone'] as bool? ?? false);

  final String title;
  final bool markedDone;
}

/// Một buổi học trong ngày của lịch (rút gọn so với StudyLog).
class ScheduleLog {
  const ScheduleLog({required this.id, this.courseTitle, required this.minutes, this.sections = const []});

  factory ScheduleLog.fromJson(Map<String, dynamic> json) => ScheduleLog(
    id: json['id'] as String,
    courseTitle: json['courseTitle'] as String?,
    minutes: json['minutes'] as int,
    sections: [for (final s in (json['sections'] as List? ?? const [])) ScheduleLogSection.fromJson(s as Map<String, dynamic>)],
  );

  final String id;

  /// null = buổi ôn tập, không gắn khóa.
  final String? courseTitle;
  final int minutes;
  final List<ScheduleLogSection> sections;
}

class PlannedItem {
  const PlannedItem({required this.courseId, required this.courseTitle, required this.sectionId, required this.title, required this.minutes});

  factory PlannedItem.fromJson(Map<String, dynamic> json) => PlannedItem(
    courseId: json['courseId'] as String,
    courseTitle: json['courseTitle'] as String? ?? '',
    sectionId: json['sectionId'] as String,
    title: json['title'] as String,
    minutes: json['minutes'] as int,
  );

  final String courseId;
  final String courseTitle;
  final String sectionId;
  final String title;
  final int minutes;
}

class Milestone {
  const Milestone({required this.courseId, required this.courseTitle});

  factory Milestone.fromJson(Map<String, dynamic> json) => Milestone(courseId: json['courseId'] as String, courseTitle: json['courseTitle'] as String);

  final String courseId;
  final String courseTitle;
}

/// Một ngày của lịch. past / today có số liệu thật ([minutes], [done]...); planned chỉ có [plannedItems].
class ScheduleDay {
  const ScheduleDay({
    required this.date,
    required this.kind,
    required this.isReviewDay,
    this.goalMinutes,
    this.minutes,
    this.done,
    this.extraMinutes,
    this.reason,
    this.logs = const [],
    this.plannedItems,
    this.milestones = const [],
  });

  factory ScheduleDay.fromJson(Map<String, dynamic> json) => ScheduleDay(
    date: json['date'] as String,
    kind: ScheduleKind.fromApi(json['kind']),
    isReviewDay: json['isReviewDay'] as bool? ?? false,
    goalMinutes: json['goalMinutes'] as int?,
    minutes: json['minutes'] as int?,
    done: json['done'] as bool?,
    extraMinutes: json['extraMinutes'] as int?,
    reason: json['reason'] == null ? null : DayReason.fromJson(json['reason'] as Map<String, dynamic>),
    logs: [for (final l in (json['logs'] as List? ?? const [])) ScheduleLog.fromJson(l as Map<String, dynamic>)],
    plannedItems: json['plannedItems'] == null ? null : [for (final p in json['plannedItems'] as List) PlannedItem.fromJson(p as Map<String, dynamic>)],
    milestones: [for (final m in (json['milestones'] as List? ?? const [])) Milestone.fromJson(m as Map<String, dynamic>)],
  );

  final String date;
  final ScheduleKind kind;
  final bool isReviewDay;

  /// null = môn không đặt mục tiêu.
  final int? goalMinutes;

  /// Chỉ past / today.
  final int? minutes;
  final bool? done;
  final int? extraMinutes;
  final DayReason? reason;
  final List<ScheduleLog> logs;

  /// planned: luôn có (rỗng ở ngày ôn); today: chỉ khi hôm nay chưa có buổi nào; past: null.
  final List<PlannedItem>? plannedItems;
  final List<Milestone> milestones;

  bool get isPast => kind == ScheduleKind.past;
  bool get isToday => kind == ScheduleKind.today;
  bool get isPlanned => kind == ScheduleKind.planned;
  bool get hasActual => kind != ScheduleKind.planned;

  int get actualMinutes => minutes ?? 0;

  /// Tổng phút dự kiến của ngày.
  int get plannedMinutes => (plannedItems ?? const []).fold(0, (n, p) => n + p.minutes);

  /// Ngày đã qua, môn có mục tiêu, chưa đủ và chưa có lý do → app còn nợ lý do.
  bool get missingReason => isPast && goalMinutes != null && done != true && reason == null;
}

/// Một khóa trong so sánh với kế hoạch gốc.
class BaselineEntry {
  const BaselineEntry({
    required this.courseId,
    required this.courseTitle,
    required this.status,
    this.baselineFinishDate,
    this.forecastFinishDate,
    this.deltaDays,
  });

  factory BaselineEntry.fromJson(Map<String, dynamic> json) => BaselineEntry(
    courseId: json['courseId'] as String,
    courseTitle: json['courseTitle'] as String,
    status: CourseStatus.fromApi(json['status']),
    baselineFinishDate: json['baselineFinishDate'] as String?,
    forecastFinishDate: json['forecastFinishDate'] as String?,
    deltaDays: json['deltaDays'] as int?,
  );

  final String courseId;
  final String courseTitle;
  final CourseStatus status;
  final String? baselineFinishDate;
  final String? forecastFinishDate;
  final int? deltaDays;
}

class ScheduleSummary {
  const ScheduleSummary({required this.minutes, required this.plannedMinutes, this.vsBaseline = const []});

  factory ScheduleSummary.fromJson(Map<String, dynamic> json) => ScheduleSummary(
    minutes: json['minutes'] as int? ?? 0,
    plannedMinutes: json['plannedMinutes'] as int? ?? 0,
    vsBaseline: [for (final b in (json['vsBaseline'] as List? ?? const [])) BaselineEntry.fromJson(b as Map<String, dynamic>)],
  );

  /// Đã học trong khoảng.
  final int minutes;

  /// Dự kiến từ hôm nay tới hết khoảng.
  final int plannedMinutes;
  final List<BaselineEntry> vsBaseline;

  /// deltaDays của khóa ACTIVE (banner so với kế hoạch gốc); null nếu không có khóa ACTIVE hoặc thiếu mốc.
  int? get activeDelta => vsBaseline.where((b) => b.status == CourseStatus.active).firstOrNull?.deltaDays;
}

/// GET /api/tra-dinh/hoc-tap/schedule.
class StudySchedule {
  const StudySchedule({required this.days, required this.summary});

  factory StudySchedule.fromJson(Map<String, dynamic> json) => StudySchedule(
    days: [for (final d in json['days'] as List) ScheduleDay.fromJson(d as Map<String, dynamic>)],
    summary: ScheduleSummary.fromJson(json['summary'] as Map<String, dynamic>),
  );

  final List<ScheduleDay> days;
  final ScheduleSummary summary;
}

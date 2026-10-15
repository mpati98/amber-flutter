import 'study_enums.dart';

/// Một điểm của biểu đồ: [start] là ngày (bucket day) hoặc thứ Hai của tuần (bucket week).
class StatsPoint {
  const StatsPoint({required this.start, required this.minutes, required this.goalMinutes});

  factory StatsPoint.fromJson(Map<String, dynamic> json) =>
      StatsPoint(start: json['start'] as String, minutes: json['minutes'] as int, goalMinutes: json['goalMinutes'] as int? ?? 0);

  final String start;
  final int minutes;

  /// Mục tiêu của cả bucket (tổng mục tiêu ngày × số ngày); 0 = không có mục tiêu.
  final int goalMinutes;

  bool get reachedGoal => goalMinutes > 0 && minutes >= goalMinutes;
}

class StatsCourse {
  const StatsCourse({this.courseId, required this.title, required this.minutes, required this.logCount});

  factory StatsCourse.fromJson(Map<String, dynamic> json) => StatsCourse(
    courseId: json['courseId'] as String?,
    title: json['title'] as String,
    minutes: json['minutes'] as int,
    logCount: json['logCount'] as int,
  );

  /// null = buổi ôn tập, không gắn khóa (server đặt title "Ôn tập").
  final String? courseId;
  final String title;
  final int minutes;
  final int logCount;
}

class PlanEntry {
  const PlanEntry({
    required this.courseId,
    required this.title,
    required this.status,
    required this.progressPct,
    this.baselineFinishDate,
    this.forecastFinishDate,
    this.finishedDate,
    this.deltaDays,
  });

  factory PlanEntry.fromJson(Map<String, dynamic> json) => PlanEntry(
    courseId: json['courseId'] as String,
    title: json['title'] as String,
    status: CourseStatus.fromApi(json['status']),
    progressPct: json['progressPct'] as int? ?? 0,
    baselineFinishDate: json['baselineFinishDate'] as String?,
    forecastFinishDate: json['forecastFinishDate'] as String?,
    finishedDate: json['finishedDate'] as String?,
    deltaDays: json['deltaDays'] as int?,
  );

  final String courseId;
  final String title;
  final CourseStatus status;
  final int progressPct;
  final String? baselineFinishDate;
  final String? forecastFinishDate;
  final String? finishedDate;

  /// DONE: ngày xong − gốc; ACTIVE/QUEUED: dự kiến − gốc. Âm = sớm. null nếu thiếu mốc.
  final int? deltaDays;
}

class SubjectDelta {
  const SubjectDelta({required this.subjectId, this.deltaDays});

  factory SubjectDelta.fromJson(Map<String, dynamic> json) => SubjectDelta(subjectId: json['subjectId'] as String, deltaDays: json['deltaDays'] as int?);

  final String subjectId;
  final int? deltaDays;
}

class DayRecord {
  const DayRecord({required this.date, required this.minutes});

  factory DayRecord.fromJson(Map<String, dynamic> json) => DayRecord(date: json['date'] as String, minutes: json['minutes'] as int);

  final String date;
  final int minutes;
}

class WeekdayTotal {
  const WeekdayTotal({required this.weekday, required this.minutes});

  factory WeekdayTotal.fromJson(Map<String, dynamic> json) => WeekdayTotal(weekday: json['weekday'] as int, minutes: json['minutes'] as int);

  /// 1 = thứ Hai … 7 = Chủ nhật.
  final int weekday;
  final int minutes;
}

class ReasonCounts {
  const ReasonCounts({this.busy = 0, this.tired = 0, this.away = 0, this.other = 0});

  factory ReasonCounts.fromJson(Map<String, dynamic> json) =>
      ReasonCounts(busy: json['BUSY'] as int? ?? 0, tired: json['TIRED'] as int? ?? 0, away: json['AWAY'] as int? ?? 0, other: json['OTHER'] as int? ?? 0);

  final int busy;
  final int tired;
  final int away;
  final int other;

  int get total => busy + tired + away + other;

  int of(ReasonCode code) => switch (code) {
    ReasonCode.busy => busy,
    ReasonCode.tired => tired,
    ReasonCode.away => away,
    ReasonCode.other => other,
    ReasonCode.unknown => 0,
  };
}

/// GET /api/tra-dinh/hoc-tap/stats.
class StudyStats {
  const StudyStats({
    required this.from,
    required this.to,
    required this.totalMinutes,
    required this.logCount,
    required this.avgPerDay,
    required this.goalDaysMet,
    required this.goalDaysTotal,
    required this.bucket,
    required this.series,
    required this.byCourse,
    required this.vsPlan,
    required this.overallDeltaDays,
    this.longestDay,
    this.topWeekday,
    this.reasonCounts = const ReasonCounts(),
  });

  factory StudyStats.fromJson(Map<String, dynamic> json) {
    final goal = json['goalDays'] as Map<String, dynamic>? ?? const {};
    return StudyStats(
      from: json['from'] as String,
      to: json['to'] as String,
      totalMinutes: json['totalMinutes'] as int,
      logCount: json['logCount'] as int,
      avgPerDay: json['avgPerDay'] as int,
      goalDaysMet: goal['met'] as int? ?? 0,
      goalDaysTotal: goal['total'] as int? ?? 0,
      bucket: json['bucket'] as String? ?? 'day',
      series: [for (final p in (json['series'] as List? ?? const [])) StatsPoint.fromJson(p as Map<String, dynamic>)],
      byCourse: [for (final c in (json['byCourse'] as List? ?? const [])) StatsCourse.fromJson(c as Map<String, dynamic>)],
      vsPlan: [for (final c in (json['vsPlan'] as List? ?? const [])) PlanEntry.fromJson(c as Map<String, dynamic>)],
      overallDeltaDays: [for (final c in (json['overallDeltaDays'] as List? ?? const [])) SubjectDelta.fromJson(c as Map<String, dynamic>)],
      longestDay: json['longestDay'] == null ? null : DayRecord.fromJson(json['longestDay'] as Map<String, dynamic>),
      topWeekday: json['topWeekday'] == null ? null : WeekdayTotal.fromJson(json['topWeekday'] as Map<String, dynamic>),
      reasonCounts: json['reasonCounts'] == null ? const ReasonCounts() : ReasonCounts.fromJson(json['reasonCounts'] as Map<String, dynamic>),
    );
  }

  final String from;
  final String to;
  final int totalMinutes;
  final int logCount;
  final int avgPerDay;
  final int goalDaysMet;
  final int goalDaysTotal;

  /// "day" | "week".
  final String bucket;
  final List<StatsPoint> series;
  final List<StatsCourse> byCourse;
  final List<PlanEntry> vsPlan;
  final List<SubjectDelta> overallDeltaDays;
  final DayRecord? longestDay;
  final WeekdayTotal? topWeekday;
  final ReasonCounts reasonCounts;

  bool get isWeekly => bucket == 'week';
  bool get hasLogs => logCount > 0;
}

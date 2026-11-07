import 'course.dart';
import 'study_enums.dart';

/// Trường số của backend mới hơn: sai kiểu / thiếu → null, không ném (bản cũ vẫn chạy).
int? _intOrNull(Object? v) => v is num ? v.toInt() : null;

class WeekDay {
  const WeekDay({required this.date, required this.minutes, required this.goalMinutes, required this.done});

  factory WeekDay.fromJson(Map<String, dynamic> json) => WeekDay(
    date: json['date'] as String,
    minutes: json['minutes'] as int,
    goalMinutes: json['goalMinutes'] as int,
    done: json['done'] as bool,
  );

  final String date;
  final int minutes;
  final int goalMinutes;
  final bool done;
}

class WeekSubject {
  const WeekSubject({
    required this.subjectId,
    required this.name,
    required this.goalMinutes,
    required this.minutes,
    required this.remainingMinutes,
    required this.suggestedPerDay,
  });

  factory WeekSubject.fromJson(Map<String, dynamic> json) => WeekSubject(
    subjectId: json['subjectId'] as String,
    name: json['name'] as String,
    goalMinutes: json['goalMinutes'] as int,
    minutes: json['minutes'] as int,
    remainingMinutes: json['remainingMinutes'] as int? ?? 0,
    suggestedPerDay: json['suggestedPerDay'] as int? ?? 0,
  );

  final String subjectId;
  final String name;

  /// Mục tiêu CẢ TUẦN của môn (mục tiêu ngày × 7).
  final int goalMinutes;
  final int minutes;
  final int remainingMinutes;
  final int suggestedPerDay;
}

class WeekSummary {
  const WeekSummary({
    required this.start,
    required this.end,
    required this.goalMinutes,
    required this.minutes,
    required this.remainingMinutes,
    required this.remainingDays,
    required this.suggestedPerDay,
    required this.days,
    required this.bySubject,
  });

  factory WeekSummary.fromJson(Map<String, dynamic> json) => WeekSummary(
    start: json['start'] as String,
    end: json['end'] as String,
    goalMinutes: json['goalMinutes'] as int,
    minutes: json['minutes'] as int,
    remainingMinutes: json['remainingMinutes'] as int,
    remainingDays: json['remainingDays'] as int,
    suggestedPerDay: json['suggestedPerDay'] as int,
    days: [for (final d in json['days'] as List) WeekDay.fromJson(d as Map<String, dynamic>)],
    bySubject: [for (final s in (json['bySubject'] as List? ?? const [])) WeekSubject.fromJson(s as Map<String, dynamic>)],
  );

  final String start;
  final String end;
  final int goalMinutes;
  final int minutes;
  final int remainingMinutes;
  final int remainingDays;
  final int suggestedPerDay;
  final List<WeekDay> days;
  final List<WeekSubject> bySubject;
}

class DayReason {
  const DayReason({required this.code, this.text});

  factory DayReason.fromJson(Map<String, dynamic> json) => DayReason(code: ReasonCode.fromApi(json['code']), text: json['text'] as String?);

  final ReasonCode code;
  final String? text;

  /// "Bận" / "Khác: đi khám".
  String get label => text == null || text!.trim().isEmpty ? code.label : '${code.label}: $text';
}

/// Phút hôm nay theo loại buổi (`today.minutesByActivity`). Backend cũ không có → toàn 0 ([hasData] = false).
class MinutesByActivity {
  const MinutesByActivity({this.lesson = 0, this.cardReview = 0, this.practice = 0, this.hasData = false});

  factory MinutesByActivity.fromJson(Object? json) {
    if (json is! Map<String, dynamic>) return const MinutesByActivity();
    int n(String k) => _intOrNull(json[k]) ?? 0;
    return MinutesByActivity(lesson: n('LESSON'), cardReview: n('CARD_REVIEW'), practice: n('PRACTICE'), hasData: true);
  }

  final int lesson;
  final int cardReview;
  final int practice;

  /// false = server không trả (bản cũ), nên "0 phút" chưa chắc là thật.
  final bool hasData;
}

class TodayInfo {
  const TodayInfo({required this.minutes, required this.logCount, required this.done, this.reason, this.byActivity = const MinutesByActivity()});

  factory TodayInfo.fromJson(Map<String, dynamic> json) => TodayInfo(
    minutes: json['minutes'] as int,
    logCount: json['logCount'] as int,
    done: json['done'] as bool,
    reason: json['reason'] == null ? null : DayReason.fromJson(json['reason'] as Map<String, dynamic>),
    byActivity: MinutesByActivity.fromJson(json['minutesByActivity']),
  );

  final int minutes;
  final int logCount;
  final bool done;
  final DayReason? reason;
  final MinutesByActivity byActivity;
}

class NextItem {
  const NextItem({required this.courseId, required this.courseTitle, required this.sectionId, required this.sectionTitle, this.minutes});

  factory NextItem.fromJson(Map<String, dynamic> json) => NextItem(
    courseId: json['courseId'] as String,
    courseTitle: json['courseTitle'] as String,
    sectionId: json['sectionId'] as String,
    sectionTitle: json['sectionTitle'] as String,
    minutes: _intOrNull(json['minutes']),
  );

  final String courseId;
  final String courseTitle;
  final String sectionId;
  final String sectionTitle;

  /// Số phút của phần kế tiếp; null = server không trả (bản cũ).
  final int? minutes;
}

class CourseCounts {
  const CourseCounts({this.queued = 0, this.done = 0, this.wishlist = 0});

  factory CourseCounts.fromJson(Map<String, dynamic> json) =>
      CourseCounts(queued: json['QUEUED'] as int? ?? 0, done: json['DONE'] as int? ?? 0, wishlist: json['WISHLIST'] as int? ?? 0);

  final int queued;
  final int done;
  final int wishlist;
}

/// Khối thẻ từ vựng của một môn trong Tổng quan (`cards`): số thẻ trong kế hoạch hôm nay, đã ôn xong, hạn mức, ngày ôn tập kế tiếp.
class CardsToday {
  const CardsToday({this.planned = 0, this.finished = 0, this.total, this.quota = 20, this.nextReviewDay});

  factory CardsToday.fromJson(Map<String, dynamic> json) => CardsToday(
    planned: (json['planned'] as num?)?.toInt() ?? 0,
    finished: (json['finished'] as num?)?.toInt() ?? 0,
    total: _intOrNull(json['total']),
    quota: (json['quota'] as num?)?.toInt() ?? 20,
    nextReviewDay: json['nextReviewDay'] as String?,
  );

  final int planned;
  final int finished;

  /// Tổng thẻ không tạm dừng của môn; null = server không trả (bản cũ), coi như chưa biết.
  final int? total;
  final int quota;

  /// "YYYY-MM-DD" của ngày ôn tập kế tiếp (sau hôm nay); null nếu server không trả.
  final String? nextReviewDay;
}

class SubjectOverview {
  const SubjectOverview({
    required this.subjectId,
    required this.name,
    this.goalMinutes,
    required this.today,
    this.next,
    this.activeCourse,
    this.counts = const CourseCounts(),
    this.vsBaseline,
    this.cards,
    this.streak,
    this.pendingReasonDates = const [],
  });

  factory SubjectOverview.fromJson(Map<String, dynamic> json) => SubjectOverview(
    subjectId: json['subjectId'] as String,
    name: json['name'] as String,
    goalMinutes: json['goalMinutes'] as int?,
    today: TodayInfo.fromJson(json['today'] as Map<String, dynamic>),
    next: json['next'] == null ? null : NextItem.fromJson(json['next'] as Map<String, dynamic>),
    activeCourse: json['activeCourse'] == null ? null : CourseView.fromJson(json['activeCourse'] as Map<String, dynamic>),
    counts: json['counts'] == null ? const CourseCounts() : CourseCounts.fromJson(json['counts'] as Map<String, dynamic>),
    vsBaseline: json['vsBaseline'] as int?,
    cards: json['cards'] is Map<String, dynamic> ? CardsToday.fromJson(json['cards'] as Map<String, dynamic>) : null,
    streak: _intOrNull(json['streak']),
    pendingReasonDates: [for (final d in (json['pendingReasonDates'] as List? ?? const [])) if (d is String) d],
  );

  final String subjectId;
  final String name;
  final int? goalMinutes;
  final TodayInfo today;
  final NextItem? next;
  final CourseView? activeCourse;
  final CourseCounts counts;

  /// Lệch ngày so với kế hoạch của khóa cuối hàng học (âm = sớm).
  final int? vsBaseline;

  /// Khối thẻ từ vựng; null = backend cũ chưa có (không hiện gì).
  final CardsToday? cards;

  /// Chuỗi ngày đủ mục tiêu của môn; null = backend cũ chưa có (ẩn).
  final int? streak;

  /// Ngày còn thiếu lý do (cũ trước hoặc mới trước tuỳ server); rỗng = không có hoặc backend cũ.
  final List<String> pendingReasonDates;
}

/// GET /api/tra-dinh/hoc-tap/overview.
class StudyOverview {
  const StudyOverview({required this.today, required this.week, required this.subjects});

  factory StudyOverview.fromJson(Map<String, dynamic> json) => StudyOverview(
    today: json['today'] as String,
    week: WeekSummary.fromJson(json['week'] as Map<String, dynamic>),
    subjects: [for (final s in (json['subjects'] as List? ?? const [])) SubjectOverview.fromJson(s as Map<String, dynamic>)],
  );

  final String today;
  final WeekSummary week;
  final List<SubjectOverview> subjects;
}

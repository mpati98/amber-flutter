import 'study_enums.dart';

class CourseProgress {
  const CourseProgress({required this.doneSections, required this.totalSections, required this.doneMinutes, required this.totalMinutes});

  factory CourseProgress.fromJson(Map<String, dynamic> json) => CourseProgress(
    doneSections: json['doneSections'] as int? ?? 0,
    totalSections: json['totalSections'] as int? ?? 0,
    doneMinutes: json['doneMinutes'] as int? ?? 0,
    totalMinutes: json['totalMinutes'] as int? ?? 0,
  );

  static const empty = CourseProgress(doneSections: 0, totalSections: 0, doneMinutes: 0, totalMinutes: 0);

  final int doneSections;
  final int totalSections;
  final int doneMinutes;
  final int totalMinutes;

  int get remainingMinutes => totalMinutes - doneMinutes;

  /// 0–100, theo phút (không có phút thì theo số phần).
  int get percent {
    if (totalMinutes > 0) return (doneMinutes * 100 / totalMinutes).round();
    return totalSections > 0 ? (doneSections * 100 / totalSections).round() : 0;
  }
}

class NextSection {
  const NextSection({required this.id, required this.title});

  factory NextSection.fromJson(Map<String, dynamic> json) => NextSection(id: json['id'] as String, title: json['title'] as String);

  final String id;
  final String title;
}

/// courseView của backend (danh sách / tổng quan / chi tiết). Ngày dạng "YYYY-MM-DD" giữ nguyên chuỗi.
class CourseView {
  const CourseView({
    required this.id,
    required this.subjectId,
    required this.title,
    this.instructor,
    this.platform,
    this.url,
    required this.status,
    this.queuePosition,
    this.targetPrice,
    this.note,
    this.startedAt,
    this.finishedAt,
    this.baselineFinishDate,
    this.forecastFinishDate,
    this.deltaDays,
    this.progress = CourseProgress.empty,
    this.nextSection,
  });

  factory CourseView.fromJson(Map<String, dynamic> json) => CourseView(
    id: json['id'] as String,
    subjectId: json['subjectId'] as String,
    title: json['title'] as String,
    instructor: json['instructor'] as String?,
    platform: json['platform'] as String?,
    url: json['url'] as String?,
    status: CourseStatus.fromApi(json['status']),
    queuePosition: json['queuePosition'] as int?,
    targetPrice: json['targetPrice'] as String?,
    note: json['note'] as String?,
    startedAt: _dt(json['startedAt']),
    finishedAt: _dt(json['finishedAt']),
    baselineFinishDate: json['baselineFinishDate'] as String?,
    forecastFinishDate: json['forecastFinishDate'] as String?,
    deltaDays: json['deltaDays'] as int?,
    progress: json['progress'] == null ? CourseProgress.empty : CourseProgress.fromJson(json['progress'] as Map<String, dynamic>),
    nextSection: json['nextSection'] == null ? null : NextSection.fromJson(json['nextSection'] as Map<String, dynamic>),
  );

  final String id;
  final String subjectId;
  final String title;
  final String? instructor;
  final String? platform;
  final String? url;
  final CourseStatus status;
  final int? queuePosition;
  final String? targetPrice;
  final String? note;
  final DateTime? startedAt;
  final DateTime? finishedAt;
  final String? baselineFinishDate;
  final String? forecastFinishDate;

  /// forecast − baseline theo ngày; âm = sớm hơn kế hoạch. null nếu thiếu một vế.
  final int? deltaDays;
  final CourseProgress progress;
  final NextSection? nextSection;

  /// "Giảng viên · Nền tảng" (bỏ vế trống).
  String get byline => [?instructor, ?platform].where((s) => s.trim().isNotEmpty).join(' · ');

  CourseView copyWith({CourseProgress? progress, NextSection? nextSection, bool clearNext = false}) => CourseView(
    id: id,
    subjectId: subjectId,
    title: title,
    instructor: instructor,
    platform: platform,
    url: url,
    status: status,
    queuePosition: queuePosition,
    targetPrice: targetPrice,
    note: note,
    startedAt: startedAt,
    finishedAt: finishedAt,
    baselineFinishDate: baselineFinishDate,
    forecastFinishDate: forecastFinishDate,
    deltaDays: deltaDays,
    progress: progress ?? this.progress,
    nextSection: clearNext ? null : (nextSection ?? this.nextSection),
  );
}

DateTime? _dt(Object? v) => v == null ? null : DateTime.tryParse(v as String);

class CourseSection {
  const CourseSection({required this.id, required this.position, required this.title, required this.durationMinutes, required this.done});

  factory CourseSection.fromJson(Map<String, dynamic> json) => CourseSection(
    id: json['id'] as String,
    position: json['position'] as int,
    title: json['title'] as String,
    durationMinutes: json['durationMinutes'] as int,
    done: json['done'] as bool? ?? json['doneAt'] != null,
  );

  final String id;
  final int position;
  final String title;
  final int durationMinutes;
  final bool done;

  CourseSection withDone(bool value) => CourseSection(id: id, position: position, title: title, durationMinutes: durationMinutes, done: value);
}

/// Dòng trong `recentLogs` của chi tiết khóa (rút gọn: không có phần).
class RecentLog {
  const RecentLog({required this.id, required this.logDate, required this.minutes, this.note});

  factory RecentLog.fromJson(Map<String, dynamic> json) => RecentLog(
    id: json['id'] as String,
    logDate: json['logDate'] as String,
    minutes: json['minutes'] as int,
    note: json['note'] as String?,
  );

  final String id;
  final String logDate;
  final int minutes;
  final String? note;
}

/// GET /courses/:id, và phản hồi của POST /courses, PUT/PATCH sections (cùng dạng, thiếu `recentLogs`).
class CourseDetail {
  const CourseDetail({required this.course, required this.sections, this.recentLogs = const []});

  factory CourseDetail.fromJson(Map<String, dynamic> json) => CourseDetail(
    course: CourseView.fromJson(json),
    sections: [for (final s in (json['sections'] as List? ?? const [])) CourseSection.fromJson(s as Map<String, dynamic>)],
    recentLogs: [for (final l in (json['recentLogs'] as List? ?? const [])) RecentLog.fromJson(l as Map<String, dynamic>)],
  );

  final CourseView course;
  final List<CourseSection> sections;
  final List<RecentLog> recentLogs;

  CourseDetail copyWith({CourseView? course, List<CourseSection>? sections, List<RecentLog>? recentLogs}) =>
      CourseDetail(course: course ?? this.course, sections: sections ?? this.sections, recentLogs: recentLogs ?? this.recentLogs);

  /// Bản ước lượng khi tick / bỏ tick một phần (trước khi server trả lời): đổi cờ, tính lại tiến độ và phần kế tiếp.
  CourseDetail withSectionDone(String sectionId, bool done) {
    final next = [for (final s in sections) s.id == sectionId ? s.withDone(done) : s];
    final finished = next.where((s) => s.done);
    final first = next.where((s) => !s.done).firstOrNull;
    return CourseDetail(
      course: course.copyWith(
        progress: CourseProgress(
          doneSections: finished.length,
          totalSections: next.length,
          doneMinutes: finished.fold(0, (n, s) => n + s.durationMinutes),
          totalMinutes: next.fold(0, (n, s) => n + s.durationMinutes),
        ),
        nextSection: first == null ? null : NextSection(id: first.id, title: first.title),
        clearNext: first == null,
      ),
      sections: next,
      recentLogs: recentLogs,
    );
  }
}

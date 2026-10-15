import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:amber_flutter/features/tra_dinh/hoc_tap/models/course.dart';
import 'package:amber_flutter/features/tra_dinh/hoc_tap/models/parsed_sections.dart';
import 'package:amber_flutter/features/tra_dinh/hoc_tap/models/study_enums.dart';
import 'package:amber_flutter/features/tra_dinh/hoc_tap/models/study_log.dart';
import 'package:amber_flutter/features/tra_dinh/hoc_tap/models/study_overview.dart';
import 'package:amber_flutter/features/tra_dinh/hoc_tap/models/study_schedule.dart';
import 'package:amber_flutter/features/tra_dinh/hoc_tap/models/study_stats.dart';
import 'package:amber_flutter/features/tra_dinh/hoc_tap/models/study_subject.dart';
import 'package:amber_flutter/features/tra_dinh/hoc_tap/services/hoc_tap_api.dart';
import 'package:dio/dio.dart';

/// JSON thật lấy từ backend dev (test/fixtures/hoc_tap).
Object fixture(String name) => jsonDecode(File('test/fixtures/hoc_tap/$name.json').readAsStringSync()) as Object;

Map<String, dynamic> fixtureMap(String name) => fixture(name) as Map<String, dynamic>;
List<dynamic> fixtureList(String name) => fixture(name) as List<dynamic>;

DioException apiError(int status, Object data) {
  final req = RequestOptions(path: '/api/tra-dinh/hoc-tap/x');
  return DioException(requestOptions: req, type: DioExceptionType.badResponse, response: Response(requestOptions: req, statusCode: status, data: data));
}

/// API giả: dữ liệu lấy từ fixture, ghi lại các lệnh ghi, có thể chặn / báo lỗi.
class FakeHocTapApi extends HocTapApi {
  FakeHocTapApi({StudyOverview? overview, List<StudySubject>? subjects, List<CourseView>? courses, CourseDetail? detail})
    : overview = overview ?? StudyOverview.fromJson(fixtureMap('overview')),
      subjects = subjects ?? [for (final s in fixtureList('subjects')) StudySubject.fromJson(s as Map<String, dynamic>)],
      courses = courses ?? [for (final c in fixtureList('courses_list')) CourseView.fromJson(c as Map<String, dynamic>)],
      detail = detail ?? CourseDetail.fromJson(fixtureMap('course_detail')),
      super(Dio());

  StudyOverview overview;
  List<StudySubject> subjects;
  List<CourseView> courses;
  CourseDetail detail;

  final created = <Map<String, Object?>>[];
  final patches = <Map<String, Object?>>[];
  final moves = <({String id, bool up})>[];
  final sectionToggles = <({String sectionId, bool done})>[];
  final parsedTexts = <String>[];
  final puts = <List<SectionInput>>[];
  final subjectBodies = <Map<String, Object?>>[];
  final subjectPatches = <Map<String, Object?>>[];
  final subjectDeletes = <String>[];
  Object? subjectDeleteError;
  /// Các buổi học trả về cho getLogs (lọc theo môn + khoảng ngày như server).
  List<StudyLog> logs = [];
  final logCreates = <Map<String, Object?>>[];
  final logPatches = <Map<String, Object?>>[];
  final logDeletes = <String>[];
  final reasonPuts = <({String subjectId, String date, ReasonCode code, String? text})>[];
  Object? reasonError;
  Object? logError;
  late StudyLogResult logResult = StudyLogResult.fromJson(fixtureMap('log_created'));
  /// Lịch trả về cho getSchedule: khớp theo (from, to) nếu có trong [schedules], không thì [defaultSchedule] (hoặc tự dựng).
  final schedules = <String, StudySchedule>{};
  StudySchedule? defaultSchedule;
  final scheduleCalls = <({String subjectId, String from, String to})>[];
  Object? scheduleError;
  Completer<void>? scheduleGate;
  /// Thống kê trả về: khớp theo "range|all" (mọi môn) hoặc "range|one" (một môn); mặc định lấy fixture.
  final statsResponses = <String, StudyStats>{};
  final statsCalls = <({String? subjectId, String range})>[];
  Object? statsError;
  Object? coursesError;
  Object? detailError;
  int overviewCalls = 0;
  int rebaselines = 0;
  Object? toggleError;
  Completer<void>? toggleGate;
  Object? createError;
  Object? overviewError;

  @override
  Future<List<StudyLog>> getLogs({required String from, required String to, String? subjectId}) async => [
    for (final l in logs)
      if ((subjectId == null || l.subjectId == subjectId) && l.logDate.compareTo(from) >= 0 && l.logDate.compareTo(to) <= 0) l,
  ];

  @override
  Future<StudyLogResult> createLog(Map<String, Object?> body) async {
    logCreates.add(body);
    if (logError case final e?) throw e;
    return logResult;
  }

  @override
  Future<StudyLogResult> patchLog(String id, Map<String, Object?> patch) async {
    logPatches.add({'id': id, ...patch});
    if (logError case final e?) throw e;
    return logResult;
  }

  @override
  Future<TodaySummary> deleteLog(String id) async {
    logDeletes.add(id);
    if (logError case final e?) throw e;
    return logResult.today;
  }

  @override
  Future<DayReasonEntry> putReason(String subjectId, String date, {required ReasonCode code, String? text}) async {
    reasonPuts.add((subjectId: subjectId, date: date, code: code, text: text));
    if (reasonError case final e?) throw e;
    return DayReasonEntry(date: date, code: code, text: text);
  }

  @override
  Future<StudySchedule> getSchedule({required String subjectId, required String from, required String to}) async {
    scheduleCalls.add((subjectId: subjectId, from: from, to: to));
    await scheduleGate?.future;
    if (scheduleError case final e?) throw e;
    return schedules['$from|$to'] ?? defaultSchedule ?? const StudySchedule(days: [], summary: ScheduleSummary(minutes: 0, plannedMinutes: 0));
  }

  @override
  Future<StudyOverview> getOverview() async {
    overviewCalls++;
    if (overviewError case final e?) throw e;
    return overview;
  }

  @override
  Future<StudyStats> getStats({String? subjectId, String range = '30'}) async {
    statsCalls.add((subjectId: subjectId, range: range));
    if (statsError case final e?) throw e;
    final key = '$range|${subjectId == null ? 'all' : 'one'}';
    if (statsResponses[key] case final r?) return r;
    final file = subjectId == null ? 'stats_all_subjects' : {'7': 'stats_7', '30': 'stats_30', 'all': 'stats_all'}[range]!;
    return StudyStats.fromJson(fixtureMap(file));
  }

  @override
  Future<List<StudySubject>> getSubjects() async => subjects;

  @override
  Future<StudySubject> createSubject(Map<String, Object?> body) async {
    subjectBodies.add(body);
    return subjects.first;
  }

  @override
  Future<StudySubject> updateSubject(String id, Map<String, Object?> patch) async {
    subjectPatches.add({'id': id, ...patch});
    return subjects.first;
  }

  @override
  Future<void> deleteSubject(String id) async {
    subjectDeletes.add(id);
    if (subjectDeleteError case final e?) throw e;
  }

  @override
  Future<List<CourseView>> getCourses({String? subjectId, Iterable<CourseStatus> statuses = const []}) async {
    if (coursesError case final e?) throw e;
    return [
    for (final c in courses)
      if ((subjectId == null || c.subjectId == subjectId) && (statuses.isEmpty || statuses.contains(c.status))) c,
    ];
  }

  @override
  Future<CourseDetail> getCourseDetail(String id) async {
    if (detailError case final e?) throw e;
    return detail;
  }

  @override
  Future<CourseDetail> setSectionDone(String courseId, String sectionId, bool done) async {
    sectionToggles.add((sectionId: sectionId, done: done));
    await toggleGate?.future;
    if (toggleError case final e?) throw e;
    detail = detail.withSectionDone(sectionId, done);
    return detail.copyWith(recentLogs: const []);
  }

  @override
  Future<ParsedSections> parseSections(String text) async {
    parsedTexts.add(text);
    final sections = <ParsedSection>[];
    final skipped = <SkippedLine>[];
    final lines = text.split('\n');
    for (final (i, line) in lines.indexed) {
      if (line.trim().isEmpty) continue;
      final m = RegExp(r'^(.*?)\s*(\d+)min$').firstMatch(line.trim());
      if (m == null || m.group(1)!.isEmpty) {
        skipped.add(SkippedLine(line: i + 1, text: line.trim()));
      } else {
        sections.add(ParsedSection(title: m.group(1)!, durationMinutes: int.parse(m.group(2)!)));
      }
    }
    return ParsedSections(sections: sections, skipped: skipped, totalMinutes: sections.fold(0, (n, s) => n + s.durationMinutes));
  }

  @override
  Future<CourseDetail> createCourse(Map<String, Object?> body) async {
    created.add(body);
    if (createError case final e?) throw e;
    return detail;
  }

  @override
  Future<CourseView> patchCourse(String id, Map<String, Object?> patch) async {
    patches.add({'id': id, ...patch});
    final old = courses.firstWhere((c) => c.id == id);
    if (patch['status'] case final String s) {
      courses = [
        for (final c in courses)
          if (c.id == id)
            CourseView(id: c.id, subjectId: c.subjectId, title: c.title, status: CourseStatus.fromApi(s), progress: c.progress)
          else
            c,
      ];
    }
    return old;
  }

  @override
  Future<List<CourseView>> moveCourse(String id, {required bool up}) async {
    moves.add((id: id, up: up));
    final queued = courses.where((c) => c.status == CourseStatus.queued).toList();
    final i = queued.indexWhere((c) => c.id == id);
    final j = up ? i - 1 : i + 1;
    if (i >= 0 && j >= 0 && j < queued.length) {
      final a = queued[i], b = queued[j];
      courses = [for (final c in courses) c.id == a.id ? b : (c.id == b.id ? a : c)];
    }
    return courses;
  }

  @override
  Future<void> deleteCourse(String id) async {}

  @override
  Future<CourseDetail> putSections(String courseId, List<SectionInput> sections) async {
    puts.add(sections);
    return detail;
  }

  @override
  Future<List<CourseView>> rebaseline(String subjectId) async {
    rebaselines++;
    return courses;
  }
}

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../shared/services/api_client.dart';
import '../models/course.dart';
import '../models/parsed_sections.dart';
import '../models/study_enums.dart';
import '../models/study_log.dart';
import '../models/study_overview.dart';
import '../models/study_schedule.dart';
import '../models/study_stats.dart';
import '../models/study_subject.dart';

/// Một dòng khi thay cả danh sách phần (PUT sections): có [id] thì giữ trạng thái xong.
class SectionInput {
  const SectionInput({this.id, required this.title, required this.durationMinutes});

  final String? id;
  final String title;
  final int durationMinutes;

  Map<String, Object> toJson() => {'id': ?id, 'title': title, 'durationMinutes': durationMinutes};
}

/// Học tập của Trà Đình: môn, khóa, phần, tổng quan. Mọi route lọc theo user đăng nhập.
class HocTapApi {
  const HocTapApi(this._dio);

  final Dio _dio;

  static const _base = '/api/tra-dinh/hoc-tap';

  Future<List<StudySubject>> getSubjects() async {
    final res = await _dio.get<List<dynamic>>('$_base/subjects');
    return [for (final e in res.data!) StudySubject.fromJson(e as Map<String, dynamic>)];
  }

  /// [body] gồm name, dailyGoalMinutes (null = bỏ mục tiêu), videoMinutesPerDay, reviewWeekdays.
  Future<StudySubject> createSubject(Map<String, Object?> body) async {
    final res = await _dio.post<Map<String, dynamic>>('$_base/subjects', data: body);
    return StudySubject.fromJson(res.data!);
  }

  Future<StudySubject> updateSubject(String id, Map<String, Object?> patch) async {
    final res = await _dio.patch<Map<String, dynamic>>('$_base/subjects/$id', data: patch);
    return StudySubject.fromJson(res.data!);
  }

  /// 409 `subject_in_use` nếu còn việc hằng ngày trỏ tới.
  Future<void> deleteSubject(String id) => _dio.delete<void>('$_base/subjects/$id');

  /// Chốt lại ngày xong dự kiến làm mốc mới; trả hàng học của môn (ACTIVE rồi QUEUED).
  Future<List<CourseView>> rebaseline(String subjectId) async {
    final res = await _dio.post<List<dynamic>>('$_base/subjects/$subjectId/rebaseline');
    return [for (final e in res.data!) CourseView.fromJson(e as Map<String, dynamic>)];
  }

  /// Thứ tự server trả: ACTIVE, QUEUED theo hàng chờ, WISHLIST mới nhất, DONE xong gần nhất.
  Future<List<CourseView>> getCourses({String? subjectId, Iterable<CourseStatus> statuses = const []}) async {
    final res = await _dio.get<List<dynamic>>(
      '$_base/courses',
      queryParameters: {'subjectId': ?subjectId, if (statuses.isNotEmpty) 'status': [for (final s in statuses) s.api]},
    );
    return [for (final e in res.data!) CourseView.fromJson(e as Map<String, dynamic>)];
  }

  Future<CourseDetail> getCourseDetail(String id) async {
    final res = await _dio.get<Map<String, dynamic>>('$_base/courses/$id');
    return CourseDetail.fromJson(res.data!);
  }

  /// [body]: subjectId, title, instructor, platform, url, status, targetPrice, note, sections / sectionsText.
  /// 409 `active_exists`; 400 `sections_unparsed` / `sections_conflict`.
  Future<CourseDetail> createCourse(Map<String, Object?> body) async {
    final res = await _dio.post<Map<String, dynamic>>('$_base/courses', data: body);
    return CourseDetail.fromJson(res.data!);
  }

  /// [patch] chỉ chứa trường cần đổi (kể cả status).
  Future<CourseView> patchCourse(String id, Map<String, Object?> patch) async {
    final res = await _dio.patch<Map<String, dynamic>>('$_base/courses/$id', data: patch);
    return CourseView.fromJson(res.data!);
  }

  Future<void> deleteCourse(String id) => _dio.delete<void>('$_base/courses/$id');

  /// Thay cả danh sách phần; trả chi tiết (không kèm recentLogs).
  Future<CourseDetail> putSections(String courseId, List<SectionInput> sections) async {
    final res = await _dio.put<Map<String, dynamic>>('$_base/courses/$courseId/sections', data: [for (final s in sections) s.toJson()]);
    return CourseDetail.fromJson(res.data!);
  }

  Future<CourseDetail> setSectionDone(String courseId, String sectionId, bool done) async {
    final res = await _dio.patch<Map<String, dynamic>>('$_base/courses/$courseId/sections/$sectionId', data: {'done': done});
    return CourseDetail.fromJson(res.data!);
  }

  /// [up] true = lên trước; chỉ khóa QUEUED. Trả hàng học của môn.
  Future<List<CourseView>> moveCourse(String id, {required bool up}) async {
    final res = await _dio.post<List<dynamic>>('$_base/courses/$id/move', data: {'direction': up ? 'up' : 'down'});
    return [for (final e in res.data!) CourseView.fromJson(e as Map<String, dynamic>)];
  }

  Future<ParsedSections> parseSections(String text) async {
    final res = await _dio.post<Map<String, dynamic>>('$_base/sections/parse', data: {'text': text});
    return ParsedSections.fromJson(res.data!);
  }

  /// Buổi học trong [from, to] ("YYYY-MM-DD", tối đa 400 ngày), mới nhất trước.
  Future<List<StudyLog>> getLogs({required String from, required String to, String? subjectId}) async {
    final res = await _dio.get<List<dynamic>>('$_base/logs', queryParameters: {'subjectId': ?subjectId, 'from': from, 'to': to});
    return [for (final e in res.data!) StudyLog.fromJson(e as Map<String, dynamic>)];
  }

  /// Ghi buổi học HÔM NAY (server tự đặt ngày). [body]: subjectId, courseId, minutes, sections [{sectionId, markDone}],
  /// note, stopForToday {code, text}.
  Future<StudyLogResult> createLog(Map<String, Object?> body) async {
    final res = await _dio.post<Map<String, dynamic>>('$_base/logs', data: body);
    return StudyLogResult.fromJson(res.data!);
  }

  /// Sửa buổi của hôm nay (400 `not_today` nếu không phải). [patch]: minutes, note, sections (thay cả danh sách), stopForToday.
  Future<StudyLogResult> patchLog(String id, Map<String, Object?> patch) async {
    final res = await _dio.patch<Map<String, dynamic>>('$_base/logs/$id', data: patch);
    return StudyLogResult.fromJson(res.data!);
  }

  /// Xoá buổi của hôm nay; trả tổng hôm nay mới.
  Future<TodaySummary> deleteLog(String id) async {
    final res = await _dio.delete<Map<String, dynamic>>('$_base/logs/$id');
    return TodaySummary.fromJson(res.data!['today'] as Map<String, dynamic>);
  }

  /// Ghi lý do chưa đủ mục tiêu cho [date] ("YYYY-MM-DD", hôm nay hoặc đã qua). 400 `goal_met`, `future_date`, `goal_missing`,
  /// `reason_text_required`.
  Future<DayReasonEntry> putReason(String subjectId, String date, {required ReasonCode code, String? text}) async {
    final res = await _dio.put<Map<String, dynamic>>('$_base/subjects/$subjectId/reasons/$date', data: {'code': code.api, 'text': ?text});
    return DayReasonEntry.fromJson(res.data!);
  }

  Future<void> deleteReason(String subjectId, String date) => _dio.delete<void>('$_base/subjects/$subjectId/reasons/$date');

  /// Lịch của một môn trong [from, to] ("YYYY-MM-DD", tối đa 62 ngày): ngày đã qua = buổi học thật, ngày tới = dự kiến.
  Future<StudySchedule> getSchedule({required String subjectId, required String from, required String to}) async {
    final res = await _dio.get<Map<String, dynamic>>('$_base/schedule', queryParameters: {'subjectId': subjectId, 'from': from, 'to': to});
    return StudySchedule.fromJson(res.data!);
  }

  /// Thống kê [range] = "7" | "30" | "all" (mặc định server 30); [subjectId] null = tất cả môn.
  Future<StudyStats> getStats({String? subjectId, String range = '30'}) async {
    final res = await _dio.get<Map<String, dynamic>>('$_base/stats', queryParameters: {'subjectId': ?subjectId, 'range': range});
    return StudyStats.fromJson(res.data!);
  }

  Future<StudyOverview> getOverview() async {
    final res = await _dio.get<Map<String, dynamic>>('$_base/overview');
    return StudyOverview.fromJson(res.data!);
  }
}

final hocTapApiProvider = Provider<HocTapApi>((ref) => HocTapApi(ref.watch(apiClientProvider)));

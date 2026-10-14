import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../shared/services/api_client.dart';
import '../models/course.dart';
import '../models/parsed_sections.dart';
import '../models/study_enums.dart';
import '../models/study_overview.dart';
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

  Future<StudyOverview> getOverview() async {
    final res = await _dio.get<Map<String, dynamic>>('$_base/overview');
    return StudyOverview.fromJson(res.data!);
  }
}

final hocTapApiProvider = Provider<HocTapApi>((ref) => HocTapApi(ref.watch(apiClientProvider)));

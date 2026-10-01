import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/services/api_client.dart';
import '../models/course.dart';
import '../models/lesson.dart';

/// Mảng Học tập: mỗi khóa học là 1 project LEARN. Backend kiểm tra khóa học/bài
/// học thuộc user (404 nếu không — gồm cả trường hợp không tồn tại).
class LearnApi {
  const LearnApi(this._dio);

  final Dio _dio;

  /// Mới tạo trước, kèm toàn bộ bài học của từng khóa.
  Future<List<Course>> getCourses() async {
    final res = await _dio.get<List<dynamic>>('/api/learn/courses');
    return res.data!.map((e) => Course.fromJson(e as Map<String, dynamic>)).toList();
  }

  /// [status] COMPLETED thì backend lưu trữ project ngay khi tạo.
  Future<Course> createCourse({
    required String name,
    String? source,
    String? field,
    CourseStatus status = CourseStatus.planned,
    String? startDate,
    String? endDate,
  }) async {
    final res = await _dio.post<Map<String, dynamic>>(
      '/api/learn/courses',
      data: {
        'name': name,
        'source': ?source,
        'field': ?field,
        'status': status.apiValue,
        'startDate': ?startDate,
        'endDate': ?endDate,
      },
    );
    return Course.fromJson(res.data!);
  }

  /// PATCH từng phần: chỉ gửi field khác null. Đổi [status] sang COMPLETED thì
  /// backend lưu trữ project, sang trạng thái khác thì bỏ lưu trữ.
  Future<Course> updateCourse(
    String id, {
    String? name,
    String? source,
    String? field,
    String? outcome,
    String? startDate,
    String? endDate,
    CourseStatus? status,
  }) async {
    final res = await _dio.patch<Map<String, dynamic>>(
      '/api/learn/courses/$id',
      data: {
        'name': ?name,
        'source': ?source,
        'field': ?field,
        'outcome': ?outcome,
        'startDate': ?startDate,
        'endDate': ?endDate,
        if (status != null) 'status': status.apiValue,
      },
    );
    return Course.fromJson(res.data!);
  }

  /// Xoá luôn mọi bài học (cascade).
  Future<void> deleteCourse(String id) => _dio.delete<void>('/api/learn/courses/$id');

  /// Thứ tự server: studiedAt giảm dần (bài chưa có ngày lên ĐẦU) — dùng
  /// sortLessonsRecentFirst nếu cần "mới nhất trước, chưa có ngày cuối".
  Future<List<Lesson>> getLessons(String courseId) async {
    final res = await _dio.get<List<dynamic>>('/api/learn/courses/$courseId/lessons');
    return res.data!.map((e) => Lesson.fromJson(e as Map<String, dynamic>)).toList();
  }

  /// [studiedAt] "YYYY-MM-DD".
  Future<Lesson> createLesson(
    String courseId, {
    required String title,
    String? studiedAt,
    int? durationMinutes,
    String? note,
  }) async {
    final res = await _dio.post<Map<String, dynamic>>(
      '/api/learn/courses/$courseId/lessons',
      data: {'title': title, 'studiedAt': ?studiedAt, 'durationMinutes': ?durationMinutes, 'note': ?note},
    );
    return Lesson.fromJson(res.data!);
  }

  Future<void> deleteLesson(String id) => _dio.delete<void>('/api/learn/lessons/$id');
}

final learnApiProvider = Provider<LearnApi>((ref) => LearnApi(ref.watch(apiClientProvider)));

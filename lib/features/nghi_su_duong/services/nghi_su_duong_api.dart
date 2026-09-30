import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/services/api_client.dart';
import '../models/overview.dart';
import '../models/project.dart';
import '../models/task.dart';

/// Trang chính Nghị Sự Đường + mảng Dự án (projects, tasks, 3 overview).
/// Mọi route lọc theo user đang đăng nhập ở backend.
class NghiSuDuongApi {
  const NghiSuDuongApi(this._dio);

  final Dio _dio;

  /// [year] mặc định (backend) = năm hiện tại theo lịch VN.
  Future<DuAnOverview> getDuAnOverview({int? year}) async {
    final res = await _dio.get<Map<String, dynamic>>('/api/du-an/overview', queryParameters: {'year': ?year});
    return DuAnOverview.fromJson(res.data!);
  }

  Future<FinanceOverview> getFinanceOverview({int? year}) async {
    final res = await _dio.get<Map<String, dynamic>>('/api/finance/overview', queryParameters: {'year': ?year});
    return FinanceOverview.fromJson(res.data!);
  }

  Future<LearnOverview> getLearnOverview({int? year}) async {
    final res = await _dio.get<Map<String, dynamic>>('/api/learn/overview', queryParameters: {'year': ?year});
    return LearnOverview.fromJson(res.data!);
  }

  /// Chỉ project chưa lưu trữ. [type] null = mọi loại.
  Future<List<Project>> getProjects({ProjectType? type}) async {
    final res = await _dio.get<List<dynamic>>(
      '/api/projects',
      queryParameters: {if (type != null) 'type': type.apiValue},
    );
    return res.data!.map((e) => Project.fromJson(e as Map<String, dynamic>)).toList();
  }

  /// [type] mặc định STANDARD ở backend.
  Future<Project> createProject({required String name, String? color, ProjectType? type}) async {
    final res = await _dio.post<Map<String, dynamic>>(
      '/api/projects',
      data: {'name': name, 'color': ?color, if (type != null) 'type': type.apiValue},
    );
    return Project.fromJson(res.data!);
  }

  /// Mọi task của user (không lọc theo ngày — lọc "hôm nay" ở client như web).
  Future<List<Task>> getTasks() async {
    final res = await _dio.get<List<dynamic>>('/api/tasks');
    return res.data!.map((e) => Task.fromJson(e as Map<String, dynamic>)).toList();
  }

  /// [projectId] phải là project của chính user (backend trả 404 nếu không).
  /// [startDate]/[dueDate] dạng "YYYY-MM-DD".
  Future<Task> createTask({
    String? projectId,
    required String title,
    required int importance,
    required int urgency,
    int durationMinutes = 15,
    String? startDate,
    String? dueDate,
  }) async {
    final res = await _dio.post<Map<String, dynamic>>(
      '/api/tasks',
      data: {
        'projectId': ?projectId,
        'title': title,
        'importance': importance,
        'urgency': urgency,
        'durationMinutes': durationMinutes,
        'startDate': ?startDate,
        'dueDate': ?dueDate,
      },
    );
    return Task.fromJson(res.data!);
  }
}

final nghiSuDuongApiProvider = Provider<NghiSuDuongApi>((ref) => NghiSuDuongApi(ref.watch(apiClientProvider)));

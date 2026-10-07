import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/services/api_client.dart';
import '../models/key_result.dart';
import '../models/overview.dart';
import '../models/project_detail.dart';
import '../models/project.dart';
import '../models/project_summary.dart';
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

  /// Dữ liệu màn Dự án: mọi dự án STANDARD (mọi trạng thái) kèm số liệu + việc cần chú ý.
  Future<DuAnSummary> getDuAnSummary() async {
    final res = await _dio.get<Map<String, dynamic>>('/api/du-an/summary');
    return DuAnSummary.fromJson(res.data!);
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

  /// [type] mặc định STANDARD ở backend. [startDate]/[endDate] dạng "YYYY-MM-DD";
  /// hạn trước ngày bắt đầu thì backend trả 400 `end_before_start`.
  Future<Project> createProject({
    required String name,
    String? color,
    ProjectType? type,
    String? goal,
    String? startDate,
    String? endDate,
  }) async {
    final res = await _dio.post<Map<String, dynamic>>(
      '/api/projects',
      data: {
        'name': name,
        'color': ?color,
        if (type != null) 'type': type.apiValue,
        'goal': ?goal,
        'startDate': ?startDate,
        'endDate': ?endDate,
      },
    );
    return Project.fromJson(res.data!);
  }

  /// Dự án STANDARD [id] kèm keyResults (404 nếu không phải của user hoặc khác loại).
  Future<ProjectDetail> getProject(String id) async {
    final res = await _dio.get<Map<String, dynamic>>('/api/projects/$id');
    return ProjectDetail.fromJson(res.data!);
  }

  /// PATCH từng phần: [patch] chỉ chứa trường cần đổi (name, goal, startDate, endDate, status);
  /// đặt `null` để xoá goal / startDate / endDate. 400 `end_before_start` khi hạn trước ngày bắt đầu.
  Future<ProjectDetail> updateProject(String id, Map<String, Object?> patch) async {
    final res = await _dio.patch<Map<String, dynamic>>('/api/projects/$id', data: patch);
    return ProjectDetail.fromJson(res.data!);
  }

  /// Việc của một dự án (kèm checklistItems, attention).
  Future<List<Task>> getProjectTasks(String projectId) async {
    final res = await _dio.get<List<dynamic>>('/api/tasks', queryParameters: {'projectId': projectId});
    return res.data!.map((e) => Task.fromJson(e as Map<String, dynamic>)).toList();
  }

  /// [target] chỉ dùng cho MANUAL (≥ 1); AUTO server bỏ qua target/current.
  Future<KeyResult> createKeyResult(
    String projectId, {
    required String name,
    required KrMode mode,
    String? unit,
    int? target,
  }) async {
    final res = await _dio.post<Map<String, dynamic>>(
      '/api/projects/$projectId/key-results',
      data: {'name': name, 'mode': mode.apiValue, 'unit': ?unit, if (mode == KrMode.manual) 'target': ?target},
    );
    return KeyResult.fromJson(res.data!);
  }

  /// [patch] chỉ chứa trường cần đổi (name, mode, unit, target, current). 400 `current_out_of_range`
  /// khi current ngoài 0..target.
  Future<KeyResult> updateKeyResult(String projectId, String krId, Map<String, Object?> patch) async {
    final res = await _dio.patch<Map<String, dynamic>>('/api/projects/$projectId/key-results/$krId', data: patch);
    return KeyResult.fromJson(res.data!);
  }

  /// Việc đang gắn vào KR tự thành không gắn (server xử lý).
  Future<void> deleteKeyResult(String projectId, String krId) =>
      _dio.delete<void>('/api/projects/$projectId/key-results/$krId');

  /// Việc luôn thuộc một dự án: [projectId] phải là project của chính user (backend trả 404 nếu không).
  /// [startDate]/[dueDate] dạng "YYYY-MM-DD".
  Future<Task> createTask({
    required String projectId,
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
        'projectId': projectId,
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

  /// PATCH từng phần: chỉ gửi trường được truyền (backend báo 400 nếu rỗng).
  /// Backend không tự đặt thêm trường nào khi chuyển sang DONE (chỉ ghi
  /// activity_logs "task.completed").
  Future<Task> updateTask(String id, {String? title, TaskStatus? status, int? importance}) async {
    final res = await _dio.patch<Map<String, dynamic>>(
      '/api/tasks/$id',
      data: {'title': ?title, 'status': ?status?.apiValue, 'importance': ?importance},
    );
    return Task.fromJson(res.data!);
  }

  /// Backend trả `{ok: true}`, 404 nếu không phải task của user.
  Future<void> deleteTask(String id) => _dio.delete<void>('/api/tasks/$id');
}

final nghiSuDuongApiProvider = Provider<NghiSuDuongApi>((ref) => NghiSuDuongApi(ref.watch(apiClientProvider)));

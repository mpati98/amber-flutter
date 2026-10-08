import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/services/api_client.dart';
import '../models/key_result.dart';
import '../models/overview.dart';
import '../models/project_detail.dart';
import '../models/project.dart';
import '../models/project_summary.dart';
import '../models/routine.dart';
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

  /// Việc hằng ngày chưa lưu trữ, tính quanh [date] ("YYYY-MM-DD"; null = hôm nay giờ VN ở server).
  Future<List<Routine>> getRoutines({String? date}) async {
    final res = await _dio.get<List<dynamic>>('/api/du-an/routines', queryParameters: {'date': ?date});
    return res.data!.map((e) => Routine.fromJson(e as Map<String, dynamic>)).toList();
  }

  /// [weekdays] 1–7 (1 = thứ Hai), không trùng; null = cả 7 ngày.
  Future<Routine> createRoutine({required String name, List<int>? weekdays}) async {
    final res = await _dio.post<Map<String, dynamic>>(
      '/api/du-an/routines',
      data: {'name': name, 'weekdays': ?weekdays},
    );
    return Routine.fromJson(res.data!);
  }

  /// [patch] chỉ chứa trường cần đổi (name, weekdays).
  Future<Routine> updateRoutine(String id, Map<String, Object?> patch) async {
    final res = await _dio.patch<Map<String, dynamic>>('/api/du-an/routines/$id', data: patch);
    return Routine.fromJson(res.data!);
  }

  /// Xoá hẳn, cả lịch sử đã làm.
  Future<void> deleteRoutine(String id) => _dio.delete<void>('/api/du-an/routines/$id');

  /// Đánh dấu đã làm ngày [date] ("YYYY-MM-DD"; idempotent). 400 `not_scheduled` (ngày không đến hạn),
  /// `future_date`. Trả routine đã cập nhật (tính quanh hôm nay).
  Future<Routine> markRoutineDone(String id, String date) async {
    final res = await _dio.put<Map<String, dynamic>>('/api/du-an/routines/$id/logs/$date');
    return Routine.fromJson(res.data!);
  }

  /// Bỏ đánh dấu ngày [date]. Trả routine đã cập nhật.
  Future<Routine> unmarkRoutineDone(String id, String date) async {
    final res = await _dio.delete<Map<String, dynamic>>('/api/du-an/routines/$id/logs/$date');
    return Routine.fromJson(res.data!);
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

  /// Đóng dự án: status DONE + closedAt, đồng thời server lưu một tài liệu tổng kết vào Tàng Kinh Các.
  /// [note] tối đa 5000 ký tự. 400 `project_already_done`. Trả dự án (không kèm KR) và id tài liệu.
  Future<({ProjectDetail project, String documentId})> closeProject(String id, {String? note}) async {
    final res = await _dio.post<Map<String, dynamic>>('/api/projects/$id/close', data: {'note': ?note});
    return (
      project: ProjectDetail.fromJson(res.data!['project'] as Map<String, dynamic>),
      documentId: res.data!['documentId'] as String,
    );
  }

  /// Xoá hẳn dự án: KR, việc, checklist xoá theo; giao dịch đã gắn được giữ (bỏ liên kết); tài liệu tổng kết giữ.
  Future<void> deleteProject(String id) => _dio.delete<void>('/api/projects/$id');

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
  /// [startDate]/[dueDate] dạng "YYYY-MM-DD". importance và urgency không gửi (server mặc định 2).
  /// POST không nhận null: trường không có thì bỏ hẳn. 400: `end_before_start`,
  /// `notify_requires_due_date`, `kr_not_in_project`.
  Future<Task> createTask({
    required String projectId,
    required String title,
    TaskStatus? status,
    String? startDate,
    String? dueDate,
    bool? isMilestone,
    String? krId,
    bool? notifyDeadline,
    int? prepLeadDays,
    String? description,
  }) async {
    final res = await _dio.post<Map<String, dynamic>>(
      '/api/tasks',
      data: {
        'projectId': projectId,
        'title': title,
        'status': ?status?.apiValue,
        'startDate': ?startDate,
        'dueDate': ?dueDate,
        'isMilestone': ?isMilestone,
        'krId': ?krId,
        'notifyDeadline': ?notifyDeadline,
        'prepLeadDays': ?prepLeadDays,
        'description': ?description,
      },
    );
    return Task.fromJson(res.data!);
  }

  /// PATCH từng phần: [patch] chỉ chứa trường cần đổi (title, status, startDate, dueDate, isMilestone,
  /// krId, notifyDeadline, prepLeadDays, description). Backend nhận `null` cho description, krId,
  /// startDate, dueDate, prepLeadDays (để xoá). Backend không tự đặt thêm trường nào khi sang DONE.
  Future<Task> updateTask(String id, Map<String, Object?> patch) async {
    final res = await _dio.patch<Map<String, dynamic>>('/api/tasks/$id', data: patch);
    return Task.fromJson(res.data!);
  }

  /// Thay cả checklist của việc (có id → giữ, không id → tạo, thiếu → xoá; thứ tự = thứ tự mảng).
  /// Tối đa 50 mục, text 1–500. Trả danh sách mới.
  Future<List<ChecklistItem>> putChecklist(String taskId, List<ChecklistDraft> items) async {
    final res = await _dio.put<List<dynamic>>(
      '/api/tasks/$taskId/checklist',
      data: {
        'items': [
          for (final i in items) {'id': ?i.id, 'text': i.text, 'done': i.done},
        ],
      },
    );
    return res.data!.map((e) => ChecklistItem.fromJson(e as Map<String, dynamic>)).toList();
  }

  /// Sửa một mục: [done] và/hoặc [text].
  Future<ChecklistItem> patchChecklistItem(String taskId, String itemId, {bool? done, String? text}) async {
    final res = await _dio.patch<Map<String, dynamic>>(
      '/api/tasks/$taskId/checklist/$itemId',
      data: {'done': ?done, 'text': ?text},
    );
    return ChecklistItem.fromJson(res.data!);
  }

  /// Backend trả `{ok: true}`, 404 nếu không phải task của user.
  Future<void> deleteTask(String id) => _dio.delete<void>('/api/tasks/$id');
}

/// Một mục trong body PUT checklist ([id] null = mục mới).
class ChecklistDraft {
  const ChecklistDraft({this.id, required this.text, required this.done});

  final String? id;
  final String text;
  final bool done;
}

final nghiSuDuongApiProvider = Provider<NghiSuDuongApi>((ref) => NghiSuDuongApi(ref.watch(apiClientProvider)));

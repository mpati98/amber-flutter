import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/services/api_client.dart';
import '../models/ats_task.dart';

/// Task công việc từ ats-app (bản sao chỉ đọc ở amber-v4). Không có hàm sửa / xoá / tạo — sửa trên ats-app.
class AtsTasksApi {
  const AtsTasksApi(this._dio);

  final Dio _dio;

  /// [all] = true: gồm cả dự án lưu trữ và việc DONE xong quá 7 ngày (`?all=1`).
  Future<AtsTasksData> getTasks({bool all = false}) async {
    final res = await _dio.get<Map<String, dynamic>>('/api/du-an/ats-tasks', queryParameters: {if (all) 'all': '1'});
    return AtsTasksData.fromJson(res.data ?? const {});
  }

  /// Đồng bộ ngay. 429 (bấm dưới 30 giây) và 502/503 ném DioException — xem [atsRetryAfterSeconds], `apiErrorMessage`.
  Future<AtsSyncResult> syncNow() async {
    final res = await _dio.post<Map<String, dynamic>>('/api/du-an/ats-tasks/sync');
    return AtsSyncResult.fromJson(res.data ?? const {});
  }
}

final atsTasksApiProvider = Provider<AtsTasksApi>((ref) => AtsTasksApi(ref.watch(apiClientProvider)));

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/services/api_client.dart';
import '../models/sleep_log.dart';

/// `/api/du-an/sleep` (backend amber-v4): giấc ngủ tự ghi mỗi sáng, nguồn của chỉ số Sinh lực ở màn chủ 3D.
class SleepApi {
  SleepApi(this._dio);

  final Dio _dio;

  Future<SleepHistory> history({int days = 14}) async {
    final res = await _dio.get<Map<String, dynamic>>('/api/du-an/sleep', queryParameters: {'days': days});
    return SleepHistory.fromJson(res.data ?? const {});
  }

  Future<SleepLog> save({required String date, required int sleepMinutes, int? quality, String? note}) async {
    final res = await _dio.put<Map<String, dynamic>>(
      '/api/du-an/sleep',
      data: {'date': date, 'sleepMinutes': sleepMinutes, 'quality': quality, 'note': (note?.trim().isEmpty ?? true) ? null : note!.trim()},
    );
    return SleepLog.fromJson(Map<String, dynamic>.from(res.data?['log'] as Map? ?? const {}));
  }

  Future<void> delete(String date) => _dio.delete<void>('/api/du-an/sleep/$date');
}

final sleepApiProvider = Provider<SleepApi>((ref) => SleepApi(ref.watch(apiClientProvider)));

final sleepHistoryProvider = FutureProvider.autoDispose<SleepHistory>((ref) => ref.watch(sleepApiProvider).history());

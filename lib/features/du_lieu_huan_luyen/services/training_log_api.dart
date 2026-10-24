import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/services/api_client.dart';
import '../models/training_log.dart';

/// API nhật ký amber-brain trên amber-v4 (/api/brain-logs). App KHÔNG gọi thẳng brain: amber-v4 là cổng, nên dùng được
/// từ web/điện thoại mà không cần brain mở ra ngoài.
class TrainingLogApi {
  const TrainingLogApi(this._dio);

  final Dio _dio;

  Future<TrainingLogPage> list({
    String? agent,
    LogOutcome? outcome,
    TrainingRoute? route,
    String? cursor,
    int limit = 30,
  }) async {
    final res = await _dio.get<Map<String, dynamic>>(
      '/api/brain-logs',
      queryParameters: {
        'agent': ?agent,
        if (outcome != null) 'outcome': outcome.name,
        if (route != null) 'route': route.apiValue,
        'cursor': ?cursor,
        'limit': limit,
      },
    );
    return TrainingLogPage.fromJson(res.data!);
  }

  Future<TrainingLogDetail> detail(String id) async {
    final res = await _dio.get<Map<String, dynamic>>('/api/brain-logs/$id');
    return TrainingLogDetail.fromJson(res.data!);
  }

  Future<TrainingStats> stats() async {
    final res = await _dio.get<Map<String, dynamic>>('/api/brain-logs/stats');
    return TrainingStats.fromJson(res.data!);
  }

  /// Đánh giá đúng/sai: [accepted] hoặc [rejected] (server từ chối giá trị khác).
  Future<void> feedback(String id, {required bool correct}) => _dio.post<void>(
    '/api/brain-logs/$id/feedback',
    data: {'outcome': correct ? 'accepted' : 'rejected'},
  );

  Future<void> setExcluded(String id, bool excluded) => _dio.patch<void>(
    '/api/brain-logs/$id',
    data: {'excludeFromTraining': excluded},
  );

  Future<void> setCorrection(String id, Object? correctedOutput) =>
      _dio.patch<void>(
        '/api/brain-logs/$id',
        data: {'correctedOutput': correctedOutput},
      );
}

final trainingLogApiProvider = Provider<TrainingLogApi>(
  (ref) => TrainingLogApi(ref.watch(apiClientProvider)),
);

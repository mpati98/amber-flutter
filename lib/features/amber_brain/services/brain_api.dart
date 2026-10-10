import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/services/api_client.dart';
import '../../../shared/services/token_storage.dart';
import '../models/brain_models.dart';

const brainBaseUrl = String.fromEnvironment('BRAIN_BASE_URL', defaultValue: 'http://127.0.0.1:8765');

/// Brain chạy mô hình cục bộ nên một lượt chat có thể mất vài chục giây.
const brainTimeout = Duration(seconds: 60);

const _statusPath = '/v1/status';

/// Dio riêng cho amber-brain: gắn Bearer từ [storage]; 401 thì [refresher] (dùng
/// chung với Dio của amber-v4) làm mới token rồi gửi lại đúng request đó một lần.
/// `/v1/status` không cần token nên không gắn Bearer (tránh preflight thừa).
Dio createBrainClient(TokenStorage storage, TokenRefresher refresher, {String baseUrl = brainBaseUrl}) {
  final dio = Dio(
    BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: brainTimeout,
      receiveTimeout: brainTimeout,
      sendTimeout: brainTimeout,
    ),
  );
  addAuthInterceptor(dio, storage: storage, refresher: refresher, noAuthPaths: const [_statusPath]);
  return dio;
}

class BrainApi {
  BrainApi(this._dio);

  final Dio _dio;

  Future<BrainStatus> status() async {
    final res = await _dio.get<Map<String, dynamic>>(
      _statusPath,
      options: Options(receiveTimeout: const Duration(seconds: 5), sendTimeout: const Duration(seconds: 5)),
    );
    return BrainStatus.fromJson(res.data!);
  }

  Future<BrainReply> chat(String text, {String? conversationId}) =>
      _post('/v1/chat', {'text': text, 'conversationId': ?conversationId});

  Future<BrainReply> confirm(String conversationId) =>
      _post('/v1/confirm', {'conversationId': conversationId, 'accept': true});

  Future<BrainReply> cancel(String conversationId) => _post('/v1/cancel', {'conversationId': conversationId});

  Future<BrainReply> undo({String? conversationId}) => _post('/v1/undo', {'conversationId': ?conversationId});

  Future<BrainReply> _post(String path, Map<String, dynamic> body) async {
    final res = await _dio.post<Map<String, dynamic>>(path, data: body);
    return BrainReply.fromJson(res.data!);
  }
}

final brainDioProvider = Provider<Dio>(
  (ref) => createBrainClient(ref.watch(tokenStorageProvider), ref.watch(tokenRefresherProvider)),
);

final brainApiProvider = Provider<BrainApi>((ref) => BrainApi(ref.watch(brainDioProvider)));

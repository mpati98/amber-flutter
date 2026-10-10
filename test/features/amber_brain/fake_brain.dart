import 'dart:async';
import 'dart:convert';

import 'package:amber_flutter/features/amber_brain/providers/brain_status_provider.dart';
import 'package:amber_flutter/shared/services/token_storage.dart';
import 'package:dio/dio.dart';

typedef Scripted = (int, Object);

/// Brain giả ở tầng HTTP: chạy qua đúng Dio + interceptor thật của app.
/// [script] map đường dẫn → danh sách phản hồi lần lượt (phản hồi cuối lặp lại).
class FakeBrain implements HttpClientAdapter {
  final requests = <RequestOptions>[];

  /// Header Authorization tại thời điểm gọi (RequestOptions bị gửi lại dùng chung object nên không đọc lại được).
  final auths = <(String, String?)>[];
  final script = <String, List<Scripted>>{};
  bool offline = false;

  /// Giữ /v1/chat cho tới khi hoàn thành (để thấy trạng thái đang chờ).
  Completer<void>? chatGate;

  /// Nếu đặt: chỉ nhận Bearer đúng token này, còn lại 401 (giống brain kiểm tra với amber-v4).
  String? requiredToken;

  List<String?> authsOf(String path) => [
    for (final (p, a) in auths)
      if (p == path) a,
  ];

  int count(String path) => requests.where((r) => r.path == path).length;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<List<int>>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    requests.add(options);
    auths.add((options.path, options.headers['Authorization'] as String?));
    if (offline) throw DioException.connectionError(requestOptions: options, reason: 'offline');
    if (options.path == '/v1/chat' && chatGate != null) await chatGate!.future;
    Scripted reply;
    if (requiredToken != null &&
        options.path != '/v1/status' &&
        options.headers['Authorization'] != 'Bearer $requiredToken') {
      reply = (401, {'error': 'unauthorized', 'message': 'Invalid or expired token.'});
    } else {
      final list = script[options.path] ?? (throw StateError('Chưa có kịch bản cho ${options.path}'));
      reply = list.length > 1 ? list.removeAt(0) : list.first;
    }
    return ResponseBody.fromString(
      jsonEncode(reply.$2),
      reply.$1,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}

Map<String, Object?> statusJson({String env = 'DEV', String host = 'localhost:3000'}) => {
  'serverEnv': env,
  'serverHost': host,
  'ollama': 'up',
  'model': 'qwen3:4b-instruct',
};

Map<String, Object?> replyJson({
  String reply = '',
  String state = 'idle',
  Map<String, Object?>? draft,
  Map<String, Object?>? undoTarget,
  String? action,
  String? transactionId,
  num? balance,
  String conversationId = 'c1',
}) => {
  'serverEnv': 'DEV',
  'serverHost': 'localhost:3000',
  'reply': reply,
  'conversationId': conversationId,
  'state': state,
  'draft': draft,
  'undoTarget': undoTarget,
  'action': ?action,
  'transactionId': ?transactionId,
  'balance': ?balance,
};

const draftJson = <String, Object?>{
  'kind': 'EXPENSE',
  'amount': 45000,
  'account': {'id': 'a1', 'name': 'Momo'},
  'category': {'id': 'c1', 'name': 'Ăn uống'},
  'date': '2026-10-10',
  'dateLabel': 'today',
  'note': 'ăn trưa',
};

const undoTargetJson = <String, Object?>{
  'id': 'tx-1',
  'kind': 'EXPENSE',
  'amount': 45000,
  'account': {'id': 'a1', 'name': 'Momo'},
  'date': '2026-10-10',
};

class MemoryTokenStorage implements TokenStorage {
  MemoryTokenStorage({this.access, this.refresh});
  String? access;
  String? refresh;

  @override
  Future<void> saveTokens({required String accessToken, required String refreshToken}) async {
    access = accessToken;
    refresh = refreshToken;
  }

  @override
  Future<String?> readAccessToken() async => access;

  @override
  Future<String?> readRefreshToken() async => refresh;

  @override
  Future<void> clear() async {
    access = null;
    refresh = null;
  }
}

/// Trạng thái brain cố định — không tạo Timer/Dio thật (dùng cho test màn khác có nút Amber).
class FixedBrainStatus extends BrainStatusNotifier {
  FixedBrainStatus([this.value = const BrainConnection(link: BrainLink.offline)]);
  final BrainConnection value;

  @override
  BrainConnection build() => value;
}

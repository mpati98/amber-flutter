import 'dart:convert';
import 'dart:io';

import 'package:amber_flutter/shared/services/api_client.dart';
import 'package:amber_flutter/shared/services/token_storage.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

class _MemoryTokenStorage implements TokenStorage {
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

/// Giả lập backend: access token hợp lệ duy nhất là [validAccess]; refresh
/// token xoay vòng giống /api/mobile/auth/refresh (dùng xong là hết hiệu lực).
class _FakeBackend {
  late final HttpServer server;
  String validAccess = 'access-1';
  String validRefresh = 'refresh-1';
  int refreshCalls = 0;
  final authHeaders = <String?>[];

  String get baseUrl => 'http://${server.address.host}:${server.port}';

  Future<void> start() async {
    server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
    server.listen(_handle);
  }

  Future<void> _handle(HttpRequest req) async {
    final body = await utf8.decoder.bind(req).join();
    final authHeader = req.headers.value('authorization');
    authHeaders.add(authHeader);
    void reply(int status, Object json) {
      req.response
        ..statusCode = status
        ..headers.contentType = ContentType.json
        ..write(jsonEncode(json))
        ..close();
    }

    switch (req.uri.path) {
      case '/api/mobile/auth/refresh':
        refreshCalls++;
        // Trễ một chút để các request 401 song song thật sự chồng lên nhau.
        await Future<void>.delayed(const Duration(milliseconds: 50));
        final token = (jsonDecode(body) as Map)['refreshToken'];
        if (token != validRefresh) return reply(401, {'error': 'invalid_refresh_token'});
        validAccess = 'access-${refreshCalls + 1}';
        validRefresh = 'refresh-${refreshCalls + 1}';
        return reply(200, {'accessToken': validAccess, 'refreshToken': validRefresh});
      case '/api/mobile/auth/login':
        return reply(401, {'error': 'invalid_credentials'});
      case '/always-401':
        return reply(401, {'error': 'unauthorized'});
      default:
        if (authHeader != 'Bearer $validAccess') return reply(401, {'error': 'unauthorized'});
        return reply(200, {'ok': true});
    }
  }
}

void main() {
  late _FakeBackend backend;
  late _MemoryTokenStorage storage;
  late Dio dio;

  setUp(() async {
    backend = _FakeBackend();
    await backend.start();
    storage = _MemoryTokenStorage();
    dio = createApiClient(storage, baseUrl: backend.baseUrl);
  });

  tearDown(() => backend.server.close(force: true));

  test('gắn Bearer từ storage', () async {
    storage.access = 'access-1';
    final res = await dio.get<Map<String, dynamic>>('/api/kieu-lau/notifications');
    expect(res.statusCode, 200);
    expect(backend.authHeaders.single, 'Bearer access-1');
    expect(backend.refreshCalls, 0);
  });

  test('401 → refresh → retry request gốc với token mới, lưu cặp token mới', () async {
    storage
      ..access = 'expired'
      ..refresh = 'refresh-1';
    final res = await dio.get<Map<String, dynamic>>('/api/kieu-lau/notifications');
    expect(res.statusCode, 200);
    expect(backend.refreshCalls, 1);
    expect(storage.access, 'access-2');
    expect(storage.refresh, 'refresh-2');
    expect(backend.authHeaders.last, 'Bearer access-2');
  });

  test('nhiều request cùng dính 401 chỉ refresh 1 lần (refresh token xoay vòng)', () async {
    storage
      ..access = 'expired'
      ..refresh = 'refresh-1';
    final results = await Future.wait([
      for (var i = 0; i < 3; i++) dio.get<Map<String, dynamic>>('/api/kieu-lau/feed-sources'),
    ]);
    expect(results.map((r) => r.statusCode), everyElement(200));
    expect(backend.refreshCalls, 1);
    expect(storage.refresh, 'refresh-2');
  });

  test('server từ chối refresh token → xoá token, 401 đi tiếp ra ngoài', () async {
    storage
      ..access = 'expired'
      ..refresh = 'revoked';
    await expectLater(
      dio.get<void>('/api/kieu-lau/notifications'),
      throwsA(isA<DioException>().having((e) => e.response?.statusCode, 'status', 401)),
    );
    expect(storage.access, isNull);
    expect(storage.refresh, isNull);
  });

  test('401 từ login không kích hoạt refresh', () async {
    storage.refresh = 'refresh-1';
    await expectLater(
      dio.post<void>('/api/mobile/auth/login', data: {'email': 'a', 'password': 'b'}),
      throwsA(isA<DioException>()),
    );
    expect(backend.refreshCalls, 0);
    expect(storage.refresh, 'refresh-1');
  });

  test('request tuyệt đối tới host khác KHÔNG kèm Bearer', () async {
    final external = _FakeBackend();
    await external.start();
    addTearDown(() => external.server.close(force: true));
    storage
      ..access = 'access-1'
      ..refresh = 'refresh-1';
    // Host ngoài trả 401 vì không có Bearer của nó — chỉ cần xem header gửi đi.
    await expectLater(dio.get<void>('${external.baseUrl}/cover.jpg'), throwsA(isA<DioException>()));
    expect(external.authHeaders.single, isNull);
    // Request tương đối tới chính API vẫn có Bearer như cũ.
    await dio.get<void>('/api/kieu-lau/notifications');
    expect(backend.authHeaders.single, 'Bearer access-1');
  });

  test('401 từ host khác không kích hoạt refresh, không xoá token', () async {
    final external = _FakeBackend();
    await external.start();
    addTearDown(() => external.server.close(force: true));
    storage
      ..access = 'access-1'
      ..refresh = 'refresh-1';
    await expectLater(dio.get<void>('${external.baseUrl}/private'), throwsA(isA<DioException>()));
    expect(backend.refreshCalls + external.refreshCalls, 0);
    expect(storage.refresh, 'refresh-1');
  });

  test('retry vẫn 401 thì dừng, không lặp refresh', () async {
    storage
      ..access = 'expired'
      ..refresh = 'refresh-1';
    await expectLater(dio.get<void>('/always-401'), throwsA(isA<DioException>()));
    expect(backend.refreshCalls, 1);
  });
}

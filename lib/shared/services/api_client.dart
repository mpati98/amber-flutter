import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/auth_provider.dart';
import 'token_storage.dart';

const apiBaseUrl = String.fromEnvironment('API_BASE_URL', defaultValue: 'http://localhost:3000');

// login/refresh/logout: không gắn Bearer, và 401 ở đây là lỗi thật (sai mật
// khẩu, refresh token hết hạn) — không được kích hoạt refresh.
const _authPathPrefix = '/api/mobile/auth/';
const _retriedKey = 'amber_retried_after_refresh';

/// Làm mới cặp token. Dùng chung cho mọi Dio gọi tới backend của Amber (amber-v4
/// và amber-brain): backend xoay vòng refresh token (dùng xong là xoá), nên mọi
/// request dính 401 — dù ở Dio nào — phải chờ chung 1 lần refresh; gọi song song
/// thì lần thứ 2 dùng token đã bị xoá, nhận 401 và làm mất phiên đăng nhập.
///
/// [onSessionExpired] chạy khi server từ chối refresh token (phiên đã hết) —
/// để tầng auth chuyển sang chưa đăng nhập và router đưa về /login.
class TokenRefresher {
  TokenRefresher(this.storage, {String baseUrl = apiBaseUrl, this.onSessionExpired, Dio? dio})
    // Instance riêng KHÔNG gắn interceptor — chỉ để gọi refresh, tránh đệ quy.
    : _dio = dio ?? Dio(BaseOptions(baseUrl: baseUrl));

  final TokenStorage storage;
  final void Function()? onSessionExpired;
  final Dio _dio;
  Future<_RefreshResult>? _inFlight;

  Future<_RefreshResult> _refresh() async {
    final refreshToken = await storage.readRefreshToken();
    if (refreshToken == null) return _RefreshResult.rejected;
    try {
      final res = await _dio.post<Map<String, dynamic>>(
        '/api/mobile/auth/refresh',
        data: {'refreshToken': refreshToken},
      );
      await storage.saveTokens(
        accessToken: res.data!['accessToken'] as String,
        refreshToken: res.data!['refreshToken'] as String,
      );
      return _RefreshResult.success;
    } on DioException catch (e) {
      return e.response?.statusCode == 401 ? _RefreshResult.rejected : _RefreshResult.failed;
    }
  }

  /// Gọi khi một request nhận 401. True = đã có access token mới, gửi lại được.
  Future<bool> recover() async {
    final result = await (_inFlight ??= _refresh().whenComplete(() => _inFlight = null));
    // Chỉ xoá token khi server từ chối refresh token; lỗi mạng thì giữ
    // lại để lần sau thử tiếp, không đá người dùng ra ngoài vô cớ.
    if (result == _RefreshResult.rejected) {
      await storage.clear();
      onSessionExpired?.call();
    }
    return result == _RefreshResult.success;
  }
}

/// Gắn vào [dio]: tự thêm `Authorization: Bearer <accessToken>`, gặp 401 thì
/// [refresher] làm mới token một lần rồi gửi lại đúng request gốc.
///
/// Đường dẫn chứa một trong [noAuthPaths] không gắn Bearer và 401 ở đó không
/// kích hoạt refresh.
void addAuthInterceptor(
  Dio dio, {
  required TokenStorage storage,
  required TokenRefresher refresher,
  List<String> noAuthPaths = const [_authPathPrefix],
}) {
  // So origin (scheme + host + port) của URL cuối cùng, KHÔNG so options.baseUrl
  // (Dio giữ nguyên baseUrl cả khi path là URL tuyệt đối ra host khác) và KHÔNG
  // dùng startsWith chuỗi (`https://api.x` là tiền tố của `https://api.x.evil.com`).
  final apiOrigin = Uri.parse(dio.options.baseUrl);
  bool isOwnApi(RequestOptions o) {
    final uri = o.uri;
    return uri.scheme == apiOrigin.scheme && uri.host == apiOrigin.host && uri.port == apiOrigin.port;
  }

  bool skipAuth(RequestOptions o) => noAuthPaths.any(o.path.contains);

  dio.interceptors.add(
    InterceptorsWrapper(
      onRequest: (options, handler) async {
        // Không gửi Bearer cho host khác (vd ảnh bìa URL ngoài).
        if (isOwnApi(options) && !skipAuth(options)) {
          final token = await storage.readAccessToken();
          if (token != null) options.headers['Authorization'] = 'Bearer $token';
        }
        handler.next(options);
      },
      onError: (err, handler) async {
        final options = err.requestOptions;
        // 401 từ host khác không liên quan phiên đăng nhập — không refresh.
        if (err.response?.statusCode != 401 ||
            !isOwnApi(options) ||
            skipAuth(options) ||
            options.extra[_retriedKey] == true) {
          return handler.next(err);
        }

        if (!await refresher.recover()) return handler.next(err);

        try {
          // onRequest sẽ gắn lại access token mới khi fetch đi qua interceptor.
          options.extra[_retriedKey] = true;
          handler.resolve(await dio.fetch(options));
        } on DioException catch (e) {
          handler.next(e);
        }
      },
    ),
  );
}

/// Dio dùng chung cho amber-v4. [refresher] mặc định tạo riêng; truyền vào để
/// chia sẻ với Dio khác (xem [tokenRefresherProvider]).
Dio createApiClient(
  TokenStorage storage, {
  String baseUrl = apiBaseUrl,
  void Function()? onSessionExpired,
  TokenRefresher? refresher,
}) {
  final dio = Dio(BaseOptions(baseUrl: baseUrl));
  addAuthInterceptor(
    dio,
    storage: storage,
    refresher: refresher ?? TokenRefresher(storage, baseUrl: baseUrl, onSessionExpired: onSessionExpired),
  );
  return dio;
}

enum _RefreshResult { success, rejected, failed }

final tokenRefresherProvider = Provider<TokenRefresher>(
  (ref) => TokenRefresher(
    ref.watch(tokenStorageProvider),
    // Đọc lúc gọi (không phải lúc tạo) — tránh phụ thuộc vòng: AuthController
    // cũng dùng apiClientProvider để gọi login/logout.
    onSessionExpired: () => ref.read(authControllerProvider.notifier).sessionExpired(),
  ),
);

final apiClientProvider = Provider<Dio>(
  (ref) => createApiClient(ref.watch(tokenStorageProvider), refresher: ref.watch(tokenRefresherProvider)),
);

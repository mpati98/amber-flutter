import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/auth_provider.dart';
import 'token_storage.dart';

const apiBaseUrl = String.fromEnvironment('API_BASE_URL', defaultValue: 'http://localhost:3000');

// login/refresh/logout: không gắn Bearer, và 401 ở đây là lỗi thật (sai mật
// khẩu, refresh token hết hạn) — không được kích hoạt refresh.
const _authPathPrefix = '/api/mobile/auth/';
const _retriedKey = 'amber_retried_after_refresh';

/// Dio dùng chung: tự gắn `Authorization: Bearer <accessToken>`, gặp 401 thì
/// refresh token một lần rồi retry đúng request gốc.
///
/// [onSessionExpired] chạy khi server từ chối refresh token (phiên đã hết) —
/// để tầng auth chuyển sang chưa đăng nhập và router đưa về /login.
Dio createApiClient(TokenStorage storage, {String baseUrl = apiBaseUrl, void Function()? onSessionExpired}) {
  final dio = Dio(BaseOptions(baseUrl: baseUrl));
  // Instance riêng KHÔNG gắn interceptor bên dưới — chỉ để gọi refresh, tránh đệ quy.
  final refreshDio = Dio(BaseOptions(baseUrl: baseUrl));

  // Backend xoay vòng refresh token (dùng xong là xoá), nên nhiều request cùng
  // dính 401 phải chờ chung 1 lần refresh — gọi song song thì lần thứ 2 dùng
  // token đã bị xoá, nhận 401 và làm mất phiên đăng nhập.
  Future<_RefreshResult>? inFlightRefresh;

  // So origin (scheme + host + port) của URL cuối cùng, KHÔNG so options.baseUrl
  // (Dio giữ nguyên baseUrl cả khi path là URL tuyệt đối ra host khác) và KHÔNG
  // dùng startsWith chuỗi (`https://api.x` là tiền tố của `https://api.x.evil.com`).
  final apiOrigin = Uri.parse(baseUrl);
  bool isOwnApi(RequestOptions o) {
    final uri = o.uri;
    return uri.scheme == apiOrigin.scheme && uri.host == apiOrigin.host && uri.port == apiOrigin.port;
  }

  Future<_RefreshResult> refresh() async {
    final refreshToken = await storage.readRefreshToken();
    if (refreshToken == null) return _RefreshResult.rejected;
    try {
      final res = await refreshDio.post<Map<String, dynamic>>(
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

  dio.interceptors.add(
    InterceptorsWrapper(
      onRequest: (options, handler) async {
        // Không gửi Bearer cho host khác (vd ảnh bìa URL ngoài).
        if (isOwnApi(options) && !options.path.contains(_authPathPrefix)) {
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
            options.path.contains(_authPathPrefix) ||
            options.extra[_retriedKey] == true) {
          return handler.next(err);
        }

        final result = await (inFlightRefresh ??= refresh().whenComplete(() => inFlightRefresh = null));
        if (result != _RefreshResult.success) {
          // Chỉ xoá token khi server từ chối refresh token; lỗi mạng thì giữ
          // lại để lần sau thử tiếp, không đá người dùng ra ngoài vô cớ.
          if (result == _RefreshResult.rejected) {
            await storage.clear();
            onSessionExpired?.call();
          }
          return handler.next(err);
        }

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
  return dio;
}

enum _RefreshResult { success, rejected, failed }

final apiClientProvider = Provider<Dio>(
  (ref) => createApiClient(
    ref.watch(tokenStorageProvider),
    // Đọc lúc gọi (không phải lúc tạo) — tránh phụ thuộc vòng: AuthController
    // cũng dùng apiClientProvider để gọi login/logout.
    onSessionExpired: () => ref.read(authControllerProvider.notifier).sessionExpired(),
  ),
);

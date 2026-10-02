import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../services/api_client.dart';
import '../services/token_storage.dart';

sealed class AuthState {
  const AuthState();
}

/// Có token trong storage nhưng chưa xác nhận — để API tự xác nhận (401 nếu sai).
class AuthInitial extends AuthState {
  const AuthInitial();
}

class Authenticated extends AuthState {
  const Authenticated(this.user);

  /// `{id, email, name}` từ POST /api/mobile/auth/login.
  final Map<String, dynamic> user;
}

class Unauthenticated extends AuthState {
  const Unauthenticated();
}

class AuthController extends AsyncNotifier<AuthState> {
  @override
  Future<AuthState> build() async {
    final token = await ref.read(tokenStorageProvider).readAccessToken();
    return token != null ? const AuthInitial() : const Unauthenticated();
  }

  /// Thất bại thì state thành AsyncError (DioException 401 = sai email/mật khẩu).
  Future<void> login(String email, String password) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final res = await ref.read(apiClientProvider).post<Map<String, dynamic>>(
        '/api/mobile/auth/login',
        data: {'email': email, 'password': password},
      );
      final data = res.data!;
      await ref.read(tokenStorageProvider).saveTokens(
            accessToken: data['accessToken'] as String,
            refreshToken: data['refreshToken'] as String,
          );
      return Authenticated(data['user'] as Map<String, dynamic>);
    });
  }

  Future<void> logout() async {
    final storage = ref.read(tokenStorageProvider);
    final refreshToken = await storage.readRefreshToken();
    // Best-effort: thu hồi refresh token ở server; lỗi mạng vẫn logout ở máy.
    try {
      await ref.read(apiClientProvider).post<void>(
        '/api/mobile/auth/logout',
        data: {'refreshToken': refreshToken},
      );
    } on DioException {
      // bỏ qua
    }
    await storage.clear();
    state = const AsyncData(Unauthenticated());
  }

  /// API báo refresh token bị từ chối (token đã bị xoá ở ApiClient) — chỉ cập
  /// nhật trạng thái, router tự đưa về /login.
  void sessionExpired() {
    if (state.value is! Unauthenticated) state = const AsyncData(Unauthenticated());
  }
}

final authControllerProvider = AsyncNotifierProvider<AuthController, AuthState>(AuthController.new);

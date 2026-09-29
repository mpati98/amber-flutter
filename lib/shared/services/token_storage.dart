import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

// Lưu cặp JWT của app mobile (thay cho cookie NextAuth bên web).
class TokenStorage {
  final _storage = const FlutterSecureStorage();
  static const _accessKey = 'access_token';
  static const _refreshKey = 'refresh_token';

  // Ghi TUẦN TỰ, không Future.wait: trên web, lần ghi đầu tiên tự sinh khoá
  // AES rồi cất vào localStorage — 2 lần ghi song song mỗi lần sinh 1 khoá
  // riêng, khoá ghi sau đè khoá trước, token còn lại không giải mã được nữa.
  Future<void> saveTokens({required String accessToken, required String refreshToken}) async {
    await _storage.write(key: _accessKey, value: accessToken);
    await _storage.write(key: _refreshKey, value: refreshToken);
  }

  Future<String?> readAccessToken() => _safeRead(_accessKey);

  Future<String?> readRefreshToken() => _safeRead(_refreshKey);

  // Giá trị không giải mã được (khoá mất/đổi — web như trên, Android restore
  // backup sang máy khác...) thì coi như không có token và xoá đi, để luồng
  // refresh/đăng nhập lại tự phục hồi thay vì throw mãi ở mọi request.
  Future<String?> _safeRead(String key) async {
    try {
      return await _storage.read(key: key);
    } catch (_) {
      await _storage.delete(key: key);
      return null;
    }
  }

  Future<void> clear() => Future.wait([
        _storage.delete(key: _accessKey),
        _storage.delete(key: _refreshKey),
      ]);
}

final tokenStorageProvider = Provider<TokenStorage>((ref) => TokenStorage());

import 'package:dio/dio.dart';

/// Kết quả lỗi của các thao tác cần nhập lại mật khẩu (xoá khóa, xoá hẳn).
enum PasswordFailureKind { wrong, locked, notFound, other }

class PasswordFailure {
  const PasswordFailure(this.kind, {this.retryAfterSeconds});

  final PasswordFailureKind kind;

  /// Chỉ có khi [kind] = locked: số giây còn lại trước khi được thử lại.
  final int? retryAfterSeconds;
}

const _fallbackLockSeconds = 15 * 60;

/// Phân loại lỗi từ DELETE /courses/:id và /purge: 403 `wrong_password`, 429 `password_locked`, 404; còn lại → other
/// (lỗi mạng, 5xx, 400...). Chỉ đọc mã và số giây; KHÔNG bao giờ đụng tới mật khẩu.
PasswordFailure classifyPasswordError(Object error) {
  if (error is! DioException) {
    return const PasswordFailure(PasswordFailureKind.other);
  }
  final status = error.response?.statusCode;
  final data = error.response?.data;
  final code = data is Map ? data['error'] : null;
  if (status == 403 && code == 'wrong_password') {
    return const PasswordFailure(PasswordFailureKind.wrong);
  }
  if (status == 429 && code == 'password_locked') {
    final body = data is Map ? data['retryAfterSeconds'] : null;
    final header = int.tryParse(
      error.response?.headers.value('retry-after') ?? '',
    );
    final seconds = body is num ? body.toInt() : header;
    return PasswordFailure(
      PasswordFailureKind.locked,
      retryAfterSeconds: seconds != null && seconds > 0
          ? seconds
          : _fallbackLockSeconds,
    );
  }
  if (status == 404) {
    return const PasswordFailure(PasswordFailureKind.notFound);
  }
  return const PasswordFailure(PasswordFailureKind.other);
}

/// "Nhập sai nhiều lần. Thử lại sau N phút." — N làm tròn lên theo giây, tối thiểu 1.
String lockedMessage(int seconds) {
  final minutes = seconds <= 60 ? 1 : (seconds / 60).ceil();
  return 'Nhập sai nhiều lần. Thử lại sau $minutes phút.';
}

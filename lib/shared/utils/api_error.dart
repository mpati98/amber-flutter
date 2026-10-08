import 'package:dio/dio.dart';

/// Câu báo lỗi cho người dùng: trường `message` (chuỗi) server trả về nếu có,
/// không thì [fallback]. Lỗi validate của backend có dạng `{error: {...}}`
/// (không phải câu cho người đọc) nên rơi về [fallback].
String apiErrorMessage(Object error, String fallback) {
  if (error is DioException) {
    final message = switch (error.response?.data) {
      {'message': final String m} => m.trim(),
      _ => '',
    };
    if (message.isNotEmpty) return message;
  }
  return fallback;
}

/// Mã lỗi máy đọc được của backend: trường `error` khi nó là chuỗi (vd `not_scheduled`,
/// `end_before_start`); null nếu không có (lỗi mạng, hoặc `error` là object validate của zod).
String? apiErrorCode(Object error) {
  if (error is DioException) {
    return switch (error.response?.data) {
      {'error': final String code} => code,
      _ => null,
    };
  }
  return null;
}

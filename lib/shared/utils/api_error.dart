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

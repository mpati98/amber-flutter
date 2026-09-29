import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/services/api_client.dart';

/// POST /api/tang-kinh-cac/upload dùng chung cho ảnh bìa sách và tệp/ảnh của
/// tài liệu — route không phân biệt loại, mọi file vào `tang-kinh-cac/<ts>-<tên>`.
class UploadApi {
  const UploadApi(this._dio);

  final Dio _dio;

  /// Multipart field `file` → `{url}` dạng đường dẫn tương đối
  /// `/api/tang-kinh-cac/blob/...` (cần Bearer để tải — dùng ApiImage/Dio).
  /// Nhận bytes (không phải dart:io File) để chạy được cả trên web.
  Future<String> upload({required Uint8List bytes, required String filename, String? mimeType}) async {
    final res = await _dio.post<Map<String, dynamic>>(
      '/api/tang-kinh-cac/upload',
      data: FormData.fromMap({
        'file': MultipartFile.fromBytes(
          bytes,
          filename: filename,
          contentType: mimeType == null ? null : DioMediaType.parse(mimeType),
        ),
      }),
    );
    return res.data!['url'] as String;
  }
}

final uploadApiProvider = Provider<UploadApi>((ref) => UploadApi(ref.watch(apiClientProvider)));

/// Tên hiển thị từ URL blob: bỏ thư mục và tiền tố timestamp `<ts>-`.
String uploadedFileName(String url) {
  final last = Uri.decodeComponent(url.split('/').last);
  return last.replaceFirst(RegExp(r'^\d+-'), '');
}

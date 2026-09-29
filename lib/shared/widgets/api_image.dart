import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../services/api_client.dart';

// Tải qua Dio (không phải Image.network + header tự gắn) để đi qua interceptor:
// access token chỉ sống 1h, Image.network sẽ 401 vĩnh viễn sau đó vì không
// có ai refresh token cho nó.
final _apiImageBytesProvider = FutureProvider.autoDispose.family<Uint8List, String>((ref, path) async {
  final res = await ref.watch(apiClientProvider).get<List<int>>(
        path,
        options: Options(responseType: ResponseType.bytes),
      );
  return Uint8List.fromList(res.data!);
});

/// Ảnh từ backend cần đăng nhập (vd `/api/tang-kinh-cac/blob/...`). URL tuyệt
/// đối trỏ ra ngoài thì tải thẳng, KHÔNG kèm token (không lộ Bearer cho host lạ).
class ApiImage extends ConsumerWidget {
  const ApiImage(this.url, {super.key, this.fit = BoxFit.cover, required this.placeholder});

  final String url;
  final BoxFit fit;

  /// Hiện khi đang tải hoặc lỗi.
  final Widget placeholder;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (!url.startsWith('/')) {
      return Image.network(url, fit: fit, errorBuilder: (_, _, _) => placeholder);
    }
    return ref.watch(_apiImageBytesProvider(url)).when(
          data: (bytes) => Image.memory(bytes, fit: fit, errorBuilder: (_, _, _) => placeholder),
          loading: () => placeholder,
          error: (_, _) => placeholder,
        );
  }
}

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/services/api_client.dart';
import '../models/highlight.dart';

class HighlightApi {
  const HighlightApi(this._dio);

  final Dio _dio;

  /// Mới nhất trước.
  Future<List<Highlight>> getHighlights(String publicationId) async {
    final res = await _dio.get<List<dynamic>>('/api/tang-kinh-cac/publications/$publicationId/highlights');
    return res.data!.map((e) => Highlight.fromJson(e as Map<String, dynamic>)).toList();
  }

  /// Highlight ngẫu nhiên (đều trên toàn bộ) kèm tên sách/tác giả — thẻ "Ôn lại".
  /// null khi chưa có highlight nào (API trả `null`).
  Future<ResurfacedHighlight?> getRandomHighlight() async {
    final res = await _dio.get<Map<String, dynamic>?>('/api/tang-kinh-cac/highlights/random');
    final data = res.data;
    return data == null ? null : ResurfacedHighlight.fromJson(data);
  }

  /// 400 nếu quote rỗng.
  Future<Highlight> createHighlight(String publicationId, {required String quote, int? page, String? note}) async {
    final res = await _dio.post<Map<String, dynamic>>(
      '/api/tang-kinh-cac/publications/$publicationId/highlights',
      data: {'quote': quote, 'page': page, 'note': ?note},
    );
    return Highlight.fromJson(res.data!);
  }
}

final highlightApiProvider = Provider<HighlightApi>((ref) => HighlightApi(ref.watch(apiClientProvider)));

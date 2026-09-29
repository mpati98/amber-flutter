import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/services/api_client.dart';
import '../models/document.dart';

class DocumentApi {
  const DocumentApi(this._dio);

  final Dio _dio;

  /// Mới cập nhật trước (`updatedAt` giảm dần), mỗi document kèm `topic`.
  /// [search] khớp title hoặc content (LIKE, phân biệt hoa thường — giống web).
  /// [pinned] chỉ lọc được "đã ghim" (backend bỏ qua mọi giá trị khác `true`).
  Future<List<Document>> getDocuments({DocumentType? type, String? search, bool? pinned, String? topicId}) async {
    final res = await _dio.get<List<dynamic>>(
      '/api/tang-kinh-cac/documents',
      queryParameters: {
        if (type != null) 'type': type.apiValue,
        if (search != null && search.isNotEmpty) 'search': search,
        if (pinned == true) 'pinned': 'true',
        'topicId': ?topicId,
      },
    );
    return res.data!.map((e) => Document.fromJson(e as Map<String, dynamic>)).toList();
  }
}

final documentApiProvider = Provider<DocumentApi>((ref) => DocumentApi(ref.watch(apiClientProvider)));

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/services/api_client.dart';
import '../models/publication.dart';

class PublicationApi {
  const PublicationApi(this._dio);

  final Dio _dio;

  /// Mới thêm trước (`dateAdded` giảm dần). [search] khớp title hoặc author
  /// (LIKE, phân biệt hoa thường — giống bản web).
  Future<List<Publication>> getPublications({
    PublicationStatus? status,
    PublicationFormat? format,
    String? search,
  }) async {
    final res = await _dio.get<List<dynamic>>(
      '/api/tang-kinh-cac/publications',
      queryParameters: {
        if (status != null) 'status': status.apiValue,
        if (format != null) 'format': format.apiValue,
        if (search != null && search.isNotEmpty) 'search': search,
      },
    );
    return res.data!.map((e) => Publication.fromJson(e as Map<String, dynamic>)).toList();
  }
}

final publicationApiProvider = Provider<PublicationApi>((ref) => PublicationApi(ref.watch(apiClientProvider)));

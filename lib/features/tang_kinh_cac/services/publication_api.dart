import 'dart:typed_data';

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

  /// Backend tự set `dateStarted` nếu tạo với status READING.
  Future<Publication> createPublication({
    required String title,
    String? author,
    PublicationFormat format = PublicationFormat.physical,
    PublicationStatus status = PublicationStatus.toRead,
    int? totalPages,
    String? coverUrl,
  }) async {
    final res = await _dio.post<Map<String, dynamic>>(
      '/api/tang-kinh-cac/publications',
      data: {
        'title': title,
        if (author != null && author.isNotEmpty) 'author': author,
        'format': format.apiValue,
        'status': status.apiValue,
        'totalPages': ?totalPages,
        'coverUrl': ?coverUrl,
      },
    );
    return Publication.fromJson(res.data!);
  }

  /// Lưu toàn bộ form chi tiết (giống web gửi cả form): mọi field đều được
  /// gửi, null nghĩa là xoá giá trị. Chuỗi rỗng backend tự đổi thành null.
  /// Backend tự cập nhật dateStarted/dateFinished khi status đổi.
  Future<Publication> updatePublication(
    String id, {
    required PublicationStatus status,
    required PublicationFormat format,
    required int? currentPage,
    required int? totalPages,
    required int? rating,
    required String? review,
    required String? notes,
  }) async {
    final res = await _dio.patch<Map<String, dynamic>>(
      '/api/tang-kinh-cac/publications/$id',
      data: {
        'status': status.apiValue,
        'format': format.apiValue,
        'currentPage': currentPage,
        'totalPages': totalPages,
        'rating': rating,
        'review': review,
        'notes': notes,
      },
    );
    return Publication.fromJson(res.data!);
  }

  /// Highlight của sách bị xoá theo (cascade). File ảnh bìa trên Vercel Blob
  /// thì KHÔNG bị xoá — backend chưa có route xoá blob (web cũng vậy).
  Future<void> deletePublication(String id) => _dio.delete<void>('/api/tang-kinh-cac/publications/$id');

  /// POST /upload (multipart, field `file`) → `{url}` dạng đường dẫn tương đối
  /// `/api/tang-kinh-cac/blob/...`, dùng làm coverUrl và tải qua ApiImage.
  /// Nhận bytes (không phải dart:io File) để chạy được cả trên web.
  Future<String> uploadCover({required Uint8List bytes, required String filename, String? mimeType}) async {
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

final publicationApiProvider = Provider<PublicationApi>((ref) => PublicationApi(ref.watch(apiClientProvider)));

import 'dart:typed_data';

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

  /// Backend trả 400 nếu TEXT/CHECKLIST/MINDMAP thiếu [content] hoặc
  /// IMAGE/FILE thiếu [attachmentUrl].
  Future<Document> createDocument({
    required String title,
    required DocumentType type,
    String? content,
    String? attachmentUrl,
    String? sourceUrl,
    String? topicId,
  }) async {
    final res = await _dio.post<Map<String, dynamic>>(
      '/api/tang-kinh-cac/documents',
      data: {
        'title': title,
        'type': type.apiValue,
        'content': ?content,
        'attachmentUrl': ?attachmentUrl,
        'sourceUrl': ?sourceUrl,
        'topicId': ?topicId,
      },
    );
    return Document.fromJson(res.data!);
  }

  /// PATCH từng phần: chỉ gửi field khác null. Muốn xoá giá trị thì truyền
  /// chuỗi rỗng (backend đổi `""` thành null). Backend luôn bump `updatedAt`.
  Future<Document> updateDocument(
    String id, {
    String? title,
    String? content,
    String? attachmentUrl,
    List<String>? tags,
    bool? pinned,
    String? sourceUrl,
    String? topicId,
  }) async {
    final res = await _dio.patch<Map<String, dynamic>>(
      '/api/tang-kinh-cac/documents/$id',
      data: {
        'title': ?title,
        'content': ?content,
        'attachmentUrl': ?attachmentUrl,
        'tags': ?tags,
        'pinned': ?pinned,
        'sourceUrl': ?sourceUrl,
        'topicId': ?topicId,
      },
    );
    return Document.fromJson(res.data!);
  }

  Future<Document> togglePin(String id, bool pinned) => updateDocument(id, pinned: pinned);

  /// File đính kèm trên Vercel Blob KHÔNG bị xoá theo (backend chưa có route xoá blob).
  Future<void> deleteDocument(String id) => _dio.delete<void>('/api/tang-kinh-cac/documents/$id');

  /// Tải file đính kèm (route blob cần Bearer) — dùng để mở tệp FILE.
  Future<({Uint8List bytes, String? mimeType})> downloadAttachment(String url) async {
    final res = await _dio.get<List<int>>(url, options: Options(responseType: ResponseType.bytes));
    return (bytes: Uint8List.fromList(res.data!), mimeType: res.headers.value(Headers.contentTypeHeader));
  }
}

final documentApiProvider = Provider<DocumentApi>((ref) => DocumentApi(ref.watch(apiClientProvider)));

import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/services/api_client.dart';
import '../../../shared/services/token_storage.dart';
import '../models/music_track.dart';

const musicMaxFileBytes = 50 * 1024 * 1024;

class MusicUploadResult {
  const MusicUploadResult({required this.url, required this.pathname});

  final String url;
  final String pathname;
}

class MusicApi {
  MusicApi(this._dio, this._tokenStorage, {Dio? blobDio})
    : _blobDio = blobDio ?? Dio();

  final Dio _dio;
  final Dio _blobDio;

  /// Token tạm chỉ có quyền ghi một tệp MP3 trong thư mục của user này.
  final TokenStorage _tokenStorage;

  Future<List<MusicTrack>> getTracks() async {
    final response = await _dio.get<List<dynamic>>('/api/music/tracks');
    return (response.data ?? const [])
        .map((item) => MusicTrack.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  Future<MusicTrack> createTrack({
    required String title,
    required String? artist,
    required MusicUploadResult upload,
    required int? durationSeconds,
    required int sizeBytes,
  }) async {
    final response = await _dio.post<Map<String, dynamic>>(
      '/api/music/tracks',
      data: {
        'title': title,
        'artist': artist,
        'blobUrl': upload.url,
        'blobPathname': upload.pathname,
        'durationSeconds': durationSeconds,
        'sizeBytes': sizeBytes,
      },
    );
    return MusicTrack.fromJson(response.data!);
  }

  Future<MusicTrack> updateTrack(
    String id, {
    String? title,
    required String? artist,
    int? position,
  }) async {
    final response = await _dio.patch<Map<String, dynamic>>(
      '/api/music/tracks/$id',
      data: {'title': ?title, 'artist': artist, 'position': ?position},
    );
    return MusicTrack.fromJson(response.data!);
  }

  Future<void> deleteTrack(String id) =>
      _dio.delete<void>('/api/music/tracks/$id');

  Future<MusicUploadResult> uploadMp3({
    required Uint8List bytes,
    required String fileName,
    required String userId,
    required void Function(int sent, int total) onProgress,
  }) async {
    if (bytes.isEmpty || bytes.length > musicMaxFileBytes) {
      throw ArgumentError('Tệp MP3 phải có dung lượng từ 1 byte đến 50 MiB.');
    }
    final safeName = _sanitizeFileName(fileName);
    if (!safeName.toLowerCase().endsWith('.mp3')) {
      throw ArgumentError('Chỉ nhận tệp MP3.');
    }

    final uniqueName =
        '${DateTime.now().microsecondsSinceEpoch}-${Random.secure().nextInt(1 << 32)}-$safeName';
    final pathname = 'music/$userId/$uniqueName';
    final accessToken = await _tokenStorage.readAccessToken();
    if (accessToken == null) throw StateError('Phiên đăng nhập đã hết hạn.');

    final tokenResponse = await _dio.post<Map<String, dynamic>>(
      '/api/music/upload',
      data: {
        'type': 'blob.generate-client-token',
        'payload': {
          'pathname': pathname,
          'multipart': false,
          'clientPayload': null,
        },
      },
    );
    final clientToken = tokenResponse.data?['clientToken'];
    if (clientToken is! String ||
        !clientToken.startsWith('vercel_blob_client_')) {
      throw StateError('Máy chủ không cấp được quyền tải tệp MP3.');
    }
    final tokenParts = clientToken.split('_');
    if (tokenParts.length < 5 || tokenParts[3].isEmpty) {
      throw StateError('Token tải tệp không hợp lệ.');
    }
    final storeId = tokenParts[3];
    final uploadUrl = Uri.https('vercel.com', '/api/blob/', {
      'pathname': pathname,
    });
    final requestId =
        '$storeId:${DateTime.now().millisecondsSinceEpoch}:${Random.secure().nextInt(1 << 32).toRadixString(16)}';
    final blobResponse = await _blobDio.put<Map<String, dynamic>>(
      uploadUrl.toString(),
      data: bytes,
      onSendProgress: onProgress,
      options: Options(
        contentType: 'application/octet-stream',
        headers: {
          'Authorization': 'Bearer $clientToken',
          'x-vercel-blob-store-id': storeId,
          'x-api-blob-request-id': requestId,
          'x-api-blob-request-attempt': '0',
          'x-api-version': '12',
          'x-content-length': '${bytes.length}',
          'x-vercel-blob-access': 'private',
          'x-content-type': 'audio/mpeg',
        },
      ),
    );
    final data = blobResponse.data;
    if (data == null || data['url'] is! String || data['pathname'] is! String) {
      throw StateError('Blob không trả về URL/pathname hợp lệ.');
    }
    return MusicUploadResult(
      url: data['url'] as String,
      pathname: data['pathname'] as String,
    );
  }

  /// JWT chỉ được giải mã để tạo pathname; quyền vẫn được kiểm tra ở backend.
  Future<String> currentUserId() async {
    final token = await _tokenStorage.readAccessToken();
    if (token == null) throw StateError('Phiên đăng nhập đã hết hạn.');
    final parts = token.split('.');
    if (parts.length != 3) throw StateError('Token đăng nhập không hợp lệ.');
    try {
      final payload = jsonDecode(
        utf8.decode(base64Url.decode(base64Url.normalize(parts[1]))),
      ) as Map<String, dynamic>;
      final subject = payload['sub'];
      if (subject is! String || subject.isEmpty) {
        throw StateError('Token đăng nhập thiếu user id.');
      }
      return subject;
    } on FormatException {
      throw StateError('Token đăng nhập không hợp lệ.');
    }
  }

  String _sanitizeFileName(String raw) {
    var name = raw
        .split(RegExp(r'[/\\]'))
        .last
        .replaceAll(RegExp(r'[^a-zA-Z0-9._-]'), '_')
        .replaceAll(RegExp(r'\.{2,}'), '_');
    name = name.replaceFirst(RegExp(r'^\.+'), '');
    if (name.length > 100) {
      final dot = name.lastIndexOf('.');
      final extension = dot > 0 && name.length - dot <= 10
          ? name.substring(dot)
          : '';
      name = '${name.substring(0, 100 - extension.length)}$extension';
    }
    return name.isEmpty ? 'file.mp3' : name;
  }
}

final musicApiProvider = Provider<MusicApi>(
  (ref) =>
      MusicApi(ref.watch(apiClientProvider), ref.watch(tokenStorageProvider)),
);

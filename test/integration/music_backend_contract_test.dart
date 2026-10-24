import 'dart:typed_data';

import 'package:amber_flutter/features/kieu_lau/services/music_api.dart';
import 'package:amber_flutter/shared/services/token_storage.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

// Contract test với amber-v4 DEV. Ghi file thật lên Blob rồi tự xoá track:
//
//   flutter test test/integration/music_backend_contract_test.dart \
//     --dart-define=MUSIC_API_BASE_URL=http://localhost:3000 \
//     --dart-define=MUSIC_API_TOKEN=<access token của user trên dev>
//
// Không bao giờ chạy với API production.
const _baseUrl = String.fromEnvironment('MUSIC_API_BASE_URL');
const _token = String.fromEnvironment('MUSIC_API_TOKEN');
const _productionHosts = {'api.duangmai.io.vn', 'amber.duangmai.io.vn'};

class _FixedTokenStorage extends TokenStorage {
  _FixedTokenStorage(this.token);

  final String token;

  @override
  Future<String?> readAccessToken() async => token;
}

void main() {
  final missing = _baseUrl.isEmpty || _token.isEmpty;
  final host = Uri.tryParse(_baseUrl)?.host.toLowerCase() ?? '';
  final isProduction = _productionHosts.contains(host);

  if (isProduction) {
    test('music contract test từ chối backend production', () {
      fail('Từ chối chạy contract test trên $host. Chỉ dùng backend DEV.');
    });
    return;
  }

  test(
    'nhạc: upload → tạo → list có streamUrl → đổi tên → xoá (backend thật)',
    () async {
      final dio = Dio(
        BaseOptions(
          baseUrl: _baseUrl,
          headers: {'Authorization': 'Bearer $_token'},
        ),
      );
      final api = MusicApi(dio, _FixedTokenStorage(_token));
      final bytes = Uint8List.fromList([
        0x49,
        0x44,
        0x33,
        0x04,
        0x00,
        0x00,
        0x00,
        0x00,
        0x00,
        0x00,
      ]);
      final suffix = DateTime.now().millisecondsSinceEpoch;
      String? trackId;

      try {
        final userId = await api.currentUserId();
        final blob = await api.uploadMp3(
          bytes: bytes,
          fileName: 'music-contract-$suffix.mp3',
          userId: userId,
          onProgress: (_, _) {},
        );
        final created = await api.createTrack(
          title: 'TEST nhạc $suffix',
          artist: 'Nghệ sĩ thử',
          upload: blob,
          durationSeconds: 1,
          sizeBytes: bytes.length,
        );
        trackId = created.id;
        expect(created.position, greaterThanOrEqualTo(0));

        final listed = await api.getTracks();
        final listedTrack = listed
            .where((track) => track.id == created.id)
            .single;
        expect(
          listedTrack.streamUrl,
          contains('/api/music/tracks/${created.id}/stream?token='),
        );
        expect(listedTrack.blobUrl, blob.url);

        final renamed = await api.updateTrack(
          created.id,
          title: 'TEST đã đổi $suffix',
          artist: null,
        );
        expect(renamed.title, 'TEST đã đổi $suffix');
        expect(renamed.artist, isNull);

        await api.deleteTrack(created.id);
        trackId = null;
        expect(
          (await api.getTracks()).any((track) => track.id == created.id),
          isFalse,
        );
      } finally {
        if (trackId != null) await api.deleteTrack(trackId);
        dio.close(force: true);
      }
    },
    skip: missing
        ? 'Cần MUSIC_API_BASE_URL và MUSIC_API_TOKEN của backend DEV.'
        : null,
  );
}

import 'dart:convert';
import 'dart:typed_data';

import 'package:amber_flutter/features/kieu_lau/utils/mp3_metadata.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('mp3Title', () {
    test('ưu tiên tiêu đề ID3v2', () {
      final title = utf8.encode('Bài thử');
      final frame = <int>[
        ...ascii.encode('TIT2'),
        0,
        0,
        0,
        title.length + 1,
        0,
        0,
        3,
        ...title,
      ];
      final tagSize = frame.length;
      final bytes = Uint8List.fromList([
        ...ascii.encode('ID3'),
        3,
        0,
        0,
        0,
        0,
        0,
        tagSize,
        ...frame,
      ]);
      expect(mp3Title(bytes, 'ten-file.mp3'), 'Bài thử');
    });

    test('dùng tiêu đề ID3v1 khi không có ID3v2', () {
      final bytes = Uint8List(128)..setRange(0, 3, ascii.encode('TAG'));
      bytes.setRange(3, 3 + 5, latin1.encode('Title'));
      expect(mp3Title(bytes, 'file.mp3'), 'Title');
    });

    test('fallback sang tên tệp khi thiếu thẻ tiêu đề', () {
      expect(
        mp3Title(Uint8List(16), 'my-favorite_song.MP3'),
        'my favorite song',
      );
    });
  });
}

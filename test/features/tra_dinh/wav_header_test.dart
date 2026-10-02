import 'dart:typed_data';

import 'package:amber_flutter/features/tra_dinh/utils/wav_header.dart';
import 'package:flutter_test/flutter_test.dart';

/// WAV giống Groq: RIFF=0xFFFFFFFF, fmt 16 byte (PCM mono 24kHz 16-bit),
/// data=0xFFFFFFFF, rồi [samples] byte âm thanh.
Uint8List _streamingWav(int samples, {List<int> extraChunk = const []}) {
  final b = BytesBuilder();
  void u32(int v) => b.add((ByteData(4)..setUint32(0, v, Endian.little)).buffer.asUint8List());
  void u16(int v) => b.add((ByteData(2)..setUint16(0, v, Endian.little)).buffer.asUint8List());
  b.add('RIFF'.codeUnits);
  u32(0xFFFFFFFF);
  b.add('WAVE'.codeUnits);
  b.add('fmt '.codeUnits);
  u32(16);
  u16(1); // PCM
  u16(1); // mono
  u32(24000);
  u32(48000);
  u16(2);
  u16(16);
  b.add(extraChunk);
  b.add('data'.codeUnits);
  u32(0xFFFFFFFF);
  b.add(Uint8List(samples));
  return b.toBytes();
}

int _u32(Uint8List b, int at) => ByteData.sublistView(b).getUint32(at, Endian.little);

void main() {
  test('điền kích thước RIFF và data thật thay cho 0xFFFFFFFF', () {
    final wav = _streamingWav(1000);
    final fixed = fixWavSizes(wav);
    expect(fixed.length, wav.length);
    expect(_u32(fixed, 4), wav.length - 8);
    expect(_u32(fixed, 40), 1000); // data size ở offset 40 khi chỉ có fmt
    expect(fixed.sublist(44), wav.sublist(44)); // dữ liệu âm thanh không đổi
    expect(_u32(wav, 4), 0xFFFFFFFF); // không sửa trên bytes gốc
  });

  test('có chunk phụ trước data (số byte lẻ + đệm) vẫn tìm đúng data', () {
    // chunk "LIST" 3 byte + 1 byte đệm
    final extra = [...'LIST'.codeUnits, 3, 0, 0, 0, 1, 2, 3, 0];
    final fixed = fixWavSizes(_streamingWav(500, extraChunk: extra));
    expect(_u32(fixed, 36 + extra.length + 4), 500);
  });

  test('WAV đã đúng kích thước: giữ nguyên số liệu', () {
    final good = fixWavSizes(_streamingWav(200));
    final again = fixWavSizes(good);
    expect(_u32(again, 4), _u32(good, 4));
    expect(_u32(again, 40), 200);
  });

  test('không phải WAV: trả nguyên', () {
    final mp3 = Uint8List.fromList([0x49, 0x44, 0x33, 4, 0, 0, 0, 0, 0, 0, 0, 0, 1, 2]);
    expect(identical(fixWavSizes(mp3), mp3), isTrue);
  });
}

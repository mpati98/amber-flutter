import 'dart:typed_data';

/// Groq TTS trả WAV kiểu "streaming": kích thước RIFF và chunk `data` ghi là
/// 0xFFFFFFFF (chưa biết độ dài lúc bắt đầu gửi). Trình phát mỗi nền tảng xử lý
/// khác nhau — ExoPlayer cắt về độ dài input, còn AVPlayer (iOS/macOS) có lịch
/// sử từ chối WAV không chuẩn. Đã có đủ bytes thì điền lại kích thước thật cho
/// chắc. Không phải WAV / đã chuẩn → trả nguyên.
Uint8List fixWavSizes(Uint8List bytes) {
  if (bytes.length < 12 || _tag(bytes, 0) != 'RIFF' || _tag(bytes, 8) != 'WAVE') return bytes;
  final out = Uint8List.fromList(bytes);
  final view = ByteData.sublistView(out);
  view.setUint32(4, out.length - 8, Endian.little);

  var pos = 12;
  while (pos + 8 <= out.length) {
    final size = view.getUint32(pos + 4, Endian.little);
    if (_tag(out, pos) == 'data') {
      final available = out.length - (pos + 8);
      if (size > available) view.setUint32(pos + 4, available, Endian.little);
      break;
    }
    pos += 8 + size + (size.isOdd ? 1 : 0); // chunk lẻ có 1 byte đệm
  }
  return out;
}

String _tag(Uint8List b, int at) => String.fromCharCodes(b.sublist(at, at + 4));

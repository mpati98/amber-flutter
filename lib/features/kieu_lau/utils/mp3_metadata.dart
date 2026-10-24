import 'dart:convert';
import 'dart:typed_data';

String mp3Title(Uint8List bytes, String fileName) {
  final id3Title = _readId3v2Title(bytes) ?? _readId3v1Title(bytes);
  if (id3Title != null && id3Title.trim().isNotEmpty) return id3Title.trim();
  final withoutExtension = fileName.replaceFirst(
    RegExp(r'\.mp3$', caseSensitive: false),
    '',
  );
  return withoutExtension.replaceAll(RegExp(r'[_-]+'), ' ').trim();
}

String? _readId3v2Title(Uint8List bytes) {
  if (bytes.length < 10 ||
      ascii.decode(bytes.sublist(0, 3), allowInvalid: true) != 'ID3') {
    return null;
  }
  final majorVersion = bytes[3];
  if (majorVersion < 2 || majorVersion > 4) return null;

  final tagSize = _syncSafe(bytes, 6);
  var offset = 10 + ((bytes[5] & 0x40) != 0 ? 4 : 0);
  final end = (10 + tagSize).clamp(offset, bytes.length);
  while (offset + 6 <= end) {
    final frameIdLength = majorVersion == 2 ? 3 : 4;
    if (offset + frameIdLength + (majorVersion == 2 ? 3 : 6) > end) break;
    final frameId = ascii.decode(
      bytes.sublist(offset, offset + frameIdLength),
      allowInvalid: true,
    );
    if (frameId.trim().isEmpty) break;
    final size = majorVersion == 2
        ? (bytes[offset + 3] << 16) |
              (bytes[offset + 4] << 8) |
              bytes[offset + 5]
        : majorVersion == 4
        ? _syncSafe(bytes, offset + 4)
        : (bytes[offset + 4] << 24) |
              (bytes[offset + 5] << 16) |
              (bytes[offset + 6] << 8) |
              bytes[offset + 7];
    final headerSize = frameIdLength + (majorVersion == 2 ? 3 : 6);
    final dataStart = offset + headerSize;
    final dataEnd = dataStart + size;
    if (size <= 0 || dataEnd > end) break;
    if (frameId == 'TIT2' || frameId == 'TT2') {
      return _decodeTextFrame(bytes.sublist(dataStart, dataEnd));
    }
    offset = dataEnd;
  }
  return null;
}

int _syncSafe(Uint8List bytes, int offset) =>
    (bytes[offset] << 21) |
    (bytes[offset + 1] << 14) |
    (bytes[offset + 2] << 7) |
    bytes[offset + 3];

String? _decodeTextFrame(Uint8List frame) {
  if (frame.length < 2) return null;
  final encoding = frame[0];
  final data = frame.sublist(1);
  if (encoding == 0) {
    return latin1
        .decode(data, allowInvalid: true)
        .replaceAll('\u0000', '')
        .trim();
  }
  if (encoding == 3) {
    return utf8
        .decode(data, allowMalformed: true)
        .replaceAll('\u0000', '')
        .trim();
  }

  final littleEndian =
      encoding == 1 && data.length >= 2 && data[0] == 0xff && data[1] == 0xfe;
  final start =
      encoding == 1 && data.length >= 2 && (data[0] == 0xff || data[0] == 0xfe)
      ? 2
      : 0;
  final units = <int>[];
  for (var i = start; i + 1 < data.length; i += 2) {
    units.add(
      littleEndian
          ? data[i] | (data[i + 1] << 8)
          : (data[i] << 8) | data[i + 1],
    );
  }
  return String.fromCharCodes(units).replaceAll('\u0000', '').trim();
}

String? _readId3v1Title(Uint8List bytes) {
  if (bytes.length < 128) return null;
  final start = bytes.length - 128;
  if (ascii.decode(bytes.sublist(start, start + 3), allowInvalid: true) !=
      'TAG') {
    return null;
  }
  return latin1
      .decode(bytes.sublist(start + 3, start + 33), allowInvalid: true)
      .replaceAll('\u0000', '')
      .trim();
}

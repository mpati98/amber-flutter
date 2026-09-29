/// Cột timestamp của Tàng Kinh Các (Prisma cũ, `mode: "string"` bên Drizzle)
/// trả về dạng `"2026-09-20 11:01:44.321"` — KHÔNG có `T`, KHÔNG có múi giờ.
/// Giá trị thật là UTC (DB chạy GMT, backend ghi bằng `toISOString()`), nhưng
/// `DateTime.parse` sẽ hiểu chuỗi thiếu múi giờ là giờ địa phương → lệch 7 tiếng
/// ở VN. Luôn parse qua đây.
DateTime parseDbTimestamp(String raw) {
  final iso = raw.contains('T') ? raw : raw.replaceFirst(' ', 'T');
  final hasZone = iso.endsWith('Z') || RegExp(r'[+-]\d{2}(:?\d{2})?$').hasMatch(iso);
  return DateTime.parse(hasZone ? iso : '${iso}Z');
}

DateTime? parseDbTimestampOrNull(Object? raw) => raw == null ? null : parseDbTimestamp(raw as String);

/// Backend luôn parse `tags` (chuỗi JSON trong DB) thành mảng trước khi trả về.
List<String> parseTags(Object? raw) => raw == null ? const [] : (raw as List<dynamic>).cast<String>();

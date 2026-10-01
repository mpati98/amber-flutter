/// Tổng số phút → "1h 30p" / "45p" / "2h".
///
/// Sửa lỗi bên web (hoc-tap): web dùng `Math.round(phút / 60)` cho phần giờ
/// nên 90 phút hiện "2h 30p" (round(1.5) = 2). Phần giờ phải là chia lấy
/// nguyên (floor), phần dư mới là phút.
String formatDuration(int totalMinutes) {
  final h = totalMinutes ~/ 60;
  final m = totalMinutes % 60;
  if (h == 0) return '${m}p';
  if (m == 0) return '${h}h';
  return '${h}h ${m}p';
}

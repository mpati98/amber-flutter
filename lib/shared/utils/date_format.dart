/// "2026-10-14" → "14/10". Chuỗi không đúng "YYYY-MM-DD" trả nguyên văn.
String formatDayMonth(String isoDate) {
  final m = RegExp(r'^\d{4}-(\d{2})-(\d{2})$').firstMatch(isoDate);
  return m == null ? isoDate : '${m.group(2)}/${m.group(1)}';
}

/// Khoảng ngày của dự án (đầu vào "YYYY-MM-DD" hoặc null):
/// cả hai → "dd/MM – dd/MM"; chỉ bắt đầu → "Từ dd/MM"; chỉ hạn → "Hạn dd/MM"; không có → "Chưa có ngày".
String formatDateRange(String? start, String? end) {
  if (start != null && end != null) return '${formatDayMonth(start)} – ${formatDayMonth(end)}';
  if (start != null) return 'Từ ${formatDayMonth(start)}';
  if (end != null) return 'Hạn ${formatDayMonth(end)}';
  return 'Chưa có ngày';
}

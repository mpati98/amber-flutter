// Tính ngày cho tab Lịch. Mọi ngày là chuỗi "YYYY-MM-DD" (lịch VN), tính trên UTC để không dính múi giờ máy.

DateTime parseDay(String iso) {
  final p = iso.split('-');
  return DateTime.utc(int.parse(p[0]), int.parse(p[1]), int.parse(p[2]));
}

String formatIso(DateTime d) => '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

/// "YYYY-MM-DD" hợp lệ (có kiểm tra ngày thật, 2026-02-30 bị loại).
bool isValidIso(String? iso) {
  if (iso == null || !RegExp(r'^\d{4}-\d{2}-\d{2}$').hasMatch(iso)) return false;
  return formatIso(parseDay(iso)) == iso;
}

String addDays(String iso, int days) => formatIso(parseDay(iso).add(Duration(days: days)));

/// Thứ của ngày: 1 = thứ Hai … 7 = Chủ nhật.
int isoWeekdayOf(String iso) => parseDay(iso).weekday;

/// Thứ Hai của tuần chứa [iso].
String mondayOf(String iso) => addDays(iso, 1 - isoWeekdayOf(iso));

/// Số ngày từ [a] tới [b] (b − a).
int daysBetween(String a, String b) => parseDay(b).difference(parseDay(a)).inDays;

/// Tuần (thứ Hai–Chủ nhật) chứa [iso].
({String from, String to}) weekRange(String iso) {
  final mon = mondayOf(iso);
  return (from: mon, to: addDays(mon, 6));
}

/// Ngày 1 của tháng cách [iso] [months] tháng (âm = lùi).
String firstOfMonth(String iso, [int months = 0]) {
  final d = parseDay(iso);
  return formatIso(DateTime.utc(d.year, d.month + months, 1));
}

/// Lưới tháng chứa [iso]: từ thứ Hai của tuần chứa ngày 1 tới Chủ nhật của tuần chứa ngày cuối tháng (35 hoặc 42 ngày;
/// 28 ngày khi tháng 2 bắt đầu thứ Hai). [monthStart] / [monthEnd] là ngày đầu / cuối của chính tháng.
({String from, String to, String monthStart, String monthEnd}) monthGrid(String iso) {
  final start = firstOfMonth(iso);
  final end = addDays(firstOfMonth(iso, 1), -1);
  return (from: mondayOf(start), to: addDays(mondayOf(end), 6), monthStart: start, monthEnd: end);
}

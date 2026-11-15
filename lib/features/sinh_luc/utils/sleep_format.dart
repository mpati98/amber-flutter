/// 450 → "7 giờ 30", 420 → "7 giờ", 45 → "45 phút".
String sleepDuration(int minutes) {
  final h = minutes ~/ 60, m = minutes % 60;
  if (h == 0) return '$m phút';
  return m == 0 ? '$h giờ' : '$h giờ ${m.toString().padLeft(2, '0')}';
}

const sleepQualityLabels = {1: 'Rất tệ', 2: 'Tệ', 3: 'Bình thường', 4: 'Tốt', 5: 'Rất tốt'};

/// Ô giờ + ô phút của form → tổng phút (0–1440), hoặc câu lỗi tiếng Việt.
({int? minutes, String? error}) parseSleepInput(String hours, String minutes) {
  final h = int.tryParse(hours.trim().isEmpty ? '0' : hours.trim());
  final m = int.tryParse(minutes.trim().isEmpty ? '0' : minutes.trim());
  if (h == null || m == null || h < 0 || m < 0) return (minutes: null, error: 'Giờ và phút phải là số không âm.');
  if (m >= 60) return (minutes: null, error: 'Phút phải nhỏ hơn 60.');
  final total = h * 60 + m;
  if (total == 0) return (minutes: null, error: 'Nhập số giờ đã ngủ.');
  if (total > 1440) return (minutes: null, error: 'Không quá 24 giờ.');
  return (minutes: total, error: null);
}

/// "2026-11-15" → "15/11"
String shortDate(String iso) => iso.length == 10 ? '${iso.substring(8, 10)}/${iso.substring(5, 7)}' : iso;

/// Ngày trước [iso] n ngày, dạng "YYYY-MM-DD".
String isoMinusDays(String iso, int n) {
  final d = DateTime.utc(int.parse(iso.substring(0, 4)), int.parse(iso.substring(5, 7)), int.parse(iso.substring(8, 10))).subtract(Duration(days: n));
  return '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
}

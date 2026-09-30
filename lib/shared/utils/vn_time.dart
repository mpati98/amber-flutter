// Lịch theo giờ Việt Nam (UTC+7, không có giờ mùa hè) — đối ứng src/lib/vn-time.ts
// bên backend, để "hôm nay"/"giờ" trong app khớp với cách server tính, không
// phụ thuộc múi giờ đang cài trên máy.

const _vnOffset = Duration(hours: 7);

/// DateTime UTC đã dịch +7h: đọc .year/.month/.day/.hour sẽ ra giờ VN.
DateTime vnNow([DateTime? at]) => (at ?? DateTime.now()).toUtc().add(_vnOffset);

/// "YYYY-MM-DD" theo lịch VN — so sánh trực tiếp được với các cột `date` của API.
String vnToday([DateTime? at]) {
  final d = vnNow(at);
  return '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
}

/// Giờ hiện tại (0–23) theo giờ VN.
int vnHour([DateTime? at]) => vnNow(at).hour;

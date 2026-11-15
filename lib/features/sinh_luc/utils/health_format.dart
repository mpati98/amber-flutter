import '../../../shared/utils/api_error.dart';
import '../../../shared/utils/vn_time.dart';
import '../models/health_inputs.dart';
import 'sleep_format.dart';

/// Tự chấm thể lực buổi trưa (1–5).
const staminaSelfLabels = {1: 'Kiệt sức', 2: 'Mệt', 3: 'Bình thường', 4: 'Khoẻ', 5: 'Rất khoẻ'};

/// Mức debuff → [tên, điểm Sức khoẻ bị trừ] (khớp `health.debuff` trong bộ luật mặc định).
const debuffLevels = {'light': ('Nhẹ', 10), 'medium': ('Vừa', 25), 'heavy': ('Nặng', 40)};

String debuffLevelLabel(String level) {
  final l = debuffLevels[level];
  return l == null ? level : '${l.$1} (−${l.$2})';
}

/// Phút nhập tay: trống = null (không ghi), số nguyên 0–1440. Trả (giá trị, lỗi).
({int? minutes, String? error}) parseOptionalMinutes(String raw, String what) {
  final s = raw.trim();
  if (s.isEmpty) return (minutes: null, error: null);
  final n = int.tryParse(s);
  if (n == null || n < 0 || n > 1440) return (minutes: null, error: '$what phải là số phút từ 0 đến 1440.');
  return (minutes: n, error: null);
}

/// Dòng tóm tắt một check-in tối.
String eveningSummary(CheckIn c) {
  if (c.restDay) return 'Ngày nghỉ';
  final parts = [
    if (c.exerciseMinutes != null) '${c.exerciseMinutes} phút tập',
    if (c.sportMinutes != null) '${c.sportMinutes} phút thể thao',
  ];
  return parts.isEmpty ? 'Không vận động' : parts.join(' · ');
}

String checkInTitle(CheckIn c) =>
    c.isNoon ? '${shortDate(c.date)} · Trưa · ${staminaSelfLabels[c.staminaSelf] ?? '–'}' : '${shortDate(c.date)} · Tối · ${eveningSummary(c)}';

/// "dd/MM HH:mm" theo giờ VN.
String vnShortDateTime(DateTime at) {
  final v = vnNow(at);
  String two(int x) => x.toString().padLeft(2, '0');
  return '${two(v.day)}/${two(v.month)} ${two(v.hour)}:${two(v.minute)}';
}

String debuffTitle(Debuff d) => d.label ?? 'Debuff ${debuffLevels[d.level]?.$1.toLowerCase() ?? d.level}';

String debuffSubtitle(Debuff d) => [
  debuffLevelLabel(d.level),
  'từ ${vnShortDateTime(d.startedAt)}',
  if (d.endedAt != null) 'đến ${vnShortDateTime(d.endedAt!)}' else if (d.active) 'đang có',
].join(' · ');

/// Câu lỗi cho mã lỗi của các route check-in / debuff.
String healthInputError(Object e, String fallback) => switch (apiErrorCode(e)) {
  'future_date' => 'Không ghi được cho ngày trong tương lai.',
  'too_old' => 'Chỉ ghi được trong 60 ngày gần nhất.',
  'future_start' => 'Thời điểm bắt đầu chưa tới.',
  'future_end' => 'Thời điểm khỏi chưa tới.',
  'ended_before_started' => 'Thời điểm khỏi phải sau lúc bắt đầu.',
  'checkin_not_found' || 'debuff_not_found' => 'Mục này đã bị xoá. Kéo xuống để tải lại.',
  _ => apiErrorMessage(e, fallback),
};

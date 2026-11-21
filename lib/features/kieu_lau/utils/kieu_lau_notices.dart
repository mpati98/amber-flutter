import '../models/activity_log_entry.dart';
import '../models/alert.dart';
import '../services/kieu_lau_api.dart';
import 'activity_groups.dart';

/// Dòng thông báo chung của popup Kiều Lâu trên cảnh 3D (`setTowerNotices('kieulau', …)`), cùng nguồn với màn Kiều Lâu
/// (GET /api/kieu-lau/notifications):
/// 1. số mục cần chú ý (khung "Cần chú ý") — bỏ nếu 0;
/// 2. mục cần chú ý đầu tiên (tiêu đề · chi tiết);
/// 3. hoạt động mới nhất (nhóm đầu của [groupActivity], như dòng đầu khung "Hoạt động").
/// Không có cảnh báo lẫn hoạt động → `[]` (popup hiện "Mọi thứ ổn."). Dạng `{text, lvl}` của cảnh.
List<Map<String, Object?>> buildKieuLauNotices({required List<Alert> alerts, required List<ActivityLogEntry> activity}) {
  final out = <Map<String, Object?>>[];
  if (alerts.isNotEmpty) {
    out.add({'text': '${alerts.length} mục cần chú ý', 'lvl': 'bad'});
    final a = alerts.first;
    out.add({'text': a.detail == null ? a.title : '${a.title} · ${a.detail}', 'lvl': 'warn'});
  }
  final latest = groupActivity(activity).firstOrNull;
  if (latest != null) out.add({'text': 'Mới nhất: ${latest.title} · ${latest.subtitle}', 'lvl': 'info'});
  return out;
}

/// Tải thông báo rồi [buildKieuLauNotices]. Lỗi thì ném — WorldFeeder bỏ phần Kiều Lâu của lần nạp đó.
Future<List<Map<String, Object?>>> fetchKieuLauNotices(KieuLauApi api) async {
  final n = await api.getNotifications();
  return buildKieuLauNotices(alerts: n.alerts, activity: n.recentActivity);
}

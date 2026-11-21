import 'package:amber_flutter/features/kieu_lau/models/activity_log_entry.dart';
import 'package:amber_flutter/features/kieu_lau/models/alert.dart';
import 'package:amber_flutter/features/kieu_lau/utils/kieu_lau_notices.dart';
import 'package:flutter_test/flutter_test.dart';

// Dòng thông báo của popup Kiều Lâu trên cảnh 3D: cùng nguồn với màn Kiều Lâu (cảnh báo + hoạt động gần đây).

ActivityLogEntry _e(String source, String action, String title, int day, [int hour = 12]) =>
    ActivityLogEntry(id: '$title$day$hour', source: source, action: action, title: title, createdAt: DateTime.utc(2026, 11, day, hour - 7));

void main() {
  test('số mục cần chú ý → mục đầu (tiêu đề · chi tiết) → hoạt động mới nhất (đã gộp như khung Hoạt động)', () {
    final n = buildKieuLauNotices(
      alerts: const [
        Alert(id: 'task:1', kind: 'TASK_DUE', title: 'Sắp/đã trễ hạn: "Nộp hồ sơ"', detail: '2026-11-23', href: '/du-an'),
        Alert(id: 'budget:1', kind: 'BUDGET_EXCEEDED', title: 'Vượt ngân sách "Ăn uống"', href: '/finance/m'),
      ],
      activity: [
        _e('FINANCE', 'finance.transaction_created', 'cafe', 21, 9),
        _e('FINANCE', 'finance.transaction_created', 'ăn trưa', 21, 12),
        _e('TRA_DINH', 'study_log.created', 'Bài 3', 20),
      ],
    );
    expect(n, [
      {'text': '2 mục cần chú ý', 'lvl': 'bad'},
      {'text': 'Sắp/đã trễ hạn: "Nộp hồ sơ" · 2026-11-23', 'lvl': 'warn'},
      {'text': 'Mới nhất: ăn trưa, cafe · 2 mục · 21/11', 'lvl': 'info'},
    ]);
  });

  test('không cảnh báo: chỉ hoạt động mới nhất; không gì cả → [] (popup "Mọi thứ ổn.")', () {
    expect(buildKieuLauNotices(alerts: const [], activity: [_e('DU_AN', 'task.created', 'Viết báo cáo', 19)]), [
      {'text': 'Mới nhất: Viết báo cáo · 19/11', 'lvl': 'info'},
    ]);
    expect(buildKieuLauNotices(alerts: const [], activity: const []), isEmpty);
  });
}

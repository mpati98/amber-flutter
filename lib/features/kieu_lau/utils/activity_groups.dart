import '../../../shared/utils/vn_time.dart';
import '../models/activity_log_entry.dart';

/// Một dòng nhật ký đã gộp ở Kiều Lâu (design/ref/kieu-lau.html):
/// cùng nguồn + cùng `action` + cùng ngày (giờ VN) → một dòng.
/// - Mọi tên giống nhau → [title] là tên đó, nhãn "×N" ([repeat]).
/// - Tên khác nhau → [title] liệt kê các tên (bỏ trùng, mới trước), dòng phụ "N mục · ngày".
class ActivityGroup {
  const ActivityGroup({
    required this.source,
    required this.action,
    required this.day,
    required this.titles,
    required this.count,
  });

  final String source;
  final String action;

  /// "YYYY-MM-DD" theo giờ VN.
  final String day;

  /// Các tên riêng, mới trước.
  final List<String> titles;

  /// Tổng số hoạt động trong dòng (≥ 1).
  final int count;

  String get title => titles.join(', ');

  /// Số lần lặp khi mọi mục cùng tên (nhãn "×N"); null khi chỉ 1 mục hoặc tên khác nhau.
  int? get repeat => titles.length == 1 && count > 1 ? count : null;

  /// Ngày ngắn "d/M" như bản mẫu ("11/11", "9/11").
  String get shortDate {
    final p = day.split('-');
    return '${int.parse(p[2])}/${int.parse(p[1])}';
  }

  /// Dòng phụ: "4 mục · 11/11" khi gộp nhiều tên khác nhau, còn lại chỉ ngày.
  String get subtitle => titles.length > 1 ? '$count mục · $shortDate' : shortDate;
}

/// Gộp [entries] (thứ tự bất kỳ) thành các dòng; dòng có hoạt động mới nhất lên trước.
List<ActivityGroup> groupActivity(List<ActivityLogEntry> entries) {
  final sorted = [...entries]..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  final groups = <String, List<ActivityLogEntry>>{}; // Map giữ thứ tự chèn = thứ tự mới trước
  for (final e in sorted) {
    (groups['${e.source}|${e.action}|${vnToday(e.createdAt)}'] ??= []).add(e);
  }
  return [
    for (final list in groups.values)
      ActivityGroup(
        source: list.first.source,
        action: list.first.action,
        day: vnToday(list.first.createdAt),
        titles: list.map((e) => e.title).toSet().toList(), // toSet giữ thứ tự gặp đầu tiên
        count: list.length,
      ),
  ];
}

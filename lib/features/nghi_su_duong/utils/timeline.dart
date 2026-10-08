// Tính toán cho tab Lịch (timeline theo tuần). Hàm thuần, ngày là chuỗi "YYYY-MM-DD" theo lịch VN
// (truyền "hôm nay" từ vnToday()); mọi phép tính theo NGÀY, không phụ thuộc múi giờ máy.

const timelineMinWeeks = 4;
const timelineMaxWeeks = 26;

/// Số tuần nhìn lại trước tuần hiện tại khi phải cắt cửa sổ về [timelineMaxWeeks].
const timelineWeeksBefore = 2;

int _day(String iso) => DateTime.parse('${iso}T00:00:00Z').millisecondsSinceEpoch ~/ 86400000;

String _iso(int day) => DateTime.fromMillisecondsSinceEpoch(day * 86400000, isUtc: true).toIso8601String().substring(0, 10);

/// Thứ Hai của tuần chứa [day] (ngày kể từ epoch; 1970-01-01 là thứ Năm).
int _monday(int day) => day - ((day + 3) % 7);

/// Thứ Hai của tuần chứa ngày [iso].
String mondayOf(String iso) => _iso(_monday(_day(iso)));

/// Số ngày từ [from] đến [to] ("YYYY-MM-DD"); to sau from thì dương.
int daysBetween(String from, String to) => _day(to) - _day(from);

class TimelineWindow {
  const TimelineWindow({required this.start, required this.end});

  /// Thứ Hai đầu cửa sổ.
  final String start;

  /// Chủ nhật cuối cửa sổ.
  final String end;

  int get days => daysBetween(start, end) + 1;
  int get weeks => days ~/ 7;

  /// Thứ Hai của tuần thứ [i] (từ 0).
  String weekStart(int i) => _iso(_day(start) + i * 7);

  /// Vị trí (ngày kể từ [start]) của [iso]; có thể âm / vượt [days] nếu ngoài cửa sổ.
  int offsetOf(String iso) => daysBetween(start, iso);

  bool contains(String iso) {
    final o = offsetOf(iso);
    return o >= 0 && o < days;
  }
}

/// Cửa sổ thời gian của lịch.
///
/// Bắt đầu từ thứ Hai của tuần chứa ngày sớm nhất trong (startDate dự án, startDate + dueDate các việc,
/// [today]); kết thúc ở Chủ nhật của tuần chứa ngày muộn nhất trong (endDate dự án, ngày các việc,
/// [today]). Tối thiểu [timelineMinWeeks] tuần. Dài hơn [timelineMaxWeeks] tuần thì lấy đúng
/// [timelineMaxWeeks] tuần, bắt đầu [timelineWeeksBefore] tuần trước tuần hiện tại, không vượt ra
/// ngoài khoảng gốc (dịch lại nếu chạm biên).
TimelineWindow computeTimelineWindow({
  String? projectStart,
  String? projectEnd,
  Iterable<({String? start, String? due})> taskDates = const [],
  required String today,
}) {
  final days = <int>[
    _day(today),
    if (projectStart != null) _day(projectStart),
    if (projectEnd != null) _day(projectEnd),
    for (final t in taskDates) ...[
      if (t.start != null) _day(t.start!),
      if (t.due != null) _day(t.due!),
    ],
  ];
  final lo = days.reduce((a, b) => a < b ? a : b);
  final hi = days.reduce((a, b) => a > b ? a : b);
  var start = _monday(lo);
  var end = _monday(hi) + 6;

  final minDays = timelineMinWeeks * 7;
  final maxDays = timelineMaxWeeks * 7;
  if (end - start + 1 < minDays) end = start + minDays - 1;
  if (end - start + 1 > maxDays) {
    final origStart = start, origEnd = end;
    final currentMonday = _monday(_day(today));
    start = currentMonday - timelineWeeksBefore * 7;
    // Không đi quá cuối khoảng gốc: nếu 26 tuần từ đây vượt origEnd thì lùi cho vừa.
    if (start + maxDays - 1 > origEnd) start = origEnd - maxDays + 1;
    if (start < origStart) start = origStart;
    end = start + maxDays - 1;
  }
  return TimelineWindow(start: _iso(start), end: _iso(end));
}

/// Thanh của một việc trong cửa sổ: [offset] ngày kể từ đầu cửa sổ, dài [length] ngày (đã cắt).
class TimelineBar {
  const TimelineBar({required this.offset, required this.length, this.clippedStart = false, this.clippedEnd = false});

  final int offset;
  final int length;

  /// Thanh bị cắt ở đầu / cuối cửa sổ (việc kéo dài ra ngoài).
  final bool clippedStart;
  final bool clippedEnd;

  @override
  bool operator ==(Object other) =>
      other is TimelineBar &&
      other.offset == offset &&
      other.length == length &&
      other.clippedStart == clippedStart &&
      other.clippedEnd == clippedEnd;

  @override
  int get hashCode => Object.hash(offset, length, clippedStart, clippedEnd);

  @override
  String toString() => 'TimelineBar($offset, $length${clippedStart ? ', clippedStart' : ''}${clippedEnd ? ', clippedEnd' : ''})';
}

/// Thanh của việc có [start] / [due] (đều có thể null): chỉ có một ngày → thanh 1 ngày; start sau due →
/// đổi chỗ; phần ngoài cửa sổ bị cắt; nằm hẳn ngoài cửa sổ hoặc không có ngày nào → null (việc vẫn có
/// dòng, không có thanh).
TimelineBar? timelineBar(String? start, String? due, TimelineWindow window) {
  if (start == null && due == null) return null;
  var a = _day(start ?? due!);
  var b = _day(due ?? start!);
  if (a > b) (a, b) = (b, a);
  final w0 = _day(window.start);
  final w1 = w0 + window.days - 1;
  if (b < w0 || a > w1) return null;
  final clippedStart = a < w0, clippedEnd = b > w1;
  final from = clippedStart ? w0 : a;
  final to = clippedEnd ? w1 : b;
  return TimelineBar(offset: from - w0, length: to - from + 1, clippedStart: clippedStart, clippedEnd: clippedEnd);
}

/// Một ngày trong 7 ngày gần nhất của việc hằng ngày.
class RoutineDay {
  const RoutineDay({required this.date, required this.due, required this.done});

  factory RoutineDay.fromJson(Map<String, dynamic> json) => RoutineDay(
        date: json['date'] as String,
        due: json['due'] as bool,
        done: json['done'] as bool,
      );

  /// "YYYY-MM-DD".
  final String date;

  /// Ngày đó có đến hạn theo lịch lặp không.
  final bool due;
  final bool done;
}

/// Việc hằng ngày + thống kê quanh hôm nay do backend tính.
class Routine {
  const Routine({
    required this.id,
    required this.name,
    required this.weekdays,
    required this.dueToday,
    required this.doneToday,
    required this.streak,
    required this.last7,
  });

  factory Routine.fromJson(Map<String, dynamic> json) => Routine(
        id: json['id'] as String,
        name: json['name'] as String,
        weekdays: [for (final d in json['weekdays'] as List) d as int],
        dueToday: json['dueToday'] as bool,
        doneToday: json['doneToday'] as bool,
        streak: json['streak'] as int,
        last7: [for (final d in json['last7'] as List) RoutineDay.fromJson(d as Map<String, dynamic>)],
      );

  final String id;
  final String name;

  /// 1 = thứ Hai … 7 = Chủ nhật.
  final List<int> weekdays;
  final bool dueToday;
  final bool doneToday;

  /// Số ngày ĐẾN HẠN liên tiếp đã làm (ngày không đến hạn không làm đứt chuỗi).
  final int streak;

  /// 7 ngày kết thúc ở hôm nay, cũ trước mới sau.
  final List<RoutineDay> last7;

  /// Bản ước lượng ngay khi người dùng tick / bỏ tick hôm nay (trước khi server trả lời).
  Routine withDoneToday(bool done) => Routine(
        id: id,
        name: name,
        weekdays: weekdays,
        dueToday: dueToday,
        doneToday: done,
        streak: done == doneToday ? streak : (done ? streak + 1 : (streak > 0 ? streak - 1 : 0)),
        last7: [
          for (final (i, d) in last7.indexed) i == last7.length - 1 ? RoutineDay(date: d.date, due: d.due, done: done) : d,
        ],
      );
}

const _weekdayShort = {1: 'T2', 2: 'T3', 3: 'T4', 4: 'T5', 5: 'T6', 6: 'T7', 7: 'CN'};

/// Chữ lịch lặp: đủ 7 ngày → "Hằng ngày", ngược lại "T2 · T4 · T6".
String weekdaysLabel(Iterable<int> weekdays) {
  final days = weekdays.toSet().toList()..sort();
  if (days.length == 7) return 'Hằng ngày';
  return days.map((d) => _weekdayShort[d] ?? '?').join(' · ');
}

/// Nhãn ngắn của một thứ (1–7): "T2" … "CN".
String weekdayShort(int weekday) => _weekdayShort[weekday] ?? '?';

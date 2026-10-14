/// Loại việc hằng ngày: tick tay hoặc ghi buổi tập (phút + danh sách bài).
enum RoutineKind {
  check('CHECK', 'Việc thường'),
  workout('WORKOUT', 'Tập thể dục'),

  /// Tự tính từ nhật ký học của một môn (Trà Đình) — không tick tay, không tạo từ form việc hằng ngày.
  study('STUDY', 'Học');

  const RoutineKind(this.api, this.label);

  /// Giá trị trên API.
  final String api;
  final String label;

  /// Thiếu / lạ → [check] (backend cũ chưa có trường `kind`).
  static RoutineKind fromApi(Object? value) => RoutineKind.values.firstWhere((k) => k.api == value, orElse: () => check);
}

/// Cách đo một bài tập: số lần / số hiệp × số lần / thời lượng (giây).
enum ExerciseMeasure {
  reps('REPS', 'Số lần'),
  setsReps('SETS_REPS', 'Hiệp × lần'),
  duration('DURATION', 'Thời lượng');

  const ExerciseMeasure(this.api, this.label);

  final String api;
  final String label;

  static ExerciseMeasure fromApi(Object? value) => ExerciseMeasure.values.firstWhere((m) => m.api == value, orElse: () => reps);
}

/// Một bài trong buổi tập. Chỉ các trường thuộc [measure] có giá trị, còn lại null.
class Exercise {
  const Exercise({required this.name, required this.measure, this.sets, this.reps, this.durationSeconds});

  factory Exercise.fromJson(Map<String, dynamic> json) => Exercise(
        name: json['name'] as String,
        measure: ExerciseMeasure.fromApi(json['measure']),
        sets: json['sets'] as int?,
        reps: json['reps'] as int?,
        durationSeconds: json['durationSeconds'] as int?,
      );

  final String name;
  final ExerciseMeasure measure;
  final int? sets;
  final int? reps;
  final int? durationSeconds;

  /// Body gửi PUT: backend từ chối trường không thuộc kiểu đo nên chỉ gửi đúng trường cần.
  Map<String, Object> toJson() => {
        'name': name,
        'measure': measure.api,
        if (measure == ExerciseMeasure.setsReps) 'sets': sets!,
        if (measure != ExerciseMeasure.duration) 'reps': reps!,
        if (measure == ExerciseMeasure.duration) 'durationSeconds': durationSeconds!,
      };

  /// "20 lần" / "3 × 15" / "60 giây" (chẵn phút: "2 phút").
  String get amountLabel => switch (measure) {
        ExerciseMeasure.reps => '$reps lần',
        ExerciseMeasure.setsReps => '$sets × $reps',
        ExerciseMeasure.duration => durationSeconds! >= 60 && durationSeconds! % 60 == 0 ? '${durationSeconds! ~/ 60} phút' : '$durationSeconds giây',
      };
}

/// Log buổi tập của hôm nay: tổng phút (null với việc thường) + các bài theo thứ tự.
class TodayLog {
  const TodayLog({this.durationMinutes, this.exercises = const []});

  factory TodayLog.fromJson(Map<String, dynamic> json) => TodayLog(
        durationMinutes: json['durationMinutes'] as int?,
        exercises: [for (final e in (json['exercises'] as List? ?? const [])) Exercise.fromJson(e as Map<String, dynamic>)],
      );

  final int? durationMinutes;
  final List<Exercise> exercises;
}

/// "30 phút · 4 bài" (bỏ vế không có); chưa có số phút lẫn bài → "Đã tập".
String workoutSummary(TodayLog? log) {
  final parts = [
    if (log?.durationMinutes != null) '${log!.durationMinutes} phút',
    if (log != null && log.exercises.isNotEmpty) '${log.exercises.length} bài',
  ];
  return parts.isEmpty ? 'Đã tập' : parts.join(' · ');
}

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
    this.kind = RoutineKind.check,
    this.todayLog,
    this.lastWorkout,
    this.studySubjectId,
    this.studySubjectName,
    this.todayMinutes,
    this.goalMinutes,
    this.pendingReasonDates = const [],
  });

  factory Routine.fromJson(Map<String, dynamic> json) => Routine(
        id: json['id'] as String,
        name: json['name'] as String,
        weekdays: [for (final d in json['weekdays'] as List) d as int],
        dueToday: json['dueToday'] as bool,
        doneToday: json['doneToday'] as bool,
        streak: json['streak'] as int,
        last7: [for (final d in json['last7'] as List) RoutineDay.fromJson(d as Map<String, dynamic>)],
        kind: RoutineKind.fromApi(json['kind']),
        todayLog: json['todayLog'] == null ? null : TodayLog.fromJson(json['todayLog'] as Map<String, dynamic>),
        lastWorkout: json['lastWorkout'] == null ? null : [for (final e in json['lastWorkout'] as List) Exercise.fromJson(e as Map<String, dynamic>)],
        studySubjectId: json['studySubjectId'] as String?,
        studySubjectName: json['studySubjectName'] as String?,
        todayMinutes: json['todayMinutes'] as int?,
        goalMinutes: json['goalMinutes'] as int?,
        pendingReasonDates: [for (final d in (json['pendingReasonDates'] as List? ?? const [])) d as String],
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
  final RoutineKind kind;

  /// Log hôm nay (có số phút + bài với WORKOUT); null nếu chưa ghi.
  final TodayLog? todayLog;

  /// Các bài của buổi gần nhất trước hôm nay, để điền sẵn; chỉ WORKOUT, null nếu chưa có buổi nào.
  final List<Exercise>? lastWorkout;

  /// Chỉ routine STUDY: môn đang theo dõi, phút đã học hôm nay / mục tiêu ngày, các ngày còn thiếu lý do.
  final String? studySubjectId;
  final String? studySubjectName;
  final int? todayMinutes;
  final int? goalMinutes;
  final List<String> pendingReasonDates;

  bool get isStudy => kind == RoutineKind.study;

  bool get isWorkout => kind == RoutineKind.workout;

  /// Có bằng chứng đã có log (trong 7 ngày gần nhất). Log cũ hơn app không biết — backend chặn đổi loại bằng 409.
  bool get hasRecentLogs => doneToday || last7.any((d) => d.done);

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
        kind: kind,
        todayLog: done ? todayLog : null, // bỏ đánh dấu → log (kèm bài tập) bị xoá
        lastWorkout: lastWorkout,
        studySubjectId: studySubjectId,
        studySubjectName: studySubjectName,
        todayMinutes: todayMinutes,
        goalMinutes: goalMinutes,
        pendingReasonDates: pendingReasonDates,
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

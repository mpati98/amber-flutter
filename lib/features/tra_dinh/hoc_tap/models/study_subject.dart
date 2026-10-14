/// Môn học (study_subjects). `reviewWeekdays`: 1 = thứ Hai … 7 = Chủ nhật.
class StudySubject {
  const StudySubject({
    required this.id,
    required this.name,
    this.dailyGoalMinutes,
    required this.videoMinutesPerDay,
    required this.reviewWeekdays,
    required this.position,
  });

  factory StudySubject.fromJson(Map<String, dynamic> json) => StudySubject(
    id: json['id'] as String,
    name: json['name'] as String,
    dailyGoalMinutes: json['dailyGoalMinutes'] as int?,
    videoMinutesPerDay: json['videoMinutesPerDay'] as int? ?? 40,
    reviewWeekdays: [for (final d in (json['reviewWeekdays'] as List? ?? const [])) d as int],
    position: json['position'] as int? ?? 0,
  );

  final String id;
  final String name;

  /// null = không đặt mục tiêu.
  final int? dailyGoalMinutes;
  final int videoMinutesPerDay;
  final List<int> reviewWeekdays;
  final int position;
}

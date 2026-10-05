enum TaskStatus {
  prep('PREP'),
  waiting('WAITING'),
  inProgress('IN_PROGRESS'),
  done('DONE'),
  unknown('');

  const TaskStatus(this.apiValue);

  final String apiValue;

  static TaskStatus fromApi(String value) => values.firstWhere((s) => s.apiValue == value, orElse: () => unknown);
}

/// 1 dòng bảng tasks. Bỏ `rrule`/`occurrences` — API vẫn trả về (luôn null/[])
/// nhưng là phần sót lại của Lịch đã bỏ.
class Task {
  const Task({
    required this.id,
    this.projectId,
    required this.title,
    this.description,
    required this.status,
    required this.importance,
    required this.urgency,
    required this.durationMinutes,
    this.startDate,
    this.dueDate,
    this.prepLeadDays,
  });

  factory Task.fromJson(Map<String, dynamic> json) => Task(
        id: json['id'] as String,
        projectId: json['projectId'] as String?,
        title: json['title'] as String,
        description: json['description'] as String?,
        status: TaskStatus.fromApi(json['status'] as String),
        importance: json['importance'] as int,
        urgency: json['urgency'] as int,
        durationMinutes: json['durationMinutes'] as int,
        startDate: json['startDate'] as String?,
        dueDate: json['dueDate'] as String?,
        prepLeadDays: json['prepLeadDays'] as int?,
      );

  final String id;
  final String? projectId;
  final String title;
  final String? description;
  final TaskStatus status;

  /// 1 = thấp, 2 = trung bình, 3 = cao.
  final int importance;

  /// 1–3 như importance. UI web hiện luôn tạo task với urgency = 2.
  final int urgency;
  final int durationMinutes;

  /// "YYYY-MM-DD" (cột `date`).
  final String? startDate;
  final String? dueDate;
  final int? prepLeadDays;

  Task copyWith({String? title, TaskStatus? status, int? importance}) => Task(
        id: id,
        projectId: projectId,
        title: title ?? this.title,
        description: description,
        status: status ?? this.status,
        importance: importance ?? this.importance,
        urgency: urgency,
        durationMinutes: durationMinutes,
        startDate: startDate,
        dueDate: dueDate,
        prepLeadDays: prepLeadDays,
      );

  /// Giống web: task "hôm nay" khi ngày bắt đầu HOẶC hạn chót đúng hôm nay.
  bool isOn(String isoDate) => startDate == isoDate || dueDate == isoDate;
}

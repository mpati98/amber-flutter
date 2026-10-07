enum TaskStatus {
  prep('PREP'),
  inProgress('IN_PROGRESS'),
  review('REVIEW'),
  done('DONE'),
  unknown('');

  const TaskStatus(this.apiValue);

  final String apiValue;

  static TaskStatus fromApi(String value) => values.firstWhere((s) => s.apiValue == value, orElse: () => unknown);

  /// Nhãn hiển thị: PREP "Chờ", IN_PROGRESS "Đang làm", REVIEW "Thẩm định", DONE "Xong".
  String get label => switch (this) {
        prep => 'Chờ',
        inProgress => 'Đang làm',
        review => 'Thẩm định',
        done => 'Xong',
        unknown => 'Không rõ',
      };
}

/// Mục checklist của một việc.
class ChecklistItem {
  const ChecklistItem({required this.id, required this.text, required this.done, required this.position});

  factory ChecklistItem.fromJson(Map<String, dynamic> json) => ChecklistItem(
        id: json['id'] as String,
        text: json['text'] as String,
        done: json['done'] as bool,
        position: json['position'] as int,
      );

  final String id;
  final String text;
  final bool done;
  final int position;
}

/// Cờ "cần chú ý" do backend tính: OVERDUE (quá hạn [days] ngày) hoặc IDLE (nằm im [days] ngày).
class TaskAttention {
  const TaskAttention({required this.kind, required this.days});

  static TaskAttention? fromJson(Object? json) => switch (json) {
        {'kind': final String kind, 'days': final int days} => TaskAttention(kind: kind, days: days),
        _ => null,
      };

  final String kind;
  final int days;

  bool get isOverdue => kind == 'OVERDUE';

  String get label => isOverdue ? 'Quá hạn $days ngày' : 'Nằm im $days ngày';
}

/// 1 dòng bảng tasks. Bỏ `rrule`/`occurrences` — API vẫn trả về (luôn null/[])
/// nhưng là phần sót lại của Lịch đã bỏ.
class Task {
  const Task({
    required this.id,
    this.projectId,
    this.krId,
    required this.title,
    this.description,
    required this.status,
    required this.importance,
    required this.urgency,
    required this.durationMinutes,
    this.startDate,
    this.dueDate,
    this.prepLeadDays,
    this.isMilestone = false,
    this.notifyDeadline = false,
    this.statusChangedAt,
    this.createdAt,
    this.checklistItems = const [],
    this.attention,
  });

  factory Task.fromJson(Map<String, dynamic> json) => Task(
        id: json['id'] as String,
        projectId: json['projectId'] as String?,
        krId: json['krId'] as String?,
        title: json['title'] as String,
        description: json['description'] as String?,
        status: TaskStatus.fromApi(json['status'] as String),
        importance: json['importance'] as int,
        urgency: json['urgency'] as int,
        durationMinutes: json['durationMinutes'] as int,
        startDate: json['startDate'] as String?,
        dueDate: json['dueDate'] as String?,
        prepLeadDays: json['prepLeadDays'] as int?,
        isMilestone: json['isMilestone'] as bool? ?? false,
        notifyDeadline: json['notifyDeadline'] as bool? ?? false,
        statusChangedAt: json['statusChangedAt'] == null ? null : DateTime.parse(json['statusChangedAt'] as String),
        createdAt: json['createdAt'] == null ? null : DateTime.parse(json['createdAt'] as String),
        checklistItems: [
          for (final e in (json['checklistItems'] as List? ?? const [])) ChecklistItem.fromJson(e as Map<String, dynamic>),
        ],
        attention: TaskAttention.fromJson(json['attention']),
      );

  final String id;
  final String? projectId;

  /// KR mà việc đang gắn vào (null = không gắn).
  final String? krId;
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
  final bool isMilestone;
  final bool notifyDeadline;
  final DateTime? statusChangedAt;
  final DateTime? createdAt;
  final List<ChecklistItem> checklistItems;
  final TaskAttention? attention;

  Task copyWith({String? title, TaskStatus? status, int? importance, List<ChecklistItem>? checklistItems}) => Task(
        id: id,
        projectId: projectId,
        krId: krId,
        title: title ?? this.title,
        description: description,
        status: status ?? this.status,
        importance: importance ?? this.importance,
        urgency: urgency,
        durationMinutes: durationMinutes,
        startDate: startDate,
        dueDate: dueDate,
        prepLeadDays: prepLeadDays,
        isMilestone: isMilestone,
        notifyDeadline: notifyDeadline,
        statusChangedAt: statusChangedAt,
        createdAt: createdAt,
        checklistItems: checklistItems ?? this.checklistItems,
        attention: attention,
      );
}

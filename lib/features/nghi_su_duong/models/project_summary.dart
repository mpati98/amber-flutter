// Response GET /api/du-an/summary — dữ liệu màn Dự án. Tiền là chuỗi số ("-100000.00").

enum ProjectStatus {
  active('ACTIVE'),
  paused('PAUSED'),
  done('DONE'),
  unknown('');

  const ProjectStatus(this.apiValue);

  final String apiValue;

  static ProjectStatus fromApi(String value) => values.firstWhere((s) => s.apiValue == value, orElse: () => unknown);
}

class NextMilestone {
  const NextMilestone({required this.id, required this.title, required this.dueDate});

  factory NextMilestone.fromJson(Map<String, dynamic> json) => NextMilestone(
        id: json['id'] as String,
        title: json['title'] as String,
        dueDate: json['dueDate'] as String,
      );

  final String id;
  final String title;

  /// "YYYY-MM-DD".
  final String dueDate;
}

/// Tổng thu / chi / ròng của các giao dịch gắn với dự án (VND).
class ProjectFinance {
  const ProjectFinance({required this.income, required this.expense, required this.net});

  factory ProjectFinance.fromJson(Map<String, dynamic> json) => ProjectFinance(
        income: _money(json['income']),
        expense: _money(json['expense']),
        net: _money(json['net']),
      );

  static const zero = ProjectFinance(income: 0, expense: 0, net: 0);

  final num income;
  final num expense;
  final num net;
}

num _money(Object? v) => v is num ? v : num.tryParse('$v') ?? 0;

class ProjectSummary {
  const ProjectSummary({
    required this.id,
    required this.name,
    this.goal,
    this.color,
    required this.status,
    this.startDate,
    this.endDate,
    this.closedAt,
    this.krProgress,
    required this.taskTotal,
    required this.taskDone,
    required this.taskDoing,
    required this.attentionCount,
    this.nextMilestone,
    this.finance = ProjectFinance.zero,
  });

  factory ProjectSummary.fromJson(Map<String, dynamic> json) => ProjectSummary(
        id: json['id'] as String,
        name: json['name'] as String,
        goal: json['goal'] as String?,
        color: json['color'] as String?,
        status: ProjectStatus.fromApi(json['status'] as String),
        startDate: json['startDate'] as String?,
        endDate: json['endDate'] as String?,
        closedAt: json['closedAt'] == null ? null : DateTime.parse(json['closedAt'] as String),
        krProgress: (json['krProgress'] as num?)?.toDouble(),
        taskTotal: json['taskTotal'] as int,
        taskDone: json['taskDone'] as int,
        taskDoing: json['taskDoing'] as int,
        attentionCount: json['attentionCount'] as int,
        nextMilestone: json['nextMilestone'] == null
            ? null
            : NextMilestone.fromJson(json['nextMilestone'] as Map<String, dynamic>),
        finance: json['finance'] == null
            ? ProjectFinance.zero
            : ProjectFinance.fromJson(json['finance'] as Map<String, dynamic>),
      );

  final String id;
  final String name;
  final String? goal;
  final String? color;
  final ProjectStatus status;

  /// "YYYY-MM-DD" (cột date).
  final String? startDate;
  final String? endDate;
  final DateTime? closedAt;

  /// Trung bình tiến độ các KR (0..1); null khi dự án chưa có KR.
  final double? krProgress;
  final int taskTotal;
  final int taskDone;

  /// Số việc IN_PROGRESS.
  final int taskDoing;

  /// Số việc quá hạn hoặc nằm im (đang cần chú ý).
  final int attentionCount;
  final NextMilestone? nextMilestone;
  final ProjectFinance finance;
}

/// Việc cần chú ý, tổng hợp qua mọi dự án đang ACTIVE.
class AttentionItem {
  const AttentionItem({
    required this.taskId,
    required this.title,
    required this.status,
    required this.projectId,
    required this.projectName,
    required this.kind,
    required this.days,
  });

  factory AttentionItem.fromJson(Map<String, dynamic> json) => AttentionItem(
        taskId: json['taskId'] as String,
        title: json['title'] as String,
        status: json['status'] as String,
        projectId: json['projectId'] as String,
        projectName: json['projectName'] as String,
        kind: json['kind'] as String,
        days: json['days'] as int,
      );

  final String taskId;
  final String title;
  final String status;
  final String projectId;
  final String projectName;

  /// OVERDUE (quá hạn) | IDLE (nằm im).
  final String kind;
  final int days;

  bool get isOverdue => kind == 'OVERDUE';
}

class DuAnSummary {
  const DuAnSummary({required this.projects, required this.attention});

  factory DuAnSummary.fromJson(Map<String, dynamic> json) => DuAnSummary(
        projects: (json['projects'] as List).map((e) => ProjectSummary.fromJson(e as Map<String, dynamic>)).toList(),
        attention: (json['attention'] as List).map((e) => AttentionItem.fromJson(e as Map<String, dynamic>)).toList(),
      );

  final List<ProjectSummary> projects;
  final List<AttentionItem> attention;
}

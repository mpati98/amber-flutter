// Task công việc đồng bộ một chiều từ ats-app (GET /api/du-an/ats-tasks) — CHỈ ĐỌC trong Amber, sửa trên ats-app.
// Parse phòng thủ: thiếu trường / giá trị lạ không được làm hỏng cả danh sách.

import 'package:dio/dio.dart';

import '../../../shared/utils/vn_time.dart';

/// Trạng thái đã ánh xạ ở server. Giá trị lạ → [prep] (hiển thị "Chưa làm").
enum AtsTaskStatus {
  prep('PREP', 'Chưa làm'),
  inProgress('IN_PROGRESS', 'Đang làm'),
  waiting('WAITING', 'Chờ'),
  done('DONE', 'Xong');

  const AtsTaskStatus(this.apiValue, this.label);

  final String apiValue;
  final String label;

  static AtsTaskStatus fromApi(Object? value) => values.firstWhere((s) => s.apiValue == value, orElse: () => prep);
}

/// Nhãn loại dự án ats: CAMPAIGN / FAIR / OTHER; loại lạ hiện nguyên văn.
String atsProjectTypeLabel(String? type) => switch (type) {
  'CAMPAIGN' => 'Chiến dịch',
  'FAIR' => 'Hội chợ',
  'OTHER' => 'Khác',
  null || '' => '',
  final t => t,
};

class AtsProject {
  const AtsProject({required this.atsId, required this.name, required this.type, required this.archived});

  final String? atsId;
  final String name;
  final String? type;
  final bool archived;

  String get typeLabel => atsProjectTypeLabel(type);

  static AtsProject? fromJson(Object? json) {
    if (json is! Map) return null;
    return AtsProject(
      atsId: json['atsId']?.toString(),
      name: (json['name'] as String?) ?? '',
      type: json['type'] as String?,
      archived: json['archived'] == true,
    );
  }
}

class AtsTask {
  const AtsTask({
    required this.id,
    required this.atsId,
    required this.title,
    required this.status,
    required this.rawStatus,
    required this.dueDate,
    required this.doneAt,
    required this.project,
    required this.overdue,
  });

  final String id;
  final String atsId;
  final String title;
  final AtsTaskStatus status;

  /// Trạng thái gốc của ats (DOING | WAITING | DONE | null) — chỉ để tham khảo.
  final String? rawStatus;

  /// "YYYY-MM-DD" hoặc null.
  final String? dueDate;
  final DateTime? doneAt;
  final AtsProject? project;

  /// attention == "OVERDUE" (server tính theo ngày VN).
  final bool overdue;

  bool get isDone => status == AtsTaskStatus.done;

  factory AtsTask.fromJson(Map<String, dynamic> json) => AtsTask(
    id: json['id']?.toString() ?? '',
    atsId: json['atsId']?.toString() ?? '',
    title: (json['title'] as String?) ?? '',
    status: AtsTaskStatus.fromApi(json['status']),
    rawStatus: json['rawStatus'] as String?,
    dueDate: json['dueDate'] as String?,
    doneAt: _date(json['doneAt']),
    project: AtsProject.fromJson(json['project']),
    overdue: json['attention'] == 'OVERDUE',
  );
}

class AtsSyncState {
  const AtsSyncState({this.lastSuccessAt, this.lastAttemptAt, this.lastError});

  final DateTime? lastSuccessAt;
  final DateTime? lastAttemptAt;
  final String? lastError;

  bool get neverSynced => lastSuccessAt == null && lastError == null;

  factory AtsSyncState.fromJson(Object? json) {
    if (json is! Map) return const AtsSyncState();
    final err = json['lastError'];
    return AtsSyncState(
      lastSuccessAt: _date(json['lastSuccessAt']),
      lastAttemptAt: _date(json['lastAttemptAt']),
      lastError: err is String && err.trim().isNotEmpty ? err.trim() : null,
    );
  }
}

/// Response GET /api/du-an/ats-tasks. Thứ tự [tasks] do server sắp — client giữ nguyên.
class AtsTasksData {
  const AtsTasksData({required this.tasks, required this.sync});

  final List<AtsTask> tasks;
  final AtsSyncState sync;

  int get openCount => tasks.where((t) => !t.isDone).length;

  factory AtsTasksData.fromJson(Map<String, dynamic> json) => AtsTasksData(
    tasks: [
      for (final t in (json['tasks'] as List?) ?? const [])
        if (t is Map<String, dynamic>) AtsTask.fromJson(t),
    ],
    sync: AtsSyncState.fromJson(json['sync']),
  );
}

/// Kết quả POST /api/du-an/ats-tasks/sync.
class AtsSyncResult {
  const AtsSyncResult({required this.fetched, required this.inserted, required this.updated, required this.deleted});

  final int fetched;
  final int inserted;
  final int updated;
  final int deleted;

  bool get changed => inserted + updated + deleted > 0;

  factory AtsSyncResult.fromJson(Map<String, dynamic> json) {
    final r = json['result'] is Map ? json['result'] as Map : const {};
    int n(String k) => (r[k] as num?)?.toInt() ?? 0;
    return AtsSyncResult(fetched: n('fetched'), inserted: n('inserted'), updated: n('updated'), deleted: n('deleted'));
  }
}

DateTime? _date(Object? v) => v is String ? DateTime.tryParse(v) : null;

/// "HH:mm dd/MM" theo giờ VN.
String formatVnTimeDayMonth(DateTime at) {
  final d = vnNow(at);
  String two(int x) => x.toString().padLeft(2, '0');
  return '${two(d.hour)}:${two(d.minute)} ${two(d.day)}/${two(d.month)}';
}

/// "dd/MM/yyyy" theo giờ VN (ngày xong trong sheet chi tiết).
String formatVnDate(DateTime at) {
  final d = vnNow(at);
  String two(int x) => x.toString().padLeft(2, '0');
  return '${two(d.day)}/${two(d.month)}/${d.year}';
}

/// Số giây phải chờ khi đồng bộ bị chặn (429): `retryAfterSeconds` trong body, không có thì header `Retry-After`.
/// Không phải lỗi 429 → null.
int? atsRetryAfterSeconds(Object error) {
  if (error is! DioException || error.response?.statusCode != 429) return null;
  final data = error.response?.data;
  final fromBody = data is Map ? data['retryAfterSeconds'] : null;
  if (fromBody is num && fromBody > 0) return fromBody.ceil();
  final header = int.tryParse(error.response?.headers.value('retry-after') ?? '');
  return header != null && header > 0 ? header : 30;
}

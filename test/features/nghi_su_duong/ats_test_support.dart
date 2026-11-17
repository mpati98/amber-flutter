import 'package:amber_flutter/features/nghi_su_duong/models/ats_task.dart';
import 'package:amber_flutter/features/nghi_su_duong/services/ats_tasks_api.dart';
import 'package:dio/dio.dart';

/// API ATS giả cho widget test: trả [data] (hoặc ném [getError]); đếm số lần gọi; `syncNow` trả [syncResult] hoặc ném [syncError].
class FakeAtsTasksApi extends AtsTasksApi {
  FakeAtsTasksApi({AtsTasksData? data, this.getError, this.syncError, this.syncResult})
    : data = data ?? const AtsTasksData(tasks: [], sync: AtsSyncState()),
      super(Dio());

  AtsTasksData data;

  /// Dữ liệu trả khi gọi `?all=1`; null thì dùng [data].
  AtsTasksData? allData;
  Object? getError;
  Object? syncError;
  AtsSyncResult? syncResult;
  final getCalls = <bool>[];
  int syncCalls = 0;

  @override
  Future<AtsTasksData> getTasks({bool all = false}) async {
    getCalls.add(all);
    if (getError != null) throw getError!;
    return all ? (allData ?? data) : data;
  }

  @override
  Future<AtsSyncResult> syncNow() async {
    syncCalls++;
    if (syncError != null) throw syncError!;
    return syncResult ?? const AtsSyncResult(fetched: 0, inserted: 0, updated: 0, deleted: 0);
  }
}

Map<String, dynamic> atsTaskJson(
  String id, {
  String title = 'Việc',
  String? status = 'PREP',
  String? rawStatus,
  String? dueDate,
  String? doneAt,
  Object? project = const {'atsId': 'p1', 'name': 'Hội chợ X', 'type': 'FAIR', 'archived': false},
  String? attention,
}) => {
  'id': id,
  'atsId': 'ats-$id',
  'title': title,
  'status': status,
  'rawStatus': rawStatus,
  'dueDate': dueDate,
  'doneAt': doneAt,
  'project': project,
  'attention': attention,
};

AtsTasksData atsData(List<Map<String, dynamic>> tasks, {Map<String, dynamic>? sync}) =>
    AtsTasksData.fromJson({'tasks': tasks, 'sync': sync ?? {'lastSuccessAt': '2026-11-17T06:05:00.000Z', 'lastAttemptAt': '2026-11-17T06:05:00.000Z', 'lastError': null}});

DioException atsHttpError(int status, Object? data, {Map<String, List<String>> headers = const {}}) {
  final req = RequestOptions(path: '/api/du-an/ats-tasks/sync');
  return DioException(
    requestOptions: req,
    type: DioExceptionType.badResponse,
    response: Response(requestOptions: req, statusCode: status, data: data, headers: Headers.fromMap(headers)),
  );
}

import 'package:amber_flutter/features/nghi_su_duong/models/ats_task.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

import 'ats_test_support.dart';

// Parse model task ATS (GET /api/du-an/ats-tasks) — phòng thủ với trường thiếu / giá trị lạ.

void main() {
  test('parse đủ trường', () {
    final d = AtsTasksData.fromJson({
      'tasks': [
        atsTaskJson('1', title: 'Gửi báo giá', status: 'IN_PROGRESS', rawStatus: 'DOING', dueDate: '2026-11-20', attention: 'OVERDUE'),
      ],
      'sync': {'lastSuccessAt': '2026-11-17T06:05:00.000Z', 'lastAttemptAt': '2026-11-17T06:06:00.000Z', 'lastError': null},
    });
    final t = d.tasks.single;
    expect(t.id, '1');
    expect(t.atsId, 'ats-1');
    expect(t.title, 'Gửi báo giá');
    expect(t.status, AtsTaskStatus.inProgress);
    expect(t.status.label, 'Đang làm');
    expect(t.rawStatus, 'DOING');
    expect(t.dueDate, '2026-11-20');
    expect(t.overdue, isTrue);
    expect(t.project!.name, 'Hội chợ X');
    expect(t.project!.typeLabel, 'Hội chợ');
    expect(d.sync.lastSuccessAt, DateTime.utc(2026, 11, 17, 6, 5));
    expect(d.sync.lastError, isNull);
    expect(d.sync.neverSynced, isFalse);
    expect(d.openCount, 1);
  });

  test('project null, dueDate null, doneAt null không lỗi', () {
    final t = AtsTask.fromJson(atsTaskJson('2', project: null, dueDate: null));
    expect(t.project, isNull);
    expect(t.dueDate, isNull);
    expect(t.doneAt, isNull);
    expect(t.overdue, isFalse);
  });

  test('status lạ / null / thiếu → PREP ("Chưa làm"), không crash', () {
    for (final s in ['REVIEW', 'LẠ', null, 42]) {
      final t = AtsTask.fromJson({...atsTaskJson('x'), 'status': s});
      expect(t.status, AtsTaskStatus.prep, reason: '$s');
      expect(t.status.label, 'Chưa làm');
    }
    final missing = AtsTask.fromJson({'id': 'y'});
    expect(missing.status, AtsTaskStatus.prep);
    expect(missing.title, '');
  });

  test('ánh xạ đủ 4 nhãn', () {
    expect(AtsTaskStatus.fromApi('PREP').label, 'Chưa làm');
    expect(AtsTaskStatus.fromApi('IN_PROGRESS').label, 'Đang làm');
    expect(AtsTaskStatus.fromApi('WAITING').label, 'Chờ');
    expect(AtsTaskStatus.fromApi('DONE').label, 'Xong');
  });

  test('loại dự án: 3 nhãn + loại lạ giữ nguyên', () {
    expect(atsProjectTypeLabel('CAMPAIGN'), 'Chiến dịch');
    expect(atsProjectTypeLabel('FAIR'), 'Hội chợ');
    expect(atsProjectTypeLabel('OTHER'), 'Khác');
    expect(atsProjectTypeLabel('WEBINAR'), 'WEBINAR');
    expect(atsProjectTypeLabel(null), '');
  });

  test('response thiếu / sai kiểu: tasks rỗng, sync trống, phần tử không phải object bị bỏ', () {
    final d = AtsTasksData.fromJson({'tasks': [42, 'x', atsTaskJson('ok')], 'sync': 'sai'});
    expect(d.tasks.map((t) => t.id), ['ok']);
    expect(d.sync.neverSynced, isTrue);
    expect(AtsTasksData.fromJson({}).tasks, isEmpty);
  });

  test('lastError chuỗi rỗng coi như không lỗi', () {
    expect(AtsSyncState.fromJson({'lastError': '  '}).lastError, isNull);
    expect(AtsSyncState.fromJson({'lastError': 'unauthorized: x'}).lastError, 'unauthorized: x');
  });

  test('giờ VN: "HH:mm dd/MM" và "dd/MM/yyyy"', () {
    // 17:30Z = 00:30 ngày hôm sau giờ VN.
    expect(formatVnTimeDayMonth(DateTime.utc(2026, 11, 17, 17, 30)), '00:30 18/11');
    expect(formatVnDate(DateTime.utc(2026, 11, 17, 17, 30)), '18/11/2026');
  });

  test('AtsSyncResult', () {
    final r = AtsSyncResult.fromJson({'result': {'fetched': 57, 'inserted': 3, 'updated': 1, 'deleted': 0}});
    expect([r.fetched, r.inserted, r.updated, r.deleted], [57, 3, 1, 0]);
    expect(r.changed, isTrue);
    expect(AtsSyncResult.fromJson({}).changed, isFalse);
  });

  test('atsRetryAfterSeconds: body → header → 30; không phải 429 → null', () {
    expect(atsRetryAfterSeconds(atsHttpError(429, {'error': 'sync_throttled', 'retryAfterSeconds': 12})), 12);
    expect(atsRetryAfterSeconds(atsHttpError(429, null, headers: {'retry-after': ['7']})), 7);
    expect(atsRetryAfterSeconds(atsHttpError(429, null)), 30);
    expect(atsRetryAfterSeconds(atsHttpError(502, {'code': 'unauthorized'})), isNull);
    expect(atsRetryAfterSeconds(DioException(requestOptions: RequestOptions())), isNull);
    expect(atsRetryAfterSeconds(Exception('x')), isNull);
  });
}

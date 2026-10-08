import 'package:amber_flutter/features/nghi_su_duong/models/key_result.dart';
import 'package:amber_flutter/features/nghi_su_duong/models/project.dart';
import 'package:amber_flutter/features/nghi_su_duong/models/project_summary.dart';
import 'package:amber_flutter/features/nghi_su_duong/models/task.dart';
import 'package:amber_flutter/features/nghi_su_duong/services/nghi_su_duong_api.dart';
import 'package:amber_flutter/shared/utils/vn_time.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

// Test hợp đồng với backend THẬT (amber-v4). Bị bỏ qua nếu thiếu --dart-define:
//
//   flutter test test/integration/nsd_backend_contract_test.dart \
//     --dart-define=NSD_API_BASE_URL=http://localhost:3111 \
//     --dart-define=NSD_API_TOKEN=<access token HS256 của user>
//
// Dùng đúng NghiSuDuongApi và model của app; chỉ thao tác dọn dẹp (xoá dự án, app chưa có) gọi thẳng HTTP.
// Ghi dữ liệu thật vào DB mà backend đang trỏ — chạy trên nhánh dev, dự án thử được xoá ở cuối.

const _baseUrl = String.fromEnvironment('NSD_API_BASE_URL');
const _token = String.fromEnvironment('NSD_API_TOKEN');

String _dayBefore(String iso, int days) {
  final d = DateTime.parse(iso).subtract(Duration(days: days));
  return '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
}

void main() {
  final missing = _baseUrl.isEmpty || _token.isEmpty;

  test(
    'Dự án STANDARD → KR → việc → checklist → chuyển DONE → summary (backend thật)',
    () async {
      final dio = Dio(BaseOptions(baseUrl: _baseUrl, headers: {'Authorization': 'Bearer $_token'}));
      final api = NghiSuDuongApi(dio);
      final today = vnToday();
      final yesterday = _dayBefore(today, 1);
      String? projectId;
      var initialCount = -1;

      try {
        // 1. summary ban đầu
        final before = await api.getDuAnSummary();
        initialCount = before.projects.length;

        // 2. tạo dự án → lấy lại chi tiết
        final created = await api.createProject(
          name: 'TEST contract ${DateTime.now().millisecondsSinceEpoch}',
          type: ProjectType.standard,
          goal: 'Mục tiêu thử hợp đồng',
          startDate: yesterday,
          endDate: _dayBefore(today, -30),
        );
        projectId = created.id;
        final detail = await api.getProject(projectId);
        expect(detail.id, projectId);
        expect(detail.goal, 'Mục tiêu thử hợp đồng');
        expect(detail.status, ProjectStatus.active);
        expect(detail.startDate, yesterday);
        expect(detail.endDate, _dayBefore(today, -30));
        expect(detail.closedAt, isNull);
        expect(detail.keyResults, isEmpty);

        // 3. KR MANUAL (target 4) và KR AUTO; tăng current lên 2
        final manual = await api.createKeyResult(projectId, name: 'KR tay', mode: KrMode.manual, unit: 'bài', target: 4);
        expect(manual.mode, KrMode.manual);
        expect((manual.target, manual.current, manual.unit, manual.progress), (4, 0, 'bài', 0.0));
        final auto = await api.createKeyResult(projectId, name: 'KR tự đếm', mode: KrMode.auto);
        expect(auto.mode, KrMode.auto);
        expect((auto.target, auto.current, auto.linkedTotal, auto.progress), (0, 0, 0, 0.0));
        final bumped = await api.updateKeyResult(projectId, manual.id, {'current': 2});
        expect(bumped.current, 2);
        expect(bumped.progress, 0.5);

        // 4. việc gắn KR AUTO: mốc, hạn hôm qua, bật thông báo, có nội dung
        final task = await api.createTask(
          projectId: projectId,
          title: 'Việc thử hợp đồng',
          krId: auto.id,
          isMilestone: true,
          dueDate: yesterday,
          notifyDeadline: true,
          description: 'Dòng một\nDòng hai',
        );
        expect(task.projectId, projectId);

        // 5. checklist 3 mục; tick mục thứ hai
        final items = await api.putChecklist(task.id, const [
          ChecklistDraft(text: 'Mục một', done: false),
          ChecklistDraft(text: 'Mục hai', done: false),
          ChecklistDraft(text: 'Mục ba', done: true),
        ]);
        expect([for (final i in items) i.text], ['Mục một', 'Mục hai', 'Mục ba']);
        expect([for (final i in items) i.position], [0, 1, 2]);
        final ticked = await api.patchChecklistItem(task.id, items[1].id, done: true);
        expect(ticked.done, isTrue);
        expect(ticked.text, 'Mục hai');

        // 6. lấy việc theo projectId
        final tasks = await api.getProjectTasks(projectId);
        expect(tasks, hasLength(1));
        final t = tasks.single;
        expect(t.id, task.id);
        expect(t.projectId, projectId);
        expect(t.krId, auto.id);
        expect(t.isMilestone, isTrue);
        expect(t.notifyDeadline, isTrue);
        expect(t.description, 'Dòng một\nDòng hai');
        expect(t.dueDate, yesterday);
        expect(t.status, TaskStatus.prep);
        expect(t.statusChangedAt, isNotNull);
        expect(t.createdAt, isNotNull);
        expect([for (final i in t.checklistItems) (i.text, i.done)], [('Mục một', false), ('Mục hai', true), ('Mục ba', true)]);
        expect(t.attention, isNotNull);
        expect(t.attention!.kind, 'OVERDUE');
        expect(t.attention!.days, 1);

        // 7. chuyển DONE → KR AUTO tự đếm
        await api.updateTask(task.id, {'status': TaskStatus.done.apiValue});
        final after = await api.getProject(projectId);
        final autoAfter = after.keyResults.firstWhere((k) => k.id == auto.id);
        expect((autoAfter.linkedTotal, autoAfter.linkedDone, autoAfter.progress), (1, 1, 1.0));
        final manualAfter = after.keyResults.firstWhere((k) => k.id == manual.id);
        expect((manualAfter.current, manualAfter.progress), (2, 0.5));
        expect((await api.getProjectTasks(projectId)).single.attention, isNull, reason: 'DONE thì hết cảnh báo');

        // 8. summary: dự án vừa tạo
        final mid = await api.getDuAnSummary();
        expect(mid.projects.length, initialCount + 1);
        final s = mid.projects.firstWhere((p) => p.id == projectId);
        expect(s.krProgress, 0.75);
        expect((s.taskTotal, s.taskDone, s.taskDoing, s.attentionCount), (1, 1, 0, 0));
        expect(s.goal, 'Mục tiêu thử hợp đồng');
        expect(s.status, ProjectStatus.active);
        expect(s.nextMilestone, isNull, reason: 'mốc đã DONE');
        expect((s.finance.income, s.finance.expense, s.finance.net), (0, 0, 0));
        expect(mid.attention.where((a) => a.projectId == projectId), isEmpty);
      } finally {
        // 9. dọn: xoá dự án (KR, việc, checklist xoá theo)
        if (projectId != null) {
          await dio.delete<void>('/api/projects/$projectId');
        }
      }

      final end = await api.getDuAnSummary();
      expect(end.projects.length, initialCount, reason: 'summary về đúng số dự án ban đầu sau khi dọn');
      expect(end.projects.any((p) => p.id == projectId), isFalse);
    },
    skip: missing ? 'Cần --dart-define=NSD_API_BASE_URL và NSD_API_TOKEN (backend thật)' : null,
    timeout: const Timeout(Duration(minutes: 2)),
  );
}

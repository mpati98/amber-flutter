import 'package:amber_flutter/features/nghi_su_duong/models/finance_category.dart';
import 'package:amber_flutter/features/tang_kinh_cac/models/document.dart';
import 'package:amber_flutter/features/tang_kinh_cac/services/document_api.dart';
import 'package:amber_flutter/features/nghi_su_duong/models/key_result.dart';
import 'package:amber_flutter/features/nghi_su_duong/models/project.dart';
import 'package:amber_flutter/features/nghi_su_duong/models/project_summary.dart';
import 'package:amber_flutter/features/nghi_su_duong/models/task.dart';
import 'package:amber_flutter/features/nghi_su_duong/services/finance_api.dart';
import 'package:amber_flutter/features/nghi_su_duong/services/nghi_su_duong_api.dart';
import 'package:amber_flutter/shared/utils/api_error.dart';
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

  test(
    'Thu-chi gắn dự án: POST không projectId → PATCH → bỏ gắn / gắn lại → xoá, số dư ví hoàn lại (backend thật)',
    () async {
      final dio = Dio(BaseOptions(baseUrl: _baseUrl, headers: {'Authorization': 'Bearer $_token'}));
      final api = NghiSuDuongApi(dio);
      final fin = FinanceApi(dio);
      String? projectId;
      String? txId;

      Future<Map<String, double>> balances() async => {for (final a in await fin.getAccounts()) a.id: a.currentBalance};

      // 1. số dư các ví trước
      final before = await balances();
      expect(before, isNotEmpty, reason: 'cần ít nhất một ví trên DB dev');
      final account = (await fin.getAccounts()).first;
      final category = (await fin.getCategories()).firstWhere((c) => c.kind == MoneyKind.expense);

      try {
        // 2. dự án + giao dịch Chi 100000 gắn dự án, KHÔNG gửi projectId
        projectId = (await api.createProject(name: 'TEST contract thu-chi ${DateTime.now().millisecondsSinceEpoch}', type: ProjectType.standard)).id;
        final created = await fin.createTransaction(
          linkedProjectId: projectId,
          accountId: account.id,
          categoryId: category.id,
          kind: MoneyKind.expense,
          amount: 100000,
          note: 'Chi thử hợp đồng',
          occurredAt: DateTime.now(),
        );
        txId = created.id;
        expect(created.linkedProjectId, projectId);
        expect(created.kind, MoneyKind.expense);
        expect(created.amount, 100000);
        expect(created.note, 'Chi thử hợp đồng');
        expect(created.projectId, isNot(projectId), reason: 'projectId là tháng tài chính, không phải dự án');
        // projectId do server chọn = tháng tài chính hiện tại (đang mở, chứa hôm nay)
        final month = (await fin.getFinanceProjects()).firstWhere((p) => p.id == created.projectId);
        expect(month.type, ProjectType.finance);
        expect(month.archivedAt, isNull);
        final today = vnToday();
        expect(month.startDate!.compareTo(today) <= 0 && month.endDate!.compareTo(today) >= 0, isTrue);
        expect((await balances())[account.id], before[account.id]! - 100000);

        // 3. lấy theo linkedProjectId: parse category, account, amount
        var list = await fin.getTransactionsByLinkedProject(projectId);
        expect(list, hasLength(1));
        expect(list.single.id, txId);
        expect(list.single.amount, 100000);
        expect(list.single.kind, MoneyKind.expense);
        expect(list.single.categoryName, category.name);
        expect(list.single.accountName, account.name);
        expect(list.single.linkedProjectId, projectId);
        expect(list.single.occurredAt.difference(DateTime.now()).inMinutes.abs(), lessThan(10));

        // 4. PATCH amount + note → số dư đúng
        final patched = await fin.updateTransaction(txId, {'amount': 150000, 'note': 'Đã sửa'});
        expect(patched.amount, 150000);
        expect(patched.note, 'Đã sửa');
        expect((await balances())[account.id], before[account.id]! - 150000);
        final mid = await api.getDuAnSummary();
        final s = mid.projects.firstWhere((p) => p.id == projectId);
        expect((s.finance.income, s.finance.expense, s.finance.net), (0, 150000, -150000));

        // 5. bỏ gắn → danh sách theo dự án rỗng; gắn lại
        await fin.updateTransaction(txId, {'linkedProjectId': null});
        expect(await fin.getTransactionsByLinkedProject(projectId), isEmpty);
        expect((await balances())[account.id], before[account.id]! - 150000, reason: 'bỏ gắn không đổi số dư');
        await fin.updateTransaction(txId, {'linkedProjectId': projectId});
        list = await fin.getTransactionsByLinkedProject(projectId);
        expect(list.map((t) => t.id), [txId]);

        // 6. xoá giao dịch → số dư hoàn lại
        await fin.deleteTransaction(txId);
        txId = null;
        expect(await fin.getTransactionsByLinkedProject(projectId), isEmpty);
        expect(await balances(), before);
      } finally {
        if (txId != null) await fin.deleteTransaction(txId);
        if (projectId != null) await dio.delete<void>('/api/projects/$projectId');
      }

      // 7. sau khi xoá dự án: số dư mọi ví bằng đúng lúc đầu
      expect(await balances(), before, reason: 'số dư mọi ví bằng đúng lúc đầu');
    },
    skip: missing ? 'Cần --dart-define=NSD_API_BASE_URL và NSD_API_TOKEN (backend thật)' : null,
    timeout: const Timeout(Duration(minutes: 2)),
  );

  test(
    'Việc hằng ngày: tạo → tick / bỏ tick → ngày không đến hạn (not_scheduled) → sửa → xoá (backend thật)',
    () async {
      final dio = Dio(BaseOptions(baseUrl: _baseUrl, headers: {'Authorization': 'Bearer $_token'}));
      final api = NghiSuDuongApi(dio);
      final today = vnToday();
      final todayWeekday = vnNow().weekday; // 1 = thứ Hai … 7 = Chủ nhật, cùng quy ước với backend
      final created = <String>[];

      final initial = (await api.getRoutines()).map((r) => r.id).toList();
      try {
        // 1. routine đủ 7 ngày
        final r1 = await api.createRoutine(name: 'TEST contract hằng ngày');
        created.add(r1.id);
        expect(r1.name, 'TEST contract hằng ngày');
        expect(r1.weekdays, [1, 2, 3, 4, 5, 6, 7]);
        expect(r1.dueToday, isTrue);
        expect(r1.doneToday, isFalse);
        expect(r1.streak, 0);
        expect(r1.last7, hasLength(7));
        expect(r1.last7.last.date, today, reason: 'phần tử cuối là hôm nay');
        expect(r1.last7.last.due, isTrue);
        expect(r1.last7.every((d) => !d.done), isTrue);
        expect([for (var i = 1; i < 7; i++) r1.last7[i].date.compareTo(r1.last7[i - 1].date) > 0].every((b) => b), isTrue, reason: 'cũ trước mới sau');

        // 2. tick hôm nay → doneToday true, streak 1; bỏ tick → doneToday false
        final ticked = await api.markRoutineDone(r1.id, today);
        expect(ticked.doneToday, isTrue);
        expect(ticked.streak, 1);
        expect(ticked.last7.last.done, isTrue);
        final listed = (await api.getRoutines()).firstWhere((r) => r.id == r1.id);
        expect((listed.doneToday, listed.streak), (true, 1));
        final unticked = await api.unmarkRoutineDone(r1.id, today);
        expect(unticked.doneToday, isFalse);
        expect(unticked.streak, 0);
        expect(unticked.last7.last.done, isFalse);

        // 3. routine không chứa thứ của hôm nay → tick bị not_scheduled
        final others = [for (var d = 1; d <= 7; d++) if (d != todayWeekday) d].take(2).toList();
        final r2 = await api.createRoutine(name: 'TEST contract nghỉ hôm nay', weekdays: others);
        created.add(r2.id);
        expect(r2.weekdays, others);
        expect(r2.dueToday, isFalse);
        Object? error;
        try {
          await api.markRoutineDone(r2.id, today);
        } catch (e) {
          error = e;
        }
        expect(error, isA<DioException>());
        expect((error as DioException).response?.statusCode, 400);
        expect(apiErrorCode(error), 'not_scheduled');
        expect((await api.getRoutines()).firstWhere((r) => r.id == r2.id).doneToday, isFalse);

        // 4. sửa tên và weekdays
        final patched = await api.updateRoutine(r1.id, {'name': 'TEST contract đã sửa', 'weekdays': [1, 2, 3]});
        expect(patched.name, 'TEST contract đã sửa');
        expect(patched.weekdays, [1, 2, 3]);
        expect(patched.dueToday, [1, 2, 3].contains(todayWeekday));
        expect(patched.last7, hasLength(7));
      } finally {
        // 5. xoá cả hai (lịch sử xoá theo)
        for (final id in created) {
          await api.deleteRoutine(id);
        }
      }
      expect((await api.getRoutines()).map((r) => r.id).toList(), initial, reason: 'danh sách về như lúc đầu');
    },
    skip: missing ? 'Cần --dart-define=NSD_API_BASE_URL và NSD_API_TOKEN (backend thật)' : null,
    timeout: const Timeout(Duration(minutes: 2)),
  );

  test(
    'Đóng dự án: tài liệu tổng kết vào Tàng Kinh Các → đóng lần nữa bị từ chối → mở lại → xoá dự án, tài liệu còn (backend thật)',
    () async {
      final dio = Dio(BaseOptions(baseUrl: _baseUrl, headers: {'Authorization': 'Bearer $_token'}));
      final api = NghiSuDuongApi(dio);
      final docs = DocumentApi(dio);
      String? projectId;
      String? documentId;
      var projectDeleted = false;

      final docsBefore = (await docs.getDocuments()).length;
      try {
        // 1. dự án có KR và việc (1 xong, 1 chưa)
        final name = 'TEST contract đóng ${DateTime.now().millisecondsSinceEpoch}';
        projectId = (await api.createProject(name: name, type: ProjectType.standard, goal: 'Mục tiêu đóng')).id;
        await api.createKeyResult(projectId, name: 'KR đóng', mode: KrMode.manual, unit: 'bài', target: 4);
        await api.createTask(projectId: projectId, title: 'Việc đã xong', status: TaskStatus.done);
        await api.createTask(projectId: projectId, title: 'Việc chưa xong');

        // 2. PATCH sang DONE bị từ chối → phải dùng closeProject
        Object? patchError;
        try {
          await api.updateProject(projectId, {'status': 'DONE'});
        } catch (e) {
          patchError = e;
        }
        expect(apiErrorCode(patchError!), 'use_close_endpoint');

        // 3. đóng với ghi chú → nhận documentId
        final closed = await api.closeProject(projectId, note: 'Ghi chú tổng kết thử hợp đồng');
        documentId = closed.documentId;
        expect(documentId, isNotEmpty);
        expect(closed.project.status, ProjectStatus.done);
        expect(closed.project.closedAt, isNotNull);
        expect((await api.getProject(projectId)).status, ProjectStatus.done);

        // 4. đọc tài liệu qua api Tàng Kinh Các của app
        final doc = (await docs.getDocuments()).firstWhere((d) => d.id == documentId);
        expect(doc.type, DocumentType.text);
        expect(doc.title, startsWith('Tổng kết dự án: $name — '));
        expect(doc.tags, containsAll(['du-an', 'tong-ket']));
        expect(doc.pinned, isFalse);
        expect(doc.topicId, isNull);
        final content = doc.content!;
        expect(content, contains('Dự án: $name'));
        expect(content, contains('Mục tiêu: Mục tiêu đóng'));
        expect(content, contains('- KR đóng: 0/4 bài (0%)'));
        expect(content, contains('Việc đã xong (1/2)'));
        expect(content, contains('- Việc đã xong'));
        expect(content, contains('Còn 1 việc chưa xong.'));
        expect(content, contains('Thu-chi: Thu 0₫ · Chi 0₫ · Ròng 0₫'));
        expect(content, contains('Ghi chú tổng kết\nGhi chú tổng kết thử hợp đồng'));

        // 5. đóng lần nữa → project_already_done
        Object? again;
        try {
          await api.closeProject(projectId);
        } catch (e) {
          again = e;
        }
        expect(apiErrorCode(again!), 'project_already_done');
        expect((await docs.getDocuments()).where((d) => d.title.startsWith('Tổng kết dự án: $name')), hasLength(1), reason: 'không tạo tài liệu thứ hai');

        // 6. mở lại: closedAt null, tài liệu giữ nguyên
        final reopened = await api.updateProject(projectId, {'status': 'ACTIVE'});
        expect(reopened.status, ProjectStatus.active);
        expect(reopened.closedAt, isNull);
        expect((await docs.getDocuments()).any((d) => d.id == documentId), isTrue);

        // 7. xoá dự án: tài liệu vẫn còn
        await api.deleteProject(projectId);
        projectDeleted = true;
        Object? gone;
        try {
          await api.getProject(projectId);
        } catch (e) {
          gone = e;
        }
        expect((gone as DioException).response?.statusCode, 404);
        expect((await docs.getDocuments()).any((d) => d.id == documentId), isTrue, reason: 'tài liệu tổng kết vẫn giữ sau khi xoá dự án');
      } finally {
        // 8. dọn
        if (projectId != null && !projectDeleted) await api.deleteProject(projectId);
        if (documentId != null) await docs.deleteDocument(documentId);
      }
      expect((await docs.getDocuments()).length, docsBefore, reason: 'số tài liệu về như lúc đầu');
    },
    skip: missing ? 'Cần --dart-define=NSD_API_BASE_URL và NSD_API_TOKEN (backend thật)' : null,
    timeout: const Timeout(Duration(minutes: 2)),
  );
}

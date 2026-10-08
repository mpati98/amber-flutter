import 'dart:async';

import 'package:amber_flutter/features/kieu_lau/models/activity_log_entry.dart';
import 'package:amber_flutter/features/kieu_lau/models/alert.dart';
import 'package:amber_flutter/features/kieu_lau/providers/kieu_lau_provider.dart';
import 'package:amber_flutter/features/nghi_su_duong/models/finance_account.dart';
import 'package:amber_flutter/features/nghi_su_duong/models/finance_category.dart';
import 'package:amber_flutter/features/nghi_su_duong/models/finance_transaction.dart';
import 'package:amber_flutter/features/nghi_su_duong/models/key_result.dart';
import 'package:amber_flutter/features/nghi_su_duong/models/overview.dart';
import 'package:amber_flutter/features/nghi_su_duong/models/project_detail.dart';
import 'package:amber_flutter/features/nghi_su_duong/models/project_summary.dart';
import 'package:amber_flutter/features/nghi_su_duong/models/routine.dart';
import 'package:amber_flutter/features/nghi_su_duong/models/task.dart';
import 'package:amber_flutter/features/nghi_su_duong/screens/project_detail_screen.dart';
import 'package:amber_flutter/features/nghi_su_duong/services/finance_api.dart';
import 'package:amber_flutter/features/nghi_su_duong/services/nghi_su_duong_api.dart';
import 'package:amber_flutter/shared/services/api_client.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

// Dữ liệu giả + tiện ích dùng chung cho test màn Chi tiết dự án / trang chi tiết việc / form việc.

final requests = <String>[];

Dio offlineDio() => Dio()
  ..interceptors.add(
    InterceptorsWrapper(
      onRequest: (o, h) {
        requests.add(o.path);
        h.reject(DioException(requestOptions: o, error: 'network blocked in test'));
      },
    ),
  );

KeyResult mkKr(
  String id,
  String name, {
  KrMode mode = KrMode.manual,
  String? unit,
  int target = 0,
  int current = 0,
  int linkedTotal = 0,
  int linkedDone = 0,
}) =>
    KeyResult(
      id: id,
      name: name,
      mode: mode,
      unit: unit,
      target: target,
      current: current,
      linkedTotal: linkedTotal,
      linkedDone: linkedDone,
      progress: mode == KrMode.auto
          ? (linkedTotal == 0 ? 0 : linkedDone / linkedTotal)
          : (target == 0 ? 0 : current / target),
    );

Task mkTask(
  String id,
  String title,
  TaskStatus status, {
  String? krId,
  bool milestone = false,
  String? due,
  String? start,
  TaskAttention? attention,
  List<ChecklistItem> checklist = const [],
  int created = 0,
}) =>
    Task(
      id: id,
      projectId: 'p1',
      krId: krId,
      title: title,
      status: status,
      importance: 2,
      urgency: 2,
      durationMinutes: 15,
      startDate: start,
      dueDate: due,
      isMilestone: milestone,
      attention: attention,
      checklistItems: checklist,
      createdAt: DateTime.utc(2026, 10, 1, 0, created),
    );

class FakeApi extends NghiSuDuongApi {
  FakeApi({required this.project, required this.tasks}) : super(offlineDio());

  ProjectDetail project;
  List<Task> tasks;
  final taskPatches = <Map<String, Object>>[];
  final taskUpdates = <Map<String, Object?>>[];
  final checklistPuts = <List<Map<String, Object?>>>[];
  final checklistPatches = <Map<String, Object?>>[];
  final taskDeletes = <String>[];
  Object? taskUpdateError;
  Object? checklistPutError;
  Object? checklistPatchError;
  Object? taskCreateError;
  final krPatches = <Map<String, Object?>>[];
  final krCreates = <Map<String, Object?>>[];
  final krDeletes = <String>[];
  final projectPatches = <Map<String, Object?>>[];
  final taskCreates = <Map<String, Object?>>[];
  int projectFetches = 0;
  int overviewFetches = 0;
  Completer<void>? gate;
  Object? projectPatchError;

  // ---- việc hằng ngày ----
  List<Routine> routines = [];
  List<ProjectSummary> summaryProjects = [];
  List<AttentionItem> summaryAttention = [];
  final routineMarks = <String>[]; // 'PUT id' / 'DELETE id'
  final routineCreates = <Map<String, Object?>>[];
  final routineUpdates = <Map<String, Object?>>[];
  final routineDeletes = <String>[];
  Completer<void>? routineGate;
  Object? routineError;

  Routine _setToday(String id, bool done) {
    final r = routines.firstWhere((x) => x.id == id).withDoneToday(done);
    routines = [for (final x in routines) x.id == id ? r : x];
    return r;
  }

  @override
  Future<List<Routine>> getRoutines({String? date}) async => List.of(routines);

  @override
  Future<Routine> markRoutineDone(String id, String date) async {
    routineMarks.add('PUT $id');
    await routineGate?.future;
    if (routineError case final e?) throw e;
    return _setToday(id, true);
  }

  @override
  Future<Routine> unmarkRoutineDone(String id, String date) async {
    routineMarks.add('DELETE $id');
    await routineGate?.future;
    if (routineError case final e?) throw e;
    return _setToday(id, false);
  }

  @override
  Future<Routine> createRoutine({required String name, List<int>? weekdays}) async {
    routineCreates.add({'name': name, 'weekdays': weekdays});
    await routineGate?.future;
    if (routineError case final e?) throw e;
    final r = mkRoutine('new-${routineCreates.length}', name, weekdays: weekdays ?? const [1, 2, 3, 4, 5, 6, 7]);
    routines = [...routines, r];
    return r;
  }

  @override
  Future<Routine> updateRoutine(String id, Map<String, Object?> patch) async {
    routineUpdates.add({'id': id, ...patch});
    await routineGate?.future;
    if (routineError case final e?) throw e;
    final old = routines.firstWhere((x) => x.id == id);
    final r = mkRoutine(id, (patch['name'] as String?) ?? old.name, weekdays: (patch['weekdays'] as List?)?.cast<int>() ?? old.weekdays);
    routines = [for (final x in routines) x.id == id ? r : x];
    return r;
  }

  @override
  Future<void> deleteRoutine(String id) async {
    routineDeletes.add(id);
    routines = routines.where((x) => x.id != id).toList();
  }

  @override
  Future<ProjectDetail> getProject(String id) async {
    projectFetches++;
    return project;
  }

  @override
  Future<List<Task>> getProjectTasks(String projectId) async => List.of(tasks);

  @override
  Future<Task> updateTask(String id, Map<String, Object?> patch) async {
    taskUpdates.add({'id': id, ...patch});
    final status = patch['status'] is String ? TaskStatus.fromApi(patch['status'] as String) : null;
    if (status != null) taskPatches.add({'id': id, 'status': status});
    await gate?.future;
    if (taskUpdateError case final e?) throw e;
    final i = tasks.indexWhere((t) => t.id == id);
    tasks[i] = tasks[i].copyWith(title: patch['title'] as String?, status: status);
    return tasks[i];
  }

  @override
  Future<List<ChecklistItem>> putChecklist(String taskId, List<ChecklistDraft> items) async {
    checklistPuts.add([for (final i in items) {'id': i.id, 'text': i.text, 'done': i.done}]);
    if (checklistPutError case final e?) throw e;
    final saved = [
      for (final (n, i) in items.indexed) ChecklistItem(id: i.id ?? 'new-$n', text: i.text, done: i.done, position: n),
    ];
    final idx = tasks.indexWhere((t) => t.id == taskId);
    tasks[idx] = tasks[idx].copyWith(checklistItems: saved);
    return saved;
  }

  @override
  Future<ChecklistItem> patchChecklistItem(String taskId, String itemId, {bool? done, String? text}) async {
    checklistPatches.add({'taskId': taskId, 'itemId': itemId, 'done': done, 'text': text});
    await gate?.future;
    if (checklistPatchError case final e?) throw e;
    final idx = tasks.indexWhere((t) => t.id == taskId);
    final items = [
      for (final i in tasks[idx].checklistItems)
        i.id == itemId ? ChecklistItem(id: i.id, text: text ?? i.text, done: done ?? i.done, position: i.position) : i,
    ];
    tasks[idx] = tasks[idx].copyWith(checklistItems: items);
    return items.firstWhere((i) => i.id == itemId);
  }

  @override
  Future<void> deleteTask(String id) async {
    taskDeletes.add(id);
    tasks = tasks.where((t) => t.id != id).toList();
  }

  @override
  Future<KeyResult> updateKeyResult(String projectId, String krId, Map<String, Object?> patch) async {
    krPatches.add({'krId': krId, ...patch});
    await gate?.future;
    final list = [...project.keyResults];
    final i = list.indexWhere((k) => k.id == krId);
    final k = list[i];
    list[i] = mkKr(
      k.id,
      (patch['name'] as String?) ?? k.name,
      mode: k.mode,
      unit: k.unit,
      target: (patch['target'] as int?) ?? k.target,
      current: (patch['current'] as int?) ?? k.current,
    );
    project = _with(keyResults: list);
    return list[i];
  }

  @override
  Future<KeyResult> createKeyResult(String projectId, {required String name, required KrMode mode, String? unit, int? target}) async {
    krCreates.add({'name': name, 'mode': mode, 'unit': unit, 'target': target});
    final k = mkKr('k-new', name, mode: mode, unit: unit, target: target ?? 0);
    project = _with(keyResults: [...project.keyResults, k]);
    return k;
  }

  @override
  Future<void> deleteKeyResult(String projectId, String krId) async {
    krDeletes.add(krId);
    project = _with(keyResults: project.keyResults.where((k) => k.id != krId).toList());
  }

  @override
  Future<ProjectDetail> updateProject(String id, Map<String, Object?> patch) async {
    projectPatches.add(patch);
    if (projectPatchError case final e?) throw e;
    if (patch['status'] is String) project = _with(status: ProjectStatus.fromApi(patch['status'] as String));
    return project;
  }

  final closes = <String?>[]; // ghi chú mỗi lần đóng
  final projectDeletes = <String>[];
  Object? closeError;
  Completer<void>? closeGate;

  @override
  Future<({ProjectDetail project, String documentId})> closeProject(String id, {String? note}) async {
    closes.add(note);
    await closeGate?.future;
    if (closeError case final e?) throw e;
    project = _with(status: ProjectStatus.done);
    return (project: project, documentId: 'doc-1');
  }

  @override
  Future<void> deleteProject(String id) async {
    projectDeletes.add(id);
  }

  @override
  Future<Task> createTask({
    required String projectId,
    required String title,
    TaskStatus? status,
    String? startDate,
    String? dueDate,
    bool? isMilestone,
    String? krId,
    bool? notifyDeadline,
    int? prepLeadDays,
    String? description,
  }) async {
    taskCreates.add({
      'projectId': projectId,
      'title': title,
      'status': status,
      'startDate': startDate,
      'dueDate': dueDate,
      'isMilestone': isMilestone,
      'krId': krId,
      'notifyDeadline': notifyDeadline,
      'prepLeadDays': prepLeadDays,
      'description': description,
    });
    await gate?.future;
    if (taskCreateError case final e?) throw e;
    final t = mkTask('t-new', title, status ?? TaskStatus.prep, krId: krId, milestone: isMilestone ?? false, due: dueDate);
    tasks = [...tasks, t];
    return t;
  }

  @override
  Future<DuAnOverview> getDuAnOverview({int? year}) async {
    overviewFetches++;
    return const DuAnOverview(year: 2026, activeProjects: [], completedThisYear: 0, upcomingProjects: []);
  }

  @override
  Future<DuAnSummary> getDuAnSummary() async => DuAnSummary(projects: summaryProjects, attention: summaryAttention);

  ProjectDetail _with({List<KeyResult>? keyResults, ProjectStatus? status}) => ProjectDetail(
        id: project.id,
        name: project.name,
        goal: project.goal,
        status: status ?? project.status,
        startDate: project.startDate,
        endDate: project.endDate,
        keyResults: keyResults ?? project.keyResults,
      );
}

/// Api tài chính giả: giao dịch gắn với dự án + ví + danh mục. Ghi lại các lệnh gọi.
class FakeFinanceApi extends FinanceApi {
  FakeFinanceApi({List<FinanceTransaction>? transactions, List<FinanceAccount>? accounts, List<FinanceCategory>? categories})
      : transactions = [...?transactions],
        accounts = accounts ?? [...defaultAccounts],
        categories = categories ?? [...defaultCategories],
        super(offlineDio());

  static const defaultAccounts = [
    FinanceAccount(id: 'w1', name: 'Tiền mặt', type: AccountType.cash, currentBalance: 1000000),
    FinanceAccount(id: 'w2', name: 'Momo', type: AccountType.eWallet, currentBalance: 500000),
  ];
  static const defaultCategories = [
    FinanceCategory(id: 'c-food', name: 'Ăn uống', icon: '🍜', kind: MoneyKind.expense),
    FinanceCategory(id: 'c-rent', name: 'Thuê địa điểm', kind: MoneyKind.expense),
    FinanceCategory(id: 'c-sal', name: 'Lương', icon: '💰', kind: MoneyKind.income),
  ];

  List<FinanceTransaction> transactions;
  List<FinanceAccount> accounts;
  List<FinanceCategory> categories;
  final creates = <Map<String, Object?>>[];
  final updates = <Map<String, Object?>>[];
  final deletes = <String>[];
  Object? createError;
  Object? updateError;
  Completer<void>? gate;

  @override
  Future<List<FinanceTransaction>> getTransactionsByLinkedProject(String linkedProjectId) async =>
      transactions.where((t) => t.linkedProjectId == linkedProjectId).toList();

  @override
  Future<List<FinanceAccount>> getAccounts() async => accounts;

  @override
  Future<List<FinanceCategory>> getCategories({MoneyKind? kind}) async => categories;

  @override
  Future<FinanceTransaction> createTransaction({
    String? projectId,
    String? linkedProjectId,
    required String accountId,
    String? categoryId,
    required MoneyKind kind,
    required double amount,
    String? note,
    DateTime? occurredAt,
  }) async {
    creates.add({
      'projectId': projectId,
      'linkedProjectId': linkedProjectId,
      'accountId': accountId,
      'categoryId': categoryId,
      'kind': kind,
      'amount': amount,
      'note': note,
      'occurredAt': occurredAt,
    });
    await gate?.future;
    if (createError case final e?) throw e;
    final t = mkTx('new-${creates.length}', kind: kind, amount: amount, note: note, linked: linkedProjectId, accountId: accountId, categoryId: categoryId);
    transactions = [t, ...transactions];
    return t;
  }

  @override
  Future<FinanceTransaction> updateTransaction(String id, Map<String, Object?> patch) async {
    updates.add({'id': id, ...patch});
    await gate?.future;
    if (updateError case final e?) throw e;
    final i = transactions.indexWhere((t) => t.id == id);
    final old = transactions[i];
    final next = mkTx(
      id,
      kind: patch['kind'] is String ? MoneyKind.fromApi(patch['kind'] as String) : old.kind,
      amount: patch.containsKey('amount') ? (patch['amount'] as num).toDouble() : old.amount,
      note: patch.containsKey('note') ? patch['note'] as String? : old.note,
      linked: patch.containsKey('linkedProjectId') ? patch['linkedProjectId'] as String? : old.linkedProjectId,
      accountId: (patch['accountId'] as String?) ?? old.accountId,
      categoryId: patch.containsKey('categoryId') ? patch['categoryId'] as String? : old.categoryId,
      occurredAt: old.occurredAt,
    );
    transactions = [...transactions]..[i] = next;
    if (next.linkedProjectId == null) transactions.removeAt(i);
    return next;
  }

  @override
  Future<void> deleteTransaction(String id) async {
    deletes.add(id);
    transactions = transactions.where((t) => t.id != id).toList();
  }
}

/// Việc hằng ngày giả: [done] là các chỉ số 0–6 trong last7 đã làm (6 = hôm nay), [dueDays] các chỉ số
/// đến hạn (mặc định cả 7).
Routine mkRoutine(
  String id,
  String name, {
  List<int> weekdays = const [1, 2, 3, 4, 5, 6, 7],
  bool dueToday = true,
  Set<int> done = const {},
  Set<int>? dueDays,
  int streak = 0,
}) =>
    Routine(
      id: id,
      name: name,
      weekdays: weekdays,
      dueToday: dueToday,
      doneToday: done.contains(6),
      streak: streak,
      last7: [
        for (var i = 0; i < 7; i++)
          RoutineDay(date: '2026-10-0${i + 2}', due: dueDays == null ? (i == 6 ? dueToday : true) : dueDays.contains(i), done: done.contains(i)),
      ],
    );

/// Giao dịch giả gắn với dự án p1 (mặc định).
FinanceTransaction mkTx(
  String id, {
  MoneyKind kind = MoneyKind.expense,
  double amount = 100000,
  String? note,
  String? linked = 'p1',
  String accountId = 'w1',
  String? categoryId,
  DateTime? occurredAt,
}) {
  final cat = FakeFinanceApi.defaultCategories.where((c) => c.id == categoryId).firstOrNull;
  final acc = FakeFinanceApi.defaultAccounts.where((a) => a.id == accountId).firstOrNull;
  return FinanceTransaction(
    id: id,
    projectId: 'month1',
    linkedProjectId: linked,
    accountId: accountId,
    categoryId: categoryId,
    kind: kind,
    amount: amount,
    note: note,
    occurredAt: occurredAt ?? DateTime.now(),
    categoryName: cat?.name,
    categoryIcon: cat?.icon,
    accountName: acc?.name,
  );
}

ProjectDetail mkProject({
  ProjectStatus status = ProjectStatus.active,
  String? goal,
  List<KeyResult> krs = const [],
  String? start,
  String? end,
}) =>
    ProjectDetail(id: 'p1', name: 'Sự kiện tháng 11', goal: goal, status: status, startDate: start, endDate: end, keyResults: krs);

Future<FakeApi> pumpDetail(
  WidgetTester tester, {
  ProjectDetail? project,
  List<Task> tasks = const [],
  double width = 390,
  FakeFinanceApi? finance,
}) async {
  requests.clear();
  final api = FakeApi(project: project ?? mkProject(), tasks: [...tasks]);
  tester.view.physicalSize = Size(width, 4000);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  final router = GoRouter(
    initialLocation: '/du-an/p1',
    routes: [GoRoute(path: '/du-an/:id', builder: (_, s) => ProjectDetailScreen(projectId: s.pathParameters['id']!))],
  );
  addTearDown(router.dispose);
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        apiClientProvider.overrideWithValue(offlineDio()),
        nghiSuDuongApiProvider.overrideWithValue(api),
        financeApiProvider.overrideWithValue(finance ?? FakeFinanceApi()),
        notificationsProvider.overrideWith((ref) async => (alerts: const <Alert>[], recentActivity: const <ActivityLogEntry>[])),
      ],
      child: MaterialApp.router(theme: ThemeData.dark(), routerConfig: router),
    ),
  );
  await tester.pumpAndSettle();
  return api;
}

Finder taskCard(String id) => find.byKey(ValueKey('task-$id'));
Finder inCard(String id, Finder f) => find.descendant(of: taskCard(id), matching: f);
IconButton btnOf(WidgetTester tester, Finder f) =>
    tester.widget<IconButton>(find.ancestor(of: f, matching: find.byType(IconButton)).first);



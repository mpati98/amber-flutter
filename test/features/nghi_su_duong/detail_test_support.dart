import 'dart:async';

import 'package:amber_flutter/features/kieu_lau/models/activity_log_entry.dart';
import 'package:amber_flutter/features/kieu_lau/models/alert.dart';
import 'package:amber_flutter/features/kieu_lau/providers/kieu_lau_provider.dart';
import 'package:amber_flutter/features/nghi_su_duong/models/key_result.dart';
import 'package:amber_flutter/features/nghi_su_duong/models/overview.dart';
import 'package:amber_flutter/features/nghi_su_duong/models/project_detail.dart';
import 'package:amber_flutter/features/nghi_su_duong/models/project_summary.dart';
import 'package:amber_flutter/features/nghi_su_duong/models/task.dart';
import 'package:amber_flutter/features/nghi_su_duong/screens/project_detail_screen.dart';
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
    return project;
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
  Future<DuAnSummary> getDuAnSummary() async => const DuAnSummary(projects: [], attention: []);

  ProjectDetail _with({List<KeyResult>? keyResults}) => ProjectDetail(
        id: project.id,
        name: project.name,
        goal: project.goal,
        status: project.status,
        startDate: project.startDate,
        endDate: project.endDate,
        keyResults: keyResults ?? project.keyResults,
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



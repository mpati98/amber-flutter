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
import 'package:amber_flutter/features/nghi_su_duong/widgets/key_results_block.dart';
import 'package:amber_flutter/features/nghi_su_duong/widgets/project_header.dart';
import 'package:amber_flutter/features/nghi_su_duong/widgets/task_board.dart';
import 'package:amber_flutter/shared/services/api_client.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

// Màn Chi tiết dự án: đầu trang, Kết quả then chốt, bảng Kanban. API giả.

final _requests = <String>[];

Dio _offlineDio() => Dio()
  ..interceptors.add(
    InterceptorsWrapper(
      onRequest: (o, h) {
        _requests.add(o.path);
        h.reject(DioException(requestOptions: o, error: 'network blocked in test'));
      },
    ),
  );

KeyResult _kr(
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

Task _t(
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

class _FakeApi extends NghiSuDuongApi {
  _FakeApi({required this.project, required this.tasks}) : super(_offlineDio());

  ProjectDetail project;
  List<Task> tasks;
  final taskPatches = <Map<String, Object>>[];
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
  Future<Task> updateTask(String id, {String? title, TaskStatus? status, int? importance}) async {
    taskPatches.add({'id': id, 'status': ?status});
    await gate?.future;
    final i = tasks.indexWhere((t) => t.id == id);
    tasks[i] = tasks[i].copyWith(status: status);
    return tasks[i];
  }

  @override
  Future<KeyResult> updateKeyResult(String projectId, String krId, Map<String, Object?> patch) async {
    krPatches.add({'krId': krId, ...patch});
    await gate?.future;
    final list = [...project.keyResults];
    final i = list.indexWhere((k) => k.id == krId);
    final k = list[i];
    list[i] = _kr(
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
    final k = _kr('k-new', name, mode: mode, unit: unit, target: target ?? 0);
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
    required int importance,
    required int urgency,
    int durationMinutes = 15,
    String? startDate,
    String? dueDate,
  }) async {
    taskCreates.add({'projectId': projectId, 'title': title});
    final t = _t('t-new', title, TaskStatus.prep);
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

ProjectDetail _project({
  ProjectStatus status = ProjectStatus.active,
  String? goal,
  List<KeyResult> krs = const [],
  String? start,
  String? end,
}) =>
    ProjectDetail(id: 'p1', name: 'Sự kiện tháng 11', goal: goal, status: status, startDate: start, endDate: end, keyResults: krs);

Future<_FakeApi> _pump(
  WidgetTester tester, {
  ProjectDetail? project,
  List<Task> tasks = const [],
  double width = 390,
}) async {
  _requests.clear();
  final api = _FakeApi(project: project ?? _project(), tasks: [...tasks]);
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
        apiClientProvider.overrideWithValue(_offlineDio()),
        nghiSuDuongApiProvider.overrideWithValue(api),
        notificationsProvider.overrideWith((ref) async => (alerts: const <Alert>[], recentActivity: const <ActivityLogEntry>[])),
      ],
      child: MaterialApp.router(theme: ThemeData.dark(), routerConfig: router),
    ),
  );
  await tester.pumpAndSettle();
  return api;
}

Finder _card(String id) => find.byKey(ValueKey('task-$id'));
Finder _in(String id, Finder f) => find.descendant(of: _card(id), matching: f);
IconButton _btn(WidgetTester tester, Finder f) =>
    tester.widget<IconButton>(find.ancestor(of: f, matching: find.byType(IconButton)).first);

void main() {
  group('đầu trang', () {
    test('detailBadge: 4 trường hợp nhãn trạng thái', () {
      expect(detailBadge(ProjectStatus.paused, 5)?.label, 'Tạm dừng');
      expect(detailBadge(ProjectStatus.done, 0)?.label, 'Đã xong');
      final warn = detailBadge(ProjectStatus.active, 2);
      expect(warn?.label, '2 việc cần xử lý');
      expect(warn?.warning, isTrue);
      expect(detailBadge(ProjectStatus.active, 0)?.label, 'Đúng nhịp');
    });

    testWidgets('tên, mục tiêu, khoảng ngày, nhãn, mốc kế tiếp (việc mốc chưa xong, hạn sớm nhất)', (tester) async {
      await _pump(
        tester,
        project: _project(goal: 'Tổ chức thành công', start: '2026-10-06', end: '2026-12-31'),
        tasks: [
          _t('a', 'Việc quá hạn', TaskStatus.prep, attention: const TaskAttention(kind: 'OVERDUE', days: 3)),
          _t('b', 'Mốc xa', TaskStatus.prep, milestone: true, due: '2026-11-20'),
          _t('c', 'Mốc gần', TaskStatus.inProgress, milestone: true, due: '2026-10-14'),
          _t('d', 'Mốc đã xong', TaskStatus.done, milestone: true, due: '2026-10-01'),
        ],
      );
      expect(find.text('Tổ chức thành công'), findsOneWidget);
      expect(find.text('06/10 – 31/12'), findsOneWidget);
      expect(find.text('1 việc cần xử lý'), findsOneWidget);
      expect(find.text('Mốc kế tiếp: Mốc gần · 14/10'), findsOneWidget);
    });

    testWidgets('không có mục tiêu / mốc / việc cần xử lý', (tester) async {
      await _pump(tester, tasks: [_t('a', 'Việc', TaskStatus.prep)]);
      expect(find.text('Chưa ghi mục tiêu.'), findsOneWidget);
      expect(find.text('Chưa có ngày'), findsWidgets);
      expect(find.text('Chưa có mốc sắp tới'), findsOneWidget);
      expect(find.text('Đúng nhịp'), findsOneWidget);
    });

    testWidgets('PAUSED và DONE hiện nhãn trạng thái dù có việc cần xử lý', (tester) async {
      await _pump(tester, project: _project(status: ProjectStatus.paused), tasks: [_t('a', 'x', TaskStatus.prep, attention: const TaskAttention(kind: 'IDLE', days: 6))]);
      expect(find.text('Tạm dừng'), findsOneWidget);
      expect(find.text('1 việc cần xử lý'), findsNothing);
    });

    testWidgets('Sửa dự án: chỉ gửi trường đổi; end_before_start → câu báo', (tester) async {
      final api = await _pump(tester, project: _project(goal: 'Cũ', start: '2026-10-06'));
      await tester.tap(find.text('Sửa dự án'));
      await tester.pumpAndSettle();
      expect(find.widgetWithText(AppBar, 'Sửa dự án'), findsOneWidget);
      expect(tester.widget<FilledButton>(find.widgetWithText(FilledButton, 'Lưu')).onPressed, isNull, reason: 'chưa đổi gì');

      await tester.enterText(find.widgetWithText(TextField, 'Tên dự án'), 'Tên mới');
      await tester.tap(find.widgetWithText(ChoiceChip, 'Tạm dừng'));
      await tester.pump();
      final req = RequestOptions(path: '/api/projects/p1');
      api.projectPatchError = DioException(
        requestOptions: req,
        type: DioExceptionType.badResponse,
        response: Response(requestOptions: req, statusCode: 400, data: {'error': 'end_before_start'}),
      );
      await tester.tap(find.widgetWithText(FilledButton, 'Lưu'));
      await tester.pumpAndSettle();
      expect(api.projectPatches.single, {'name': 'Tên mới', 'status': 'PAUSED'});
      expect(find.text('Hạn phải sau ngày bắt đầu.'), findsOneWidget);

      api.projectPatchError = null;
      final fetches = api.projectFetches;
      await tester.tap(find.widgetWithText(FilledButton, 'Lưu'));
      await tester.pumpAndSettle();
      expect(find.byType(Dialog), findsNothing);
      expect(api.projectFetches, greaterThan(fetches), reason: 'làm mới dữ liệu màn này');
    });
  });

  group('Kết quả then chốt', () {
    final krs = [
      _kr('k1', 'Bán vé', unit: 'vé', target: 4, current: 2),
      _kr('k2', 'Hoàn thành khâu chuẩn bị', mode: KrMode.auto, linkedTotal: 3, linkedDone: 1),
      _kr('k3', 'Truyền thông', mode: KrMode.auto),
    ];

    test('keyResultValueLabel: ba dạng giá trị', () {
      expect(keyResultValueLabel(krs[0]), '2 / 4 vé');
      expect(keyResultValueLabel(krs[1]), '1 / 3');
      expect(keyResultValueLabel(krs[2]), 'Chưa gắn việc');
      expect(keyResultValueLabel(_kr('k', 'x', target: 10, current: 3)), '3 / 10');
    });

    testWidgets('mỗi KR một dòng: nhãn KR n, tên, cách tính, giá trị', (tester) async {
      await _pump(tester, project: _project(krs: krs));
      for (final s in ['KR 1', 'KR 2', 'KR 3', 'Bán vé', 'Truyền thông', '2 / 4 vé', '1 / 3', 'Chưa gắn việc', 'nhập tay']) {
        expect(find.text(s), findsOneWidget, reason: s);
      }
      expect(find.text('tự đếm từ việc'), findsNWidgets(2));
      expect(tester.takeException(), isNull);
    });

    testWidgets('chưa có KR → dòng trống', (tester) async {
      await _pump(tester);
      expect(find.text('Dự án chưa có kết quả then chốt nào.'), findsOneWidget);
    });

    testWidgets('nút tăng gửi PATCH current đúng giá trị; khoá ở target; giảm khoá ở 0', (tester) async {
      final api = await _pump(tester, project: _project(krs: [_kr('k1', 'Bán vé', unit: 'vé', target: 4, current: 3)]));
      await tester.tap(find.byTooltip('Tăng 1'));
      await tester.pumpAndSettle();
      expect(api.krPatches.single, {'krId': 'k1', 'current': 4});
      expect(find.text('4 / 4 vé'), findsOneWidget);
      expect(_btn(tester, find.byTooltip('Tăng 1')).onPressed, isNull, reason: 'đạt target');

      await tester.tap(find.byTooltip('Giảm 1'));
      await tester.pumpAndSettle();
      expect(api.krPatches.last, {'krId': 'k1', 'current': 3});
    });

    testWidgets('nút giảm khoá ở 0; KR AUTO không có nút tăng / giảm', (tester) async {
      await _pump(tester, project: _project(krs: [_kr('k1', 'a', target: 4), _kr('k2', 'b', mode: KrMode.auto)]));
      expect(_btn(tester, find.byTooltip('Giảm 1')).onPressed, isNull);
      expect(find.byTooltip('Tăng 1'), findsOneWidget, reason: 'chỉ KR MANUAL');
    });

    testWidgets('khoá trong lúc đang gửi: bấm liên tiếp chỉ 1 PATCH', (tester) async {
      final api = await _pump(tester, project: _project(krs: [_kr('k1', 'Bán vé', target: 4, current: 1)]));
      api.gate = Completer();
      await tester.tap(find.byTooltip('Tăng 1'));
      await tester.pump();
      expect(_btn(tester, find.byTooltip('Tăng 1')).onPressed, isNull);
      await tester.tap(find.byTooltip('Tăng 1'), warnIfMissed: false);
      await tester.pump();
      expect(api.krPatches, hasLength(1));
      api.gate!.complete();
      await tester.pumpAndSettle();
      expect(api.krPatches, hasLength(1));
    });

    testWidgets('Thêm KR nhập tay: cần tên và mục tiêu ≥ 1; gửi đúng trường', (tester) async {
      final api = await _pump(tester);
      await tester.tap(find.text('Thêm KR'));
      await tester.pumpAndSettle();
      expect(find.widgetWithText(AppBar, 'Thêm KR'), findsOneWidget);
      FilledButton add() => tester.widget<FilledButton>(find.widgetWithText(FilledButton, 'Thêm'));
      await tester.enterText(find.widgetWithText(TextField, 'Tên KR'), 'Bán vé');
      await tester.pump();
      expect(add().onPressed, isNotNull, reason: 'mặc định tự đếm: chỉ cần tên');

      await tester.tap(find.widgetWithText(ChoiceChip, 'Nhập tay theo con số'));
      await tester.pump();
      expect(add().onPressed, isNull, reason: 'nhập tay thiếu mục tiêu');
      await tester.enterText(find.widgetWithText(TextField, 'Mục tiêu (số nguyên ≥ 1)'), '0');
      await tester.pump();
      expect(add().onPressed, isNull);
      await tester.enterText(find.widgetWithText(TextField, 'Mục tiêu (số nguyên ≥ 1)'), '50');
      await tester.enterText(find.widgetWithText(TextField, 'Đơn vị (tuỳ chọn)'), 'vé');
      await tester.pump();
      await tester.tap(find.widgetWithText(FilledButton, 'Thêm'));
      await tester.pumpAndSettle();

      expect(api.krCreates.single, {'name': 'Bán vé', 'mode': KrMode.manual, 'unit': 'vé', 'target': 50});
      expect(find.text('KR 1'), findsOneWidget);
    });

    testWidgets('Sửa KR: chỉ gửi trường đổi; Xoá KR hỏi lại, Huỷ không gọi API, Xoá thì xoá', (tester) async {
      final api = await _pump(tester, project: _project(krs: [_kr('k1', 'Bán vé', target: 4, current: 2)]));
      await tester.tap(find.byTooltip('Sửa KR'));
      await tester.pumpAndSettle();
      expect(find.widgetWithText(AppBar, 'Sửa KR'), findsOneWidget);
      await tester.enterText(find.widgetWithText(TextField, 'Mục tiêu (số nguyên ≥ 1)'), '8');
      await tester.pump();
      await tester.tap(find.widgetWithText(FilledButton, 'Lưu'));
      await tester.pumpAndSettle();
      expect(api.krPatches.single, {'krId': 'k1', 'target': 8});

      await tester.tap(find.byTooltip('Sửa KR'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Xoá KR'));
      await tester.pumpAndSettle();
      expect(find.text('Xoá KR này? Các việc đang gắn sẽ thành không gắn.'), findsOneWidget);
      await tester.tap(find.text('Huỷ'));
      await tester.pumpAndSettle();
      expect(api.krDeletes, isEmpty);

      await tester.tap(find.text('Xoá KR'));
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(TextButton, 'Xoá'));
      await tester.pumpAndSettle();
      expect(api.krDeletes, ['k1']);
      expect(find.byType(Dialog), findsNothing);
      expect(find.text('Dự án chưa có kết quả then chốt nào.'), findsOneWidget);
    });
  });

  group('bảng việc', () {
    testWidgets('4 nhóm đúng thứ tự; nhóm rỗng "Trống"; đếm việc xong', (tester) async {
      await _pump(tester, tasks: [_t('a', 'Việc A', TaskStatus.prep), _t('b', 'Việc B', TaskStatus.done)]);
      final ys = [for (final s in ['Chờ', 'Đang làm', 'Thẩm định', 'Xong']) tester.getTopLeft(find.text(s).first).dy];
      expect(ys, orderedEquals([...ys]..sort()));
      expect(find.text('Trống'), findsNWidgets(2));
      expect(find.text('1 / 2 việc xong'), findsOneWidget);
      expect(find.text('Thêm việc'), findsOneWidget);
    });

    testWidgets('"Đang làm" có 2 việc: "2 / 2"; 3 việc: "Vượt WIP 3 / 2"', (tester) async {
      await _pump(tester, tasks: [_t('a', 'A', TaskStatus.inProgress), _t('b', 'B', TaskStatus.inProgress)]);
      expect(find.text('2 / 2'), findsOneWidget);
      expect(find.textContaining('Vượt WIP'), findsNothing);

      await _pump(tester, tasks: [for (final i in [1, 2, 3]) _t('t$i', 'Việc $i', TaskStatus.inProgress)]);
      expect(find.text('Vượt WIP 3 / 2'), findsOneWidget);
    });

    testWidgets('thứ tự trong nhóm: hạn tăng dần, không có hạn xuống cuối, rồi createdAt', (tester) async {
      await _pump(tester, tasks: [
        _t('a', 'Không hạn cũ', TaskStatus.prep, created: 1),
        _t('b', 'Hạn xa', TaskStatus.prep, due: '2026-12-01'),
        _t('c', 'Không hạn mới', TaskStatus.prep, created: 5),
        _t('d', 'Hạn gần', TaskStatus.prep, due: '2026-11-01'),
      ]);
      final order = ['Hạn gần', 'Hạn xa', 'Không hạn cũ', 'Không hạn mới'];
      final ys = [for (final t in order) tester.getTopLeft(find.text(t)).dy];
      expect(ys, orderedEquals([...ys]..sort()));
    });

    test('compareBoardTasks', () {
      final a = _t('a', 'a', TaskStatus.prep, due: '2026-10-01');
      final b = _t('b', 'b', TaskStatus.prep);
      expect(compareBoardTasks(a, b), lessThan(0));
      expect(compareBoardTasks(b, a), greaterThan(0));
    });

    testWidgets('thẻ việc: nhãn KR / Không gắn KR / Mốc, cảnh báo, checklist, dòng hạn', (tester) async {
      await _pump(
        tester,
        project: _project(krs: [_kr('k1', 'KR một', target: 3), _kr('k2', 'KR hai', target: 3)]),
        tasks: [
          _t('a', 'Gắn KR hai', TaskStatus.prep, krId: 'k2', due: '2026-10-20', attention: const TaskAttention(kind: 'OVERDUE', days: 3)),
          _t('b', 'Việc mốc', TaskStatus.inProgress, milestone: true, due: '2026-10-14', attention: const TaskAttention(kind: 'IDLE', days: 6)),
          _t('c', 'Có checklist', TaskStatus.review, checklist: const [
            ChecklistItem(id: 'c1', text: 'x', done: true, position: 0),
            ChecklistItem(id: 'c2', text: 'y', done: false, position: 1),
            ChecklistItem(id: 'c3', text: 'z', done: false, position: 2),
          ]),
          _t('d', 'Đã xong', TaskStatus.done, due: '2026-10-01'),
        ],
      );
      expect(_in('a', find.text('KR 2')), findsOneWidget);
      expect(_in('a', find.text('Quá hạn 3 ngày')), findsOneWidget);
      expect(_in('a', find.text('Hạn 20/10')), findsOneWidget);
      expect(_in('b', find.text('Mốc')), findsOneWidget);
      expect(_in('b', find.text('Nằm im 6 ngày')), findsOneWidget);
      expect(_in('b', find.text('14/10')), findsOneWidget, reason: 'việc mốc chỉ hiện dd/MM');
      expect(_in('c', find.text('Không gắn KR')), findsOneWidget);
      expect(_in('c', find.text('1 / 3')), findsOneWidget);
      expect(_in('c', find.text('Chưa có ngày')), findsOneWidget);
      expect(_in('d', find.text('Xong')), findsOneWidget);
      expect(_in('a', find.byType(Checkbox)), findsNothing, reason: 'không còn ô tick');
    });

    testWidgets('nút tiến chuyển sang nhóm sau (PATCH status đúng) và thẻ đổi nhóm', (tester) async {
      final api = await _pump(tester, tasks: [_t('a', 'Việc A', TaskStatus.inProgress)]);
      expect(find.text('1 / 2'), findsOneWidget);
      await tester.tap(_in('a', find.byTooltip('Chuyển sang Thẩm định')));
      await tester.pumpAndSettle();
      expect(api.taskPatches.single, {'id': 'a', 'status': TaskStatus.review});
      expect(find.text('0 / 2'), findsOneWidget, reason: 'cột Đang làm đã trống');
      expect(tester.getTopLeft(find.text('Việc A')).dy, greaterThan(tester.getTopLeft(find.text('Thẩm định').first).dy));
      expect(_in('a', find.byTooltip('Chuyển về Đang làm')), findsOneWidget);

      await tester.tap(_in('a', find.byTooltip('Chuyển về Đang làm')));
      await tester.pumpAndSettle();
      expect(api.taskPatches.last, {'id': 'a', 'status': TaskStatus.inProgress});
    });

    testWidgets('bấm hai lần liên tiếp chỉ gửi 1 PATCH (kể cả khi thẻ đã sang nhóm khác)', (tester) async {
      final api = await _pump(tester, tasks: [_t('a', 'Việc A', TaskStatus.prep)]);
      api.gate = Completer();
      await tester.tap(_in('a', find.byTooltip('Chuyển sang Đang làm')));
      await tester.pump();
      expect(_btn(tester, _in('a', find.byTooltip('Chuyển sang Thẩm định'))).onPressed, isNull, reason: 'khoá trong lúc gửi');
      expect(_btn(tester, _in('a', find.byTooltip('Chuyển về Chờ'))).onPressed, isNull);
      await tester.tap(_in('a', find.byTooltip('Chuyển sang Thẩm định')), warnIfMissed: false);
      await tester.pump();
      expect(api.taskPatches, hasLength(1));
      api.gate!.complete();
      await tester.pumpAndSettle();
      expect(api.taskPatches, hasLength(1));
      expect(_btn(tester, _in('a', find.byTooltip('Chuyển sang Thẩm định'))).onPressed, isNotNull, reason: 'mở khoá sau khi xong');
    });

    testWidgets('khoá nút lùi ở nhóm đầu, nút tiến ở nhóm cuối', (tester) async {
      await _pump(tester, tasks: [_t('a', 'A', TaskStatus.prep), _t('d', 'D', TaskStatus.done)]);
      expect(_btn(tester, _in('a', find.byTooltip('Đã ở nhóm đầu'))).onPressed, isNull);
      expect(_btn(tester, _in('a', find.byTooltip('Chuyển sang Đang làm'))).onPressed, isNotNull);
      expect(_btn(tester, _in('d', find.byTooltip('Đã ở nhóm cuối'))).onPressed, isNull);
    });

    testWidgets('bề rộng 390: xếp dọc, không tràn; bề rộng 1200: 4 cột cạnh nhau', (tester) async {
      final tasks = [_t('a', 'A', TaskStatus.prep), _t('b', 'B', TaskStatus.inProgress), _t('c', 'C', TaskStatus.review), _t('d', 'D', TaskStatus.done)];
      await _pump(tester, tasks: tasks, project: _project(krs: [_kr('k1', 'Bán vé một tên khá dài để thử tràn ngang', unit: 'vé', target: 4, current: 2)]));
      expect(tester.takeException(), isNull);
      expect({for (final t in ['A', 'B', 'C', 'D']) tester.getTopLeft(find.text(t)).dx}.length, 1);

      await _pump(tester, tasks: tasks, width: 1200);
      expect(tester.takeException(), isNull);
      expect({for (final t in ['A', 'B', 'C', 'D']) tester.getTopLeft(find.text(t)).dy}.length, 1, reason: 'cùng hàng');
      expect({for (final t in ['A', 'B', 'C', 'D']) tester.getTopLeft(find.text(t)).dx}.length, 4);
    });

    testWidgets('chạm thẻ mở form sửa việc', (tester) async {
      await _pump(tester, tasks: [_t('a', 'Việc A', TaskStatus.prep)]);
      await tester.tap(find.text('Việc A'));
      await tester.pumpAndSettle();
      expect(find.widgetWithText(AppBar, 'Sửa việc'), findsOneWidget);
    });
  });

  group('Thêm việc', () {
    testWidgets('dùng được khi dự án PAUSED: không có ô chọn dự án, tạo đúng projectId, không cần overview', (tester) async {
      final api = await _pump(tester, project: _project(status: ProjectStatus.paused));
      final overview = api.overviewFetches;
      await tester.tap(find.text('Thêm việc'));
      await tester.pumpAndSettle();
      expect(find.widgetWithText(AppBar, 'Thêm việc'), findsOneWidget);
      expect(find.byType(DropdownButtonFormField<String>), findsNothing);
      await tester.enterText(find.widgetWithText(TextField, 'Tên việc'), 'Việc mới');
      await tester.pump();
      await tester.tap(find.widgetWithText(FilledButton, 'Tạo việc'));
      await tester.pumpAndSettle();
      expect(api.taskCreates.single, {'projectId': 'p1', 'title': 'Việc mới'});
      expect(find.text('Việc mới'), findsOneWidget, reason: 'bảng được làm mới');
      expect(api.overviewFetches, greaterThanOrEqualTo(overview));
    });
  });
}

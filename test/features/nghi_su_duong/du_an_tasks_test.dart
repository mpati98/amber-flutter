import 'dart:async';

import 'package:amber_flutter/features/kieu_lau/models/activity_log_entry.dart';
import 'package:amber_flutter/features/kieu_lau/models/alert.dart';
import 'package:amber_flutter/features/kieu_lau/providers/kieu_lau_provider.dart';
import 'package:amber_flutter/features/nghi_su_duong/models/overview.dart';
import 'package:amber_flutter/features/nghi_su_duong/models/project.dart';
import 'package:amber_flutter/features/nghi_su_duong/models/project_detail.dart';
import 'package:amber_flutter/features/nghi_su_duong/models/project_summary.dart';
import 'package:amber_flutter/features/nghi_su_duong/models/task.dart';
import 'package:amber_flutter/features/nghi_su_duong/screens/du_an_screen.dart';
import 'package:amber_flutter/features/nghi_su_duong/screens/project_detail_screen.dart';
import 'package:amber_flutter/features/nghi_su_duong/services/nghi_su_duong_api.dart';
import 'package:amber_flutter/shared/providers/auth_provider.dart';
import 'package:amber_flutter/shared/services/api_client.dart';
import 'package:amber_flutter/shared/utils/vn_time.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

// Sửa / xoá việc (form) + form Thêm dự án. API giả, không request
// thật: mọi request còn sót tới Dio bị chặn và đếm.

Dio _offlineDio() => Dio()
  ..interceptors.add(
    InterceptorsWrapper(
      onRequest: (o, h) {
        h.reject(DioException(requestOptions: o, error: 'network blocked in test'));
      },
    ),
  );

final _today = vnToday();

Task _task(String id, String title, TaskStatus status, {String project = 'p1', int importance = 2}) =>
    Task(
      id: id,
      projectId: project,
      title: title,
      status: status,
      importance: importance,
      urgency: 2,
      durationMinutes: 15,
      startDate: '2026-11-01',
      dueDate: '2026-11-02',
    );

/// "Server" trong bộ nhớ: tasks + 2 dự án; overview tính lại từ tasks như backend.
class _FakeApi extends NghiSuDuongApi {
  _FakeApi() : super(_offlineDio());

  final tasks = <Task>[
    _task('t1', 'Đặt phòng hội trường', TaskStatus.inProgress, importance: 3),
    _task('t2', 'Chờ báo giá in ấn', TaskStatus.review),
    _task('t3', 'Soạn kế hoạch', TaskStatus.prep, importance: 1),
    _task('t4', 'Lập ngân sách', TaskStatus.done),
  ];
  final patches = <Map<String, Object>>[];
  final deletes = <String>[];
  final creates = <Map<String, Object?>>[];
  int projectCreates = 0;
  int taskFetches = 0;
  int overviewFetches = 0;
  int projectFetches = 0;
  int summaryFetches = 0;
  final projectCreateArgs = <Map<String, Object?>>[];

  /// Giữ PATCH lại tới khi complete (để kiểm tra optimistic / bấm đúp).
  Completer<void>? gate;
  Object? failWith;

  @override
  Future<DuAnOverview> getDuAnOverview({int? year}) async {
    overviewFetches++;
    ActiveProject p(String id, String name) {
      final mine = tasks.where((t) => t.projectId == id).toList();
      final done = mine.where((t) => t.status == TaskStatus.done).length;
      return ActiveProject(
        id: id,
        name: name,
        totalTasks: mine.length,
        doneTasks: done,
        progressPct: mine.isEmpty ? 0 : (done / mine.length * 100).round(),
      );
    }

    return DuAnOverview(
      year: 2026,
      activeProjects: [p('p1', 'Sự kiện tháng 11'), p('p2', 'Hội thảo 2027')],
      completedThisYear: 0,
      upcomingProjects: const [UpcomingProject(id: 'p2', name: 'Hội thảo 2027', startDate: '2027-01-10')],
    );
  }

  @override
  Future<DuAnSummary> getDuAnSummary() async {
    summaryFetches++;
    ProjectSummary p(String id, String name) {
      final mine = tasks.where((t) => t.projectId == id).toList();
      return ProjectSummary(
        id: id,
        name: name,
        status: ProjectStatus.active,
        taskTotal: mine.length,
        taskDone: mine.where((t) => t.status == TaskStatus.done).length,
        taskDoing: mine.where((t) => t.status == TaskStatus.inProgress).length,
        attentionCount: 0,
      );
    }

    return DuAnSummary(projects: [p('p1', 'Sự kiện tháng 11'), p('p2', 'Hội thảo 2027')], attention: const []);
  }

  @override
  Future<ProjectDetail> getProject(String id) async {
    projectFetches++;
    return ProjectDetail(id: id, name: id == 'p1' ? 'Sự kiện tháng 11' : 'Hội thảo 2027', status: ProjectStatus.active);
  }

  @override
  Future<List<Task>> getProjectTasks(String projectId) async {
    taskFetches++;
    return tasks.where((t) => t.projectId == projectId).toList();
  }

  @override
  Future<Task> updateTask(String id, {String? title, TaskStatus? status, int? importance}) async {
    patches.add({'id': id, 'title': ?title, 'status': ?status, 'importance': ?importance});
    await gate?.future;
    if (failWith case final e?) throw e;
    final i = tasks.indexWhere((t) => t.id == id);
    tasks[i] = tasks[i].copyWith(title: title, status: status, importance: importance);
    return tasks[i];
  }

  @override
  Future<void> deleteTask(String id) async {
    deletes.add(id);
    if (failWith case final e?) throw e;
    tasks.removeWhere((t) => t.id == id);
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
    creates.add({'projectId': projectId, 'title': title, 'importance': importance});
    final t = _task('t${tasks.length + 10}', title, TaskStatus.prep, project: projectId, importance: importance);
    tasks.add(t);
    return t;
  }

  @override
  Future<Project> createProject({
    required String name,
    String? color,
    ProjectType? type,
    String? goal,
    String? startDate,
    String? endDate,
  }) async {
    projectCreates++;
    projectCreateArgs.add({'name': name, 'goal': goal, 'startDate': startDate, 'endDate': endDate, 'type': type});
    return Project(id: 'p-new', name: name, type: ProjectType.standard);
  }
}

class _FakeAuth extends AuthController {
  @override
  Future<AuthState> build() async => const Authenticated({'name': 'Test'});
}

class _Harness {
  final api = _FakeApi();
  int notificationFetches = 0;

  Future<void> pump(WidgetTester tester, {String location = '/du-an'}) async {
    tester.view.physicalSize = const Size(430, 1400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final router = GoRouter(
      initialLocation: location,
      routes: [
        GoRoute(
          path: '/du-an',
          builder: (_, _) => const DuAnScreen(),
          routes: [
            GoRoute(path: ':projectId', builder: (_, s) => ProjectDetailScreen(projectId: s.pathParameters['projectId']!)),
          ],
        ),
      ],
    );
    addTearDown(router.dispose);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          apiClientProvider.overrideWithValue(_offlineDio()),
          nghiSuDuongApiProvider.overrideWithValue(api),
          authControllerProvider.overrideWith(_FakeAuth.new),
          notificationsProvider.overrideWith((ref) async {
            notificationFetches++;
            return (alerts: const <Alert>[], recentActivity: const <ActivityLogEntry>[]);
          }),
        ],
        child: MaterialApp.router(
          theme: ThemeData.dark(),
          routerConfig: router,
          // Như app thật: Dư Đồ (dưới cùng ngăn xếp) luôn nghe thông báo cho badge.
          builder: (context, child) => Consumer(
            builder: (context, ref, _) {
              ref.watch(notificationsProvider);
              return child!;
            },
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }
}


void main() {
  group('sửa việc', () {
    testWidgets('form toàn màn hình; Lưu khoá khi không đổi / tên rỗng; chỉ gửi trường thay đổi', (tester) async {
      final h = _Harness();
      await h.pump(tester, location: '/du-an/p1');
      await tester.tap(find.text('Soạn kế hoạch'));
      await tester.pumpAndSettle();

      expect(find.byType(Dialog), findsOneWidget);
      expect(find.widgetWithText(AppBar, 'Sửa việc'), findsOneWidget);
      FilledButton save() => tester.widget<FilledButton>(find.widgetWithText(FilledButton, 'Lưu'));
      expect(save().onPressed, isNull, reason: 'chưa đổi gì');

      final field = find.widgetWithText(TextField, 'Tên việc');
      await tester.enterText(field, '   ');
      await tester.pump();
      expect(save().onPressed, isNull, reason: 'tên rỗng');
      await tester.enterText(field, '  Soạn kế hoạch  ');
      await tester.pump();
      expect(save().onPressed, isNull, reason: 'cắt khoảng trắng → như cũ');

      await tester.tap(find.widgetWithText(ChoiceChip, 'Cao'));
      await tester.pump();
      await tester.tap(find.widgetWithText(FilledButton, 'Lưu'));
      await tester.pumpAndSettle();

      expect(h.api.patches.single, {'id': 't3', 'importance': 3});
      expect(find.byType(Dialog), findsNothing);
    });

    testWidgets('đổi tên (cắt khoảng trắng) + trạng thái → gửi đúng 2 trường', (tester) async {
      final h = _Harness();
      await h.pump(tester, location: '/du-an/p1');
      await tester.tap(find.text('Chờ báo giá in ấn'));
      await tester.pumpAndSettle();
      await tester.enterText(find.widgetWithText(TextField, 'Tên việc'), '  Chờ báo giá  ');
      await tester.tap(find.widgetWithText(ChoiceChip, 'Đang làm'));
      await tester.pump();
      await tester.tap(find.widgetWithText(FilledButton, 'Lưu'));
      await tester.pumpAndSettle();
      expect(h.api.patches.single, {'id': 't2', 'title': 'Chờ báo giá', 'status': TaskStatus.inProgress});
      expect(find.text('2 / 2'), findsOneWidget, reason: 'cột Đang làm có 2 việc');
    });

    testWidgets('"Xóa việc" trong form: hỏi lại (ghi tên); Huỷ không gọi API, Xoá thì xoá và đóng form', (tester) async {
      final h = _Harness();
      await h.pump(tester, location: '/du-an/p1');
      await tester.tap(find.text('Soạn kế hoạch'));
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(OutlinedButton, 'Xóa việc'));
      await tester.pumpAndSettle();
      expect(find.textContaining('"Soạn kế hoạch"'), findsOneWidget);
      await tester.tap(find.text('Huỷ'));
      await tester.pumpAndSettle();
      expect(h.api.deletes, isEmpty);
      expect(find.byType(Dialog), findsOneWidget, reason: 'form vẫn mở');

      await tester.tap(find.widgetWithText(OutlinedButton, 'Xóa việc'));
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(TextButton, 'Xoá'));
      await tester.pumpAndSettle();
      expect(h.api.deletes, ['t3']);
      expect(find.byType(Dialog), findsNothing);
      expect(find.text('Soạn kế hoạch'), findsNothing);
      expect(find.text('1 / 3 việc xong'), findsOneWidget);
    });
  });

  group('form Thêm dự án toàn màn hình', () {
    testWidgets('Thêm dự án: Dialog toàn màn hình; X đóng không tạo; Tạo thì tạo và tải lại summary', (tester) async {
      final h = _Harness();
      await h.pump(tester);
      await tester.tap(find.text('Thêm dự án'));
      await tester.pumpAndSettle();
      expect(find.byType(Dialog), findsOneWidget);
      expect(find.widgetWithText(AppBar, 'Thêm dự án'), findsOneWidget);
      await tester.tap(find.byType(CloseButton));
      await tester.pumpAndSettle();
      expect(h.api.projectCreates, 0);

      final summary = h.api.summaryFetches;
      await tester.tap(find.text('Thêm dự án'));
      await tester.pumpAndSettle();
      await tester.enterText(find.widgetWithText(TextField, 'Tên dự án'), '  Dự án mới ');
      await tester.enterText(find.widgetWithText(TextField, 'Mục tiêu'), 'Ra mắt sản phẩm');
      await tester.pump();
      await tester.tap(find.widgetWithText(FilledButton, 'Tạo'));
      await tester.pumpAndSettle();
      expect(h.api.projectCreates, 1);
      expect(h.api.projectCreateArgs.single, {
        'name': 'Dự án mới',
        'goal': 'Ra mắt sản phẩm',
        'startDate': _today,
        'endDate': null,
        'type': ProjectType.standard,
      });
      expect(h.api.summaryFetches, greaterThan(summary));
      expect(find.byType(Dialog), findsNothing);
    });
  });

  test('NghiSuDuongApi.updateTask chỉ gửi trường được truyền; deleteTask gọi DELETE', () async {
    final sent = <List<Object?>>[];
    final dio = Dio(BaseOptions(baseUrl: 'https://api.test'))
      ..interceptors.add(
        InterceptorsWrapper(
          onRequest: (o, h) {
            sent.add([o.method, o.path, o.data]);
            h.resolve(Response(
              requestOptions: o,
              statusCode: 200,
              data: o.method == 'DELETE'
                  ? {'ok': true}
                  : {
                      'id': 'x', 'projectId': null, 'title': 'T', 'status': 'DONE', 'importance': 3,
                      'urgency': 2, 'durationMinutes': 15,
                    },
            ));
          },
        ),
      );
    final api = NghiSuDuongApi(dio);
    final t = await api.updateTask('x', importance: 3);
    await api.updateTask('x', status: TaskStatus.done);
    await api.deleteTask('x');
    expect(t.importance, 3);
    expect(sent, [
      ['PATCH', '/api/tasks/x', {'importance': 3}],
      ['PATCH', '/api/tasks/x', {'status': 'DONE'}],
      ['DELETE', '/api/tasks/x', null],
    ]);
  });
}

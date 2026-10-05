import 'dart:async';

import 'package:amber_flutter/features/kieu_lau/models/activity_log_entry.dart';
import 'package:amber_flutter/features/kieu_lau/models/alert.dart';
import 'package:amber_flutter/features/kieu_lau/providers/kieu_lau_provider.dart';
import 'package:amber_flutter/features/nghi_su_duong/models/overview.dart';
import 'package:amber_flutter/features/nghi_su_duong/models/project.dart';
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

// Hoàn thành / sửa / xoá việc + màn chi tiết dự án. API giả, không request
// thật: mọi request còn sót tới Dio bị chặn và đếm.

var _blocked = 0;
Dio _offlineDio() => Dio()
  ..interceptors.add(
    InterceptorsWrapper(
      onRequest: (o, h) {
        _blocked++;
        h.reject(DioException(requestOptions: o, error: 'network blocked in test'));
      },
    ),
  );

DioException _serverError(int status, [Object? data]) {
  final req = RequestOptions(path: '/api/tasks/x');
  return DioException(
    requestOptions: req,
    type: DioExceptionType.badResponse,
    response: Response(requestOptions: req, statusCode: status, data: data),
  );
}

final _today = vnToday();

Task _task(String id, String title, TaskStatus status, {String project = 'p1', int importance = 2, bool today = false}) =>
    Task(
      id: id,
      projectId: project,
      title: title,
      status: status,
      importance: importance,
      urgency: 2,
      durationMinutes: 15,
      startDate: today ? _today : '2026-11-01',
      dueDate: today ? _today : '2026-11-02',
    );

/// "Server" trong bộ nhớ: tasks + 2 dự án; overview tính lại từ tasks như backend.
class _FakeApi extends NghiSuDuongApi {
  _FakeApi() : super(_offlineDio());

  final tasks = <Task>[
    _task('t1', 'Đặt phòng hội trường', TaskStatus.inProgress, today: true, importance: 3),
    _task('t2', 'Chờ báo giá in ấn', TaskStatus.waiting),
    _task('t3', 'Soạn kế hoạch', TaskStatus.prep, importance: 1),
    _task('t4', 'Lập ngân sách', TaskStatus.done),
  ];
  final patches = <Map<String, Object>>[];
  final deletes = <String>[];
  final creates = <Map<String, Object?>>[];
  int projectCreates = 0;
  int taskFetches = 0;
  int overviewFetches = 0;

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
  Future<List<Task>> getTasks() async {
    taskFetches++;
    return List.of(tasks);
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
    String? projectId,
    required String title,
    required int importance,
    required int urgency,
    int durationMinutes = 15,
    String? startDate,
    String? dueDate,
  }) async {
    creates.add({'projectId': projectId, 'title': title, 'importance': importance});
    final t = _task('t${tasks.length + 10}', title, TaskStatus.prep, project: projectId!, importance: importance);
    tasks.add(t);
    return t;
  }

  @override
  Future<Project> createProject({required String name, String? color, ProjectType? type}) async {
    projectCreates++;
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
    _blocked = 0;
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

Finder _tile(String id) => find.byKey(ValueKey('task-$id'));
Finder _checkbox(String id) => find.descendant(of: _tile(id), matching: find.byType(Checkbox));
bool _checked(WidgetTester tester, String id) => tester.widget<Checkbox>(_checkbox(id)).value!;
TextStyle? _titleStyle(WidgetTester tester, String title) => tester.widget<Text>(find.text(title)).style;

void main() {
  group('tick hoàn thành', () {
    testWidgets('chưa xong → DONE ngay (optimistic, trước khi PATCH xong), tick lại → IN_PROGRESS', (tester) async {
      final h = _Harness();
      await h.pump(tester, location: '/du-an/p1');
      h.api.gate = Completer();

      await tester.tap(_checkbox('t2'));
      await tester.pump();
      // Đổi ngay khi PATCH chưa trả lời: rời nhóm "Chờ", vào nhóm "Đã xong" (đang gập).
      expect(find.text('Chờ (1)'), findsNothing);
      expect(find.text('Đã xong (2)'), findsOneWidget);
      expect(h.api.patches.single, {'id': 't2', 'status': TaskStatus.done});

      h.api.gate!.complete();
      await tester.pumpAndSettle();
      expect(h.api.tasks.firstWhere((t) => t.id == 't2').status, TaskStatus.done);

      h.api.gate = null;
      await tester.tap(find.text('Đã xong (2)'));
      await tester.pumpAndSettle();
      expect(_checked(tester, 't2'), isTrue);
      expect(_titleStyle(tester, 'Chờ báo giá in ấn')?.decoration, TextDecoration.lineThrough);
      await tester.tap(_checkbox('t2'));
      await tester.pumpAndSettle();
      expect(h.api.patches.last, {'id': 't2', 'status': TaskStatus.inProgress});
      expect(find.text('Đang làm (2)'), findsOneWidget);
      expect(_checked(tester, 't2'), isFalse);
      expect(_titleStyle(tester, 'Chờ báo giá in ấn')?.decoration, isNull);
      expect(_blocked, 0);
    });

    testWidgets('lỗi → hoàn lại trạng thái cũ + SnackBar (message của server nếu có)', (tester) async {
      final h = _Harness();
      await h.pump(tester, location: '/du-an/p1');
      h.api.gate = Completer();
      h.api.failWith = _serverError(500, {'message': 'Máy chủ đang bảo trì.'});

      await tester.tap(_checkbox('t3'));
      await tester.pump();
      expect(find.text('Chuẩn bị (1)'), findsNothing, reason: 'optimistic: đã sang nhóm Đã xong');
      h.api.gate!.complete();
      await tester.pumpAndSettle();

      expect(_checked(tester, 't3'), isFalse, reason: 'hoàn lại');
      expect(find.text('Chuẩn bị (1)'), findsOneWidget);
      expect(find.text('Máy chủ đang bảo trì.'), findsOneWidget);
    });

    testWidgets('lỗi không có message (vd 400 {error: {...}}) → câu chung', (tester) async {
      final h = _Harness();
      await h.pump(tester, location: '/du-an/p1');
      h.api.failWith = _serverError(400, {'error': {'fieldErrors': {}}});
      await tester.tap(_checkbox('t3'));
      await tester.pumpAndSettle();
      expect(find.text('Không cập nhật được việc, thử lại nhé.'), findsOneWidget);
    });

    testWidgets('bấm đúp trong lúc đang gửi → chỉ 1 PATCH ("Task hôm nay": dòng đứng yên khi tick)', (tester) async {
      final h = _Harness();
      await h.pump(tester);
      h.api.gate = Completer();
      await tester.tap(_checkbox('t1'));
      await tester.pump();
      await tester.tap(_checkbox('t1'), warnIfMissed: false);
      await tester.pump();
      await tester.tap(_checkbox('t1'), warnIfMissed: false);
      await tester.pump();
      expect(h.api.patches, hasLength(1));
      h.api.gate!.complete();
      await tester.pumpAndSettle();
      expect(h.api.patches, hasLength(1));
    });

    testWidgets('sau khi xong: tải lại việc, overview và thông báo; tiến độ đổi', (tester) async {
      final h = _Harness();
      await h.pump(tester, location: '/du-an/p1');
      expect(find.text('1 / 4 việc xong'), findsOneWidget);
      final (tasks, overview, notif) = (h.api.taskFetches, h.api.overviewFetches, h.notificationFetches);

      await tester.tap(_checkbox('t1'));
      await tester.pumpAndSettle();
      expect(find.text('2 / 4 việc xong'), findsOneWidget);
      expect(h.api.taskFetches, greaterThan(tasks));
      expect(h.api.overviewFetches, greaterThan(overview));
      expect(h.notificationFetches, greaterThan(notif));
    });

    testWidgets('màn Dự án: "Task hôm nay" dùng cùng dòng việc; tick → "TB hoàn thành" đổi', (tester) async {
      final h = _Harness();
      await h.pump(tester);
      // p1: 1/4 = 25%, p2: 0% → TB 13%.
      expect(find.text('13%'), findsOneWidget);
      await tester.tap(_checkbox('t1'));
      await tester.pumpAndSettle();
      expect(find.text('25%'), findsWidgets); // p1 2/4 = 50%, TB (50+0)/2 = 25%
      expect(find.text('50%'), findsOneWidget);
    });
  });

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
      expect(find.text('Đang làm (2)'), findsOneWidget);
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

  group('vuốt để xoá', () {
    testWidgets('vuốt trái → hỏi lại; Huỷ thì không gọi API và dòng trượt về', (tester) async {
      final h = _Harness();
      await h.pump(tester, location: '/du-an/p1');
      await tester.drag(_tile('t2'), const Offset(-500, 0));
      await tester.pumpAndSettle();
      expect(find.text('Xoá việc?'), findsOneWidget);
      expect(find.textContaining('"Chờ báo giá in ấn"'), findsOneWidget);
      await tester.tap(find.text('Huỷ'));
      await tester.pumpAndSettle();
      expect(h.api.deletes, isEmpty);
      expect(_tile('t2'), findsOneWidget);
      expect(tester.getTopLeft(_tile('t2')).dx, tester.getTopLeft(_tile('t1')).dx, reason: 'trượt về chỗ cũ');
    });

    testWidgets('vuốt trái → Xoá → gọi deleteTask, dòng biến mất, tiến độ đổi', (tester) async {
      final h = _Harness();
      await h.pump(tester, location: '/du-an/p1');
      await tester.drag(_tile('t2'), const Offset(-500, 0));
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(TextButton, 'Xoá'));
      await tester.pumpAndSettle();
      expect(h.api.deletes, ['t2']);
      expect(_tile('t2'), findsNothing);
      expect(find.text('1 / 3 việc xong'), findsOneWidget);
    });

    testWidgets('xoá lỗi → SnackBar, dòng vẫn còn', (tester) async {
      final h = _Harness();
      await h.pump(tester, location: '/du-an/p1');
      h.api.failWith = _serverError(404, {'error': 'task not found'});
      await tester.drag(_tile('t2'), const Offset(-500, 0));
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(TextButton, 'Xoá'));
      await tester.pumpAndSettle();
      expect(find.text('Không xoá được việc, thử lại nhé.'), findsOneWidget);
      expect(_tile('t2'), findsOneWidget);
    });
  });

  group('màn chi tiết dự án', () {
    testWidgets('bấm dự án đang chạy → push /du-an/p1: tên, tiến độ, nhóm theo trạng thái, "Đã xong" gập', (tester) async {
      final h = _Harness();
      await h.pump(tester);
      await tester.tap(find.text('Sự kiện tháng 11'));
      await tester.pumpAndSettle();

      expect(find.byType(ProjectDetailScreen), findsOneWidget);
      expect(find.text('1 / 4 việc xong'), findsOneWidget);
      final ys = [for (final t in ['Đang làm (1)', 'Chờ (1)', 'Chuẩn bị (1)', 'Đã xong (1)']) tester.getTopLeft(find.text(t)).dy];
      expect(ys, orderedEquals([...ys]..sort()));
      expect(find.text('Lập ngân sách'), findsNothing, reason: 'nhóm Đã xong gập mặc định');

      await tester.tap(find.text('Đã xong (1)'));
      await tester.pumpAndSettle();
      expect(find.text('Lập ngân sách'), findsOneWidget);
      await tester.tap(find.text('Đã xong (1)'));
      await tester.pumpAndSettle();
      expect(find.text('Lập ngân sách'), findsNothing);

      await tester.pageBack();
      await tester.pumpAndSettle();
      expect(find.byType(DuAnScreen), findsOneWidget);
    });

    testWidgets('bấm dự án ở "Sắp tới" → chi tiết; chưa có việc → dòng hướng dẫn; nhóm rỗng ẩn', (tester) async {
      final h = _Harness();
      await h.pump(tester);
      await tester.tap(find.text('2027-01-10'));
      await tester.pumpAndSettle();
      expect(find.byType(ProjectDetailScreen), findsOneWidget);
      expect(find.textContaining('Chưa có việc nào'), findsOneWidget);
      expect(find.text('0 / 0 việc xong'), findsOneWidget);
      expect(find.textContaining('Đang làm ('), findsNothing);
    });

    testWidgets('"+ Việc" tạo việc cho chính dự án này (chọn sẵn), danh sách cập nhật', (tester) async {
      final h = _Harness();
      await h.pump(tester, location: '/du-an/p2');
      await tester.tap(find.widgetWithText(TextButton, '+ Việc'));
      await tester.pumpAndSettle();
      expect(find.byType(Dialog), findsOneWidget, reason: 'form toàn màn hình');
      expect(find.byType(BottomSheet), findsNothing);
      expect(find.text('Hội thảo 2027'), findsWidgets); // dropdown đã chọn sẵn
      await tester.enterText(find.widgetWithText(TextField, 'Tên việc'), '  Gửi thư mời  ');
      await tester.pump();
      await tester.tap(find.widgetWithText(FilledButton, 'Tạo việc'));
      await tester.pumpAndSettle();

      expect(h.api.creates.single, {'projectId': 'p2', 'title': 'Gửi thư mời', 'importance': 2});
      expect(find.byType(Dialog), findsNothing);
      expect(find.text('Gửi thư mời'), findsOneWidget);
      expect(find.text('Chuẩn bị (1)'), findsOneWidget);
    });
  });

  group('hai form cũ giờ toàn màn hình', () {
    testWidgets('Thêm việc (màn Dự án): Dialog toàn màn hình, không autofocus, tạo xong tải lại', (tester) async {
      final h = _Harness();
      await h.pump(tester);
      final fetches = h.api.taskFetches;
      await tester.tap(find.widgetWithText(TextButton, '+ Việc'));
      await tester.pumpAndSettle();
      expect(find.byType(Dialog), findsOneWidget);
      expect(find.byType(BottomSheet), findsNothing);
      expect(find.widgetWithText(AppBar, 'Thêm việc'), findsOneWidget);
      expect(FocusManager.instance.primaryFocus?.context?.widget, isNot(isA<EditableText>()));
      await tester.enterText(find.widgetWithText(TextField, 'Tên việc'), 'Việc mới');
      await tester.pump();
      await tester.tap(find.widgetWithText(FilledButton, 'Tạo việc'));
      await tester.pumpAndSettle();
      expect(h.api.creates.single['projectId'], 'p1'); // dự án đầu tiên, như trước
      expect(h.api.taskFetches, greaterThan(fetches));
      expect(find.byType(Dialog), findsNothing);
    });

    testWidgets('Thêm dự án: Dialog toàn màn hình; X đóng không tạo; Tạo thì tạo và tải lại overview', (tester) async {
      final h = _Harness();
      await h.pump(tester);
      await tester.tap(find.widgetWithText(TextButton, '+ Dự án'));
      await tester.pumpAndSettle();
      expect(find.byType(Dialog), findsOneWidget);
      expect(find.widgetWithText(AppBar, 'Thêm dự án'), findsOneWidget);
      await tester.tap(find.byType(CloseButton));
      await tester.pumpAndSettle();
      expect(h.api.projectCreates, 0);

      final overview = h.api.overviewFetches;
      await tester.tap(find.widgetWithText(TextButton, '+ Dự án'));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField), 'Dự án mới');
      await tester.pump();
      await tester.tap(find.widgetWithText(FilledButton, 'Tạo'));
      await tester.pumpAndSettle();
      expect(h.api.projectCreates, 1);
      expect(h.api.overviewFetches, greaterThan(overview));
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

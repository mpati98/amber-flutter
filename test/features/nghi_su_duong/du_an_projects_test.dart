import 'package:amber_flutter/features/kieu_lau/models/activity_log_entry.dart';
import 'package:amber_flutter/features/kieu_lau/models/alert.dart';
import 'package:amber_flutter/features/kieu_lau/providers/kieu_lau_provider.dart';
import 'package:amber_flutter/features/nghi_su_duong/models/overview.dart';
import 'package:amber_flutter/features/nghi_su_duong/models/project.dart';
import 'package:amber_flutter/features/nghi_su_duong/models/project_summary.dart';
import 'package:amber_flutter/features/nghi_su_duong/models/task.dart';
import 'package:amber_flutter/features/nghi_su_duong/screens/du_an_screen.dart';
import 'package:amber_flutter/features/nghi_su_duong/services/nghi_su_duong_api.dart';
import 'package:amber_flutter/features/nghi_su_duong/widgets/project_card.dart';
import 'package:amber_flutter/shared/providers/auth_provider.dart';
import 'package:amber_flutter/shared/services/api_client.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

// Khu "Dự án" của màn Dự án: bộ lọc, thẻ, form thêm. API giả, không request thật.

Dio _offlineDio() => Dio()
  ..interceptors.add(
    InterceptorsWrapper(onRequest: (o, h) => h.reject(DioException(requestOptions: o, error: 'network blocked in test'))),
  );

ProjectSummary _p(
  String id,
  String name, {
  ProjectStatus status = ProjectStatus.active,
  String? goal,
  double? kr,
  int total = 0,
  int done = 0,
  int doing = 0,
  int attention = 0,
  NextMilestone? milestone,
  num net = 0,
  String? start,
  String? end,
}) =>
    ProjectSummary(
      id: id,
      name: name,
      goal: goal,
      status: status,
      startDate: start,
      endDate: end,
      krProgress: kr,
      taskTotal: total,
      taskDone: done,
      taskDoing: doing,
      attentionCount: attention,
      nextMilestone: milestone,
      finance: ProjectFinance(income: 0, expense: 0, net: net),
    );

class _FakeApi extends NghiSuDuongApi {
  _FakeApi(this.projects) : super(_offlineDio());

  List<ProjectSummary> projects;
  Object? createError;
  final creates = <Map<String, Object?>>[];
  int summaryFetches = 0;
  int taskFetches = 0;

  @override
  Future<DuAnSummary> getDuAnSummary() async {
    summaryFetches++;
    return DuAnSummary(projects: projects, attention: const []);
  }

  @override
  Future<DuAnOverview> getDuAnOverview({int? year}) async =>
      const DuAnOverview(year: 2026, activeProjects: [], completedThisYear: 0, upcomingProjects: []);

  @override
  Future<List<Task>> getTasks() async {
    taskFetches++;
    return const [];
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
    creates.add({'name': name, 'goal': goal, 'startDate': startDate, 'endDate': endDate});
    if (createError case final e?) throw e;
    return Project(id: 'p-new', name: name, type: ProjectType.standard);
  }
}

class _FakeAuth extends AuthController {
  @override
  Future<AuthState> build() async => const Authenticated({'name': 'Test'});
}

Future<_FakeApi> _pump(WidgetTester tester, List<ProjectSummary> projects, {double width = 390}) async {
  final api = _FakeApi(projects);
  tester.view.physicalSize = Size(width, 1600);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  final router = GoRouter(
    routes: [
      GoRoute(path: '/', builder: (_, _) => const DuAnScreen()),
      GoRoute(path: '/du-an/:projectId', builder: (_, s) => Text('detail ${s.pathParameters['projectId']}')),
    ],
  );
  addTearDown(router.dispose);
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        apiClientProvider.overrideWithValue(_offlineDio()),
        nghiSuDuongApiProvider.overrideWithValue(api),
        authControllerProvider.overrideWith(_FakeAuth.new),
        notificationsProvider.overrideWith((ref) async => (alerts: const <Alert>[], recentActivity: const <ActivityLogEntry>[])),
      ],
      child: MaterialApp.router(theme: ThemeData.dark(), routerConfig: router),
    ),
  );
  await tester.pumpAndSettle();
  return api;
}

final _mixed = [
  _p('a1', 'Dự án đúng nhịp', total: 4, done: 1, doing: 1, kr: 0.5, goal: 'Ra mắt bản đầu'),
  _p('a2', 'Dự án có việc quá hạn', total: 3, attention: 2),
  _p('a3', 'Dự án mới tạo'),
  _p('b1', 'Dự án tạm dừng', status: ProjectStatus.paused, total: 2, attention: 1),
  _p('c1', 'Dự án đã xong 1', status: ProjectStatus.done, total: 5, done: 5),
  _p('c2', 'Dự án đã xong 2', status: ProjectStatus.done),
];

void main() {
  group('projectBadge: 5 trường hợp nhãn trạng thái', () {
    test('PAUSED → "Tạm dừng" (kể cả khi có việc cần xử lý)', () {
      expect(projectBadge(_p('x', 'x', status: ProjectStatus.paused, attention: 3)).label, 'Tạm dừng');
    });
    test('DONE → "Đã xong"', () {
      expect(projectBadge(_p('x', 'x', status: ProjectStatus.done, total: 2, done: 2)).label, 'Đã xong');
    });
    test('ACTIVE có việc cần xử lý → "{n} việc cần xử lý" (màu cảnh báo)', () {
      final b = projectBadge(_p('x', 'x', total: 3, attention: 2));
      expect(b.label, '2 việc cần xử lý');
      expect(b.tone, ProjectBadgeTone.warning);
    });
    test('ACTIVE chưa có việc → "Mới tạo"', () {
      expect(projectBadge(_p('x', 'x')).label, 'Mới tạo');
    });
    test('ACTIVE còn lại → "Đúng nhịp"', () {
      expect(projectBadge(_p('x', 'x', total: 4, done: 1)).label, 'Đúng nhịp');
    });
  });

  group('màn Dự án không còn danh sách việc', () {
    testWidgets('không gọi GET /api/tasks, không có "Task hôm nay" và "+ Việc"; làm mới chỉ tải summary', (tester) async {
      final api = await _pump(tester, _mixed);
      expect(api.taskFetches, 0);
      expect(find.text('Task hôm nay'), findsNothing);
      expect(find.text('+ Việc'), findsNothing);

      final fetches = api.summaryFetches;
      await tester.widget<RefreshIndicator>(find.byType(RefreshIndicator)).onRefresh();
      await tester.pumpAndSettle();
      expect(api.summaryFetches, greaterThan(fetches));
      expect(api.taskFetches, 0);
    });
  });

  group('bộ lọc', () {
    testWidgets('số đếm đúng; mặc định Đang triển khai chỉ hiện dự án ACTIVE', (tester) async {
      await _pump(tester, _mixed);
      expect(find.text('Đang triển khai · 3'), findsOneWidget);
      expect(find.text('Tạm dừng · 1'), findsOneWidget);
      expect(find.text('Đã xong · 2'), findsOneWidget);
      expect(find.byType(ProjectCard), findsNWidgets(3));
      expect(find.text('Dự án đúng nhịp'), findsOneWidget);
      expect(find.text('Dự án tạm dừng'), findsNothing);
      expect(tester.takeException(), isNull);
    });

    testWidgets('đổi bộ lọc đổi danh sách', (tester) async {
      await _pump(tester, _mixed);
      await tester.tap(find.text('Tạm dừng · 1'));
      await tester.pumpAndSettle();
      expect(find.byType(ProjectCard), findsOneWidget);
      expect(find.text('Dự án tạm dừng'), findsOneWidget);
      expect(find.text('Dự án đúng nhịp'), findsNothing);

      await tester.tap(find.text('Đã xong · 2'));
      await tester.pumpAndSettle();
      expect(find.byType(ProjectCard), findsNWidgets(2));
      expect(find.text('Dự án đã xong 1'), findsOneWidget);
    });

    testWidgets('nhãn trên thẻ ở từng bộ lọc', (tester) async {
      await _pump(tester, _mixed);
      expect(find.text('Đúng nhịp'), findsOneWidget);
      expect(find.text('2 việc cần xử lý'), findsOneWidget);
      expect(find.text('Mới tạo'), findsOneWidget);
      await tester.tap(find.text('Tạm dừng · 1'));
      await tester.pumpAndSettle();
      expect(find.text('Tạm dừng'), findsOneWidget);
      await tester.tap(find.text('Đã xong · 2'));
      await tester.pumpAndSettle();
      expect(find.text('Đã xong'), findsNWidgets(2));
    });

    testWidgets('không có dự án ở bộ lọc đang chọn → dòng trống', (tester) async {
      await _pump(tester, [_p('a1', 'Chỉ một dự án')]);
      await tester.tap(find.text('Tạm dừng · 0'));
      await tester.pumpAndSettle();
      expect(find.text('Không có dự án nào ở trạng thái này.'), findsOneWidget);
      expect(find.byType(ProjectCard), findsNothing);
    });
  });

  group('thẻ dự án', () {
    testWidgets('đủ các dòng: KR %, việc, ngày, mốc, ròng (âm có dấu trừ)', (tester) async {
      await _pump(tester, [
        _p(
          'a1',
          'Sự kiện tháng 11',
          goal: 'Tổ chức thành công',
          kr: 0.5,
          total: 4,
          done: 1,
          doing: 2,
          net: -100000,
          start: '2026-10-06',
          end: '2026-12-31',
          milestone: const NextMilestone(id: 'm', title: 'Chốt địa điểm', dueDate: '2026-10-14'),
        ),
      ]);
      expect(find.text('Sự kiện tháng 11'), findsOneWidget);
      expect(find.text('Tổ chức thành công'), findsOneWidget);
      expect(find.text('Kết quả then chốt'), findsOneWidget);
      expect(find.text('50%'), findsOneWidget);
      expect(find.text('Đang làm 2'), findsOneWidget);
      expect(find.text('Xong 1 / 4'), findsOneWidget);
      expect(find.text('06/10 – 31/12'), findsOneWidget);
      expect(find.text('Chốt địa điểm · 14/10'), findsOneWidget);
      expect(find.text('Ròng -100.000₫'), findsOneWidget);
    });

    testWidgets('thiếu dữ liệu: "Chưa ghi mục tiêu.", "Chưa có KR", "Chưa có mốc", "Chưa có ngày"', (tester) async {
      await _pump(tester, [_p('a1', 'Trống')]);
      expect(find.text('Chưa ghi mục tiêu.'), findsOneWidget);
      expect(find.text('Chưa có KR'), findsOneWidget);
      expect(find.text('Chưa có mốc'), findsOneWidget);
      expect(find.text('Chưa có ngày'), findsOneWidget);
      expect(find.text('Ròng 0₫'), findsOneWidget);
    });

    testWidgets('chạm thẻ → /du-an/:id', (tester) async {
      await _pump(tester, [_p('a1', 'Mở tôi')]);
      await tester.tap(find.text('Mở tôi'));
      await tester.pumpAndSettle();
      expect(find.text('detail a1'), findsOneWidget);
    });

    testWidgets('bề rộng 390: không tràn, 1 cột; màn rộng: nhiều cột, mỗi thẻ ≤ 420', (tester) async {
      await _pump(tester, _mixed, width: 390);
      expect(tester.takeException(), isNull);
      final xs = {for (final c in tester.widgetList<ProjectCard>(find.byType(ProjectCard))) tester.getTopLeft(find.byWidget(c)).dx};
      expect(xs.length, 1);

      await _pump(tester, _mixed, width: 1000);
      expect(tester.takeException(), isNull);
      final cards = find.byType(ProjectCard);
      final columns = {for (final c in tester.widgetList<ProjectCard>(cards)) tester.getTopLeft(find.byWidget(c)).dx};
      expect(columns.length, greaterThan(1));
      for (final c in tester.widgetList<ProjectCard>(cards)) {
        expect(tester.getSize(find.byWidget(c)).width, lessThanOrEqualTo(projectCardMaxWidth));
      }
    });
  });

  group('form Thêm dự án', () {
    Future<void> openForm(WidgetTester tester) async {
      await tester.tap(find.text('Thêm dự án'));
      await tester.pumpAndSettle();
      expect(find.widgetWithText(AppBar, 'Thêm dự án'), findsOneWidget);
    }

    testWidgets('Tạo khoá khi tên rỗng; gửi tên, mục tiêu, ngày bắt đầu mặc định; về bộ lọc Đang triển khai', (tester) async {
      final api = await _pump(tester, _mixed);
      await tester.tap(find.text('Đã xong · 2'));
      await tester.pumpAndSettle();
      expect(find.text('Dự án đúng nhịp'), findsNothing);

      await openForm(tester);
      expect(tester.widget<FilledButton>(find.widgetWithText(FilledButton, 'Tạo')).onPressed, isNull);
      final fetches = api.summaryFetches;
      await tester.enterText(find.widgetWithText(TextField, 'Tên dự án'), 'Dự án mới');
      await tester.enterText(find.widgetWithText(TextField, 'Mục tiêu'), 'Mục tiêu thử');
      await tester.pump();
      await tester.tap(find.widgetWithText(FilledButton, 'Tạo'));
      await tester.pumpAndSettle();

      expect(api.creates.single['name'], 'Dự án mới');
      expect(api.creates.single['goal'], 'Mục tiêu thử');
      expect(api.creates.single['startDate'], matches(RegExp(r'^\d{4}-\d{2}-\d{2}$')));
      expect(api.creates.single['endDate'], isNull);
      expect(api.summaryFetches, greaterThan(fetches));
      expect(find.byType(Dialog), findsNothing);
      expect(find.text('Dự án đúng nhịp'), findsOneWidget, reason: 'bộ lọc quay về Đang triển khai');
    });

    testWidgets('server trả end_before_start → "Hạn phải sau ngày bắt đầu."; form giữ nguyên', (tester) async {
      final api = await _pump(tester, _mixed);
      final req = RequestOptions(path: '/api/projects');
      api.createError = DioException(
        requestOptions: req,
        type: DioExceptionType.badResponse,
        response: Response(requestOptions: req, statusCode: 400, data: {'error': 'end_before_start'}),
      );
      await openForm(tester);
      await tester.enterText(find.widgetWithText(TextField, 'Tên dự án'), 'Dự án mới');
      await tester.pump();
      await tester.tap(find.widgetWithText(FilledButton, 'Tạo'));
      await tester.pumpAndSettle();
      expect(find.text('Hạn phải sau ngày bắt đầu.'), findsOneWidget);
      expect(find.byType(Dialog), findsOneWidget);
    });

    testWidgets('lỗi khác → câu chung', (tester) async {
      final api = await _pump(tester, _mixed);
      api.createError = DioException(requestOptions: RequestOptions(path: '/api/projects'), error: 'down');
      await openForm(tester);
      await tester.enterText(find.widgetWithText(TextField, 'Tên dự án'), 'Dự án mới');
      await tester.pump();
      await tester.tap(find.widgetWithText(FilledButton, 'Tạo'));
      await tester.pumpAndSettle();
      expect(find.text('Không tạo được dự án, thử lại nhé.'), findsOneWidget);
    });
  });
}

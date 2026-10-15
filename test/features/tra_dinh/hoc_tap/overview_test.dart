import 'package:amber_flutter/features/tra_dinh/hoc_tap/models/study_enums.dart';
import 'package:amber_flutter/features/tra_dinh/hoc_tap/models/study_log.dart';
import 'package:amber_flutter/features/tra_dinh/hoc_tap/models/study_overview.dart';
import 'package:amber_flutter/features/tra_dinh/hoc_tap/screens/overview_tab.dart';
import 'package:amber_flutter/features/tra_dinh/hoc_tap/screens/tra_dinh_hoc_tap_screen.dart';
import 'package:amber_flutter/features/tra_dinh/hoc_tap/services/hoc_tap_api.dart';
import 'package:amber_flutter/shared/utils/vn_time.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_test/flutter_test.dart';

import 'hoc_tap_test_support.dart';
import 'hoc_tap_widget_support.dart';

void main() {
  testWidgets('Tổng quan trống: thẻ "Tạo môn đầu tiên" + thẻ Luyện tập với AI', (tester) async {
    final api = FakeHocTapApi(overview: StudyOverview(today: '2026-10-14', week: StudyOverview.fromJson(fixtureMap('overview')).week, subjects: const []), subjects: const []);
    await pumpHocTap(tester, const Scaffold(body: OverviewTab()), api: api);

    expect(find.text('Tạo môn đầu tiên'), findsOneWidget);
    expect(find.byKey(const ValueKey('week-chart')), findsNothing);
    expect(find.byKey(const ValueKey('practice-card')), findsOneWidget);
  });

  testWidgets('Tổng quan có dữ liệu: tuần, hôm nay, khóa đang học, link, nút khóa học', (tester) async {
    await pumpHocTap(tester, const Scaffold(body: OverviewTab()), api: FakeHocTapApi());

    // chip môn + "+ Môn"
    expect(find.text('Tiếng Anh'), findsWidgets);
    expect(find.text('+ Môn'), findsOneWidget);

    // thẻ mục tiêu tuần (fixture: 75/420 phút, còn 345 phút trong 5 ngày, 69 phút mỗi ngày)
    expect(find.byKey(const ValueKey('week-minutes')), findsOneWidget);
    expect(find.textContaining('Còn 5h 45p trong 5 ngày, tối thiểu 69 phút mỗi ngày'), findsOneWidget);
    expect(find.byKey(const ValueKey('week-chart')), findsOneWidget);
    expect(find.byKey(const ValueKey('goal-line')), findsOneWidget);
    for (final d in ['2026-10-12', '2026-10-13', '2026-10-14', '2026-10-15', '2026-10-16', '2026-10-17', '2026-10-18']) {
      expect(find.byKey(ValueKey('week-bar-$d')), findsOneWidget);
    }
    // hôm nay (14/10) có viền nổi, ngày khác thì không
    BoxDecoration deco(String d) => tester.widget<Container>(find.byKey(ValueKey('week-bar-$d'))).decoration! as BoxDecoration;
    expect(deco('2026-10-14').border, isNotNull);
    expect(deco('2026-10-13').border, isNull);
    // chưa đủ → màu nhạt hơn cột đủ
    expect(deco('2026-10-13').color!.a, lessThan(1));

    // thẻ Hôm nay
    expect(tester.widget<Text>(find.byKey(const ValueKey('today-minutes'))).data, '30');
    expect(find.text(' / 60 phút'), findsOneWidget);
    expect(find.text('1 buổi'), findsOneWidget);
    expect(find.textContaining('Tiếp theo: First English Sentences · English Tenses 101'), findsOneWidget);

    // thẻ khóa đang học
    expect(find.text('English Tenses 101'), findsWidgets);
    expect(find.textContaining('Dự kiến xong 23/10 · đúng kế hoạch'), findsOneWidget);

    // link kèm số đếm
    expect(find.byKey(const ValueKey('link-Chờ học')), findsOneWidget);
    expect(find.descendant(of: find.byKey(const ValueKey('link-Chờ học')), matching: find.text('2')), findsOneWidget);
    expect(find.descendant(of: find.byKey(const ValueKey('link-Muốn mua')), matching: find.text('1')), findsOneWidget);
  });

  testWidgets('nút Ghi buổi học mở sheet cho môn đang chọn; link Chờ học điều hướng đúng', (tester) async {
    final api = FakeHocTapApi();
    await pumpHocTap(tester, const Scaffold(body: OverviewTab()), api: api);

    await tester.tap(find.text('Ghi buổi học'));
    await tester.pumpAndSettle();
    expect(find.text('Ghi buổi học'), findsWidgets);
    expect(find.textContaining('Chỉ ghi cho hôm nay.'), findsOneWidget);
    await tester.tap(find.byType(CloseButton));
    await tester.pumpAndSettle();

    await tester.ensureVisible(find.byKey(const ValueKey('link-Chờ học')));
    await tester.tap(find.byKey(const ValueKey('link-Chờ học')));
    await tester.pumpAndSettle();
    expect(visited.last, contains('/tra-dinh/hoc-tap/courses?subjectId='));
    expect(visited.last, contains('status=QUEUED'));
  });

  testWidgets('thẻ Hôm nay: danh sách buổi đã ghi, bấm → sheet sửa; lý do hiện "Dừng sớm"', (tester) async {
    final api = FakeHocTapApi();
    final subjectId = api.subjects.first.id;
    api.logs = [for (final l in fixtureList('logs_today')) StudyLog.fromJson({...(l as Map<String, dynamic>), 'subjectId': subjectId, 'logDate': vnToday()})];
    final base = StudyOverview.fromJson(fixtureMap('overview'));
    final first = base.subjects.first;
    api.overview = StudyOverview(
      today: base.today,
      week: base.week,
      subjects: [
        SubjectOverview(
          subjectId: first.subjectId,
          name: first.name,
          goalMinutes: first.goalMinutes,
          today: const TodayInfo(minutes: 50, logCount: 2, done: false, reason: DayReason(code: ReasonCode.busy)),
          activeCourse: first.activeCourse,
          counts: first.counts,
        ),
        ...base.subjects.skip(1),
      ],
    );
    await pumpHocTap(tester, const Scaffold(body: OverviewTab()), api: api);

    expect(find.text('Dừng sớm: Bận'), findsOneWidget);
    expect(find.byKey(ValueKey('today-log-${api.logs[0].id}')), findsOneWidget);
    expect(find.byKey(ValueKey('today-log-${api.logs[1].id}')), findsOneWidget);
    expect(find.textContaining('Ôn tập'), findsOneWidget);
    expect(find.textContaining('English Tenses 101 · Basics ✓, First English Sentences'), findsOneWidget);

    await tester.tap(find.byKey(ValueKey('today-log-${api.logs[0].id}')));
    await tester.pumpAndSettle();
    expect(find.text('Sửa buổi học'), findsOneWidget);
    expect(find.byKey(const ValueKey('log-delete')), findsOneWidget);
  });

  testWidgets('thẻ Luyện tập với AI → /tra-dinh/luyen-tap', (tester) async {
    await pumpHocTap(tester, const Scaffold(body: OverviewTab()), api: FakeHocTapApi());
    await tester.ensureVisible(find.byKey(const ValueKey('practice-card')));
    await tester.tap(find.byKey(const ValueKey('practice-card')));
    await tester.pumpAndSettle();
    expect(visited.last, '/tra-dinh/luyen-tap');
  });

  testWidgets('lỗi tải tổng quan → thông báo + Thử lại', (tester) async {
    final api = FakeHocTapApi()..overviewError = apiError(500, {'error': 'x'});
    await pumpHocTap(tester, const Scaffold(body: OverviewTab()), api: api);
    expect(find.textContaining('Không tải được tổng quan'), findsOneWidget);
    api.overviewError = null;
    await tester.tap(find.text('Thử lại'));
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('week-chart')), findsOneWidget);
  });

  testWidgets('shell 3 tab: tab lưu ở ?tab=, Lịch có toggle Tuần/Tháng, Thống kê có số liệu', (tester) async {
    tester.view.physicalSize = const Size(390, 2600);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final router = GoRouter(
      initialLocation: '/tra-dinh?tab=stats',
      routes: [GoRoute(path: '/tra-dinh', builder: (_, state) => TraDinhHocTapScreen(tab: state.uri.queryParameters['tab']))],
    );
    await tester.pumpWidget(
      ProviderScope(overrides: [hocTapApiProvider.overrideWithValue(FakeHocTapApi())], child: MaterialApp.router(theme: ThemeData.dark(), routerConfig: router)),
    );
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('tile-total')), findsOneWidget, reason: '?tab=stats mở đúng tab Thống kê');

    await tester.tap(find.text('Lịch'));
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('view-toggle')), findsOneWidget);
    expect(router.state.uri.toString(), '/tra-dinh?tab=schedule');

    await tester.tap(find.text('Tổng quan'));
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('week-chart')), findsOneWidget);
  });

  group('route /tra-dinh?openLog=1', () {
    Future<GoRouter> pumpRoute(WidgetTester tester, FakeHocTapApi api, String location) async {
      tester.view.physicalSize = const Size(390, 2600);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      final router = GoRouter(
        initialLocation: location,
        routes: [
          GoRoute(
            path: '/tra-dinh',
            builder: (_, state) => TraDinhHocTapScreen(tab: state.uri.queryParameters['tab'], openLog: state.uri.queryParameters['openLog'] == '1', subjectId: state.uri.queryParameters['subjectId']),
          ),
        ],
      );
      await tester.pumpWidget(ProviderScope(overrides: [hocTapApiProvider.overrideWithValue(api)], child: MaterialApp.router(theme: ThemeData.dark(), routerConfig: router)));
      await tester.pumpAndSettle();
      return router;
    }

    testWidgets('mở Tổng quan, tự mở sheet đúng một lần, xoá query khỏi URL, chọn môn theo subjectId', (tester) async {
      final api = FakeHocTapApi();
      final second = api.subjects[1].id; // môn "Lập trình"
      final router = await pumpRoute(tester, api, '/tra-dinh?openLog=1&subjectId=$second');

      expect(find.textContaining('Chỉ ghi cho hôm nay.'), findsOneWidget);
      expect(router.state.uri.toString(), '/tra-dinh');
      // sheet mở với môn đã chỉ định (môn thứ 2 không có mục tiêu)
      expect(find.text('Môn chưa đặt mục tiêu mỗi ngày.'), findsOneWidget);

      await tester.tap(find.byType(CloseButton));
      await tester.pumpAndSettle();
      expect(find.textContaining('Chỉ ghi cho hôm nay.'), findsNothing);
      // Không tự mở lại khi rebuild / chuyển tab.
      await tester.tap(find.text('Lịch'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Tổng quan'));
      await tester.pumpAndSettle();
      expect(find.textContaining('Chỉ ghi cho hôm nay.'), findsNothing);
      expect(find.byKey(const ValueKey('week-chart')), findsOneWidget);
    });

    testWidgets('mở từ tab khác vẫn về Tổng quan; không có openLog thì không mở sheet', (tester) async {
      final api = FakeHocTapApi();
      final router = await pumpRoute(tester, api, '/tra-dinh?tab=stats&openLog=1&subjectId=${api.subjects.first.id}');
      expect(find.textContaining('Chỉ ghi cho hôm nay.'), findsOneWidget);
      expect(router.state.uri.toString(), '/tra-dinh');

      final api2 = FakeHocTapApi();
      await pumpRoute(tester, api2, '/tra-dinh?tab=stats');
      expect(find.textContaining('Chỉ ghi cho hôm nay.'), findsNothing);
    });
  });
}

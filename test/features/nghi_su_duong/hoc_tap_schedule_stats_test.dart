import 'package:amber_flutter/features/nghi_su_duong/screens/hoc_tap_plan_detail_screen.dart';
import 'package:amber_flutter/features/nghi_su_duong/screens/hoc_tap_schedule_screen.dart';
import 'package:amber_flutter/features/nghi_su_duong/screens/hoc_tap_stats_screen.dart';
import 'package:amber_flutter/features/tra_dinh/hoc_tap/models/study_schedule.dart';
import 'package:amber_flutter/features/tra_dinh/hoc_tap/services/hoc_tap_api.dart';
import 'package:amber_flutter/features/tra_dinh/hoc_tap/widgets/missing_reason_sheet.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import '../tra_dinh/hoc_tap/hoc_tap_test_support.dart';

// Lịch dự kiến và Thống kê dựng độc lập ở Nghị Sự Đường: thân màn là cùng ScheduleTab / StatsTab của Trà Đình.

late GoRouter _router;

Future<FakeHocTapApi> _pump(
  WidgetTester tester,
  String location, {
  FakeHocTapApi? api,
}) async {
  tester.view.physicalSize = const Size(390, 4200);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  final fake = api ?? FakeHocTapApi();
  fake.schedules['2026-10-12|2026-10-18'] = StudySchedule.fromJson(
    fixtureMap('schedule_week'),
  );
  _router = GoRouter(
    initialLocation: location,
    routes: [
      GoRoute(
        path: '/hoc-tap',
        builder: (_, _) => const Scaffold(body: Text('màn kế hoạch')),
        routes: [
          GoRoute(
            path: 'chi-tiet',
            builder: (_, _) => const HocTapPlanDetailScreen(),
          ),
          GoRoute(
            path: 'lich',
            builder: (_, s) => HocTapScheduleScreen(
              view: s.uri.queryParameters['view'],
              date: s.uri.queryParameters['date'],
            ),
          ),
          GoRoute(
            path: 'thong-ke',
            builder: (_, s) => HocTapStatsScreen(
              range: s.uri.queryParameters['range'],
              subject: s.uri.queryParameters['subject'],
            ),
          ),
        ],
      ),
      GoRoute(
        path: '/tra-dinh/:rest(.*)',
        builder: (_, s) => Scaffold(body: Text('stub ${s.uri}')),
      ),
    ],
  );
  await tester.pumpWidget(
    ProviderScope(
      overrides: [hocTapApiProvider.overrideWithValue(fake)],
      child: MaterialApp.router(theme: ThemeData.dark(), routerConfig: _router),
    ),
  );
  await tester.pumpAndSettle();
  return fake;
}

Finder _k(String key) => find.byKey(ValueKey(key));

// URL của màn đang hiển thị (kể cả trang đã push / replace, nơi routerDelegate.currentConfiguration không phản ánh).
String _loc(WidgetTester tester) =>
    GoRouterState.of(tester.element(find.byType(Scaffold).last)).uri.toString();

void main() {
  group('Lịch dự kiến (/hoc-tap/lich)', () {
    testWidgets(
      'AppBar "‹ Chi tiết kế hoạch" + tiêu đề; thân là tab Lịch với dữ liệu giả',
      (tester) async {
        await _pump(tester, '/hoc-tap/lich?view=week&date=2026-10-15');
        expect(find.text('‹ Chi tiết kế hoạch'), findsOneWidget);
        expect(find.text('Lịch dự kiến'), findsOneWidget);
        expect(_k('view-toggle'), findsOneWidget);
        expect(find.text('12/10 – 18/10'), findsOneWidget);
        expect(
          _k('missing-reason-2026-10-12'),
          findsOneWidget,
          reason: 'dòng ngày thiếu lý do từ fixture',
        );
      },
    );

    testWidgets(
      'đổi Tháng / tuần sau: URL ở lại /hoc-tap/lich (không về /tra-dinh) và nút quay lại vẫn về Chi tiết kế hoạch',
      (tester) async {
        await _pump(tester, '/hoc-tap/chi-tiet');
        await tester.tap(find.text('Lịch dự kiến'));
        await tester.pumpAndSettle();
        expect(find.byType(HocTapScheduleScreen), findsOneWidget);

        await tester.tap(_k('view-month'));
        await tester.pumpAndSettle();
        expect(_loc(tester), startsWith('/hoc-tap/lich?view=month&date='));
        await tester.tap(_k('nav-next'));
        await tester.pumpAndSettle();
        expect(_loc(tester), startsWith('/hoc-tap/lich?view=month&date='));
        expect(_loc(tester), isNot(contains('/tra-dinh')));

        await tester.tap(find.text('‹ Chi tiết kế hoạch'));
        await tester.pumpAndSettle();
        expect(find.byType(HocTapPlanDetailScreen), findsOneWidget);
      },
    );

    testWidgets('bấm "Thiếu lý do" mở sheet nhập lý do như ở tab cũ', (
      tester,
    ) async {
      await _pump(tester, '/hoc-tap/lich?view=week&date=2026-10-15');
      await tester.tap(_k('missing-reason-2026-10-12'));
      await tester.pumpAndSettle();
      expect(find.byType(MissingReasonSheet), findsOneWidget);
    });

    testWidgets('chỉ có các nút vàng của phần thân (không thêm nút mới)', (
      tester,
    ) async {
      await _pump(tester, '/hoc-tap/lich?view=week&date=2026-10-15');
      expect(find.byType(FilledButton), findsNothing);
    });
  });

  group('Thống kê (/hoc-tap/thong-ke)', () {
    testWidgets(
      'AppBar "‹ Chi tiết kế hoạch" + tiêu đề; thân là tab Thống kê',
      (tester) async {
        await _pump(tester, '/hoc-tap/thong-ke?range=30&subject=all');
        expect(find.text('‹ Chi tiết kế hoạch'), findsOneWidget);
        expect(find.text('Thống kê'), findsOneWidget);
        expect(_k('range-7'), findsOneWidget);
        expect(_k('stats-subject-all'), findsOneWidget);
        expect(_k('tile-total'), findsOneWidget);
      },
    );

    testWidgets(
      'đổi khoảng / môn: URL ở lại /hoc-tap/thong-ke; quay lại về Chi tiết kế hoạch',
      (tester) async {
        final api = FakeHocTapApi();
        await _pump(tester, '/hoc-tap/chi-tiet', api: api);
        await tester.tap(find.text('Thống kê'));
        await tester.pumpAndSettle();
        await tester.tap(_k('range-7'));
        await tester.pumpAndSettle();
        expect(_loc(tester), startsWith('/hoc-tap/thong-ke?range=7&subject='));
        await tester.tap(_k('stats-subject-all'));
        await tester.pumpAndSettle();
        expect(_loc(tester), '/hoc-tap/thong-ke?range=7&subject=all');
        expect(api.statsCalls.last, (subjectId: null, range: '7'));

        await tester.tap(find.text('‹ Chi tiết kế hoạch'));
        await tester.pumpAndSettle();
        expect(find.byType(HocTapPlanDetailScreen), findsOneWidget);
      },
    );
  });
}

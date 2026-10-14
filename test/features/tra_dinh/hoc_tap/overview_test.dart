import 'package:amber_flutter/features/tra_dinh/hoc_tap/models/study_overview.dart';
import 'package:amber_flutter/features/tra_dinh/hoc_tap/screens/overview_tab.dart';
import 'package:amber_flutter/features/tra_dinh/hoc_tap/screens/tra_dinh_hoc_tap_screen.dart';
import 'package:amber_flutter/features/tra_dinh/hoc_tap/services/hoc_tap_api.dart';
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

  testWidgets('Ghi buổi học tạm báo "Sắp có"; link Chờ học và thẻ Luyện tập điều hướng đúng', (tester) async {
    await pumpHocTap(tester, const Scaffold(body: OverviewTab()), api: FakeHocTapApi());

    await tester.tap(find.text('Ghi buổi học'));
    await tester.pump();
    expect(find.text('Sắp có'), findsOneWidget);

    await tester.ensureVisible(find.byKey(const ValueKey('link-Chờ học')));
    await tester.tap(find.byKey(const ValueKey('link-Chờ học')));
    await tester.pumpAndSettle();
    expect(visited.last, contains('/tra-dinh/hoc-tap/courses?subjectId='));
    expect(visited.last, contains('status=QUEUED'));
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

  testWidgets('shell 3 tab: tab lưu ở ?tab=, Lịch và Thống kê là màn chờ "đang xây"', (tester) async {
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
    expect(find.byKey(const ValueKey('placeholder-Thống kê')), findsOneWidget, reason: '?tab=stats mở đúng tab');

    await tester.tap(find.text('Lịch'));
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('placeholder-Lịch')), findsOneWidget);
    expect(router.state.uri.toString(), '/tra-dinh?tab=schedule');

    await tester.tap(find.text('Tổng quan'));
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('week-chart')), findsOneWidget);
  });
}

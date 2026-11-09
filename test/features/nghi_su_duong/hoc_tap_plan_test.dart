import 'dart:async';

import 'package:amber_flutter/features/nghi_su_duong/models/overview.dart';
import 'package:amber_flutter/features/nghi_su_duong/providers/nghi_su_duong_provider.dart';
import 'package:amber_flutter/features/nghi_su_duong/screens/hoc_tap_plan_detail_screen.dart';
import 'package:amber_flutter/features/nghi_su_duong/screens/hoc_tap_plan_screen.dart';
import 'package:amber_flutter/features/nghi_su_duong/screens/nghi_su_duong_screen.dart';
import 'package:amber_flutter/features/nghi_su_duong/widgets/plan_widgets.dart';
import 'package:amber_flutter/features/tra_dinh/hoc_tap/models/study_overview.dart';
import 'package:amber_flutter/features/tra_dinh/hoc_tap/services/hoc_tap_api.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import '../tra_dinh/hoc_tap/hoc_tap_test_support.dart';

final _visited = <String>[];

Map<String, dynamic> _subject(
  Map<String, dynamic> base, {
  Object? goal = 'giữ',
  bool active = true,
  int queued = 2,
  String? id,
  String? name,
}) => {
  ...base,
  'subjectId': id ?? base['subjectId'],
  'name': name ?? base['name'],
  if (goal != 'giữ') 'goalMinutes': goal,
  if (!active) 'activeCourse': null,
  'counts': {'QUEUED': queued, 'DONE': 0, 'WISHLIST': 0},
};

StudyOverview _overview(List<Map<String, dynamic>> subjects) =>
    StudyOverview.fromJson({...fixtureMap('overview'), 'subjects': subjects});

Future<FakeHocTapApi> _pump(
  WidgetTester tester,
  String initial, {
  StudyOverview? overview,
  Object? overviewError,
}) async {
  tester.view.physicalSize = const Size(390, 2400);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  _visited.clear();
  final api = FakeHocTapApi(overview: overview)..overviewError = overviewError;
  final never = Completer<Never>();
  Widget stub(GoRouterState s) {
    _visited.add(s.uri.toString());
    return Scaffold(body: Text('stub ${s.uri}'));
  }

  final router = GoRouter(
    initialLocation: initial,
    routes: [
      GoRoute(
        path: '/',
        builder: (_, _) => const Scaffold(body: Text('trang gốc')),
      ),
      GoRoute(
        path: '/nghi-su-duong',
        builder: (_, _) => const NghiSuDuongScreen(),
      ),
      GoRoute(
        path: '/hoc-tap',
        builder: (_, _) => const HocTapPlanScreen(),
        routes: [
          GoRoute(path: 'lich', builder: (_, _) => const Scaffold(body: Text('lịch'))),
          GoRoute(path: 'thong-ke', builder: (_, _) => const Scaffold(body: Text('thống kê'))),
          GoRoute(
            path: 'chi-tiet',
            builder: (_, _) => const HocTapPlanDetailScreen(),
          ),
        ],
      ),
      GoRoute(path: '/tra-dinh', builder: (_, s) => stub(s)),
      GoRoute(path: '/tra-dinh/:rest(.*)', builder: (_, s) => stub(s)),
    ],
  );
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        hocTapApiProvider.overrideWithValue(api),
        duAnOverviewProvider.overrideWith(
          (ref) => never.future as Future<DuAnOverview>,
        ),
        financeOverviewProvider.overrideWith(
          (ref) => never.future as Future<FinanceOverview>,
        ),
      ],
      child: MaterialApp.router(theme: ThemeData.dark(), routerConfig: router),
    ),
  );
  await tester.pumpAndSettle();
  return api;
}

Map<String, dynamic> get _first =>
    (fixtureMap('overview')['subjects'] as List)[0] as Map<String, dynamic>;
Map<String, dynamic> get _second =>
    (fixtureMap('overview')['subjects'] as List)[1] as Map<String, dynamic>;

void main() {
  group('card Học tập ở Nghị Sự Đường', () {
    testWidgets(
      'hiện sau Dự án và Tài chính (ba card), dòng phụ là khóa đang học, bấm mở /hoc-tap',
      (tester) async {
        await _pump(tester, '/nghi-su-duong');
        double y(String t) => tester.getTopLeft(find.textContaining(t)).dy;
        expect(y('Dự án thông thường'), lessThan(y('Tài chính')));
        expect(y('Tài chính'), lessThan(y('Học tập')));
        expect(find.textContaining('Học tập'), findsOneWidget);
        expect(find.text('Đang học: English Tenses 101'), findsOneWidget);
        await tester.tap(find.textContaining('Học tập'));
        await tester.pumpAndSettle();
        expect(find.byType(HocTapPlanScreen), findsOneWidget);
      },
    );

    testWidgets('không có khóa đang học: dòng phụ là "N khóa chờ"', (
      tester,
    ) async {
      await _pump(
        tester,
        '/nghi-su-duong',
        overview: _overview([_subject(_first, active: false, queued: 3)]),
      );
      expect(find.text('3 khóa chờ'), findsOneWidget);
    });

    testWidgets('lỗi tải: chỉ có tiêu đề, card vẫn bấm được', (tester) async {
      await _pump(tester, '/nghi-su-duong', overviewError: apiError(500, 'x'));
      expect(find.textContaining('Học tập'), findsOneWidget);
      expect(find.byKey(const ValueKey('learn-card-line')), findsNothing);
      await tester.tap(find.textContaining('Học tập'));
      await tester.pumpAndSettle();
      expect(find.byType(HocTapPlanScreen), findsOneWidget);
    });
  });

  group('màn Học tập (kế hoạch)', () {
    testWidgets(
      'đầu màn: "‹ Nghị Sự Đường", tiêu đề, dòng phụ; quay lại về Nghị Sự Đường',
      (tester) async {
        await _pump(tester, '/nghi-su-duong');
        await tester.tap(find.textContaining('Học tập'));
        await tester.pumpAndSettle();
        expect(find.text('‹ Nghị Sự Đường'), findsOneWidget);
        expect(find.text('Học tập'), findsOneWidget);
        expect(find.text('Học gì, bao nhiêu phút mỗi ngày'), findsOneWidget);
        await tester.tap(find.text('‹ Nghị Sự Đường'));
        await tester.pumpAndSettle();
        expect(find.byType(NghiSuDuongScreen), findsOneWidget);
      },
    );

    testWidgets(
      'thẻ môn có mục tiêu + khóa đang học: ĐANG HỌC, tên khóa, "N / M phần", "Dự kiến xong"',
      (tester) async {
        await _pump(
          tester,
          '/hoc-tap',
          overview: _overview([_subject(_first)]),
        );
        expect(find.text('Tiếng Anh'), findsOneWidget);
        expect(find.text('60 phút / ngày'), findsOneWidget);
        expect(find.text('ĐANG HỌC'), findsOneWidget);
        expect(find.text('English Tenses 101'), findsOneWidget);
        expect(find.text('1 / 4 phần'), findsOneWidget);
        expect(find.text('Dự kiến xong 23/10'), findsOneWidget);
      },
    );

    testWidgets(
      'thẻ môn chưa đặt mục tiêu và không có khóa đang học: không có khối "Đang học"',
      (tester) async {
        await _pump(
          tester,
          '/hoc-tap',
          overview: _overview([_subject(_second, goal: null, active: false)]),
        );
        expect(find.text('Chưa đặt mục tiêu'), findsOneWidget);
        expect(find.text('ĐANG HỌC'), findsNothing);
        expect(find.textContaining('Dự kiến xong'), findsNothing);
      },
    );

    testWidgets('khóa đang học không có dự kiến: ẩn "Dự kiến xong"', (
      tester,
    ) async {
      final base = {
        ..._first,
        'activeCourse': {
          ...(_first['activeCourse'] as Map<String, dynamic>),
          'forecastFinishDate': null,
        },
      };
      await _pump(tester, '/hoc-tap', overview: _overview([_subject(base)]));
      expect(find.text('1 / 4 phần'), findsOneWidget);
      expect(find.textContaining('Dự kiến xong'), findsNothing);
    });

    testWidgets(
      'bấm thẻ: có khóa đang học → chi tiết khóa; không có → danh sách khóa của môn',
      (tester) async {
        final a = _subject(_first),
            b = _subject(
              _second,
              active: false,
              id: 'sub-2',
              name: 'Lập trình',
            );
        await _pump(tester, '/hoc-tap', overview: _overview([a, b]));
        await tester.tap(
          find.byKey(ValueKey('plan-subject-${a['subjectId']}')),
        );
        await tester.pumpAndSettle();
        expect(
          _visited.last,
          '/tra-dinh/hoc-tap/courses/ac6b30ba-9a71-4979-9225-ab7ad51a3d3a',
        );
        GoRouter.of(tester.element(find.byType(Scaffold).last)).pop();
        await tester.pumpAndSettle();
        await tester.tap(find.byKey(const ValueKey('plan-subject-sub-2')));
        await tester.pumpAndSettle();
        expect(_visited.last, '/tra-dinh/hoc-tap/courses?subjectId=sub-2');
      },
    );

    testWidgets(
      'hàng "Hàng chờ": tổng khóa chờ; một môn → hàng chờ của môn; nhiều môn → hàng chờ chung',
      (tester) async {
        await _pump(
          tester,
          '/hoc-tap',
          overview: _overview([_subject(_first, queued: 2)]),
        );
        expect(find.text('Hàng chờ'), findsOneWidget);
        expect(find.text('Hàng chờ và Muốn mua'), findsNothing, reason: 'nhãn cũ đã đổi');
        expect(find.text('2 khóa chờ'), findsOneWidget);
        expect(
          tester.getSize(find.byKey(const ValueKey('plan-queue'))).height,
          greaterThanOrEqualTo(52),
        );
        await tester.tap(find.byKey(const ValueKey('plan-queue')));
        await tester.pumpAndSettle();
        expect(
          _visited.last,
          '/tra-dinh/hoc-tap/courses?subjectId=${_first['subjectId']}&status=QUEUED',
        );

        await _pump(
          tester,
          '/hoc-tap',
          overview: _overview([
            _subject(_first, queued: 2),
            _subject(_second, queued: 1, id: 'sub-2'),
          ]),
        );
        expect(find.text('3 khóa chờ'), findsOneWidget);
        await tester.tap(find.byKey(const ValueKey('plan-queue')));
        await tester.pumpAndSettle();
        expect(_visited.last, '/tra-dinh/hoc-tap/courses?status=QUEUED');
      },
    );

    testWidgets(
      'đúng MỘT nút vàng "+ Thêm khóa" (cao ≥ 48), bấm mở form thêm khóa',
      (tester) async {
        await _pump(
          tester,
          '/hoc-tap',
          overview: _overview([_subject(_first)]),
        );
        expect(find.byType(FilledButton), findsOneWidget);
        expect(
          tester.getSize(find.byKey(const ValueKey('plan-add-course'))).height,
          greaterThanOrEqualTo(48),
        );
        await tester.tap(find.byKey(const ValueKey('plan-add-course')));
        await tester.pumpAndSettle();
        expect(
          find.byKey(const ValueKey('course-subject')),
          findsOneWidget,
          reason: 'form thêm khóa đã mở',
        );
      },
    );

    testWidgets(
      'cuối màn: đường kẻ + "Chi tiết kế hoạch" với dòng phụ; bấm mở /hoc-tap/chi-tiet',
      (tester) async {
        await _pump(
          tester,
          '/hoc-tap',
          overview: _overview([_subject(_first)]),
        );
        expect(
          find.text('Lịch dự kiến · Thống kê · Muốn mua · Thùng rác'),
          findsOneWidget,
        );
        expect(find.byType(Divider), findsOneWidget);
        double y(String k) => tester.getTopLeft(find.byKey(ValueKey(k))).dy;
        expect(y('plan-add-course'), lessThan(y('plan-details')));
        await tester.tap(find.byKey(const ValueKey('plan-details')));
        await tester.pumpAndSettle();
        expect(find.byType(HocTapPlanDetailScreen), findsOneWidget);
      },
    );

    testWidgets(
      'rỗng: lời mời, vẫn có "+ Thêm khóa" (một nút vàng) và "Thêm môn học"',
      (tester) async {
        await _pump(tester, '/hoc-tap', overview: _overview([]));
        expect(find.byKey(const ValueKey('plan-empty')), findsOneWidget);
        expect(find.byType(FilledButton), findsOneWidget);
        expect(find.byKey(const ValueKey('plan-add-course')), findsOneWidget);
        expect(find.byKey(const ValueKey('plan-add-subject')), findsOneWidget);
      },
    );

    testWidgets('lỗi tải: báo lỗi + Thử lại', (tester) async {
      await _pump(tester, '/hoc-tap', overviewError: apiError(500, 'x'));
      expect(find.text('Không tải được kế hoạch học tập.'), findsOneWidget);
      expect(find.text('Thử lại'), findsOneWidget);
      expect(find.byKey(const ValueKey('plan-add-course')), findsNothing);
    });
  });

  group('màn Chi tiết kế hoạch', () {
    testWidgets(
      'đúng bốn hàng theo thứ tự, cao ≥ 52, không nút vàng, không còn "Lý do thiếu"; mỗi hàng đi đúng route và Back về lại màn này',
      (tester) async {
        // Lịch / Thống kê là màn của Nghị Sự Đường; Muốn mua / Thùng rác là màn Trà Đình (stub ghi lại đường dẫn).
        final rows = [
          ('plan-schedule', 'Lịch dự kiến', '/hoc-tap/lich'),
          ('plan-stats', 'Thống kê', '/hoc-tap/thong-ke'),
          ('plan-wishlist', 'Muốn mua', '/tra-dinh/hoc-tap/wishlist'),
          ('plan-trash', 'Thùng rác', '/tra-dinh/hoc-tap/thung-rac'),
        ];
        await _pump(tester, '/hoc-tap/chi-tiet');
        expect(find.text('‹ Học tập'), findsOneWidget);
        expect(find.text('Chi tiết kế hoạch'), findsOneWidget);
        expect(find.byType(FilledButton), findsNothing);
        expect(find.text('Lý do thiếu'), findsNothing);
        expect(find.byType(PlanNavRow), findsNWidgets(4));
        final ys = [
          for (final r in rows) tester.getTopLeft(find.byKey(ValueKey(r.$1))).dy,
        ];
        expect(ys, [...ys]..sort(), reason: 'đúng thứ tự từ trên xuống');
        for (final (key, label, route) in rows) {
          expect(find.text(label), findsOneWidget);
          expect(
            tester.getSize(find.byKey(ValueKey(key))).height,
            greaterThanOrEqualTo(52),
          );
          await tester.tap(find.byKey(ValueKey(key)));
          await tester.pumpAndSettle();
          if (route.startsWith('/tra-dinh')) {
            expect(_visited.last, route, reason: key);
          } else {
            expect(
              GoRouterState.of(tester.element(find.byType(Scaffold).last)).uri.toString(),
              route,
              reason: key,
            );
          }
          GoRouter.of(tester.element(find.byType(Scaffold).last)).pop();
          await tester.pumpAndSettle();
          expect(find.byType(HocTapPlanDetailScreen), findsOneWidget, reason: '$key: Back về Chi tiết kế hoạch');
        }
      },
    );
  });
}

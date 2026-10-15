import 'package:amber_flutter/features/tra_dinh/hoc_tap/models/study_enums.dart';
import 'package:amber_flutter/features/tra_dinh/hoc_tap/models/study_stats.dart';
import 'package:amber_flutter/features/tra_dinh/hoc_tap/providers/hoc_tap_provider.dart' show StatsQuery;
import 'package:amber_flutter/features/tra_dinh/hoc_tap/screens/tra_dinh_hoc_tap_screen.dart';
import 'package:amber_flutter/features/tra_dinh/hoc_tap/services/hoc_tap_api.dart';
import 'package:amber_flutter/features/tra_dinh/hoc_tap/widgets/stats_chart.dart';
import 'package:amber_flutter/shared/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import 'hoc_tap_test_support.dart';

// Tab Thống kê với fixture thật chụp từ backend dev (hôm nay lúc chụp = 2026-10-15). stats_all có bucket "week" thật:
// backend dev được dựng 120 ngày log bằng SQL nên không phải tự viết fixture.

StudyStats _stats(String name, [void Function(Map<String, dynamic> json)? edit]) {
  final json = Map<String, dynamic>.from(fixtureMap(name));
  edit?.call(json);
  return StudyStats.fromJson(json);
}

Finder _k(String key) => find.byKey(ValueKey(key));
late GoRouter _router;

Future<FakeHocTapApi> _pump(WidgetTester tester, {FakeHocTapApi? api, String location = '/tra-dinh?tab=stats', bool settle = true}) async {
  final fake = api ?? FakeHocTapApi();
  tester.view.physicalSize = const Size(390, 4200);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  _router = GoRouter(
    initialLocation: location,
    routes: [
      GoRoute(
        path: '/tra-dinh',
        builder: (_, state) => TraDinhHocTapScreen(
          tab: state.uri.queryParameters['tab'],
          view: state.uri.queryParameters['view'],
          date: state.uri.queryParameters['date'],
          range: state.uri.queryParameters['range'],
          subject: state.uri.queryParameters['subject'],
        ),
      ),
    ],
  );
  await tester.pumpWidget(ProviderScope(overrides: [hocTapApiProvider.overrideWithValue(fake)], child: MaterialApp.router(theme: ThemeData.dark(), routerConfig: _router)));
  settle ? await tester.pumpAndSettle() : await tester.pump(const Duration(milliseconds: 50));
  return fake;
}

Color? _barColor(WidgetTester tester, int i) => ((tester.widget<Container>(_k('bar-$i')).decoration) as BoxDecoration).color;
double _barHeight(WidgetTester tester, int i) => tester.getSize(_k('bar-$i')).height;

void main() {
  group('model', () {
    test('StudyStats.fromJson: 30 ngày (một môn)', () {
      final s = _stats('stats_30');
      expect(s.isWeekly, isFalse);
      expect(s.series.length, 30);
      expect((s.totalMinutes, s.logCount, s.avgPerDay), (900, 16, 30));
      expect((s.goalDaysMet, s.goalDaysTotal), (9, 29));
      expect(s.byCourse.map((c) => c.title), ['English Tenses 101', 'Ôn tập']);
      expect(s.byCourse.last.courseId, isNull);
      expect(s.vsPlan.map((p) => p.status), [CourseStatus.active, CourseStatus.queued, CourseStatus.done]);
      expect(s.reasonCounts.busy, 2);
      expect(s.reasonCounts.total, 4);
      expect(s.longestDay?.minutes, 90);
      expect(s.topWeekday?.weekday, 2);
      expect(s.overallDeltaDays.single.deltaDays, 0);
    });

    test('stats_all: bucket week thật (> 92 ngày), mỗi điểm là thứ Hai', () {
      final s = _stats('stats_all');
      expect(s.bucket, 'week');
      expect(s.isWeekly, isTrue);
      expect(s.series.length, 18);
      expect(s.series.every((p) => DateTime.parse(p.start).weekday == DateTime.monday), isTrue);
      expect(s.series[1].goalMinutes, 420, reason: '7 ngày × 60 phút');
      expect(s.series.first.goalMinutes, inInclusiveRange(60, 420), reason: 'tuần đầu bị cắt theo ngày log đầu tiên');
    });

    test('rỗng: stats_empty không có buổi, không có khóa, mọi số 0', () {
      final s = _stats('stats_empty');
      expect(s.hasLogs, isFalse);
      expect(s.series, isEmpty);
      expect(s.byCourse, isEmpty);
      expect(s.vsPlan, isEmpty);
      expect(s.longestDay, isNull);
      expect(s.topWeekday, isNull);
      expect(s.reasonCounts.total, 0);
      expect(s.overallDeltaDays.single.deltaDays, isNull);
    });

    test('tất cả môn: mỗi môn một overallDeltaDays', () {
      expect(_stats('stats_all_subjects').overallDeltaDays.length, 3);
    });

    test('thiếu trường / giá trị lạ không crash', () {
      final s = StudyStats.fromJson({'from': '2026-10-01', 'to': '2026-10-02', 'totalMinutes': 0, 'logCount': 0, 'avgPerDay': 0});
      expect(s.series, isEmpty);
      expect(s.bucket, 'day');
      expect(s.reasonCounts.total, 0);
      expect(PlanEntry.fromJson({'courseId': 'c', 'title': 't', 'status': 'LẠ'}).status, CourseStatus.unknown);
    });

    test('StatsQuery so sánh theo giá trị', () {
      expect(const StatsQuery(subjectId: 'a', range: '7'), isNot(const StatsQuery(subjectId: 'a', range: '30')));
    });
  });

  group('tab Thống kê', () {
    testWidgets('mặc định: 30 ngày, môn đầu tiên; 4 ô số, 2 ô phụ, lý do', (tester) async {
      final api = await _pump(tester);
      expect(api.statsCalls.last, (subjectId: api.subjects.first.id, range: '30'));
      Text t(String key) => tester.widget<Text>(find.descendant(of: _k(key), matching: find.byType(Text)).last);
      expect(t('tile-total').data, '15h');
      expect(t('tile-logs').data, '16');
      expect(t('tile-avg').data, '30p');
      expect(t('tile-goal').data, '9/29');
      expect(t('tile-longest').data, '22/09 · 1h 30p');
      expect(t('tile-weekday').data, 'Thứ Ba · 2h 40p');
      expect(tester.widget<Text>(_k('reasons')).data, 'Bận việc 2 · Mệt 1 · Khác 1');
      expect(find.text('Phút theo ngày'), findsOneWidget);
    });

    testWidgets('đổi khoảng và môn đổi query + URL', (tester) async {
      final api = await _pump(tester);
      final id = api.subjects.first.id;
      await tester.tap(_k('range-7'));
      await tester.pumpAndSettle();
      expect(api.statsCalls.last, (subjectId: id, range: '7'));
      expect(_router.state.uri.toString(), '/tra-dinh?tab=stats&range=7&subject=$id');
      expect(find.byKey(const ValueKey('bar-6')), findsOneWidget);
      expect(find.byKey(const ValueKey('bar-7')), findsNothing, reason: '7 cột');

      await tester.tap(_k('stats-subject-all'));
      await tester.pumpAndSettle();
      expect(api.statsCalls.last, (subjectId: null, range: '7'));
      expect(_router.state.uri.toString(), '/tra-dinh?tab=stats&range=7&subject=all');

      await tester.tap(_k('range-all'));
      await tester.pumpAndSettle();
      expect(api.statsCalls.last, (subjectId: null, range: 'all'));

      await tester.tap(_k('stats-subject-${api.subjects[1].id}'));
      await tester.pumpAndSettle();
      expect(api.statsCalls.last, (subjectId: api.subjects[1].id, range: 'all'));
    });

    testWidgets('URL có sẵn range + subject; subject lạ rơi về môn đầu', (tester) async {
      final api = FakeHocTapApi();
      await _pump(tester, api: api, location: '/tra-dinh?tab=stats&range=7&subject=all');
      expect(api.statsCalls.last, (subjectId: null, range: '7'));
      final api2 = FakeHocTapApi();
      await _pump(tester, api: api2, location: '/tra-dinh?tab=stats&range=bậy&subject=khong-co');
      expect(api2.statsCalls.last, (subjectId: api2.subjects.first.id, range: '30'));
    });

    testWidgets('cột đạt mục tiêu vàng đậm, chưa đạt vàng nhạt, 0 phút là vạch mảnh', (tester) async {
      await _pump(tester);
      final s = _stats('stats_30');
      var reached = 0, partial = 0, zero = 0;
      for (final (i, p) in s.series.indexed) {
        if (p.minutes == 0) {
          zero++;
          expect(_barHeight(tester, i), 2, reason: 'ngày $i');
        } else if (p.reachedGoal) {
          reached++;
          expect(_barColor(tester, i), AppColors.kincha400);
        } else {
          partial++;
          expect(_barColor(tester, i)!.a, lessThan(0.5));
        }
      }
      expect(reached, greaterThan(0));
      expect(partial, greaterThan(0));
      expect(zero, greaterThan(0));
      expect(find.byKey(const ValueKey('goal-tick-0')), findsOneWidget, reason: 'vạch mục tiêu');
    });

    testWidgets('chạm cột hiện nhãn "<ngày>: X / Y phút"', (tester) async {
      await _pump(tester);
      final s = _stats('stats_30');
      expect(tester.widget<Text>(_k('chart-label')).data, 'Chạm vào một cột để xem chi tiết');
      final i = s.series.indexWhere((p) => p.minutes >= 60);
      await tester.tap(_k('bar-slot-$i'));
      await tester.pump();
      final p = s.series[i];
      expect(tester.widget<Text>(_k('chart-label')).data, StatsBarChart.pointLabel(p, weekly: false));
      expect(tester.widget<Text>(_k('chart-label')).data, matches(RegExp(r'^\d{2}/\d{2}: \d+ / 60 phút$')));
    });

    testWidgets('bucket week (range=all): 18 cột theo tuần, tiêu đề và nhãn theo tuần', (tester) async {
      final api = await _pump(tester, location: '/tra-dinh?tab=stats&range=all&subject=x');
      expect(api.statsCalls.last.range, 'all');
      expect(find.text('Phút theo tuần'), findsOneWidget);
      expect(find.byKey(const ValueKey('bar-17')), findsOneWidget);
      expect(find.byKey(const ValueKey('bar-18')), findsNothing);
      await tester.tap(_k('bar-slot-1'));
      await tester.pump();
      expect(tester.widget<Text>(_k('chart-label')).data, startsWith('Tuần '));
      expect(tester.widget<Text>(_k('chart-label')).data, contains(' / 420 phút'));
    });

    testWidgets('Semantics tóm tắt biểu đồ', (tester) async {
      final handle = tester.ensureSemantics();
      await _pump(tester);
      expect(find.bySemanticsLabel(RegExp('^30 ngày, trung bình 30 phút mỗi ngày, đạt mục tiêu 9/29 ngày')), findsOneWidget);
      handle.dispose();
    });

    testWidgets('theo khóa: "Ôn tập" cho log không gắn khóa, kèm "Xg Yp · N buổi"', (tester) async {
      await _pump(tester);
      expect(find.descendant(of: _k('by-course-review'), matching: find.text('Ôn tập')), findsOneWidget);
      final s = _stats('stats_30');
      final review = s.byCourse.firstWhere((c) => c.courseId == null);
      expect(find.descendant(of: _k('by-course-review'), matching: find.text('7h 20p · ${review.logCount} buổi')), findsOneWidget);
      final c = s.byCourse.firstWhere((c) => c.courseId != null);
      expect(find.descendant(of: _k('by-course-${c.courseId}'), matching: find.text('English Tenses 101')), findsOneWidget);
    });

    testWidgets('so với kế hoạch: dự kiến / gốc / sớm-trễ-đúng; DONE "Xong dd/MM"; tổng lộ trình', (tester) async {
      final stats = _stats('stats_30', (j) {
        final plan = (j['vsPlan'] as List).cast<Map<String, dynamic>>();
        plan[0]..['forecastFinishDate'] = '2026-10-22'..['baselineFinishDate'] = '2026-10-24'..['deltaDays'] = -2..['progressPct'] = 25;
        plan[1]..['forecastFinishDate'] = '2026-11-05'..['baselineFinishDate'] = '2026-11-02'..['deltaDays'] = 3;
        plan[2]..['status'] = 'DONE'..['finishedDate'] = '2026-10-09'..['baselineFinishDate'] = '2026-10-10'..['deltaDays'] = -1..['progressPct'] = 100;
        (j['overallDeltaDays'] as List).first['deltaDays'] = 2;
      });
      final api = FakeHocTapApi()..statsResponses['30|one'] = stats;
      await _pump(tester, api: api);
      final ids = stats.vsPlan.map((p) => p.courseId).toList();
      Text line(int i) => tester.widget<Text>(_k('plan-line-${ids[i]}'));
      expect(line(0).data, 'Dự kiến xong 22/10/2026 · gốc 24/10 · sớm 2 ngày');
      expect(line(1).data, 'Dự kiến xong 05/11/2026 · gốc 02/11 · trễ 3 ngày');
      expect(line(2).data, 'Xong 09/10 · sớm 1 ngày');
      expect(find.text('25%'), findsOneWidget);
      expect(find.text('100%'), findsOneWidget);
      expect(find.text('Cả lộ trình: trễ 2 ngày'), findsOneWidget);
      // màu: sớm ≠ trễ
      expect(line(0).style!.color, isNot(line(1).style!.color));
    });

    testWidgets('đúng kế hoạch; thiếu mốc thì không có đoạn sớm/trễ', (tester) async {
      final stats = _stats('stats_30', (j) {
        final plan = (j['vsPlan'] as List).cast<Map<String, dynamic>>();
        plan[0]..['deltaDays'] = 0..['forecastFinishDate'] = '2026-10-22'..['baselineFinishDate'] = '2026-10-22';
        plan[1]..['deltaDays'] = null..['baselineFinishDate'] = null..['forecastFinishDate'] = '2026-11-05';
        (j['overallDeltaDays'] as List).first['deltaDays'] = 0;
      });
      final api = FakeHocTapApi()..statsResponses['30|one'] = stats;
      await _pump(tester, api: api);
      final ids = stats.vsPlan.map((p) => p.courseId).toList();
      expect(tester.widget<Text>(_k('plan-line-${ids[0]}')).data, 'Dự kiến xong 22/10/2026 · gốc 22/10 · đúng kế hoạch');
      expect(tester.widget<Text>(_k('plan-line-${ids[1]}')).data, 'Dự kiến xong 05/11/2026');
      expect(find.text('Cả lộ trình: đúng kế hoạch'), findsOneWidget);
    });

    testWidgets('tất cả môn: mỗi môn có delta một dòng "Cả lộ trình" kèm tên môn', (tester) async {
      final api = FakeHocTapApi();
      final stats = _stats('stats_all_subjects', (j) {
        final ids = [api.subjects[0].id, api.subjects[1].id, 'khong-co-ten'];
        final list = (j['overallDeltaDays'] as List).cast<Map<String, dynamic>>();
        for (var i = 0; i < 3; i++) {
          list[i]['subjectId'] = ids[i];
        }
        list[0]['deltaDays'] = -2;
        list[1]['deltaDays'] = 4;
        list[2]['deltaDays'] = null; // môn chưa có mốc → không có dòng
      });
      api.statsResponses['30|all'] = stats;
      await _pump(tester, api: api, location: '/tra-dinh?tab=stats&range=30&subject=all');
      expect(find.text('Tiếng Anh · Cả lộ trình: sớm 2 ngày'), findsOneWidget);
      expect(find.text('Lập trình · Cả lộ trình: trễ 4 ngày'), findsOneWidget);
      expect(find.textContaining('Cả lộ trình'), findsNWidgets(2));
    });

    testWidgets('lý do: ẩn khi đều 0', (tester) async {
      final api = FakeHocTapApi()..statsResponses['30|one'] = _stats('stats_30', (j) => j['reasonCounts'] = {'BUSY': 0, 'TIRED': 0, 'AWAY': 0, 'OTHER': 0});
      await _pump(tester, api: api);
      expect(_k('reasons'), findsNothing);
      expect(find.text('Lý do dừng sớm'), findsNothing);
    });

    testWidgets('trạng thái trống: không có buổi → thông báo; So với kế hoạch vẫn hiện nếu có khóa', (tester) async {
      final api = FakeHocTapApi()
        ..statsResponses['30|one'] = _stats('stats_empty', (j) {
          j['vsPlan'] = [
            {'courseId': 'c1', 'title': 'Khóa mới', 'status': 'QUEUED', 'progressPct': 0, 'baselineFinishDate': null, 'forecastFinishDate': '2026-11-01', 'finishedDate': null, 'deltaDays': null},
          ];
        });
      await _pump(tester, api: api);
      expect(_k('stats-empty'), findsOneWidget);
      expect(find.textContaining('Chưa có buổi học nào trong khoảng này'), findsOneWidget);
      expect(_k('stats-chart'), findsNothing);
      expect(_k('tile-total'), findsNothing);
      expect(_k('by-course'), findsNothing);
      expect(_k('vs-plan'), findsOneWidget);
      expect(find.text('Khóa mới'), findsOneWidget);
    });

    testWidgets('trống hoàn toàn (không buổi, không khóa): chỉ thông báo', (tester) async {
      final api = FakeHocTapApi()..statsResponses['30|one'] = _stats('stats_empty');
      await _pump(tester, api: api);
      expect(_k('stats-empty'), findsOneWidget);
      expect(_k('vs-plan'), findsNothing);
    });

    testWidgets('lỗi hiện ngay + Thử lại (không kẹt khung chờ khi Riverpod tự thử lại)', (tester) async {
      final api = FakeHocTapApi()..statsError = apiError(500, {'error': 'x'});
      await _pump(tester, api: api);
      expect(find.textContaining('Không tải được thống kê'), findsOneWidget);
      api.statsError = null;
      await tester.tap(find.text('Thử lại'));
      await tester.pumpAndSettle();
      expect(find.textContaining('Không tải được thống kê'), findsNothing);
      expect(_k('tile-total'), findsOneWidget);
    });

    testWidgets('chuyển sang tab Thống kê từ thanh tab; mutation không liên quan không phá URL', (tester) async {
      await _pump(tester, location: '/tra-dinh');
      await tester.tap(find.text('Thống kê'));
      await tester.pumpAndSettle();
      expect(_k('tile-total'), findsOneWidget);
      expect(_router.state.uri.queryParameters['tab'], 'stats');
    });
  });
}

import 'dart:async';

import 'package:amber_flutter/features/tra_dinh/hoc_tap/models/study_schedule.dart';
import 'package:amber_flutter/features/tra_dinh/hoc_tap/screens/tra_dinh_hoc_tap_screen.dart';
import 'package:amber_flutter/features/tra_dinh/hoc_tap/widgets/schedule_day_row.dart';
import 'package:amber_flutter/shared/utils/vn_time.dart';
import 'package:amber_flutter/shared/widgets/progress_bar.dart';
import 'package:amber_flutter/features/tra_dinh/hoc_tap/services/hoc_tap_api.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import 'hoc_tap_test_support.dart';

// Tab Lịch (tuần + tháng) với fixture thật chụp từ backend dev (hôm nay lúc chụp = 2026-10-15, thứ Năm).

const _weekKey = '2026-10-12|2026-10-18';
const _octKey = '2026-09-28|2026-11-01';
const _novKey = '2026-10-26|2026-12-06';

StudySchedule _sched(String name, [void Function(Map<String, dynamic> json)? edit]) {
  final json = Map<String, dynamic>.from(fixtureMap(name));
  edit?.call(json);
  return StudySchedule.fromJson(json);
}

Map<String, dynamic> _day(Map<String, dynamic> json, String date) => (json['days'] as List).cast<Map<String, dynamic>>().firstWhere((d) => d['date'] == date);

Finder _k(String key) => find.byKey(ValueKey(key));

late GoRouter _router;

Future<void> _pump(WidgetTester tester, FakeHocTapApi api, String location, {bool settle = true}) async {
  tester.view.physicalSize = const Size(390, 3600);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  _router = GoRouter(
    initialLocation: location,
    routes: [
      GoRoute(
        path: '/tra-dinh',
        builder: (_, state) => TraDinhHocTapScreen(
          tab: state.uri.queryParameters['tab'],
          openLog: state.uri.queryParameters['openLog'] == '1',
          subjectId: state.uri.queryParameters['subjectId'],
          view: state.uri.queryParameters['view'],
          date: state.uri.queryParameters['date'],
        ),
      ),
    ],
  );
  await tester.pumpWidget(ProviderScope(overrides: [hocTapApiProvider.overrideWithValue(api)], child: MaterialApp.router(theme: ThemeData.dark(), routerConfig: _router)));
  if (settle) {
    await tester.pumpAndSettle();
  } else {
    await tester.pump(const Duration(milliseconds: 50));
  }
}

FakeHocTapApi _api({StudySchedule? week, StudySchedule? oct, StudySchedule? nov}) {
  final api = FakeHocTapApi();
  api.schedules[_weekKey] = week ?? _sched('schedule_week');
  api.schedules[_octKey] = oct ?? _sched('schedule_month_oct');
  api.schedules[_novKey] = nov ?? _sched('schedule_month_42');
  return api;
}

const _weekUrl = '/tra-dinh?tab=schedule&view=week&date=2026-10-15';
const _monthUrl = '/tra-dinh?tab=schedule&view=month&date=2026-10-15';

void main() {
  group('model', () {
    test('ScheduleDay.fromJson: past / today / planned và missingReason', () {
      final s = _sched('schedule_week');
      final byDate = {for (final d in s.days) d.date: d};
      expect(s.days.length, 7);
      expect(byDate['2026-10-12']!.kind, ScheduleKind.past);
      expect(byDate['2026-10-12']!.missingReason, isTrue, reason: 'đã qua, chưa đủ, chưa có lý do');
      expect(byDate['2026-10-13']!.missingReason, isFalse, reason: 'đã có lý do');
      expect(byDate['2026-10-14']!.done, isTrue);
      expect(byDate['2026-10-14']!.extraMinutes, 10);
      expect(byDate['2026-10-15']!.kind, ScheduleKind.today);
      expect(byDate['2026-10-15']!.plannedItems, isNull, reason: 'hôm nay đã có buổi → không có kế hoạch');
      expect(byDate['2026-10-16']!.isPlanned, isTrue);
      expect(byDate['2026-10-16']!.plannedMinutes, 40);
      expect(byDate['2026-10-18']!.isReviewDay, isTrue);
      expect(byDate['2026-10-18']!.plannedItems, isEmpty);
      expect(s.summary.minutes, 120);
      expect(s.summary.plannedMinutes, 80);
      expect(s.summary.activeDelta, 0);
    });

    test('kind lạ → planned; thiếu trường không crash', () {
      expect(ScheduleKind.fromApi('weird'), ScheduleKind.planned);
      final d = ScheduleDay.fromJson({'date': '2026-10-20', 'kind': 'weird'});
      expect(d.isPlanned, isTrue);
      expect(d.milestones, isEmpty);
      expect(d.missingReason, isFalse);
    });

    test('môn không mục tiêu: goalMinutes null, không bao giờ "thiếu lý do"', () {
      final s = _sched('schedule_no_goal');
      expect(s.days.every((d) => d.goalMinutes == null && !d.missingReason), isTrue);
    });

    test('groupPlanned gom theo khóa, giữ thứ tự và cộng phút', () {
      final g = groupPlanned(const [
        PlannedItem(courseId: 'a', courseTitle: 'Khóa A', sectionId: '1', title: 'P1', minutes: 20),
        PlannedItem(courseId: 'b', courseTitle: 'Khóa B', sectionId: '2', title: 'Q1', minutes: 10),
        PlannedItem(courseId: 'a', courseTitle: 'Khóa A', sectionId: '3', title: 'P2', minutes: 20),
      ]);
      expect(g.map((e) => '${e.courseTitle}|${e.sections.join(',')}|${e.minutes}'), ['Khóa A|P1,P2|40', 'Khóa B|Q1|10']);
      expect(shortCourseName('Tên khóa học rất rất rất dài dòng', 12), 'Tên khóa họ…');
      expect(shortCourseName('Ngắn', 12), 'Ngắn');
    });
  });

  group('xem tuần', () {
    testWidgets('đủ past / today / planned / review; tổng kết tuần', (tester) async {
      final week = _sched('schedule_week', (j) => _day(j, '2026-10-17')['milestones'] = [{'courseId': 'c1', 'courseTitle': 'English Tenses 101', 'type': 'finish'}]);
      await _pump(tester, _api(week: week), _weekUrl);

      expect(find.text('12/10 – 18/10'), findsOneWidget);
      for (var d = 12; d <= 18; d++) {
        expect(_k('day-2026-10-$d'), findsOneWidget);
      }
      // past: thiếu lý do / dừng sớm / học vượt
      expect(_k('missing-reason-2026-10-12'), findsOneWidget);
      expect(find.text('Không học'), findsOneWidget);
      expect(find.text('Dừng sớm: Bận'), findsOneWidget);
      expect(_k('missing-reason-2026-10-13'), findsNothing);
      expect(find.text('Học vượt 10 phút'), findsOneWidget);
      expect(find.text('1h 10p / 1h'), findsOneWidget);
      // buổi thật: khóa · phần có dấu xong
      expect(find.textContaining('English Tenses 101 · Basics ✓'), findsWidgets);
      // today: còn X phút + viền nổi; không có gợi ý vì đã có buổi
      expect(find.text('Còn 40p'), findsOneWidget);
      // planned: viền đứt + kế hoạch gom theo khóa
      expect(find.text('Dự kiến · 60 phút'), findsNWidgets(3));
      expect(find.byKey(const ValueKey('plan-English Tenses 101')), findsWidgets);
      expect(_k('milestone-2026-10-17-c1'), findsOneWidget);
      expect(find.text('Xong khóa English Tenses 101'), findsOneWidget);
      // review: Chủ nhật không có kế hoạch
      expect(find.text('Ôn tập tuần'), findsOneWidget);
      // thanh tiến độ: past/today (4 ngày có mục tiêu), không có ở ngày dự kiến
      expect(find.descendant(of: _k('day-2026-10-16'), matching: find.byType(ProgressBar)), findsNothing);
      expect(find.descendant(of: _k('day-2026-10-14'), matching: find.byType(ProgressBar)), findsOneWidget);
      // tổng kết
      expect(find.text('Tuần này: đã học 2h · dự kiến thêm 1h 20p'), findsOneWidget);
      expect(find.textContaining('học vượt thì lịch tự dời lên'), findsOneWidget);
    });

    testWidgets('banner so với kế hoạch gốc: sớm / đúng / trễ / ẩn', (tester) async {
      Future<void> check(int? delta, String? text, {bool hide = false}) async {
        final week = _sched('schedule_week', (j) {
          final list = ((j['summary'] as Map)['vsBaseline'] as List).cast<Map<String, dynamic>>();
          if (hide) {
            (j['summary'] as Map)['vsBaseline'] = <dynamic>[];
          } else {
            list.first['deltaDays'] = delta;
          }
        });
        await _pump(tester, _api(week: week), _weekUrl);
        if (text == null) {
          expect(_k('baseline-banner'), findsNothing);
        } else {
          expect(find.descendant(of: _k('baseline-banner'), matching: find.text(text)), findsOneWidget);
          expect(find.text('Mỗi ngày vẫn cần đủ 60 phút.'), findsOneWidget);
        }
      }

      await check(-2, 'Đang sớm 2 ngày so với kế hoạch gốc');
      await check(0, 'Đúng kế hoạch');
      await check(3, 'Đang trễ 3 ngày so với kế hoạch gốc');
      await check(null, null); // khóa ACTIVE chưa có mốc
      await check(0, null, hide: true); // không có khóa nào
    });

    testWidgets('banner: màu ngọc khi sớm, màu cảnh báo khi trễ', (tester) async {
      Color bannerColor() => ((tester.widget<Container>(_k('baseline-banner')).decoration as BoxDecoration).border! as Border).top.color;
      final late = _sched('schedule_week', (j) => (((j['summary'] as Map)['vsBaseline']) as List).first['deltaDays'] = 2);
      await _pump(tester, _api(week: late), _weekUrl);
      final lateColor = bannerColor();
      final early = _sched('schedule_week', (j) => (((j['summary'] as Map)['vsBaseline']) as List).first['deltaDays'] = -2);
      await _pump(tester, _api(week: early), _weekUrl);
      expect(bannerColor(), isNot(lateColor));
    });

    testWidgets('link "So với kế hoạch gốc" → bottom sheet liệt kê từng khóa', (tester) async {
      await _pump(tester, _api(), _weekUrl);
      await tester.tap(_k('baseline-link'));
      await tester.pumpAndSettle();
      final entries = _sched('schedule_week').summary.vsBaseline;
      for (final e in entries) {
        expect(_k('baseline-${e.courseId}'), findsOneWidget);
        expect(find.text(e.courseTitle), findsWidgets);
      }
      expect(find.textContaining('Gốc 22/10 · Dự kiến 22/10'), findsOneWidget);
      expect(find.text('đúng kế hoạch'), findsNWidgets(2));
    });

    testWidgets('"Thiếu lý do" mở sheet lý do của đúng ngày đó', (tester) async {
      await _pump(tester, _api(), _weekUrl);
      await tester.tap(_k('missing-reason-2026-10-12'));
      await tester.pumpAndSettle();
      expect(find.text('12/10 · đã học 0/60 phút'), findsOneWidget);
      expect(find.text('Tiếng Anh · ngày 1/1'), findsOneWidget, reason: 'chỉ ngày đó');
    });

    testWidgets('bấm hôm nay mở sheet ghi buổi học; ngày khác không mở', (tester) async {
      await _pump(tester, _api(), _weekUrl);
      await tester.tap(_k('day-2026-10-14'));
      await tester.pumpAndSettle();
      expect(find.textContaining('Chỉ ghi cho hôm nay.'), findsNothing);
      await tester.tap(_k('day-2026-10-15'));
      await tester.pumpAndSettle();
      expect(find.textContaining('Chỉ ghi cho hôm nay.'), findsOneWidget);
    });

    testWidgets('hôm nay chưa có buổi: hiện gợi ý từ plannedItems', (tester) async {
      final week = _sched('schedule_week', (j) {
        final d = _day(j, '2026-10-15');
        d['logs'] = <dynamic>[];
        d['minutes'] = 0;
        d['plannedItems'] = [{'courseId': 'c1', 'courseTitle': 'English Tenses 101', 'sectionId': 's1', 'title': 'Past Tenses', 'minutes': 40}];
      });
      await _pump(tester, _api(week: week), _weekUrl);
      expect(find.text('Gợi ý: English Tenses 101: Past Tenses · 40p'), findsOneWidget);
      expect(find.text('Còn 1h'), findsOneWidget);
    });

    testWidgets('tuần trước / sau / Hôm nay đổi from-to đúng và lưu trên URL', (tester) async {
      final api = _api();
      await _pump(tester, api, _weekUrl);
      expect(api.scheduleCalls.last, (subjectId: api.subjects.first.id, from: '2026-10-12', to: '2026-10-18'));

      await tester.tap(_k('nav-next'));
      await tester.pumpAndSettle();
      expect(api.scheduleCalls.last.from, '2026-10-19');
      expect(api.scheduleCalls.last.to, '2026-10-25');
      expect(_router.state.uri.toString(), '/tra-dinh?tab=schedule&view=week&date=2026-10-22');
      expect(find.text('19/10 – 25/10'), findsOneWidget);

      await tester.tap(_k('nav-prev'));
      await tester.pumpAndSettle();
      await tester.tap(_k('nav-prev'));
      await tester.pumpAndSettle();
      expect(api.scheduleCalls.last.from, '2026-10-05');
      expect(api.scheduleCalls.last.to, '2026-10-11');

      await tester.tap(_k('nav-today'));
      await tester.pumpAndSettle();
      expect(_router.state.uri.queryParameters['date'], vnToday());
    });

    testWidgets('URL không có view/date → tuần chứa hôm nay; date sai bị bỏ qua', (tester) async {
      final api = _api();
      await _pump(tester, api, '/tra-dinh?tab=schedule&date=2026-02-30');
      final t = vnToday();
      expect(api.scheduleCalls.last.from.compareTo(t) <= 0 && api.scheduleCalls.last.to.compareTo(t) >= 0, isTrue);
    });

    testWidgets('chuyển Tuần ↔ Tháng giữ mốc ngày, URL phản ánh', (tester) async {
      final api = _api();
      await _pump(tester, api, _weekUrl);
      await tester.tap(_k('view-month'));
      await tester.pumpAndSettle();
      expect(_router.state.uri.toString(), '/tra-dinh?tab=schedule&view=month&date=2026-10-15');
      expect((api.scheduleCalls.last.from, api.scheduleCalls.last.to), ('2026-09-28', '2026-11-01'));
      await tester.tap(_k('view-week'));
      await tester.pumpAndSettle();
      expect(_router.state.uri.queryParameters['view'], 'week');
    });

    testWidgets('môn không mục tiêu: bỏ thanh tiến độ, chỉ hiện phút', (tester) async {
      await _pump(tester, _api(week: _sched('schedule_no_goal')), _weekUrl);
      expect(find.byType(ProgressBar), findsNothing);
      expect(tester.widget<Text>(_k('day-minutes-2026-10-14')).data, '25p');
      expect(find.text('Dự kiến'), findsWidgets);
      expect(find.textContaining('Thiếu lý do'), findsNothing);
      expect(find.textContaining('Mỗi ngày vẫn cần đủ'), findsNothing);
    });

    testWidgets('môn chưa có khóa: ngày đã qua vẫn hiện, phần dự kiến ghi "Chưa có khóa để xếp lịch" + nút thêm khóa', (tester) async {
      final week = _sched('schedule_week', (j) {
        for (final d in (j['days'] as List).cast<Map<String, dynamic>>()) {
          if (d['kind'] == 'planned') d['plannedItems'] = <dynamic>[];
        }
        (j['summary'] as Map)['vsBaseline'] = <dynamic>[];
        (j['summary'] as Map)['plannedMinutes'] = 0;
      });
      final api = _api(week: week)..courses = [];
      await _pump(tester, api, _weekUrl);
      expect(find.text('Chưa có khóa để xếp lịch'), findsNWidgets(2), reason: '16/10 và 17/10; 18/10 là ngày ôn');
      expect(_k('no-course-hint'), findsOneWidget);
      expect(find.text('Dừng sớm: Bận'), findsOneWidget, reason: 'ngày đã qua vẫn hiện');
      await tester.ensureVisible(_k('schedule-add-course'));
      await tester.tap(_k('schedule-add-course'));
      await tester.pumpAndSettle();
      expect(find.text('Thêm khóa học'), findsOneWidget);
    });

    testWidgets('đang tải → khung chờ; lỗi → nút thử lại', (tester) async {
      final api = _api();
      final gate = Completer<void>();
      api.scheduleGate = gate;
      await _pump(tester, api, _weekUrl, settle: false);
      await tester.pump();
      expect(_k('schedule-skeleton'), findsOneWidget);
      gate.complete();
      await tester.pumpAndSettle();
      expect(_k('schedule-skeleton'), findsNothing);

      api
        ..scheduleGate = null
        ..scheduleError = apiError(500, {'error': 'x'});
      await tester.tap(_k('nav-next'));
      await tester.pumpAndSettle();
      expect(find.textContaining('Không tải được lịch học'), findsOneWidget);
      api.scheduleError = null;
      await tester.tap(find.text('Thử lại'));
      await tester.pumpAndSettle();
      expect(find.textContaining('Không tải được lịch học'), findsNothing);
    });
  });

  group('xem tháng', () {
    testWidgets('tháng 10/2026 bắt đầu thứ Năm: 3 ô mờ đầu lưới, 1 ô mờ cuối, 5 hàng', (tester) async {
      await _pump(tester, _api(), _monthUrl);
      expect(find.text('Tháng 10/2026'), findsOneWidget);
      for (final d in ['2026-09-28', '2026-09-29', '2026-09-30', '2026-11-01']) {
        expect(_k('dim-$d'), findsOneWidget, reason: d);
      }
      expect(_k('dim-2026-10-01'), findsNothing);
      expect(_k('dim-2026-10-31'), findsNothing);
      expect(find.byKey(const ValueKey('month-grid')).evaluate().length, 1);
      expect(find.descendant(of: _k('month-grid'), matching: find.byType(InkWell)).evaluate().length, 35);
      // ngày 1/10 nằm đúng cột T5
      final t5 = tester.getCenter(find.text('T5'));
      final cell = tester.getRect(_k('cell-2026-10-01'));
      expect(cell.left < t5.dx && t5.dx < cell.right, isTrue);
      final t2 = tester.getCenter(find.text('T2'));
      expect(tester.getRect(_k('cell-2026-09-28')).left < t2.dx && t2.dx < tester.getRect(_k('cell-2026-09-28')).right, isTrue);
    });

    testWidgets('lưới 42 ngày (tháng 11/2026): 6 hàng, 6 ô mờ đầu và 6 ô mờ cuối', (tester) async {
      await _pump(tester, _api(), '/tra-dinh?tab=schedule&view=month&date=2026-11-10');
      expect(find.descendant(of: _k('month-grid'), matching: find.byType(InkWell)).evaluate().length, 42);
      expect(find.byWidgetPredicate((w) => w is Opacity && w.key.toString().contains('dim-')).evaluate().length, 12);
    });

    testWidgets('ô chưa đủ có ký hiệu và nhãn Semantics đọc được; ô đủ không có ký hiệu', (tester) async {
      final handle = tester.ensureSemantics();
      await _pump(tester, _api(), _monthUrl);
      expect(_k('short-2026-10-13'), findsOneWidget);
      expect(_k('short-2026-10-14'), findsNothing);
      expect(find.bySemanticsLabel('13 tháng 10, 30 trên 60 phút, chưa đủ'), findsOneWidget);
      expect(find.bySemanticsLabel('14 tháng 10, 70 trên 60 phút, đủ mục tiêu'), findsOneWidget);
      expect(find.bySemanticsLabel(RegExp('^16 tháng 10, dự kiến 60 phút')), findsOneWidget);
      expect(find.bySemanticsLabel(RegExp('^15 tháng 10, 20 trên 60 phút, chưa đủ, hôm nay')), findsOneWidget);
      handle.dispose();
    });

    testWidgets('chấm ngọc ở ngày xong khóa, ký hiệu "ôn" ở Chủ nhật, chú thích dưới lưới', (tester) async {
      await _pump(tester, _api(), _monthUrl);
      expect(_k('dot-2026-10-22'), findsOneWidget);
      expect(_k('dot-2026-10-29'), findsOneWidget);
      expect(_k('rev-2026-10-18'), findsOneWidget);
      expect(_k('rev-2026-10-19'), findsNothing);
      expect(_k('month-legend'), findsOneWidget);
      for (final t in ['Đủ mục tiêu', 'Chưa đủ', 'Chưa học', 'Dự kiến', 'Hôm nay', 'Xong khóa', 'Ngày ôn tập']) {
        expect(find.descendant(of: _k('month-legend'), matching: find.text(t)), findsOneWidget, reason: t);
      }
    });

    testWidgets('bấm ô → bottom sheet chi tiết ngày (cùng widget dòng ngày)', (tester) async {
      await _pump(tester, _api(), _monthUrl);
      await tester.tap(_k('cell-2026-10-13'));
      await tester.pumpAndSettle();
      expect(find.text('Ngày 13/10'), findsOneWidget);
      expect(_k('day-2026-10-13'), findsOneWidget);
      expect(find.text('Dừng sớm: Bận'), findsOneWidget);
    });

    testWidgets('thẻ tóm tắt: đã học, dự kiến tới hết tháng, mốc xong khóa', (tester) async {
      final oct = _sched('schedule_month_oct');
      final inOct = oct.days.where((d) => d.date.startsWith('2026-10'));
      final learned = inOct.where((d) => d.hasActual).fold<int>(0, (n, d) => n + d.actualMinutes);
      final planned = inOct.fold<int>(0, (n, d) => n + d.plannedMinutes);
      String fmt(int m) => m >= 60 ? (m % 60 == 0 ? '${m ~/ 60}h' : '${m ~/ 60}h ${m % 60}p') : '${m}p';
      await _pump(tester, _api(oct: oct), _monthUrl);
      expect(find.text('Đã học: ${fmt(learned)}'), findsOneWidget);
      expect(find.text('Dự kiến tới hết tháng: ${fmt(learned + planned)}'), findsOneWidget);
      expect(planned, greaterThan(0));
      expect(_k('month-milestone-2026-10-22'), findsOneWidget);
      expect(_k('month-milestone-2026-10-29'), findsOneWidget);
      expect(find.textContaining('Dự kiến xong English Tenses 101'), findsOneWidget);
    });

    testWidgets('tháng trước / sau chuyển sang lưới tháng khác', (tester) async {
      final api = _api();
      await _pump(tester, api, _monthUrl);
      await tester.tap(_k('nav-next'));
      await tester.pumpAndSettle();
      expect(api.scheduleCalls.last.from, '2026-10-26');
      expect(api.scheduleCalls.last.to, '2026-12-06');
      expect(find.text('Tháng 11/2026'), findsOneWidget);
      expect(_router.state.uri.queryParameters['date'], '2026-11-01');
    });

    testWidgets('môn không mục tiêu: ô tháng không có ký hiệu "chưa đủ", nhãn chỉ có phút', (tester) async {
      final handle = tester.ensureSemantics();
      final oct = _sched('schedule_month_oct', (j) {
        for (final d in (j['days'] as List).cast<Map<String, dynamic>>()) {
          d['goalMinutes'] = null;
          if (d['kind'] != 'planned') d['done'] = false;
        }
      });
      await _pump(tester, _api(oct: oct), _monthUrl);
      expect(_k('short-2026-10-13'), findsNothing);
      expect(find.bySemanticsLabel('13 tháng 10, 30 phút'), findsOneWidget);
      handle.dispose();
    });
  });
}

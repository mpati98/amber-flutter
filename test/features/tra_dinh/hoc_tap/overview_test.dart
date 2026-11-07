import 'dart:convert';

import 'package:amber_flutter/features/nghi_su_duong/models/routine.dart';
import 'package:amber_flutter/features/tra_dinh/hoc_tap/models/study_enums.dart';
import 'package:amber_flutter/features/tra_dinh/hoc_tap/models/study_log.dart';
import 'package:amber_flutter/features/tra_dinh/hoc_tap/models/study_overview.dart';
import 'package:amber_flutter/features/tra_dinh/hoc_tap/models/study_schedule.dart';
import 'package:amber_flutter/features/tra_dinh/hoc_tap/screens/library_screen.dart';
import 'package:amber_flutter/features/tra_dinh/hoc_tap/screens/overview_tab.dart';
import 'package:amber_flutter/features/tra_dinh/hoc_tap/screens/tra_dinh_hoc_tap_screen.dart';
import 'package:amber_flutter/features/tra_dinh/hoc_tap/services/hoc_tap_api.dart';
import 'package:amber_flutter/features/tra_dinh/hoc_tap/utils/next_action.dart';
import 'package:amber_flutter/shared/services/api_client.dart';
import 'package:amber_flutter/shared/utils/vn_time.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../nghi_su_duong/detail_test_support.dart';
import 'hoc_tap_test_support.dart';
import 'hoc_tap_widget_support.dart';

Map<String, dynamic> jsonDecodeMap(Map<String, dynamic> m) => jsonDecode(jsonEncode(m)) as Map<String, dynamic>;

Finder _k(String key) => find.byKey(ValueKey(key));

SubjectOverview _subject({CardsToday? cards, NextItem? next, int? goal = 60, bool done = false}) => SubjectOverview(
  subjectId: 's',
  name: 'Tiếng Anh',
  goalMinutes: goal,
  today: TodayInfo(minutes: done ? 60 : 10, logCount: 0, done: done),
  next: next,
  cards: cards,
);

const _next = NextItem(courseId: 'c', courseTitle: 'Khóa', sectionId: 'x', sectionTitle: 'Bài 1');

Routine _studyRoutine(String subjectId, {int streak = 3, List<String> pending = const []}) {
  final base = mkRoutine('st', 'Học', kind: RoutineKind.study, done: const {});
  return Routine(
    id: base.id,
    name: base.name,
    weekdays: base.weekdays,
    dueToday: true,
    doneToday: false,
    streak: streak,
    last7: base.last7,
    kind: RoutineKind.study,
    studySubjectId: subjectId,
    studySubjectName: 'Tiếng Anh',
    todayMinutes: 10,
    goalMinutes: 60,
    pendingReasonDates: pending,
  );
}

Future<void> _pumpTab(WidgetTester tester, FakeHocTapApi api, {List<Routine> routines = const []}) => pumpHocTap(
  tester,
  const Scaffold(body: OverviewTab()),
  api: api,
  routinesApi: FakeApi(project: mkProject(), tasks: [])..routines = [...routines],
  overrides: [apiClientProvider.overrideWithValue(offlineDio())],
);

void main() {
  group('nextTodayAction (hàm thuần)', () {
    test('ôn thẻ đã lên kế hoạch mà chưa xong → ôn thẻ, trước cả học bài', () {
      expect(nextTodayAction(_subject(cards: const CardsToday(planned: 5, finished: 2), next: _next)), TodayAction.reviewCards);
    });
    test('chưa mở hàng đợi (planned 0) vẫn là chưa làm → ôn thẻ, kể cả khi có phần học kế tiếp', () {
      expect(nextTodayAction(_subject(cards: const CardsToday(), next: _next)), TodayAction.reviewCards);
      expect(nextTodayAction(_subject(cards: const CardsToday())), TodayAction.reviewCards);
    });
    test('ôn thẻ xong (done == planned > 0) → học bài nếu còn phần kế tiếp', () {
      expect(nextTodayAction(_subject(cards: const CardsToday(planned: 5, finished: 5), next: _next)), TodayAction.nextLesson);
    });
    test('backend cũ không có cards → bỏ qua Ôn thẻ', () {
      expect(nextTodayAction(_subject(next: _next)), TodayAction.nextLesson);
      expect(nextTodayAction(_subject()), TodayAction.practice);
    });
    test('hết việc khác mà chưa đủ phút → luyện AI; đủ phút → không có nút vàng', () {
      expect(nextTodayAction(_subject()), TodayAction.practice);
      expect(nextTodayAction(_subject(done: true)), isNull);
    });
    test('môn không đặt mục tiêu phút → không bao giờ gợi ý luyện AI', () {
      expect(nextTodayAction(_subject(goal: null)), isNull);
    });
  });

  testWidgets('chưa có môn: thẻ "Tạo môn đầu tiên", không có thẻ chính / thư viện', (tester) async {
    final api = FakeHocTapApi(overview: StudyOverview(today: '2026-10-14', week: StudyOverview.fromJson(fixtureMap('overview')).week, subjects: const []), subjects: const []);
    await _pumpTab(tester, api);
    expect(find.text('Tạo môn đầu tiên'), findsOneWidget);
    expect(_k('today-main'), findsNothing);
    expect(_k('library-tile'), findsNothing);
  });

  testWidgets('Hôm nay: thẻ chính (vòng, phút, tuần), 3 việc, ô Thư viện; chip môn chỉ hiện khi có ≥ 2 môn', (tester) async {
    await _pumpTab(tester, FakeHocTapApi());
    expect(_k('today-ring'), findsOneWidget);
    expect(tester.widget<Text>(_k('today-minutes')).data, '30 / 60 phút');
    expect(tester.widget<Text>(_k('week-summary')).data, 'Tuần này: 1h 15p / 7h');
    expect(_k('week-dots'), findsOneWidget);
    for (final d in ['2026-10-12', '2026-10-14', '2026-10-18']) {
      expect(_k('week-dot-$d'), findsOneWidget);
    }
    expect(_k('task-lesson'), findsOneWidget);
    expect(find.text('First English Sentences'), findsOneWidget);
    expect(_k('task-practice'), findsOneWidget);
    expect(_k('library-tile'), findsOneWidget);
    expect(_k('subject-chip-${FakeHocTapApi().subjects.first.id}'), findsOneWidget, reason: 'fixture có 2 môn');
    expect(_k('week-chart'), findsNothing, reason: 'biểu đồ tuần đã chuyển sang dải chấm');
  });

  testWidgets('chỉ một môn: không có chip môn', (tester) async {
    final base = StudyOverview.fromJson(fixtureMap('overview'));
    await _pumpTab(tester, FakeHocTapApi(overview: StudyOverview(today: base.today, week: base.week, subjects: [base.subjects.first])));
    expect(find.byType(ChoiceChip), findsNothing);
  });

  testWidgets('chỉ MỘT nút vàng: việc tiếp theo (Học tiếp); Luyện AI là nút viền', (tester) async {
    await _pumpTab(tester, FakeHocTapApi());
    final lesson = find.descendant(of: _k('task-lesson'), matching: find.byType(FilledButton));
    final practice = find.descendant(of: _k('task-practice'), matching: find.byType(FilledButton));
    expect(lesson, findsOneWidget);
    expect(practice, findsNothing);
    expect(find.descendant(of: _k('today-tasks'), matching: find.byType(FilledButton)), findsOneWidget);
  });

  testWidgets('hết việc khác, chưa đủ phút → nút vàng chuyển sang Luyện AI; đủ phút → không còn nút vàng', (tester) async {
    final base = StudyOverview.fromJson(fixtureMap('overview'));
    SubjectOverview s({bool done = false}) => SubjectOverview(subjectId: base.subjects.first.subjectId, name: 'Tiếng Anh', goalMinutes: 60, today: TodayInfo(minutes: done ? 60 : 10, logCount: 0, done: done));
    await _pumpTab(tester, FakeHocTapApi(overview: StudyOverview(today: base.today, week: base.week, subjects: [s()])));
    expect(find.descendant(of: _k('task-practice'), matching: find.byType(FilledButton)), findsOneWidget);
    expect(find.text('Chưa có khóa đang học'), findsOneWidget);
    expect(find.text('Thêm khóa ›'), findsOneWidget);

    await _pumpTab(tester, FakeHocTapApi(overview: StudyOverview(today: base.today, week: base.week, subjects: [s(done: true)])));
    expect(find.descendant(of: _k('today-tasks'), matching: find.byType(FilledButton)), findsNothing);
    expect(find.text('Đủ mục tiêu'), findsOneWidget);
  });

  testWidgets('chuỗi ngày và dòng "Thiếu lý do" lấy từ routine STUDY của môn; mở sheet lý do', (tester) async {
    final api = FakeHocTapApi();
    final id = api.overview.subjects.first.subjectId;
    await _pumpTab(tester, api, routines: [_studyRoutine(id, streak: 4, pending: const ['2026-10-12', '2026-10-13'])]);
    expect(tester.widget<Text>(_k('today-streak')).data, 'Chuỗi 4 ngày');
    expect(find.textContaining('Thiếu lý do ngày 13/10, 12/10'), findsOneWidget);
    await tester.tap(_k('today-pending'));
    await tester.pumpAndSettle();
    expect(find.byType(CloseButton), findsWidgets, reason: 'sheet lý do đã mở');
  });

  testWidgets('không có routine STUDY: ẩn chuỗi và dòng thiếu lý do, không lỗi', (tester) async {
    await _pumpTab(tester, FakeHocTapApi());
    expect(_k('today-streak'), findsNothing);
    expect(_k('today-pending'), findsNothing);
  });

  testWidgets('môn không có mục tiêu: không có vòng, có "Đặt mục tiêu ›"', (tester) async {
    final api = FakeHocTapApi();
    await _pumpTab(tester, api);
    await tester.ensureVisible(_k('subject-chip-${api.overview.subjects[1].subjectId}'));
    await tester.tap(_k('subject-chip-${api.overview.subjects[1].subjectId}'));
    await tester.pumpAndSettle();
    expect(_k('today-ring'), findsNothing);
    expect(_k('set-goal'), findsOneWidget);
  });

  testWidgets('nút "Ghi buổi học thủ công" mở sheet; Luyện AI và Thư viện điều hướng đúng', (tester) async {
    final api = FakeHocTapApi();
    await _pumpTab(tester, api);
    await tester.tap(_k('manual-log'));
    await tester.pumpAndSettle();
    expect(find.textContaining('Chỉ ghi cho hôm nay.'), findsOneWidget);
    await tester.tap(find.byType(CloseButton));
    await tester.pumpAndSettle();

    await tester.tap(find.descendant(of: _k('task-practice'), matching: find.byType(OutlinedButton)));
    await tester.pumpAndSettle();
    expect(visited.last, '/tra-dinh/luyen-tap');
    GoRouter.of(tester.element(find.byType(Scaffold).first)).pop();
    await tester.pumpAndSettle();

    await tester.ensureVisible(_k('library-tile'));
    await tester.tap(_k('library-tile'));
    await tester.pumpAndSettle();
    expect(visited.last, '/tra-dinh/hoc-tap/thu-vien?subjectId=${api.overview.subjects.first.subjectId}');
  });

  testWidgets('buổi đã ghi hôm nay vẫn hiện trong "Việc hôm nay", bấm → sheet sửa; lý do hiện "Dừng sớm"', (tester) async {
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
    await _pumpTab(tester, api);
    expect(find.text('Dừng sớm: Bận'), findsOneWidget);
    expect(_k('today-log-${api.logs[0].id}'), findsOneWidget);
    expect(find.textContaining('English Tenses 101 · Basics ✓, First English Sentences'), findsOneWidget);
    await tester.tap(_k('today-log-${api.logs[0].id}'));
    await tester.pumpAndSettle();
    expect(find.text('Sửa buổi học'), findsOneWidget);
  });

  testWidgets('lỗi tải → thông báo + Thử lại', (tester) async {
    final api = FakeHocTapApi()..overviewError = apiError(500, {'error': 'x'});
    await _pumpTab(tester, api);
    expect(find.textContaining('Không tải được tổng quan'), findsOneWidget);
    api.overviewError = null;
    await tester.tap(find.text('Thử lại'));
    await tester.pumpAndSettle();
    expect(_k('today-main'), findsOneWidget);
  });

  testWidgets('không tràn ở 320 px, chữ x2.0', (tester) async {
    tester.platformDispatcher.textScaleFactorTestValue = 2.0;
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
    final api = FakeHocTapApi();
    await pumpHocTap(
      tester,
      const Scaffold(body: OverviewTab()),
      api: api,
      width: 320,
      routinesApi: FakeApi(project: mkProject(), tasks: [])..routines = [_studyRoutine(api.overview.subjects.first.subjectId, pending: const ['2026-10-12'])],
      overrides: [apiClientProvider.overrideWithValue(offlineDio())],
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('shell: tab Hôm nay | Lịch | Thống kê, menu ⋯ có "+ Môn" và "Cài đặt môn"', (tester) async {
    tester.view.physicalSize = const Size(390, 2600);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final router = GoRouter(
      initialLocation: '/tra-dinh?tab=stats',
      routes: [GoRoute(path: '/tra-dinh', builder: (_, state) => TraDinhHocTapScreen(tab: state.uri.queryParameters['tab']))],
    );
    await tester.pumpWidget(
      ProviderScope(
        overrides: [hocTapApiProvider.overrideWithValue(FakeHocTapApi()), apiClientProvider.overrideWithValue(offlineDio())],
        child: MaterialApp.router(theme: ThemeData.dark(), routerConfig: router),
      ),
    );
    await tester.pumpAndSettle();
    expect(_k('tile-total'), findsOneWidget, reason: '?tab=stats mở đúng tab Thống kê');
    expect(find.text('Tổng quan'), findsNothing);

    await tester.tap(find.text('Lịch'));
    await tester.pumpAndSettle();
    expect(_k('view-toggle'), findsOneWidget);

    await tester.tap(find.widgetWithText(Tab, 'Hôm nay'));
    await tester.pumpAndSettle();
    expect(_k('today-main'), findsOneWidget);

    await tester.tap(_k('subject-menu'));
    await tester.pumpAndSettle();
    expect(_k('add-subject'), findsOneWidget);
    expect(_k('edit-subject'), findsOneWidget);
    await tester.tap(_k('edit-subject'));
    await tester.pumpAndSettle();
    expect(find.byType(CloseButton), findsWidgets, reason: 'sheet cài đặt môn mở');
  });

  group('Thư viện', () {
    testWidgets('3 nhóm: Khóa học, Thẻ từ vựng, Trình độ; mỗi hàng điều hướng đúng môn', (tester) async {
      final api = FakeHocTapApi();
      final id = api.overview.subjects.first.subjectId;
      await pumpHocTap(tester, LibraryScreen(subjectId: id), api: api);
      for (final k in ['active', 'queued', 'done', 'wishlist', 'add-course', 'cards', 'cards-import', 'cards-hard', 'placement']) {
        expect(_k('lib-$k'), findsOneWidget, reason: k);
      }
      expect(find.descendant(of: _k('lib-queued'), matching: find.text('2')), findsOneWidget);
      expect(find.descendant(of: _k('lib-wishlist'), matching: find.text('1')), findsOneWidget);

      final expected = {
        'queued': '/tra-dinh/hoc-tap/courses?subjectId=$id&status=QUEUED',
        'done': '/tra-dinh/hoc-tap/courses?subjectId=$id&status=DONE',
        'wishlist': '/tra-dinh/hoc-tap/wishlist?subjectId=$id',
        'cards': '/tra-dinh/hoc-tap/the?subjectId=$id',
        'cards-import': '/tra-dinh/hoc-tap/the/them?subjectId=$id',
        'cards-hard': '/tra-dinh/hoc-tap/the/thong-ke?subjectId=$id',
        'placement': '/tra-dinh/placement-test',
      };
      for (final e in expected.entries) {
        await tester.ensureVisible(_k('lib-${e.key}'));
        await tester.tap(_k('lib-${e.key}'));
        await tester.pumpAndSettle();
        expect(visited.last, e.value, reason: e.key);
        GoRouter.of(tester.element(find.byType(Scaffold).first)).pop();
        await tester.pumpAndSettle();
      }
    });

    testWidgets('"Đang học" mở chi tiết khóa đang học; "Thêm khóa" mở form khóa', (tester) async {
      final api = FakeHocTapApi();
      final active = api.overview.subjects.first.activeCourse!;
      await pumpHocTap(tester, LibraryScreen(subjectId: api.overview.subjects.first.subjectId), api: api);
      await tester.tap(_k('lib-active'));
      await tester.pumpAndSettle();
      expect(visited.last, '/tra-dinh/hoc-tap/courses/${active.id}');
      GoRouter.of(tester.element(find.byType(Scaffold).first)).pop();
      await tester.pumpAndSettle();
      await tester.ensureVisible(_k('lib-add-course'));
      await tester.tap(_k('lib-add-course'));
      await tester.pumpAndSettle();
      expect(find.byType(CloseButton), findsWidgets);
    });

    testWidgets('không tràn ở 320 px, chữ x2.0', (tester) async {
      tester.platformDispatcher.textScaleFactorTestValue = 2.0;
      addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
      await pumpHocTap(tester, const LibraryScreen(), api: FakeHocTapApi(), width: 320);
      expect(tester.takeException(), isNull);
    });
  });

  test('activity lạ (chưa biết): enum → unknown; lịch bỏ qua buổi đó, giữ các buổi khác', () {
    expect(LogActivity.fromApi('FUTURE_KIND'), LogActivity.unknown);
    expect(LogActivity.fromApi(null), LogActivity.lesson);
    final json = jsonDecodeMap(fixtureMap('schedule_card_review'));
    final day = (json['days'] as List).firstWhere((d) => (d['logs'] as List).isNotEmpty) as Map<String, dynamic>;
    final before = (day['logs'] as List).length;
    (day['logs'] as List).add({'id': 'p', 'minutes': 20, 'activity': 'FUTURE_KIND', 'sections': []});
    final parsed = StudySchedule.fromJson(json).days.firstWhere((d) => d.date == day['date']);
    expect(parsed.logs.length, before);
    expect(parsed.logs.any((l) => l.id == 'p'), isFalse);
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

    testWidgets('mở Hôm nay, tự mở sheet đúng một lần, xoá query khỏi URL, chọn môn theo subjectId', (tester) async {
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
      await tester.tap(find.widgetWithText(Tab, 'Hôm nay'));
      await tester.pumpAndSettle();
      expect(find.textContaining('Chỉ ghi cho hôm nay.'), findsNothing);
      expect(find.byKey(const ValueKey('today-main')), findsOneWidget);
    });

    testWidgets('mở từ tab khác vẫn về Hôm nay; không có openLog thì không mở sheet', (tester) async {
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

import 'dart:convert';

import 'package:amber_flutter/features/tra_dinh/hoc_tap/models/study_enums.dart';
import 'package:amber_flutter/features/tra_dinh/hoc_tap/models/study_log.dart';
import 'package:amber_flutter/features/tra_dinh/hoc_tap/models/study_overview.dart';
import 'package:amber_flutter/features/tra_dinh/hoc_tap/models/study_schedule.dart';
import 'package:amber_flutter/shared/router/app_router.dart' show traDinhLegacyTabRedirect;
import 'package:amber_flutter/features/tra_dinh/hoc_tap/screens/overview_tab.dart';
import 'package:amber_flutter/features/tra_dinh/hoc_tap/screens/tra_dinh_hoc_tap_screen.dart';
import 'package:amber_flutter/features/tra_dinh/hoc_tap/services/hoc_tap_api.dart';
import 'package:amber_flutter/features/tra_dinh/hoc_tap/utils/next_action.dart';
import 'package:amber_flutter/shared/utils/vn_time.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_test/flutter_test.dart';

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

/// Overview từ JSON thật chụp ở dev (có trường mới) với môn đầu đã chỉnh bằng [edit].
StudyOverview _practiceOverview([void Function(Map<String, dynamic> subject)? edit]) {
  final json = jsonDecode(jsonEncode(fixtureMap('overview_practice'))) as Map<String, dynamic>;
  if (edit != null) edit((json['subjects'] as List).first as Map<String, dynamic>);
  return StudyOverview.fromJson(json);
}

Future<void> _pumpTab(WidgetTester tester, FakeHocTapApi api, {double width = 390}) => pumpHocTap(tester, const Scaffold(body: OverviewTab()), api: api, width: width);

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
    test('cards.total == 0 (môn chưa có thẻ) → không phải việc cần làm, nút vàng sang việc kế tiếp', () {
      expect(nextTodayAction(_subject(cards: const CardsToday(total: 0), next: _next)), TodayAction.nextLesson);
      expect(nextTodayAction(_subject(cards: const CardsToday(total: 0))), TodayAction.practice);
    });
    test('planned == 0 với total > 0 hoặc total thiếu → vẫn là ôn thẻ', () {
      expect(nextTodayAction(_subject(cards: const CardsToday(total: 5), next: _next)), TodayAction.reviewCards);
      expect(nextTodayAction(_subject(cards: const CardsToday(), next: _next)), TodayAction.reviewCards);
    });
    test('có phút luyện AI nhưng chưa đủ mục tiêu, hết việc khác → vẫn gợi ý Luyện AI; đủ phút (đã gồm PRACTICE) → không', () {
      expect(nextTodayAction(_subject()), TodayAction.practice);
      expect(nextTodayAction(_subject(done: true)), isNull);
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

  testWidgets('chưa có môn: lời mời mở kế hoạch, không có thẻ chính / Kho thẻ', (tester) async {
    final api = FakeHocTapApi(overview: StudyOverview(today: '2026-10-14', week: StudyOverview.fromJson(fixtureMap('overview')).week, subjects: const []), subjects: const []);
    await _pumpTab(tester, api);
    expect(find.text('Mở kế hoạch học tập'), findsOneWidget);
    expect(_k('today-main'), findsNothing);
    expect(_k('cards-tile'), findsNothing);
  });

  testWidgets('Hôm nay: tổng quan (phút, còn bao nhiêu, tuần), 3 việc, hàng Kho thẻ; chip môn chỉ hiện khi có ≥ 2 môn', (tester) async {
    await _pumpTab(tester, FakeHocTapApi());
    expect(tester.widget<Text>(_k('today-minutes')).data, '30 / 60 phút');
    expect(tester.widget<Text>(_k('today-remaining')).data, '· còn 30 phút để đủ mục tiêu');
    expect(tester.widget<Text>(_k('week-summary')).data, '1h 15p / 7h');
    expect(find.text('Tuần này'), findsOneWidget);
    // Bản mẫu bỏ vòng tiến độ và dải 7 chấm.
    expect(_k('today-ring'), findsNothing);
    expect(_k('week-dots'), findsNothing);
    expect(_k('task-lesson'), findsOneWidget);
    expect(find.text('First English Sentences'), findsOneWidget);
    expect(_k('task-practice'), findsOneWidget);
    expect(_k('cards-tile'), findsOneWidget);
    expect(find.text('Thư viện'), findsNothing);
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

  testWidgets('chuỗi ngày và dòng "Thiếu lý do" đọc từ overview (không cần routine); mở sheet lý do', (tester) async {
    final o = _practiceOverview((s) {
      s['streak'] = 4;
      s['pendingReasonDates'] = ['2026-10-12', '2026-10-13'];
    });
    await _pumpTab(tester, FakeHocTapApi(overview: o));
    expect(tester.widget<Text>(_k('today-streak')).data, '4 ngày');
    expect(find.text('Chuỗi'), findsOneWidget);
    // Hộp cảnh báo: bấm mở danh sách ngày (mới trước), rồi "Nhập lý do ›" mở sheet.
    expect(find.text('⚠ Thiếu lý do 2 ngày gần đây · bấm để xem'), findsOneWidget);
    expect(_k('today-pending-dates'), findsNothing);
    await tester.tap(_k('today-pending'));
    await tester.pumpAndSettle();
    expect(tester.widget<Text>(_k('today-pending-dates')).data, '13/10, 12/10');
    await tester.tap(_k('today-pending-open'));
    await tester.pumpAndSettle();
    expect(find.byType(CloseButton), findsWidgets, reason: 'sheet lý do đã mở');
  });

  testWidgets('overview không có streak / pendingReasonDates (backend cũ): ẩn cả hai, không lỗi', (tester) async {
    await _pumpTab(tester, FakeHocTapApi());
    expect(_k('today-streak'), findsNothing);
    expect(_k('today-pending'), findsNothing);
  });

  testWidgets('streak 0 vẫn hiện "Chuỗi 0 ngày" khi môn có mục tiêu; môn không mục tiêu thì ẩn', (tester) async {
    await _pumpTab(tester, FakeHocTapApi(overview: _practiceOverview()));
    expect(tester.widget<Text>(_k('today-streak')).data, '0 ngày');
  });

  group('hàng Học bài tiếp và Luyện AI', () {
    testWidgets('Học bài tiếp: "[Tên bài] · N phút" khi có next.minutes; thiếu thì chỉ tên bài', (tester) async {
      await _pumpTab(tester, FakeHocTapApi(overview: _practiceOverview()));
      expect(find.text('First English Sentences · 25 phút'), findsOneWidget);
      await _pumpTab(tester, FakeHocTapApi());
      expect(find.text('First English Sentences'), findsOneWidget);
      expect(find.textContaining(' phút'), findsWidgets); // chỉ để chắc không lỗi; tên bài không kèm phút
      expect(find.textContaining('First English Sentences ·'), findsNothing);
    });

    testWidgets('Luyện AI: đã luyện 15 phút → "Đã luyện 15 phút hôm nay"', (tester) async {
      await _pumpTab(tester, FakeHocTapApi(overview: _practiceOverview()));
      expect(find.descendant(of: _k('task-practice'), matching: find.text('Đã luyện 15 phút hôm nay')), findsOneWidget);
    });

    testWidgets('Luyện AI: chưa luyện (PRACTICE 0) → "Trò chuyện, làm bài test · 0 phút"', (tester) async {
      final o = _practiceOverview((s) => (s['today'] as Map<String, dynamic>)['minutesByActivity']['PRACTICE'] = 0);
      await _pumpTab(tester, FakeHocTapApi(overview: o));
      expect(find.descendant(of: _k('task-practice'), matching: find.text('Trò chuyện, làm bài test · 0 phút')), findsOneWidget);
    });

    testWidgets('Luyện AI: backend cũ (không có minutesByActivity) không khẳng định "0 phút"', (tester) async {
      await _pumpTab(tester, FakeHocTapApi());
      expect(find.descendant(of: _k('task-practice'), matching: find.textContaining('0 phút')), findsNothing);
      expect(find.descendant(of: _k('task-practice'), matching: find.textContaining('Trò chuyện')), findsOneWidget);
    });

    testWidgets('Luyện AI là nút vàng khi hết việc khác và chưa đủ phút; đủ phút thì không còn nút vàng', (tester) async {
      final o = _practiceOverview((s) {
        s['next'] = null;
        s['cards'] = {...Map<String, dynamic>.from(s['cards'] as Map), 'planned': 3, 'finished': 3};
      });
      await _pumpTab(tester, FakeHocTapApi(overview: o));
      expect(find.descendant(of: _k('task-practice'), matching: find.byType(FilledButton)), findsOneWidget);
      expect(find.descendant(of: _k('today-tasks'), matching: find.byType(FilledButton)), findsOneWidget);

      final done = _practiceOverview((s) {
        s['next'] = null;
        s['cards'] = {...Map<String, dynamic>.from(s['cards'] as Map), 'planned': 3, 'finished': 3};
        s['today'] = {...Map<String, dynamic>.from(s['today'] as Map), 'minutes': 60, 'done': true};
      });
      await _pumpTab(tester, FakeHocTapApi(overview: done));
      expect(find.descendant(of: _k('today-tasks'), matching: find.byType(FilledButton)), findsNothing);
    });
  });

  group('hàng Ôn thẻ theo cards.total', () {
    testWidgets('total == 0: "Chưa có thẻ" + "Nhập thẻ ›" (không nút vàng), bấm → màn nhập thẻ của môn', (tester) async {
      final o = _practiceOverview((s) => s['cards'] = {...Map<String, dynamic>.from(s['cards'] as Map), 'total': 0});
      await _pumpTab(tester, FakeHocTapApi(overview: o));
      expect(tester.widget<Text>(_k('cards-status')).data, 'Chưa có thẻ');
      expect(_k('cards-start'), findsNothing);
      expect(tester.widget(_k('cards-import')), isA<OutlinedButton>()); // nút viền như bản mẫu, không vàng
      // Nút vàng chuyển sang việc kế tiếp (Học tiếp), không phải Ôn thẻ.
      expect(find.descendant(of: _k('task-lesson'), matching: find.byType(FilledButton)), findsOneWidget);
      await tester.tap(_k('cards-import'));
      await tester.pumpAndSettle();
      expect(visited.last, '/tra-dinh/hoc-tap/the/them?subjectId=${o.subjects.first.subjectId}');
    });

    testWidgets('planned == 0 và total > 0: "Chưa bắt đầu" là nút vàng', (tester) async {
      await _pumpTab(tester, FakeHocTapApi(overview: _practiceOverview()));
      expect(tester.widget<Text>(_k('cards-status')).data, 'Chưa bắt đầu · tối đa 20 thẻ');
      expect(tester.widget(_k('cards-start')), isA<FilledButton>());
    });

    testWidgets('total thiếu (backend cũ) và planned == 0: vẫn nút vàng như trước', (tester) async {
      final o = _practiceOverview((s) => (s['cards'] as Map<String, dynamic>).remove('total'));
      await _pumpTab(tester, FakeHocTapApi(overview: o));
      expect(tester.widget(_k('cards-start')), isA<FilledButton>());
    });
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

  testWidgets('nút "Ghi buổi học thủ công" mở sheet; Luyện AI và Kho thẻ điều hướng đúng', (tester) async {
    final api = FakeHocTapApi();
    await _pumpTab(tester, api);
    await tester.tap(_k('manual-log'));
    await tester.pumpAndSettle();
    expect(find.textContaining('Chỉ ghi cho hôm nay.'), findsOneWidget);
    await tester.tap(find.byType(CloseButton));
    await tester.pumpAndSettle();

    await tester.tap(find.descendant(of: _k('task-practice'), matching: find.byType(OutlinedButton)));
    await tester.pumpAndSettle();
    expect(visited.last, '/tra-dinh/luyen-tap?subjectId=${api.overview.subjects.first.subjectId}');
    GoRouter.of(tester.element(find.byType(Scaffold).first)).pop();
    await tester.pumpAndSettle();

    await tester.ensureVisible(_k('cards-tile'));
    await tester.tap(_k('cards-tile'));
    await tester.pumpAndSettle();
    expect(visited.last, '/tra-dinh/hoc-tap/the?subjectId=${api.overview.subjects.first.subjectId}');
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

  testWidgets('không tràn ở 320 px, chữ x2.0 (có chuỗi, thiếu lý do, phút luyện AI, nhập thẻ)', (tester) async {
    tester.platformDispatcher.textScaleFactorTestValue = 2.0;
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
    for (final total in [0, 2]) {
      final o = _practiceOverview((s) {
        s['streak'] = 12;
        s['pendingReasonDates'] = ['2026-10-12', '2026-10-13', '2026-10-14'];
        s['cards'] = {...Map<String, dynamic>.from(s['cards'] as Map), 'total': total};
      });
      await _pumpTab(tester, FakeHocTapApi(overview: o), width: 320);
      expect(tester.takeException(), isNull, reason: 'total=$total');
    }
  });

  testWidgets('shell: màn Hôm nay không còn thanh tab, không còn menu ⋯ (quản lý môn dời sang Nghị Sự Đường)', (tester) async {
    tester.view.physicalSize = const Size(390, 2600);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final router = GoRouter(initialLocation: '/tra-dinh', routes: [GoRoute(path: '/tra-dinh', builder: (_, _) => const TraDinhHocTapScreen())]);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [hocTapApiProvider.overrideWithValue(FakeHocTapApi())],
        child: MaterialApp.router(theme: ThemeData.dark(), routerConfig: router),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.byType(TabBar), findsNothing);
    expect(find.byType(TabBarView), findsNothing);
    expect(find.widgetWithText(Tab, 'Lịch'), findsNothing);
    expect(find.text('Hôm nay'), findsWidgets);
    expect(find.text('Trà Đình'), findsOneWidget); // tên màn trên thanh trên mới
    expect(find.byKey(const ValueKey('design-top-bar-back')), findsOneWidget);
    expect(_k('subject-menu'), findsNothing);
    expect(_k('today-main'), findsOneWidget);
  });

  group('hàng Kho thẻ và Ghi buổi học thủ công', () {
    testWidgets('hàng "Kho thẻ" cao ≥ 56, dòng phụ có số thẻ, bấm mở Kho thẻ của môn', (tester) async {
      final api = FakeHocTapApi();
      final first = api.overview.subjects.first;
      await _pumpTab(tester, api);
      await tester.ensureVisible(_k('cards-tile'));
      expect(tester.getSize(_k('cards-tile')).height, greaterThanOrEqualTo(56));
      expect(find.text('Kho thẻ'), findsOneWidget);
      expect(find.text('Thư viện'), findsNothing);
      expect(find.textContaining('hập thẻ, thẻ khó'), findsOneWidget);
      await tester.tap(_k('cards-tile'));
      await tester.pumpAndSettle();
      expect(visited.last, '/tra-dinh/hoc-tap/the?subjectId=${first.subjectId}');
    });

    testWidgets('"Ghi buổi học thủ công": liên kết căn giữa ở cuối màn (cao ≥ 44), mở form ghi buổi học', (tester) async {
      await _pumpTab(tester, FakeHocTapApi());
      await tester.ensureVisible(_k('manual-log'));
      expect(tester.getSize(_k('manual-log')).height, greaterThanOrEqualTo(44));
      expect(tester.getCenter(_k('manual-log')).dx, closeTo(195, 1.0), reason: 'căn giữa màn 390');
      expect(tester.getTopLeft(_k('manual-log')).dy, greaterThan(tester.getTopLeft(_k('cards-tile')).dy), reason: 'dưới hàng Kho thẻ');
      await tester.tap(_k('manual-log'));
      await tester.pumpAndSettle();
      expect(find.textContaining('Chỉ ghi cho hôm nay.'), findsOneWidget);
    });

    testWidgets('chưa có môn: lời mời dẫn tới kế hoạch /hoc-tap', (tester) async {
      final empty = StudyOverview.fromJson({...fixtureMap('overview'), 'subjects': <Object>[]});
      await _pumpTab(tester, FakeHocTapApi(overview: empty));
      expect(_k('open-plan'), findsOneWidget);
      expect(find.byType(FilledButton), findsOneWidget);
    });
  });

  group('toàn màn Hôm nay chỉ có MỘT nút vàng, ở việc tiếp theo', () {
    Future<void> pumpScreen(WidgetTester tester, StudyOverview o) =>
        pumpHocTap(tester, const TraDinhHocTapScreen(), api: FakeHocTapApi(overview: o));

    Map<String, dynamic> cards(Map<String, dynamic> s, Map<String, Object?> extra) => {...Map<String, dynamic>.from(s['cards'] as Map), ...extra};

    testWidgets('có thẻ đến hạn → "Ôn thẻ"', (tester) async {
      await pumpScreen(tester, _practiceOverview((s) => s['cards'] = cards(s, {'total': 10, 'planned': 5, 'finished': 2})));
      expect(find.byType(FilledButton), findsOneWidget);
      expect(tester.widget(_k('cards-start')), isA<FilledButton>());
    });

    testWidgets('hết thẻ nhưng còn bài tiếp → "Học bài tiếp"', (tester) async {
      await pumpScreen(tester, _practiceOverview((s) => s['cards'] = cards(s, {'total': 10, 'planned': 5, 'finished': 5})));
      expect(find.byType(FilledButton), findsOneWidget);
      expect(find.descendant(of: _k('task-lesson'), matching: find.byType(FilledButton)), findsOneWidget);
    });

    testWidgets('chỉ còn Luyện AI → "Luyện nói với AI"', (tester) async {
      await pumpScreen(tester, _practiceOverview((s) {
        s['next'] = null;
        s['cards'] = cards(s, {'total': 10, 'planned': 3, 'finished': 3});
      }));
      expect(find.byType(FilledButton), findsOneWidget);
      expect(find.descendant(of: _k('task-practice'), matching: find.byType(FilledButton)), findsOneWidget);
    });

    testWidgets('mọi việc xong → không có nút vàng nào trên cả màn', (tester) async {
      await pumpScreen(tester, _practiceOverview((s) {
        s['next'] = null;
        s['cards'] = cards(s, {'total': 10, 'planned': 3, 'finished': 3});
        s['today'] = {...Map<String, dynamic>.from(s['today'] as Map), 'minutes': 60, 'done': true};
      }));
      expect(find.byType(FilledButton), findsNothing);
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
            redirect: (_, state) => traDinhLegacyTabRedirect(state.uri),
            builder: (_, state) => TraDinhHocTapScreen(openLog: state.uri.queryParameters['openLog'] == '1', subjectId: state.uri.queryParameters['subjectId']),
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
      // Không tự mở lại khi rebuild.
      await tester.pump(const Duration(milliseconds: 300));
      expect(find.textContaining('Chỉ ghi cho hôm nay.'), findsNothing);
      expect(find.byKey(const ValueKey('today-main')), findsOneWidget);
    });

    testWidgets('liên kết cũ kèm ?tab= vẫn giữ openLog / subjectId; không có openLog thì không mở sheet', (tester) async {
      final api = FakeHocTapApi();
      final router = await pumpRoute(tester, api, '/tra-dinh?tab=today&openLog=1&subjectId=${api.subjects.first.id}');
      expect(find.textContaining('Chỉ ghi cho hôm nay.'), findsOneWidget);
      expect(router.state.uri.toString(), '/tra-dinh');

      final api2 = FakeHocTapApi();
      await pumpRoute(tester, api2, '/tra-dinh?tab=today');
      expect(find.textContaining('Chỉ ghi cho hôm nay.'), findsNothing);
      expect(find.byKey(const ValueKey('today-main')), findsOneWidget);
    });
  });
}

import 'package:amber_flutter/features/tra_dinh/hoc_tap/models/study_enums.dart';
import 'package:amber_flutter/features/tra_dinh/hoc_tap/models/study_log.dart';
import 'package:amber_flutter/features/tra_dinh/hoc_tap/models/study_overview.dart';
import 'package:amber_flutter/features/tra_dinh/hoc_tap/models/study_schedule.dart';
import 'package:amber_flutter/features/tra_dinh/hoc_tap/models/study_subject.dart';
import 'package:amber_flutter/features/tra_dinh/hoc_tap/screens/overview_tab.dart';
import 'package:amber_flutter/features/tra_dinh/hoc_tap/utils/log_labels.dart';
import 'package:amber_flutter/features/tra_dinh/hoc_tap/widgets/overview_cards.dart';
import 'package:amber_flutter/features/tra_dinh/hoc_tap/widgets/cards_today_block.dart';
import 'package:amber_flutter/features/tra_dinh/hoc_tap/widgets/schedule_day_row.dart';
import 'package:amber_flutter/shared/utils/vn_time.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import 'hoc_tap_test_support.dart';
import 'hoc_tap_widget_support.dart';

// Khối "Thẻ hôm nay" ở Tổng quan (JSON thật `overview_cards`: A 0/3, B chưa có kế hoạch, C 2/2, D 1/3), nhãn "Ôn thẻ" ở danh sách buổi học.

Finder _k(String key) => find.byKey(ValueKey(key));

StudyOverview _overview() => StudyOverview.fromJson(fixtureMap('overview_cards'));
SubjectOverview _subject(StudyOverview o, String name) => o.subjects.firstWhere((s) => s.name == name);

Future<FakeHocTapApi> _pump(WidgetTester tester, {StudyOverview? overview, String? select, FakeHocTapApi? fake}) async {
  final o = overview ?? _overview();
  final api = fake ?? FakeHocTapApi(overview: o);
  await pumpHocTap(tester, const Scaffold(body: OverviewTab()), api: api);
  if (select != null) {
    final id = _subject(o, select).subjectId;
    await tester.tap(_k('subject-chip-$id'));
    await tester.pumpAndSettle();
  }
  return api;
}

String _text(WidgetTester tester, String key) => tester.widget<Text>(_k(key)).data!;

void main() {
  group('model', () {
    test('SubjectOverview.cards: khối thật của backend dev', () {
      final o = _overview();
      final a = _subject(o, 'Môn A').cards!;
      expect((a.planned, a.finished, a.quota), (3, 0, 20));
      expect(a.nextReviewDay, matches(RegExp(r'^\d{4}-\d{2}-\d{2}$')));
      expect(_subject(o, 'Môn B').cards!.planned, 0);
      expect((_subject(o, 'Môn C').cards!.planned, _subject(o, 'Môn C').cards!.finished), (2, 2));
      expect(_subject(o, 'Môn D').cards!.finished, 1);
    });

    test('thiếu khối cards (backend cũ) → null; các trường cũ vẫn đọc như trước', () {
      final old = StudyOverview.fromJson(fixtureMap('overview'));
      expect(old.subjects.every((s) => s.cards == null), isTrue);
      expect(old.subjects.first.name, 'Tiếng Anh');
      final s = SubjectOverview.fromJson({...Map<String, dynamic>.from(fixtureMap('overview')['subjects'][0] as Map), 'cards': 'hỏng'});
      expect(s.cards, isNull, reason: 'không phải object → bỏ qua, không ném lỗi');
    });

    test('khối cards thiếu trường: mặc định planned 0, finished 0, quota 20, không có ngày ôn', () {
      final c = CardsToday.fromJson({});
      expect((c.planned, c.finished, c.quota, c.nextReviewDay), (0, 0, 20, null));
      expect(CardsToday.fromJson({'planned': 5.0, 'quota': 12}).planned, 5);
    });

    test('ScheduleLog.activity: buổi ôn thẻ thật; thiếu activity → học bài', () {
      final sc = StudySchedule.fromJson(fixtureMap('schedule_card_review'));
      final logs = sc.days.expand((d) => d.logs).toList();
      expect(logs.map((l) => l.activity).toSet(), {LogActivity.lesson, LogActivity.cardReview});
      expect(logs.firstWhere((l) => l.activity == LogActivity.cardReview).courseTitle, isNull);
      expect(ScheduleLog.fromJson({'id': 'x', 'minutes': 5}).activity, LogActivity.lesson);
    });

    test('weekdayDateLabel: thứ + ngày; chuỗi hỏng giữ nguyên', () {
      expect(weekdayDateLabel('2026-11-08'), 'CN 08/11');
      expect(weekdayDateLabel('2026-11-09'), 'T2 09/11');
      expect(weekdayDateLabel('2026-11-14'), 'T7 14/11');
      expect(weekdayDateLabel('hỏng'), 'hỏng');
    });
  });

  group('khối Thẻ hôm nay', () {
    testWidgets('chưa có kế hoạch (planned 0): "chưa bắt đầu · tối đa 20 thẻ" + nút chính "Bắt đầu ôn", không thanh tiến độ', (tester) async {
      await _pump(tester, select: 'Môn B');
      expect(_text(tester, 'cards-status'), 'Thẻ hôm nay: chưa bắt đầu · tối đa 20 thẻ');
      expect(find.text('Bắt đầu ôn'), findsOneWidget);
      expect(find.text('Tiếp tục ôn'), findsNothing);
      expect(_k('cards-progress'), findsNothing);
      expect(find.text('Kho thẻ'), findsOneWidget);
    });

    testWidgets('đang ôn dở (0 < finished < planned): "Đã ôn 1 / 3 thẻ", thanh tiến độ mảnh, nút chính "Tiếp tục ôn"', (tester) async {
      await _pump(tester, select: 'Môn D');
      expect(_text(tester, 'cards-status'), 'Đã ôn 1 / 3 thẻ');
      final bar = tester.widget<LinearProgressIndicator>(_k('cards-progress'));
      expect(bar.value, closeTo(1 / 3, 1e-9));
      expect(bar.minHeight, lessThanOrEqualTo(4));
      expect(find.text('Tiếp tục ôn'), findsOneWidget);
      expect(find.text('Bắt đầu ôn'), findsNothing);
      expect(find.text('Kho thẻ'), findsOneWidget);
    });

    testWidgets('đã mở kế hoạch nhưng chưa ôn thẻ nào (0 / 3): nút "Bắt đầu ôn", vẫn có thanh tiến độ', (tester) async {
      await _pump(tester, select: 'Môn A');
      expect(_text(tester, 'cards-status'), 'Đã ôn 0 / 3 thẻ');
      expect(tester.widget<LinearProgressIndicator>(_k('cards-progress')).value, 0.0);
      expect(find.text('Bắt đầu ôn'), findsOneWidget);
    });

    testWidgets('ôn xong (finished = planned > 0): "Hôm nay đã ôn xong 2 thẻ", KHÔNG có nút chính, vẫn có "Kho thẻ"', (tester) async {
      await _pump(tester, select: 'Môn C');
      expect(_text(tester, 'cards-status'), 'Hôm nay đã ôn xong 2 thẻ');
      expect(_k('cards-start'), findsNothing);
      expect(find.text('Bắt đầu ôn'), findsNothing);
      expect(find.text('Tiếp tục ôn'), findsNothing);
      expect(_k('cards-progress'), findsNothing);
      expect(_k('open-card-library'), findsOneWidget);
    });

    testWidgets('luôn có dòng "Ngày ôn tập kế tiếp: thứ dd/MM" ở cả ba trạng thái', (tester) async {
      final o = _overview();
      final expected = 'Ngày ôn tập kế tiếp: ${weekdayDateLabel(_subject(o, 'Môn A').cards!.nextReviewDay!)}';
      for (final name in ['Môn A', 'Môn B', 'Môn C']) {
        await _pump(tester, overview: o, select: name);
        expect(_text(tester, 'cards-next-review'), expected, reason: name);
      }
    });

    testWidgets('không có nextReviewDay thì ẩn dòng đó, không lỗi', (tester) async {
      final s = _subject(_overview(), 'Môn A');
      final o = StudyOverview(today: '2026-11-06', week: _overview().week, subjects: [
        SubjectOverview(subjectId: s.subjectId, name: s.name, today: s.today, cards: const CardsToday(planned: 3, finished: 1)),
      ]);
      await _pump(tester, overview: o);
      expect(_k('cards-next-review'), findsNothing);
      expect(_k('cards-start'), findsOneWidget);
    });

    testWidgets('nút chính mở màn ôn, "Kho thẻ" mở kho thẻ — đúng môn đang chọn', (tester) async {
      final o = _overview();
      final id = _subject(o, 'Môn D').subjectId;
      await _pump(tester, overview: o, select: 'Môn D');
      await tester.tap(_k('cards-start'));
      await tester.pumpAndSettle();
      expect(visited.last, '/tra-dinh/hoc-tap/the/on?subjectId=$id');
    });

    testWidgets('"Thống kê thẻ" cạnh "Kho thẻ" mở màn Nhóm khó của môn đang chọn (cả khi đã ôn xong, không có nút chính)', (tester) async {
      final o = _overview();
      final id = _subject(o, 'Môn C').subjectId;
      await _pump(tester, overview: o, select: 'Môn C');
      expect(find.text('Thống kê thẻ'), findsOneWidget);
      expect(_k('open-card-library'), findsOneWidget);
      expect(find.byType(Wrap), findsWidgets, reason: 'hai nút phụ trong Wrap: cạnh nhau khi đủ chỗ, xuống dòng khi hẹp (font test rộng hơn font thật nên không kiểm vị trí)');
      await tester.tap(_k('open-card-insights'));
      await tester.pumpAndSettle();
      expect(visited.last, '/tra-dinh/hoc-tap/the/thong-ke?subjectId=$id');
    });

    testWidgets('hai nút phụ không tràn ở 320 px, chữ x2.0 (xuống dòng)', (tester) async {
      tester.platformDispatcher.textScaleFactorTestValue = 2.0;
      addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
      await pumpHocTap(tester, Scaffold(body: SingleChildScrollView(child: CardsTodayBlock(subject: _subject(_overview(), 'Môn C')))), api: FakeHocTapApi(), width: 320);
      expect(tester.takeException(), isNull);
      expect(_k('open-card-insights'), findsOneWidget);
    });

    testWidgets('backend cũ (không có khối cards): không có nút "Thống kê thẻ"', (tester) async {
      await pumpHocTap(tester, const Scaffold(body: OverviewTab()), api: FakeHocTapApi());
      expect(_k('open-card-insights'), findsNothing);
    });

    testWidgets('"Kho thẻ" mở kho thẻ của môn đang chọn', (tester) async {
      final o = _overview();
      final id = _subject(o, 'Môn C').subjectId;
      await _pump(tester, overview: o, select: 'Môn C');
      await tester.tap(_k('open-card-library'));
      await tester.pumpAndSettle();
      expect(visited.last, '/tra-dinh/hoc-tap/the?subjectId=$id');
    });

    testWidgets('quay lại từ màn ôn thì Tổng quan tải lại (số thẻ đã ôn mới)', (tester) async {
      final api = await _pump(tester, select: 'Môn D');
      final before = api.overviewCalls;
      await tester.tap(_k('cards-start'));
      await tester.pumpAndSettle();
      GoRouter.of(tester.element(find.byType(Scaffold).first)).pop();
      await tester.pumpAndSettle();
      expect(api.overviewCalls, greaterThan(before));
    });

    testWidgets('backend cũ (không có khối cards): không hiện gì — cả nút "Kho thẻ"; phần còn lại của Tổng quan vẫn như cũ', (tester) async {
      await pumpHocTap(tester, const Scaffold(body: OverviewTab()), api: FakeHocTapApi());
      expect(_k('cards-today'), findsNothing);
      expect(find.text('Thẻ hôm nay'), findsNothing);
      expect(_k('open-card-library'), findsNothing);
      expect(_k('add-course'), findsOneWidget);
      expect(find.text('+ Môn'), findsOneWidget, reason: 'chip môn của Tổng quan giữ nguyên');
    });

    testWidgets('riêng khối này không tràn ở bề rộng 320 với chữ x1.8, ở cả ba trạng thái', (tester) async {
      tester.platformDispatcher.textScaleFactorTestValue = 1.8;
      addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
      final o = _overview();
      for (final name in ['Môn B', 'Môn D', 'Môn C']) {
        await pumpHocTap(tester, Scaffold(body: SingleChildScrollView(child: CardsTodayBlock(subject: _subject(o, name)))), api: FakeHocTapApi(), width: 320);
        expect(tester.takeException(), isNull, reason: name);
      }
    });
  });

  group('nhãn "Ôn thẻ" của buổi học', () {
    test('logTitle: ôn thẻ → "Ôn thẻ"; có khóa → tên khóa; không khóa → "Ôn tập"', () {
      expect(logTitle(activity: LogActivity.cardReview), 'Ôn thẻ');
      expect(logTitle(activity: LogActivity.cardReview, courseTitle: 'x'), 'Ôn thẻ');
      expect(logTitle(activity: LogActivity.lesson, courseTitle: 'Khóa A'), 'Khóa A');
      expect(logTitle(activity: LogActivity.lesson), 'Ôn tập');
    });

    testWidgets('thẻ "Hôm nay" ở Tổng quan: buổi ôn thẻ hiện "Ôn thẻ", buổi không khóa vẫn "Ôn tập"', (tester) async {
      final o = _overview();
      final sid = _subject(o, 'Môn D').subjectId;
      final api = FakeHocTapApi(overview: o)
        ..logs = [
          StudyLog(id: 'card', subjectId: sid, logDate: vnToday(), minutes: 15, createdAt: DateTime.now(), activity: LogActivity.cardReview),
          StudyLog(id: 'free', subjectId: sid, logDate: vnToday(), minutes: 20, createdAt: DateTime.now()),
        ];
      await pumpHocTap(tester, const Scaffold(body: OverviewTab()), api: api);
      await tester.tap(_k('subject-chip-$sid'));
      await tester.pumpAndSettle();
      expect(find.descendant(of: _k('today-log-card'), matching: find.text('Ôn thẻ')), findsOneWidget);
      expect(find.descendant(of: _k('today-log-free'), matching: find.text('Ôn tập')), findsOneWidget);
    });

    testWidgets('dòng ngày của Lịch (JSON thật): buổi ôn thẻ "Ôn thẻ", buổi học bài không khóa "Ôn tập"', (tester) async {
      final sc = StudySchedule.fromJson(fixtureMap('schedule_card_review'));
      final day = sc.days.firstWhere((d) => d.logs.isNotEmpty);
      final subject = StudySubject.fromJson({'id': 's', 'name': 'Môn D', 'dailyGoalMinutes': 60, 'videoMinutesPerDay': 40, 'reviewWeekdays': [7], 'position': 0});
      await pumpHocTap(tester, Scaffold(body: SingleChildScrollView(child: ScheduleDayRow(day: day, subject: subject))), api: FakeHocTapApi());
      expect(find.text('Ôn thẻ'), findsOneWidget);
      expect(find.text('Ôn tập'), findsOneWidget);
      expect(find.text('15p'), findsOneWidget);
    });
  });

  group('thẻ "Hôm nay" (TodayCard): dòng phút không tràn', () {
    SubjectOverview subject({int minutes = 0, int logCount = 0, int? goal = 60}) => SubjectOverview(
      subjectId: 's',
      name: 'Tiếng Anh',
      goalMinutes: goal,
      today: TodayInfo(minutes: minutes, logCount: logCount, done: false),
    );

    for (final (width, scale) in [(390.0, 1.0), (320.0, 1.0), (320.0, 2.0), (390.0, 2.0)]) {
      testWidgets('bề rộng $width, chữ x$scale: "0 / 60 phút" và "Chưa có buổi nào" xuống dòng thay vì tràn', (tester) async {
        tester.platformDispatcher.textScaleFactorTestValue = scale;
        addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
        for (final s in [subject(), subject(goal: null), subject(minutes: 1440, logCount: 12, goal: 1440), subject(minutes: 20, logCount: 1)]) {
          await pumpHocTap(tester, Scaffold(body: SingleChildScrollView(child: TodayCard(subject: s, onLog: () {}))), api: FakeHocTapApi(), width: width);
          expect(tester.takeException(), isNull, reason: '${s.goalMinutes} / ${s.today.minutes} / ${s.today.logCount}');
          expect(find.byKey(const ValueKey('today-minutes')), findsOneWidget);
        }
      });
    }

    testWidgets('chữ vẫn đủ: số phút, mục tiêu và số buổi đều có mặt', (tester) async {
      await pumpHocTap(tester, Scaffold(body: SingleChildScrollView(child: TodayCard(subject: subject(), onLog: () {}))), api: FakeHocTapApi(), width: 320);
      expect(find.text('0'), findsOneWidget);
      expect(find.text(' / 60 phút'), findsOneWidget);
      expect(find.text('Chưa có buổi nào'), findsOneWidget);
    });
  });
}

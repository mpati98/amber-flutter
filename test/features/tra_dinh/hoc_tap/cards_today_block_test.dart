import 'package:amber_flutter/features/tra_dinh/hoc_tap/models/study_enums.dart';
import 'package:amber_flutter/features/tra_dinh/hoc_tap/models/study_log.dart';
import 'package:amber_flutter/features/tra_dinh/hoc_tap/models/study_overview.dart';
import 'package:amber_flutter/features/tra_dinh/hoc_tap/models/study_schedule.dart';
import 'package:amber_flutter/features/tra_dinh/hoc_tap/models/study_subject.dart';
import 'package:amber_flutter/features/tra_dinh/hoc_tap/screens/overview_tab.dart';
import 'package:amber_flutter/features/tra_dinh/hoc_tap/utils/log_labels.dart';
import 'package:amber_flutter/features/tra_dinh/hoc_tap/widgets/today_tasks_card.dart';
import 'package:amber_flutter/features/tra_dinh/hoc_tap/widgets/schedule_day_row.dart';
import 'package:amber_flutter/shared/utils/vn_time.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import 'hoc_tap_test_support.dart';
import 'hoc_tap_widget_support.dart';

// Hàng Ôn thẻ của "Việc hôm nay" (JSON thật `overview_cards`: A 0/3, B chưa có kế hoạch, C 2/2, D 1/3), nhãn "Ôn thẻ" ở danh sách buổi học.

Finder _k(String key) => find.byKey(ValueKey(key));

StudyOverview _overview() => StudyOverview.fromJson(fixtureMap('overview_cards'));
SubjectOverview _subject(StudyOverview o, String name) => o.subjects.firstWhere((s) => s.name == name);

Future<FakeHocTapApi> _pump(WidgetTester tester, {StudyOverview? overview, String? select, FakeHocTapApi? fake}) async {
  final o = overview ?? _overview();
  final api = fake ?? FakeHocTapApi(overview: o);
  await pumpHocTap(tester, const Scaffold(body: OverviewTab()), api: api);
  if (select != null) {
    final id = _subject(o, select).subjectId;
    await tester.ensureVisible(_k('subject-chip-$id'));
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

  group('hàng Ôn thẻ trong "Việc hôm nay"', () {
    testWidgets('chưa mở hàng đợi (planned 0): "Chưa bắt đầu · tối đa 20 thẻ", "Bắt đầu" là nút vàng', (tester) async {
      await _pump(tester, select: 'Môn B');
      expect(_text(tester, 'cards-status'), 'Chưa bắt đầu · tối đa 20 thẻ');
      expect(tester.widget(_k('cards-start')), isA<FilledButton>());
      expect(find.descendant(of: _k('cards-start'), matching: find.text('Bắt đầu')), findsOneWidget);
    });

    testWidgets('đang ôn dở (1 / 3): "1 / 3 thẻ", nút "Tiếp tục" là nút vàng', (tester) async {
      await _pump(tester, select: 'Môn D');
      expect(_text(tester, 'cards-status'), '1 / 3 thẻ');
      expect(tester.widget(_k('cards-start')), isA<FilledButton>());
      expect(find.text('Tiếp tục'), findsOneWidget);
    });

    testWidgets('đã mở kế hoạch nhưng chưa ôn (0 / 3): "Bắt đầu" là nút vàng', (tester) async {
      await _pump(tester, select: 'Môn A');
      expect(_text(tester, 'cards-status'), '0 / 3 thẻ');
      expect(tester.widget(_k('cards-start')), isA<FilledButton>());
    });

    testWidgets('ôn xong (2 / 2): "2 / 2 · xong" + dấu tick, không có nút', (tester) async {
      await _pump(tester, select: 'Môn C');
      expect(find.descendant(of: _k('today-tasks'), matching: find.byType(FilledButton)).evaluate().any((e) => e.widget.key == const ValueKey('cards-start')), isFalse);
      expect(_text(tester, 'cards-status'), '2 / 2 · xong');
      expect(_k('cards-start'), findsNothing);
      expect(_k('task-done'), findsOneWidget);
    });

    testWidgets('dòng "Ngày ôn tập kế tiếp: thứ dd/MM" ở cả ba trạng thái', (tester) async {
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

    testWidgets('nút mở màn ôn của đúng môn đang chọn', (tester) async {
      final o = _overview();
      final id = _subject(o, 'Môn D').subjectId;
      await _pump(tester, overview: o, select: 'Môn D');
      await tester.tap(_k('cards-start'));
      await tester.pumpAndSettle();
      expect(visited.last, '/tra-dinh/hoc-tap/the/on?subjectId=$id');
    });

    testWidgets('quay lại từ màn ôn thì tải lại tổng quan (số thẻ đã ôn mới)', (tester) async {
      final api = await _pump(tester, select: 'Môn D');
      final before = api.overviewCalls;
      await tester.tap(_k('cards-start'));
      await tester.pumpAndSettle();
      GoRouter.of(tester.element(find.byType(Scaffold).first)).pop();
      await tester.pumpAndSettle();
      expect(api.overviewCalls, greaterThan(before));
    });

    testWidgets('backend cũ (không có khối cards): không có hàng Ôn thẻ; hàng Học bài và Luyện AI vẫn có', (tester) async {
      await pumpHocTap(tester, const Scaffold(body: OverviewTab()), api: FakeHocTapApi());
      expect(_k('task-cards'), findsNothing);
      expect(_k('task-lesson'), findsOneWidget);
      expect(_k('task-practice'), findsOneWidget);
    });

    testWidgets('không tràn ở 320 px, chữ x1.8, cả ba trạng thái', (tester) async {
      tester.platformDispatcher.textScaleFactorTestValue = 1.8;
      addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
      final o = _overview();
      for (final name in ['Môn B', 'Môn D', 'Môn C']) {
        await pumpHocTap(tester, Scaffold(body: SingleChildScrollView(child: TodayTasksCard(subject: _subject(o, name)))), api: FakeHocTapApi(), width: 320);
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
      await tester.ensureVisible(_k('subject-chip-$sid'));
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
}

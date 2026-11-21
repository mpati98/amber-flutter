import 'package:amber_flutter/features/tra_dinh/hoc_tap/models/study_overview.dart';
import 'package:amber_flutter/features/tra_dinh/hoc_tap/screens/tra_dinh_hoc_tap_screen.dart';
import 'package:amber_flutter/features/tra_dinh/hoc_tap/utils/tra_dinh_notices.dart';
import 'package:flutter/services.dart' show LogicalKeyboardKey;
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

import 'hoc_tap_test_support.dart';
import 'hoc_tap_widget_support.dart';

// Màn Trà Đình một màn (ZoneScaffold): khung Hôm nay | khung Kho thẻ — bố cục, nút vàng, phiên mở từ Hôm nay.

Finder _k(String key) => find.byKey(ValueKey(key));
final _today = _k('zone-frame-Hôm nay');
final _cards = _k('zone-frame-Kho thẻ');

/// Fixture thật có khối `cards` (môn đầu: còn thẻ cần ôn → nút vàng ở hàng Ôn thẻ).
StudyOverview _overview() => StudyOverview.fromJson(fixtureMap('overview_cards'));

Future<FakeHocTapApi> _pump(WidgetTester tester, Size size, {Widget? screen}) async {
  final api = FakeHocTapApi(overview: _overview());
  await pumpHocTap(tester, screen ?? const TraDinhHocTapScreen(), api: api, width: size.width, height: size.height);
  return api;
}

/// Mọi Scrollable DỌC phải nằm trong một ZoneFrame — trang không cuộn.
void _expectNoPageScroll(WidgetTester tester) {
  final frames = find.byWidgetPredicate((w) => w.key is ValueKey<String> && (w.key! as ValueKey<String>).value.startsWith('zone-frame-'));
  var vertical = 0;
  for (final e in find.byType(Scrollable).evaluate()) {
    final s = e.widget as Scrollable;
    if (axisDirectionToAxis(s.axisDirection) != Axis.vertical) continue;
    vertical++;
    expect(find.ancestor(of: find.byWidget(s), matching: frames), findsWidgets, reason: 'Scrollable dọc ngoài ZoneFrame');
  }
  expect(vertical, greaterThan(0));
}

Future<void> _tab(WidgetTester tester, String id) async {
  await tester.ensureVisible(_k('zone-tab-$id'));
  await tester.pumpAndSettle();
  await tester.tap(_k('zone-tab-$id'));
  await tester.pumpAndSettle();
}

void main() {
  group('bố cục một màn', () {
    for (final size in const [Size(1920, 1080), Size(1280, 720), Size(800, 1000)]) {
      testWidgets('${size.width.toInt()}×${size.height.toInt()}: Hôm nay | Kho thẻ tỉ lệ 2 / 3, không tràn, không cuộn trang', (tester) async {
        await _pump(tester, size);
        expect(tester.takeException(), isNull);
        _expectNoPageScroll(tester);
        final t = tester.getRect(_today);
        final c = tester.getRect(_cards);
        expect(t.left, 16);
        expect(c.right, closeTo(size.width - 16, 0.01));
        expect(c.width / t.width, closeTo(1.5, 0.05));
        expect(c.bottom, t.bottom);
        expect(t.bottom, lessThanOrEqualTo(size.height - 16));
        expect(_k('zone-tab-today'), findsNothing);
        // Chip môn ở đầu khung Hôm nay (cố định, ngoài vùng cuộn của khung).
        final chip = _k('subject-chip-${_overview().subjects.first.subjectId}');
        expect(find.descendant(of: _today, matching: chip), findsOneWidget);
        expect(find.ancestor(of: chip, matching: find.byType(SingleChildScrollView)).evaluate().every((e) {
          final v = e.widget as SingleChildScrollView;
          return v.scrollDirection == Axis.horizontal || v.padding == const EdgeInsets.only(right: 8, bottom: 8);
        }), isTrue, reason: 'chỉ hàng chip cuộn ngang / vỏ đầu khung, không nằm trong vùng cuộn thân khung');
      });
    }

    testWidgets('390×844: tab Hôm nay / Kho thẻ, tab lấp chiều cao; không tràn, không cuộn trang', (tester) async {
      await _pump(tester, const Size(390, 844));
      expect(_today, findsOneWidget);
      expect(_cards, findsNothing);
      expect(tester.getRect(_today).bottom, closeTo(844 - 16, 0.5));
      _expectNoPageScroll(tester);
      await _tab(tester, 'cards');
      expect(_cards, findsOneWidget);
      expect(_today, findsNothing);
      expect(tester.getRect(_cards).bottom, closeTo(844 - 16, 0.5));
      expect(tester.takeException(), isNull);
      _expectNoPageScroll(tester);
    });

    testWidgets('320 px, chữ ×2,0: cả hai tab không tràn', (tester) async {
      tester.platformDispatcher.textScaleFactorTestValue = 2.0;
      addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
      await _pump(tester, const Size(320, 640));
      expect(tester.takeException(), isNull, reason: 'Hôm nay');
      await _tab(tester, 'cards');
      expect(tester.takeException(), isNull, reason: 'Kho thẻ');
    });

    testWidgets('?kho=1 (route cũ /tra-dinh/hoc-tap/the): điện thoại mở sẵn tab Kho thẻ', (tester) async {
      await _pump(tester, const Size(390, 844), screen: const TraDinhHocTapScreen(cards: true));
      expect(_cards, findsOneWidget);
      expect(_today, findsNothing);
    });

    testWidgets('Kho thẻ mở rộng toàn màn (modal), Esc đóng', (tester) async {
      await _pump(tester, const Size(1280, 720));
      await tester.tap(_k('zone-expand-Kho thẻ'));
      await tester.pumpAndSettle();
      final modal = _k('zone-expanded-Kho thẻ');
      expect(find.descendant(of: modal, matching: _k('card-search')), findsOneWidget);
      expect(tester.takeException(), isNull);
      await tester.sendKeyEvent(LogicalKeyboardKey.escape);
      await tester.pumpAndSettle();
      expect(modal, findsNothing);
    });
  });

  group('nút vàng và phiên', () {
    testWidgets('cả màn (hai khung) chỉ có ĐÚNG MỘT nút vàng — việc tiếp theo theo nextTodayAction (Ôn thẻ)', (tester) async {
      await _pump(tester, const Size(1280, 900));
      expect(find.byType(FilledButton), findsOneWidget);
      expect(find.descendant(of: _k('task-cards'), matching: find.byType(FilledButton)), findsOneWidget);
      expect(find.descendant(of: _cards, matching: find.byType(FilledButton)), findsNothing);
    });

    testWidgets('các phiên mở được từ khung Hôm nay (màn toàn màn riêng): ôn thẻ, học bài, luyện nói AI', (tester) async {
      final api = await _pump(tester, const Size(1280, 900));
      final s = api.overview.subjects.first;
      Future<void> openFrom(String row) async {
        final button = find.descendant(of: _k(row), matching: find.byWidgetPredicate((w) => w is FilledButton || w is OutlinedButton));
        await tester.tap(button.first);
        await tester.pumpAndSettle();
      }

      await openFrom('task-cards');
      expect(visited.last, '/tra-dinh/hoc-tap/the/on?subjectId=${s.subjectId}');
      Navigator.of(tester.element(find.textContaining('stub'))).pop();
      await tester.pumpAndSettle();

      if (s.next case final next?) {
        await openFrom('task-lesson');
        expect(visited.last, '/tra-dinh/hoc-tap/courses/${next.courseId}');
        Navigator.of(tester.element(find.textContaining('stub'))).pop();
        await tester.pumpAndSettle();
      }

      await openFrom('task-practice');
      expect(visited.last, '/tra-dinh/luyen-tap?subjectId=${s.subjectId}');
    });

    testWidgets('"+ Nhập thẻ" ở đầu khung Kho thẻ mở màn nhập của môn đang chọn', (tester) async {
      final api = await _pump(tester, const Size(1280, 720));
      await tester.tap(_k('card-import'));
      await tester.pumpAndSettle();
      expect(visited.last, '/tra-dinh/hoc-tap/the/them?subjectId=${api.overview.subjects.first.subjectId}');
    });
  });

  group('popup Trà Đình trên cảnh 3D', () {
    test('buildTraDinhNotices: phút / mục tiêu, chuỗi, thẻ cần ôn (cùng luật nút vàng)', () {
      SubjectOverview s(String id, {int minutes = 0, int? goal, bool done = false, int? streak, CardsToday? cards}) =>
          SubjectOverview(subjectId: id, name: id, goalMinutes: goal, today: TodayInfo(minutes: minutes, logCount: 0, done: done), streak: streak, cards: cards);
      final week = _overview().week;
      StudyOverview o(List<SubjectOverview> subjects) => StudyOverview(today: '2026-11-21', week: week, subjects: subjects);

      expect(buildTraDinhNotices(o([
        s('a', minutes: 30, goal: 60, streak: 6, cards: const CardsToday(planned: 20, finished: 8, total: 100)),
        s('b', minutes: 10, cards: const CardsToday(planned: 0, total: 5)),
      ])), [
        {'text': 'Hôm nay 40 / 60 phút', 'lvl': 'warn'},
        {'text': 'Chuỗi 6 ngày', 'lvl': 'ok'},
        {'text': '12 thẻ cần ôn hôm nay', 'lvl': 'warn'},
      ]);
      expect(buildTraDinhNotices(o([s('a', minutes: 60, goal: 60, done: true, cards: const CardsToday(planned: 0, total: 3))])), [
        {'text': 'Hôm nay 60 / 60 phút', 'lvl': 'ok'},
        {'text': 'Chưa ôn thẻ hôm nay', 'lvl': 'warn'},
      ]);
      expect(buildTraDinhNotices(o([s('a', cards: const CardsToday(planned: 5, finished: 5, total: 9))])), [
        {'text': 'Hôm nay 0 phút', 'lvl': 'info'},
        {'text': 'Đã ôn xong thẻ hôm nay', 'lvl': 'ok'},
      ]);
      expect(buildTraDinhNotices(o(const [])), [
        {'text': 'Chưa có môn học nào', 'lvl': 'info'},
      ]);
    });
  });
}

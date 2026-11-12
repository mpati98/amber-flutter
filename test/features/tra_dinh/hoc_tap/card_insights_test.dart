import 'dart:async';

import 'package:amber_flutter/features/tra_dinh/hoc_tap/models/study_card.dart';
import 'package:amber_flutter/features/tra_dinh/hoc_tap/models/study_card_insights.dart';
import 'package:amber_flutter/features/tra_dinh/hoc_tap/screens/card_insights_screen.dart';
import 'package:amber_flutter/features/tra_dinh/hoc_tap/utils/card_insights_prompt.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import 'hoc_tap_test_support.dart';
import 'hoc_tap_widget_support.dart';

// Màn "Nhóm khó": số tổng theo kỳ, ba phần nhóm, thẻ hay quên, kỳ 7/30/90 (giữ dữ liệu cũ khi tải), trạng thái trống / lỗi, chép cho Claude.

const _sid = 'subject-1';
Finder _k(String key) => find.byKey(ValueKey(key));

CardInsights _fix(String name) => CardInsights.fromJson(fixtureMap(name));

Future<FakeHocTapApi> _pump(WidgetTester tester, {FakeHocTapApi? api, double width = 390, bool settle = true}) async {
  final fake = api ?? FakeHocTapApi();
  await pumpHocTap(tester, const CardInsightsScreen(subjectId: _sid), api: fake, width: width, height: 1800, settle: settle);
  return fake;
}

String _text(WidgetTester tester, String key) => tester.widget<Text>(_k(key)).data!;

void main() {
  group('đầu màn và số tổng', () {
    testWidgets('nút quay lại, tiêu đề "Nhóm khó", điều khiển 7 / 30 / 90 ngày (mặc định 30), gọi API đúng kỳ', (tester) async {
      final api = await _pump(tester);
      expect(find.byKey(const ValueKey('design-top-bar-back')), findsOneWidget);
      expect(find.text('Nhóm khó'), findsOneWidget);
      for (final d in [7, 30, 90]) {
        expect(find.text('$d ngày'), findsOneWidget);
      }
      expect(tester.widget<SegmentedButton<int>>(_k('insights-days')).selected, {30});
      expect(api.insightsCalls, [(subjectId: _sid, days: 30)]);
    });

    testWidgets('ba ô: "Lượt ôn", "Chưa nhớ" (phần trăm), "Thẻ lên Hàng tuần"', (tester) async {
      await _pump(tester);
      expect(find.text('Lượt ôn'), findsOneWidget);
      expect(find.text('Chưa nhớ'), findsOneWidget);
      expect(find.text('Thẻ lên Hàng tuần'), findsOneWidget);
      expect(_text(tester, 'tile-reviews-value'), '4');
      expect(_text(tester, 'tile-notyet-value'), '50%');
      expect(_text(tester, 'tile-promoted-value'), '2');
    });

    testWidgets('chú thích cuối trang nói rõ hai mốc thời gian', (tester) async {
      await _pump(tester);
      await tester.scrollUntilVisible(_k('insights-footnote'), 300, scrollable: find.byType(Scrollable).first);
      expect(_text(tester, 'insights-footnote'), 'Nhóm tính trên toàn bộ lịch sử của thẻ (thẻ đã Chưa nhớ rồi Đã nhớ vẫn tính). Tổng lượt ôn chỉ tính trong kỳ đã chọn.');
    });
  });

  group('các nhóm', () {
    testWidgets('mỗi dòng: nhãn (loại bằng tiếng Việt như kho thẻ), "a/b thẻ từng chưa nhớ · x%", thanh có độ rộng = tỷ lệ', (tester) async {
      await _pump(tester);
      expect(find.text('Theo loại'), findsOneWidget);
      expect(find.text('Theo chủ đề'), findsOneWidget);
      expect(find.text('Theo buổi học'), findsOneWidget);
      final kind = _k('row-kind-IDIOM');
      expect(find.descendant(of: kind, matching: find.text('Thành ngữ')), findsOneWidget, reason: 'nhãn tiếng Việt, không phải "IDIOM"');
      expect(find.descendant(of: kind, matching: find.text('10/12 thẻ từng chưa nhớ · 83%')), findsOneWidget);
      expect(tester.widget<LinearProgressIndicator>(_k('bar-kind-IDIOM')).value, closeTo(10 / 12, 1e-9));
      expect(find.descendant(of: _k('row-topic-work'), matching: find.text('work')), findsOneWidget);
      expect(find.descendant(of: _k('row-topic-work'), matching: find.text('10/12 thẻ từng chưa nhớ · 83%')), findsOneWidget);
      final lesson = _fix('card_insights_seeded').byLesson.single;
      expect(find.descendant(of: _k('row-lesson-${lesson.key}'), matching: find.text(lesson.label)), findsOneWidget);
      expect(find.byType(Wrap), findsNothing);
    });

    testWidgets('các dòng giữ đúng thứ tự server gửi (không tự sắp lại); thanh theo từng tỷ lệ', (tester) async {
      final api = FakeHocTapApi()
        ..cardInsights = CardInsights(
          byKind: const [
            InsightGroup(key: 'PATTERN', label: 'PATTERN', totalCards: 10, everNotYetCards: 10, rate: 1),
            InsightGroup(key: 'COLLOCATION', label: 'COLLOCATION', totalCards: 12, everNotYetCards: 10, rate: 10 / 12),
            InsightGroup(key: 'PHRASAL_VERB', label: 'PHRASAL_VERB', totalCards: 40, everNotYetCards: 12, rate: 0.3),
          ],
        );
      await _pump(tester, api: api);
      final ys = [for (final k in ['PATTERN', 'COLLOCATION', 'PHRASAL_VERB']) tester.getTopLeft(_k('row-kind-$k')).dy];
      expect(ys, [...ys]..sort(), reason: 'đúng thứ tự server');
      expect(tester.widget<LinearProgressIndicator>(_k('bar-kind-PATTERN')).value, 1.0);
      expect(tester.widget<LinearProgressIndicator>(_k('bar-kind-PHRASAL_VERB')).value, 0.3);
      expect(find.text('12/40 thẻ từng chưa nhớ · 30%'), findsOneWidget);
      expect(find.text('Cụm động từ'), findsOneWidget);
      expect(find.text('Cấu trúc'), findsOneWidget);
    });

    testWidgets('loại lạ (server thêm loại mới) dùng nhãn server gửi, không lỗi', (tester) async {
      final api = FakeHocTapApi()..cardInsights = const CardInsights(byKind: [InsightGroup(key: 'NEW_KIND', label: 'Loại mới', totalCards: 11, everNotYetCards: 10, rate: 0.9)]);
      await _pump(tester, api: api);
      expect(find.text('Loại mới'), findsOneWidget);
    });
  });

  group('thẻ hay quên', () {
    testWidgets('mỗi thẻ: cụm + "N lần chưa nhớ", đúng thứ tự server', (tester) async {
      await _pump(tester);
      final cards = _fix('card_insights_seeded').hardestCards;
      expect(find.text('Thẻ hay quên'), findsOneWidget);
      for (final c in cards) {
        expect(find.descendant(of: _k('hardest-${c.id}'), matching: find.text(c.phrase)), findsOneWidget);
        expect(find.descendant(of: _k('hardest-${c.id}'), matching: find.text('${c.notYetCount} lần chưa nhớ')), findsOneWidget);
      }
      final ys = [for (final c in cards) tester.getTopLeft(_k('hardest-${c.id}')).dy];
      expect(ys, [...ys]..sort());
    });

    testWidgets('không có thẻ hay quên thì ẩn cả phần', (tester) async {
      await _pump(tester, api: FakeHocTapApi()..cardInsights = _fix('card_insights_partial'));
      expect(_k('hardest-section'), findsNothing);
      expect(find.text('Thẻ hay quên'), findsNothing);
    });
  });

  group('trạng thái trống', () {
    testWidgets('cả ba phần rỗng: MỘT lời giải thích (nêu ngưỡng) thay cho ba phần', (tester) async {
      await _pump(tester, api: FakeHocTapApi()..cardInsights = _fix('card_insights_empty'));
      expect(_text(tester, 'tile-reviews-value'), '0');
      expect(_k('insights-empty'), findsOneWidget);
      expect(find.text('Chưa đủ dữ liệu: một nhóm cần ít nhất 10 thẻ từng bị đánh Chưa nhớ mới hiện ở đây.'), findsOneWidget);
      expect(find.text('Theo loại'), findsNothing);
      expect(find.text('Theo chủ đề'), findsNothing);
      expect(find.text('Theo buổi học'), findsNothing);
      expect(_k('hardest-section'), findsNothing);
      expect(_text(tester, 'tile-notyet-value'), '0%');
    });

    testWidgets('ngưỡng lấy từ server (minCards)', (tester) async {
      await _pump(tester, api: FakeHocTapApi()..cardInsights = const CardInsights(minCards: 15));
      expect(find.textContaining('ít nhất 15 thẻ'), findsOneWidget);
    });

    testWidgets('chỉ một số phần rỗng: dòng ngắn ngay trong phần rỗng, không có lời giải thích chung', (tester) async {
      await _pump(tester, api: FakeHocTapApi()..cardInsights = _fix('card_insights_partial'));
      expect(_k('insights-empty'), findsNothing);
      expect(_k('row-kind-COLLOCATION'), findsOneWidget);
      expect(_text(tester, 'section-empty-topic'), 'Chưa đủ dữ liệu (cần ít nhất 10 thẻ từng chưa nhớ).');
      expect(_k('section-empty-lesson'), findsOneWidget);
      expect(_k('section-empty-kind'), findsNothing);
      expect(find.text('Theo chủ đề'), findsOneWidget, reason: 'phần rỗng vẫn có tiêu đề');
    });

    testWidgets('môn không có thẻ nào (JSON thật của môn trống) hiện trạng thái trống, không lỗi', (tester) async {
      await _pump(tester, api: FakeHocTapApi()..cardInsights = _fix('card_insights_empty'));
      expect(tester.takeException(), isNull);
      expect(find.byKey(const ValueKey('design-top-bar-back')), findsOneWidget);
    });
  });

  group('đổi kỳ', () {
    FakeHocTapApi twoPeriods() => FakeHocTapApi()
      ..insightsByDays = (d) => d == 7 ? _fix('card_insights_seeded_7') : (d == 30 ? _fix('card_insights_seeded') : _fix('card_insights_empty'));

    testWidgets('bấm 7 ngày rồi 90 ngày: tải lại đúng kỳ, số tổng đổi, nhóm tích luỹ giữ nguyên ở kỳ có dữ liệu', (tester) async {
      final api = twoPeriods();
      await _pump(tester, api: api);
      expect(_text(tester, 'tile-reviews-value'), '4');
      await tester.tap(find.text('7 ngày'));
      await tester.pumpAndSettle();
      expect(api.insightsCalls.map((c) => c.days), [30, 7]);
      expect(_text(tester, 'tile-reviews-value'), '3');
      expect(_text(tester, 'tile-notyet-value'), '33%');
      expect(_k('row-kind-IDIOM'), findsOneWidget, reason: 'nhóm là tích luỹ nên vẫn còn');
      expect(tester.widget<SegmentedButton<int>>(_k('insights-days')).selected, {7});
      await tester.tap(find.text('90 ngày'));
      await tester.pumpAndSettle();
      expect(api.insightsCalls.map((c) => c.days), [30, 7, 90]);
      expect(tester.widget<SegmentedButton<int>>(_k('insights-days')).selected, {90});
    });

    testWidgets('đang tải kỳ mới: GIỮ dữ liệu cũ (không nháy về trống), chỉ có thanh tải mảnh; tải xong thì thay', (tester) async {
      final api = twoPeriods();
      await _pump(tester, api: api);
      final gate = Completer<void>();
      api.insightsGate = gate;
      await tester.tap(find.text('7 ngày'));
      await tester.pump();
      expect(_k('insights-loading'), findsOneWidget);
      expect(_text(tester, 'tile-reviews-value'), '4', reason: 'vẫn hiện số của kỳ cũ');
      expect(_k('row-kind-IDIOM'), findsOneWidget);
      expect(_k('insights-empty'), findsNothing);
      expect(find.byType(CircularProgressIndicator), findsNothing);
      expect(tester.widget<SegmentedButton<int>>(_k('insights-days')).selected, {7}, reason: 'điều khiển đổi ngay');
      api.insightsGate = null;
      gate.complete();
      await tester.pumpAndSettle();
      expect(_k('insights-loading'), findsNothing);
      expect(_text(tester, 'tile-reviews-value'), '3');
    });

    testWidgets('bấm lại đúng kỳ đang chọn không gọi API thêm', (tester) async {
      final api = twoPeriods();
      await _pump(tester, api: api);
      await tester.tap(find.text('30 ngày'));
      await tester.pumpAndSettle();
      expect(api.insightsCalls.length, 1);
    });

    testWidgets('đổi kỳ liên tục: chỉ kết quả của lần bấm CUỐI được hiện (bỏ kết quả cũ về muộn)', (tester) async {
      final api = FakeHocTapApi();
      final slow = Completer<void>();
      await _pump(tester, api: api);
      api.insightsGate = slow;
      api.insightsByDays = (d) => d == 7 ? _fix('card_insights_seeded_7') : _fix('card_insights_empty');
      await tester.tap(find.text('7 ngày'));
      await tester.pump();
      api.insightsGate = null; // lần bấm sau trả ngay
      await tester.tap(find.text('90 ngày'));
      await tester.pumpAndSettle();
      expect(_text(tester, 'tile-reviews-value'), '0', reason: 'dữ liệu của 90 ngày');
      slow.complete(); // kết quả 7 ngày về muộn: không được ghi đè
      await tester.pumpAndSettle();
      expect(_text(tester, 'tile-reviews-value'), '0');
      expect(tester.widget<SegmentedButton<int>>(_k('insights-days')).selected, {90});
    });

    testWidgets('đổi kỳ gặp lỗi: báo lỗi + Thử lại (vẫn đổi được kỳ); thử lại thành công thì hiện dữ liệu', (tester) async {
      final api = twoPeriods();
      await _pump(tester, api: api);
      api.insightsError = apiError(500, {'error': 'x'});
      await tester.tap(find.text('7 ngày'));
      await tester.pumpAndSettle();
      expect(find.textContaining('Không tải được thống kê nhóm khó'), findsOneWidget);
      expect(_k('insights-days'), findsOneWidget);
      api.insightsError = null;
      await tester.tap(find.text('Thử lại'));
      await tester.pumpAndSettle();
      expect(find.textContaining('Không tải được'), findsNothing);
      expect(_text(tester, 'tile-reviews-value'), '3');
      expect(api.insightsCalls.last.days, 7);
    });
  });

  group('tải và lỗi', () {
    testWidgets('đang tải lần đầu: vòng quay và nút quay lại', (tester) async {
      final api = FakeHocTapApi()..insightsGate = Completer<void>();
      await _pump(tester, api: api, settle: false);
      await tester.pump();
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.byKey(const ValueKey('design-top-bar-back')), findsOneWidget);
      expect(_k('insights-copy'), findsNothing);
    });

    testWidgets('lỗi tải lần đầu: báo lỗi + Thử lại', (tester) async {
      final api = FakeHocTapApi()..insightsError = apiError(500, {'error': 'x'});
      await _pump(tester, api: api);
      expect(find.textContaining('Không tải được thống kê nhóm khó'), findsOneWidget);
      api.insightsError = null;
      await tester.tap(find.text('Thử lại'));
      await tester.pumpAndSettle();
      expect(_k('tile-reviews'), findsOneWidget);
    });
  });

  group('Sao chép cho Claude phân tích', () {
    Future<String?> copy(WidgetTester tester, FakeHocTapApi api) async {
      String? copied;
      tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(SystemChannels.platform, (call) async {
        if (call.method == 'Clipboard.setData') copied = (call.arguments as Map)['text'] as String;
        return null;
      });
      addTearDown(() => tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(SystemChannels.platform, null));
      await _pump(tester, api: api);
      await tester.tap(_k('insights-copy'));
      await tester.pumpAndSettle();
      return copied;
    }

    testWidgets('có nhóm và thẻ hay quên: nút bật, chép đúng lời nhắc (kỳ, số liệu, chủ đề của môn), báo đã chép', (tester) async {
      final api = FakeHocTapApi();
      final text = await copy(tester, api);
      expect(find.text('Đã sao chép cho Claude'), findsOneWidget);
      expect(text, buildInsightsPrompt(insights: _fix('card_insights_seeded'), topics: ['work', 'daily life']));
      expect(text, contains('(last 30 days)'));
      expect(text, contains('- idiom: 10/12 cards ever not remembered (83%)'));
      expect(text, contains('"idiom phrase 0" - not remembered 5 times'));
      expect(text, contains('Topics I already use: work, daily life.'));
    });

    testWidgets('chép theo kỳ đang chọn (7 ngày) với số liệu của kỳ đó', (tester) async {
      final api = FakeHocTapApi()..insightsByDays = (d) => d == 7 ? _fix('card_insights_seeded_7') : _fix('card_insights_seeded');
      String? copied;
      tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(SystemChannels.platform, (call) async {
        if (call.method == 'Clipboard.setData') copied = (call.arguments as Map)['text'] as String;
        return null;
      });
      addTearDown(() => tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(SystemChannels.platform, null));
      await _pump(tester, api: api);
      await tester.tap(find.text('7 ngày'));
      await tester.pumpAndSettle();
      await tester.tap(_k('insights-copy'));
      await tester.pumpAndSettle();
      expect(copied, contains('(last 7 days)'));
      expect(copied, contains('- Reviews: 3'));
    });

    testWidgets('môn chưa có chủ đề → "none yet"; tải chủ đề lỗi vẫn chép được', (tester) async {
      expect(await copy(tester, FakeHocTapApi()..topics = const []), contains('Topics I already use: none yet.'));
      expect(await copy(tester, FakeHocTapApi()..topicsError = apiError(500, {'error': 'x'})), contains('Topics I already use: none yet.'));
    });

    testWidgets('chỉ có nhóm (không có thẻ hay quên): vẫn bật', (tester) async {
      await _pump(tester, api: FakeHocTapApi()..cardInsights = _fix('card_insights_partial'));
      expect(tester.widget<FilledButton>(_k('insights-copy')).onPressed, isNotNull);
      expect(_k('insights-copy-hint'), findsNothing);
    });

    testWidgets('không có nhóm và không có thẻ hay quên: nút KHÓA kèm dòng giải thích ngắn', (tester) async {
      await _pump(tester, api: FakeHocTapApi()..cardInsights = _fix('card_insights_empty'));
      expect(tester.widget<FilledButton>(_k('insights-copy')).onPressed, isNull);
      expect(_text(tester, 'insights-copy-hint'), 'Chưa có nhóm khó hay thẻ hay quên để phân tích.');
    });

    testWidgets('chỉ có thẻ hay quên (chưa có nhóm nào): vẫn bật', (tester) async {
      await _pump(tester, api: FakeHocTapApi()..cardInsights = const CardInsights(hardestCards: [HardCard(id: 'h', phrase: 'a b', kind: CardKind.idiom, notYetCount: 3)]));
      expect(tester.widget<FilledButton>(_k('insights-copy')).onPressed, isNotNull);
    });

    testWidgets('khoá trong lúc đang tải kỳ mới', (tester) async {
      final api = FakeHocTapApi();
      await _pump(tester, api: api);
      api.insightsGate = Completer<void>();
      await tester.tap(find.text('7 ngày'));
      await tester.pump();
      expect(tester.widget<FilledButton>(_k('insights-copy')).onPressed, isNull);
      expect(_k('insights-copy-hint'), findsNothing, reason: 'đang tải thì không hiện câu "chưa có nhóm"');
    });
  });

  group('không tràn ở 320 px, chữ x2.0', () {
    for (final name in ['card_insights_seeded', 'card_insights_empty', 'card_insights_partial']) {
      testWidgets(name, (tester) async {
        tester.platformDispatcher.textScaleFactorTestValue = 2.0;
        addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
        await _pump(tester, api: FakeHocTapApi()..cardInsights = _fix(name), width: 320);
        expect(tester.takeException(), isNull);
        // điều khiển kỳ cuộn ngang được, không bị cắt
        expect(tester.widget<SingleChildScrollView>(find.ancestor(of: _k('insights-days'), matching: find.byType(SingleChildScrollView)).first).scrollDirection, Axis.horizontal);
        await tester.drag(find.byType(Scrollable).first, const Offset(0, -3000));
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull, reason: 'cuối trang');
      });
    }

    testWidgets('nhãn dài (chủ đề / buổi học dài) và thẻ có cụm dài xuống dòng, không tràn', (tester) async {
      tester.platformDispatcher.textScaleFactorTestValue = 2.0;
      addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
      final api = FakeHocTapApi()
        ..cardInsights = CardInsights(
          byTopic: const [InsightGroup(key: 'a', label: 'một chủ đề có tên rất dài để thử việc xuống dòng', totalCards: 120, everNotYetCards: 111, rate: 0.925)],
          byLesson: const [InsightGroup(key: 'l', label: '04/11 · Một khóa học tiếng Anh với cái tên cực kỳ dài dòng', totalCards: 1200, everNotYetCards: 1100, rate: 0.9167)],
          hardestCards: const [HardCard(id: 'h', phrase: 'a very long phrase that keeps going and going', kind: CardKind.idiom, notYetCount: 1234)],
        );
      await _pump(tester, api: api, width: 320);
      expect(tester.takeException(), isNull);
    });
  });

  testWidgets('không có subjectId: màn tự dùng môn đầu tiên của Tổng quan', (tester) async {
    final api = FakeHocTapApi();
    await pumpHocTap(tester, const CardInsightsScreen(), api: api);
    expect(api.insightsCalls.single.subjectId, api.overview.subjects.first.subjectId, reason: 'mặc định môn đầu tiên của Tổng quan');
  });
}

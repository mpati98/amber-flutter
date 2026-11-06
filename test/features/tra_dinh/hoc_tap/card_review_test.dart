import 'dart:async';

import 'package:amber_flutter/features/tra_dinh/hoc_tap/models/study_card.dart';
import 'package:amber_flutter/features/tra_dinh/hoc_tap/models/study_card_queue.dart';
import 'package:amber_flutter/features/tra_dinh/hoc_tap/providers/card_review_provider.dart';
import 'package:amber_flutter/features/tra_dinh/hoc_tap/screens/card_review_screen.dart';
import 'package:amber_flutter/shared/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:flutter_test/flutter_test.dart';

import 'hoc_tap_test_support.dart';
import 'hoc_tap_widget_support.dart';

// Màn Ôn thẻ: mặt trước / mặt sau, nút đánh giá, chờ thẻ quay lại, kết thúc phiên và nhập số phút.

const _sid = 'subject-1';
Finder _k(String key) => find.byKey(ValueKey(key));

// Bây giờ cố định: 14:00 giờ VN thứ Sáu 06/11/2026.
final _now = DateTime.parse('2026-11-06T14:00:00+07:00');

class _Clock {
  _Clock(this.now);

  DateTime now;
}

QueueCard _qc(
  String id,
  String phrase,
  String example, {
  String meaning = 'nghĩa tiếng Anh',
  CardKind kind = CardKind.phrasalVerb,
  List<String> topics = const [],
  String? note,
  CardStage stage = CardStage.newCard,
  DateTime? dueAt,
  CardBucket bucket = CardBucket.newCard,
  Map<CardRating, NextSchedule>? next,
}) => QueueCard(
  card: StudyCard(id: id, subjectId: _sid, phrase: phrase, meaning: meaning, example: example, kind: kind, topics: topics, note: note, stage: stage, dueAt: dueAt),
  bucket: bucket,
  next:
      next ??
      {
        CardRating.notYet: NextSchedule(stage: CardStage.learning, dueAt: _now.add(const Duration(minutes: 5))),
        CardRating.reviewAgain: NextSchedule(stage: CardStage.learning, dueAt: DateTime.parse('2026-11-07T00:00:00+07:00')),
        CardRating.remembered: NextSchedule(stage: CardStage.weekly, dueAt: DateTime.parse('2026-11-08T00:00:00+07:00')),
      },
);

CardQueue _queue(List<QueueCard> cards, {int? planned, int finished = 0, DateTime? soonest}) {
  final p = planned ?? cards.length;
  return CardQueue(
    date: '2026-11-06',
    cards: cards,
    progress: CardProgress(
      planned: p,
      finished: finished,
      remaining: p - finished,
      byBucket: {
        CardBucket.due: BucketProgress(planned: cards.where((c) => c.bucket == CardBucket.due).length),
        CardBucket.newCard: BucketProgress(planned: cards.where((c) => c.bucket == CardBucket.newCard).length),
        CardBucket.hard: BucketProgress(planned: cards.where((c) => c.bucket == CardBucket.hard).length),
        CardBucket.random: BucketProgress(planned: cards.where((c) => c.bucket == CardBucket.random).length),
      },
    ),
    soonestDueAt: soonest,
  );
}

Future<_Clock> _pump(WidgetTester tester, FakeHocTapApi api, {double width = 390, double height = 800, bool settle = true, List<Override> overrides = const []}) async {
  final clock = _Clock(_now);
  await pumpHocTap(
    tester,
    const CardReviewScreen(subjectId: _sid),
    api: api,
    width: width,
    height: height,
    settle: settle,
    overrides: [cardReviewClockProvider.overrideWithValue(() => clock.now), ...overrides],
  );
  return clock;
}

/// Nút OutlinedButton bên trong ô đánh giá có key [key].
OutlinedButton _btn(WidgetTester tester, String key) => tester.widget<OutlinedButton>(find.descendant(of: _k(key), matching: find.byType(OutlinedButton)));

String _plain(WidgetTester tester, String key) => tester.widget<Text>(_k(key)).textSpan!.toPlainText();

List<InlineSpan> _children(WidgetTester tester, String key) => ((tester.widget<Text>(_k(key)).textSpan!) as TextSpan).children!;

final _fixtureCard = _qc('c1', 'look forward to', 'I look forward to meeting you next week.', meaning: 'to be excited about something in the future', topics: ['daily life', 'work'], note: 'followed by V-ing');

void main() {
  group('mặt trước', () {
    testWidgets('tiêu đề, "đã ôn / kế hoạch", thanh tiến độ mảnh, ba chip đếm, nhãn, câu có chỗ trống gạch chân, gợi ý, nút Hiện đáp án', (tester) async {
      final api = FakeHocTapApi()..cardQueue = _queue([_fixtureCard, _qc('c2', 'break the ice', 'A joke can break the ice.', bucket: CardBucket.due), _qc('c3', 'pick up on', 'She picks up on moods.', bucket: CardBucket.random)], planned: 5, finished: 2);
      await _pump(tester, api);
      expect(find.byType(BackButton), findsOneWidget);
      expect(find.text('Ôn thẻ'), findsOneWidget);
      expect(tester.widget<Text>(_k('review-count')).data, '2 / 5');
      expect(tester.widget<LinearProgressIndicator>(_k('review-progress')).value, closeTo(0.4, 1e-9));
      expect(tester.widget<LinearProgressIndicator>(_k('review-progress')).minHeight, lessThanOrEqualTo(4));
      expect(tester.widget<Text>(find.descendant(of: _k('chip-due'), matching: find.byType(Text))).data, 'Đến hạn 1');
      expect(find.text('Mới 1'), findsOneWidget);
      expect(find.text('Ôn thêm 1'), findsOneWidget, reason: 'Ôn thêm = HARD + RANDOM');

      final label = tester.widget<Text>(_k('review-label'));
      expect(label.data, 'ĐIỀN CỤM TỪ CÒN THIẾU');
      expect(label.style!.color, ThemeData.dark().colorScheme.primary, reason: 'nhãn màu primary của theme');
      final example = _plain(tester, 'review-example');
      expect(example, isNot(contains('look forward to')), reason: 'cụm bị che');
      expect(example, startsWith('I '));
      expect(example, endsWith(' meeting you next week.'));
      final blank = _children(tester, 'review-example').whereType<TextSpan>().firstWhere((s) => s.style?.decoration == TextDecoration.underline);
      expect(blank.text, matches(RegExp('^ +\$')), reason: 'chỗ trống là khoảng trắng không ngắt có gạch chân');
      final hint = tester.widget<Text>(_k('review-hint'));
      expect(hint.data, 'Gợi ý: to be excited about something in the future');
      expect(hint.style!.color, ThemeData.dark().colorScheme.secondary, reason: 'gợi ý màu secondary');
      expect(find.text('Hiện đáp án'), findsOneWidget);
      expect(find.text('Chưa nhớ'), findsNothing, reason: 'nút đánh giá chỉ có ở mặt sau');
      expect(_k('review-phrase'), findsNothing);
    });

    testWidgets('khớp theo thân từ: "looking forward to" vẫn được che', (tester) async {
      final api = FakeHocTapApi()..cardQueue = _queue([_qc('c1', 'look forward to', 'She is looking forward to the trip.')]);
      await _pump(tester, api);
      expect(_plain(tester, 'review-example'), isNot(contains('looking')));
      expect(_plain(tester, 'review-example'), startsWith('She is '));
      expect(_k('review-hint'), findsOneWidget);
    });

    testWidgets('không tìm thấy cụm trong câu: KHÔNG hiện câu ví dụ, chỉ "NHỚ LẠI CỤM TỪ CÓ NGHĨA:" + nghĩa; câu hiện ở mặt sau', (tester) async {
      final api = FakeHocTapApi()..cardQueue = _queue([_qc('c1', 'be about to + V', 'She is on the verge of leaving.', meaning: 'going to do something very soon')]);
      await _pump(tester, api);
      expect(tester.widget<Text>(_k('review-label')).data, 'NHỚ LẠI CỤM TỪ CÓ NGHĨA:');
      expect(tester.widget<Text>(_k('review-meaning')).data, 'going to do something very soon');
      expect(_k('review-example'), findsNothing);
      expect(find.textContaining('on the verge'), findsNothing, reason: 'câu ví dụ không lộ ở mặt trước');
      expect(_k('review-hint'), findsNothing);
      await tester.tap(_k('review-show-answer'));
      await tester.pumpAndSettle();
      expect(_plain(tester, 'review-answer-example'), 'She is on the verge of leaving.');
      expect(tester.widget<Text>(_k('review-phrase')).data, 'be about to + V');
    });
  });

  group('mặt sau', () {
    testWidgets('cụm lớn đậm màu primary, câu đầy đủ có cụm in đậm, nghĩa màu secondary, rồi loại / chủ đề / ghi chú', (tester) async {
      final api = FakeHocTapApi()..cardQueue = _queue([_fixtureCard]);
      await _pump(tester, api);
      await tester.tap(_k('review-show-answer'));
      await tester.pumpAndSettle();
      final scheme = ThemeData.dark().colorScheme;
      final phrase = tester.widget<Text>(_k('review-phrase'));
      expect(phrase.data, 'look forward to');
      expect(phrase.style!.fontSize, greaterThanOrEqualTo(26));
      expect(phrase.style!.fontWeight, FontWeight.w700);
      expect(phrase.style!.color, scheme.primary);
      expect(_plain(tester, 'review-answer-example'), 'I look forward to meeting you next week.');
      final bold = _children(tester, 'review-answer-example').whereType<TextSpan>().where((s) => s.style?.fontWeight == FontWeight.w700).toList();
      expect(bold.map((s) => s.text), ['look forward to'], reason: 'chỉ cụm tìm thấy được in đậm');
      expect(tester.widget<Text>(_k('review-answer-meaning')).style!.color, scheme.secondary);
      expect(find.byType(Divider), findsWidgets);
      expect(find.text('Cụm động từ'), findsOneWidget);
      expect(find.text('daily life'), findsOneWidget);
      expect(find.text('work'), findsOneWidget);
      expect(tester.widget<Text>(_k('review-note')).data, 'followed by V-ing');
      expect(_k('review-show-answer'), findsNothing);
      expect(find.text('Chưa nhớ'), findsOneWidget);
      expect(find.text('Cần ôn lại'), findsOneWidget);
      expect(find.text('Đã nhớ'), findsOneWidget);
    });

    testWidgets('không có ghi chú / chủ đề thì không hiện', (tester) async {
      final api = FakeHocTapApi()..cardQueue = _queue([_qc('c1', 'break the ice', 'A joke can break the ice.', kind: CardKind.idiom)]);
      await _pump(tester, api);
      await tester.tap(_k('review-show-answer'));
      await tester.pumpAndSettle();
      expect(_k('review-note'), findsNothing);
      expect(find.text('Thành ngữ'), findsOneWidget);
    });

    testWidgets('ba nút bằng nhau (cùng bề rộng), cao ít nhất 72, màu: đỏ / hổ phách / success', (tester) async {
      final api = FakeHocTapApi()..cardQueue = _queue([_fixtureCard]);
      await _pump(tester, api);
      await tester.tap(_k('review-show-answer'));
      await tester.pumpAndSettle();
      final sizes = [for (final k in ['rate-notYet', 'rate-reviewAgain', 'rate-remembered']) tester.getSize(_k(k))];
      expect(sizes.map((s) => s.width.round()).toSet().length, 1, reason: 'ba nút rộng bằng nhau');
      expect(sizes.every((s) => s.height >= 72), isTrue);
      expect(sizes.map((s) => s.height).toSet().length, 1, reason: 'cao bằng nhau');
      Color fg(String key) => _btn(tester, key).style!.foregroundColor!.resolve({})!;
      final theme = ThemeData.dark();
      expect(fg('rate-notYet'), theme.colorScheme.error);
      expect(fg('rate-remembered'), theme.success, reason: 'màu success của theme (không phải token)');
      expect(fg('rate-reviewAgain'), isNot(anyOf(theme.colorScheme.error, theme.success)));
    });

    testWidgets('dòng nhỏ dưới nút lấy từ next: "5 phút" / "Ngày mai" / "CN 08/11"', (tester) async {
      final api = FakeHocTapApi()..cardQueue = _queue([_fixtureCard]);
      await _pump(tester, api);
      await tester.tap(_k('review-show-answer'));
      await tester.pumpAndSettle();
      expect(tester.widget<Text>(_k('sub-notYet')).data, '5 phút');
      expect(tester.widget<Text>(_k('sub-reviewAgain')).data, 'Ngày mai');
      expect(tester.widget<Text>(_k('sub-remembered')).data, 'CN 08/11');
    });

    testWidgets('thẻ ôn thêm (HARD): Đã nhớ giữ nguyên lịch → "Giữ lịch" (dữ liệu thật của backend dev)', (tester) async {
      final q = CardQueue.fromJson(fixtureMap('card_queue_buckets'));
      final hard = q.cards.firstWhere((c) => c.bucket == CardBucket.hard);
      final api = FakeHocTapApi()..cardQueue = CardQueue(date: q.date, cards: [hard], progress: q.progress);
      await _pump(tester, api);
      await tester.tap(_k('review-show-answer'));
      await tester.pumpAndSettle();
      expect(tester.widget<Text>(_k('sub-remembered')).data, 'Giữ lịch');
      expect(tester.widget<Text>(_k('sub-notYet')).data, isNot('Giữ lịch'));
    });

    testWidgets('thẻ đến hạn / mới: Đã nhớ tiến lên, nhãn là ngày thật, không phải "Giữ lịch"', (tester) async {
      final q = CardQueue.fromJson(fixtureMap('card_queue_buckets'));
      final due = q.cards.firstWhere((c) => c.bucket == CardBucket.due);
      final api = FakeHocTapApi()..cardQueue = CardQueue(date: q.date, cards: [due], progress: q.progress);
      await _pump(tester, api);
      await tester.tap(_k('review-show-answer'));
      await tester.pumpAndSettle();
      expect(tester.widget<Text>(_k('sub-remembered')).data, matches(RegExp(r'^(Tháng \d+|CN \d{2}/\d{2}|T[2-7] \d{2}/\d{2})$')));
    });
  });

  group('đánh giá', () {
    testWidgets('bấm "Đã nhớ": khoá cả ba nút trong lúc gọi, xong thì sang thẻ kế ở mặt trước, tiến độ và chip cập nhật', (tester) async {
      final gate = Completer<void>();
      final api = FakeHocTapApi()
        ..reviewGate = gate
        ..cardQueue = _queue([_qc('c1', 'look forward to', 'I look forward to it.'), _qc('c2', 'break the ice', 'A joke can break the ice.'), _qc('c3', 'pick up on', 'She picks up on moods.')]);
      await _pump(tester, api);
      await tester.tap(_k('review-show-answer'));
      await tester.pumpAndSettle();
      await tester.tap(_k('rate-remembered'));
      await tester.pump();
      for (final k in ['rate-notYet', 'rate-reviewAgain', 'rate-remembered']) {
        expect(_btn(tester, k).onPressed, isNull, reason: '$k bị khoá khi đang gọi');
      }
      await tester.tap(_k('rate-notYet'), warnIfMissed: false);
      await tester.pump();
      expect(api.reviewCalls.length, 1, reason: 'bấm lúc đang gọi không gửi thêm');
      gate.complete();
      await tester.pumpAndSettle();
      expect(api.reviewCalls.single, (id: 'c1', rating: CardRating.remembered));
      expect(_k('review-show-answer'), findsOneWidget, reason: 'thẻ kế bắt đầu từ mặt trước');
      expect(tester.widget<Text>(_k('review-count')).data, '1 / 3');
      expect(find.text('Mới 2'), findsOneWidget);
    });

    testWidgets('lỗi mạng: giữ thẻ ở mặt sau, báo lỗi, ba nút mở lại để bấm tiếp', (tester) async {
      final api = FakeHocTapApi()
        ..reviewError = Exception('mất mạng')
        ..cardQueue = _queue([_qc('c1', 'look forward to', 'I look forward to it.'), _qc('c2', 'break the ice', 'A joke can break the ice.')]);
      await _pump(tester, api);
      await tester.tap(_k('review-show-answer'));
      await tester.pumpAndSettle();
      await tester.tap(_k('rate-remembered'));
      await tester.pumpAndSettle();
      expect(find.text('Có lỗi, thử lại'), findsOneWidget);
      expect(_k('review-phrase'), findsOneWidget);
      expect(tester.widget<Text>(_k('review-phrase')).data, 'look forward to');
      expect(_btn(tester, 'rate-remembered').onPressed, isNotNull);
      api.reviewError = null;
      await tester.tap(_k('rate-remembered'));
      await tester.pumpAndSettle();
      expect(tester.widget<Text>(_k('review-count')).data, '1 / 2');
    });

    testWidgets('409 already_finished_today: báo ngắn tiếng Việt và tải lại hàng ôn', (tester) async {
      final api = FakeHocTapApi()
        ..reviewError = apiError(409, {'error': 'already_finished_today'})
        ..cardQueue = _queue([_qc('c1', 'look forward to', 'I look forward to it.'), _qc('c2', 'break the ice', 'A joke can break the ice.')]);
      await _pump(tester, api);
      await tester.tap(_k('review-show-answer'));
      await tester.pumpAndSettle();
      api.cardQueue = _queue([_qc('c2', 'break the ice', 'A joke can break the ice.')], planned: 2, finished: 1);
      await tester.tap(_k('rate-remembered'));
      await tester.pumpAndSettle();
      expect(find.text('Thẻ này đã ôn xong hôm nay'), findsOneWidget);
      expect(api.queueCalls.length, 2, reason: 'đã tải lại hàng ôn');
      expect(_k('review-show-answer'), findsOneWidget, reason: 'sang thẻ còn lại, mặt trước');
      expect(tester.widget<Text>(_k('review-count')).data, '1 / 2');
    });
  });

  group('chờ thẻ quay lại', () {
    testWidgets('hết thẻ hiện ngay mà còn thẻ "Chưa nhớ": "N thẻ quay lại sau X phút" + đếm ngược chạy từng giây', (tester) async {
      final api = FakeHocTapApi()..cardQueue = _queue(const [], planned: 3, finished: 1, soonest: _now.add(const Duration(minutes: 5)));
      final clock = await _pump(tester, api);
      expect(find.byType(BackButton), findsOneWidget);
      expect(tester.widget<Text>(_k('review-waiting-title')).data, '2 thẻ quay lại sau 5 phút');
      expect(tester.widget<Text>(_k('review-countdown')).data, '5:00');
      expect(tester.widget<Text>(_k('review-count')).data, '1 / 3');
      clock.now = _now.add(const Duration(seconds: 1));
      await tester.pump(const Duration(seconds: 1));
      expect(tester.widget<Text>(_k('review-countdown')).data, '4:59');
      clock.now = _now.add(const Duration(minutes: 2, seconds: 30));
      await tester.pump(const Duration(seconds: 1));
      expect(tester.widget<Text>(_k('review-countdown')).data, '2:30');
      expect(tester.widget<Text>(_k('review-waiting-title')).data, '2 thẻ quay lại sau 3 phút', reason: 'làm tròn lên');
      expect(api.queueCalls.length, 1, reason: 'chưa tới giờ thì chưa tải lại');
    });

    testWidgets('tới giờ: tự tải lại hàng ôn, thẻ quay lại hiện ở mặt trước', (tester) async {
      final soon = _now.add(const Duration(minutes: 5));
      final api = FakeHocTapApi()..cardQueue = _queue(const [], planned: 1, soonest: soon);
      final clock = await _pump(tester, api);
      expect(api.queueCalls.length, 1);
      api.cardQueue = _queue([_qc('c1', 'look forward to', 'I look forward to it.')], planned: 1);
      clock.now = soon.add(const Duration(seconds: 1));
      await tester.pump(const Duration(seconds: 1));
      await tester.pumpAndSettle();
      expect(api.queueCalls.length, 2, reason: 'tự tải lại khi tới giờ');
      expect(_k('review-show-answer'), findsOneWidget);
      expect(_k('review-waiting'), findsNothing);
    });

    testWidgets('server chưa coi là đến hạn (lệch đồng hồ): thử lại thưa, không dồn dập mỗi giây', (tester) async {
      final soon = _now.add(const Duration(minutes: 5));
      final api = FakeHocTapApi()..cardQueue = _queue(const [], planned: 1, soonest: soon);
      final clock = await _pump(tester, api);
      clock.now = soon.add(const Duration(seconds: 1));
      for (var i = 0; i < 4; i++) {
        await tester.pump(const Duration(seconds: 1));
        clock.now = clock.now.add(const Duration(seconds: 1));
      }
      expect(api.queueCalls.length, 2, reason: 'một lần tải lại trong 5 giây đầu');
      clock.now = clock.now.add(const Duration(seconds: 6));
      await tester.pump(const Duration(seconds: 1));
      expect(api.queueCalls.length, 3, reason: 'thử lại sau 5 giây');
    });

    testWidgets('"Kết thúc phiên" → màn kết thúc', (tester) async {
      final api = FakeHocTapApi()..cardQueue = _queue(const [], planned: 3, finished: 1, soonest: _now.add(const Duration(minutes: 5)));
      await _pump(tester, api);
      await tester.tap(_k('review-finish'));
      await tester.pumpAndSettle();
      expect(find.text('Xong phiên ôn'), findsOneWidget);
      // Phiên này chưa đánh giá thẻ nào (1 thẻ đã xong từ trước): không có số liệu phiên để báo.
      expect(tester.widget<Text>(_k('end-title')).data, 'Hôm nay đã ôn xong');
      expect(_k('end-chip-notYet'), findsNothing);
    });
  });

  group('hàng rỗng và lỗi', () {
    testWidgets('không có thẻ nào trong kế hoạch: "Hôm nay chưa có thẻ cần ôn" + mở kho thẻ; có nút quay lại', (tester) async {
      final api = FakeHocTapApi()..cardQueue = CardQueue.fromJson(fixtureMap('card_queue_empty'));
      await _pump(tester, api);
      expect(find.text('Hôm nay chưa có thẻ cần ôn'), findsOneWidget);
      expect(find.byType(BackButton), findsOneWidget);
      await tester.tap(_k('review-empty-library'));
      await tester.pumpAndSettle();
      expect(visited.last, '/tra-dinh/hoc-tap/the?subjectId=$_sid');
    });

    testWidgets('lỗi tải hàng ôn: báo lỗi + Thử lại', (tester) async {
      final api = FakeHocTapApi()..queueError = apiError(500, {'error': 'x'});
      await _pump(tester, api);
      expect(find.textContaining('Không tải được hàng ôn thẻ'), findsOneWidget);
      expect(find.byType(BackButton), findsOneWidget);
      api.queueError = null;
      await tester.tap(find.text('Thử lại'));
      await tester.pumpAndSettle();
      expect(_k('review-show-answer'), findsOneWidget);
    });

    testWidgets('đang tải: vòng quay và nút quay lại', (tester) async {
      final gate = Completer<void>();
      final api = FakeHocTapApi()..queueGate = gate;
      await _pump(tester, api, settle: false);
      await tester.pump();
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.byType(BackButton), findsOneWidget);
      gate.complete();
      await tester.pumpAndSettle();
      expect(_k('review-show-answer'), findsOneWidget);
    });
  });

  group('không tràn, chữ phóng to', () {
    for (final (scale, width) in [(1.0, 320.0), (1.6, 390.0), (2.0, 320.0)]) {
      testWidgets('mặt trước, mặt sau và màn chờ ở bề rộng $width, chữ x$scale', (tester) async {
        tester.platformDispatcher.textScaleFactorTestValue = scale;
        addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
        final api = FakeHocTapApi()..cardQueue = _queue([_fixtureCard, _qc('c2', 'break the ice', 'A joke can break the ice.')]);
        await _pump(tester, api, width: width);
        expect(tester.takeException(), isNull, reason: 'mặt trước');
        await tester.tap(_k('review-show-answer'));
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull, reason: 'mặt sau');
        expect(tester.getSize(_k('rate-notYet')).height, greaterThanOrEqualTo(72));
        expect(tester.getTopRight(_k('rate-remembered')).dx, lessThanOrEqualTo(width));
        api.cardQueue = _queue(const [], planned: 2, soonest: _now.add(const Duration(minutes: 5)));
        await tester.tap(_k('rate-remembered'));
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull, reason: 'sau khi đánh giá');
      });
    }
  });

  testWidgets('ôn hết thẻ rồi sang màn kết thúc: tổng kết đúng số liệu của phiên', (tester) async {
    final api = FakeHocTapApi()..cardQueue = _queue([_qc('c1', 'look forward to', 'I look forward to it.'), _qc('c2', 'break the ice', 'A joke can break the ice.'), _qc('c3', 'pick up on', 'She picks up on moods.')]);
    await _pump(tester, api);
    for (final r in ['rate-remembered', 'rate-reviewAgain', 'rate-remembered']) {
      await tester.tap(_k('review-show-answer'));
      await tester.pumpAndSettle();
      await tester.tap(_k(r));
      await tester.pumpAndSettle();
    }
    expect(find.text('Xong phiên ôn'), findsOneWidget);
    expect(tester.widget<Text>(_k('end-title')).data, 'Hôm nay đã ôn 3 / 3 thẻ');
    expect(find.text('Chưa nhớ 0'), findsOneWidget);
    expect(find.text('Cần ôn lại 1'), findsOneWidget);
    expect(find.text('Đã nhớ 2'), findsOneWidget);
  });
}

import 'dart:async';

import 'package:amber_flutter/features/tra_dinh/hoc_tap/models/study_card_queue.dart';
import 'package:amber_flutter/features/tra_dinh/hoc_tap/providers/card_review_provider.dart';
import 'package:amber_flutter/features/tra_dinh/hoc_tap/services/hoc_tap_api.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'hoc_tap_test_support.dart';

// Logic của phiên ôn thẻ (không có widget): API giả dùng JSON thật của backend dev (card_queue*.json).

const _sid = 'subject-1';

({ProviderContainer c, FakeHocTapApi api}) _setup([FakeHocTapApi? fake]) {
  final api = fake ?? FakeHocTapApi();
  final c = ProviderContainer(overrides: [hocTapApiProvider.overrideWithValue(api)]);
  addTearDown(c.dispose);
  c.listen(cardReviewProvider(_sid), (_, _) {}); // autoDispose: giữ sống suốt test
  return (c: c, api: api);
}

CardReviewNotifier _n(ProviderContainer c) => c.read(cardReviewProvider(_sid).notifier);
CardReviewState _s(ProviderContainer c) => c.read(cardReviewProvider(_sid));

void main() {
  test('mở màn: tải hàng ôn → mặt trước của thẻ đầu, tiến độ từ server', () async {
    final t = _setup();
    expect(_s(t.c).phase, ReviewPhase.loading);
    await pumpEventQueue();
    final s = _s(t.c);
    expect(s.phase, ReviewPhase.question);
    expect(s.queue.length, 3);
    expect(s.current!.card.phrase, isNotEmpty);
    expect((s.progress.planned, s.progress.finished, s.progress.remaining), (3, 0, 3));
    expect(s.soonestDueAt, isNull);
    expect(t.api.queueCalls, [_sid]);
  });

  test('Hiện đáp án → mặt sau; chỉ chuyển khi đang ở mặt trước', () async {
    final t = _setup();
    await pumpEventQueue();
    _n(t.c).showAnswer();
    expect(_s(t.c).phase, ReviewPhase.answer);
    _n(t.c).showAnswer();
    expect(_s(t.c).phase, ReviewPhase.answer);
  });

  test('đánh giá thành công: bỏ thẻ khỏi hàng, cập nhật tiến độ, sang thẻ kế ở MẶT TRƯỚC', () async {
    final t = _setup();
    await pumpEventQueue();
    final first = _s(t.c).current!;
    _n(t.c).showAnswer();
    await _n(t.c).rate(CardRating.remembered);
    final s = _s(t.c);
    expect(t.api.reviewCalls, [(id: first.id, rating: CardRating.remembered)]);
    expect(s.queue.length, 2);
    expect(s.queue.any((c) => c.id == first.id), isFalse);
    expect(s.phase, ReviewPhase.question, reason: 'thẻ kế bắt đầu từ mặt trước');
    expect((s.progress.finished, s.progress.remaining), (1, 2));
    expect((s.remembered, s.again, s.notYet), (1, 0, 0));
    expect(s.busy, isFalse);
  });

  test('khoá nút trong lúc gọi API: lần bấm thứ hai bị bỏ qua, không gọi hai lần', () async {
    final gate = Completer<void>();
    final t = _setup(FakeHocTapApi()..reviewGate = gate);
    await pumpEventQueue();
    _n(t.c).showAnswer();
    final first = _n(t.c).rate(CardRating.remembered);
    await pumpEventQueue();
    expect(_s(t.c).busy, isTrue);
    await _n(t.c).rate(CardRating.notYet); // bấm đúp khi đang gọi
    expect(t.api.reviewCalls.length, 1);
    gate.complete();
    await first;
    expect(_s(t.c).busy, isFalse);
    expect(t.api.reviewCalls.length, 1);
    expect(_s(t.c).remembered, 1);
  });

  test('rate chỉ chạy ở mặt sau: ở mặt trước thì bỏ qua', () async {
    final t = _setup();
    await pumpEventQueue();
    await _n(t.c).rate(CardRating.remembered);
    expect(t.api.reviewCalls, isEmpty);
  });

  test('NOT_YET: thẻ ra khỏi hàng; hết thẻ thì chuyển sang chờ với soonestDueAt; đồng hồ đếm ngược tính từ đó', () async {
    final t = _setup();
    await pumpEventQueue();
    for (var i = 0; i < 3; i++) {
      _n(t.c).showAnswer();
      await _n(t.c).rate(CardRating.notYet);
    }
    final s = _s(t.c);
    expect(s.phase, ReviewPhase.waiting);
    expect(s.queue, isEmpty);
    expect(s.soonestDueAt, isNotNull);
    final left = s.soonestDueAt!.difference(DateTime.now());
    expect(left.inMinutes, inInclusiveRange(4, 5), reason: 'quay lại sau 5 phút');
    expect(s.notYet, 3);
    expect(s.progress.finished, 0, reason: 'NOT_YET chưa tính là xong');
    expect(s.waitingCount, 3, reason: 'cả 3 thẻ đang đợi quay lại');
  });

  test('NOT_YET một thẻ trong hàng 3 thẻ: vẫn còn thẻ để ôn (không vào chờ)', () async {
    final t = _setup();
    await pumpEventQueue();
    _n(t.c).showAnswer();
    await _n(t.c).rate(CardRating.notYet);
    expect(_s(t.c).phase, ReviewPhase.question);
    expect(_s(t.c).soonestDueAt, isNotNull);
    expect(_s(t.c).waitingCount, 1);
  });

  test('chờ → tới giờ: tải lại hàng, thẻ quay lại ở mặt trước', () async {
    final t = _setup();
    await pumpEventQueue();
    for (var i = 0; i < 3; i++) {
      _n(t.c).showAnswer();
      await _n(t.c).rate(CardRating.notYet);
    }
    expect(_s(t.c).phase, ReviewPhase.waiting);
    // Server: thẻ đã đến hạn quay lại → có trong hàng; hết thẻ đợi.
    final back = CardQueue.fromJson(fixtureMap('card_queue'));
    t.api.cardQueue = CardQueue(date: back.date, cards: [back.cards.first], progress: const CardProgress(planned: 3, finished: 2, remaining: 1));
    await _n(t.c).load(quiet: true);
    expect(_s(t.c).phase, ReviewPhase.question);
    expect(_s(t.c).queue.length, 1);
    expect(_s(t.c).soonestDueAt, isNull);
    expect(_s(t.c).notYet, 3, reason: 'số liệu của phiên giữ nguyên qua lần tải lại');
  });

  test('"Kết thúc phiên" ở màn chờ → màn kết thúc, giữ số liệu', () async {
    final t = _setup();
    await pumpEventQueue();
    for (var i = 0; i < 3; i++) {
      _n(t.c).showAnswer();
      await _n(t.c).rate(CardRating.notYet);
    }
    _n(t.c).finish();
    expect(_s(t.c).phase, ReviewPhase.done);
    expect(_s(t.c).notYet, 3);
  });

  test('ôn hết thẻ, không còn thẻ chờ → kết thúc; đếm từng mức đúng', () async {
    final t = _setup();
    await pumpEventQueue();
    final ratings = [CardRating.remembered, CardRating.reviewAgain, CardRating.remembered];
    for (final r in ratings) {
      _n(t.c).showAnswer();
      await _n(t.c).rate(r);
    }
    final s = _s(t.c);
    expect(s.phase, ReviewPhase.done);
    expect((s.remembered, s.again, s.notYet, s.reviewedThisSession), (2, 1, 0, 3));
    expect((s.progress.finished, s.progress.planned), (3, 3));
  });

  group('409 → báo ngắn và tải lại hàng', () {
    for (final code in ['already_finished_today', 'not_due_yet', 'not_in_today_plan', 'card_suspended']) {
      test(code, () async {
        final t = _setup();
        await pumpEventQueue();
        final stale = _s(t.c).current!;
        // Server thực tế: thẻ đã xong ở máy khác → hàng ôn mới không còn thẻ đó.
        t.api.cardQueue = CardQueue(
          date: t.api.cardQueue.date,
          cards: [for (final c in t.api.cardQueue.cards) if (c.id != stale.id) c],
          progress: const CardProgress(planned: 3, finished: 1, remaining: 2),
        );
        t.api.reviewError = apiError(409, {'error': code});
        _n(t.c).showAnswer();
        await _n(t.c).rate(CardRating.remembered);
        final s = _s(t.c);
        expect(s.message, isNotNull);
        expect(s.message, isNot(contains(code)), reason: 'thông báo tiếng Việt, không lộ mã');
        expect(t.api.queueCalls.length, 2, reason: 'đã tải lại hàng');
        expect(s.queue.any((c) => c.id == stale.id), isFalse);
        expect(s.phase, ReviewPhase.question);
        expect(s.busy, isFalse);
        expect((s.remembered, s.reviewedThisSession), (0, 0), reason: 'lượt bị từ chối không tính vào phiên');
      });
    }

    test('thông báo tiếng Việt đúng từng mã', () async {
      final expected = {
        'already_finished_today': 'Thẻ này đã ôn xong hôm nay',
        'not_due_yet': 'Thẻ này chưa đến lúc ôn lại',
        'not_in_today_plan': 'Thẻ này không có trong kế hoạch hôm nay',
        'card_suspended': 'Thẻ này đang tạm dừng',
      };
      for (final e in expected.entries) {
        final t = _setup(FakeHocTapApi()..reviewError = apiError(409, {'error': e.key}));
        await pumpEventQueue();
        _n(t.c).showAnswer();
        await _n(t.c).rate(CardRating.remembered);
        expect(_s(t.c).message, e.value);
      }
    });
  });

  test('lỗi mạng: giữ thẻ ở mặt sau, báo lỗi, bấm lại được và thành công', () async {
    final t = _setup(FakeHocTapApi()..reviewError = Exception('mất mạng'));
    await pumpEventQueue();
    final first = _s(t.c).current!;
    _n(t.c).showAnswer();
    await _n(t.c).rate(CardRating.remembered);
    var s = _s(t.c);
    expect(s.phase, ReviewPhase.answer);
    expect(s.current!.id, first.id);
    expect(s.queue.length, 3);
    expect(s.busy, isFalse);
    expect(s.message, 'Có lỗi, thử lại');
    expect(t.api.queueCalls.length, 1, reason: 'lỗi mạng không tải lại hàng');
    t.api.reviewError = null;
    await _n(t.c).rate(CardRating.remembered);
    s = _s(t.c);
    expect(s.queue.length, 2);
    expect(s.progress.finished, 1);
  });

  test('ackMessage xoá thông báo', () async {
    final t = _setup(FakeHocTapApi()..reviewError = Exception('x'));
    await pumpEventQueue();
    _n(t.c).showAnswer();
    await _n(t.c).rate(CardRating.remembered);
    expect(_s(t.c).message, isNotNull);
    _n(t.c).ackMessage();
    expect(_s(t.c).message, isNull);
  });

  group('hàng rỗng', () {
    test('không có thẻ nào trong kế hoạch → empty', () async {
      final t = _setup(FakeHocTapApi()..cardQueue = CardQueue.fromJson(fixtureMap('card_queue_empty')));
      await pumpEventQueue();
      expect(_s(t.c).phase, ReviewPhase.empty);
      expect(_s(t.c).progress.planned, 0);
    });

    test('hết thẻ hiện ngay nhưng còn thẻ đợi quay lại (fixture card_queue_waiting) → waiting', () async {
      final waiting = CardQueue.fromJson(fixtureMap('card_queue_waiting'));
      final t = _setup(FakeHocTapApi()..cardQueue = CardQueue(date: waiting.date, progress: waiting.progress, soonestDueAt: waiting.soonestDueAt));
      await pumpEventQueue();
      expect(_s(t.c).phase, ReviewPhase.waiting);
      expect(_s(t.c).soonestDueAt, waiting.soonestDueAt);
    });

    test('kế hoạch đã ôn xong từ trước (mở lại màn): kết thúc, không phải "trống"', () async {
      final t = _setup(FakeHocTapApi()..cardQueue = const CardQueue(progress: CardProgress(planned: 5, finished: 5)));
      await pumpEventQueue();
      expect(_s(t.c).phase, ReviewPhase.done);
      expect(_s(t.c).reviewedThisSession, 0);
    });
  });

  test('lỗi tải hàng ôn → error; tải lại được', () async {
    final t = _setup(FakeHocTapApi()..queueError = apiError(500, {'error': 'x'}));
    await pumpEventQueue();
    expect(_s(t.c).phase, ReviewPhase.error);
    t.api.queueError = null;
    await _n(t.c).load();
    expect(_s(t.c).phase, ReviewPhase.question);
  });

  test('tải lại ngầm lỗi khi đang ôn dở: giữ màn hiện tại, chỉ báo ngắn', () async {
    final t = _setup();
    await pumpEventQueue();
    t.api.queueError = apiError(500, {'error': 'x'});
    await _n(t.c).load(quiet: true);
    expect(_s(t.c).phase, ReviewPhase.question);
    expect(_s(t.c).queue.length, 3);
    expect(_s(t.c).message, isNotNull);
  });

  test('kết quả của lần tải cũ bị bỏ khi đã có lần tải mới hơn', () async {
    final slow = Completer<void>();
    final api = FakeHocTapApi()..queueGate = slow;
    final t = _setup(api);
    await pumpEventQueue(); // lần tải đầu đang chờ cổng
    api.queueGate = null;
    api.cardQueue = CardQueue.fromJson(fixtureMap('card_queue_empty'));
    await _n(t.c).load();
    expect(_s(t.c).phase, ReviewPhase.empty);
    slow.complete(); // lần tải cũ xong muộn: không được ghi đè
    await pumpEventQueue();
    expect(_s(t.c).phase, ReviewPhase.empty);
  });

  test('reviewPhaseFor: thứ tự ưu tiên', () {
    final card = CardQueue.fromJson(fixtureMap('card_queue')).cards.first;
    const p = CardProgress(planned: 3, finished: 1, remaining: 2);
    final soon = DateTime.now();
    expect(reviewPhaseFor(queue: [card], progress: p, soonestDueAt: soon), ReviewPhase.question);
    expect(reviewPhaseFor(queue: const [], progress: p, soonestDueAt: soon), ReviewPhase.waiting);
    expect(reviewPhaseFor(queue: const [], progress: const CardProgress(), soonestDueAt: null), ReviewPhase.empty);
    expect(reviewPhaseFor(queue: const [], progress: p, soonestDueAt: null), ReviewPhase.done);
  });
}

import 'package:amber_flutter/features/tra_dinh/hoc_tap/models/study_card.dart';
import 'package:amber_flutter/features/tra_dinh/hoc_tap/models/study_card_queue.dart';
import 'package:amber_flutter/features/tra_dinh/hoc_tap/models/study_enums.dart';
import 'package:amber_flutter/features/tra_dinh/hoc_tap/models/study_log.dart';
import 'package:amber_flutter/features/tra_dinh/hoc_tap/utils/card_format.dart';
import 'package:flutter_test/flutter_test.dart';

import 'hoc_tap_test_support.dart';

// fromJson với JSON thật của backend dev (test/fixtures/hoc_tap/card_queue*.json, card_review*.json) + trường thiếu / lạ.

void main() {
  test('CardQueue.fromJson: hàng ôn thật — thẻ, nhóm, kết quả của ba mức, tiến độ, số đếm', () {
    final q = CardQueue.fromJson(fixtureMap('card_queue'));
    expect(q.date, matches(RegExp(r'^\d{4}-\d{2}-\d{2}$')));
    expect(q.quota, 20);
    expect(q.cards.length, 3);
    expect(q.soonestDueAt, isNull);
    final c = q.cards.first;
    expect(c.bucket, CardBucket.newCard);
    expect(c.card.stage, CardStage.newCard);
    expect(c.card.phrase, isNotEmpty);
    expect(c.card.example, isNotEmpty);
    expect(c.next.keys.toSet(), CardRating.values.toSet());
    expect(c.next[CardRating.notYet]!.stage, CardStage.learning);
    expect(c.next[CardRating.reviewAgain]!.stage, CardStage.learning);
    expect(c.next[CardRating.remembered]!.stage, CardStage.weekly);
    expect(c.next[CardRating.remembered]!.dueAt, isNotNull);
    expect((q.progress.planned, q.progress.finished, q.progress.remaining), (3, 0, 3));
    expect(q.progress.byBucket[CardBucket.newCard]!.planned, 3);
    expect(q.progress.remainingOf(CardBucket.newCard), 3);
    expect(q.progress.remainingOf(CardBucket.due), 0);
    expect(q.counts.total, 3);
  });

  test('đủ bốn nhóm: DUE / NEW / HARD / RANDOM; "Ôn thêm" = HARD + RANDOM', () {
    final q = CardQueue.fromJson(fixtureMap('card_queue_buckets'));
    expect(q.cards.map((c) => c.bucket).toSet(), {CardBucket.due, CardBucket.newCard, CardBucket.hard, CardBucket.random});
    expect(q.progress.planned, 4);
    expect(q.progress.remainingOf(CardBucket.due), 1);
    expect(q.progress.remainingOf(CardBucket.hard), 1);
    expect(q.progress.remainingOf(CardBucket.random), 1);
    expect(q.progress.remainingExtra, 2);
  });

  test('thẻ ôn thêm (HARD / RANDOM, lượt đầu trong ngày): "Đã nhớ" GIỮ NGUYÊN giai đoạn và hạn; DUE và NEW thì tiến lên', () {
    final q = CardQueue.fromJson(fixtureMap('card_queue_buckets'));
    for (final c in q.cards) {
      final remembered = c.next[CardRating.remembered]!;
      final keeps = remembered.stage == c.card.stage && remembered.dueAt == c.card.dueAt;
      expect(keeps, c.bucket == CardBucket.hard || c.bucket == CardBucket.random, reason: '${c.card.phrase} (${c.bucket.api})');
      final label = ratingDueLabel(card: c.card, rating: CardRating.remembered, next: remembered);
      expect(label == 'Giữ lịch', keeps, reason: 'nhãn nút "Đã nhớ" của ${c.bucket.api}');
      // Chưa nhớ / Cần ôn lại luôn đưa về Đang học, kể cả thẻ ôn thêm.
      expect(c.next[CardRating.notYet]!.stage, CardStage.learning);
      expect(c.next[CardRating.reviewAgain]!.stage, CardStage.learning);
    }
  });

  test('ôn thêm thật trên server: Đã nhớ ở thẻ HARD để nguyên giai đoạn và hạn (fixture card_review_hard_extra)', () {
    final queue = CardQueue.fromJson(fixtureMap('card_queue_buckets'));
    final hard = queue.cards.firstWhere((c) => c.bucket == CardBucket.hard);
    final r = ReviewResult.fromJson(fixtureMap('card_review_hard_extra'));
    expect(r.card.id, hard.id);
    expect(r.card.card.stage, hard.card.stage);
    expect(r.card.card.dueAt, hard.card.dueAt);
    expect(r.card.card.reviewCount, hard.card.reviewCount + 1, reason: 'vẫn tính một lượt ôn');
    expect(r.progress.finished, 1);
  });

  test('ReviewResult.fromJson: thẻ sau khi cập nhật, tiến độ, soonestDueAt', () {
    final r = ReviewResult.fromJson(fixtureMap('card_review'));
    expect(r.card.card.stage, CardStage.weekly);
    expect(r.card.card.reviewCount, 1);
    expect(r.card.bucket, CardBucket.newCard);
    expect(r.card.next.keys.toSet(), CardRating.values.toSet());
    expect((r.progress.planned, r.progress.finished, r.progress.remaining), (3, 1, 2));
    expect(r.progress.byBucket[CardBucket.newCard]!.finished, 1);
    expect(r.soonestDueAt, isNull);
  });

  test('NOT_YET: thẻ về Đang học, notYetCount tăng, soonestDueAt = hạn quay lại trong hôm nay', () {
    final r = ReviewResult.fromJson(fixtureMap('card_review_not_yet'));
    expect(r.card.card.stage, CardStage.learning);
    expect(r.card.card.notYetCount, 1);
    expect(r.soonestDueAt, isNotNull);
    expect(r.soonestDueAt, r.card.card.dueAt);
    expect(r.progress.finished, 1, reason: 'lần trước đã xong 1 thẻ; NOT_YET không cộng thêm');
  });

  test('hàng chờ: còn thẻ chưa ôn và thẻ đang đợi quay lại', () {
    final q = CardQueue.fromJson(fixtureMap('card_queue_waiting'));
    expect(q.cards.length, 1);
    expect(q.soonestDueAt, isNotNull);
    expect((q.progress.planned, q.progress.finished, q.progress.remaining), (3, 1, 2));
  });

  test('hàng trống: không có thẻ nào trong kế hoạch', () {
    final q = CardQueue.fromJson(fixtureMap('card_queue_empty'));
    expect(q.cards, isEmpty);
    expect(q.progress.planned, 0);
    expect(q.soonestDueAt, isNull);
    expect(q.counts.total, 0);
  });

  test('buổi ôn thẻ: StudyLog đọc activity; thiếu activity (server / app cũ) → LESSON', () {
    final created = StudyLogResult.fromJson(fixtureMap('log_card_review'));
    expect(created.log.activity, LogActivity.cardReview);
    expect(created.log.courseId, isNull);
    expect(created.log.courseTitle, isNull);
    expect(created.log.sections, isEmpty);
    expect(created.log.minutes, 15);
    final logs = [for (final l in fixtureList('logs_today_mixed')) StudyLog.fromJson(l as Map<String, dynamic>)];
    expect(logs.where((l) => l.activity == LogActivity.cardReview).fold<int>(0, (n, l) => n + l.minutes), 15);
    final old = StudyLog.fromJson({'id': 'x', 'subjectId': 's', 'logDate': '2026-11-06', 'minutes': 30, 'createdAt': '2026-11-06T01:00:00.000Z'});
    expect(old.activity, LogActivity.lesson);
    expect(StudyLog.fromJson({'id': 'x', 'subjectId': 's', 'logDate': '2026-11-06', 'minutes': 1, 'createdAt': '2026-11-06T01:00:00.000Z', 'activity': 'NEW_KIND'}).activity, LogActivity.lesson);
  });

  test('trường thiếu hoặc lạ không làm hỏng việc đọc', () {
    final q = CardQueue.fromJson({
      'cards': [
        {'id': 'c1', 'phrase': 'p', 'bucket': 'SOMETHING', 'next': {'NOT_YET': {'stage': 'LEARNING'}, 'REMEMBERED': 'hỏng', 'EXTRA': {}}},
        {'id': 'c2'},
      ],
      'progress': {'planned': 2.0, 'byBucket': {'DUE': {'planned': 1}, 'NEW': 'hỏng'}},
      'soonestDueAt': 'không phải ngày',
    });
    expect(q.cards.length, 2);
    expect(q.cards[0].bucket, CardBucket.unknown);
    expect(q.cards[0].next.keys, [CardRating.notYet], reason: 'mức thiếu / hỏng bị bỏ');
    expect(q.cards[0].next[CardRating.notYet]!.dueAt, isNull);
    expect(q.cards[1].next, isEmpty);
    expect(q.progress.planned, 2);
    expect(q.progress.finished, 0);
    expect(q.progress.remainingOf(CardBucket.due), 1);
    expect(q.progress.remainingOf(CardBucket.newCard), 0);
    expect(q.soonestDueAt, isNull);
    expect(q.quota, 20);

    final empty = CardQueue.fromJson({});
    expect(empty.cards, isEmpty);
    expect(empty.progress.planned, 0);
    final r = ReviewResult.fromJson({'card': {'id': 'c'}});
    expect(r.card.id, 'c');
    expect(r.progress.planned, 0);
    expect(r.soonestDueAt, isNull);
    expect(CardBucket.fromApi('HARD'), CardBucket.hard);
    expect(CardBucket.fromApi(null), CardBucket.unknown);
  });
}

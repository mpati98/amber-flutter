import 'package:amber_flutter/features/tra_dinh/hoc_tap/models/study_card.dart';
import 'package:amber_flutter/features/tra_dinh/hoc_tap/models/study_card_insights.dart';
import 'package:flutter_test/flutter_test.dart';

import 'hoc_tap_test_support.dart';

// fromJson với JSON thật của backend dev (card_insights_*.json): môn trống, môn có dữ liệu (7 và 30 ngày), chỉ nhóm theo loại.

void main() {
  test('môn trống: số 0, mọi danh sách rỗng, minCards 10', () {
    final i = CardInsights.fromJson(fixtureMap('card_insights_empty'));
    expect((i.days, i.minCards), (30, 10));
    expect((i.totals.reviews, i.totals.notYetRate, i.totals.promotedToWeekly), (0, 0.0, 0));
    expect([i.byKind.length, i.byTopic.length, i.byLesson.length, i.hardestCards.length], [0, 0, 0, 0]);
    expect(i.hasGroups, isFalse);
  });

  test('môn đã gài 10 thẻ từng Chưa nhớ: nhóm theo loại / chủ đề / buổi học, thẻ hay quên, số tổng trong kỳ', () {
    final i = CardInsights.fromJson(fixtureMap('card_insights_seeded'));
    expect(i.hasGroups, isTrue);
    expect(i.totals.reviews, 4);
    expect(i.totals.notYetRate, 0.5);
    expect(i.totals.notYetPercent, 50);
    expect(i.totals.promotedToWeekly, 2);
    final kind = i.byKind.single;
    expect((kind.key, kind.label, kind.totalCards, kind.everNotYetCards), ('IDIOM', 'IDIOM', 12, 10));
    expect(kind.rate, closeTo(10 / 12, 1e-9));
    expect(kind.percent, 83);
    expect(i.byTopic.single.key, 'work');
    final lesson = i.byLesson.single;
    expect(lesson.key, isNotEmpty);
    expect(lesson.label, matches(RegExp(r'^\d{2}/\d{2} · English Tenses 101$')));
    expect(i.hardestCards.map((c) => c.notYetCount), [5, 4, 3]);
    final hard = i.hardestCards.first;
    expect((hard.phrase, hard.kind), ('idiom phrase 0', CardKind.idiom));
    expect(hard.topics, ['work', 'daily life']);
    expect(hard.meaning, 'meaning 0');
    expect(hard.example, 'Example sentence number 0.');
    expect(hard.note, 'note 0');
    expect(i.hardestCards[1].note, isNull, reason: 'thẻ không có ghi chú');
    expect(hard.reviewCount, 7);
    expect(hard.id, isNotEmpty);
  });

  test('chỉ số tổng đổi theo kỳ nhưng nhóm tích luỹ giữ nguyên: 7 ngày vs 30 ngày', () {
    final d30 = CardInsights.fromJson(fixtureMap('card_insights_seeded'));
    final d7 = CardInsights.fromJson(fixtureMap('card_insights_seeded_7'));
    expect((d7.days, d7.totals.reviews), (7, 3));
    expect(d7.totals.notYetRate, closeTo(1 / 3, 1e-9));
    expect(d7.totals.notYetPercent, 33);
    expect(d7.byKind.single.everNotYetCards, d30.byKind.single.everNotYetCards);
    expect(d7.hardestCards.length, d30.hardestCards.length);
  });

  test('chỉ nhóm theo loại đạt ngưỡng: chủ đề và buổi học rỗng', () {
    final i = CardInsights.fromJson(fixtureMap('card_insights_partial'));
    expect(i.byKind.single.key, 'COLLOCATION');
    expect((i.byKind.single.totalCards, i.byKind.single.everNotYetCards), (11, 10));
    expect(i.byTopic, isEmpty);
    expect(i.byLesson, isEmpty);
    expect(i.hasGroups, isTrue);
  });

  test('thiếu trường hoặc giá trị lạ không làm hỏng việc đọc', () {
    final i = CardInsights.fromJson({
      'byKind': [
        {'key': 'IDIOM'},
        'hỏng',
        {'key': 'X', 'label': 'Nhãn', 'totalCards': 5.0, 'everNotYetCards': 2, 'rate': 7},
      ],
      'byTopic': 'hỏng',
      'hardestCards': [{'id': 'c', 'phrase': 'p', 'kind': 'LẠ', 'topics': ['a', 1, null]}, 5],
      'totals': {'notYetRate': 'x'},
    });
    final bad = CardInsights.fromJson({'totals': 'hỏng', 'byKind': {'a': 1}, 'hardestCards': 'hỏng', 'minCards': 'x', 'days': null});
    expect(bad.hasGroups, isFalse);
    expect(bad.hardestCards, isEmpty);
    expect(bad.totals.reviews, 0);
    expect((i.days, i.minCards), (30, 10));
    expect(i.byKind.length, 2, reason: 'bỏ phần tử không phải object');
    expect(i.byKind.first.label, 'IDIOM', reason: 'thiếu label → dùng key');
    expect(i.byKind.last.totalCards, 5);
    expect(i.byKind.last.rate, 1.0, reason: 'rate kẹp trong [0, 1]');
    expect(i.byTopic, isEmpty);
    expect(i.hardestCards.single.kind, CardKind.unknown);
    expect(i.hardestCards.single.topics, ['a']);
    expect(i.hardestCards.single.notYetCount, 0);
    expect(i.totals.notYetRate, 0.0);
    final empty = CardInsights.fromJson({});
    expect(empty.hasGroups, isFalse);
    expect(InsightGroup.fromJson({'rate': double.nan}).rate, 0.0);
  });
}

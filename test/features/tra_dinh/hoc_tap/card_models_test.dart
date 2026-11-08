import 'package:amber_flutter/features/tra_dinh/hoc_tap/models/study_card.dart';
import 'package:flutter_test/flutter_test.dart';

import 'hoc_tap_test_support.dart';

// fromJson với JSON thật của backend dev (test/fixtures/hoc_tap/card*.json) + trường thiếu / giá trị lạ.

void main() {
  test('StudyCard.fromJson: thẻ thật (GET /cards/[id])', () {
    final c = StudyCard.fromJson(fixtureMap('card'));
    expect(c.phrase, 'look forward to');
    expect(c.meaning, startsWith('to be excited'));
    expect(c.example, 'I look forward to meeting you next week.');
    expect(c.note, 'followed by V-ing');
    expect(c.kind, CardKind.phrasalVerb);
    expect(c.topics, ['daily life', 'work']);
    expect(c.stage, CardStage.newCard);
    expect(c.dueAt, isNull, reason: 'thẻ mới chưa có hạn');
    expect((c.reviewCount, c.notYetCount, c.suspended), (0, 0, false));
    expect(c.lastReviewedAt, isNull);
    expect(c.createdAt, isNotNull);
    expect(c.sourceLogId, isNull);
  });

  test('CardListPage.fromJson: danh sách, số đếm cả môn, thẻ đã ôn / tạm dừng', () {
    final page = CardListPage.fromJson(fixtureMap('cards_list'));
    expect(page.cards.map((c) => c.phrase), ['make a decision', 'break the ice', 'look forward to']);
    expect(page.nextCursor, isNull);
    expect((page.counts.total, page.counts.newCards, page.counts.weekly, page.counts.learning, page.counts.suspended), (3, 2, 1, 0, 1));
    expect(page.counts.of(null), 3);
    expect(page.counts.of(CardStage.weekly), 1);
    expect(page.counts.of(CardStage.quarterly), 0);
    final weekly = page.cards.firstWhere((c) => c.stage == CardStage.weekly);
    expect(weekly.dueAt, isNotNull);
    expect((weekly.reviewCount, weekly.notYetCount), (4, 1));
    expect(weekly.lastReviewedAt, isNotNull);
    expect(page.cards.firstWhere((c) => c.suspended).phrase, 'make a decision');
  });

  test('CardListPage.fromJson: trang đầu có nextCursor', () {
    final page = CardListPage.fromJson(fixtureMap('cards_list_page1'));
    expect(page.cards.length, 2);
    expect(page.nextCursor, isNotNull);
    expect(page.counts.total, 3, reason: 'số đếm là của cả môn, không phải của trang');
  });

  test('StudyCard.fromJson: pronunciation có / thiếu / lạ / rỗng / quá dài', () {
    Map<String, dynamic> j(Object? p, {bool omit = false}) => {'id': 'c1', 'phrase': 'catch up with', if (!omit) 'pronunciation': p};
    expect(StudyCard.fromJson(j('  /ˈkætʃ ʌp wɪð/ ')).pronunciation, '/ˈkætʃ ʌp wɪð/');
    expect(StudyCard.fromJson(j(null, omit: true)).pronunciation, isNull, reason: 'backend cũ không có trường');
    expect(StudyCard.fromJson(j(null)).pronunciation, isNull);
    expect(StudyCard.fromJson(j(42)).pronunciation, isNull);
    expect(StudyCard.fromJson(j('   ')).pronunciation, isNull);
    expect(StudyCard.fromJson(j('a' * 101)).pronunciation, isNull);
    expect(StudyCard.fromJson(j('a' * 100)).pronunciation, 'a' * 100);
  });

  test('ParsedCardItem: pronunciation có / thiếu / quá dài (chỉ bỏ trường đó), và gửi lại khi import', () {
    final withP = ParsedCardItem.fromJson({'index': 0, 'phrase': 'catch up with', 'pronunciation': ' /ˈkætʃ/ '});
    expect(withP.pronunciation, '/ˈkætʃ/');
    expect(withP.toImportJson()['pronunciation'], '/ˈkætʃ/');
    final without = ParsedCardItem.fromJson({'index': 1, 'phrase': 'break the ice'});
    expect(without.pronunciation, isNull);
    expect(without.toImportJson().containsKey('pronunciation'), isFalse, reason: 'thiếu thì không gửi khoá');
    final long = ParsedCardItem.fromJson({'index': 2, 'phrase': 'pick up on', 'meaning': 'giữ nguyên', 'pronunciation': 'a' * 101});
    expect(long.pronunciation, isNull);
    expect(long.phrase, 'pick up on');
    expect(long.meaning, 'giữ nguyên');
  });

  test('ParsedCards.fromJson: thẻ hợp lệ, lỗi theo vị trí, lặp, đã có', () {
    final p = ParsedCards.fromJson(fixtureMap('cards_parse'));
    expect(p.cards.map((c) => (c.index, c.phrase)), [(1, 'pick up on'), (4, 'come across')]);
    expect(p.cards.first.kind, CardKind.phrasalVerb);
    expect(p.cards.first.topics, ['daily life']);
    expect(p.cards.last.note, 'inseparable');
    expect(p.errors.map((e) => (e.index, e.field, e.reason)), [(3, 'phrase', 'single_word'), (3, 'kind', 'invalid')]);
    expect(p.hasErrors, isTrue);
    expect(p.duplicates.single.index, 2);
    expect(p.duplicates.single.firstIndex, 1);
    expect(p.duplicates.single.phrase, 'PICK  UP on');
    expect(p.existing.single.index, 0);
    expect(p.existing.single.phrase, 'Break the ice');
  });

  test('ParsedCards.fromJson: lỗi của cả đầu vào có index null', () {
    final p = ParsedCards.fromJson(fixtureMap('cards_parse_invalid_json'));
    expect(p.cards, isEmpty);
    expect(p.errors.single.index, isNull);
    expect(p.errors.single.field, isNull);
    expect(p.errors.single.reason, 'invalid_json');
  });

  test('ParsedCardItem.toImportJson: đúng dạng gửi POST /cards/import', () {
    final item = ParsedCards.fromJson(fixtureMap('cards_parse')).cards.last;
    expect(item.toImportJson(), {
      'phrase': 'come across',
      'meaning': 'to find by chance',
      'example': 'I came across an old photo.',
      'note': 'inseparable',
      'kind': 'PHRASAL_VERB',
      'topics': ['travel'],
    });
  });

  test('ImportResult và TopicCount từ JSON thật', () {
    final r = ImportResult.fromJson(fixtureMap('cards_import'));
    expect((r.created, r.skipped), (1, 1));
    final topics = [for (final t in fixtureMap('cards_topics')['topics'] as List) TopicCount.fromJson(t as Map<String, dynamic>)];
    expect(topics.map((t) => (t.topic, t.cards)), [('work', 2), ('daily life', 1)]);
  });

  test('trường thiếu hoặc lạ không làm hỏng việc đọc', () {
    final c = StudyCard.fromJson({'id': 'x', 'kind': 'SOMETHING_NEW', 'stage': 'ARCHIVED', 'topics': ['a', 3, null], 'reviewCount': 2.0, 'dueAt': 'không phải ngày', 'future': true});
    expect(c.id, 'x');
    expect(c.phrase, '');
    expect(c.kind, CardKind.unknown);
    expect(c.stage, CardStage.unknown);
    expect(c.topics, ['a'], reason: 'bỏ phần tử không phải chữ');
    expect(c.reviewCount, 2);
    expect(c.dueAt, isNull, reason: 'ngày hỏng → null');
    expect(c.suspended, isFalse);

    final page = CardListPage.fromJson({});
    expect(page.cards, isEmpty);
    expect(page.counts.total, 0);
    expect(page.nextCursor, isNull);

    final parsed = ParsedCards.fromJson({});
    expect([parsed.cards.length, parsed.errors.length, parsed.duplicates.length, parsed.existing.length], [0, 0, 0, 0]);
    expect(parsed.hasErrors, isFalse);
    expect(ImportResult.fromJson({}).created, 0);
    expect(TopicCount.fromJson({}).cards, 0);
    expect(CardCounts.fromJson({'NEW': 5}).newCards, 5);
  });

  test('enum: giá trị lạ → unknown, không ném lỗi', () {
    expect(CardStage.fromApi('WEEKLY'), CardStage.weekly);
    expect(CardStage.fromApi(null), CardStage.unknown);
    expect(CardKind.fromApi('IDIOM'), CardKind.idiom);
    expect(CardKind.fromApi(42), CardKind.unknown);
    expect(CardKind.values.where((k) => k != CardKind.unknown).map((k) => k.api), ['PHRASAL_VERB', 'COLLOCATION', 'IDIOM', 'PATTERN', 'EXPRESSION']);
  });
}

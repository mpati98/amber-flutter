import 'package:amber_flutter/features/tra_dinh/hoc_tap/models/study_card.dart';
import 'package:amber_flutter/features/tra_dinh/hoc_tap/models/study_card_insights.dart';
import 'package:amber_flutter/features/tra_dinh/hoc_tap/utils/card_insights_prompt.dart';
import 'package:flutter_test/flutter_test.dart';

import 'hoc_tap_test_support.dart';

// Lời nhắc tiếng Anh gửi Claude: bối cảnh, số tổng, nhóm khó, thẻ hay quên, chủ đề đang dùng, yêu cầu.

CardInsights _seeded() => CardInsights.fromJson(fixtureMap('card_insights_seeded'));

const _kinds = ['PHRASAL_VERB', 'COLLOCATION', 'IDIOM', 'PATTERN', 'EXPRESSION'];

void main() {
  test('cấu trúc theo thứ tự: bối cảnh → số tổng → nhóm → thẻ hay quên → chủ đề → yêu cầu', () {
    final p = buildInsightsPrompt(insights: _seeded(), topics: ['work', 'daily life']);
    final order = [
      'I am learning English with spaced-repetition cards. Here are my recent statistics (last 30 days).',
      'Totals in this period:',
      'Hard groups by kind:',
      'Hard groups by topic:',
      'Hard groups by lesson:',
      'My hardest cards',
      'Topics I already use: work, daily life.',
      '(1) For each hard group and each hard card',
      '(2) Suggest 10 to 15 related phrases',
    ].map(p.indexOf).toList();
    expect(order.every((i) => i >= 0), isTrue, reason: '$order');
    expect([...order]..sort(), order, reason: 'đúng thứ tự');
    expect(p.startsWith('I am learning English with spaced-repetition cards.'), isTrue);
  });

  test('dòng bối cảnh theo kỳ đã chọn (7 / 90 ngày)', () {
    for (final d in [7, 90]) {
      final p = buildInsightsPrompt(insights: CardInsights(days: d), topics: const []);
      expect(p.split('\n').first, 'I am learning English with spaced-repetition cards. Here are my recent statistics (last $d days).');
    }
  });

  test('số tổng: lượt ôn, % chưa nhớ, số thẻ lên Hàng tuần', () {
    final p = buildInsightsPrompt(insights: _seeded(), topics: const []);
    expect(p, contains('- Reviews: 4'));
    expect(p, contains('- Not remembered: 50% of reviews'));
    expect(p, contains('- Cards promoted to weekly: 2'));
  });

  test('nhóm khó: "nhãn: a/b cards ever not remembered (rate%)"; loại viết tên tiếng Anh dễ đọc', () {
    final p = buildInsightsPrompt(insights: _seeded(), topics: const []);
    expect(p, contains('- idiom: 10/12 cards ever not remembered (83%)'));
    expect(p, contains('- work: 10/12 cards ever not remembered (83%)'));
    expect(p, contains(RegExp(r'- \d{2}/\d{2} · English Tenses 101: 10/12 cards ever not remembered \(83%\)')));
    expect(p, isNot(contains('- IDIOM:')), reason: 'khóa loại không lộ ở dạng mã trong phần nhóm');
  });

  test('bỏ phần nhóm rỗng (không có tiêu đề trống)', () {
    final p = buildInsightsPrompt(insights: CardInsights.fromJson(fixtureMap('card_insights_partial')), topics: const []);
    expect(p, contains('Hard groups by kind:'));
    expect(p, contains('- collocation: 10/11 cards ever not remembered (91%)'));
    expect(p, isNot(contains('Hard groups by topic')));
    expect(p, isNot(contains('Hard groups by lesson')));
    expect(p, isNot(contains('My hardest cards')), reason: 'không có thẻ hay quên thì bỏ phần');
  });

  test('thẻ hay quên: cụm, số lần, loại, chủ đề, nghĩa, ví dụ; ghi chú chỉ khi có', () {
    final i = CardInsights(hardestCards: [
      const HardCard(id: '1', phrase: 'look forward to', kind: CardKind.phrasalVerb, meaning: 'to be excited', example: 'I look forward to it.', note: 'followed by V-ing', topics: ['daily life', 'work'], notYetCount: 5),
      const HardCard(id: '2', phrase: 'break the ice', kind: CardKind.idiom, meaning: 'to relax people', example: 'A joke broke the ice.', notYetCount: 1),
    ]);
    final p = buildInsightsPrompt(insights: i, topics: const []);
    expect(p, contains('1. "look forward to" - not remembered 5 times'));
    expect(p, contains('   kind: phrasal verb; topics: daily life, work'));
    expect(p, contains('   meaning: to be excited'));
    expect(p, contains('   example: I look forward to it.'));
    expect(p, contains('   note: followed by V-ing'));
    expect(p, contains('2. "break the ice" - not remembered 1 time\n'), reason: 'số ít');
    expect(p, contains('   kind: idiom; topics: none'));
    expect(RegExp('   note:').allMatches(p).length, 1, reason: 'thẻ không có ghi chú thì không có dòng note');
  });

  test('loại của thẻ hay quên viết dạng "phrasal verb"', () {
    final p = buildInsightsPrompt(insights: _seeded(), topics: const []);
    expect(p, contains('kind: idiom; topics: work, daily life'));
    final pv = buildInsightsPrompt(insights: CardInsights.fromJson({'hardestCards': [{'id': 'x', 'phrase': 'pick up on', 'kind': 'PHRASAL_VERB', 'notYetCount': 3}]}), topics: const []);
    expect(pv, contains('kind: phrasal verb;'));
  });

  test('chủ đề đang dùng: liệt kê, hoặc "none yet" khi chưa có / chỉ chuỗi rỗng', () {
    expect(buildInsightsPrompt(insights: _seeded(), topics: ['travel', 'work']), contains('Topics I already use: travel, work.'));
    expect(buildInsightsPrompt(insights: _seeded(), topics: const []), contains('Topics I already use: none yet.'));
    expect(buildInsightsPrompt(insights: _seeded(), topics: ['', '  ']), contains('Topics I already use: none yet.'));
  });

  test('yêu cầu: nguyên văn hai ý (1) nguyên nhân (2) 10–15 cụm liên quan, JSON riêng, đủ năm loại, "related to:" trong note, cụm ≥ 2 từ', () {
    final p = buildInsightsPrompt(insights: _seeded(), topics: const []);
    expect(p, contains('(1) For each hard group and each hard card, explain the most likely causes of the difficulty (for example confusable meanings, grammar structure, unfamiliar topic) in simple English.'));
    expect(p, contains('(2) Suggest 10 to 15 related phrases that connect to my hardest cards (same topic, same pattern or particle, synonyms, opposites), so I can learn them as connected groups.'));
    expect(p, contains('Return the suggestions as ONLY a JSON array in a separate code block.'));
    expect(p, contains('Each item: {"phrase", "meaning", "example", "note", "kind", "topics"}.'));
    expect(p, contains('"kind" is exactly one of ${_kinds.join(', ')}.'));
    expect(p, contains('"topics" has up to 3 lowercase topics; reuse my existing topics when they fit.'));
    expect(p, contains('Put \'related to: <phrase>\' in "note".'));
    expect(p, contains('Phrases must have at least two words.'));
    expect(p.trimRight().endsWith('Phrases must have at least two words.'), isTrue, reason: 'yêu cầu nằm cuối cùng');
  });

  test('loại thẻ lạ (server thêm loại mới) in "unknown", không để trống', () {
    final p = buildInsightsPrompt(insights: const CardInsights(hardestCards: [HardCard(id: 'x', phrase: 'a b', notYetCount: 3)]), topics: const []);
    expect(p, contains('kind: unknown;'));
  });

  test('môn trống vẫn dựng được lời nhắc hợp lệ (không ném lỗi)', () {
    final p = buildInsightsPrompt(insights: CardInsights.fromJson(fixtureMap('card_insights_empty')), topics: const []);
    expect(p, contains('- Reviews: 0'));
    expect(p, isNot(contains('Hard groups')));
    expect(p, contains('(2) Suggest 10 to 15'));
  });
}

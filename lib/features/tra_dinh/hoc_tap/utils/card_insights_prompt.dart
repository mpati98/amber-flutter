import '../models/study_card_insights.dart';

/// "PHRASAL_VERB" → "phrasal verb": tên loại thẻ trong lời nhắc tiếng Anh.
String _kindEnglish(String key) => key.isEmpty ? 'unknown' : key.toLowerCase().replaceAll('_', ' ');

List<String> _groupLines(List<InsightGroup> groups, {bool kind = false}) => [
  for (final g in groups) '- ${kind ? _kindEnglish(g.key) : g.label}: ${g.everNotYetCards}/${g.totalCards} cards ever not remembered (${g.percent}%)',
];

/// Lời nhắc tiếng Anh để dán cho Claude phân tích nhóm khó và gợi ý cụm liên quan (dán kết quả JSON vào màn Nhập thẻ).
/// Thứ tự: bối cảnh, số tổng, các nhóm khó (bỏ phần rỗng), thẻ hay quên, chủ đề đang dùng, yêu cầu. Hàm thuần.
String buildInsightsPrompt({required CardInsights insights, required List<String> topics}) {
  final i = insights;
  final out = <String>[
    'I am learning English with spaced-repetition cards. Here are my recent statistics (last ${i.days} days).',
    '',
    'Totals in this period:',
    '- Reviews: ${i.totals.reviews}',
    '- Not remembered: ${i.totals.notYetPercent}% of reviews',
    '- Cards promoted to weekly: ${i.totals.promotedToWeekly}',
  ];

  for (final (title, lines) in [
    ('Hard groups by kind', _groupLines(i.byKind, kind: true)),
    ('Hard groups by topic', _groupLines(i.byTopic)),
    ('Hard groups by lesson', _groupLines(i.byLesson)),
  ]) {
    if (lines.isEmpty) continue;
    out..add('')..add('$title:')..addAll(lines);
  }

  if (i.hardestCards.isNotEmpty) {
    out..add('')..add('My hardest cards (most often not remembered):');
    for (final (n, c) in i.hardestCards.indexed) {
      final topicsText = c.topics.isEmpty ? 'none' : c.topics.join(', ');
      out
        ..add('${n + 1}. "${c.phrase}" - not remembered ${c.notYetCount} ${c.notYetCount == 1 ? 'time' : 'times'}')
        ..add('   kind: ${_kindEnglish(c.kind.api)}; topics: $topicsText')
        ..add('   meaning: ${c.meaning}')
        ..add('   example: ${c.example}');
      if (c.note != null && c.note!.trim().isNotEmpty) out.add('   note: ${c.note!.trim()}');
    }
  }

  final used = topics.where((t) => t.trim().isNotEmpty).toList();
  out
    ..add('')
    ..add('Topics I already use: ${used.isEmpty ? 'none yet' : used.join(', ')}.')
    ..add('')
    ..add(
      '(1) For each hard group and each hard card, explain the most likely causes of the difficulty (for example confusable meanings, grammar structure, unfamiliar topic) in simple English.',
    )
    ..add(
      '(2) Suggest 10 to 15 related phrases that connect to my hardest cards (same topic, same pattern or particle, synonyms, opposites), so I can learn them as connected groups. '
      'Return the suggestions as ONLY a JSON array in a separate code block. Each item: {"phrase", "meaning", "example", "note", "kind", "topics"}. '
      '"kind" is exactly one of PHRASAL_VERB, COLLOCATION, IDIOM, PATTERN, EXPRESSION. "topics" has up to 3 lowercase topics; reuse my existing topics when they fit. '
      'Put \'related to: <phrase>\' in "note". Phrases must have at least two words.',
    );
  return out.join('\n');
}

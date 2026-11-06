/// Lời nhắc mẫu để Claude tạo thẻ từ transcript (phụ lục của kế hoạch thẻ từ vựng). [topics] là các chủ đề đang có
/// trong môn để Claude dùng lại; rỗng → "none yet".
String cardPrompt(Iterable<String> topics) {
  final list = topics.where((t) => t.trim().isNotEmpty).toList();
  return 'Here is the transcript of my English lesson. Pick the 10–15 most useful\n'
      'phrases (collocations, phrasal verbs, patterns), not single isolated words.\n'
      'Return only a JSON array. Each item:\n'
      '{"phrase", "meaning", "example", "note", "kind", "topics"}.\n'
      '"meaning" is a simple English definition. "example" is a natural sentence\n'
      'that contains the phrase. "note" is optional (grammar or usage warning).\n'
      '"kind" is exactly one of: PHRASAL_VERB, COLLOCATION, IDIOM, PATTERN,\n'
      'EXPRESSION. "topics" has up to 3 lowercase topics. Reuse these existing\n'
      'topics when they fit: ${list.isEmpty ? 'none yet' : list.join(', ')}.';
}

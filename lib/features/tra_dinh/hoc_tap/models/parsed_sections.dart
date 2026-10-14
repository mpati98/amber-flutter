class ParsedSection {
  const ParsedSection({required this.title, required this.durationMinutes});

  factory ParsedSection.fromJson(Map<String, dynamic> json) => ParsedSection(title: json['title'] as String, durationMinutes: json['durationMinutes'] as int);

  final String title;
  final int durationMinutes;
}

class SkippedLine {
  const SkippedLine({required this.line, required this.text});

  factory SkippedLine.fromJson(Map<String, dynamic> json) => SkippedLine(line: json['line'] as int, text: json['text'] as String);

  /// Số dòng trong văn bản dán, từ 1.
  final int line;
  final String text;
}

/// POST /sections/parse (và `skipped` trong lỗi 400 `sections_unparsed`).
class ParsedSections {
  const ParsedSections({this.sections = const [], this.skipped = const [], this.totalMinutes = 0});

  factory ParsedSections.fromJson(Map<String, dynamic> json) => ParsedSections(
    sections: [for (final s in (json['sections'] as List? ?? const [])) ParsedSection.fromJson(s as Map<String, dynamic>)],
    skipped: [for (final s in (json['skipped'] as List? ?? const [])) SkippedLine.fromJson(s as Map<String, dynamic>)],
    totalMinutes: json['totalMinutes'] as int? ?? 0,
  );

  final List<ParsedSection> sections;
  final List<SkippedLine> skipped;
  final int totalMinutes;
}

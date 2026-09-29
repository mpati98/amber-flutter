import 'db_timestamp.dart';

class Highlight {
  const Highlight({
    required this.id,
    required this.publicationId,
    required this.quote,
    this.page,
    this.note,
    required this.createdAt,
  });

  factory Highlight.fromJson(Map<String, dynamic> json) => Highlight(
        id: json['id'] as String,
        publicationId: json['publicationId'] as String,
        quote: json['quote'] as String,
        page: json['page'] as int?,
        note: json['note'] as String?,
        createdAt: parseDbTimestamp(json['createdAt'] as String),
      );

  final String id;
  final String publicationId;
  final String quote;
  final int? page;

  /// Có trong API nhưng UI web chưa có ô nhập/hiển thị.
  final String? note;
  final DateTime createdAt;
}

/// Phần publication mà GET /highlights/random kèm theo (chỉ 3 cột).
class HighlightSource {
  const HighlightSource({required this.title, this.author, this.coverUrl});

  factory HighlightSource.fromJson(Map<String, dynamic> json) => HighlightSource(
        title: json['title'] as String,
        author: json['author'] as String?,
        coverUrl: json['coverUrl'] as String?,
      );

  final String title;
  final String? author;
  final String? coverUrl;
}

/// Response GET /highlights/random — thẻ "Ôn lại": `"quote"` — title, author.
/// Endpoint trả `null` khi chưa có highlight nào (xử lý ở tầng service).
class ResurfacedHighlight {
  const ResurfacedHighlight({required this.highlight, this.source});

  factory ResurfacedHighlight.fromJson(Map<String, dynamic> json) => ResurfacedHighlight(
        highlight: Highlight.fromJson(json),
        source: json['publication'] == null
            ? null
            : HighlightSource.fromJson(json['publication'] as Map<String, dynamic>),
      );

  final Highlight highlight;

  /// FK bắt buộc nên thực tế luôn có — để nullable giống web (`publication?`).
  final HighlightSource? source;
}

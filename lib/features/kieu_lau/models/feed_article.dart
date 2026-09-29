class FeedArticle {
  const FeedArticle({
    required this.id,
    required this.title,
    required this.url,
    this.publishedAt,
    required this.sourceName,
  });

  factory FeedArticle.fromJson(Map<String, dynamic> json) => FeedArticle(
        id: json['id'] as String,
        title: json['title'] as String,
        url: json['url'] as String,
        publishedAt: json['publishedAt'] == null ? null : DateTime.parse(json['publishedAt'] as String),
        sourceName: json['sourceName'] as String,
      );

  final String id;
  final String title;
  final String url;
  final DateTime? publishedAt;
  final String sourceName;
}

class FeedSource {
  const FeedSource({required this.id, required this.name, required this.url, required this.createdAt});

  factory FeedSource.fromJson(Map<String, dynamic> json) => FeedSource(
        id: json['id'] as String,
        name: json['name'] as String,
        url: json['url'] as String,
        createdAt: DateTime.parse(json['createdAt'] as String),
      );

  final String id;
  final String name;

  /// URL RSS.
  final String url;
  final DateTime createdAt;
}

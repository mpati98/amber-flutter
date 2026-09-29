import 'db_timestamp.dart';
import 'topic.dart';

// Enum Dart (pgEnum ở DB, cùng lý do như PublicationStatus bên publication.dart).
enum DocumentType {
  text('TEXT'),
  checklist('CHECKLIST'),
  mindmap('MINDMAP'),
  image('IMAGE'),
  file('FILE'),
  unknown('');

  const DocumentType(this.apiValue);

  final String apiValue;

  /// TEXT/CHECKLIST/MINDMAP lưu nội dung ở `content`; IMAGE/FILE lưu ở `attachmentUrl`.
  bool get hasTextContent => this == text || this == checklist || this == mindmap;

  static DocumentType fromApi(String value) => values.firstWhere((t) => t.apiValue == value, orElse: () => unknown);
}

class Document {
  const Document({
    required this.id,
    required this.title,
    required this.type,
    this.content,
    this.attachmentUrl,
    required this.tags,
    required this.pinned,
    this.sourceUrl,
    this.topicId,
    this.topic,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Document.fromJson(Map<String, dynamic> json) => Document(
        id: json['id'] as String,
        title: json['title'] as String,
        type: DocumentType.fromApi(json['type'] as String),
        content: json['content'] as String?,
        attachmentUrl: json['attachmentUrl'] as String?,
        tags: parseTags(json['tags']),
        pinned: json['pinned'] as bool,
        sourceUrl: json['sourceUrl'] as String?,
        topicId: json['topicId'] as String?,
        topic: json['topic'] == null ? null : Topic.fromJson(json['topic'] as Map<String, dynamic>),
        createdAt: parseDbTimestamp(json['createdAt'] as String),
        updatedAt: parseDbTimestamp(json['updatedAt'] as String),
      );

  final String id;
  final String title;
  final DocumentType type;

  /// Markdown thô: TEXT tự do, CHECKLIST `- [ ]`/`- [x]`, MINDMAP `#` heading + gạch đầu dòng.
  final String? content;

  /// Đường dẫn tương đối `/api/tang-kinh-cac/blob/...` (IMAGE/FILE).
  final String? attachmentUrl;

  /// Chưa dùng ở UI.
  final List<String> tags;
  final bool pinned;

  /// Chưa dùng ở UI.
  final String? sourceUrl;
  final String? topicId;

  /// Mọi response documents đều kèm quan hệ topic (null nếu không gán topic).
  final Topic? topic;
  final DateTime createdAt;

  /// Danh sách sắp xếp theo trường này (mới nhất trước).
  final DateTime updatedAt;
}

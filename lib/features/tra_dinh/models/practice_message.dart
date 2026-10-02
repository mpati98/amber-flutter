enum MessageRole {
  user('USER'),
  assistant('ASSISTANT');

  const MessageRole(this.apiValue);

  final String apiValue;

  /// Giá trị lạ coi như assistant (hiện bên trái) — chỉ USER mới là người học.
  static MessageRole fromApi(String? value) => value == user.apiValue ? user : assistant;
}

/// 1 dòng practice_messages. Có trong GET /tra-dinh/sessions/[id]
/// (`practiceMessages`, cũ trước) và trong response POST .../messages.
class PracticeMessage {
  const PracticeMessage({
    required this.id,
    required this.role,
    required this.content,
    this.audioUrl,
    required this.createdAt,
  });

  factory PracticeMessage.fromJson(Map<String, dynamic> json) => PracticeMessage(
    id: json['id'] as String,
    role: MessageRole.fromApi(json['role'] as String?),
    content: json['content'] as String,
    audioUrl: json['audioUrl'] as String?,
    createdAt: DateTime.parse(json['createdAt'] as String),
  );

  final String id;
  final MessageRole role;

  /// Văn bản thô — tin của AI có thể chứa markdown (`**...**`), web cũng hiện thô.
  final String content;

  /// Cột có sẵn nhưng hiện chưa nơi nào ghi (web không upload ghi âm).
  final String? audioUrl;
  final DateTime createdAt;

  bool get isUser => role == MessageRole.user;
}

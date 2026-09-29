class Topic {
  const Topic({required this.id, required this.name, this.description, this.documentCount});

  factory Topic.fromJson(Map<String, dynamic> json) => Topic(
        id: json['id'] as String,
        name: json['name'] as String,
        description: json['description'] as String?,
        documentCount: (json['_count'] as Map<String, dynamic>?)?['documents'] as int?,
      );

  /// Dữ liệu cũ là cuid (Prisma), dữ liệu mới là UUID — đều là chuỗi.
  final String id;

  /// Duy nhất (backend upsert theo name).
  final String name;
  final String? description;

  /// Chỉ có khi lấy từ GET /topics (`_count.documents`); null khi topic đi kèm
  /// trong 1 document.
  final int? documentCount;
}

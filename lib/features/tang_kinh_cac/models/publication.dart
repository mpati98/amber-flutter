import 'db_timestamp.dart';

// Enum Dart thay vì String thô: các giá trị này là pgEnum ở DB, muốn thêm giá
// trị mới phải chạy migration — hiếm và có chủ đích. Enum cho phép switch đầy
// đủ khi map nhãn/màu (StatusBadge...), compiler bắt chỗ quên xử lý. Giá trị
// lạ vẫn không làm vỡ app: rơi vào `unknown` thay vì throw.

enum PublicationFormat {
  physical('PHYSICAL'),
  ebook('EBOOK'),
  audiobook('AUDIOBOOK'),
  unknown('');

  const PublicationFormat(this.apiValue);

  final String apiValue;

  static PublicationFormat fromApi(String value) =>
      values.firstWhere((f) => f.apiValue == value, orElse: () => unknown);
}

enum PublicationStatus {
  toRead('TO_READ'),
  reading('READING'),
  read('READ'),
  abandoned('ABANDONED'),
  unknown('');

  const PublicationStatus(this.apiValue);

  final String apiValue;

  static PublicationStatus fromApi(String value) =>
      values.firstWhere((s) => s.apiValue == value, orElse: () => unknown);
}

class Publication {
  const Publication({
    required this.id,
    required this.title,
    this.author,
    this.isbn,
    this.coverUrl,
    required this.format,
    required this.status,
    this.rating,
    this.currentPage,
    this.totalPages,
    required this.tags,
    this.url,
    this.review,
    this.notes,
    required this.dateAdded,
    this.dateStarted,
    this.dateFinished,
  });

  factory Publication.fromJson(Map<String, dynamic> json) => Publication(
        id: json['id'] as String,
        title: json['title'] as String,
        author: json['author'] as String?,
        isbn: json['isbn'] as String?,
        coverUrl: json['coverUrl'] as String?,
        format: PublicationFormat.fromApi(json['format'] as String),
        status: PublicationStatus.fromApi(json['status'] as String),
        rating: json['rating'] as int?,
        currentPage: json['currentPage'] as int?,
        totalPages: json['totalPages'] as int?,
        tags: parseTags(json['tags']),
        url: json['url'] as String?,
        review: json['review'] as String?,
        notes: json['notes'] as String?,
        dateAdded: parseDbTimestamp(json['dateAdded'] as String),
        dateStarted: parseDbTimestampOrNull(json['dateStarted']),
        dateFinished: parseDbTimestampOrNull(json['dateFinished']),
      );

  final String id;
  final String title;
  final String? author;

  /// Chưa dùng ở UI.
  final String? isbn;

  /// Đường dẫn tương đối `/api/tang-kinh-cac/blob/...` — cần ghép baseUrl và
  /// gửi kèm Bearer khi tải ảnh (route blob có withAuth).
  final String? coverUrl;
  final PublicationFormat format;
  final PublicationStatus status;

  /// 1-5, chỉ đặt khi đã đọc (validate ở UI, DB không ràng buộc).
  final int? rating;
  final int? currentPage;
  final int? totalPages;

  /// Chưa dùng ở UI.
  final List<String> tags;

  /// Chưa dùng ở UI.
  final String? url;

  /// "Review dài..." trong BookDetailModal.
  final String? review;

  /// "Ghi chú nhanh..." trong BookDetailModal — tên field thật là `notes`.
  final String? notes;
  final DateTime dateAdded;

  /// Backend tự set khi status chuyển sang READING (nếu chưa có).
  final DateTime? dateStarted;

  /// Backend tự set khi status chuyển sang READ; về TO_READ thì xoá cả 2 ngày.
  final DateTime? dateFinished;
}

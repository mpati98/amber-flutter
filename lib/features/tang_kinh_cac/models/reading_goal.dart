/// Response GET /reading-goals/{year}: mục tiêu của năm + tiến độ backend tự tính
/// từ các publication READ có dateFinished trong năm. Luôn trả về, kể cả khi
/// chưa đặt mục tiêu (targetBooks/targetPages/note = null).
///
/// GET /reading-goals (danh sách) trả shape khác — `{id, year, targetBooks,
/// targetPages, note}`, không có booksRead/pagesRead — UI web không dùng nên
/// chưa có model.
class ReadingGoal {
  const ReadingGoal({
    required this.year,
    this.targetBooks,
    this.targetPages,
    this.note,
    required this.booksRead,
    required this.pagesRead,
  });

  factory ReadingGoal.fromJson(Map<String, dynamic> json) => ReadingGoal(
        year: json['year'] as int,
        targetBooks: json['targetBooks'] as int?,
        targetPages: json['targetPages'] as int?,
        note: json['note'] as String?,
        booksRead: json['booksRead'] as int,
        pagesRead: json['pagesRead'] as int,
      );

  final int year;
  final int? targetBooks;

  /// Chưa có ô nhập ở UI web (chỉ nhập số sách).
  final int? targetPages;
  final String? note;
  final int booksRead;

  /// Tổng totalPages của các sách đã đọc trong năm (sách thiếu totalPages tính 0).
  final int pagesRead;

  /// % theo số sách, 0 nếu chưa đặt mục tiêu — giống vòng tiến độ bên web.
  int get percent => (targetBooks ?? 0) > 0 ? (booksRead * 100 / targetBooks!).round().clamp(0, 100) : 0;
}

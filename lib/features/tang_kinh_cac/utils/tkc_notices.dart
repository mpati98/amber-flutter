import '../../../shared/utils/vn_time.dart';
import '../models/document.dart';
import '../models/publication.dart';
import '../models/reading_goal.dart';
import '../services/document_api.dart';
import '../services/publication_api.dart';
import '../services/reading_goal_api.dart';

/// Dòng thông báo chung của popup Tàng Kinh Các trên cảnh 3D (`setTowerNotices('tangkinh', …)`), chỉ từ dữ liệu có sẵn:
/// 1. số mục mới 7 ngày qua (sách theo ngày thêm, tài liệu theo ngày tạo) — bỏ nếu 0;
/// 2. mục tiêu đọc năm nay (x / y sách) hoặc "chưa đặt mục tiêu";
/// 3. cuốn đang đọc (trang hiện tại / tổng).
/// Phần nào null (chưa tải / lỗi) thì bỏ phần đó. Dạng `{text, lvl}` của cảnh.
List<Map<String, Object?>> buildTkcNotices({
  List<Publication>? books,
  List<Document>? docs,
  ReadingGoal? goal,
  DateTime? now,
}) {
  final at = now ?? DateTime.now();
  final weekAgo = at.subtract(const Duration(days: 7));
  final out = <Map<String, Object?>>[];
  if (books != null || docs != null) {
    final fresh = [
      for (final b in books ?? const <Publication>[]) if (b.dateAdded.isAfter(weekAgo)) b,
      for (final d in docs ?? const <Document>[]) if (d.createdAt.isAfter(weekAgo)) d,
    ].length;
    if (fresh > 0) out.add({'text': '$fresh mục mới tuần này', 'lvl': 'ok'});
  }
  if (goal != null) {
    final target = goal.targetBooks;
    out.add(
      target == null || target <= 0
          ? {'text': 'Chưa đặt mục tiêu đọc năm ${goal.year}', 'lvl': 'warn'}
          : {'text': 'Đọc ${goal.booksRead} / $target sách năm ${goal.year}', 'lvl': 'info'},
    );
  }
  final reading = books?.where((b) => b.status == PublicationStatus.reading).firstOrNull;
  if (reading != null) {
    final total = reading.totalPages;
    final pages = total != null && total > 0 ? ' · ${reading.currentPage ?? 0}/$total trang' : '';
    out.add({'text': 'Đang đọc: ${reading.title}$pages', 'lvl': 'info'});
  }
  return out;
}

/// Tải đủ nguồn rồi [buildTkcNotices]. Nguồn nào lỗi thì bỏ qua nguồn đó.
Future<List<Map<String, Object?>>> fetchTkcNotices({
  required PublicationApi publications,
  required DocumentApi documents,
  required ReadingGoalApi goals,
}) async {
  Future<T?> safe<T>(Future<T> f) => f.then<T?>((v) => v, onError: (_) => null);
  final (books, docs, goal) = await (
    safe(publications.getPublications()),
    safe(documents.getDocuments()),
    safe(goals.getReadingGoal(vnNow().year)),
  ).wait;
  return buildTkcNotices(books: books, docs: docs, goal: goal);
}

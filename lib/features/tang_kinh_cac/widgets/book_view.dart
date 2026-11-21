import 'package:dio/dio.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/theme/app_theme.dart';
import '../../../shared/theme/design_tokens.dart';
import '../../../shared/widgets/api_image.dart';
import '../../../shared/widgets/list_frame.dart';
import '../../../shared/widgets/rating_stars.dart';
import '../models/highlight.dart';
import '../models/publication.dart';
import '../providers/publication_provider.dart';
import '../services/highlight_api.dart';
import '../services/publication_api.dart';
import 'book_detail_modal.dart';
import 'status_badge.dart';

// Tầng 1 (Sách) trên màn Tàng Kinh Các: dòng sách trong khung Danh sách + phần đọc trong khung Nội dung.

/// Màu nhãn trạng thái sách trong bộ thiết kế mới.
Color bookStatusColor(PublicationStatus s) => switch (s) {
  PublicationStatus.reading => DesignColors.gold,
  PublicationStatus.read => DesignColors.success,
  PublicationStatus.toRead => DesignColors.info,
  PublicationStatus.abandoned || PublicationStatus.unknown => DesignColors.muted,
};

/// Highlight của một cuốn (khung Nội dung chỉ đọc; thêm highlight ở form sửa — BookDetailModal).
final bookHighlightsProvider = FutureProvider.autoDispose.family<List<Highlight>, String>(
  (ref, id) => ref.watch(highlightApiProvider).getHighlights(id),
);

/// Khung Nội dung của một cuốn: bìa · tên · tác giả · trạng thái, định dạng · tiến độ trang / sao · review · ghi chú ·
/// highlight. "Sửa" mở form có sẵn ([showBookDetailModal]); "Xoá" hỏi lại rồi xoá, xong gọi [onDeleted].
class BookView extends ConsumerStatefulWidget {
  const BookView({super.key, required this.book, required this.onDeleted});

  final Publication book;
  final VoidCallback onDeleted;

  @override
  ConsumerState<BookView> createState() => _BookViewState();
}

class _BookViewState extends ConsumerState<BookView> {
  bool _busy = false;

  Future<void> _edit() async {
    await showBookDetailModal(context, widget.book);
    ref.invalidate(bookHighlightsProvider(widget.book.id)); // form có thể vừa thêm highlight
  }

  Future<void> _delete() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        content: const Text('Xóa sách này khỏi Tàng Kinh Các?'),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(false), child: const Text('Huỷ')),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: AppColors.shuiro500),
            child: const Text('Xóa'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    setState(() => _busy = true);
    try {
      await ref.read(publicationApiProvider).deletePublication(widget.book.id);
      ref.invalidate(publicationsProvider);
      if (mounted) widget.onDeleted();
    } on DioException {
      if (mounted) {
        setState(() => _busy = false);
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Không xóa được, thử lại nhé.')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final b = widget.book;
    final total = b.totalPages;
    final highlights = ref.watch(bookHighlightsProvider(b.id));
    Widget section(String title, Widget child) => Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 4,
      children: [
        Text(title.toUpperCase(), style: const TextStyle(fontSize: 12, letterSpacing: 1, color: DesignColors.gold)),
        child,
      ],
    );
    return Column(
      key: ValueKey('book-view-${b.id}'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: 14,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: 14,
          children: [
            BookCover(b, width: 72, height: 102),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: 4,
                children: [
                  Text(b.title, style: DesignText.serif(fontSize: 18, fontWeight: FontWeight.w700, color: DesignColors.text)),
                  if (b.author != null) Text(b.author!, style: DesignText.muted),
                  Wrap(
                    spacing: 6,
                    runSpacing: 4,
                    children: [
                      DesignPill(b.status.label, color: bookStatusColor(b.status)),
                      DesignPill(b.format.label, color: DesignColors.muted),
                    ],
                  ),
                  if (total != null && total > 0) ...[
                    DesignProgressBar((b.currentPage ?? 0) * 100 / total),
                    Text('${b.currentPage ?? 0} / $total trang', style: DesignText.muted),
                  ],
                  if (b.rating != null) RatingStars(rating: b.rating),
                ],
              ),
            ),
          ],
        ),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            DesignButton.primary(key: const ValueKey('book-edit'), label: 'Sửa', onPressed: _busy ? null : _edit),
            DesignButton.outline(key: const ValueKey('book-delete'), label: 'Xoá', onPressed: _busy ? null : _delete),
          ],
        ),
        if (b.review case final r? when r.trim().isNotEmpty) section('Review', SelectableText(r, style: DesignText.body)),
        if (b.notes case final n? when n.trim().isNotEmpty) section('Ghi chú', SelectableText(n, style: DesignText.body)),
        section(
          'Highlight',
          highlights.when(
            loading: () => const Text('Đang tải…', style: DesignText.muted),
            error: (_, _) => const Text('Không tải được highlight.', style: DesignText.muted),
            data: (items) => items.isEmpty
                ? const Text('Chưa có highlight nào.', style: DesignText.muted)
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    spacing: 8,
                    children: [for (final h in items) _Quote(h)],
                  ),
          ),
        ),
      ],
    );
  }
}

class _Quote extends StatelessWidget {
  const _Quote(this.highlight);

  final Highlight highlight;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(left: 12),
      decoration: const BoxDecoration(border: Border(left: BorderSide(color: DesignColors.gold, width: 2))),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('"${highlight.quote}"', style: DesignText.body.copyWith(fontStyle: FontStyle.italic)),
          if (highlight.page != null) Text('trang ${highlight.page}', style: DesignText.muted),
        ],
      ),
    );
  }
}

/// Một cuốn: bìa nhỏ · tên + tác giả · nhãn trạng thái · tiến độ trang (đang đọc) hoặc sao đánh giá.
class BookRow extends StatelessWidget {
  const BookRow({super.key, required this.book, required this.onTap, this.selected = false});

  final Publication book;
  final VoidCallback onTap;

  /// Cuốn đang mở ở khung Nội dung — viền vàng.
  final bool selected;

  @override
  Widget build(BuildContext context) {
    final total = book.totalPages;
    final reading = book.status == PublicationStatus.reading && total != null && total > 0;
    return FrameTile(
      key: ValueKey('book-${book.id}'),
      onTap: onTap,
      semanticLabel: book.title,
      borderColor: selected ? DesignColors.gold : null,
      padding: const EdgeInsets.all(10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 12,
        children: [
          BookCover(book),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 2,
              children: [
                Text(book.title, maxLines: 2, overflow: TextOverflow.ellipsis, style: DesignText.bold),
                if (book.author != null) Text(book.author!, maxLines: 1, overflow: TextOverflow.ellipsis, style: DesignText.muted),
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: DesignPill(book.status.label, color: bookStatusColor(book.status)),
                ),
                if (reading) ...[
                  DesignProgressBar((book.currentPage ?? 0) * 100 / total),
                  Text('${book.currentPage ?? 0} / $total trang', style: DesignText.muted),
                ] else if (book.rating != null)
                  RatingStars(rating: book.rating),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class BookCover extends StatelessWidget {
  const BookCover(this.book, {super.key, this.width = 48, this.height = 68});

  final Publication book;
  final double width;
  final double height;

  @override
  Widget build(BuildContext context) {
    final initial = Center(
      child: Text(
        book.title.isEmpty ? '' : book.title.characters.first,
        style: const TextStyle(fontSize: 20, color: DesignColors.gold),
      ),
    );
    final url = book.coverUrl;
    return ClipRRect(
      borderRadius: BorderRadius.circular(4),
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: DesignColors.frame,
          border: Border.all(color: DesignColors.panelBorder),
          borderRadius: BorderRadius.circular(4),
        ),
        child: url == null ? initial : ApiImage(url, placeholder: initial),
      ),
    );
  }
}

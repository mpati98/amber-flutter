import 'package:dio/dio.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/theme/design_tokens.dart';
import '../../../shared/widgets/api_image.dart';
import '../../../shared/widgets/design_page.dart';
import '../../../shared/widgets/list_frame.dart';
import '../../../shared/widgets/overview_block.dart';
import '../../../shared/widgets/rating_stars.dart';
import '../models/publication.dart';
import '../providers/publication_provider.dart';
import '../widgets/add_book_modal.dart';
import '../widgets/book_detail_modal.dart';
import '../widgets/status_badge.dart';

// Thứ tự giống bộ lọc bên web (null = Tất cả).
const _filters = <PublicationStatus?>[
  null,
  PublicationStatus.reading,
  PublicationStatus.toRead,
  PublicationStatus.read,
  PublicationStatus.abandoned,
];

/// Màu nhãn trạng thái sách trong bộ thiết kế mới.
Color _statusColor(PublicationStatus s) => switch (s) {
  PublicationStatus.reading => DesignColors.gold,
  PublicationStatus.read => DesignColors.success,
  PublicationStatus.toRead => DesignColors.info,
  PublicationStatus.abandoned || PublicationStatus.unknown => DesignColors.muted,
};

/// /tang-kinh-cac/sach (Tầng 1): Tổng quan (đếm theo trạng thái · cuốn đang đọc) → khung có chip lọc + "+ Thêm sách" → các cuốn.
/// Bấm một cuốn mở modal chi tiết như trước.
class SachScreen extends ConsumerStatefulWidget {
  const SachScreen({super.key});

  @override
  ConsumerState<SachScreen> createState() => _SachScreenState();
}

class _SachScreenState extends ConsumerState<SachScreen> {
  PublicationStatus? _filter;

  @override
  Widget build(BuildContext context) {
    // Tổng quan luôn đếm trên toàn bộ tủ sách, không theo chip đang chọn.
    final all = ref.watch(publicationsProvider(null));
    final books = ref.watch(publicationsProvider(_filter));

    return DesignPage(
      title: 'Sách',
      backFallback: '/tang-kinh-cac',
      onRefresh: () async {
        ref.invalidate(publicationsProvider);
        await ref.read(publicationsProvider(_filter).future).then<void>((_) {}, onError: (_) {});
      },
      overview: OverviewBlock(
        title: 'Tủ sách',
        labelWidth: 90,
        rows: [
          OverviewRow.muted(label: 'Số sách', text: _counts(all)),
          OverviewRow.muted(label: 'Đang đọc', text: _reading(all)),
        ],
      ),
      content: (context, _) => ListFrame(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          spacing: 8,
          children: [
            FrameToolbar(
              chips: DesignChipRow<PublicationStatus?>(
                items: [for (final f in _filters) (f, f?.label ?? 'Tất cả')],
                selected: _filter,
                onSelected: (f) => setState(() => _filter = f),
              ),
              action: DesignButton.outline(
                key: const ValueKey('add-book'),
                label: '+ Thêm sách',
                onPressed: () => showAddBookModal(context),
              ),
            ),
            books.when(
              loading: () => const _Message('Đang tải…'),
              error: (e, _) => _Message(
                e is DioException
                    ? 'Không tải được danh sách sách (${e.response?.statusCode ?? e.type.name}).'
                    : 'Không tải được danh sách sách.',
              ),
              data: (items) => items.isEmpty
                  ? const _Message('Chưa có sách nào trong mục này.')
                  : FrameRows(
                      children: [
                        for (final b in items) _BookRow(book: b, onTap: () => showBookDetailModal(context, b)),
                      ],
                    ),
            ),
          ],
        ),
      ),
      hint: 'Chạm vào một cuốn để xem chi tiết',
    );
  }
}

String _counts(AsyncValue<List<Publication>> all) {
  final books = all.value;
  if (books == null) return all.hasError ? 'Không tải được số liệu' : 'Đang tải...';
  int n(PublicationStatus s) => books.where((b) => b.status == s).length;
  return '${n(PublicationStatus.reading)} đang đọc · ${n(PublicationStatus.read)} đã đọc · '
      '${n(PublicationStatus.toRead)} muốn đọc';
}

String _reading(AsyncValue<List<Publication>> all) {
  final books = all.value;
  if (books == null) return all.hasError ? 'Không tải được số liệu' : 'Đang tải...';
  final reading = books.where((b) => b.status == PublicationStatus.reading).toList();
  if (reading.isEmpty) return 'Chưa đọc cuốn nào';
  final b = reading.first;
  final pages = b.totalPages != null && b.totalPages! > 0 ? ' · ${b.currentPage ?? 0}/${b.totalPages} trang' : '';
  final more = reading.length > 1 ? ' (+${reading.length - 1} cuốn)' : '';
  return '${b.title}$pages$more';
}

class _Message extends StatelessWidget {
  const _Message(this.text);

  final String text;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 24),
    child: Text(text, textAlign: TextAlign.center, style: DesignText.muted),
  );
}

/// Một cuốn: bìa nhỏ · tên + tác giả · nhãn trạng thái · tiến độ trang (đang đọc) hoặc sao đánh giá.
class _BookRow extends StatelessWidget {
  const _BookRow({required this.book, required this.onTap});

  final Publication book;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final total = book.totalPages;
    final reading = book.status == PublicationStatus.reading && total != null && total > 0;
    return FrameTile(
      key: ValueKey('book-${book.id}'),
      onTap: onTap,
      semanticLabel: book.title,
      padding: const EdgeInsets.all(10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 12,
        children: [
          _Cover(book),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 2,
              children: [
                Text(book.title, maxLines: 2, overflow: TextOverflow.ellipsis, style: DesignText.bold),
                if (book.author != null) Text(book.author!, maxLines: 1, overflow: TextOverflow.ellipsis, style: DesignText.muted),
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: DesignPill(book.status.label, color: _statusColor(book.status)),
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

class _Cover extends StatelessWidget {
  const _Cover(this.book);

  final Publication book;

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
        width: 48,
        height: 68,
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

import 'package:flutter/material.dart';

import '../../../shared/widgets/api_image.dart';
import '../../../shared/widgets/progress_bar.dart';
import '../../../shared/widgets/rating_stars.dart';
import '../../../shared/widgets/scroll_card.dart';
import '../models/publication.dart';
import 'status_badge.dart';

/// Port BookCard (amber-v3/src/components/tang-kinh-cac/BookCard.tsx): bìa
/// 80×112 bên trái, bên phải badge / tên / tác giả, đáy là tiến độ (đang đọc
/// và có tổng số trang) hoặc sao đánh giá. Hiệu ứng hover nhấc card bên web
/// bỏ qua — không có hover trên cảm ứng.
class BookCard extends StatelessWidget {
  const BookCard({super.key, required this.book, this.onTap});

  final Publication book;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final isReading = book.status == PublicationStatus.reading;
    final totalPages = book.totalPages;
    final muted = Colors.white.withValues(alpha: 0.5);

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: ScrollCard(
        glow: isReading ? ScrollCardGlow.kincha : ScrollCardGlow.yugen,
        // IntrinsicHeight để cột phải cao bằng bìa, đẩy phần đáy xuống như
        // `mt-auto` bên web.
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            spacing: 16, // gap-4
            children: [
              _Cover(book),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    StatusBadge(book.status),
                    const SizedBox(height: 8), // mt-2
                    Text(
                      book.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontSize: 18, color: Colors.white),
                    ),
                    if (book.author != null)
                      Text(
                        book.author!,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(fontSize: 14, color: muted),
                      ),
                    const Spacer(),
                    const SizedBox(height: 12), // pt-3
                    if (isReading && totalPages != null && totalPages > 0) ...[
                      ProgressBar(value: (book.currentPage ?? 0).toDouble(), max: totalPages.toDouble()),
                      const SizedBox(height: 4),
                      Text(
                        '${book.currentPage ?? 0} / $totalPages trang',
                        style: TextStyle(fontSize: 12, color: Colors.white.withValues(alpha: 0.4)),
                      ),
                    ] else
                      RatingStars(rating: book.rating),
                  ],
                ),
              ),
            ],
          ),
        ),
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
        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontSize: 24, // text-2xl
              color: Colors.white.withValues(alpha: 0.2),
            ),
      ),
    );
    final coverUrl = book.coverUrl;

    return ClipRRect(
      borderRadius: BorderRadius.circular(2), // rounded-sm
      child: Container(
        width: 80, // w-20
        height: 112, // h-28
        color: Colors.white.withValues(alpha: 0.05),
        child: coverUrl == null ? initial : ApiImage(coverUrl, placeholder: initial),
      ),
    );
  }
}

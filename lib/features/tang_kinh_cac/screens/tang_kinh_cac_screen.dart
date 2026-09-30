import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/theme/app_theme.dart';
import '../../../shared/widgets/scroll_card.dart';
import '../models/highlight.dart';
import '../models/publication.dart';
import '../providers/document_provider.dart';
import '../providers/publication_provider.dart';
import '../providers/tang_kinh_cac_provider.dart';
import '../widgets/section_card.dart';
import 'ke_hoach_doc_screen.dart';
import 'sach_screen.dart';
import 'tai_lieu_screen.dart';

/// Port /tang-kinh-cac (trang chính của tòa): thẻ "Ôn lại" + 3 lối vào.
/// Xếp 1 cột thay cho lưới 1-3 cột bên web.
class TangKinhCacScreen extends ConsumerWidget {
  const TangKinhCacScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final year = DateTime.now().year;
    final highlight = ref.watch(resurfacedHighlightProvider).value;

    // Giống web: đếm trên toàn bộ danh sách ở client.
    final bookStat = ref.watch(publicationsProvider(null)).when(
          data: (books) {
            int count(PublicationStatus s) => books.where((b) => b.status == s).length;
            return '${count(PublicationStatus.reading)} đang đọc · '
                '${count(PublicationStatus.read)} đã đọc · '
                '${count(PublicationStatus.toRead)} muốn đọc';
          },
          loading: () => 'Đang tải...',
          error: (_, _) => 'Không tải được số liệu',
        );
    final docStat = ref.watch(documentsProvider(null)).when(
          data: (docs) => '${docs.length} tài liệu đã lưu',
          loading: () => 'Đang tải...',
          error: (_, _) => 'Không tải được số liệu',
        );
    final goalStat = ref.watch(readingGoalProvider(year)).when(
          data: (g) => g.targetBooks != null && g.targetBooks! > 0
              ? '${g.booksRead}/${g.targetBooks} sách năm ${g.year}'
              : 'Chưa đặt mục tiêu',
          loading: () => 'Đang tải...',
          error: (_, _) => 'Không tải được số liệu',
        );

    void push(Widget screen) => Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => screen));

    return Scaffold(
      appBar: AppBar(title: const Text('Tàng Kinh Các')),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 640),
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Chưa có highlight nào thì ẩn hẳn thẻ (giống web), không hiện thẻ rỗng.
              if (highlight != null) ...[
                _ResurfaceCard(highlight),
                const SizedBox(height: 32), // space-y-8
              ],
              SectionCard(
                icon: '📚',
                title: 'Sách',
                description: 'Thư viện sách đang đọc, đã đọc và muốn đọc — kèm review và highlight.',
                stat: bookStat,
                glow: ScrollCardGlow.kincha,
                onTap: () => push(const SachScreen()),
              ),
              const SizedBox(height: 20), // gap-5
              SectionCard(
                icon: '🗂',
                title: 'Tài liệu',
                description: 'Ghi chú, checklist, mindmap, hình ảnh và tệp bạn muốn lưu lại để xem sau.',
                stat: docStat,
                glow: ScrollCardGlow.yugen,
                onTap: () => push(const TaiLieuScreen()),
              ),
              const SizedBox(height: 20),
              SectionCard(
                icon: '🎯',
                title: 'Kế hoạch đọc',
                description: 'Đặt mục tiêu đọc theo năm và theo dõi tiến độ.',
                stat: goalStat,
                glow: ScrollCardGlow.shuiro,
                onTap: () => push(const KeHoachDocScreen()),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ResurfaceCard extends StatelessWidget {
  const _ResurfaceCard(this.resurfaced);

  final ResurfacedHighlight resurfaced;

  @override
  Widget build(BuildContext context) {
    final source = resurfaced.source;
    return ScrollCard(
      glow: ScrollCardGlow.kincha,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'ÔN LẠI',
            style: TextStyle(fontSize: 12, letterSpacing: 12 * 0.05, color: AppColors.kincha400.withValues(alpha: 0.8)),
          ),
          const SizedBox(height: 8),
          Text(
            '"${resurfaced.highlight.quote}"',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontSize: 16,
                  height: 1.6,
                  fontStyle: FontStyle.italic,
                  color: Colors.white.withValues(alpha: 0.85),
                ),
          ),
          if (source != null) ...[
            const SizedBox(height: 8),
            Text(
              '— ${source.title}${source.author != null ? ', ${source.author}' : ''}',
              style: TextStyle(fontSize: 14, color: Colors.white.withValues(alpha: 0.4)),
            ),
          ],
        ],
      ),
    );
  }
}

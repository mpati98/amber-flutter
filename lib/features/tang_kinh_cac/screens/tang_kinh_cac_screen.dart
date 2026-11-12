import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../shared/theme/design_tokens.dart';
import '../../../shared/widgets/design_page.dart';
import '../../../shared/widgets/list_frame.dart';
import '../../../shared/widgets/overview_block.dart';
import '../../du_lieu_huan_luyen/providers/training_log_provider.dart';
import '../models/publication.dart';
import '../providers/document_provider.dart';
import '../providers/publication_provider.dart';
import '../providers/tang_kinh_cac_provider.dart';

/// 4 tầng theo design/ref/tang-kinh-cac.html: (tầng, chữ Hán, tên, mô tả, đường dẫn con).
const _floors = [
  (n: 1, glyph: '書', title: 'Sách', sub: 'Đang đọc, đã đọc, muốn đọc · review & highlight', path: 'sach'),
  (n: 2, glyph: '檔', title: 'Tài liệu', sub: 'Ghi chú, checklist, mindmap, hình ảnh', path: 'tai-lieu'),
  (n: 3, glyph: '標', title: 'Kế hoạch đọc', sub: 'Mục tiêu đọc theo năm, theo dõi tiến độ', path: 'ke-hoach-doc'),
  (n: 4, glyph: '訓', title: 'Dữ liệu huấn luyện', sub: 'Nhật ký amber-brain: xem, đánh giá đúng/sai', path: 'du-lieu-huan-luyen'),
];

const _loading = 'Đang tải...';
const _failed = 'Không tải được số liệu';

/// /tang-kinh-cac: Tổng quan (số liệu từng tầng + câu "Ôn lại" nếu có highlight) → khung 4 tầng.
/// Bản mẫu chỉ có 3 dòng tổng quan; thêm "Huấn luyện" (số mẫu đủ điều kiện) và "Ôn lại" để không mất thông tin màn cũ có.
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
      loading: () => _loading,
      error: (_, _) => _failed,
    );
    final docStat = ref.watch(documentsProvider(null)).when(
      data: (docs) => '${docs.length} tài liệu đã lưu',
      loading: () => _loading,
      error: (_, _) => _failed,
    );
    final goalStat = ref.watch(readingGoalProvider(year)).when(
      data: (g) => g.targetBooks != null && g.targetBooks! > 0
          ? '${g.booksRead}/${g.targetBooks} sách năm ${g.year}'
          : 'Chưa đặt mục tiêu',
      loading: () => _loading,
      error: (_, _) => _failed,
    );
    // Mục riêng, dùng provider/API riêng (không lẫn với sách, tài liệu): số mẫu đủ điều kiện train.
    final trainStat = ref.watch(trainingStatsProvider).when(
      data: (s) => '${s.eligible} mẫu đủ điều kiện · ${s.total} dòng',
      loading: () => _loading,
      error: (_, _) => _failed,
    );

    return DesignPage(
      title: 'Tàng Kinh Các',
      overview: OverviewBlock(
        title: 'Tổng quan',
        labelWidth: 90,
        rows: [
          OverviewRow.muted(label: 'Sách', text: bookStat),
          OverviewRow.muted(label: 'Tài liệu', text: docStat),
          OverviewRow.muted(label: 'Kế hoạch đọc', text: goalStat),
          OverviewRow.muted(label: 'Huấn luyện', text: trainStat),
          // Chưa có highlight nào thì không có dòng này.
          if (highlight != null)
            OverviewRow(
              key: const ValueKey('tkc-resurface'),
              label: 'Ôn lại',
              child: Text.rich(
                TextSpan(
                  children: [
                    TextSpan(text: '"${highlight.highlight.quote}"', style: const TextStyle(fontStyle: FontStyle.italic)),
                    if (highlight.source case final s?)
                      TextSpan(text: ' — ${s.title}${s.author != null ? ', ${s.author}' : ''}', style: DesignText.muted),
                  ],
                ),
              ),
            ),
        ],
      ),
      content: (context, _) => ListFrame(
        child: FrameRows(
          children: [
            for (final f in _floors)
              FrameRow(
                key: ValueKey('tkc-${f.path}'),
                leading: _FloorNumber(f.n),
                glyph: f.glyph,
                title: f.title,
                subtitle: f.sub,
                onTap: () => context.push('/tang-kinh-cac/${f.path}'),
              ),
          ],
        ),
      ),
      hint: 'Chạm vào một tầng để vào',
    );
  }
}

/// Cột "TẦNG / số" vàng bên trái mỗi dòng, kẻ dọc ngăn với phần còn lại.
class _FloorNumber extends StatelessWidget {
  const _FloorNumber(this.n);

  final int n;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 52,
      padding: const EdgeInsets.only(right: 10),
      decoration: const BoxDecoration(border: Border(right: BorderSide(color: DesignColors.panelBorder))),
      child: Column(
        children: [
          const Text('TẦNG', style: TextStyle(fontSize: 12, letterSpacing: 1, color: DesignColors.gold)),
          Text('$n', style: const TextStyle(fontSize: 22, height: 1.2, color: DesignColors.gold)),
        ],
      ),
    );
  }
}

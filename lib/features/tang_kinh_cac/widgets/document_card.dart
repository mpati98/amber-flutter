import 'package:material_ui/material_ui.dart';

import '../../../shared/theme/design_tokens.dart';
import '../../../shared/widgets/list_frame.dart';
import '../models/document.dart';
import 'type_tag.dart';

// Chỉ nhận cú pháp ở ĐẦU dòng — khớp cách ChecklistView/MindmapOutline bên
// web đọc nội dung (`^\s*-\s*\[[ xX]\]`, `^#{1,6}\s+`).
final _heading = RegExp(r'^\s*#{1,6}\s+');
final _checkbox = RegExp(r'^\s*(-\s*)?\[[ xX]\]\s*');
final _bullet = RegExp(r'^\s*-\s+');
final _spaces = RegExp(r'\s+');

/// Văn bản xem trước trên DocumentCard: bỏ ký hiệu markdown ở đầu dòng
/// (`# ` heading, `- [ ]`/`- [x]` checklist, `- ` gạch đầu dòng) rồi nối các
/// dòng bằng dấu cách — web hiển thị trong `<p>` nên xuống dòng cũng thành cách.
///
/// Sửa lỗi bên web: web dùng `replace(/[#\-\[\]xX]/g, "")`, xoá MỌI chữ x/X,
/// mọi dấu `-`, `[`, `]` ở bất kỳ đâu ("xfreerdp3" → "freerdp3", "Wi-Fi" → "WiFi").
String documentPreview(String content) => content
    .split('\n')
    .map((line) => line.replaceFirst(_heading, '').replaceFirst(_checkbox, '').replaceFirst(_bullet, '').trim())
    .where((line) => line.isNotEmpty)
    .join(' ')
    .replaceAll(_spaces, ' ');

/// Chữ Hán cho từng loại tài liệu (vòng tròn vàng bên trái dòng, như các mục của bộ thiết kế mới).
String documentGlyph(DocumentType t) => switch (t) {
  DocumentType.text => '文',
  DocumentType.checklist => '單',
  DocumentType.mindmap => '圖',
  DocumentType.image => '像',
  DocumentType.file => '檔',
  DocumentType.unknown => '書',
};

/// Một tài liệu trong khung của màn Tài liệu (bộ thiết kế mới): chữ Hán theo loại · tên · xem trước 2 dòng ·
/// nhãn loại + chủ đề + "ghim". Không hiện ngày (updatedAt chỉ để sắp xếp), IMAGE / FILE không có xem trước.
class DocumentCard extends StatelessWidget {
  const DocumentCard({super.key, required this.doc, this.onTap});

  final Document doc;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final content = doc.content;
    final preview = doc.type.hasTextContent && content != null ? documentPreview(content) : '';
    final topic = doc.topic;

    return FrameRow(
      key: ValueKey('doc-${doc.id}'),
      glyph: documentGlyph(doc.type),
      title: doc.title,
      borderColor: doc.pinned ? DesignColors.gold.withValues(alpha: 0.5) : null,
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (preview.isNotEmpty) Text(preview, maxLines: 2, overflow: TextOverflow.ellipsis, style: DesignText.muted),
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Wrap(
              spacing: 6,
              runSpacing: 4,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                DesignPill(doc.type.label, color: DesignColors.info),
                if (topic != null) Text(topic.name, style: DesignText.muted),
                if (doc.pinned) const Text('📌 ghim', style: TextStyle(fontSize: 12, color: DesignColors.gold)),
              ],
            ),
          ),
        ],
      ),
      onTap: onTap,
    );
  }
}

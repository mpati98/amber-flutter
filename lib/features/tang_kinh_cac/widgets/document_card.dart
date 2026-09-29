import 'package:flutter/material.dart';

import '../../../shared/theme/app_theme.dart';
import '../../../shared/widgets/scroll_card.dart';
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

/// Port DocumentCard (amber-v3/src/components/tang-kinh-cac/DocumentCard.tsx).
/// Không hiện ngày (updatedAt chỉ để sắp xếp), IMAGE cũng chỉ hiện icon.
class DocumentCard extends StatelessWidget {
  const DocumentCard({super.key, required this.doc, this.onTap});

  final Document doc;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final content = doc.content;
    final preview = doc.type.hasTextContent && content != null ? documentPreview(content) : '';
    final topic = doc.topic;

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: ScrollCard(
        glow: doc.pinned ? ScrollCardGlow.kincha : ScrollCardGlow.yugen,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(doc.type.icon, style: const TextStyle(fontSize: 18)), // text-lg
                const Spacer(),
                TypeTag(doc.type),
              ],
            ),
            const SizedBox(height: 8), // mb-2
            Text(
              doc.title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontSize: 16, color: Colors.white),
            ),
            if (preview.isNotEmpty) ...[
              const SizedBox(height: 4), // mt-1
              Text(
                preview,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(fontSize: 14, color: Colors.white.withValues(alpha: 0.5)),
              ),
            ],
            if (topic != null || doc.pinned) ...[
              const SizedBox(height: 12), // mt-3
              Row(
                children: [
                  // Có hay không có topic, "ghim" vẫn ở bên phải (web: justify-between
                  // với 1 phần tử thì nó dạt sang trái).
                  if (topic != null)
                    Expanded(
                      child: Text(
                        topic.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 12, color: AppColors.yugen300),
                      ),
                    )
                  else
                    const Spacer(),
                  if (doc.pinned) const Text('📌 ghim', style: TextStyle(fontSize: 12, color: AppColors.kincha400)),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

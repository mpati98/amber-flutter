import 'package:flutter/material.dart';

import '../../../shared/widgets/tag.dart';
import '../models/document.dart';

extension DocumentTypeDisplay on DocumentType {
  String get label => switch (this) {
        DocumentType.text => 'Ghi chú',
        DocumentType.checklist => 'Checklist',
        DocumentType.mindmap => 'Mindmap',
        DocumentType.image => 'Hình ảnh',
        DocumentType.file => 'Tệp',
        DocumentType.unknown => 'Khác',
      };

  String get icon => switch (this) {
        DocumentType.text => '📝',
        DocumentType.checklist => '☑',
        DocumentType.mindmap => '🌳',
        DocumentType.image => '🖼',
        DocumentType.file => '📎',
        DocumentType.unknown => '📄',
      };
}

/// Port TypeTag (tang-kinh-cac/ui.tsx): viền white/15, chữ white/50, 10px viết hoa.
class TypeTag extends StatelessWidget {
  const TypeTag(this.type, {super.key});

  final DocumentType type;

  @override
  Widget build(BuildContext context) {
    return Tag(
      label: type.label,
      color: Colors.white,
      foregroundColor: Colors.white.withValues(alpha: 0.5),
      borderAlpha: 0.15,
      uppercase: true,
      fontSize: 10,
    );
  }
}

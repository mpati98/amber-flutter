// Đọc/sửa nội dung markdown thô của Document (CHECKLIST, MINDMAP) — port từ
// ChecklistView.tsx và MindmapOutline.tsx bên amber-v3.

// ---------------------------------------------------------------- Checklist

final _checkLine = RegExp(r'^\s*-\s*\[([ xX])\]\s*(.*)');
final _checkMark = RegExp(r'^(\s*-\s*\[)([ xX])(\])');

class ChecklistItem {
  const ChecklistItem({required this.lineIndex, required this.checked, required this.label});

  /// Vị trí dòng trong content gốc — để đảo đúng dòng khi bấm.
  final int lineIndex;
  final bool checked;
  final String label;
}

/// Chỉ lấy các dòng `- [ ]` / `- [x]`; dòng khác bị bỏ qua (giống web).
List<ChecklistItem> parseChecklist(String content) {
  final lines = content.split('\n');
  return [
    for (var i = 0; i < lines.length; i++)
      if (_checkLine.firstMatch(lines[i]) case final m?)
        ChecklistItem(lineIndex: i, checked: m.group(1)!.toLowerCase() == 'x', label: m.group(2)!),
  ];
}

/// Đảo ô checkbox ở ĐẦU dòng [lineIndex], giữ nguyên mọi dòng khác.
/// Sửa lỗi web: web tìm `- [ ]` ở bất kỳ đâu trong dòng nên `- [x] a - [ ] b`
/// bị đổi nhầm ô `[ ]` ở giữa dòng.
String toggleChecklistLine(String content, int lineIndex) {
  final lines = content.split('\n');
  lines[lineIndex] = lines[lineIndex].replaceFirstMapped(
    _checkMark,
    (m) => '${m[1]}${m[2] == ' ' ? 'x' : ' '}${m[3]}',
  );
  return lines.join('\n');
}

// ------------------------------------------------------------------ Mindmap

class OutlineNode {
  OutlineNode(this.label);

  final String label;
  final List<OutlineNode> children = [];
}

final _headingLine = RegExp(r'^(#{1,6})\s+(.*)');
final _bulletLine = RegExp(r'^(\s*)-\s*(?:\[[ xX]\]\s*)?(.*)');

/// `#`..`######` heading → cấp theo số dấu #; gạch đầu dòng → cấp = heading
/// gần nhất + 1 + (thụt lề / 2). Dòng khác bỏ qua. Giống hệt parseOutline bên web.
List<OutlineNode> parseOutline(String md) {
  final root = OutlineNode('root');
  final stack = <({int level, OutlineNode node})>[(level: 0, node: root)];
  var lastHeadingLevel = 0;

  for (final raw in md.split('\n').where((l) => l.trim().isNotEmpty)) {
    final int level;
    final String label;
    if (_headingLine.firstMatch(raw) case final h?) {
      level = h.group(1)!.length;
      label = h.group(2)!;
      lastHeadingLevel = level;
    } else if (_bulletLine.firstMatch(raw) case final b?) {
      level = lastHeadingLevel + 1 + b.group(1)!.length ~/ 2;
      label = b.group(2)!;
    } else {
      continue;
    }

    while (stack.length > 1 && stack.last.level >= level) {
      stack.removeLast();
    }
    final node = OutlineNode(label);
    stack.last.node.children.add(node);
    stack.add((level: level, node: node));
  }
  return root.children;
}

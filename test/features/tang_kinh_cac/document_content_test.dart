import 'package:amber_flutter/features/tang_kinh_cac/utils/document_content.dart';
import 'package:flutter_test/flutter_test.dart';

/// Cây → chuỗi gọn để so sánh: "A(B(C),D)".
String tree(List<OutlineNode> nodes) =>
    nodes.map((n) => n.children.isEmpty ? n.label : '${n.label}(${tree(n.children)})').join(',');

void main() {
  group('checklist', () {
    const content = 'Việc hôm nay\n- [ ] Mua sữa\n- [x] Gửi mail\n  - [X] Việc con\nghi chú tự do';

    test('chỉ lấy dòng checkbox, nhớ đúng vị trí dòng', () {
      final items = parseChecklist(content);
      expect(items.map((i) => (i.lineIndex, i.checked, i.label)), [
        (1, false, 'Mua sữa'),
        (2, true, 'Gửi mail'),
        (3, true, 'Việc con'),
      ]);
    });

    test('đảo đúng 1 dòng, các dòng khác giữ nguyên từng ký tự', () {
      expect(toggleChecklistLine(content, 1),
          'Việc hôm nay\n- [x] Mua sữa\n- [x] Gửi mail\n  - [X] Việc con\nghi chú tự do');
      expect(toggleChecklistLine(content, 3),
          'Việc hôm nay\n- [ ] Mua sữa\n- [x] Gửi mail\n  - [ ] Việc con\nghi chú tự do');
    });

    test('đảo 2 lần về như cũ', () {
      expect(toggleChecklistLine(toggleChecklistLine(content, 2), 2), content);
    });

    test('sửa lỗi web: chỉ đổi ô ở đầu dòng, không đụng "[ ]" giữa dòng', () {
      expect(toggleChecklistLine('- [x] a - [ ] b', 0), '- [ ] a - [ ] b');
      expect(toggleChecklistLine('- [ ] mảng arr[x]', 0), '- [x] mảng arr[x]');
    });
  });

  group('mindmap', () {
    test('heading nhiều cấp', () {
      expect(tree(parseOutline('# A\n## B\n### C\n## D')), 'A(B(C),D)');
    });

    test('gạch đầu dòng dưới heading, thụt 2 dấu cách = 1 cấp', () {
      expect(tree(parseOutline('# Chủ đề\n- ý 1\n  - ý con\n    - cháu\n- ý 2')), 'Chủ đề(ý 1(ý con(cháu)),ý 2)');
    });

    test('thụt 4 dấu cách nhảy 2 cấp vẫn gắn vào nút gần nhất', () {
      expect(tree(parseOutline('# A\n- b\n    - c')), 'A(b(c))');
    });

    test('heading mới sau nhánh sâu thì quay lại đúng cấp', () {
      expect(tree(parseOutline('# A\n## B\n- b1\n  - b2\n## C\n- c1')), 'A(B(b1(b2)),C(c1))');
    });

    test('không có heading: gạch đầu dòng làm gốc', () {
      expect(tree(parseOutline('- x\n  - y\n- z')), 'x(y),z');
    });

    test('bỏ checkbox trong bullet, bỏ dòng trống/dòng lạ', () {
      expect(tree(parseOutline('# A\n\n- [x] xong\ntext tự do\n- [ ] chưa')), 'A(xong,chưa)');
    });
  });
}

import 'package:amber_flutter/features/tang_kinh_cac/widgets/document_card.dart';
import 'package:flutter_test/flutter_test.dart';

/// Regex gốc bên web (DocumentCard.tsx) — chỉ để đối chiếu lỗi cũ.
String webPreview(String content) => content.replaceAll(RegExp(r'[#\-\[\]xX]'), '').trim();

void main() {
  group('chữ x/X trong văn bản thường KHÔNG bị xoá', () {
    const cases = {
      'Nhân x2 lần': 'Nhân x2 lần',
      'Xuất file Excel': 'Xuất file Excel',
      'Xin chào, xe máy XL': 'Xin chào, xe máy XL',
      // Nội dung thật của document "Ubuntu cmd" (đoạn đầu).
      'Chạy winboat: xfreerdp3 /v:127': 'Chạy winboat: xfreerdp3 /v:127',
      'x': 'x',
    };
    cases.forEach((input, expected) {
      test('"$input"', () => expect(documentPreview(input), expected));
    });

    test('bản web thật sự ăn nhầm (để chứng minh lỗi có thật)', () {
      expect(webPreview('Nhân x2 lần'), 'Nhân 2 lần');
      expect(webPreview('Xuất file Excel'), 'uất file Ecel');
      expect(webPreview('Chạy winboat: xfreerdp3 /v:127'), 'Chạy winboat: freerdp3 /v:127');
    });
  });

  group('dấu - # [ ] giữa câu cũng giữ nguyên', () {
    test('gạch nối trong từ', () => expect(documentPreview('Wi-Fi 5-10 phút'), 'Wi-Fi 5-10 phút'));
    test('# không phải heading', () => expect(documentPreview('Học C# và #hashtag'), 'Học C# và #hashtag'));
    test('[x] giữa câu (vd code)', () => expect(documentPreview('arr[x] = 1'), 'arr[x] = 1'));
    test('số âm đầu dòng', () => expect(documentPreview('-5 độ'), '-5 độ'));
  });

  group('ký hiệu markdown ở đầu dòng bị bỏ', () {
    test('checklist đủ kiểu [ ] [x] [X], có/không thụt lề', () {
      expect(
        documentPreview('- [ ] Mua sữa\n- [x] Xong việc X\n  - [X] Việc con\n-[ ] sát dấu'),
        'Mua sữa Xong việc X Việc con sát dấu',
      );
    });

    test('mindmap: heading nhiều cấp + gạch đầu dòng lồng nhau', () {
      expect(
        documentPreview('# Chủ đề chính\n## Nhánh 1\n- ý 1\n  - ý con\n## Nhánh 2'),
        'Chủ đề chính Nhánh 1 ý 1 ý con Nhánh 2',
      );
    });

    test('dòng trống và khoảng trắng thừa gộp thành 1 dấu cách', () {
      expect(documentPreview('Dòng 1\n\n\n   Dòng   2  '), 'Dòng 1 Dòng 2');
    });

    test('chỉ toàn ký hiệu → rỗng (card sẽ ẩn phần xem trước)', () {
      expect(documentPreview('- [ ]\n#\n'), '#');
      expect(documentPreview('- [ ] \n'), '');
    });
  });
}

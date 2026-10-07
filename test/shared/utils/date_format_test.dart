import 'package:amber_flutter/shared/utils/date_format.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('formatDayMonth', () {
    test('"YYYY-MM-DD" → "dd/MM"', () {
      expect(formatDayMonth('2026-10-14'), '14/10');
      expect(formatDayMonth('2026-01-05'), '05/01');
      expect(formatDayMonth('2028-02-29'), '29/02');
    });

    test('chuỗi không đúng dạng → trả nguyên văn', () {
      expect(formatDayMonth('14/10'), '14/10');
      expect(formatDayMonth(''), '');
    });
  });

  group('formatDateRange', () {
    test('có cả hai → "dd/MM – dd/MM"', () {
      expect(formatDateRange('2026-10-06', '2026-12-31'), '06/10 – 31/12');
    });

    test('chỉ có bắt đầu → "Từ dd/MM"', () {
      expect(formatDateRange('2026-10-06', null), 'Từ 06/10');
    });

    test('chỉ có hạn → "Hạn dd/MM"', () {
      expect(formatDateRange(null, '2026-12-31'), 'Hạn 31/12');
    });

    test('không có → "Chưa có ngày"', () {
      expect(formatDateRange(null, null), 'Chưa có ngày');
    });
  });
}

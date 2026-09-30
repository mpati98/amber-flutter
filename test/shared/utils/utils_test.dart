import 'package:amber_flutter/shared/utils/currency.dart';
import 'package:amber_flutter/shared/utils/vn_time.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('vnToday/vnHour quanh mốc nửa đêm VN (khớp vn-time.ts bên backend)', () {
    expect(vnToday(DateTime.utc(2026, 9, 30, 16, 59, 59)), '2026-09-30'); // 23:59:59 VN
    expect(vnToday(DateTime.utc(2026, 9, 30, 17)), '2026-10-01'); // 00:00 VN, UTC vẫn 30/9
    expect(vnToday(DateTime.utc(2026, 12, 31, 17, 30)), '2027-01-01');
    expect(vnHour(DateTime.utc(2026, 9, 30, 17)), 0);
    expect(vnHour(DateTime.utc(2026, 9, 30, 4)), 11);
  });

  test('formatVnd giống toLocaleString("vi-VN") + "₫"', () {
    expect(formatVnd(3058792), '3.058.792₫');
    expect(formatVnd(60000), '60.000₫');
    expect(formatVnd(0), '0₫');
    expect(formatVnd(999), '999₫');
    expect(formatVnd(-1500000), '-1.500.000₫');
  });
}

import 'package:amber_flutter/features/tra_dinh/hoc_tap/utils/schedule_range.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('isoWeekdayOf / mondayOf / weekRange', () {
    expect(isoWeekdayOf('2026-10-15'), 4); // thứ Năm
    expect(isoWeekdayOf('2026-10-18'), 7);
    expect(mondayOf('2026-10-15'), '2026-10-12');
    expect(mondayOf('2026-10-12'), '2026-10-12');
    expect(mondayOf('2026-10-18'), '2026-10-12');
    expect(weekRange('2026-10-18'), (from: '2026-10-12', to: '2026-10-18'));
    expect(weekRange('2026-10-19'), (from: '2026-10-19', to: '2026-10-25'));
  });

  test('addDays qua tháng / năm, daysBetween', () {
    expect(addDays('2026-10-30', 3), '2026-11-02');
    expect(addDays('2026-12-31', 1), '2027-01-01');
    expect(addDays('2026-03-01', -1), '2026-02-28');
    expect(daysBetween('2026-10-12', '2026-10-18'), 6);
  });

  test('isValidIso', () {
    expect(isValidIso('2026-10-15'), isTrue);
    expect(isValidIso('2026-02-30'), isFalse);
    expect(isValidIso('2026-13-01'), isFalse);
    expect(isValidIso('15/10/2026'), isFalse);
    expect(isValidIso(null), isFalse);
  });

  test('monthGrid: tháng 10/2026 bắt đầu thứ Năm → lưới 35 ngày từ thứ Hai 28/9 tới Chủ nhật 1/11', () {
    final g = monthGrid('2026-10-15');
    expect(g.monthStart, '2026-10-01');
    expect(g.monthEnd, '2026-10-31');
    expect(g.from, '2026-09-28');
    expect(g.to, '2026-11-01');
    expect(daysBetween(g.from, g.to) + 1, 35);
    expect(isoWeekdayOf(g.monthStart), 4);
  });

  test('monthGrid: tháng 11/2026 cần 6 hàng = 42 ngày (≤ 62 của API)', () {
    final g = monthGrid('2026-11-30');
    expect((g.from, g.to), ('2026-10-26', '2026-12-06'));
    expect(daysBetween(g.from, g.to) + 1, 42);
  });

  test('monthGrid: tháng 2/2027 bắt đầu thứ Hai và có 28 ngày → đúng 4 hàng', () {
    final g = monthGrid('2027-02-10');
    expect((g.from, g.to, g.monthEnd), ('2027-02-01', '2027-02-28', '2027-02-28'));
    expect(daysBetween(g.from, g.to) + 1, 28);
  });

  test('firstOfMonth ±n tháng qua ranh giới năm', () {
    expect(firstOfMonth('2026-10-15'), '2026-10-01');
    expect(firstOfMonth('2026-10-15', 1), '2026-11-01');
    expect(firstOfMonth('2026-01-20', -1), '2025-12-01');
    expect(firstOfMonth('2026-12-05', 1), '2027-01-01');
  });
}

import 'package:amber_flutter/features/sinh_luc/utils/sleep_format.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('sleepDuration', () {
    expect(sleepDuration(450), '7 giờ 30');
    expect(sleepDuration(420), '7 giờ');
    expect(sleepDuration(45), '45 phút');
    expect(sleepDuration(485), '8 giờ 05');
  });

  test('parseSleepInput: hợp lệ, trống phút = 0, lỗi rõ ràng', () {
    expect(parseSleepInput('7', '30').minutes, 450);
    expect(parseSleepInput('7', '').minutes, 420);
    expect(parseSleepInput('', '45').minutes, 45);
    expect(parseSleepInput('', '').error, 'Nhập số giờ đã ngủ.');
    expect(parseSleepInput('7', '60').error, 'Phút phải nhỏ hơn 60.');
    expect(parseSleepInput('25', '0').error, 'Không quá 24 giờ.');
    expect(parseSleepInput('bảy', '0').error, isNotNull);
    expect(parseSleepInput('-1', '0').error, isNotNull);
  });

  test('isoMinusDays / shortDate qua ranh giới tháng, năm', () {
    expect(isoMinusDays('2026-11-01', 1), '2026-10-31');
    expect(isoMinusDays('2026-01-01', 1), '2025-12-31');
    expect(shortDate('2026-11-05'), '05/11');
  });
}

import 'package:amber_flutter/shared/utils/duration_format.dart';
import 'package:flutter_test/flutter_test.dart';

/// Công thức gốc bên web, chỉ để chứng minh lỗi: `${Math.round(m/60)}h ${m%60}p`.
String webFormat(int m) => '${(m / 60).round()}h ${m % 60}p';

void main() {
  const cases = {
    0: '0p',
    1: '1p',
    29: '29p',
    30: '30p',
    59: '59p',
    60: '1h',
    61: '1h 1p',
    89: '1h 29p',
    90: '1h 30p', // web: "2h 30p"
    119: '1h 59p', // web: "2h 59p"
    120: '2h',
    150: '2h 30p', // web: "3h 30p"
    600: '10h',
    1439: '23h 59p',
  };

  cases.forEach((minutes, expected) {
    test('$minutes phút → "$expected"', () => expect(formatDuration(minutes), expected));
  });

  test('bản web sai đúng ở các ca phút dư ≥ 30', () {
    expect(webFormat(90), '2h 30p');
    expect(webFormat(119), '2h 59p');
    expect(webFormat(150), '3h 30p');
    expect(webFormat(30), '1h 30p'); // 30 phút mà web hiện "1h 30p"
    expect(webFormat(89), '1h 29p'); // phút dư < 30 thì web đúng tình cờ
  });
}

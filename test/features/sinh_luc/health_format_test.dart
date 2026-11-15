import 'package:amber_flutter/features/sinh_luc/models/health_inputs.dart';
import 'package:amber_flutter/features/sinh_luc/utils/health_format.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('parseOptionalMinutes: trống = null, 0–1440, sai thì báo lỗi', () {
    expect(parseOptionalMinutes('  ', 'Phút tập'), (minutes: null, error: null));
    expect(parseOptionalMinutes('0', 'Phút tập').minutes, 0);
    expect(parseOptionalMinutes('1440', 'Phút tập').minutes, 1440);
    expect(parseOptionalMinutes('1441', 'Phút tập').error, 'Phút tập phải là số phút từ 0 đến 1440.');
    expect(parseOptionalMinutes('-1', 'Phút tập').error, isNotNull);
    expect(parseOptionalMinutes('2.5', 'Phút tập').error, isNotNull);
  });

  test('tóm tắt check-in', () {
    expect(eveningSummary(const CheckIn(date: '2026-11-15', slot: 'evening', restDay: true, exerciseMinutes: 10)), 'Ngày nghỉ');
    expect(eveningSummary(const CheckIn(date: '2026-11-15', slot: 'evening')), 'Không vận động');
    expect(checkInTitle(const CheckIn(date: '2026-11-15', slot: 'noon', staminaSelf: 1)), '15/11 · Trưa · Kiệt sức');
    expect(checkInTitle(const CheckIn(date: '2026-11-15', slot: 'evening', sportMinutes: 40)), '15/11 · Tối · 40 phút thể thao');
  });

  test('debuff: nhãn mức, giờ VN, trạng thái', () {
    expect(debuffLevelLabel('heavy'), 'Nặng (−40)');
    final d = Debuff(id: 'a', level: 'light', startedAt: DateTime.utc(2026, 11, 14, 17, 5), active: true); // 00:05 VN ngày 15
    expect(debuffTitle(d), 'Debuff nhẹ');
    expect(debuffSubtitle(d), 'Nhẹ (−10) · từ 15/11 00:05 · đang có');
    final ended = Debuff(id: 'b', level: 'medium', label: 'Cảm', startedAt: DateTime.utc(2026, 11, 14, 1), endedAt: DateTime.utc(2026, 11, 15, 2, 30), active: false);
    expect(debuffSubtitle(ended), 'Vừa (−25) · từ 14/11 08:00 · đến 15/11 09:30');
  });

  test('parse JSON chịu thiếu trường', () {
    final c = CheckInHistory.fromJson({'today': '2026-11-15', 'checkIns': [{'date': '2026-11-15', 'slot': 'noon', 'staminaSelf': 2}, 'rác']});
    expect(c.checkIns.single.staminaSelf, 2);
    expect(c.find('2026-11-15', 'noon'), isNotNull);
    expect(c.find('2026-11-15', 'evening'), isNull);
    final d = Debuff.fromJson({'id': 'x', 'level': 'heavy', 'startedAt': '2026-11-15T01:00:00.000Z', 'endedAt': null, 'active': true});
    expect(d.endedAt, isNull);
    expect(d.active, isTrue);
  });
}

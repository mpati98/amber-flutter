import 'package:amber_flutter/features/tra_dinh/models/practice_message.dart';
import 'package:amber_flutter/features/tra_dinh/utils/practice_minutes.dart';
import 'package:flutter_test/flutter_test.dart';

// estimatePracticeMinutes: hàm thuần cho số phút điền sẵn ở sheet cuối phiên luyện AI.

final _t0 = DateTime.utc(2026, 11, 7, 9);

PracticeMessage _m(String id, Duration at, {MessageRole role = MessageRole.user}) => PracticeMessage(id: id, role: role, content: id, createdAt: _t0.add(at));

void main() {
  test('không có tin nhắn → 0 (không hiện sheet)', () {
    expect(estimatePracticeMinutes(const []), 0);
  });

  test('một tin nhắn → tối thiểu 1 phút', () {
    expect(estimatePracticeMinutes([_m('u1', Duration.zero)]), 1);
  });

  test('các khoảng ngắn cộng nguyên: 40s + 80s + 60s = 3 phút', () {
    final msgs = [
      _m('u1', Duration.zero),
      _m('a1', const Duration(seconds: 40), role: MessageRole.assistant),
      _m('u2', const Duration(seconds: 120)),
      _m('a2', const Duration(seconds: 180), role: MessageRole.assistant),
    ];
    expect(estimatePracticeMinutes(msgs), 3);
  });

  test('khoảng nghỉ dài bị chặn ở 3 phút, không tính cả giờ để app mở', () {
    final msgs = [
      _m('u1', Duration.zero),
      _m('a1', const Duration(seconds: 30), role: MessageRole.assistant),
      _m('u2', const Duration(hours: 2)), // nghỉ 2 giờ → chỉ tính 3 phút
      _m('a2', const Duration(hours: 2, seconds: 30), role: MessageRole.assistant),
    ];
    // 30s + 180s + 30s = 240s = 4 phút
    expect(estimatePracticeMinutes(msgs), 4);
  });

  test('khoảng đúng 3 phút tính đủ; hơn 3 phút bị chặn', () {
    expect(estimatePracticeMinutes([_m('u1', Duration.zero), _m('a1', const Duration(minutes: 3))]), 3);
    expect(estimatePracticeMinutes([_m('u1', Duration.zero), _m('a1', const Duration(minutes: 30))]), 3);
  });

  test('thứ tự đầu vào không quan trọng: sắp theo thời gian trước khi cộng', () {
    final msgs = [
      _m('a2', const Duration(seconds: 150), role: MessageRole.assistant),
      _m('u1', Duration.zero),
      _m('u2', const Duration(seconds: 100)),
      _m('a1', const Duration(seconds: 30), role: MessageRole.assistant),
    ];
    // theo thời gian: 0, 30, 100, 150 → 30 + 70 + 50 = 150s → 2.5 phút → làm tròn 3
    expect(estimatePracticeMinutes(msgs), 3);
  });

  test('tin nhắn cùng một thời điểm (hai tin ghi cùng giao dịch) → 1 phút tối thiểu', () {
    expect(estimatePracticeMinutes([_m('u1', Duration.zero), _m('a1', Duration.zero, role: MessageRole.assistant)]), 1);
  });

  test('buổi rất dài không vượt 1440', () {
    final msgs = [for (var i = 0; i < 600; i++) _m('m$i', Duration(minutes: 3 * i))];
    expect(estimatePracticeMinutes(msgs), 1440); // 599 × 3 = 1797 → kẹp ở 1440
  });
}

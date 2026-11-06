import 'package:amber_flutter/features/tra_dinh/hoc_tap/utils/card_mask.dart';
import 'package:flutter_test/flutter_test.dart';

// Che cụm trong câu ví dụ: khớp đúng cụm, khớp theo thân từ, không khớp.

String _join(MaskedExample m) => m.before + m.match + m.after;

void main() {
  group('khớp đúng cụm (không phân biệt hoa thường)', () {
    test('cụm nằm giữa câu', () {
      final m = maskPhrase('I look forward to meeting you next week.', 'look forward to')!;
      expect((m.before, m.match, m.after), ('I ', 'look forward to', ' meeting you next week.'));
    });

    test('hoa thường khác nhau: giữ nguyên chữ trong câu', () {
      final m = maskPhrase('Break the ICE with a joke.', 'break the ice')!;
      expect(m.match, 'Break the ICE');
      expect(m.before, '');
      expect(m.after, ' with a joke.');
    });

    test('khoảng trắng bất kỳ giữa các từ', () {
      final m = maskPhrase('He did  look   forward to it.', 'look forward to')!;
      expect(m.match, 'look   forward to');
    });

    test('ghép lại ba đoạn ra đúng câu gốc', () {
      const s = 'We need to make a decision today.';
      expect(_join(maskPhrase(s, 'make a decision')!), s);
    });

    test('cụm có ký tự đặc biệt của regex không làm hỏng', () {
      final m = maskPhrase('Try (not) to give up.', '(not) to')!;
      expect(m.match, '(not) to');
      expect(maskPhrase('cost +10% more', '+10%')?.match, '+10%');
    });

    test('không khớp giữa từ: "to" không nằm trong "today", "act" không nằm trong "react"', () {
      expect(maskPhrase('Call me today.', 'me to'), isNull);
      expect(maskPhrase('They react fast.', 'act fast'), isNull);
    });

    test('chọn lần khớp trọn từ đầu tiên (bỏ qua lần dính vào giữa từ)', () {
      final m = maskPhrase('Reacts well; I act well.', 'act well')!;
      expect(m.before, 'Reacts well; I ');
      expect(m.match, 'act well');
    });
  });

  group('khớp theo thân từ', () {
    test('"look forward to" khớp "looking forward to"', () {
      final m = maskPhrase('She is looking forward to the trip.', 'look forward to')!;
      expect((m.before, m.match, m.after), ('She is ', 'looking forward to', ' the trip.'));
    });

    test('chia động từ: broke / break không khớp thân, nhưng breaking the ice khớp "break the ice"', () {
      expect(maskPhrase('Breaking the ice is hard.', 'break the ice')!.match, 'Breaking the ice');
    });

    test('từ ≤ 3 chữ giữ nguyên (không bỏ chữ): "be up to" không khớp "being upset to"', () {
      expect(maskPhrase('He is being upset to hear it.', 'be up to'), isNull);
    });

    test('nhiều từ chia dạng khác: "picks up on" ← "pick up on"', () {
      final m = maskPhrase('She picks up on small things.', 'pick up on')!;
      expect(m.match, 'picks up on');
    });

    test('thân từ không được dính chữ cuối: "to" cuối cụm không khớp "today"', () {
      expect(maskPhrase('He looks forward today.', 'look forward to'), isNull);
    });

    test('ưu tiên khớp đúng cụm trước, rồi mới tới thân từ', () {
      final m = maskPhrase('I look forward to it, and looking forward to more.', 'look forward to')!;
      expect(m.match, 'look forward to');
      expect(m.before, 'I ');
    });
  });

  group('không tìm thấy', () {
    test('cụm không có trong câu → null', () {
      expect(maskPhrase('The weather is nice.', 'break the ice'), isNull);
    });

    test('câu hoặc cụm rỗng → null', () {
      expect(maskPhrase('', 'break the ice'), isNull);
      expect(maskPhrase('Anything.', '   '), isNull);
    });

    test('mẫu cấu trúc có "+ V" không có trong câu → null (mặt trước ẩn câu)', () {
      expect(maskPhrase('She is about to leave.', 'be about to + V'), isNull);
    });
  });
}

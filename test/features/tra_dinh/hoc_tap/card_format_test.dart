import 'package:amber_flutter/features/tra_dinh/hoc_tap/models/study_card.dart';
import 'package:amber_flutter/features/tra_dinh/hoc_tap/utils/card_format.dart';
import 'package:amber_flutter/features/tra_dinh/hoc_tap/utils/card_prompt.dart';
import 'package:flutter_test/flutter_test.dart';

import 'hoc_tap_test_support.dart';

// Nhãn hạn, câu báo lỗi tiếng Việt, lời nhắc cho Claude.

// 14:00 giờ VN thứ Sáu 06/11/2026.
final _now = DateTime.parse('2026-11-06T14:00:00+07:00');

StudyCard _card({CardStage stage = CardStage.weekly, String? dueAt, bool suspended = false}) =>
    StudyCard(id: 'c', phrase: 'p', stage: stage, dueAt: dueAt == null ? null : DateTime.parse(dueAt), suspended: suspended);

void main() {
  group('cardDueLabel', () {
    test('Mới / Tạm dừng (tạm dừng thắng mọi nhãn khác)', () {
      expect(cardDueLabel(_card(stage: CardStage.newCard), now: _now), 'Mới');
      expect(cardDueLabel(_card(stage: CardStage.newCard, suspended: true), now: _now), 'Tạm dừng');
      expect(cardDueLabel(_card(dueAt: '2026-11-06T00:00:00+07:00', suspended: true), now: _now), 'Tạm dừng');
    });

    test('hôm nay (kể cả quá hạn), mai, ngày khác', () {
      expect(cardDueLabel(_card(dueAt: '2026-11-06T00:00:00+07:00'), now: _now), 'Hôm nay');
      expect(cardDueLabel(_card(dueAt: '2026-11-06T23:59:00+07:00'), now: _now), 'Hôm nay');
      expect(cardDueLabel(_card(dueAt: '2026-10-30T00:00:00+07:00'), now: _now), 'Hôm nay', reason: 'quá hạn vẫn là hôm nay');
      expect(cardDueLabel(_card(dueAt: '2026-11-07T00:00:00+07:00'), now: _now), 'Mai');
      expect(cardDueLabel(_card(dueAt: '2026-11-08T00:00:00+07:00'), now: _now), '08/11');
      expect(cardDueLabel(_card(dueAt: '2027-01-03T00:00:00+07:00'), now: _now), '03/01');
    });

    test('tính theo giờ VN, không theo UTC: 00:30 ngày 07 giờ VN là "Mai", không phải "Hôm nay"', () {
      // 2026-11-06T17:30:00Z = 00:30 ngày 07/11 giờ VN.
      expect(cardDueLabel(_card(dueAt: '2026-11-06T17:30:00Z'), now: _now), 'Mai');
      // Cùng thời điểm đó khi "bây giờ" đã là 00:10 ngày 07 giờ VN → Hôm nay.
      expect(cardDueLabel(_card(dueAt: '2026-11-06T17:30:00Z'), now: DateTime.parse('2026-11-06T17:10:00Z')), 'Hôm nay');
    });

    test('thẻ đã ôn mà thiếu dueAt → "—"', () {
      expect(cardDueLabel(_card(), now: _now), '—');
    });
  });

  test('cardDateLabel', () {
    expect(cardDateLabel(DateTime.parse('2026-11-15T00:00:00+07:00')), '15/11');
    expect(cardDateLabel(null), '—');
  });

  group('lỗi kiểm tra thẻ → tiếng Việt', () {
    // Mọi cặp trường:lý do mà study-card-parse.ts (backend) có thể trả.
    const backendReasons = [
      (field: 'phrase', reason: 'required'),
      (field: 'phrase', reason: 'too_long'),
      (field: 'phrase', reason: 'single_word'),
      (field: 'meaning', reason: 'required'),
      (field: 'example', reason: 'required'),
      (field: 'note', reason: 'invalid'),
      (field: 'kind', reason: 'invalid'),
      (field: 'topics', reason: 'invalid'),
      (field: 'topics', reason: 'too_many'),
      (field: null, reason: 'not_object'),
      (field: null, reason: 'invalid_json'),
      (field: null, reason: 'not_array'),
      (field: null, reason: 'too_many_cards'),
    ];

    test('mọi lý do của backend đều có câu riêng (không rơi vào câu chung)', () {
      for (final r in backendReasons) {
        final text = cardReasonText(r.field, r.reason);
        expect(text, isNot(contains('chưa hợp lệ (')), reason: '${r.field}:${r.reason} chưa có câu');
        expect(text, isNot(contains(r.reason)), reason: '${r.field}:${r.reason}: không để lộ mã');
      }
    });

    test('lý do lạ rơi về câu chung kèm mã', () {
      expect(cardReasonText('phrase', 'brand_new'), 'Cụm từ chưa hợp lệ (brand_new)');
      expect(cardReasonText(null, 'weird'), 'Dữ liệu chưa hợp lệ (weird)');
    });

    test('parseErrorLine: có vị trí (đếm từ 1) hoặc lỗi cả đầu vào', () {
      expect(parseErrorLine(const CardParseError(index: 2, field: 'phrase', reason: 'single_word')), 'Thẻ 3 · Cụm từ phải có ít nhất 2 từ (kho không nhận từ đơn)');
      expect(parseErrorLine(const CardParseError(field: null, reason: 'invalid_json')), startsWith('Không đọc được JSON'));
      expect(parseErrorLine(const CardParseError(index: 0, field: null, reason: 'not_object')), startsWith('Thẻ 1 · '));
    });
  });

  group('cardErrorMessage', () {
    test('lỗi kiểm tra từng trường (fixture thật) → câu theo trường', () {
      expect(cardErrorMessage(apiError(400, fixtureMap('cards_error_validation'))), 'Cụm từ phải có ít nhất 2 từ (kho không nhận từ đơn)');
    });

    test('duplicate_phrase (fixture thật), card_not_found, subject_not_found, log_subject_mismatch', () {
      expect(cardErrorMessage(apiError(409, fixtureMap('cards_error_duplicate'))), 'Cụm từ này đã có trong kho của môn');
      expect(cardErrorMessage(apiError(404, {'error': 'card_not_found'})), 'Không tìm thấy thẻ, có thể đã bị xoá');
      expect(cardErrorMessage(apiError(404, {'error': 'subject_not_found'})), 'Không tìm thấy môn học');
      expect(cardErrorMessage(apiError(400, {'error': 'log_subject_mismatch'})), 'Buổi học này thuộc môn khác');
      expect(cardErrorMessage(apiError(400, {'error': 'invalid_cards', 'errors': []})), startsWith('Có thẻ chưa hợp lệ'));
    });

    test('zod báo chữ tiếng Anh (thiếu trường) → vẫn là câu tiếng Việt theo trường; lỗi mạng → câu chung', () {
      expect(
        cardErrorMessage(apiError(400, {'error': {'formErrors': [], 'fieldErrors': {'example': ['Invalid input: expected string, received undefined']}}})),
        'Ví dụ chưa hợp lệ',
      );
      expect(cardErrorMessage(Exception('mạng')), 'Có lỗi, thử lại');
    });
  });

  group('cardPrompt', () {
    test('thay [LIST OF MY TOPICS] bằng các chủ đề đang có', () {
      final p = cardPrompt(['travel', 'work']);
      expect(p, contains('Reuse these existing\ntopics when they fit: travel, work.'));
      expect(p, isNot(contains('[LIST OF MY TOPICS]')));
      expect(p, startsWith('Here is the transcript of my English lesson.'));
      expect(p, contains('PHRASAL_VERB, COLLOCATION, IDIOM, PATTERN,\nEXPRESSION'));
    });

    test('chưa có chủ đề (hoặc chỉ chuỗi rỗng) → "none yet"', () {
      expect(cardPrompt(const []), contains('topics when they fit: none yet.'));
      expect(cardPrompt(['', '  ']), contains('none yet'));
    });
  });
}

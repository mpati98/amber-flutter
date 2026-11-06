import 'package:flutter/foundation.dart';

import '../../../../shared/utils/api_error.dart';
import '../../../../shared/utils/date_format.dart';
import '../../../../shared/utils/vn_time.dart';
import '../models/study_card.dart';
import '../models/study_card_queue.dart';
import 'hoc_tap_errors.dart';

/// Nhãn hạn ôn trên dòng thẻ: "Tạm dừng", "Mới", "Hôm nay" (đến hạn hoặc quá hạn), "Mai", hoặc dd/MM. Ngày theo giờ VN.
String cardDueLabel(StudyCard card, {DateTime? now}) {
  if (card.suspended) return 'Tạm dừng';
  if (card.stage == CardStage.newCard) return 'Mới';
  final due = card.dueAt;
  if (due == null) return '—';
  final now0 = now ?? DateTime.now();
  final dueDay = vnToday(due);
  if (dueDay.compareTo(vnToday(now0)) <= 0) return 'Hôm nay';
  if (dueDay == vnToday(now0.add(const Duration(days: 1)))) return 'Mai';
  return formatDayMonth(dueDay);
}

/// "dd/MM" của một thời điểm theo giờ VN; null → "—".
String cardDateLabel(DateTime? at) => at == null ? '—' : formatDayMonth(vnToday(at));

const _fieldLabels = {'phrase': 'Cụm từ', 'meaning': 'Nghĩa', 'example': 'Ví dụ', 'note': 'Ghi chú', 'kind': 'Loại', 'topics': 'Chủ đề'};

/// Lý do kiểm tra thẻ của backend (study-card-parse.ts) → câu tiếng Việt. Lý do lạ → null.
@visibleForTesting
const cardReasonMessages = <String, String>{
  'phrase:required': 'Cụm từ không được để trống',
  'phrase:too_long': 'Cụm từ dài quá 255 ký tự',
  'phrase:single_word': 'Cụm từ phải có ít nhất 2 từ (kho không nhận từ đơn)',
  'meaning:required': 'Nghĩa tiếng Anh không được để trống',
  'example:required': 'Câu ví dụ không được để trống',
  'note:invalid': 'Ghi chú phải là chữ',
  'kind:invalid': 'Loại không hợp lệ (PHRASAL_VERB, COLLOCATION, IDIOM, PATTERN hoặc EXPRESSION)',
  'topics:invalid': 'Chủ đề phải là một danh sách chữ',
  'topics:too_many': 'Tối đa 3 chủ đề cho mỗi thẻ',
  ':not_object': 'Mỗi thẻ phải là một đối tượng { ... }',
  // Lỗi của cả đầu vào (index null)
  ':invalid_json': 'Không đọc được JSON, kiểm tra dấu ngoặc và dấu phẩy',
  ':not_array': 'JSON phải là một danh sách [ ... ] các thẻ',
  ':too_many_cards': 'Tối đa 100 thẻ mỗi lần nhập',
};

/// Câu cho một lỗi kiểm tra (không kèm vị trí thẻ).
String cardReasonText(String? field, String reason) {
  final known = cardReasonMessages['${field ?? ''}:$reason'];
  if (known != null) return known;
  final label = _fieldLabels[field];
  return label == null ? 'Dữ liệu chưa hợp lệ ($reason)' : '$label chưa hợp lệ ($reason)';
}

/// Dòng báo lỗi nhập thẻ: "Thẻ 3 · Cụm từ phải có ít nhất 2 từ…"; lỗi của cả đầu vào thì không có "Thẻ N".
String parseErrorLine(CardParseError e) {
  final text = cardReasonText(e.field, e.reason);
  return e.index == null ? text : 'Thẻ ${e.index! + 1} · $text';
}

/// Lỗi khi lưu / sửa / xoá / nhập thẻ → câu tiếng Việt. Lỗi kiểm tra từng trường của backend có dạng
/// `{error: {fieldErrors: {phrase: ['single_word']}}}`; mã lỗi chuỗi dùng bảng chung của Học tập.
String cardErrorMessage(Object error) {
  if (apiErrorCode(error) == null) {
    final fields = _fieldErrors(error);
    if (fields != null) {
      for (final e in fields.entries) {
        final reasons = e.value;
        if (reasons is List && reasons.isNotEmpty && reasons.first is String) {
          final r = reasons.first as String;
          // zod báo chữ tiếng Anh dài khi thiếu / sai kiểu: coi như "required" nếu là trường chữ bắt buộc.
          final known = cardReasonMessages['${e.key}:$r'];
          if (known != null) return known;
          if (_fieldLabels.containsKey(e.key)) return '${_fieldLabels[e.key]} chưa hợp lệ';
        }
      }
    }
  }
  return hocTapErrorMessage(error);
}

Map<String, dynamic>? _fieldErrors(Object error) {
  final data = apiErrorData(error);
  if (data is Map && data['error'] is Map && (data['error'] as Map)['fieldErrors'] is Map) {
    return ((data['error'] as Map)['fieldErrors'] as Map).cast<String, dynamic>();
  }
  return null;
}

const _weekdayShort = ['T2', 'T3', 'T4', 'T5', 'T6', 'T7', 'CN'];

/// Thứ viết tắt theo ISO (1 = thứ Hai … 7 = Chủ nhật): T2..T7, CN.
String weekdayShort(int isoWeekday) => _weekdayShort[(isoWeekday - 1).clamp(0, 6)];

/// Dòng nhỏ dưới nút đánh giá, từ kết quả [next] của mức đó (server tính sẵn):
/// - đúng giai đoạn và hạn như bây giờ (ôn thêm giữ lịch) → "Giữ lịch";
/// - Đang học: ngày khác → "Ngày mai" (hoặc dd/MM nếu xa hơn); trong hôm nay dưới 1 giờ → "N phút";
/// - Hàng tuần → "CN 08/11"; Hàng tháng → "Tháng 12"; Hàng quý → "Quý 1/2027". Ngày theo giờ VN.
/// Kiểm "ngày khác" trước "dưới 1 giờ": "Cần ôn lại" lúc 23:30 hẹn 00:00 ngày mai là "Ngày mai", không phải "30 phút"
/// (server coi thẻ hẹn sang ngày khác là xong cho hôm nay, nó không quay lại trong hôm nay).
String ratingDueLabel({required StudyCard card, required CardRating rating, required NextSchedule next, DateTime? now}) {
  final due = next.dueAt;
  final sameSchedule = next.stage == card.stage && ((due == null && card.dueAt == null) || (due != null && card.dueAt != null && due.isAtSameMomentAs(card.dueAt!)));
  if (rating == CardRating.remembered && sameSchedule) return 'Giữ lịch';
  if (due == null) return '';
  final now0 = now ?? DateTime.now();
  final vn = vnNow(due);
  switch (next.stage) {
    case CardStage.learning:
      final dueDay = vnToday(due);
      final today = vnToday(now0);
      if (dueDay.compareTo(today) > 0) return dueDay == vnToday(now0.add(const Duration(days: 1))) ? 'Ngày mai' : formatDayMonth(dueDay);
      final left = due.difference(now0);
      if (left < const Duration(hours: 1)) return '${waitMinutes(left)} phút';
      return 'Hôm nay';
    case CardStage.weekly:
      return '${weekdayShort(vn.weekday)} ${formatDayMonth(vnToday(due))}';
    case CardStage.monthly:
      return 'Tháng ${vn.month}';
    case CardStage.quarterly:
      return 'Quý ${(vn.month - 1) ~/ 3 + 1}/${vn.year}';
    case CardStage.newCard:
    case CardStage.unknown:
      return '';
  }
}

/// Số phút làm tròn LÊN của khoảng còn lại, tối thiểu 1 ("quay lại sau N phút").
int waitMinutes(Duration left) {
  final seconds = left.inSeconds;
  return seconds <= 60 ? 1 : (seconds + 59) ~/ 60;
}

/// Đồng hồ đếm ngược "m:ss" (hoặc "h:mm:ss" khi từ 1 giờ); âm → "0:00".
String countdownLabel(Duration left) {
  final total = left.isNegative ? 0 : left.inSeconds;
  final h = total ~/ 3600, m = (total % 3600) ~/ 60, s = total % 60;
  final ss = s.toString().padLeft(2, '0');
  return h > 0 ? '$h:${m.toString().padLeft(2, '0')}:$ss' : '$m:$ss';
}

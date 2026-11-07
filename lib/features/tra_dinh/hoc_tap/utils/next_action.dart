import '../models/study_overview.dart';

/// Việc tiếp theo của môn trong ngày (chỉ một việc được nút vàng).
enum TodayAction { reviewCards, nextLesson, practice }

/// Hàm thuần: Ôn thẻ (chưa xong) → Học bài tiếp (có phần kế tiếp) → Luyện AI (mục tiêu phút chưa đủ,
/// không còn việc khác). null = không có nút vàng.
///
/// `cards.planned == 0` nghĩa là hôm nay chưa mở hàng đợi (kế hoạch ngày chỉ tạo khi mở lần đầu), KHÔNG phải
/// môn không có thẻ, nên vẫn tính là chưa làm (trừ khi `cards.total == 0`). Backend cũ không có khối `cards` thì bỏ qua Ôn thẻ.
/// Môn không đặt mục tiêu phút thì không bao giờ gợi ý Luyện AI.
TodayAction? nextTodayAction(SubjectOverview subject) {
  final cards = subject.cards;
  if (cards != null && cardsPending(cards)) {
    return TodayAction.reviewCards;
  }
  if (subject.next != null) {
    return TodayAction.nextLesson;
  }
  if (subject.goalMinutes != null && !subject.today.done) {
    return TodayAction.practice;
  }
  return null;
}

/// Ôn thẻ chưa xong hôm nay: chưa mở hàng đợi (planned 0) hoặc còn thẻ chưa ôn.
/// Môn chắc chắn chưa có thẻ nào (`total == 0`) thì không có gì để ôn: không phải việc cần làm.
/// `total` thiếu (backend cũ) = chưa biết, giữ như cũ.
bool cardsPending(CardsToday cards) => cards.total != 0 && (cards.planned == 0 || cards.finished < cards.planned);

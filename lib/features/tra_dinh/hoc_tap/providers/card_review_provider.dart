import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../shared/utils/api_error.dart';
import '../models/study_card_queue.dart';
import '../services/hoc_tap_api.dart';
import '../utils/card_format.dart';

// Phiên ôn thẻ: tải hàng ôn, hiện từng thẻ (mặt trước → mặt sau → đánh giá), chờ thẻ "Chưa nhớ" quay lại, kết thúc.

/// Các trạng thái của màn ôn.
enum ReviewPhase {
  /// Đang tải hàng ôn lần đầu.
  loading,

  /// Thẻ đầu hàng, mặt trước (câu hỏi).
  question,

  /// Thẻ đầu hàng, mặt sau (đáp án + ba nút đánh giá).
  answer,

  /// Hết thẻ cần hiện ngay nhưng còn thẻ "Chưa nhớ" sẽ quay lại trong hôm nay.
  waiting,

  /// Xong phiên (hết thẻ, không còn thẻ chờ quay lại): màn kết thúc và nhập số phút.
  done,

  /// Hôm nay không có thẻ nào trong kế hoạch.
  empty,

  /// Không tải được hàng ôn.
  error,
}

/// Lỗi 409 / 404 cho biết hàng ôn trên máy đã cũ: báo ngắn rồi tải lại hàng ôn.
const _staleCodes = {'already_finished_today', 'not_due_yet', 'not_in_today_plan', 'card_suspended', 'card_not_found'};

class CardReviewState {
  const CardReviewState({
    this.phase = ReviewPhase.loading,
    this.queue = const [],
    this.progress = const CardProgress(),
    this.soonestDueAt,
    this.notYet = 0,
    this.again = 0,
    this.remembered = 0,
    this.busy = false,
    this.message,
    this.error,
  });

  final ReviewPhase phase;

  /// Các thẻ cần hiện ngay, thẻ đầu hàng là thẻ đang ôn.
  final List<QueueCard> queue;
  final CardProgress progress;

  /// Hạn sớm nhất của thẻ còn đợi quay lại trong hôm nay; null nếu không có.
  final DateTime? soonestDueAt;

  /// Số lượt đánh giá trong phiên này, theo từng mức.
  final int notYet;
  final int again;
  final int remembered;

  /// Đang gọi API đánh giá: khoá ba nút.
  final bool busy;

  /// Thông báo ngắn (SnackBar) cho lần thao tác vừa rồi; màn hình đọc xong gọi [CardReviewNotifier.ackMessage].
  final String? message;
  final Object? error;

  QueueCard? get current => queue.isEmpty ? null : queue.first;
  int get reviewedThisSession => notYet + again + remembered;

  /// Số thẻ đang đợi quay lại (còn lại của kế hoạch trừ các thẻ đã hiện được).
  int get waitingCount => (progress.remaining - queue.length).clamp(0, 1 << 30);

  CardReviewState copyWith({
    ReviewPhase? phase,
    List<QueueCard>? queue,
    CardProgress? progress,
    Object? soonestDueAt = _keep,
    int? notYet,
    int? again,
    int? remembered,
    bool? busy,
    Object? message = _keep,
    Object? error = _keep,
  }) => CardReviewState(
    phase: phase ?? this.phase,
    queue: queue ?? this.queue,
    progress: progress ?? this.progress,
    soonestDueAt: identical(soonestDueAt, _keep) ? this.soonestDueAt : soonestDueAt as DateTime?,
    notYet: notYet ?? this.notYet,
    again: again ?? this.again,
    remembered: remembered ?? this.remembered,
    busy: busy ?? this.busy,
    message: identical(message, _keep) ? this.message : message as String?,
    error: identical(error, _keep) ? this.error : error,
  );
}

const _keep = Object();

/// Quyết định trạng thái từ hàng ôn: còn thẻ → câu hỏi; hết thẻ mà còn thẻ đợi → chờ; kế hoạch rỗng → trống; còn lại → xong.
ReviewPhase reviewPhaseFor({required List<QueueCard> queue, required CardProgress progress, required DateTime? soonestDueAt}) {
  if (queue.isNotEmpty) return ReviewPhase.question;
  if (soonestDueAt != null) return ReviewPhase.waiting;
  if (progress.planned == 0) return ReviewPhase.empty;
  return ReviewPhase.done;
}

class CardReviewNotifier extends Notifier<CardReviewState> {
  CardReviewNotifier(this.subjectId);

  final String subjectId;
  int _seq = 0;

  HocTapApi get _api => ref.read(hocTapApiProvider);

  @override
  CardReviewState build() {
    Future.microtask(load);
    return const CardReviewState();
  }

  /// Tải (hoặc tải lại) hàng ôn. [quiet] = giữ màn hiện tại cho tới khi có dữ liệu mới (sau 409, khi tới giờ thẻ quay lại).
  Future<void> load({bool quiet = false}) async {
    final seq = ++_seq;
    if (!quiet || state.phase == ReviewPhase.loading || state.phase == ReviewPhase.error) {
      state = state.copyWith(phase: ReviewPhase.loading, error: null);
    }
    try {
      final q = await _api.getCardQueue(subjectId);
      if (!ref.mounted || seq != _seq) return;
      state = state.copyWith(
        phase: reviewPhaseFor(queue: q.cards, progress: q.progress, soonestDueAt: q.soonestDueAt),
        queue: q.cards,
        progress: q.progress,
        soonestDueAt: q.soonestDueAt,
        busy: false,
        error: null,
      );
    } catch (e) {
      if (!ref.mounted || seq != _seq) return;
      // Đang ôn dở mà tải lại lỗi: giữ nguyên màn hiện tại, chỉ báo ngắn. Chưa có gì để hiện → màn lỗi.
      if (quiet && state.queue.isNotEmpty) {
        state = state.copyWith(busy: false, message: cardErrorMessage(e));
      } else {
        state = state.copyWith(phase: ReviewPhase.error, busy: false, error: e);
      }
    }
  }

  void showAnswer() {
    if (state.phase == ReviewPhase.question && state.queue.isNotEmpty) state = state.copyWith(phase: ReviewPhase.answer);
  }

  /// Đánh giá thẻ đang hiện. Khoá ba nút trong lúc gọi. Thành công: bỏ thẻ khỏi hàng, cập nhật tiến độ, sang thẻ kế.
  /// 409 (hàng đã cũ): báo ngắn rồi tải lại hàng. Lỗi mạng: giữ thẻ để bấm lại.
  Future<void> rate(CardRating rating) async {
    final s = state;
    final card = s.current;
    if (s.busy || s.phase != ReviewPhase.answer || card == null) return;
    state = s.copyWith(busy: true, message: null);
    try {
      final r = await _api.reviewCard(card.id, rating);
      if (!ref.mounted) return;
      final rest = [for (final c in state.queue) if (c.id != card.id) c];
      state = state.copyWith(
        queue: rest,
        progress: r.progress,
        soonestDueAt: r.soonestDueAt,
        notYet: state.notYet + (rating == CardRating.notYet ? 1 : 0),
        again: state.again + (rating == CardRating.reviewAgain ? 1 : 0),
        remembered: state.remembered + (rating == CardRating.remembered ? 1 : 0),
        busy: false,
        phase: reviewPhaseFor(queue: rest, progress: r.progress, soonestDueAt: r.soonestDueAt),
      );
    } catch (e) {
      if (!ref.mounted) return;
      if (_staleCodes.contains(apiErrorCode(e))) {
        state = state.copyWith(busy: false, message: cardErrorMessage(e));
        await load(quiet: true);
      } else {
        state = state.copyWith(busy: false, message: cardErrorMessage(e)); // giữ thẻ, cho bấm lại
      }
    }
  }

  /// "Kết thúc phiên" ở màn chờ: sang màn kết thúc dù còn thẻ chưa quay lại.
  void finish() => state = state.copyWith(phase: ReviewPhase.done);

  void ackMessage() {
    if (state.message != null) state = state.copyWith(message: null);
  }
}

final cardReviewProvider = NotifierProvider.autoDispose.family<CardReviewNotifier, CardReviewState, String>(CardReviewNotifier.new);

/// Đồng hồ của màn ôn (đếm ngược thẻ quay lại): provider riêng để test điều khiển được thời gian.
final cardReviewClockProvider = Provider<DateTime Function()>((ref) => DateTime.now);

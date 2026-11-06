import 'study_card.dart';

/// Nhóm của thẻ trong kế hoạch ngày (study_card_bucket). Giá trị lạ → [unknown].
enum CardBucket {
  due('DUE'),
  newCard('NEW'),
  hard('HARD'),
  random('RANDOM'),
  unknown('');

  const CardBucket(this.api);

  final String api;

  static CardBucket fromApi(Object? value) => values.firstWhere((b) => b.api == value && b != unknown, orElse: () => unknown);
}

/// Ba mức đánh giá (study_card_rating).
enum CardRating {
  notYet('NOT_YET'),
  reviewAgain('REVIEW_AGAIN'),
  remembered('REMEMBERED');

  const CardRating(this.api);

  final String api;
}

/// Kết quả nếu chọn một mức: giai đoạn mới và thời điểm đến hạn (server tính sẵn để nút hiện đúng nhãn).
class NextSchedule {
  const NextSchedule({required this.stage, this.dueAt});

  factory NextSchedule.fromJson(Map<String, dynamic> json) =>
      NextSchedule(stage: CardStage.fromApi(json['stage']), dueAt: json['dueAt'] is String ? DateTime.tryParse(json['dueAt'] as String) : null);

  final CardStage stage;
  final DateTime? dueAt;
}

/// Một thẻ trong hàng ôn: các trường của thẻ + nhóm + kết quả của từng mức đánh giá.
class QueueCard {
  const QueueCard({required this.card, this.bucket = CardBucket.unknown, this.next = const {}});

  factory QueueCard.fromJson(Map<String, dynamic> json) {
    final next = json['next'];
    return QueueCard(
      card: StudyCard.fromJson(json),
      bucket: CardBucket.fromApi(json['bucket']),
      next: {
        if (next is Map<String, dynamic>)
          for (final r in CardRating.values)
            if (next[r.api] is Map<String, dynamic>) r: NextSchedule.fromJson(next[r.api] as Map<String, dynamic>),
      },
    );
  }

  final StudyCard card;
  final CardBucket bucket;

  /// Thiếu mức nào thì không có trong map.
  final Map<CardRating, NextSchedule> next;

  String get id => card.id;
}

class BucketProgress {
  const BucketProgress({this.planned = 0, this.finished = 0});

  factory BucketProgress.fromJson(Map<String, dynamic> json) =>
      BucketProgress(planned: (json['planned'] as num?)?.toInt() ?? 0, finished: (json['finished'] as num?)?.toInt() ?? 0);

  final int planned;
  final int finished;

  int get remaining => planned - finished;
}

/// Tiến độ ôn hôm nay của cả kế hoạch (không tính thẻ tạm dừng).
class CardProgress {
  const CardProgress({this.planned = 0, this.finished = 0, this.remaining = 0, this.byBucket = const {}});

  factory CardProgress.fromJson(Map<String, dynamic> json) {
    final by = json['byBucket'];
    return CardProgress(
      planned: (json['planned'] as num?)?.toInt() ?? 0,
      finished: (json['finished'] as num?)?.toInt() ?? 0,
      remaining: (json['remaining'] as num?)?.toInt() ?? 0,
      byBucket: {
        if (by is Map<String, dynamic>)
          for (final b in CardBucket.values)
            if (b != CardBucket.unknown && by[b.api] is Map<String, dynamic>) b: BucketProgress.fromJson(by[b.api] as Map<String, dynamic>),
      },
    );
  }

  final int planned;
  final int finished;
  final int remaining;
  final Map<CardBucket, BucketProgress> byBucket;

  /// Số thẻ còn lại của một nhóm (0 nếu thiếu).
  int remainingOf(CardBucket b) => byBucket[b]?.remaining ?? 0;

  /// "Ôn thêm" = HARD + RANDOM.
  int get remainingExtra => remainingOf(CardBucket.hard) + remainingOf(CardBucket.random);
}

DateTime? _date(Object? v) => v is String ? DateTime.tryParse(v) : null;

/// GET /cards/queue: thẻ cần ôn ngay (chưa ôn + thẻ "Chưa nhớ" đã đến hạn quay lại, theo thứ tự kế hoạch),
/// tiến độ cả kế hoạch, số đếm của môn, hạn sớm nhất của thẻ còn đợi quay lại trong hôm nay.
class CardQueue {
  const CardQueue({this.date = '', this.quota = 20, this.cards = const [], this.progress = const CardProgress(), this.counts = const CardCounts(), this.soonestDueAt});

  factory CardQueue.fromJson(Map<String, dynamic> json) => CardQueue(
    date: json['date'] as String? ?? '',
    quota: (json['quota'] as num?)?.toInt() ?? 20,
    cards: [for (final c in (json['cards'] as List? ?? const [])) QueueCard.fromJson(c as Map<String, dynamic>)],
    progress: CardProgress.fromJson(json['progress'] as Map<String, dynamic>? ?? const {}),
    counts: CardCounts.fromJson(json['counts'] as Map<String, dynamic>? ?? const {}),
    soonestDueAt: _date(json['soonestDueAt']),
  );

  final String date;
  final int quota;
  final List<QueueCard> cards;
  final CardProgress progress;
  final CardCounts counts;
  final DateTime? soonestDueAt;
}

/// POST /cards/[id]/review (201): thẻ sau khi cập nhật, tiến độ mới, hạn sớm nhất của thẻ còn đợi.
class ReviewResult {
  const ReviewResult({required this.card, this.progress = const CardProgress(), this.soonestDueAt});

  factory ReviewResult.fromJson(Map<String, dynamic> json) => ReviewResult(
    card: QueueCard.fromJson(json['card'] as Map<String, dynamic>),
    progress: CardProgress.fromJson(json['progress'] as Map<String, dynamic>? ?? const {}),
    soonestDueAt: _date(json['soonestDueAt']),
  );

  final QueueCard card;
  final CardProgress progress;
  final DateTime? soonestDueAt;
}

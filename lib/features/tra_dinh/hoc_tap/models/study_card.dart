/// Giai đoạn ôn của thẻ (study_card_stage). Giá trị lạ → [unknown], không làm hỏng cả danh sách.
enum CardStage {
  newCard('NEW', 'Mới'),
  learning('LEARNING', 'Đang học'),
  weekly('WEEKLY', 'Hàng tuần'),
  monthly('MONTHLY', 'Hàng tháng'),
  quarterly('QUARTERLY', 'Hàng quý'),
  unknown('', 'Không rõ');

  const CardStage(this.api, this.label);

  final String api;
  final String label;

  static CardStage fromApi(Object? value) => values.firstWhere((s) => s.api == value && s != unknown, orElse: () => unknown);
}

/// Loại thẻ (study_card_kind).
enum CardKind {
  phrasalVerb('PHRASAL_VERB', 'Cụm động từ'),
  collocation('COLLOCATION', 'Kết hợp từ'),
  idiom('IDIOM', 'Thành ngữ'),
  pattern('PATTERN', 'Cấu trúc'),
  expression('EXPRESSION', 'Cách nói'),
  unknown('', 'Khác');

  const CardKind(this.api, this.label);

  final String api;
  final String label;

  static CardKind fromApi(Object? value) => values.firstWhere((k) => k.api == value && k != unknown, orElse: () => unknown);
}

/// Một thẻ từ vựng (GET /cards, GET/POST/PATCH /cards/[id]). Trường thiếu hoặc lạ không làm hỏng việc đọc.
class StudyCard {
  const StudyCard({
    required this.id,
    this.subjectId = '',
    this.sourceLogId,
    required this.phrase,
    this.meaning = '',
    this.example = '',
    this.note,
    this.kind = CardKind.unknown,
    this.topics = const [],
    this.stage = CardStage.newCard,
    this.dueAt,
    this.reviewCount = 0,
    this.notYetCount = 0,
    this.lastReviewedAt,
    this.suspended = false,
    this.createdAt,
  });

  factory StudyCard.fromJson(Map<String, dynamic> json) => StudyCard(
    id: json['id'] as String,
    subjectId: json['subjectId'] as String? ?? '',
    sourceLogId: json['sourceLogId'] as String?,
    phrase: json['phrase'] as String? ?? '',
    meaning: json['meaning'] as String? ?? '',
    example: json['example'] as String? ?? '',
    note: json['note'] as String?,
    kind: CardKind.fromApi(json['kind']),
    topics: [for (final t in (json['topics'] as List? ?? const [])) if (t is String) t],
    stage: CardStage.fromApi(json['stage']),
    dueAt: _date(json['dueAt']),
    reviewCount: (json['reviewCount'] as num?)?.toInt() ?? 0,
    notYetCount: (json['notYetCount'] as num?)?.toInt() ?? 0,
    lastReviewedAt: _date(json['lastReviewedAt']),
    suspended: json['suspended'] as bool? ?? false,
    createdAt: _date(json['createdAt']),
  );

  final String id;
  final String subjectId;
  final String? sourceLogId;
  final String phrase;
  final String meaning;
  final String example;
  final String? note;
  final CardKind kind;
  final List<String> topics;
  final CardStage stage;

  /// null khi thẻ còn ở giai đoạn Mới.
  final DateTime? dueAt;
  final int reviewCount;
  final int notYetCount;
  final DateTime? lastReviewedAt;
  final bool suspended;
  final DateTime? createdAt;
}

DateTime? _date(Object? v) => v is String ? DateTime.tryParse(v) : null;

/// Số thẻ của cả môn theo giai đoạn (không phụ thuộc bộ lọc).
class CardCounts {
  const CardCounts({this.newCards = 0, this.learning = 0, this.weekly = 0, this.monthly = 0, this.quarterly = 0, this.total = 0, this.suspended = 0});

  factory CardCounts.fromJson(Map<String, dynamic> json) {
    int n(String k) => (json[k] as num?)?.toInt() ?? 0;
    return CardCounts(newCards: n('NEW'), learning: n('LEARNING'), weekly: n('WEEKLY'), monthly: n('MONTHLY'), quarterly: n('QUARTERLY'), total: n('total'), suspended: n('suspended'));
  }

  final int newCards;
  final int learning;
  final int weekly;
  final int monthly;
  final int quarterly;
  final int total;
  final int suspended;

  /// Số thẻ của một giai đoạn; null = tất cả.
  int of(CardStage? stage) => switch (stage) {
    null => total,
    CardStage.newCard => newCards,
    CardStage.learning => learning,
    CardStage.weekly => weekly,
    CardStage.monthly => monthly,
    CardStage.quarterly => quarterly,
    CardStage.unknown => 0,
  };
}

/// GET /cards: một trang thẻ, số đếm cả môn, con trỏ trang kế (null = hết).
class CardListPage {
  const CardListPage({required this.cards, required this.counts, this.nextCursor});

  factory CardListPage.fromJson(Map<String, dynamic> json) => CardListPage(
    cards: [for (final c in (json['cards'] as List? ?? const [])) StudyCard.fromJson(c as Map<String, dynamic>)],
    counts: CardCounts.fromJson(json['counts'] as Map<String, dynamic>? ?? const {}),
    nextCursor: json['nextCursor'] as String?,
  );

  final List<StudyCard> cards;
  final CardCounts counts;
  final String? nextCursor;
}

/// Một thẻ đọc được từ JSON dán vào (kết quả POST /cards/parse). [index] là vị trí (từ 0) trong mảng đầu vào.
class ParsedCardItem {
  const ParsedCardItem({required this.index, required this.phrase, this.meaning = '', this.example = '', this.note, this.kind = CardKind.unknown, this.topics = const []});

  factory ParsedCardItem.fromJson(Map<String, dynamic> json) => ParsedCardItem(
    index: (json['index'] as num?)?.toInt() ?? 0,
    phrase: json['phrase'] as String? ?? '',
    meaning: json['meaning'] as String? ?? '',
    example: json['example'] as String? ?? '',
    note: json['note'] as String?,
    kind: CardKind.fromApi(json['kind']),
    topics: [for (final t in (json['topics'] as List? ?? const [])) if (t is String) t],
  );

  final int index;
  final String phrase;
  final String meaning;
  final String example;
  final String? note;
  final CardKind kind;
  final List<String> topics;

  /// Dạng gửi lên POST /cards/import.
  Map<String, Object?> toImportJson() => {
    'phrase': phrase,
    'meaning': meaning,
    'example': example,
    'note': note,
    'kind': kind.api,
    'topics': topics,
  };
}

/// Lỗi của đầu vào. [index] null = lỗi của cả đầu vào (JSON hỏng, không phải mảng, quá 100 thẻ).
class CardParseError {
  const CardParseError({this.index, this.field, required this.reason});

  factory CardParseError.fromJson(Map<String, dynamic> json) =>
      CardParseError(index: (json['index'] as num?)?.toInt(), field: json['field'] as String?, reason: json['reason'] as String? ?? '');

  final int? index;
  final String? field;
  final String reason;
}

/// Thẻ lặp trong đầu vào: [index] trùng với thẻ ở [firstIndex].
class CardDuplicate {
  const CardDuplicate({required this.index, required this.phrase, this.firstIndex});

  factory CardDuplicate.fromJson(Map<String, dynamic> json) =>
      CardDuplicate(index: (json['index'] as num?)?.toInt() ?? 0, phrase: json['phrase'] as String? ?? '', firstIndex: (json['firstIndex'] as num?)?.toInt());

  final int index;
  final String phrase;
  final int? firstIndex;
}

/// Thẻ đầu vào đã có trong kho của môn (sẽ không được lưu).
class ExistingCard {
  const ExistingCard({required this.index, required this.phrase});

  factory ExistingCard.fromJson(Map<String, dynamic> json) => ExistingCard(index: (json['index'] as num?)?.toInt() ?? 0, phrase: json['phrase'] as String? ?? '');

  final int index;
  final String phrase;
}

/// POST /cards/parse: `cards` là các thẻ SẼ được tạo (đã bỏ thẻ lặp và thẻ đã có trong kho).
class ParsedCards {
  const ParsedCards({this.cards = const [], this.errors = const [], this.duplicates = const [], this.existing = const []});

  factory ParsedCards.fromJson(Map<String, dynamic> json) => ParsedCards(
    cards: [for (final c in (json['cards'] as List? ?? const [])) ParsedCardItem.fromJson(c as Map<String, dynamic>)],
    errors: [for (final e in (json['errors'] as List? ?? const [])) CardParseError.fromJson(e as Map<String, dynamic>)],
    duplicates: [for (final d in (json['duplicates'] as List? ?? const [])) CardDuplicate.fromJson(d as Map<String, dynamic>)],
    existing: [for (final e in (json['existing'] as List? ?? const [])) ExistingCard.fromJson(e as Map<String, dynamic>)],
  );

  final List<ParsedCardItem> cards;
  final List<CardParseError> errors;
  final List<CardDuplicate> duplicates;
  final List<ExistingCard> existing;

  bool get hasErrors => errors.isNotEmpty;
}

/// POST /cards/import.
class ImportResult {
  const ImportResult({required this.created, required this.skipped});

  factory ImportResult.fromJson(Map<String, dynamic> json) => ImportResult(created: (json['created'] as num?)?.toInt() ?? 0, skipped: (json['skipped'] as num?)?.toInt() ?? 0);

  final int created;
  final int skipped;
}

/// Một chủ đề đang có trong môn và số thẻ của nó (GET /cards/topics).
class TopicCount {
  const TopicCount({required this.topic, required this.cards});

  factory TopicCount.fromJson(Map<String, dynamic> json) => TopicCount(topic: json['topic'] as String? ?? '', cards: (json['cards'] as num?)?.toInt() ?? 0);

  final String topic;
  final int cards;
}

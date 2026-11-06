import 'study_card.dart';

int _int(Object? v, [int fallback = 0]) => v is num && v.isFinite ? v.toInt() : fallback;

double _rate(Object? v) => v is num && v.isFinite ? v.toDouble().clamp(0.0, 1.0) : 0.0;

/// Một nhóm khó (theo loại, chủ đề hoặc buổi học): [everNotYetCards]/[totalCards] thẻ từng bị Chưa nhớ, [rate] ∈ [0, 1].
class InsightGroup {
  const InsightGroup({required this.key, required this.label, this.totalCards = 0, this.everNotYetCards = 0, this.rate = 0});

  factory InsightGroup.fromJson(Map<String, dynamic> json) => InsightGroup(
    key: json['key'] as String? ?? '',
    label: json['label'] as String? ?? (json['key'] as String? ?? ''),
    totalCards: _int(json['totalCards']),
    everNotYetCards: _int(json['everNotYetCards']),
    rate: _rate(json['rate']),
  );

  final String key;
  final String label;
  final int totalCards;
  final int everNotYetCards;
  final double rate;

  int get percent => (rate * 100).round();
}

/// Số tổng trong kỳ đã chọn (7 / 30 / 90 ngày).
class InsightTotals {
  const InsightTotals({this.reviews = 0, this.notYetRate = 0, this.promotedToWeekly = 0});

  factory InsightTotals.fromJson(Map<String, dynamic> json) => InsightTotals(
    reviews: _int(json['reviews']),
    notYetRate: _rate(json['notYetRate']),
    promotedToWeekly: _int(json['promotedToWeekly']),
  );

  final int reviews;
  final double notYetRate;
  final int promotedToWeekly;

  int get notYetPercent => (notYetRate * 100).round();
}

/// Thẻ hay quên (từ 3 lượt Chưa nhớ trở lên).
class HardCard {
  const HardCard({
    required this.id,
    required this.phrase,
    this.meaning = '',
    this.example = '',
    this.note,
    this.kind = CardKind.unknown,
    this.topics = const [],
    this.notYetCount = 0,
    this.reviewCount = 0,
  });

  factory HardCard.fromJson(Map<String, dynamic> json) => HardCard(
    id: json['id'] as String? ?? '',
    phrase: json['phrase'] as String? ?? '',
    meaning: json['meaning'] as String? ?? '',
    example: json['example'] as String? ?? '',
    note: json['note'] is String ? json['note'] as String : null,
    kind: CardKind.fromApi(json['kind']),
    topics: [for (final t in (json['topics'] is List ? json['topics'] as List : const [])) if (t is String) t],
    notYetCount: _int(json['notYetCount']),
    reviewCount: _int(json['reviewCount']),
  );

  final String id;
  final String phrase;
  final String meaning;
  final String example;
  final String? note;
  final CardKind kind;
  final List<String> topics;
  final int notYetCount;
  final int reviewCount;
}

List<InsightGroup> _groups(Object? v) => [for (final g in (v is List ? v : const [])) if (g is Map<String, dynamic>) InsightGroup.fromJson(g)];

/// GET /cards/insights. Các nhóm là TÍCH LUỸ suốt đời thẻ (thẻ đã Chưa nhớ rồi Đã nhớ vẫn tính); chỉ [totals] theo kỳ [days].
/// Nhóm dưới ngưỡng [minCards] không có trong danh sách nên các danh sách có thể rỗng.
class CardInsights {
  const CardInsights({
    this.days = 30,
    this.minCards = 10,
    this.totals = const InsightTotals(),
    this.byKind = const [],
    this.byTopic = const [],
    this.byLesson = const [],
    this.hardestCards = const [],
  });

  factory CardInsights.fromJson(Map<String, dynamic> json) => CardInsights(
    days: _int(json['days'], 30),
    minCards: _int(json['minCards'], 10),
    totals: json['totals'] is Map<String, dynamic> ? InsightTotals.fromJson(json['totals'] as Map<String, dynamic>) : const InsightTotals(),
    byKind: _groups(json['byKind']),
    byTopic: _groups(json['byTopic']),
    byLesson: _groups(json['byLesson']),
    hardestCards: [for (final c in (json['hardestCards'] is List ? json['hardestCards'] as List : const [])) if (c is Map<String, dynamic>) HardCard.fromJson(c)],
  );

  final int days;
  final int minCards;
  final InsightTotals totals;
  final List<InsightGroup> byKind;
  final List<InsightGroup> byTopic;
  final List<InsightGroup> byLesson;
  final List<HardCard> hardestCards;

  bool get hasGroups => byKind.isNotEmpty || byTopic.isNotEmpty || byLesson.isNotEmpty;
}

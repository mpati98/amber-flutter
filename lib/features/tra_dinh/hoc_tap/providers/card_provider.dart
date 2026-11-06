import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/study_card.dart';
import '../services/hoc_tap_api.dart';

// Kho thẻ từ vựng. autoDispose như phần còn lại của Học tập: rời màn là bỏ cache.

/// Bộ lọc của kho thẻ; null = không lọc. So sánh theo giá trị.
class CardFilter {
  const CardFilter({this.stage, this.kind, this.topic, this.q = ''});

  final CardStage? stage;
  final CardKind? kind;
  final String? topic;
  final String q;

  /// Bộ lọc loại / chủ đề đang bật (không tính giai đoạn và ô tìm).
  int get sheetActiveCount => (kind != null ? 1 : 0) + (topic != null ? 1 : 0);

  bool get isEmpty => stage == null && kind == null && topic == null && q.trim().isEmpty;

  CardFilter copyWith({Object? stage = _keep, Object? kind = _keep, Object? topic = _keep, String? q}) => CardFilter(
    stage: identical(stage, _keep) ? this.stage : stage as CardStage?,
    kind: identical(kind, _keep) ? this.kind : kind as CardKind?,
    topic: identical(topic, _keep) ? this.topic : topic as String?,
    q: q ?? this.q,
  );

  @override
  bool operator ==(Object other) => other is CardFilter && other.stage == stage && other.kind == kind && other.topic == topic && other.q == q;

  @override
  int get hashCode => Object.hash(stage, kind, topic, q);
}

const _keep = Object();

/// Trạng thái màn kho thẻ: bộ lọc đang áp dụng, các thẻ đã tải, số đếm cả môn, con trỏ trang kế.
class CardLibraryState {
  const CardLibraryState({
    this.filter = const CardFilter(),
    this.cards = const [],
    this.counts = const CardCounts(),
    this.nextCursor,
    this.loading = false,
    this.loadingMore = false,
    this.error,
    this.moreError,
  });

  factory CardLibraryState.fromPage(CardFilter filter, CardListPage page) =>
      CardLibraryState(filter: filter, cards: page.cards, counts: page.counts, nextCursor: page.nextCursor);

  final CardFilter filter;
  final List<StudyCard> cards;
  final CardCounts counts;
  final String? nextCursor;

  /// Đang tải lại trang đầu (đổi bộ lọc / làm mới); danh sách cũ vẫn giữ.
  final bool loading;
  final bool loadingMore;

  /// Lỗi tải trang đầu sau khi đổi bộ lọc (danh sách bị bỏ); lỗi tải thêm thì giữ danh sách và báo ở cuối.
  final Object? error;
  final Object? moreError;

  CardLibraryState copyWith({
    CardFilter? filter,
    List<StudyCard>? cards,
    CardCounts? counts,
    Object? nextCursor = _keep,
    bool? loading,
    bool? loadingMore,
    Object? error = _keep,
    Object? moreError = _keep,
  }) => CardLibraryState(
    filter: filter ?? this.filter,
    cards: cards ?? this.cards,
    counts: counts ?? this.counts,
    nextCursor: identical(nextCursor, _keep) ? this.nextCursor : nextCursor as String?,
    loading: loading ?? this.loading,
    loadingMore: loadingMore ?? this.loadingMore,
    error: identical(error, _keep) ? this.error : error,
    moreError: identical(moreError, _keep) ? this.moreError : moreError,
  );
}

/// Danh sách thẻ của một môn: trang đầu khi mở, [setFilter] đổi bộ lọc, [loadMore] nối trang kế bằng con trỏ.
/// Mỗi lần tải lại tăng [_seq] để bỏ kết quả của yêu cầu cũ (gõ tìm nhanh, đổi chip liên tục).
class CardLibraryNotifier extends AsyncNotifier<CardLibraryState> {
  CardLibraryNotifier(this.subjectId);

  final String subjectId;
  int _seq = 0;

  HocTapApi get _api => ref.read(hocTapApiProvider);

  Future<CardListPage> _fetch(CardFilter f, {String? cursor}) =>
      _api.getCards(subjectId: subjectId, stage: f.stage, kind: f.kind, topic: f.topic, q: f.q, cursor: cursor);

  @override
  Future<CardLibraryState> build() async => CardLibraryState.fromPage(const CardFilter(), await ref.watch(hocTapApiProvider).getCards(subjectId: subjectId));

  /// Áp bộ lọc mới và tải lại từ trang đầu.
  Future<void> setFilter(CardFilter filter) async {
    final prev = state.value;
    if (prev == null || prev.filter == filter) return;
    state = AsyncData(prev.copyWith(filter: filter, loading: true, error: null, moreError: null));
    await _reloadFirstPage(filter);
  }

  /// Tải lại trang đầu với bộ lọc hiện tại (sau khi sửa / thêm / xoá thẻ, kéo để làm mới, nút Thử lại).
  Future<void> reload() async {
    final prev = state.value;
    if (prev == null) return;
    state = AsyncData(prev.copyWith(loading: true, error: null, moreError: null));
    await _reloadFirstPage(prev.filter);
  }

  Future<void> _reloadFirstPage(CardFilter filter) async {
    final seq = ++_seq;
    try {
      final page = await _fetch(filter);
      if (seq != _seq) return;
      state = AsyncData(CardLibraryState.fromPage(filter, page));
    } catch (e) {
      if (seq != _seq) return;
      final cur = state.value ?? const CardLibraryState();
      state = AsyncData(cur.copyWith(filter: filter, cards: const [], nextCursor: null, loading: false, error: e));
    }
  }

  /// Nối trang kế (nếu còn). Lỗi giữ danh sách hiện có và đặt moreError để cuối danh sách hiện nút thử lại.
  Future<void> loadMore() async {
    final cur = state.value;
    if (cur == null || cur.nextCursor == null || cur.loading || cur.loadingMore) return;
    final seq = _seq;
    state = AsyncData(cur.copyWith(loadingMore: true, moreError: null));
    try {
      final page = await _fetch(cur.filter, cursor: cur.nextCursor);
      if (seq != _seq) return;
      final now = state.value ?? cur;
      final known = {for (final c in now.cards) c.id};
      state = AsyncData(now.copyWith(cards: [...now.cards, for (final c in page.cards) if (!known.contains(c.id)) c], counts: page.counts, nextCursor: page.nextCursor, loadingMore: false));
    } catch (e) {
      if (seq != _seq) return;
      state = AsyncData((state.value ?? cur).copyWith(loadingMore: false, moreError: e));
    }
  }
}

final cardLibraryProvider = AsyncNotifierProvider.autoDispose.family<CardLibraryNotifier, CardLibraryState, String>(CardLibraryNotifier.new);

/// Các chủ đề đang có trong môn (nhiều thẻ trước).
final cardTopicsProvider = FutureProvider.autoDispose.family<List<TopicCount>, String>((ref, subjectId) => ref.watch(hocTapApiProvider).getCardTopics(subjectId));

/// Các thao tác ghi thẻ: gọi API rồi làm mới danh sách chủ đề. Màn kho thẻ tự `reload()` danh sách của nó (giữ bộ lọc).
/// Lỗi ném lại cho nơi gọi báo.
class CardActions {
  const CardActions(this._ref);

  final Ref _ref;

  HocTapApi get _api => _ref.read(hocTapApiProvider);

  Future<StudyCard> create(Map<String, Object?> body) async {
    final c = await _api.createCard(body);
    _ref.invalidate(cardTopicsProvider);
    return c;
  }

  Future<StudyCard> patch(String id, Map<String, Object?> patch) async {
    final c = await _api.patchCard(id, patch);
    _ref.invalidate(cardTopicsProvider);
    return c;
  }

  Future<void> delete(String id) async {
    await _api.deleteCard(id);
    _ref.invalidate(cardTopicsProvider);
  }

  Future<ParsedCards> parse(String subjectId, String text) => _api.parseCards(subjectId, text);

  Future<ImportResult> import(String subjectId, List<ParsedCardItem> cards, {String? logId}) async {
    final r = await _api.importCards(subjectId, [for (final c in cards) c.toImportJson()], logId: logId);
    _ref.invalidate(cardTopicsProvider);
    return r;
  }
}

final cardActionsProvider = Provider<CardActions>(CardActions.new);

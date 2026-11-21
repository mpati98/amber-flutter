import 'dart:async';

import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../shared/theme/design_tokens.dart';
import '../../../../shared/theme/app_theme.dart';
import '../models/study_card.dart';
import '../providers/card_provider.dart';
import '../utils/async_view.dart';
import 'card_filter_sheet.dart';
import 'card_sheet.dart';
import 'card_widgets.dart';
import 'hoc_tap_common.dart';

/// Kho thẻ từ vựng của một môn — thân khung "Kho thẻ" trên màn Trà Đình (ZoneFrame không tự cuộn: panel có đầu cố định
/// = tổng số + ô tìm + "Lọc" + chip giai đoạn, rồi danh sách cuộn vô hạn của riêng nó). Chạm thẻ → sheet xem / sửa ([showCardSheet]).
/// Nút "Ôn thẻ" ở khung Hôm nay (nút vàng duy nhất của màn); "+ Nhập thẻ", "+ một thẻ", "Thống kê" là action của khung.
class CardLibraryPanel extends ConsumerStatefulWidget {
  const CardLibraryPanel({super.key, required this.subjectId, required this.onImport});

  final String subjectId;

  /// Mở màn nhập thẻ từ Claude (lời mời khi kho còn trống).
  final Future<void> Function() onImport;

  @override
  ConsumerState<CardLibraryPanel> createState() => _LibraryState();
}

class _LibraryState extends ConsumerState<CardLibraryPanel> {
  static const _searchDebounce = Duration(milliseconds: 350);

  final _search = TextEditingController();
  final _scroll = ScrollController();
  Timer? _debounce;

  CardLibraryNotifier get _notifier => ref.read(cardLibraryProvider(widget.subjectId).notifier);

  @override
  void initState() {
    super.initState();
    _scroll.addListener(_maybeLoadMore);
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _search.dispose();
    _scroll.dispose();
    super.dispose();
  }

  /// Gần cuối danh sách thì nối trang kế. Không tự thử lại khi lần trước lỗi (nút "Thử lại" ở cuối làm việc đó).
  void _maybeLoadMore() {
    final s = ref.read(cardLibraryProvider(widget.subjectId)).value;
    if (s == null || s.nextCursor == null || s.moreError != null || s.error != null) return;
    if (_scroll.hasClients && _scroll.position.extentAfter < 400) _notifier.loadMore();
  }

  void _onSearchChanged(String text) {
    _debounce?.cancel();
    _debounce = Timer(_searchDebounce, () {
      final s = ref.read(cardLibraryProvider(widget.subjectId)).value;
      if (s != null) _notifier.setFilter(s.filter.copyWith(q: text));
    });
  }

  void _clearFilters() {
    _search.clear();
    _debounce?.cancel();
    _notifier.setFilter(const CardFilter());
  }

  Future<void> _openCard(StudyCard? card) async {
    final changed = await showCardSheet(context, subjectId: widget.subjectId, card: card);
    if (changed == true && mounted) await _notifier.reload();
  }

  Future<void> _openFilters(CardFilter current) async {
    final next = await showCardFilterSheet(context, subjectId: widget.subjectId, current: current);
    if (next != null && mounted) await _notifier.setFilter(next);
  }

  Future<void> _openImport() => widget.onImport();

  @override
  Widget build(BuildContext context) {
    final async = ref.watch(cardLibraryProvider(widget.subjectId));
    // Danh sách ngắn hơn màn hình thì không có cuộn để kích hoạt: kiểm tra sau mỗi lần dựng.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _maybeLoadMore();
    });

    return switch (async.settled) {
      AsyncData(:final value) => _content(value),
      AsyncError() => HocTapLoadError(what: 'kho thẻ', onRetry: () => ref.invalidate(cardLibraryProvider(widget.subjectId))),
      _ => const Center(child: Padding(padding: EdgeInsets.all(24), child: CircularProgressIndicator())),
    };
  }

  Widget _content(CardLibraryState s) {
    final theme = Theme.of(context);
    final filter = s.filter;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text('${s.counts.total} thẻ', key: const ValueKey('library-total'), style: DesignText.muted),
        Padding(
          padding: const EdgeInsets.fromLTRB(0, 6, 8, 8),
          child: Row(
            spacing: 8,
            children: [
              Expanded(
                child: TextField(
                  key: const ValueKey('card-search'),
                  controller: _search,
                  textInputAction: TextInputAction.search,
                  decoration: const InputDecoration(hintText: 'Tìm cụm từ hoặc nghĩa', prefixIcon: Icon(Icons.search), isDense: true),
                  onChanged: _onSearchChanged,
                ),
              ),
              OutlinedButton.icon(
                key: const ValueKey('card-filter'),
                onPressed: () => _openFilters(filter),
                icon: const Icon(Icons.tune, size: 18),
                label: Text(filter.sheetActiveCount == 0 ? 'Lọc' : 'Lọc (${filter.sheetActiveCount})'),
              ),
            ],
          ),
        ),
        ChipScrollRow(
          padding: const EdgeInsets.only(right: 8),
          children: [
            for (final stage in const [null, CardStage.newCard, CardStage.learning, CardStage.weekly, CardStage.monthly, CardStage.quarterly])
              FilterPill(
                key: ValueKey('stage-chip-${stage?.api ?? 'all'}'),
                label: '${stage?.label ?? 'Tất cả'} ${s.counts.of(stage)}',
                selected: filter.stage == stage,
                onSelected: () => _notifier.setFilter(filter.copyWith(stage: stage)),
              ),
          ],
        ),
        SizedBox(height: 3, child: s.loading ? const LinearProgressIndicator(key: ValueKey('library-loading')) : null),
        Expanded(
          child: RefreshIndicator(
            onRefresh: _notifier.reload,
            child: s.error != null
                ? ListView(physics: const AlwaysScrollableScrollPhysics(), children: [HocTapLoadError(what: 'kho thẻ', onRetry: _notifier.reload)])
                : s.cards.isEmpty && !s.loading
                ? _empty(s)
                : ListView.separated(
                    controller: _scroll,
                    physics: const AlwaysScrollableScrollPhysics(),
                    // Đáy chừa chỗ cho nút chat nổi (như ZoneFrame.chatClearance).
                    padding: const EdgeInsets.fromLTRB(0, 8, 8, 56),
                    itemCount: s.cards.length + 1,
                    separatorBuilder: (_, _) => const SizedBox(height: 8),
                    itemBuilder: (context, i) {
                      if (i == s.cards.length) return _footer(s, theme);
                      final c = s.cards[i];
                      return CardRow(card: c, onTap: () => _openCard(c));
                    },
                  ),
          ),
        ),
      ],
    );
  }

  Widget _footer(CardLibraryState s, ThemeData theme) {
    if (s.loadingMore) return const Padding(padding: EdgeInsets.all(12), child: Center(child: SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2))));
    if (s.moreError != null) {
      return Padding(
        padding: const EdgeInsets.all(8),
        child: Column(
          children: [
            Text('Không tải thêm được thẻ.', style: TextStyle(color: theme.textMuted)),
            TextButton(key: const ValueKey('library-retry-more'), onPressed: _notifier.loadMore, child: const Text('Thử lại')),
          ],
        ),
      );
    }
    return const SizedBox(height: 8);
  }

  /// Kho trống hẳn → mời nhập thẻ; có bộ lọc mà không khớp → báo và cho xoá bộ lọc.
  Widget _empty(CardLibraryState s) {
    final theme = Theme.of(context);
    final truly = s.counts.total == 0 && s.filter.isEmpty;
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(24),
      children: [
        Column(
          key: ValueKey(truly ? 'library-empty' : 'library-no-match'),
          spacing: 12,
          children: [
            Text(truly ? 'Kho thẻ còn trống.' : 'Không có thẻ nào khớp bộ lọc.', style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
            Text(
              truly ? 'Nhập thẻ từ Claude hoặc thêm từng thẻ bằng nút + ở đầu khung.' : 'Thử đổi từ khoá hoặc bỏ bớt bộ lọc.',
              textAlign: TextAlign.center,
              style: TextStyle(color: theme.textMuted),
            ),
            // Nút viền: nút vàng duy nhất của màn là việc tiếp theo ở khung Hôm nay.
            if (truly) OutlinedButton(key: const ValueKey('library-empty-import'), onPressed: _openImport, child: const Text('Nhập thẻ từ Claude'))
            else OutlinedButton(key: const ValueKey('library-clear-filters'), onPressed: _clearFilters, child: const Text('Xoá bộ lọc')),
          ],
        ),
      ],
    );
  }
}

import 'dart:async';

import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../shared/theme/design_tokens.dart';
import '../../../../shared/widgets/design_page.dart';
import '../../../../shared/theme/app_theme.dart';
import '../models/study_card.dart';
import '../providers/card_provider.dart';
import '../utils/async_view.dart';
import '../widgets/card_filter_sheet.dart';
import '../widgets/card_sheet.dart';
import '../widgets/card_widgets.dart';
import '../widgets/hoc_tap_common.dart';

/// Kho thẻ từ vựng của một môn: tìm, lọc theo giai đoạn / loại / chủ đề, cuộn vô hạn, thêm / sửa / xoá thẻ.
class CardLibraryScreen extends StatelessWidget {
  const CardLibraryScreen({super.key, this.subjectId});

  final String? subjectId;

  @override
  Widget build(BuildContext context) =>
      CardSubjectGate(subjectId: subjectId, title: 'Kho thẻ', builder: (context, id, name) => _Library(key: ValueKey('library-$id'), subjectId: id, subjectName: name));
}

class _Library extends ConsumerStatefulWidget {
  const _Library({super.key, required this.subjectId, this.subjectName});

  final String subjectId;
  final String? subjectName;

  @override
  ConsumerState<_Library> createState() => _LibraryState();
}

class _LibraryState extends ConsumerState<_Library> {
  static const _searchDebounce = Duration(milliseconds: 350);

  final _search = TextEditingController();
  final _scroll = ScrollController();
  Timer? _debounce;

  CardLibraryNotifier get _notifier => ref.read(cardLibraryProvider(widget.subjectId).notifier);
  String get _reviewPath => '/tra-dinh/hoc-tap/the/on?subjectId=${widget.subjectId}';
  String get _importPath => '/tra-dinh/hoc-tap/the/them?subjectId=${widget.subjectId}';

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

  Future<void> _openReview() async {
    await context.push(_reviewPath);
    if (mounted) await _notifier.reload(); // có thể vừa ôn: lịch hạn của thẻ đã đổi
  }

  Future<void> _openImport() async {
    await context.push(_importPath);
    if (mounted) await _notifier.reload(); // có thể vừa nhập thẻ
  }

  @override
  Widget build(BuildContext context) {
    final async = ref.watch(cardLibraryProvider(widget.subjectId));
    final state = async.value;
    // Danh sách ngắn hơn màn hình thì không có cuộn để kích hoạt: kiểm tra sau mỗi lần dựng.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _maybeLoadMore();
    });

    return DesignScaffold(
      title: 'Kho thẻ',
      backFallback: '/tra-dinh',
      // Màn có nút "+ Thêm thẻ từ Claude" cố định ở đáy → không gắn nút chat nổi (sẽ che nút).
      chat: false,
      // Tiêu đề 2 dòng: thu nhỏ khi không vừa thanh trên cao 52 (màn hẹp / chữ phóng to).
      titleWidget: FittedBox(
        fit: BoxFit.scaleDown,
        alignment: Alignment.centerLeft,
        child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('Kho thẻ', style: DesignText.serif(fontSize: 16, fontWeight: FontWeight.w700, color: DesignColors.text)),
          if (state != null)
            Text(
              '${state.counts.total} thẻ${widget.subjectName == null ? '' : ' · ${widget.subjectName}'}',
              key: const ValueKey('library-total'),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 12, color: DesignColors.muted),
            ),
        ],
      ),
      ),
      actions: [
        IconButton(key: const ValueKey('card-stats'), tooltip: 'Thống kê', color: DesignColors.gold, icon: const Icon(Icons.insights_outlined), onPressed: () => context.push('/tra-dinh/hoc-tap/the/thong-ke?subjectId=${widget.subjectId}')),
        IconButton(key: const ValueKey('card-add'), tooltip: 'Thêm một thẻ', color: DesignColors.gold, icon: const Icon(Icons.add), onPressed: () => _openCard(null)),
      ],
      bottomNavigationBar: SafeArea(
        child: Center(
          heightFactor: 1,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 640),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
              child: FilledButton(key: const ValueKey('card-import'), onPressed: _openImport, child: const Text('+ Thêm thẻ từ Claude')),
            ),
          ),
        ),
      ),
      body: HocTapBody(
        child: switch (async.settled) {
          AsyncData(:final value) => _content(value),
          AsyncError() => ListView(children: [HocTapLoadError(what: 'kho thẻ', onRetry: () => ref.invalidate(cardLibraryProvider(widget.subjectId)))]),
          _ => const Center(child: CircularProgressIndicator()),
        },
      ),
    );
  }

  Widget _content(CardLibraryState s) {
    final theme = Theme.of(context);
    final filter = s.filter;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
          child: FilledButton.icon(key: const ValueKey('card-review-start'), onPressed: _openReview, icon: const Icon(Icons.play_arrow), label: const Text('Ôn thẻ hôm nay')),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
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
          padding: const EdgeInsets.symmetric(horizontal: 16),
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
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
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
      padding: const EdgeInsets.all(32),
      children: [
        Column(
          key: ValueKey(truly ? 'library-empty' : 'library-no-match'),
          spacing: 12,
          children: [
            Text(truly ? 'Kho thẻ còn trống.' : 'Không có thẻ nào khớp bộ lọc.', style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
            Text(
              truly ? 'Nhập thẻ từ Claude hoặc thêm từng thẻ bằng nút + ở góc trên.' : 'Thử đổi từ khoá hoặc bỏ bớt bộ lọc.',
              textAlign: TextAlign.center,
              style: TextStyle(color: theme.textMuted),
            ),
            if (truly) FilledButton.tonal(key: const ValueKey('library-empty-import'), onPressed: _openImport, child: const Text('Nhập thẻ từ Claude'))
            else OutlinedButton(key: const ValueKey('library-clear-filters'), onPressed: _clearFilters, child: const Text('Xoá bộ lọc')),
          ],
        ),
      ],
    );
  }
}

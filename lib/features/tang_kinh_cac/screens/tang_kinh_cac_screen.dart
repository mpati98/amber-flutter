import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../shared/theme/design_tokens.dart';
import '../../../shared/widgets/list_frame.dart';
import '../../../shared/widgets/zone_frame.dart';
import '../../../shared/widgets/zone_scaffold.dart';
import '../../du_lieu_huan_luyen/providers/training_log_provider.dart';
import '../../du_lieu_huan_luyen/widgets/training_log_detail_view.dart';
import '../../du_lieu_huan_luyen/widgets/training_log_list.dart';
import '../models/document.dart';
import '../models/publication.dart';
import '../providers/document_provider.dart';
import '../providers/publication_provider.dart';
import '../providers/tang_kinh_cac_provider.dart';
import '../widgets/add_book_modal.dart';
import '../widgets/add_document_modal.dart';
import '../widgets/book_view.dart';
import '../widgets/document_card.dart';
import '../widgets/document_viewer_modal.dart';
import '../widgets/reading_goal_view.dart';
import '../widgets/status_badge.dart';
import '../widgets/type_tag.dart';

/// 4 tầng, giữ đúng dữ liệu hiện có: số tầng (`?tang=`) · nhãn trên thanh chọn tầng.
const tkcFloors = [(1, 'Tầng 1 · Sách'), (2, 'Tầng 2 · Tài liệu'), (3, 'Tầng 3 · Kế hoạch đọc'), (4, 'Tầng 4 · Huấn luyện')];

/// Tầng mở khi không có / sai `?tang=`.
const tkcDefaultFloor = 2;

/// `?tang=` hợp lệ (1–4) hoặc [tkcDefaultFloor].
int tkcFloorOf(String? raw) {
  final n = int.tryParse(raw ?? '');
  return n != null && n >= 1 && n <= tkcFloors.length ? n : tkcDefaultFloor;
}

/// Đường dẫn màn Tàng Kinh Các ở tầng [tang], mở mục [id] (nếu có).
String tkcLocation(int tang, {String? id}) =>
    Uri(path: '/tang-kinh-cac', queryParameters: {'tang': '$tang', 'id': ?id}).toString();

// Bộ lọc chip của từng tầng (null = Tất cả), thứ tự như màn cũ.
const _bookFilters = <PublicationStatus?>[
  null,
  PublicationStatus.reading,
  PublicationStatus.toRead,
  PublicationStatus.read,
  PublicationStatus.abandoned,
];
const _docFilters = <DocumentType?>[
  null,
  DocumentType.text,
  DocumentType.checklist,
  DocumentType.mindmap,
  DocumentType.image,
  DocumentType.file,
];

/// /tang-kinh-cac?tang=1..4&id=… — MỘT màn cho cả Tàng Kinh Các ([ZoneScaffold], không cuộn trang).
/// Thanh chọn tầng cố định; ≥ 600: khung "Danh sách" (tìm + chip lọc, "+ Thêm") | khung "Nội dung" (mục `?id=`, chưa chọn
/// thì mục mới nhất của tầng; mở rộng toàn màn được), tỉ lệ 2 / 3. < 600: chỉ Danh sách; chạm một mục → push chính màn này
/// kèm `?id=`, hiện Nội dung toàn màn. Route cũ (/sach, /tai-lieu, /ke-hoach-doc, /du-lieu-huan-luyen[/:id]) redirect về đây.
class TangKinhCacScreen extends ConsumerStatefulWidget {
  const TangKinhCacScreen({super.key, this.tang = tkcDefaultFloor, this.id});

  final int tang;
  final String? id;

  static const layout = ZoneRow([ZoneCell('list', flex: 2), ZoneCell('content', flex: 3)]);

  @override
  ConsumerState<TangKinhCacScreen> createState() => _TangKinhCacScreenState();
}

class _TangKinhCacScreenState extends ConsumerState<TangKinhCacScreen> {
  // Tìm + chip lọc theo từng tầng, giữ khi đổi qua lại giữa các tầng.
  final _queries = <int, String>{};
  final _search = TextEditingController();
  PublicationStatus? _bookStatus;
  DocumentType? _docType;

  int get _tang => widget.tang;
  String get _query => _queries[_tang] ?? '';

  @override
  void initState() {
    super.initState();
    _search.text = _query;
  }

  @override
  void didUpdateWidget(TangKinhCacScreen old) {
    super.didUpdateWidget(old);
    if (old.tang != widget.tang) _search.text = _query;
  }

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  bool _compact(BuildContext context) => MediaQuery.sizeOf(context).width < DesignLayout.medium;

  /// Chọn một mục: màn rộng thay `?id=` tại chỗ; điện thoại push chính màn này kèm `?id=` (Nội dung toàn màn, ← về danh sách).
  void _select(String id) {
    final to = tkcLocation(_tang, id: id);
    _compact(context) ? context.push(to) : context.go(to);
  }

  void _afterDelete(BuildContext frameContext, bool expanded) {
    if (expanded) Navigator.of(frameContext).pop();
    if (_compact(context) && GoRouter.of(context).canPop()) {
      context.pop();
    } else {
      context.go(tkcLocation(_tang));
    }
  }

  Future<void> _refresh() async {
    switch (_tang) {
      case 1:
        ref.invalidate(publicationsProvider);
      case 2:
        ref.invalidate(documentsProvider);
      case 3:
        ref.invalidate(readingGoalProvider);
      default:
        ref.invalidate(trainingStatsProvider);
        ref.invalidate(logListProvider);
    }
  }

  @override
  Widget build(BuildContext context) {
    final compact = _compact(context);
    final showContentOnly = compact && widget.id != null;

    final listFrame = ZoneFrame(
      key: ValueKey('tkc-list-$_tang'),
      title: 'Danh sách',
      onRefresh: _refresh,
      actions: [
        if (_tang == 1) DesignButton.outline(key: const ValueKey('tkc-add'), label: '+ Thêm', onPressed: () => showAddBookModal(context)),
        if (_tang == 2) DesignButton.outline(key: const ValueKey('tkc-add'), label: '+ Thêm', onPressed: () => showAddDocumentModal(context)),
      ],
      header: _listHeader(),
      childBuilder: (_, _) => _list(compact ? null : widget.id),
    );
    final contentFrame = ZoneFrame(
      key: ValueKey('tkc-content-$_tang'),
      title: 'Nội dung',
      expandable: true,
      childBuilder: (frameContext, expanded) => _content(frameContext, expanded),
    );

    return ZoneScaffold(
      title: 'Tàng Kinh Các',
      // Nội dung toàn màn trên điện thoại: ← về danh sách của tầng (mở thẳng bằng link thì không có trang để pop).
      backFallback: showContentOnly ? tkcLocation(_tang) : '/',
      toolbar: showContentOnly
          ? null
          : DesignChipRow<int>(
              items: tkcFloors,
              selected: _tang,
              onSelected: (n) => context.go(tkcLocation(n)),
              keyOf: (n) => ValueKey('tkc-tang-$n'),
            ),
      wide: TangKinhCacScreen.layout,
      medium: TangKinhCacScreen.layout,
      compact: (_) => showContentOnly ? contentFrame : listFrame,
      panes: [
        ZonePane(id: 'list', label: 'Danh sách', child: listFrame),
        ZonePane(id: 'content', label: 'Nội dung', child: contentFrame),
      ],
    );
  }

  // ───────────────────────── Danh sách ─────────────────────────

  Widget? _listHeader() {
    final search = TextField(
      key: const ValueKey('tkc-search'),
      controller: _search,
      onChanged: (v) => setState(() => _queries[_tang] = v),
      style: DesignText.body,
      cursorColor: DesignColors.gold,
      decoration: designInput(switch (_tang) {
        1 => 'Tìm tên sách, tác giả…',
        2 => 'Tìm tiêu đề, nội dung, thẻ…',
        _ => 'Tìm câu gốc, agent, công cụ…',
      }).copyWith(prefixIcon: const Icon(Icons.search, size: 18, color: DesignColors.muted)),
    );
    final Widget? extra = switch (_tang) {
      1 => DesignChipRow<PublicationStatus?>(
        items: [for (final f in _bookFilters) (f, f?.label ?? 'Tất cả')],
        selected: _bookStatus,
        onSelected: (f) => setState(() => _bookStatus = f),
      ),
      2 => DesignChipRow<DocumentType?>(
        items: [for (final f in _docFilters) (f, f?.label ?? 'Tất cả')],
        selected: _docType,
        onSelected: (f) => setState(() => _docType = f),
      ),
      4 => const TrainingLogListHeader(),
      _ => null,
    };
    // Tầng 3 chỉ có một mục (năm nay) — không cần ô tìm / chip.
    if (_tang == 3) return null;
    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, spacing: 8, children: [search, ?extra]);
  }

  bool _hit(Iterable<String?> fields) {
    final q = _query.trim().toLowerCase();
    return q.isEmpty || fields.any((f) => f != null && f.toLowerCase().contains(q));
  }

  /// [selectedId] null trên điện thoại (danh sách không có mục "đang mở").
  Widget _list(String? selectedId) {
    switch (_tang) {
      case 1:
        final books = ref.watch(publicationsProvider(_bookStatus));
        final current = selectedId ?? (_compact(context) ? null : ref.watch(publicationsProvider(null)).value?.firstOrNull?.id);
        return books.when(
          loading: () => const _Message('Đang tải…'),
          error: (_, _) => const _Message('Không tải được danh sách sách.'),
          data: (items) {
            final shown = items.where((b) => _hit([b.title, b.author, ...b.tags])).toList();
            if (shown.isEmpty) return const _Message('Không có sách nào khớp.');
            return FrameRows(
              children: [for (final b in shown) BookRow(book: b, selected: b.id == current, onTap: () => _select(b.id))],
            );
          },
        );
      case 2:
        final docs = ref.watch(documentsProvider(_docType));
        final current = selectedId ?? (_compact(context) ? null : ref.watch(documentsProvider(null)).value?.firstOrNull?.id);
        return docs.when(
          loading: () => const _Message('Đang tải…'),
          error: (_, _) => const _Message('Không tải được danh sách tài liệu.'),
          data: (items) {
            final shown = items.where((d) => _hit([d.title, d.content, d.topic?.name, ...d.tags])).toList();
            if (shown.isEmpty) return const _Message('Không có tài liệu nào khớp.');
            return FrameRows(
              children: [for (final d in shown) DocumentCard(doc: d, selected: d.id == current, onTap: () => _select(d.id))],
            );
          },
        );
      case 3:
        final year = DateTime.now().year;
        final goal = ref.watch(readingGoalProvider(year));
        final g = goal.value;
        return FrameRows(
          children: [
            FrameRow(
              key: ValueKey('goal-year-$year'),
              glyph: '標',
              title: 'Năm $year',
              borderColor: _compact(context) ? null : DesignColors.gold,
              subtitle: g == null
                  ? (goal.hasError ? 'Không tải được tiến độ.' : 'Đang tải…')
                  : (g.targetBooks == null ? '${g.booksRead} sách · chưa đặt mục tiêu' : '${g.booksRead} / ${g.targetBooks} sách'),
              onTap: () => _select('$year'),
            ),
          ],
        );
      default:
        final current = selectedId ?? (_compact(context) ? null : ref.watch(logListProvider).value?.items.firstOrNull?.id);
        return TrainingLogList(query: _query, selectedId: current, onSelect: (l) => _select(l.id));
    }
  }

  // ───────────────────────── Nội dung ─────────────────────────

  Widget _content(BuildContext frameContext, bool expanded) {
    void deleted() => _afterDelete(frameContext, expanded);
    final id = widget.id;
    switch (_tang) {
      case 1:
        final all = ref.watch(publicationsProvider(null));
        final items = all.value;
        if (items == null) return _Message(all.hasError ? 'Không tải được sách.' : 'Đang tải…');
        final b = id == null ? items.firstOrNull : items.where((x) => x.id == id).firstOrNull;
        if (b == null) return _Message(id == null ? 'Chưa có sách nào — bấm "+ Thêm".' : 'Không tìm thấy cuốn sách này.');
        return BookView(key: ValueKey('book-content-${b.id}'), book: b, onDeleted: deleted);
      case 2:
        final all = ref.watch(documentsProvider(null));
        final items = all.value;
        if (items == null) return _Message(all.hasError ? 'Không tải được tài liệu.' : 'Đang tải…');
        final d = id == null ? items.firstOrNull : items.where((x) => x.id == id).firstOrNull;
        if (d == null) return _Message(id == null ? 'Chưa có tài liệu nào — bấm "+ Thêm".' : 'Không tìm thấy tài liệu này.');
        // Key theo id + updatedAt: tài liệu đổi (ghim, sửa ghi chú khóa ở nơi khác) thì dựng lại state từ dữ liệu mới.
        return DocumentViewerModal(key: ValueKey('doc-view-${d.id}-${d.updatedAt}'), doc: d, embedded: true, onDeleted: deleted);
      case 3:
        return ReadingGoalView(year: int.tryParse(id ?? '') ?? DateTime.now().year);
      default:
        final logId = id ?? ref.watch(logListProvider).value?.items.firstOrNull?.id;
        if (logId == null) {
          final list = ref.watch(logListProvider);
          return _Message(list.isLoading ? 'Đang tải…' : 'Chưa có dòng nhật ký nào.');
        }
        return TrainingLogDetailView(key: ValueKey('log-view-$logId'), logId: logId);
    }
  }
}

class _Message extends StatelessWidget {
  const _Message(this.text);

  final String text;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 24),
    child: Text(text, textAlign: TextAlign.center, style: DesignText.muted),
  );
}

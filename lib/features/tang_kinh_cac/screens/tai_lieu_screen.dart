import 'package:dio/dio.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/theme/design_tokens.dart';
import '../../../shared/widgets/design_page.dart';
import '../../../shared/widgets/list_frame.dart';
import '../../../shared/widgets/overview_block.dart';
import '../models/document.dart';
import '../providers/document_provider.dart';
import '../widgets/add_document_modal.dart';
import '../widgets/document_card.dart';
import '../widgets/document_viewer_modal.dart';
import '../widgets/type_tag.dart';

// Thứ tự giống bộ lọc bên web (null = Tất cả).
const _filters = <DocumentType?>[
  null,
  DocumentType.text,
  DocumentType.checklist,
  DocumentType.mindmap,
  DocumentType.image,
  DocumentType.file,
];

/// /tang-kinh-cac/tai-lieu (Tầng 2): Tổng quan (tổng số · theo loại · đã ghim) → khung có chip loại + "+ Lưu tài liệu" →
/// các tài liệu ([DocumentCard]); bấm mở trình xem như trước.
class TaiLieuScreen extends ConsumerStatefulWidget {
  const TaiLieuScreen({super.key});

  @override
  ConsumerState<TaiLieuScreen> createState() => _TaiLieuScreenState();
}

class _TaiLieuScreenState extends ConsumerState<TaiLieuScreen> {
  DocumentType? _filter;

  @override
  Widget build(BuildContext context) {
    final all = ref.watch(documentsProvider(null));
    final docs = ref.watch(documentsProvider(_filter));

    return DesignPage(
      title: 'Tài liệu',
      backFallback: '/tang-kinh-cac',
      onRefresh: () async {
        ref.invalidate(documentsProvider);
        await ref.read(documentsProvider(_filter).future).then<void>((_) {}, onError: (_) {});
      },
      overview: OverviewBlock(
        title: 'Tổng quan',
        labelWidth: 90,
        rows: [
          OverviewRow.muted(label: 'Đã lưu', text: _total(all)),
          OverviewRow.muted(label: 'Theo loại', text: _byType(all)),
        ],
      ),
      content: (context, _) => ListFrame(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          spacing: 8,
          children: [
            FrameToolbar(
              chips: DesignChipRow<DocumentType?>(
                items: [for (final f in _filters) (f, f?.label ?? 'Tất cả')],
                selected: _filter,
                onSelected: (f) => setState(() => _filter = f),
              ),
              action: DesignButton.outline(
                key: const ValueKey('add-document'),
                label: '+ Lưu tài liệu',
                onPressed: () => showAddDocumentModal(context),
              ),
            ),
            docs.when(
              loading: () => const _Message('Đang tải…'),
              error: (e, _) => _Message(
                e is DioException
                    ? 'Không tải được tài liệu (${e.response?.statusCode ?? e.type.name}).'
                    : 'Không tải được tài liệu.',
              ),
              data: (items) => items.isEmpty
                  ? const _Message('Chưa có tài liệu nào trong mục này.')
                  : FrameRows(
                      children: [
                        for (final d in items) DocumentCard(doc: d, onTap: () => showDocumentViewerModal(context, d)),
                      ],
                    ),
            ),
          ],
        ),
      ),
      hint: 'Chạm vào một tài liệu để xem',
    );
  }
}

String _total(AsyncValue<List<Document>> all) {
  final docs = all.value;
  if (docs == null) return all.hasError ? 'Không tải được số liệu' : 'Đang tải...';
  final pinned = docs.where((d) => d.pinned).length;
  return '${docs.length} tài liệu${pinned > 0 ? ' · $pinned đã ghim' : ''}';
}

String _byType(AsyncValue<List<Document>> all) {
  final docs = all.value;
  if (docs == null) return all.hasError ? 'Không tải được số liệu' : 'Đang tải...';
  final parts = [
    for (final t in _filters.nonNulls)
      if (docs.where((d) => d.type == t).length case final n when n > 0) '$n ${t.label.toLowerCase()}',
  ];
  return parts.isEmpty ? 'Chưa có tài liệu nào' : parts.join(' · ');
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

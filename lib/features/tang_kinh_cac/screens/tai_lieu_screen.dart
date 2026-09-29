import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/theme/app_theme.dart';
import '../models/document.dart';
import '../providers/document_provider.dart';
import '../widgets/document_card.dart';
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

/// Port /tang-kinh-cac/tai-lieu. 1 cột như /sach: ở bề ngang điện thoại, lưới
/// 2 cột làm tiêu đề (1 dòng) và xem trước (2 dòng) bị cắt quá ngắn; màn rộng
/// thì giới hạn bề ngang.
class TaiLieuScreen extends ConsumerStatefulWidget {
  const TaiLieuScreen({super.key});

  @override
  ConsumerState<TaiLieuScreen> createState() => _TaiLieuScreenState();
}

class _TaiLieuScreenState extends ConsumerState<TaiLieuScreen> {
  DocumentType? _filter;

  @override
  Widget build(BuildContext context) {
    final docs = ref.watch(documentsProvider(_filter));

    return Scaffold(
      appBar: AppBar(title: const Text('Tài liệu')),
      floatingActionButton: FloatingActionButton.extended(
        // TODO: mở AddDocumentModal (bước 2).
        onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('TODO: AddDocumentModal')),
        ),
        icon: const Icon(Icons.add),
        label: const Text('Lưu tài liệu'),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 640),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
                child: Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    for (final f in _filters)
                      ChoiceChip(
                        label: Text(f?.label ?? 'Tất cả'),
                        selected: _filter == f,
                        showCheckmark: false,
                        selectedColor: AppColors.kincha400,
                        labelStyle: TextStyle(color: _filter == f ? AppColors.ink950 : null),
                        onSelected: (_) => setState(() => _filter = f),
                      ),
                  ],
                ),
              ),
              Expanded(
                child: RefreshIndicator(
                  onRefresh: () => ref.refresh(documentsProvider(_filter).future),
                  child: docs.when(
                    loading: () => const Center(child: CircularProgressIndicator()),
                    error: (e, _) => _Message(
                      e is DioException
                          ? 'Không tải được tài liệu (${e.response?.statusCode ?? e.type.name}).'
                          : 'Không tải được tài liệu.',
                    ),
                    data: (items) => items.isEmpty
                        ? const _Message('Chưa có tài liệu nào trong mục này.')
                        : ListView.separated(
                            padding: const EdgeInsets.fromLTRB(16, 4, 16, 96), // chừa chỗ cho FAB
                            itemCount: items.length,
                            separatorBuilder: (_, _) => const SizedBox(height: 16), // gap-4
                            // TODO: onTap mở DocumentViewerModal (bước 2).
                            itemBuilder: (_, i) => DocumentCard(doc: items[i]),
                          ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Trạng thái rỗng/lỗi — vẫn cuộn được để kéo xuống làm mới.
class _Message extends StatelessWidget {
  const _Message(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 64), // py-16
          child: Text(
            text,
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white.withValues(alpha: 0.3)),
          ),
        ),
      ],
    );
  }
}

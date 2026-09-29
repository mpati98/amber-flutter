import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/theme/app_theme.dart';
import '../models/publication.dart';
import '../providers/publication_provider.dart';
import '../widgets/add_book_modal.dart';
import '../widgets/book_card.dart';
import '../widgets/book_detail_modal.dart';
import '../widgets/status_badge.dart';

// Thứ tự giống bộ lọc bên web (null = Tất cả).
const _filters = <PublicationStatus?>[
  null,
  PublicationStatus.reading,
  PublicationStatus.toRead,
  PublicationStatus.read,
  PublicationStatus.abandoned,
];

/// Port /tang-kinh-cac/sach. Card ngang nên xếp 1 cột thay cho lưới 1-3 cột
/// bên web; màn rộng thì giới hạn bề ngang để card không bị kéo dài.
class SachScreen extends ConsumerStatefulWidget {
  const SachScreen({super.key});

  @override
  ConsumerState<SachScreen> createState() => _SachScreenState();
}

class _SachScreenState extends ConsumerState<SachScreen> {
  PublicationStatus? _filter;

  @override
  Widget build(BuildContext context) {
    final books = ref.watch(publicationsProvider(_filter));

    return Scaffold(
      appBar: AppBar(title: const Text('Tủ sách')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => showAddBookModal(context),
        icon: const Icon(Icons.add),
        label: const Text('Thêm sách'),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 640),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Wrap thay vì cuộn ngang: ở bề ngang điện thoại chip cuối bị khuất.
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
                  onRefresh: () => ref.refresh(publicationsProvider(_filter).future),
                  child: books.when(
                    loading: () => const Center(child: CircularProgressIndicator()),
                    error: (e, _) => _Message(
                      e is DioException
                          ? 'Không tải được danh sách sách (${e.response?.statusCode ?? e.type.name}).'
                          : 'Không tải được danh sách sách.',
                    ),
                    data: (items) => items.isEmpty
                        ? const _Message('Chưa có sách nào trong mục này.')
                        : ListView.separated(
                            padding: const EdgeInsets.fromLTRB(16, 4, 16, 96), // chừa chỗ cho FAB
                            itemCount: items.length,
                            separatorBuilder: (_, _) => const SizedBox(height: 16), // gap-4
                            itemBuilder: (_, i) => BookCard(
                              book: items[i],
                              onTap: () => showBookDetailModal(context, items[i]),
                            ),
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

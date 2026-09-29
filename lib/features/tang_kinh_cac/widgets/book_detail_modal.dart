import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/theme/app_theme.dart';
import '../../../shared/widgets/rating_stars.dart';
import '../models/highlight.dart';
import '../models/publication.dart';
import '../providers/publication_provider.dart';
import '../services/highlight_api.dart';
import '../services/publication_api.dart';
import 'status_badge.dart';

/// Port BookDetailModal (web) — bottom sheet cao gần hết màn vì có cả form
/// lẫn danh sách highlight.
Future<void> showBookDetailModal(BuildContext context, Publication book) => showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      constraints: const BoxConstraints(maxWidth: 560),
      builder: (_) => BookDetailModal(book: book),
    );

class BookDetailModal extends ConsumerStatefulWidget {
  const BookDetailModal({super.key, required this.book});

  final Publication book;

  @override
  ConsumerState<BookDetailModal> createState() => _BookDetailModalState();
}

class _BookDetailModalState extends ConsumerState<BookDetailModal> {
  late var _status = widget.book.status;
  late var _format = widget.book.format;
  late int? _rating = widget.book.rating;
  late final _currentPage = TextEditingController(text: widget.book.currentPage?.toString() ?? '');
  late final _totalPages = TextEditingController(text: widget.book.totalPages?.toString() ?? '');
  late final _review = TextEditingController(text: widget.book.review ?? '');
  late final _notes = TextEditingController(text: widget.book.notes ?? '');
  bool _busy = false;
  String? _error;

  // null = đang tải.
  List<Highlight>? _highlights;
  String? _highlightError;
  final _newQuote = TextEditingController();
  final _newPage = TextEditingController();
  bool _addingHighlight = false;

  @override
  void initState() {
    super.initState();
    _newQuote.addListener(() => setState(() {}));
    _loadHighlights();
  }

  @override
  void dispose() {
    for (final c in [_currentPage, _totalPages, _review, _notes, _newQuote, _newPage]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _loadHighlights() async {
    try {
      final items = await ref.read(highlightApiProvider).getHighlights(widget.book.id);
      if (mounted) setState(() => _highlights = items);
    } on DioException {
      if (mounted) setState(() => _highlightError = 'Không tải được highlight.');
    }
  }

  Future<void> _save() async {
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await ref.read(publicationApiProvider).updatePublication(
            widget.book.id,
            status: _status,
            format: _format,
            currentPage: int.tryParse(_currentPage.text),
            totalPages: int.tryParse(_totalPages.text),
            rating: _rating,
            review: _review.text,
            notes: _notes.text,
          );
      ref.invalidate(publicationsProvider);
      if (mounted) Navigator.of(context).pop();
    } on DioException {
      if (mounted) {
        setState(() {
          _busy = false;
          _error = 'Không lưu được, thử lại nhé.';
        });
      }
    }
  }

  Future<void> _delete() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        content: const Text('Xóa sách này khỏi Tàng Kinh Các?'),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(false), child: const Text('Huỷ')),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: AppColors.shuiro500),
            child: const Text('Xóa'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;

    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await ref.read(publicationApiProvider).deletePublication(widget.book.id);
      ref.invalidate(publicationsProvider);
      if (mounted) Navigator.of(context).pop();
    } on DioException {
      if (mounted) {
        setState(() {
          _busy = false;
          _error = 'Không xóa được, thử lại nhé.';
        });
      }
    }
  }

  /// Giống web: chèn lên đầu danh sách ngay, không tải lại.
  Future<void> _addHighlight() async {
    setState(() => _addingHighlight = true);
    try {
      final created = await ref.read(highlightApiProvider).createHighlight(
            widget.book.id,
            quote: _newQuote.text.trim(),
            page: int.tryParse(_newPage.text),
          );
      if (!mounted) return;
      setState(() {
        _highlights = [created, ...?_highlights];
        _newQuote.clear();
        _newPage.clear();
      });
    } on DioException {
      if (mounted) setState(() => _highlightError = 'Không thêm được highlight.');
    } finally {
      if (mounted) setState(() => _addingHighlight = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final muted = Colors.white.withValues(alpha: 0.4);

    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          spacing: 16, // space-y-4
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    widget.book.title,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontSize: 20),
                  ),
                ),
                IconButton(
                  tooltip: 'Đóng',
                  icon: Icon(Icons.close, color: muted),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
            Row(
              spacing: 12,
              children: [
                Expanded(
                  child: DropdownButtonFormField<PublicationStatus>(
                    initialValue: _status,
                    items: [
                      for (final s in PublicationStatus.values.where((s) => s != PublicationStatus.unknown))
                        DropdownMenuItem(value: s, child: Text(s.label)),
                    ],
                    onChanged: (v) => setState(() => _status = v!),
                  ),
                ),
                Expanded(
                  child: DropdownButtonFormField<PublicationFormat>(
                    initialValue: _format,
                    items: [
                      for (final f in PublicationFormat.values.where((f) => f != PublicationFormat.unknown))
                        DropdownMenuItem(value: f, child: Text(f.label)),
                    ],
                    onChanged: (v) => setState(() => _format = v!),
                  ),
                ),
              ],
            ),
            if (_status == PublicationStatus.reading)
              Row(
                spacing: 12,
                children: [
                  Expanded(child: _NumberField(controller: _currentPage, hint: 'Trang hiện tại')),
                  Expanded(child: _NumberField(controller: _totalPages, hint: 'Tổng số trang')),
                ],
              ),
            if (_status == PublicationStatus.read)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: 4,
                children: [
                  Text('Đánh giá', style: TextStyle(fontSize: 12, color: muted)),
                  RatingStars(rating: _rating, size: 20, onChanged: (r) => setState(() => _rating = r)),
                ],
              ),
            TextField(
              controller: _review,
              minLines: 3,
              maxLines: 8,
              decoration: const InputDecoration(hintText: 'Review dài...'),
            ),
            TextField(
              controller: _notes,
              minLines: 2,
              maxLines: 6,
              decoration: const InputDecoration(hintText: 'Ghi chú nhanh...'),
            ),
            if (_error != null) Text(_error!, style: TextStyle(color: Theme.of(context).colorScheme.error)),
            Row(
              spacing: 8,
              children: [
                Expanded(child: FilledButton(onPressed: _busy ? null : _save, child: const Text('Lưu'))),
                OutlinedButton(
                  onPressed: _busy ? null : _delete,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.shuiro500,
                    side: BorderSide(color: AppColors.shuiro500.withValues(alpha: 0.4)),
                  ),
                  child: const Text('Xóa'),
                ),
              ],
            ),
            Divider(color: Colors.white.withValues(alpha: 0.1), height: 1),
            _buildHighlights(),
          ],
        ),
      ),
    );
  }

  Widget _buildHighlights() {
    final highlights = _highlights;
    final canAdd = !_addingHighlight && _newQuote.text.trim().isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: 8,
      children: [
        Text(
          'HIGHLIGHT',
          style: TextStyle(
            fontSize: 12,
            letterSpacing: 12 * 0.05, // tracking-wider
            color: AppColors.yugen300.withValues(alpha: 0.8),
          ),
        ),
        if (_highlightError != null)
          Text(_highlightError!, style: TextStyle(fontSize: 14, color: Theme.of(context).colorScheme.error)),
        if (highlights == null && _highlightError == null)
          Text('Đang tải...', style: TextStyle(fontSize: 14, color: Colors.white.withValues(alpha: 0.3)))
        else if (highlights != null && highlights.isEmpty)
          Text('Chưa có highlight nào.', style: TextStyle(fontSize: 14, color: Colors.white.withValues(alpha: 0.3)))
        else if (highlights != null)
          for (final h in highlights) _HighlightItem(h),
        const SizedBox(height: 4),
        Row(
          spacing: 8,
          children: [
            Expanded(
              child: TextField(
                controller: _newQuote,
                decoration: const InputDecoration(hintText: 'Trích dẫn mới...'),
                onSubmitted: (_) => canAdd ? _addHighlight() : null,
              ),
            ),
            SizedBox(width: 80, child: _NumberField(controller: _newPage, hint: 'Trang')), // w-20
            OutlinedButton(
              onPressed: canAdd ? _addHighlight : null,
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.yugen300,
                side: BorderSide(color: AppColors.yugen500.withValues(alpha: 0.4)),
              ),
              child: const Text('Thêm'),
            ),
          ],
        ),
      ],
    );
  }
}

class _HighlightItem extends StatelessWidget {
  const _HighlightItem(this.highlight);

  final Highlight highlight;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(left: 12), // pl-3
      decoration: BoxDecoration(
        border: Border(left: BorderSide(color: AppColors.yugen500.withValues(alpha: 0.4), width: 2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '"${highlight.quote}"',
            style: TextStyle(fontSize: 14, fontStyle: FontStyle.italic, color: Colors.white.withValues(alpha: 0.8)),
          ),
          if (highlight.page != null)
            Text('trang ${highlight.page}', style: TextStyle(fontSize: 12, color: Colors.white.withValues(alpha: 0.4))),
        ],
      ),
    );
  }
}

class _NumberField extends StatelessWidget {
  const _NumberField({required this.controller, required this.hint});

  final TextEditingController controller;
  final String hint;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: TextInputType.number,
      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
      decoration: InputDecoration(hintText: hint),
    );
  }
}

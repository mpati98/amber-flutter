import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../../../shared/theme/app_theme.dart';
import '../../../shared/widgets/form_bits.dart';
import '../models/publication.dart';
import '../providers/publication_provider.dart';
import '../services/publication_api.dart';
import '../services/upload_api.dart';
import 'status_badge.dart';

/// Port AddBookModal (web), form toàn màn hình chung ([showFinanceSheet]).
Future<void> showAddBookModal(BuildContext context) => showFinanceSheet<void>(context, const AddBookModal());

class AddBookModal extends ConsumerStatefulWidget {
  const AddBookModal({super.key});

  @override
  ConsumerState<AddBookModal> createState() => _AddBookModalState();
}

class _AddBookModalState extends ConsumerState<AddBookModal> {
  final _title = TextEditingController();
  final _author = TextEditingController();
  final _totalPages = TextEditingController();
  var _format = PublicationFormat.physical;
  var _status = PublicationStatus.toRead;

  Uint8List? _coverPreview;
  String? _coverUrl;
  bool _uploading = false;
  bool _submitting = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _title.addListener(() => setState(() {})); // bật/tắt nút theo tên sách
  }

  @override
  void dispose() {
    _title.dispose();
    _author.dispose();
    _totalPages.dispose();
    super.dispose();
  }

  /// Giống web: chọn xong là upload ngay, nút Thêm bị khoá trong lúc tải lên.
  Future<void> _pickCover() async {
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery, maxWidth: 1200, imageQuality: 85);
    if (picked == null) return;
    final bytes = await picked.readAsBytes();
    setState(() {
      _coverPreview = bytes;
      _coverUrl = null;
      _uploading = true;
      _error = null;
    });
    try {
      final url =
          await ref.read(uploadApiProvider).upload(bytes: bytes, filename: picked.name, mimeType: picked.mimeType);
      if (mounted) setState(() => _coverUrl = url);
    } on DioException {
      if (mounted) {
        setState(() {
          _coverPreview = null;
          _error = 'Không tải được ảnh bìa lên, thử lại nhé.';
        });
      }
    } finally {
      if (mounted) setState(() => _uploading = false);
    }
  }

  Future<void> _submit() async {
    setState(() {
      _submitting = true;
      _error = null;
    });
    try {
      await ref.read(publicationApiProvider).createPublication(
            title: _title.text.trim(),
            author: _author.text.trim(),
            format: _format,
            status: _status,
            totalPages: int.tryParse(_totalPages.text),
            coverUrl: _coverUrl,
          );
      ref.invalidate(publicationsProvider);
      if (mounted) Navigator.of(context).pop();
    } on DioException {
      if (mounted) {
        setState(() {
          _submitting = false;
          _error = 'Không thêm được sách, thử lại nhé.';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final canSubmit = !_uploading && !_submitting && _title.text.trim().isNotEmpty;

    return FinanceSheetBody(
      title: 'Thêm sách',
      children: [
        TextField(controller: _title, decoration: const InputDecoration(hintText: 'Tên sách')),
        TextField(controller: _author, decoration: const InputDecoration(hintText: 'Tác giả')),
        Row(
          spacing: 12,
          children: [
            if (_coverPreview != null)
              ClipRRect(
                borderRadius: BorderRadius.circular(2),
                child: Image.memory(_coverPreview!, width: 44, height: 64, fit: BoxFit.cover), // w-11 h-16
              ),
            OutlinedButton.icon(
              onPressed: _uploading ? null : _pickCover,
              icon: const Icon(Icons.image_outlined, size: 18),
              label: Text(_coverPreview == null ? 'Chọn ảnh bìa' : 'Đổi ảnh bìa'),
            ),
            if (_uploading) const Text('Đang tải lên...', style: TextStyle(fontSize: 12, color: AppColors.yugen300)),
          ],
        ),
        Row(
          spacing: 12,
          children: [
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
            Expanded(
              child: DropdownButtonFormField<PublicationStatus>(
                initialValue: _status,
                // Không có "Bỏ dở" khi thêm mới — giống web.
                items: [
                  for (final s in const [PublicationStatus.toRead, PublicationStatus.reading, PublicationStatus.read])
                    DropdownMenuItem(value: s, child: Text(s.label)),
                ],
                onChanged: (v) => setState(() => _status = v!),
              ),
            ),
          ],
        ),
        TextField(
          controller: _totalPages,
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          decoration: const InputDecoration(hintText: 'Tổng số trang (tùy chọn)'),
        ),
        sheetError(context, _error),
        FilledButton(
          onPressed: canSubmit ? _submit : null,
          child: Text(_submitting ? 'Đang thêm...' : 'Thêm vào Tàng Kinh Các'),
        ),
      ],
    );
  }
}

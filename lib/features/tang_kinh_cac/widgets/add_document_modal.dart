import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';

import '../../../shared/theme/app_theme.dart';
import '../../../shared/widgets/form_bits.dart';
import '../models/document.dart';
import '../providers/document_provider.dart';
import '../services/document_api.dart';
import '../services/upload_api.dart';
import 'type_tag.dart';

// Mẫu cú pháp làm hintText cho từng loại có nội dung chữ.
const _placeholder = {
  DocumentType.text: 'Viết ghi chú của bạn...',
  DocumentType.checklist: '- [ ] Việc cần làm 1\n- [ ] Việc cần làm 2',
  DocumentType.mindmap: '# Chủ đề\n- ý 1\n  - ý con\n- ý 2',
};

/// Port AddDocumentModal (web), form toàn màn hình chung ([showFinanceSheet]).
Future<void> showAddDocumentModal(BuildContext context) => showFinanceSheet<void>(context, const AddDocumentModal());

class AddDocumentModal extends ConsumerStatefulWidget {
  const AddDocumentModal({super.key});

  @override
  ConsumerState<AddDocumentModal> createState() => _AddDocumentModalState();
}

class _AddDocumentModalState extends ConsumerState<AddDocumentModal> {
  final _title = TextEditingController();
  final _content = TextEditingController();
  var _type = DocumentType.text;

  Uint8List? _imagePreview;
  String? _fileName;
  String? _attachmentUrl;
  bool _uploading = false;
  bool _submitting = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _title.addListener(() => setState(() {}));
    _content.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _title.dispose();
    _content.dispose();
    super.dispose();
  }

  void _selectType(DocumentType type) => setState(() {
        // Đổi giữa IMAGE/FILE thì bỏ file đã tải — tránh lưu ảnh dưới dạng
        // "Tệp" (bản web giữ lại attachmentUrl khi đổi loại). Nội dung chữ thì giữ.
        if (type != _type) {
          _attachmentUrl = null;
          _imagePreview = null;
          _fileName = null;
        }
        _type = type;
      });

  /// Chọn xong là upload ngay (giống web), nút Lưu khoá trong lúc tải lên.
  Future<void> _pickAttachment() async {
    final Uint8List bytes;
    final String name;
    final String? mimeType;
    if (_type == DocumentType.image) {
      // image_picker chỉ chọn được ảnh/video.
      final picked = await ImagePicker().pickImage(source: ImageSource.gallery, maxWidth: 2000, imageQuality: 90);
      if (picked == null) return;
      bytes = await picked.readAsBytes();
      name = picked.name;
      mimeType = picked.mimeType;
    } else {
      // FILE: file bất kỳ → file_picker.
      final picked = await FilePicker.pickFiles();
      if (picked.isEmpty) return;
      bytes = await picked.first.readAsBytes();
      name = picked.first.name;
      mimeType = picked.first.xFile.mimeType;
    }

    setState(() {
      _imagePreview = _type == DocumentType.image ? bytes : null;
      _fileName = name;
      _attachmentUrl = null;
      _uploading = true;
      _error = null;
    });
    try {
      final url = await ref.read(uploadApiProvider).upload(bytes: bytes, filename: name, mimeType: mimeType);
      if (mounted) setState(() => _attachmentUrl = url);
    } on DioException {
      if (mounted) {
        setState(() {
          _imagePreview = null;
          _fileName = null;
          _error = 'Không tải được tệp lên, thử lại nhé.';
        });
      }
    } finally {
      if (mounted) setState(() => _uploading = false);
    }
  }

  bool get _canSubmit {
    if (_uploading || _submitting || _title.text.trim().isEmpty) return false;
    // Backend trả 400 nếu thiếu — chặn luôn ở UI (web không chặn, bấm Lưu im lặng thất bại).
    return _type.hasTextContent ? _content.text.trim().isNotEmpty : _attachmentUrl != null;
  }

  Future<void> _submit() async {
    setState(() {
      _submitting = true;
      _error = null;
    });
    try {
      await ref.read(documentApiProvider).createDocument(
            title: _title.text.trim(),
            type: _type,
            content: _type.hasTextContent ? _content.text : null,
            attachmentUrl: _type.hasTextContent ? null : _attachmentUrl,
          );
      ref.invalidate(documentsProvider);
      if (mounted) Navigator.of(context).pop();
    } on DioException {
      if (mounted) {
        setState(() {
          _submitting = false;
          _error = 'Không lưu được tài liệu, thử lại nhé.';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return FinanceSheetBody(
      title: 'Lưu tài liệu mới',
      children: [
        TextField(controller: _title, decoration: const InputDecoration(hintText: 'Tiêu đề')),
        // Nhãn tiếng Việt thay cho mã thô TEXT/CHECKLIST... bên web.
        Wrap(
          spacing: 6,
          runSpacing: 6,
          children: [
            for (final t in DocumentType.values.where((t) => t != DocumentType.unknown))
              ChoiceChip(
                label: Text('${t.icon} ${t.label}'),
                selected: _type == t,
                showCheckmark: false,
                selectedColor: AppColors.kincha400,
                labelStyle: TextStyle(fontSize: 13, color: _type == t ? AppColors.ink950 : null),
                onSelected: (_) => _selectType(t),
              ),
          ],
        ),
        if (_type.hasTextContent)
          TextField(
            controller: _content,
            minLines: 6,
            maxLines: 14,
            keyboardType: TextInputType.multiline,
            style: GoogleFonts.robotoMono(fontSize: 13),
            decoration: InputDecoration(
              hintText: _placeholder[_type],
              hintMaxLines: 6,
              hintStyle: GoogleFonts.robotoMono(fontSize: 13, color: Colors.white.withValues(alpha: 0.3)),
            ),
          )
        else
          _buildAttachmentPicker(),
        sheetError(context, _error),
        FilledButton(
          onPressed: _canSubmit ? _submit : null,
          child: Text(_submitting ? 'Đang lưu...' : 'Lưu vào Tàng Kinh Các'),
        ),
      ],
    );
  }

  Widget _buildAttachmentPicker() {
    final isImage = _type == DocumentType.image;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 8,
      children: [
        OutlinedButton.icon(
          onPressed: _uploading ? null : _pickAttachment,
          icon: Icon(isImage ? Icons.image_outlined : Icons.attach_file, size: 18),
          label: Text(_fileName == null ? (isImage ? 'Chọn ảnh' : 'Chọn tệp') : (isImage ? 'Đổi ảnh' : 'Đổi tệp')),
        ),
        if (_uploading) const Text('Đang tải lên...', style: TextStyle(fontSize: 12, color: AppColors.yugen300)),
        if (!_uploading && _imagePreview != null)
          ClipRRect(
            borderRadius: BorderRadius.circular(2),
            child: Image.memory(_imagePreview!, height: 96, fit: BoxFit.cover), // h-24
          ),
        if (!_uploading && !isImage && _fileName != null && _attachmentUrl != null)
          Text(
            '📎 $_fileName',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(fontSize: 12, color: Colors.white.withValues(alpha: 0.5)),
          ),
      ],
    );
  }
}

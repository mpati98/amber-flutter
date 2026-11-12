import 'package:dio/dio.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../shared/services/file_opener.dart';
import '../../../shared/theme/app_theme.dart';
import '../../../shared/widgets/api_image.dart';
import '../../tra_dinh/hoc_tap/services/hoc_tap_api.dart';
import '../models/document.dart';
import '../providers/document_provider.dart';
import '../services/document_api.dart';
import '../services/upload_api.dart';
import '../utils/document_content.dart';
import '../../../shared/utils/api_error.dart';

/// Đoạn đề mục nối vào cuối ghi chú khóa; con trỏ đặt ngay sau "— ".
const videoSummaryHeading = '\n\n## Module _ · Video _ — ';

/// Mỗi lần gọi tạo 1 route + 1 State MỚI cho đúng [doc] được bấm — không có
/// instance nào sống lâu hơn 1 lần mở (xem lỗi 1 bên dưới).
Future<void> showDocumentViewerModal(BuildContext context, Document doc) => showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      constraints: const BoxConstraints(maxWidth: 560),
      builder: (_) => DocumentViewerModal(key: ValueKey(doc.id), doc: doc),
    );

/// Port DocumentViewerModal (web), sửa 2 lỗi của bản gốc:
///
/// 1. Lẫn nội dung: web giữ 1 component luôn mount, `useState(doc?.content)`
///    chỉ khởi tạo 1 lần → sau khi tick checklist A, mở checklist B vẫn hiện
///    nội dung A. Ở đây mỗi lần mở là 1 bottom sheet mới, state khởi tạo từ
///    đúng document đó (thêm ValueKey để chắc chắn nếu có lúc bị dùng lại).
/// 2. Nhãn ghim sai: web đọc `doc.pinned` từ prop cũ nên bấm xong nhãn không
///    đổi. Ở đây [_pinned] là state cục bộ, đổi NGAY khi bấm rồi mới gọi API
///    (lỗi thì trả lại như cũ).
class DocumentViewerModal extends ConsumerStatefulWidget {
  const DocumentViewerModal({super.key, required this.doc});

  final Document doc;

  @override
  ConsumerState<DocumentViewerModal> createState() => _DocumentViewerModalState();
}

class _DocumentViewerModalState extends ConsumerState<DocumentViewerModal> {
  late String _content = widget.doc.content ?? '';
  late bool _pinned = widget.doc.pinned;
  bool _busy = false;
  bool _opening = false;
  bool _openingCourse = false;
  bool _editing = false;
  bool _saving = false;
  String? _error;
  final _editor = TextEditingController();
  final _editorFocus = FocusNode();

  Document get _doc => widget.doc;

  /// Ghi chú khóa (TEXT gắn khóa) mới có chế độ sửa và nút "Thêm tóm tắt video".
  bool get _isCourseNote => _doc.studyCourseId != null && _doc.type == DocumentType.text;

  @override
  void dispose() {
    _editor.dispose();
    _editorFocus.dispose();
    super.dispose();
  }

  /// Vào chế độ sửa; [append] nối thêm vào cuối nội dung (đề mục video), con trỏ ở cuối (hoặc sau "— ").
  void _startEditing({String append = ''}) {
    final text = _content + append;
    _editor.value = TextEditingValue(text: text, selection: TextSelection.collapsed(offset: text.length));
    setState(() {
      _editing = true;
      _error = null;
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _editorFocus.requestFocus();
    });
  }

  Future<void> _saveEdit() async {
    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      final saved = await ref.read(documentApiProvider).updateDocument(_doc.id, content: _editor.text);
      ref.invalidate(documentsProvider);
      if (mounted) {
        setState(() {
          _content = saved.content ?? '';
          _editing = false;
          _saving = false;
        });
      }
    } on DioException {
      if (mounted) {
        setState(() => _saving = false);
        _showError('Không lưu được ghi chú.'); // giữ nguyên nội dung đang sửa
      }
    }
  }

  /// Chip tên khóa: kiểm khóa còn truy cập được (404 = đang trong Thùng rác hoặc đã xoá hẳn) rồi mở chi tiết khóa.
  Future<void> _openCourse() async {
    final id = _doc.studyCourseId!;
    final router = GoRouter.of(context);
    setState(() {
      _openingCourse = true;
      _error = null;
    });
    try {
      await ref.read(hocTapApiProvider).getCourseDetail(id);
    } catch (e) {
      if (apiErrorCode(e) == 'course_not_found') {
        if (mounted) {
          setState(() => _openingCourse = false);
          _showError('Khóa này đã được xoá');
        }
        return;
      }
      // Lỗi khác (mạng...): vẫn mở, màn chi tiết khóa tự báo lỗi và có nút thử lại.
    }
    if (!mounted) return;
    Navigator.of(context).pop();
    router.push('/tra-dinh/hoc-tap/courses/$id');
  }

  void _showError(String message) => setState(() => _error = message);

  Future<void> _togglePin() async {
    final next = !_pinned;
    setState(() {
      _pinned = next; // đổi nhãn ngay, không chờ API
      _error = null;
    });
    try {
      await ref.read(documentApiProvider).togglePin(_doc.id, next);
      ref.invalidate(documentsProvider); // card ngoài danh sách đổi viền/📌
    } on DioException {
      if (mounted) {
        setState(() => _pinned = !next);
        _showError('Không cập nhật được trạng thái ghim.');
      }
    }
  }

  Future<void> _toggleChecklist(int lineIndex) async {
    final before = _content;
    final after = toggleChecklistLine(before, lineIndex);
    setState(() {
      _content = after; // tick ngay, không chờ API
      _error = null;
    });
    try {
      await ref.read(documentApiProvider).updateDocument(_doc.id, content: after);
      ref.invalidate(documentsProvider);
    } on DioException {
      if (mounted) {
        setState(() => _content = before);
        _showError('Không lưu được checklist.');
      }
    }
  }

  Future<void> _delete() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        content: const Text('Xóa tài liệu này?'),
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

    setState(() => _busy = true);
    try {
      await ref.read(documentApiProvider).deleteDocument(_doc.id);
      ref.invalidate(documentsProvider);
      if (mounted) Navigator.of(context).pop();
    } on DioException {
      if (mounted) {
        setState(() => _busy = false);
        _showError('Không xóa được tài liệu.');
      }
    }
  }

  /// Route blob cần Bearer → url_launcher không mở thẳng được. Tải qua Dio
  /// (interceptor gắn/refresh token) rồi mở bằng trình xem của hệ thống.
  Future<void> _openFile() async {
    final url = _doc.attachmentUrl!;
    setState(() {
      _opening = true;
      _error = null;
    });
    try {
      final file = await ref.read(documentApiProvider).downloadAttachment(url);
      await openBytes(file.bytes, filename: uploadedFileName(url), mimeType: file.mimeType);
    } catch (_) {
      if (mounted) _showError('Không mở được tệp.');
    } finally {
      if (mounted) setState(() => _opening = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: 16, // space-y-4
        children: [
          if (_doc.studyCourseId != null) _CourseHeader(title: _doc.studyCourseTitle, busy: _openingCourse, onTap: _openCourse),
          Row(
            children: [
              Expanded(
                child: Text(_doc.title, style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontSize: 20)),
              ),
              IconButton(
                tooltip: 'Đóng',
                icon: Icon(Icons.close, color: Colors.white.withValues(alpha: 0.4)),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          ),
          _buildBody(),
          if (_isCourseNote) _noteActions(),
          if (_error != null) Text(_error!, style: TextStyle(color: Theme.of(context).colorScheme.error)),
          Divider(color: Colors.white.withValues(alpha: 0.1), height: 1),
          Row(
            children: [
              TextButton(
                onPressed: _togglePin,
                style: TextButton.styleFrom(foregroundColor: AppColors.yugen300, padding: EdgeInsets.zero),
                child: Text(
                  _pinned ? 'Bỏ ghim' : 'Ghim tài liệu',
                  style: const TextStyle(decoration: TextDecoration.underline, decorationColor: AppColors.yugen300),
                ),
              ),
              const Spacer(),
              TextButton(
                onPressed: _busy ? null : _delete,
                style: TextButton.styleFrom(foregroundColor: AppColors.shuiro500),
                child: const Text('Xóa'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _noteActions() {
    if (_editing) {
      return Row(
        spacing: 12,
        children: [
          Expanded(
            child: OutlinedButton(key: const ValueKey('note-cancel'), style: OutlinedButton.styleFrom(minimumSize: const Size(0, 48)), onPressed: _saving ? null : () => setState(() => _editing = false), child: const Text('Huỷ')),
          ),
          Expanded(
            child: FilledButton(
              key: const ValueKey('note-save'),
              style: FilledButton.styleFrom(minimumSize: const Size(0, 48)),
              onPressed: _saving ? null : _saveEdit,
              child: _saving ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)) : const Text('Lưu'),
            ),
          ),
        ],
      );
    }
    // Nút vàng duy nhất là "Sửa"; "Thêm tóm tắt video" là nút viền.
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: 8,
      children: [
        FilledButton(key: const ValueKey('note-edit'), style: FilledButton.styleFrom(minimumSize: const Size(0, 48)), onPressed: () => _startEditing(), child: const Text('Sửa')),
        OutlinedButton(
          key: const ValueKey('add-video-summary'),
          style: OutlinedButton.styleFrom(minimumSize: const Size(0, 48)),
          onPressed: () => _startEditing(append: videoSummaryHeading),
          child: const Text('Thêm tóm tắt video'),
        ),
      ],
    );
  }

  Widget _buildBody() {
    final attachmentUrl = _doc.attachmentUrl;
    if (_editing) {
      return TextField(
        key: const ValueKey('note-editor'),
        controller: _editor,
        focusNode: _editorFocus,
        enabled: !_saving,
        minLines: 8,
        maxLines: null,
        keyboardType: TextInputType.multiline,
        style: const TextStyle(fontSize: 14, height: 1.6),
        decoration: const InputDecoration(border: OutlineInputBorder()),
      );
    }
    return switch (_doc.type) {
      // Nguyên văn, giữ xuống dòng — không dùng preview đã lọc của card.
      DocumentType.text => SelectableText(
          _content,
          style: TextStyle(fontSize: 14, height: 1.6, color: Colors.white.withValues(alpha: 0.85)),
        ),
      DocumentType.checklist => _ChecklistView(content: _content, onToggle: _toggleChecklist),
      DocumentType.mindmap => _OutlineTree(nodes: parseOutline(_content)),
      DocumentType.image when attachmentUrl != null => ClipRRect(
          borderRadius: BorderRadius.circular(2),
          child: ApiImage(
            attachmentUrl,
            fit: BoxFit.fitWidth,
            placeholder: const SizedBox(height: 160, child: Center(child: CircularProgressIndicator())),
          ),
        ),
      DocumentType.file when attachmentUrl != null => Align(
          alignment: Alignment.centerLeft,
          child: OutlinedButton(
            onPressed: _opening ? null : _openFile,
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.kincha200,
              side: BorderSide(color: AppColors.kincha400.withValues(alpha: 0.4)),
            ),
            child: Text(_opening ? 'Đang tải tệp...' : '📎 Mở tệp'),
          ),
        ),
      _ => Text('Không có nội dung để hiển thị.', style: TextStyle(color: Colors.white.withValues(alpha: 0.4))),
    };
  }
}

class _ChecklistView extends StatelessWidget {
  const _ChecklistView({required this.content, required this.onToggle});

  final String content;
  final ValueChanged<int> onToggle;

  @override
  Widget build(BuildContext context) {
    final items = parseChecklist(content);
    if (items.isEmpty) {
      return Text('Chưa có mục nào.', style: TextStyle(color: Colors.white.withValues(alpha: 0.4)));
    }
    return Column(
      children: [
        for (final item in items)
          CheckboxListTile(
            value: item.checked,
            onChanged: (_) => onToggle(item.lineIndex),
            controlAffinity: ListTileControlAffinity.leading,
            contentPadding: EdgeInsets.zero,
            dense: true,
            visualDensity: VisualDensity.compact,
            activeColor: AppColors.kincha400,
            checkColor: AppColors.ink950,
            title: Text(
              item.label,
              style: TextStyle(
                fontSize: 14,
                color: Colors.white.withValues(alpha: item.checked ? 0.4 : 0.9),
                decoration: item.checked ? TextDecoration.lineThrough : null,
                decorationColor: Colors.white.withValues(alpha: 0.4),
              ),
            ),
          ),
      ],
    );
  }
}

/// Port OutlineTree (MindmapOutline.tsx): cấp 0 "◆" kincha chữ lớn, cấp 1 "·"
/// yugen, sâu hơn "·" trắng 70%; mỗi cấp con thụt vào với viền trái mờ.
class _OutlineTree extends StatelessWidget {
  const _OutlineTree({required this.nodes, this.depth = 0});

  final List<OutlineNode> nodes;
  final int depth;

  static final _colors = [AppColors.kincha400, AppColors.yugen300, Colors.white.withValues(alpha: 0.7)];

  @override
  Widget build(BuildContext context) {
    if (nodes.isEmpty && depth == 0) {
      return Text('Chưa có nội dung.', style: TextStyle(color: Colors.white.withValues(alpha: 0.4)));
    }
    final serif = Theme.of(context).textTheme.headlineSmall;
    final list = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final node in nodes)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 6), // my-1.5
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${depth == 0 ? '◆' : '·'} ${node.label}',
                  style: serif?.copyWith(
                    fontSize: depth == 0 ? 18 : 14, // text-lg / text-sm
                    color: _colors[depth.clamp(0, 2)],
                  ),
                ),
                if (node.children.isNotEmpty) _OutlineTree(nodes: node.children, depth: depth + 1),
              ],
            ),
          ),
      ],
    );
    if (depth == 0) return list;
    // ml-4 border-l border-white/10 pl-4
    return Container(
      margin: const EdgeInsets.only(left: 16),
      padding: const EdgeInsets.only(left: 16),
      decoration: BoxDecoration(border: Border(left: BorderSide(color: Colors.white.withValues(alpha: 0.1)))),
      child: list,
    );
  }
}

/// Đầu màn ghi chú khóa: nhãn nhỏ "GHI CHÚ KHÓA" + chip viền mảnh "tên khóa ›" mở chi tiết khóa trong Học tập.
class _CourseHeader extends StatelessWidget {
  const _CourseHeader({required this.title, required this.busy, required this.onTap});

  final String? title;
  final bool busy;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 6,
      children: [
        Text('GHI CHÚ KHÓA', key: const ValueKey('course-label'), style: TextStyle(fontSize: 11, letterSpacing: 1.2, fontWeight: FontWeight.w500, color: theme.textMuted)),
        InkWell(
          key: const ValueKey('course-chip'),
          borderRadius: BorderRadius.circular(999),
          onTap: busy ? null : onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(border: Border.all(color: theme.colorScheme.onSurface.withValues(alpha: 0.25)), borderRadius: BorderRadius.circular(999)),
            child: Text('${title ?? 'Khóa học'} ›', style: const TextStyle(fontSize: 13)),
          ),
        ),
      ],
    );
  }
}

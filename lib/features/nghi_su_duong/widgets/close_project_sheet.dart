import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/utils/api_error.dart';
import '../../../shared/widgets/form_bits.dart';
import '../models/project_detail.dart';
import '../models/task.dart';
import '../providers/nghi_su_duong_provider.dart';
import '../services/nghi_su_duong_api.dart';

/// Form "Đóng dự án": ghi chú tổng kết tuỳ chọn; đóng xong server lưu tài liệu tổng kết vào Tàng Kinh Các.
Future<void> showCloseProjectSheet(BuildContext context, ProjectDetail project) =>
    showFinanceSheet<void>(context, CloseProjectSheet(project: project));

const maxNoteLength = 5000;
const closedMessage = 'Đã lưu tổng kết vào Tàng Kinh Các.';
const alreadyClosedMessage = 'Dự án đã được đóng trước đó.';

class CloseProjectSheet extends ConsumerStatefulWidget {
  const CloseProjectSheet({super.key, required this.project});

  final ProjectDetail project;

  @override
  ConsumerState<CloseProjectSheet> createState() => _CloseProjectSheetState();
}

class _CloseProjectSheetState extends ConsumerState<CloseProjectSheet> {
  final _note = TextEditingController();
  bool _busy = false;
  String? _error;

  @override
  void dispose() {
    _note.dispose();
    super.dispose();
  }

  Future<void> _close() async {
    if (_busy) return;
    setState(() {
      _busy = true; // khoá ngay: bấm hai lần chỉ gửi một lần
      _error = null;
    });
    final messenger = ScaffoldMessenger.of(context);
    try {
      final note = _note.text.trim();
      await ref.read(nghiSuDuongApiProvider).closeProject(widget.project.id, note: note.isEmpty ? null : note);
      refreshAfterLifecycle(ref.invalidate, widget.project.id);
      if (!mounted) return;
      Navigator.of(context).pop();
      // App chưa có màn chi tiết tài liệu theo id (tài liệu mở bằng hộp thoại trong tab Tài liệu) nên chỉ báo.
      messenger.showSnackBar(const SnackBar(content: Text(closedMessage)));
    } catch (e) {
      if (!mounted) return;
      final already = apiErrorCode(e) == 'project_already_done';
      if (already) refreshAfterLifecycle(ref.invalidate, widget.project.id);
      setState(() {
        _busy = false;
        _error = already ? alreadyClosedMessage : apiErrorMessage(e, 'Không đóng được dự án, thử lại nhé.');
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final muted = TextStyle(fontSize: 12, color: cs.onSurface.withValues(alpha: 0.7));
    final tasks = ref.watch(projectTasksProvider(widget.project.id)).value;
    final notDone = tasks?.where((t) => t.status != TaskStatus.done).length ?? 0;

    return FinanceSheetBody(
      title: 'Đóng dự án',
      children: [
        Text(
          'Dự án sẽ chuyển sang Đã xong. Một tài liệu tổng kết (KR, việc đã xong, thu-chi và ghi chú dưới đây) '
          'sẽ được lưu vào Tàng Kinh Các.',
          style: muted,
        ),
        if (notDone > 0)
          Text('Còn $notDone việc chưa xong.', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: cs.error)),
        TextField(
          controller: _note,
          minLines: 3,
          maxLines: 8,
          maxLength: maxNoteLength,
          textInputAction: TextInputAction.newline,
          decoration: const InputDecoration(labelText: 'Ghi chú tổng kết'),
        ),
        sheetError(context, _error),
        FilledButton(onPressed: _busy ? null : _close, child: Text(_busy ? 'Đang đóng...' : 'Đóng dự án')),
      ],
    );
  }
}

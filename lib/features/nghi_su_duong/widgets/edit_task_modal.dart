import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/theme/app_theme.dart';
import '../../../shared/utils/api_error.dart';
import '../../../shared/widgets/form_bits.dart';
import '../models/task.dart';
import '../providers/nghi_su_duong_provider.dart';
import '../services/nghi_su_duong_api.dart';
import 'task_badges.dart';
import 'task_tile.dart';

/// Sửa tên / trạng thái / mức quan trọng, hoặc xoá việc. Chưa sửa ngày/hạn.
Future<void> showEditTaskModal(BuildContext context, Task task) =>
    showFinanceSheet<void>(context, EditTaskModal(task: task));

class EditTaskModal extends ConsumerStatefulWidget {
  const EditTaskModal({super.key, required this.task});

  final Task task;

  @override
  ConsumerState<EditTaskModal> createState() => _EditTaskModalState();
}

class _EditTaskModalState extends ConsumerState<EditTaskModal> {
  late final _title = TextEditingController(text: widget.task.title);
  // Việc có trạng thái lạ (unknown) thì chưa chọn sẵn ô nào.
  late TaskStatus _status = widget.task.status;
  late int _importance = widget.task.importance;
  bool _busy = false;
  String? _error;

  static const _statuses = [TaskStatus.prep, TaskStatus.inProgress, TaskStatus.review, TaskStatus.done];

  @override
  void initState() {
    super.initState();
    _title.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _title.dispose();
    super.dispose();
  }

  String get _trimmedTitle => _title.text.trim();

  bool get _changed =>
      _trimmedTitle != widget.task.title || _status != widget.task.status || _importance != widget.task.importance;

  bool get _canSave => !_busy && _trimmedTitle.isNotEmpty && _changed;

  Future<void> _save() async {
    setState(() {
      _busy = true;
      _error = null;
    });
    final t = widget.task;
    try {
      // Chỉ gửi trường thực sự đổi.
      await ref.read(nghiSuDuongApiProvider).updateTask(
            t.id,
            title: _trimmedTitle != t.title ? _trimmedTitle : null,
            status: _status != t.status ? _status : null,
            importance: _importance != t.importance ? _importance : null,
          );
      ref.read(tasksProvider.notifier).refreshAfterWrite();
      if (mounted) Navigator.of(context).pop();
    } catch (e) {
      if (mounted) {
        setState(() {
          _busy = false;
          _error = apiErrorMessage(e, 'Không lưu được việc, thử lại nhé.');
        });
      }
    }
  }

  Future<void> _delete() async {
    if (!await confirmDeleteTask(context, widget.task) || !mounted) return;
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await ref.read(nghiSuDuongApiProvider).deleteTask(widget.task.id);
      final notifier = ref.read(tasksProvider.notifier);
      notifier.removeLocal(widget.task.id);
      notifier.refreshAfterWrite();
      if (mounted) Navigator.of(context).pop();
    } catch (e) {
      if (mounted) {
        setState(() {
          _busy = false;
          _error = apiErrorMessage(e, 'Không xoá được việc, thử lại nhé.');
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final label = TextStyle(fontSize: 12, color: Colors.white.withValues(alpha: 0.6));
    return FinanceSheetBody(
      title: 'Sửa việc',
      children: [
        TextField(
          controller: _title,
          maxLength: 255, // cột varchar(255)
          decoration: const InputDecoration(labelText: 'Tên việc', counterText: ''),
          textInputAction: TextInputAction.done,
          onSubmitted: (_) => _canSave ? _save() : null,
        ),
        Text('Trạng thái', style: label),
        ChoiceRow<TaskStatus>(
          options: {for (final s in _statuses) s: s.label},
          selected: _status,
          onSelected: (s) => setState(() => _status = s),
        ),
        Text('Mức quan trọng', style: label),
        ChoiceRow<int>(
          options: {for (final level in const [3, 2, 1]) level: importanceLabel(level)},
          selected: _importance,
          onSelected: (v) => setState(() => _importance = v),
        ),
        sheetError(context, _error),
        FilledButton(
          onPressed: _canSave ? _save : null,
          style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(48)),
          child: Text(_busy ? 'Đang lưu...' : 'Lưu'),
        ),
        OutlinedButton(
          onPressed: _busy ? null : _delete,
          style: OutlinedButton.styleFrom(
            minimumSize: const Size.fromHeight(48),
            foregroundColor: AppColors.shuiro500,
            side: const BorderSide(color: AppColors.shuiro500),
          ),
          child: const Text('Xóa việc'),
        ),
      ],
    );
  }
}

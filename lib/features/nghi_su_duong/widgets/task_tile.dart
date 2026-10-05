import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/theme/app_theme.dart';
import '../../../shared/utils/api_error.dart';
import '../models/task.dart';
import '../providers/nghi_su_duong_provider.dart';
import '../services/nghi_su_duong_api.dart';
import 'edit_task_modal.dart';
import 'task_badges.dart';

/// Hộp xác nhận xoá việc (ghi rõ tên). true = người dùng chọn Xoá.
Future<bool> confirmDeleteTask(BuildContext context, Task task) async {
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Xoá việc?'),
      content: Text('"${task.title}" sẽ bị xoá hẳn, không khôi phục được.'),
      actions: [
        TextButton(onPressed: () => Navigator.of(context).pop(false), child: const Text('Huỷ')),
        TextButton(
          onPressed: () => Navigator.of(context).pop(true),
          style: TextButton.styleFrom(foregroundColor: AppColors.shuiro500),
          child: const Text('Xoá'),
        ),
      ],
    ),
  );
  return confirmed == true;
}

/// 1 dòng việc dùng chung ("Task hôm nay" ở màn Dự án, màn chi tiết dự án):
/// ô tick (hoàn thành, optimistic), chạm dòng → form sửa, vuốt trái → xoá
/// (luôn hỏi lại; huỷ hoặc lỗi thì dòng trượt về).
class TaskTile extends ConsumerStatefulWidget {
  const TaskTile(this.task, {super.key});

  final Task task;

  @override
  ConsumerState<TaskTile> createState() => _TaskTileState();
}

class _TaskTileState extends ConsumerState<TaskTile> {
  /// Đang gửi PATCH tick — khoá ô tick để không gửi 2 lần.
  bool _toggling = false;

  void _snack(String text) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));

  Future<void> _toggle() async {
    if (_toggling) return;
    setState(() => _toggling = true);
    // Lấy trước khi await: ở màn chi tiết, việc vừa tick chuyển sang nhóm "Đã
    // xong" (đang gập) → dòng này bị gỡ khỏi cây, nhưng lỗi vẫn phải được báo.
    final messenger = ScaffoldMessenger.of(context);
    try {
      await ref.read(tasksProvider.notifier).toggleDone(widget.task);
    } catch (e) {
      messenger.showSnackBar(SnackBar(content: Text(apiErrorMessage(e, 'Không cập nhật được việc, thử lại nhé.'))));
    } finally {
      if (mounted) setState(() => _toggling = false);
    }
  }

  /// confirmDismiss: hỏi → xoá ở server. Chỉ trả true khi server đã xoá xong.
  Future<bool> _confirmAndDelete() async {
    if (!await confirmDeleteTask(context, widget.task)) return false;
    try {
      await ref.read(nghiSuDuongApiProvider).deleteTask(widget.task.id);
      return true;
    } catch (e) {
      if (mounted) _snack(apiErrorMessage(e, 'Không xoá được việc, thử lại nhé.'));
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final task = widget.task;
    final done = task.status == TaskStatus.done;
    // Nút semantics riêng cho mỗi dòng — không gộp với tiêu đề nhóm phía trên.
    return Semantics(
      container: true,
      child: Dismissible(
        key: ValueKey('task-${task.id}'),
        direction: DismissDirection.endToStart,
        confirmDismiss: (_) => _confirmAndDelete(),
        onDismissed: (_) {
          final notifier = ref.read(tasksProvider.notifier);
          notifier.removeLocal(task.id);
          notifier.refreshAfterWrite();
        },
        background: Container(
          alignment: Alignment.centerRight,
          padding: const EdgeInsets.only(right: 16),
          color: AppColors.shuiro500.withValues(alpha: 0.25),
          child: const Icon(Icons.delete_outline, color: AppColors.shuiro500),
        ),
        child: InkWell(
          onTap: () => showEditTaskModal(context, task),
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 48),
            child: Row(
              children: [
                SizedBox(
                  width: 44,
                  height: 44,
                  child: Checkbox(
                    value: done,
                    // null khi đang gửi → ô tick khoá (chống bấm đúp).
                    onChanged: _toggling ? null : (_) => _toggle(),
                    activeColor: AppColors.emerald400,
                    semanticLabel: done ? 'Bỏ hoàn thành "${task.title}"' : 'Hoàn thành "${task.title}"',
                  ),
                ),
                const SizedBox(width: 4),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      spacing: 6,
                      children: [
                        Text(
                          task.title,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 13,
                            decoration: done ? TextDecoration.lineThrough : null,
                            decorationColor: Colors.white.withValues(alpha: 0.4),
                            color: done ? Colors.white.withValues(alpha: 0.4) : null,
                          ),
                        ),
                        Opacity(
                          opacity: done ? 0.5 : 1,
                          child: Wrap(
                            spacing: 6,
                            runSpacing: 4,
                            children: [TaskStatusBadge(task.status), ImportanceTag(task.importance)],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

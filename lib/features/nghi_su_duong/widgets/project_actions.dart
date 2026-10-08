import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../shared/utils/api_error.dart';
import '../models/project_detail.dart';
import '../models/project_summary.dart';
import '../providers/nghi_su_duong_provider.dart';
import '../services/nghi_su_duong_api.dart';
import 'close_project_sheet.dart';

enum _Action { close, reopen, delete }

/// Nút menu ở đầu trang chi tiết: "Đóng dự án" / "Mở lại dự án" (theo trạng thái) và "Xoá dự án".
class ProjectActionsButton extends ConsumerWidget {
  const ProjectActionsButton({super.key, required this.project});

  final ProjectDetail project;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final done = project.status == ProjectStatus.done;
    return PopupMenuButton<_Action>(
      tooltip: 'Thao tác dự án',
      icon: const Icon(Icons.more_vert),
      onSelected: (a) => switch (a) {
        _Action.close => showCloseProjectSheet(context, project),
        _Action.reopen => _reopen(context, ref),
        _Action.delete => _delete(context, ref),
      },
      itemBuilder: (_) => [
        if (done) const PopupMenuItem(value: _Action.reopen, child: Text('Mở lại dự án')) else const PopupMenuItem(value: _Action.close, child: Text('Đóng dự án')),
        const PopupMenuItem(value: _Action.delete, child: Text('Xoá dự án')),
      ],
    );
  }

  Future<void> _reopen(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Mở lại dự án?'),
        content: const Text('Mở lại dự án? Tài liệu tổng kết đã lưu vẫn giữ trong Tàng Kinh Các.'),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(false), child: const Text('Huỷ')),
          TextButton(onPressed: () => Navigator.of(context).pop(true), child: const Text('Mở lại')),
        ],
      ),
    );
    if (confirmed != true || !context.mounted) return;
    try {
      await ref.read(nghiSuDuongApiProvider).updateProject(project.id, {'status': ProjectStatus.active.apiValue});
      refreshAfterLifecycle(ref.invalidate, project.id);
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(apiErrorMessage(e, 'Không mở lại được dự án, thử lại nhé.'))),
        );
      }
    }
  }

  Future<void> _delete(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Xoá dự án "${project.name}"?'),
        content: const Text(
          'Toàn bộ KR, việc và checklist sẽ bị xoá vĩnh viễn. Giao dịch đã gắn vẫn nằm trong sổ thu-chi; '
          'tài liệu tổng kết (nếu có) vẫn giữ.',
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(false), child: const Text('Huỷ')),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: Theme.of(context).colorScheme.error),
            child: const Text('Xoá vĩnh viễn'),
          ),
        ],
      ),
    );
    if (confirmed != true || !context.mounted) return;
    final messenger = ScaffoldMessenger.of(context);
    try {
      await ref.read(nghiSuDuongApiProvider).deleteProject(project.id);
    } catch (e) {
      messenger.showSnackBar(SnackBar(content: Text(apiErrorMessage(e, 'Không xoá được dự án, thử lại nhé.'))));
      return;
    }
    // Rời màn trước, rồi mới làm mới các nơi khác (không làm mới chi tiết của dự án vừa xoá — sẽ 404).
    if (context.mounted) {
      if (context.canPop()) {
        context.pop();
      } else {
        context.go('/du-an');
      }
    }
    refreshAfterProjectDeleted(ref.invalidate);
  }
}

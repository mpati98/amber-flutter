import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/widgets/progress_bar.dart';
import '../models/project_detail.dart';
import '../models/task.dart';
import '../providers/nghi_su_duong_provider.dart';
import '../widgets/key_results_block.dart';
import '../widgets/task_form.dart';
import '../widgets/project_header.dart';
import '../widgets/task_board.dart';

/// /du-an/:projectId — chi tiết một dự án STANDARD: đầu trang, Kết quả then chốt, bảng việc.
/// Dữ liệu: GET /api/projects/[id] (kèm KR) và GET /api/tasks?projectId=.
class ProjectDetailScreen extends ConsumerWidget {
  const ProjectDetailScreen({super.key, required this.projectId});

  final String projectId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final detail = ref.watch(projectDetailProvider(projectId));
    final tasksAsync = ref.watch(projectTasksProvider(projectId));
    final project = detail.value;
    final tasks = tasksAsync.value;
    final muted = TextStyle(fontSize: 12, color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6));

    // Mỗi tab là một mục ở đây; thêm tab (Lịch, Thu-chi) = thêm một mục. Hiện chỉ có "Bảng" nên
    // không dựng thanh tab.
    final tabs = <({String label, Widget Function() build})>[
      (
        label: 'Bảng',
        build: () => _BoardTab(projectId: projectId, project: project!, tasks: tasks, tasksAsync: tasksAsync),
      ),
    ];

    return Scaffold(
      appBar: AppBar(title: Text(project?.name ?? 'Dự án', maxLines: 1, overflow: TextOverflow.ellipsis)),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1200),
          child: RefreshIndicator(
            onRefresh: () => Future.wait([
              ref.refresh(projectDetailProvider(projectId).future),
              ref.refresh(projectTasksProvider(projectId).future),
            ]),
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              children: [
                if (project == null)
                  Text(detail.hasError ? 'Không tải được dự án.' : 'Đang tải...', style: muted)
                else ...[
                  ProjectHeader(project: project, tasks: tasks),
                  const SizedBox(height: 16),
                  KeyResultsBlock(projectId: projectId, keyResults: project.keyResults),
                  const SizedBox(height: 24),
                  tabs.first.build(),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _BoardTab extends StatelessWidget {
  const _BoardTab({required this.projectId, required this.project, required this.tasks, required this.tasksAsync});

  final String projectId;
  final ProjectDetail project;
  final List<Task>? tasks;
  final AsyncValue<List<Task>> tasksAsync;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final muted = TextStyle(fontSize: 12, color: cs.onSurface.withValues(alpha: 0.6));
    final total = tasks?.length ?? 0;
    final done = tasks?.where((t) => t.status == TaskStatus.done).length ?? 0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: 12,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(tasks == null ? 'Đang tải...' : '$done / $total việc xong', style: muted),
            ),
            TextButton.icon(
              // Việc luôn tạo trong dự án đang xem; dùng được cả khi dự án Tạm dừng / Đã xong.
              onPressed: () => showTaskForm(context, projectId: projectId, keyResults: project.keyResults),
              icon: const Icon(Icons.add, size: 18),
              label: const Text('Thêm việc'),
            ),
          ],
        ),
        ProgressBar(value: done.toDouble(), max: total.toDouble()),
        if (tasksAsync.hasError && tasks == null)
          Text('Không tải được việc.', style: muted)
        else if (tasks != null)
          TaskBoard(projectId: projectId, tasks: tasks!, keyResults: project.keyResults),
      ],
    );
  }
}

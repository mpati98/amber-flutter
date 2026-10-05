import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/theme/app_theme.dart';
import '../../../shared/widgets/progress_bar.dart';
import '../../../shared/widgets/scroll_card.dart';
import '../models/overview.dart';
import '../models/task.dart';
import '../providers/nghi_su_duong_provider.dart';
import '../widgets/new_task_modal.dart';
import '../widgets/task_tile.dart';

TextStyle _muted(double size) => TextStyle(fontSize: size, color: Colors.white.withValues(alpha: 0.4));

/// /du-an/:projectId — việc của 1 dự án, nhóm theo trạng thái. Không có route
/// API riêng: tên dự án lấy từ du-an/overview, việc lọc từ tasksProvider (mọi
/// việc của user) theo projectId ở client.
class ProjectDetailScreen extends ConsumerStatefulWidget {
  const ProjectDetailScreen({super.key, required this.projectId});

  final String projectId;

  @override
  ConsumerState<ProjectDetailScreen> createState() => _ProjectDetailScreenState();
}

class _ProjectDetailScreenState extends ConsumerState<ProjectDetailScreen> {
  bool _showDone = false; // nhóm "Đã xong" gập lại mặc định

  @override
  Widget build(BuildContext context) {
    final tasksAsync = ref.watch(tasksProvider);
    final overview = ref.watch(duAnOverviewProvider).value;
    final projects = overview?.activeProjects ?? const <ActiveProject>[];
    final project = projects.where((p) => p.id == widget.projectId).firstOrNull;

    final tasks = tasksAsync.value?.where((t) => t.projectId == widget.projectId).toList();
    List<Task> ofStatus(Set<TaskStatus> s) => tasks?.where((t) => s.contains(t.status)).toList() ?? const [];
    // Trạng thái lạ (không có trong 4 giá trị) xếp cùng "Chuẩn bị" để không mất việc.
    final groups = [
      ('Đang làm', ofStatus({TaskStatus.inProgress})),
      ('Chờ', ofStatus({TaskStatus.waiting})),
      ('Chuẩn bị', ofStatus({TaskStatus.prep, TaskStatus.unknown})),
    ];
    final done = ofStatus({TaskStatus.done});
    final total = tasks?.length ?? 0;

    return Scaffold(
      appBar: AppBar(
        title: Text(project?.name ?? 'Dự án', maxLines: 1, overflow: TextOverflow.ellipsis),
        actions: [
          TextButton(
            // Dự án đã lưu trữ / chưa tải xong overview thì chưa thêm việc được.
            onPressed: project == null
                ? null
                : () => showNewTaskModal(context, projects, projectId: widget.projectId),
            child: const Text('+ Việc'),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 640),
          child: RefreshIndicator(
            onRefresh: () => Future.wait([ref.refresh(tasksProvider.future), ref.refresh(duAnOverviewProvider.future)]),
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                ScrollCard(
                  glow: ScrollCardGlow.yugen,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    spacing: 8,
                    children: [
                      Text(
                        project?.name ?? 'Dự án',
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontSize: 20),
                      ),
                      ProgressBar(value: done.length.toDouble(), max: total.toDouble()),
                      Text(tasks == null ? 'Đang tải...' : '${done.length} / $total việc xong', style: _muted(12)),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                if (tasksAsync.hasError && tasks == null)
                  Text('Không tải được việc.', style: _muted(12))
                else if (tasks == null)
                  const SizedBox.shrink()
                else if (tasks.isEmpty)
                  Text('Chưa có việc nào — bấm "+ Việc" để thêm việc đầu tiên.', style: _muted(13))
                else ...[
                  for (final (title, items) in groups)
                    if (items.isNotEmpty) _Group(title: title, tasks: items),
                  if (done.isNotEmpty)
                    _DoneGroup(tasks: done, expanded: _showDone, onToggle: () => setState(() => _showDone = !_showDone)),
                  const SizedBox(height: 8),
                  Text('Chạm để sửa · vuốt sang trái để xoá', style: _muted(10)),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

Widget _groupTitle(String text) => Padding(
      padding: const EdgeInsets.only(top: 8, bottom: 4),
      child: Text(text, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: AppColors.kincha400)),
    );

class _Group extends StatelessWidget {
  const _Group({required this.title, required this.tasks});

  final String title;
  final List<Task> tasks;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _groupTitle('$title (${tasks.length})'),
        for (final t in tasks) TaskTile(t, key: ValueKey(t.id)),
        const SizedBox(height: 8),
      ],
    );
  }
}

class _DoneGroup extends StatelessWidget {
  const _DoneGroup({required this.tasks, required this.expanded, required this.onToggle});

  final List<Task> tasks;
  final bool expanded;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Semantics(
          button: true,
          expanded: expanded,
          child: InkWell(
            onTap: onToggle,
            child: ConstrainedBox(
              constraints: const BoxConstraints(minHeight: 44),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      'Đã xong (${tasks.length})',
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: AppColors.emerald300),
                    ),
                  ),
                  Icon(expanded ? Icons.expand_less : Icons.expand_more, size: 20, color: Colors.white54),
                ],
              ),
            ),
          ),
        ),
        if (expanded) for (final t in tasks) TaskTile(t, key: ValueKey(t.id)),
      ],
    );
  }
}

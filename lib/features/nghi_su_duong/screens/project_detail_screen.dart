import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/widgets/form_bits.dart';
import '../../../shared/widgets/progress_bar.dart';
import '../models/project_detail.dart';
import '../models/task.dart';
import '../providers/nghi_su_duong_provider.dart';
import '../widgets/key_results_block.dart';
import '../widgets/task_form.dart';
import '../widgets/project_header.dart';
import '../widgets/project_finance_card.dart';
import '../widgets/project_finance_tab.dart';
import '../widgets/project_transaction_form.dart';
import '../widgets/task_board.dart';
import '../widgets/task_detail_sheet.dart';
import '../widgets/task_timeline.dart';

/// Các tab của màn: thêm tab (Thu-chi...) = thêm một giá trị ở đây và một nhánh ở [_TabContent].
enum _DetailTab { board, calendar, finance }

/// /du-an/:projectId — chi tiết một dự án STANDARD: đầu trang, Kết quả then chốt, rồi tab "Bảng" |
/// "Lịch" cho cùng một danh sách việc. Dữ liệu: GET /api/projects/[id] (kèm KR) và GET /api/tasks?projectId=.
class ProjectDetailScreen extends ConsumerStatefulWidget {
  const ProjectDetailScreen({super.key, required this.projectId, this.initialTaskId});

  final String projectId;

  /// Việc cần tự mở trang chi tiết khi dữ liệu dự án đã tải xong (không còn tồn tại thì bỏ qua).
  final String? initialTaskId;

  @override
  ConsumerState<ProjectDetailScreen> createState() => _ProjectDetailScreenState();
}

class _ProjectDetailScreenState extends ConsumerState<ProjectDetailScreen> {
  _DetailTab _tab = _DetailTab.board;
  bool _initialTaskHandled = false;

  @override
  Widget build(BuildContext context) {
    final projectId = widget.projectId;
    final detail = ref.watch(projectDetailProvider(projectId));
    final tasksAsync = ref.watch(projectTasksProvider(projectId));
    final project = detail.value;
    final tasks = tasksAsync.value;
    final muted = TextStyle(fontSize: 12, color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6));

    // Mở sẵn trang chi tiết việc (một lần) khi cả dự án lẫn danh sách việc đã tải xong.
    final wantedTask = widget.initialTaskId;
    if (!_initialTaskHandled && wantedTask != null && project != null && tasks != null) {
      _initialTaskHandled = true;
      if (tasks.any((t) => t.id == wantedTask)) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) showTaskDetail(context, projectId: projectId, taskId: wantedTask);
        });
      }
    }

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
                  // Rộng: KR và thẻ Thu-chi cạnh nhau; hẹp: thẻ Thu-chi dưới khối KR.
                  LayoutBuilder(
                    builder: (context, c) {
                      final kr = KeyResultsBlock(projectId: projectId, keyResults: project.keyResults);
                      final fin = ProjectFinanceCard(projectId: projectId, onOpen: () => setState(() => _tab = _DetailTab.finance));
                      if (c.maxWidth >= 900) {
                        return Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          spacing: 16,
                          children: [Expanded(flex: 2, child: kr), Expanded(child: fin)],
                        );
                      }
                      return Column(crossAxisAlignment: CrossAxisAlignment.stretch, spacing: 16, children: [kr, fin]);
                    },
                  ),
                  const SizedBox(height: 24),
                  _WorkArea(
                    project: project,
                    tasks: tasks,
                    tasksAsync: tasksAsync,
                    tab: _tab,
                    onTab: (t) => setState(() => _tab = t),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Phần dùng chung cho mọi tab (đếm việc xong, "Thêm việc", chuyển tab) rồi nội dung tab đang chọn.
class _WorkArea extends StatelessWidget {
  const _WorkArea({required this.project, required this.tasks, required this.tasksAsync, required this.tab, required this.onTab});

  final ProjectDetail project;
  final List<Task>? tasks;
  final AsyncValue<List<Task>> tasksAsync;
  final _DetailTab tab;
  final ValueChanged<_DetailTab> onTab;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final muted = TextStyle(fontSize: 12, color: cs.onSurface.withValues(alpha: 0.6));
    final total = tasks?.length ?? 0;
    final done = tasks?.where((t) => t.status == TaskStatus.done).length ?? 0;

    final isFinance = tab == _DetailTab.finance;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: 12,
      children: [
        Row(
          children: [
            Expanded(
              // Tab Thu-chi không đếm việc.
              child: isFinance ? const SizedBox.shrink() : Text(tasks == null ? 'Đang tải...' : '$done / $total việc xong', style: muted),
            ),
            if (isFinance)
              TextButton.icon(
                onPressed: () => showProjectTransactionForm(context, projectId: project.id),
                icon: const Icon(Icons.add, size: 18),
                label: const Text('Thêm giao dịch'),
              )
            else
              TextButton.icon(
                // Việc luôn tạo trong dự án đang xem; dùng được cả khi dự án Tạm dừng / Đã xong.
                onPressed: () => showTaskForm(context, projectId: project.id, keyResults: project.keyResults),
                icon: const Icon(Icons.add, size: 18),
                label: const Text('Thêm việc'),
              ),
          ],
        ),
        if (!isFinance) ProgressBar(value: done.toDouble(), max: total.toDouble()),
        ChoiceRow<_DetailTab>(
          options: const {_DetailTab.board: 'Bảng', _DetailTab.calendar: 'Lịch', _DetailTab.finance: 'Thu-chi'},
          selected: tab,
          onSelected: onTab,
        ),
        if (isFinance)
          ProjectFinanceTab(projectId: project.id)
        else if (tasksAsync.hasError && tasks == null)
          Text('Không tải được việc.', style: muted)
        else if (tasks != null)
          switch (tab) {
            _DetailTab.board => TaskBoard(projectId: project.id, tasks: tasks!, keyResults: project.keyResults),
            _DetailTab.calendar => TaskTimeline(
                projectId: project.id,
                tasks: tasks!,
                projectStart: project.startDate,
                projectEnd: project.endDate,
              ),
            _DetailTab.finance => const SizedBox.shrink(),
          },
      ],
    );
  }
}

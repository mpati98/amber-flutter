import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/theme/design_tokens.dart';
import '../../../shared/widgets/design_page.dart';
import '../../../shared/widgets/form_bits.dart';
import '../../../shared/widgets/list_frame.dart';
import '../../../shared/widgets/overview_block.dart';
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

    final doing = tasks?.where((t) => t.status == TaskStatus.inProgress).length ?? 0;
    final open = tasks?.where((t) => t.status != TaskStatus.done).length ?? 0;

    return DesignPage(
      title: project?.name ?? 'Dự án',
      backFallback: '/du-an',
      // Bảng việc nhiều cột và dòng thời gian cần cả bề ngang → luôn xếp dọc.
      stacked: true,
      onRefresh: () => Future.wait([
        ref.refresh(projectDetailProvider(projectId).future),
        ref.refresh(projectTasksProvider(projectId).future),
      ]),
      overview: OverviewBlock(
        title: 'Tổng quan dự án',
        labelWidth: 90,
        rows: [
          OverviewRow.muted(
            label: 'Tiến độ',
            text: tasks == null ? (tasksAsync.hasError ? 'Không tải được.' : 'Đang tải…') : '$doing đang làm · $open việc còn mở',
          ),
          OverviewRow.muted(
            label: 'KR',
            text: project == null
                ? (detail.hasError ? 'Không tải được.' : 'Đang tải…')
                : project.keyResults.isEmpty
                ? 'Chưa đặt kết quả then chốt'
                : '${project.keyResults.length} kết quả then chốt',
          ),
        ],
      ),
      content: (context, _) => ListFrame(
        child: project == null
            ? Text(detail.hasError ? 'Không tải được dự án.' : 'Đang tải...', style: DesignText.muted)
            : Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  ProjectHeader(project: project, tasks: tasks),
                  const SizedBox(height: 14),
                  // Rộng: KR và thẻ Thu-chi cạnh nhau; hẹp: thẻ Thu-chi dưới khối KR.
                  LayoutBuilder(
                    builder: (context, c) {
                      final kr = KeyResultsBlock(projectId: projectId, keyResults: project.keyResults);
                      final fin = ProjectFinanceCard(projectId: projectId, onOpen: () => setState(() => _tab = _DetailTab.finance));
                      if (c.maxWidth >= 800) {
                        return Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          spacing: 12,
                          children: [Expanded(flex: 2, child: kr), Expanded(child: fin)],
                        );
                      }
                      return Column(crossAxisAlignment: CrossAxisAlignment.stretch, spacing: 12, children: [kr, fin]);
                    },
                  ),
                  const SizedBox(height: 18),
                  _WorkArea(
                    project: project,
                    tasks: tasks,
                    tasksAsync: tasksAsync,
                    tab: _tab,
                    onTab: (t) => setState(() => _tab = t),
                  ),
                ],
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
    final total = tasks?.length ?? 0;
    final done = tasks?.where((t) => t.status == TaskStatus.done).length ?? 0;
    final isFinance = tab == _DetailTab.finance;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: 10,
      children: [
        FrameToolbar(
          chips: ChoiceRow<_DetailTab>(
            options: const {_DetailTab.board: 'Bảng', _DetailTab.calendar: 'Lịch', _DetailTab.finance: 'Thu-chi'},
            selected: tab,
            onSelected: onTab,
          ),
          action: isFinance
              ? DesignButton.outline(
                  label: '+ Thêm giao dịch',
                  onPressed: () => showProjectTransactionForm(context, projectId: project.id),
                )
              // Việc luôn tạo trong dự án đang xem; dùng được cả khi dự án Tạm dừng / Đã xong.
              : DesignButton.outline(
                  label: '+ Thêm việc',
                  onPressed: () => showTaskForm(context, projectId: project.id, keyResults: project.keyResults),
                ),
        ),
        // Tab Thu-chi không đếm việc.
        if (!isFinance) ...[
          Text(tasks == null ? 'Đang tải...' : '$done / $total việc xong', style: DesignText.muted),
          DesignProgressBar(total == 0 ? 0 : done * 100 / total),
        ],
        if (isFinance)
          ProjectFinanceTab(projectId: project.id)
        else if (tasksAsync.hasError && tasks == null)
          const Text('Không tải được việc.', style: DesignText.muted)
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

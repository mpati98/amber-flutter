import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/providers/auth_provider.dart';
import '../../../shared/theme/app_theme.dart';
import '../../../shared/utils/vn_time.dart';
import '../../../shared/widgets/form_bits.dart';
import '../../../shared/widgets/scroll_card.dart';
import '../models/overview.dart';
import '../models/project_summary.dart';
import '../providers/nghi_su_duong_provider.dart';
import '../widgets/new_project_modal.dart';
import '../widgets/new_task_modal.dart';
import '../widgets/project_card.dart';
import '../widgets/task_tile.dart';

const _weekdays = ['Thứ Hai', 'Thứ Ba', 'Thứ Tư', 'Thứ Năm', 'Thứ Sáu', 'Thứ Bảy', 'Chủ Nhật'];

/// Giờ VN, không theo múi giờ cài trên máy.
String _greeting() {
  final h = vnHour();
  if (h < 11) return 'Chào buổi sáng';
  if (h < 18) return 'Chào buổi chiều';
  return 'Chào buổi tối';
}

/// Như toLocaleDateString("vi-VN", {weekday: long, day, month: long}): "Thứ Tư, 30 tháng 9".
String _dateLabel() {
  final d = vnNow();
  return '${_weekdays[d.weekday - 1]}, ${d.day} tháng ${d.month}';
}

TextStyle _muted(double size) => TextStyle(fontSize: size, color: Colors.white.withValues(alpha: 0.4));

/// Màn Dự án: lời chào, "Task hôm nay", khu "Dự án" (bộ lọc trạng thái + lưới thẻ từ
/// GET /api/du-an/summary).
class DuAnScreen extends ConsumerWidget {
  const DuAnScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tasks = ref.watch(tasksProvider);
    final overview = ref.watch(duAnOverviewProvider);
    final summary = ref.watch(duAnSummaryProvider);
    final filter = ref.watch(duAnFilterProvider);
    final auth = ref.watch(authControllerProvider).value;
    final userName = auth is Authenticated ? auth.user['name'] as String? : null;

    final today = vnToday();
    final allTasks = tasks.value;
    final todayTasks = allTasks?.where((t) => t.isOn(today)).toList();
    final data = overview.value;

    // Web ẩn nút thêm task khi chưa có dự án (task luôn thuộc 1 dự án).
    void addTask() {
      final projects = data?.activeProjects ?? const <ActiveProject>[];
      if (projects.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Tạo một dự án trước rồi mới thêm việc.')),
        );
        return;
      }
      showNewTaskModal(context, projects);
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Dự án')),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1100),
          child: RefreshIndicator(
            onRefresh: () => Future.wait([
              ref.refresh(tasksProvider.future),
              ref.refresh(duAnOverviewProvider.future),
              ref.refresh(duAnSummaryProvider.future),
            ]),
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Text(
                  '${_greeting()}${userName != null && userName.isNotEmpty ? ', $userName' : ''}',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontSize: 14,
                        fontStyle: FontStyle.italic,
                        color: AppColors.kincha400,
                      ),
                ),
                const SizedBox(height: 4),
                Text(_dateLabel(), style: _muted(12)),
                const SizedBox(height: 24), // gap-6
                Align(
                  alignment: Alignment.centerLeft,
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 640),
                    child: _Section(
                      title: 'Task hôm nay',
                      glow: ScrollCardGlow.kincha,
                      action: TextButton(onPressed: addTask, child: const Text('+ Việc')),
                      child: tasks.hasError
                          ? Text('Không tải được task.', style: _muted(12))
                          : todayTasks == null
                              ? Text('Đang tải...', style: _muted(12))
                              : todayTasks.isEmpty
                                  ? Text('Không có task nào hôm nay.', style: _muted(12))
                                  : Column(children: [for (final t in todayTasks) TaskTile(t, key: ValueKey(t.id))]),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                _ProjectsArea(summary: summary, filter: filter),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Khu "Dự án": tiêu đề + bộ lọc trạng thái kèm số đếm + nút thêm, rồi lưới thẻ.
class _ProjectsArea extends ConsumerWidget {
  const _ProjectsArea({required this.summary, required this.filter});

  final AsyncValue<DuAnSummary> summary;
  final ProjectStatus filter;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = Theme.of(context).colorScheme;
    final muted = TextStyle(fontSize: 12, color: cs.onSurface.withValues(alpha: 0.6));
    final projects = summary.value?.projects;
    int count(ProjectStatus s) => projects?.where((p) => p.status == s).length ?? 0;
    String label(String name, ProjectStatus s) => '$name · ${projects == null ? '–' : count(s)}';
    final shown = projects?.where((p) => p.status == filter).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: 12,
      children: [
        Wrap(
          spacing: 12,
          runSpacing: 8,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            Text('Dự án', style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontSize: 18, color: cs.onSurface)),
            ChoiceRow<ProjectStatus>(
              options: {
                ProjectStatus.active: label('Đang triển khai', ProjectStatus.active),
                ProjectStatus.paused: label('Tạm dừng', ProjectStatus.paused),
                ProjectStatus.done: label('Đã xong', ProjectStatus.done),
              },
              selected: filter,
              onSelected: ref.read(duAnFilterProvider.notifier).select,
            ),
            TextButton.icon(
              onPressed: () => showNewProjectModal(context),
              icon: const Icon(Icons.add, size: 18),
              label: const Text('Thêm dự án'),
            ),
          ],
        ),
        if (summary.hasError && projects == null)
          Text('Không tải được dự án.', style: muted)
        else if (shown == null)
          Text('Đang tải...', style: muted)
        else if (shown.isEmpty)
          Text('Không có dự án nào ở trạng thái này.', style: muted)
        else
          ProjectGrid(projects: shown),
      ],
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({required this.title, required this.glow, this.action, required this.child});

  final String title;
  final ScrollCardGlow glow;
  final Widget? action;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return ScrollCard(
      glow: glow,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: AppColors.kincha400),
                ),
              ),
              ?action,
            ],
          ),
          const SizedBox(height: 12), // mb-3
          child,
        ],
      ),
    );
  }
}

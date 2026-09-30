import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/providers/auth_provider.dart';
import '../../../shared/theme/app_theme.dart';
import '../../../shared/utils/vn_time.dart';
import '../../../shared/widgets/progress_bar.dart';
import '../../../shared/widgets/scroll_card.dart';
import '../models/overview.dart';
import '../models/task.dart';
import '../providers/nghi_su_duong_provider.dart';
import '../widgets/new_project_modal.dart';
import '../widgets/new_task_modal.dart';
import '../widgets/task_badges.dart';

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

/// "#eccb8a" → Color; null/sai định dạng → kincha-400 (mặc định bên web).
Color _projectColor(String? hex) {
  final v = hex == null ? null : int.tryParse(hex.replaceFirst('#', ''), radix: 16);
  return v == null || hex!.length != 7 ? AppColors.kincha400 : Color(0xFF000000 | v);
}

TextStyle _muted(double size) => TextStyle(fontSize: size, color: Colors.white.withValues(alpha: 0.4));

/// Port /du-an (ProjectsDashboard): lời chào, 4 ô số liệu, Task hôm nay,
/// Dự án đang chạy, Sắp tới. Web xếp 2 cột ở màn rộng, ở đây 1 cột.
class DuAnScreen extends ConsumerWidget {
  const DuAnScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tasks = ref.watch(tasksProvider);
    final overview = ref.watch(duAnOverviewProvider);
    final auth = ref.watch(authControllerProvider).value;
    final userName = auth is Authenticated ? auth.user['name'] as String? : null;

    final today = vnToday();
    final allTasks = tasks.value;
    final todayTasks = allTasks?.where((t) => t.isOn(today)).toList();
    final inProgress = allTasks?.where((t) => t.status == TaskStatus.inProgress).length;
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
          constraints: const BoxConstraints(maxWidth: 640),
          child: RefreshIndicator(
            onRefresh: () => Future.wait([ref.refresh(tasksProvider.future), ref.refresh(duAnOverviewProvider.future)]),
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
                GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: 2.2,
                  children: [
                    _StatCard(value: '${todayTasks?.length ?? '–'}', label: 'Task hôm nay'),
                    _StatCard(value: '${inProgress ?? '–'}', label: 'Đang làm'),
                    _StatCard(value: '${data?.activeProjects.length ?? '–'}', label: 'Dự án chạy'),
                    _StatCard(value: data == null ? '–' : '${data.averageProgress}%', label: 'TB hoàn thành'),
                  ],
                ),
                const SizedBox(height: 24),
                _Section(
                  title: 'Task hôm nay',
                  glow: ScrollCardGlow.kincha,
                  action: TextButton(onPressed: addTask, child: const Text('+ Việc')),
                  child: tasks.hasError
                      ? Text('Không tải được task.', style: _muted(12))
                      : todayTasks == null
                          ? Text('Đang tải...', style: _muted(12))
                          : todayTasks.isEmpty
                              ? Text('Không có task nào hôm nay.', style: _muted(12))
                              : Column(children: [for (final t in todayTasks) _TaskTile(t)]),
                ),
                const SizedBox(height: 16), // gap-4
                _Section(
                  title: 'Dự án đang chạy',
                  glow: ScrollCardGlow.yugen,
                  action: TextButton(onPressed: () => showNewProjectModal(context), child: const Text('+ Dự án')),
                  child: overview.hasError
                      ? Text('Không tải được dự án.', style: _muted(12))
                      : data == null
                          ? Text('Đang tải...', style: _muted(12))
                          : data.activeProjects.isEmpty
                              ? Text('Chưa có dự án nào.', style: _muted(12))
                              : Column(
                                  spacing: 12,
                                  children: [for (final p in data.activeProjects) _ProjectProgress(p)],
                                ),
                ),
                const SizedBox(height: 16),
                _Section(
                  title: 'Sắp tới',
                  glow: ScrollCardGlow.shuiro,
                  child: overview.hasError
                      ? Text('Không tải được dự án.', style: _muted(12))
                      : data == null
                          ? Text('Đang tải...', style: _muted(12))
                          : data.upcomingProjects.isEmpty
                              ? Text('Chưa có dự án sắp tới.', style: _muted(12))
                              : Column(
                                  spacing: 10,
                                  children: [for (final p in data.upcomingProjects) _UpcomingRow(p)],
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

class _StatCard extends StatelessWidget {
  const _StatCard({required this.value, required this.label});

  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12), // p-3
      decoration: BoxDecoration(
        color: AppColors.ink900.withValues(alpha: 0.6),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
        borderRadius: BorderRadius.circular(AppTheme.darkRadius),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            value,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w600, color: Colors.white),
          ),
          const SizedBox(height: 4),
          Text(label, style: _muted(11)),
        ],
      ),
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

class _TaskTile extends StatelessWidget {
  const _TaskTile(this.task);

  final Task task;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      dense: true,
      title: Text(task.title, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 13)),
      subtitle: Padding(
        padding: const EdgeInsets.only(top: 6),
        child: Align(alignment: Alignment.centerLeft, child: TaskStatusBadge(task.status)),
      ),
      trailing: ImportanceTag(task.importance),
    );
  }
}

class _ProjectProgress extends StatelessWidget {
  const _ProjectProgress(this.project);

  final ActiveProject project;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: 4,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                project.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(fontSize: 12, color: Colors.white.withValues(alpha: 0.8)),
              ),
            ),
            Text('${project.progressPct}%', style: _muted(12)),
          ],
        ),
        ProgressBar(value: project.doneTasks.toDouble(), max: project.totalTasks.toDouble()),
      ],
    );
  }
}

class _UpcomingRow extends StatelessWidget {
  const _UpcomingRow(this.project);

  final UpcomingProject project;

  @override
  Widget build(BuildContext context) {
    return Row(
      spacing: 8,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: _projectColor(project.color), shape: BoxShape.circle),
        ),
        Expanded(
          child: Text(
            project.name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(fontSize: 12, color: Colors.white.withValues(alpha: 0.8)),
          ),
        ),
        Text(project.startDate, style: _muted(12)),
      ],
    );
  }
}

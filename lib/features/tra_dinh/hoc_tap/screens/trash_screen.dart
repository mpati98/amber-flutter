import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../shared/theme/app_theme.dart';
import '../../../../shared/utils/api_error.dart';
import '../../../../shared/widgets/app_bar_back.dart';
import '../models/course.dart';
import '../providers/hoc_tap_provider.dart';
import '../utils/async_view.dart';
import '../utils/hoc_tap_errors.dart';
import '../widgets/hoc_tap_common.dart';
import '../widgets/password_confirm_sheet.dart';

/// Khóa còn ≤ ngày này thì chip và viền chip đổi sang màu cảnh báo.
const trashWarnDays = 10;

String _dd(DateTime d) {
  final l = d.toLocal();
  return '${l.day.toString().padLeft(2, '0')}/${l.month.toString().padLeft(2, '0')}';
}

/// Thùng rác của Học tập: khóa đã xoá mềm, giữ 30 ngày. Khôi phục không cần mật khẩu; xoá hẳn thì cần.
class TrashScreen extends ConsumerWidget {
  const TrashScreen({super.key});

  Future<void> _restore(
    BuildContext context,
    WidgetRef ref,
    CourseView c,
  ) async {
    final messenger = ScaffoldMessenger.of(context);
    try {
      await ref.read(hocTapActionsProvider).restoreCourse(c.id);
      messenger.showSnackBar(const SnackBar(content: Text('Đã khôi phục')));
    } catch (e) {
      messenger.showSnackBar(
        SnackBar(
          content: Text(
            apiErrorCode(e) == 'course_not_found'
                ? 'Khóa này không còn trong Thùng rác'
                : hocTapErrorMessage(e),
          ),
        ),
      );
    }
  }

  Future<void> _purge(BuildContext context, WidgetRef ref, CourseView c) async {
    final messenger = ScaffoldMessenger.of(context);
    final actions = ref.read(hocTapActionsProvider);
    final done = await showPasswordConfirmSheet(
      context,
      title: 'Xoá hẳn khóa này?',
      subtitle: c.title,
      message: 'Không thể khôi phục sau khi xoá hẳn. Buổi học đã ghi vẫn còn trong lịch sử, các thẻ vẫn giữ.',
      actionLabel: 'Xoá hẳn',
      onConfirm: (password) => actions.purgeCourse(c.id, password: password),
    );
    if (done) {
      messenger.showSnackBar(const SnackBar(content: Text('Đã xoá hẳn khóa')));
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(studyTrashProvider);
    final subjects = {
      for (final s in ref.watch(studySubjectsProvider).value ?? const [])
        s.id: s.name,
    };

    return Scaffold(
      appBar: AppBar(
        leading: const AppBarBack(fallback: '/tra-dinh'),
        title: const Text('Thùng rác'),
      ),
      body: HocTapBody(
        onRefresh: () => ref.refresh(studyTrashProvider.future),
        child: switch (async.settled) {
          AsyncData(:final value) => ListView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
            children: [
              Text(
                'Khóa đã xoá được giữ 30 ngày, sau đó tự xoá hẳn.',
                style: TextStyle(
                  fontSize: 13,
                  color: Theme.of(context).textMuted,
                ),
              ),
              const SizedBox(height: 12),
              if (value.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 32),
                  child: Center(
                    child: Text(
                      'Thùng rác trống',
                      key: const ValueKey('trash-empty'),
                      style: TextStyle(color: Theme.of(context).textMuted),
                    ),
                  ),
                )
              else
                for (final c in value)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _TrashCard(
                      course: c,
                      subjectName: subjects[c.subjectId],
                      onRestore: () => _restore(context, ref, c),
                      onPurge: () => _purge(context, ref, c),
                    ),
                  ),
              const SizedBox(height: 8),
              Text(
                'Khôi phục đưa khóa về hàng chờ. Bạn chọn lại khóa đang học khi sẵn sàng. Xoá hẳn ngay cũng cần nhập mật khẩu.',
                key: const ValueKey('trash-footnote'),
                style: TextStyle(
                  fontSize: 12,
                  color: Theme.of(context).textFaint,
                ),
              ),
            ],
          ),
          AsyncError() => ListView(
            children: [
              HocTapLoadError(
                what: 'Thùng rác',
                onRetry: () => ref.invalidate(studyTrashProvider),
              ),
            ],
          ),
          _ => const Center(child: CircularProgressIndicator()),
        },
      ),
    );
  }
}

class _TrashCard extends StatelessWidget {
  const _TrashCard({
    required this.course,
    required this.subjectName,
    required this.onRestore,
    required this.onPurge,
  });

  final CourseView course;
  final String? subjectName;
  final VoidCallback onRestore;
  final VoidCallback onPurge;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final c = course;
    final left = c.daysLeft ?? 0;
    final urgent = left <= trashWarnDays;
    final chipColor = urgent ? scheme.error : theme.textMuted;
    final sub = [
      ?subjectName,
      if (c.deletedAt != null) 'xoá ngày ${_dd(c.deletedAt!)}',
    ].join(' · ');

    return Container(
      key: ValueKey('trash-${c.id}'),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: scheme.surface,
        border: Border.all(color: scheme.onSurface.withValues(alpha: 0.12)),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: 4,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 8,
            children: [
              Expanded(
                child: Text(
                  c.title,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Container(
                key: ValueKey('trash-chip-${c.id}'),
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 3,
                ),
                decoration: BoxDecoration(
                  color: urgent ? scheme.error.withValues(alpha: 0.12) : null,
                  border: Border.all(
                    color: urgent
                        ? scheme.error
                        : scheme.onSurface.withValues(alpha: 0.2),
                  ),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  'Còn $left ngày',
                  style: TextStyle(fontSize: 12, color: chipColor),
                ),
              ),
            ],
          ),
          if (sub.isNotEmpty)
            Text(sub, style: TextStyle(fontSize: 12, color: theme.textMuted)),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            spacing: 8,
            children: [
              TextButton(
                key: ValueKey('purge-${c.id}'),
                onPressed: onPurge,
                style: TextButton.styleFrom(
                  foregroundColor: scheme.error,
                  minimumSize: const Size(0, 48),
                ),
                child: const Text('Xoá hẳn'),
              ),
              urgent
                  ? OutlinedButton(
                      key: ValueKey('restore-${c.id}'),
                      onPressed: onRestore,
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size(0, 48),
                        side: BorderSide(color: scheme.primary),
                        foregroundColor: scheme.primary,
                      ),
                      child: const Text('Khôi phục'),
                    )
                  : FilledButton(
                      key: ValueKey('restore-${c.id}'),
                      onPressed: onRestore,
                      style: FilledButton.styleFrom(
                        minimumSize: const Size(0, 48),
                      ),
                      child: const Text('Khôi phục'),
                    ),
            ],
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';

import '../../../shared/theme/app_theme.dart';
import '../../../shared/widgets/tag.dart';
import '../models/task.dart';

extension TaskStatusLabel on TaskStatus {
  String get label => switch (this) {
        TaskStatus.prep => 'Chuẩn bị',
        TaskStatus.waiting => 'Chờ',
        TaskStatus.inProgress => 'Đang làm',
        TaskStatus.done => 'Xong',
        TaskStatus.unknown => 'Không rõ',
      };
}

/// Port TaskStatusBadge (calendar/TaskBadges.tsx): nền màu mờ /20, 10px w500.
class TaskStatusBadge extends StatelessWidget {
  const TaskStatusBadge(this.status, {super.key});

  final TaskStatus status;

  @override
  Widget build(BuildContext context) {
    Tag tonal(Color bg, Color fg, {double alpha = 0.2}) => Tag(
          label: status.label,
          color: bg,
          foregroundColor: fg,
          variant: TagVariant.tonal,
          backgroundAlpha: alpha,
          fontSize: 10,
          fontWeight: FontWeight.w500,
        );
    return switch (status) {
      // bg-white/10 text-white/60 — dùng luôn cho giá trị lạ, giống fallback web.
      TaskStatus.prep || TaskStatus.unknown => tonal(Colors.white, Colors.white.withValues(alpha: 0.6), alpha: 0.1),
      TaskStatus.waiting => tonal(AppColors.yugen500, AppColors.yugen300),
      TaskStatus.inProgress => tonal(AppColors.kincha400, AppColors.kincha400),
      TaskStatus.done => tonal(AppColors.emerald400, AppColors.emerald300),
    };
  }
}

/// Nhãn mức quan trọng (1–3), dùng chung cho tag và lựa chọn trong form.
String importanceLabel(int importance) => switch (importance) {
      3 => 'Cao',
      2 => 'TB',
      _ => 'Thấp',
    };

/// Port ImportanceTag: nền đặc, px-1.5, không tracking. 3 = Cao (shuiro/trắng),
/// 2 = TB (kincha/ink-950), 1 = Thấp (yugen/trắng); giá trị lạ → như 1 (giống web).
class ImportanceTag extends StatelessWidget {
  const ImportanceTag(this.importance, {super.key});

  final int importance;

  @override
  Widget build(BuildContext context) {
    final (bg, fg) = switch (importance) {
      3 => (AppColors.shuiro500, Colors.white),
      2 => (AppColors.kincha400, AppColors.ink950),
      _ => (AppColors.yugen500, Colors.white),
    };
    return Tag(
      label: importanceLabel(importance),
      color: bg,
      foregroundColor: fg,
      variant: TagVariant.solid,
      fontSize: 10,
      fontWeight: FontWeight.w500,
      letterSpacingEm: 0,
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
    );
  }
}

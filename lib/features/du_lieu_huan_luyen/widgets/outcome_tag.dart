import 'package:flutter/material.dart';

import '../../../shared/theme/app_theme.dart';
import '../../../shared/widgets/tag.dart';
import '../models/training_log.dart';

/// Nhãn outcome của một dòng log.
class OutcomeTag extends StatelessWidget {
  const OutcomeTag(this.outcome, {super.key});

  final LogOutcome outcome;

  @override
  Widget build(BuildContext context) => switch (outcome) {
        LogOutcome.accepted => Tag(label: outcome.label, color: AppColors.emerald400, foregroundColor: AppColors.emerald300),
        LogOutcome.corrected => Tag(label: outcome.label, color: AppColors.kincha400),
        LogOutcome.rejected => Tag(label: outcome.label, color: AppColors.shuiro500),
        LogOutcome.retried => Tag(label: outcome.label, color: AppColors.yugen500, foregroundColor: AppColors.yugen300),
        LogOutcome.unknown =>
          Tag(label: outcome.label, color: Colors.white, foregroundColor: Colors.white.withValues(alpha: 0.6), borderAlpha: 0.2),
      };
}

/// Tool thành công / lỗi / không chạy tool.
class ToolStatus extends StatelessWidget {
  const ToolStatus({super.key, required this.toolName, required this.toolOk});

  final String? toolName;
  final bool? toolOk;

  @override
  Widget build(BuildContext context) {
    if (toolName == null && toolOk == null) return const SizedBox.shrink();
    final (icon, color, label) = switch (toolOk) {
      true => (Icons.check_circle_outline, AppColors.emerald300, 'Tool OK'),
      false => (Icons.error_outline, AppColors.shuiro500, 'Tool lỗi'),
      null => (Icons.remove_circle_outline, Colors.white54, 'Tool chưa chạy'),
    };
    return Row(mainAxisSize: MainAxisSize.min, children: [
      Icon(icon, size: 14, color: color),
      const SizedBox(width: 4),
      Text(label, style: TextStyle(fontSize: 11, color: color)),
    ]);
  }
}

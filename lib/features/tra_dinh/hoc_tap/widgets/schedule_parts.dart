import 'package:flutter/material.dart';

import '../../../../shared/theme/app_theme.dart';
import '../../../../shared/utils/date_format.dart';
import '../models/study_schedule.dart';
import 'hoc_tap_common.dart';

/// Bottom sheet so sánh từng khóa với kế hoạch gốc: gốc, dự kiến, sớm/trễ.
Future<void> showBaselineSheet(BuildContext context, List<BaselineEntry> entries) => showModalBottomSheet<void>(
  context: context,
  isScrollControlled: true,
  builder: (context) => SafeArea(
    child: Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: 12,
        children: [
          const HocTapSectionTitle('So với kế hoạch gốc'),
          if (entries.isEmpty) Text('Chưa có khóa nào để so sánh.', style: TextStyle(color: Theme.of(context).textMuted)),
          for (final e in entries) _BaselineRow(entry: e),
        ],
      ),
    ),
  ),
);

class _BaselineRow extends StatelessWidget {
  const _BaselineRow({required this.entry});

  final BaselineEntry entry;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final delta = deltaLabel(entry.deltaDays);
    return Column(
      key: ValueKey('baseline-${entry.courseId}'),
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 2,
      children: [
        Text(entry.courseTitle, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
        Text(
          'Gốc ${entry.baselineFinishDate == null ? '—' : formatDayMonth(entry.baselineFinishDate!)} · '
          'Dự kiến ${entry.forecastFinishDate == null ? '—' : formatDayMonth(entry.forecastFinishDate!)}',
          style: TextStyle(fontSize: 13, color: theme.textMuted),
        ),
        if (delta != null) Text(delta, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: deltaColor(context, entry.deltaDays!))),
      ],
    );
  }
}

/// Banner so với kế hoạch gốc của khóa ACTIVE: sớm (màu ngọc) / đúng kế hoạch / trễ (màu cảnh báo). Ẩn nếu không có mốc.
class BaselineBanner extends StatelessWidget {
  const BaselineBanner({super.key, required this.summary, this.goalMinutes});

  final ScheduleSummary summary;
  final int? goalMinutes;

  @override
  Widget build(BuildContext context) {
    final delta = summary.activeDelta;
    if (delta == null) return const SizedBox.shrink();
    final theme = Theme.of(context);
    final color = delta <= 0 ? theme.success : theme.colorScheme.error;
    final text = delta < 0 ? 'Đang sớm ${-delta} ngày so với kế hoạch gốc' : (delta == 0 ? 'Đúng kế hoạch' : 'Đang trễ $delta ngày so với kế hoạch gốc');
    return Container(
      key: const ValueKey('baseline-banner'),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: color.withValues(alpha: 0.12), border: Border.all(color: color.withValues(alpha: 0.5)), borderRadius: BorderRadius.circular(AppTheme.darkRadius)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 2,
        children: [
          Text(text, style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: color)),
          if (goalMinutes != null) Text('Mỗi ngày vẫn cần đủ $goalMinutes phút.', style: TextStyle(fontSize: 12, color: theme.textMuted)),
          Align(
            alignment: Alignment.centerLeft,
            child: TextButton(
              key: const ValueKey('baseline-link'),
              style: TextButton.styleFrom(padding: EdgeInsets.zero, minimumSize: const Size(0, 32), tapTargetSize: MaterialTapTargetSize.shrinkWrap),
              onPressed: () => showBaselineSheet(context, summary.vsBaseline),
              child: const Text('So với kế hoạch gốc'),
            ),
          ),
        ],
      ),
    );
  }
}

/// Khung chờ khi đang tải lịch.
class ScheduleSkeleton extends StatelessWidget {
  const ScheduleSkeleton({super.key, this.rows = 7});

  final int rows;

  @override
  Widget build(BuildContext context) => Column(
    key: const ValueKey('schedule-skeleton'),
    spacing: 8,
    children: [
      for (var i = 0; i < rows; i++)
        Container(height: 64, decoration: BoxDecoration(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.06), borderRadius: BorderRadius.circular(AppTheme.darkRadius))),
    ],
  );
}

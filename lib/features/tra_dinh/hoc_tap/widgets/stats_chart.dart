import 'package:flutter/material.dart';

import '../../../../shared/theme/app_theme.dart';
import '../../../../shared/utils/date_format.dart';
import '../models/study_stats.dart';
import '../utils/schedule_range.dart';

/// Biểu đồ cột phút theo ngày (hoặc tuần) tự vẽ bằng Container: cột đạt mục tiêu vàng đậm, chưa đạt vàng nhạt, 0 phút là
/// vạch mảnh; vạch ngang mờ là mục tiêu của từng bucket. Chạm cột để xem nhãn "ngày: X / Y phút".
class StatsBarChart extends StatefulWidget {
  const StatsBarChart({super.key, required this.series, required this.weekly, required this.summary});

  final List<StatsPoint> series;
  final bool weekly;

  /// Câu tóm tắt cho trình đọc màn hình.
  final String summary;

  /// Nhãn khi chạm một cột.
  static String pointLabel(StatsPoint p, {required bool weekly}) {
    final when = weekly ? 'Tuần ${formatDayMonth(p.start)} – ${formatDayMonth(addDays(p.start, 6))}' : formatDayMonth(p.start);
    return p.goalMinutes > 0 ? '$when: ${p.minutes} / ${p.goalMinutes} phút' : '$when: ${p.minutes} phút';
  }

  @override
  State<StatsBarChart> createState() => _StatsBarChartState();
}

class _StatsBarChartState extends State<StatsBarChart> {
  static const _height = 120.0;
  int? _selected;

  @override
  void didUpdateWidget(StatsBarChart old) {
    super.didUpdateWidget(old);
    if (old.series != widget.series) _selected = null;
  }

  List<int> _labelIndices(int n) {
    if (n <= 1) return [0];
    return {0, (n - 1) ~/ 3, (n - 1) * 2 ~/ 3, n - 1}.toList()..sort();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final series = widget.series;
    final peak = series.fold<int>(0, (m, p) => [m, p.minutes, p.goalMinutes].reduce((a, b) => a > b ? a : b));
    final scale = peak == 0 ? 1.0 : _height / peak;
    final selected = _selected != null && _selected! < series.length ? series[_selected!] : null;
    final gap = series.length > 45 ? 1.0 : 3.0;

    return Semantics(
      container: true,
      label: widget.summary,
      child: Column(
        key: const ValueKey('stats-chart'),
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: 6,
        children: [
          Text(
            selected == null ? 'Chạm vào một cột để xem chi tiết' : StatsBarChart.pointLabel(selected, weekly: widget.weekly),
            key: const ValueKey('chart-label'),
            style: TextStyle(fontSize: 12, fontWeight: selected == null ? FontWeight.w400 : FontWeight.w600, color: selected == null ? theme.textFaint : theme.colorScheme.onSurface),
          ),
          SizedBox(
            height: _height,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              spacing: gap,
              children: [
                for (final (i, p) in series.indexed)
                  Expanded(
                    child: GestureDetector(
                      key: ValueKey('bar-slot-$i'),
                      behavior: HitTestBehavior.opaque,
                      onTap: () => setState(() => _selected = i),
                      child: Stack(
                        alignment: Alignment.bottomCenter,
                        children: [
                          if (p.goalMinutes > 0) Positioned(left: 0, right: 0, bottom: p.goalMinutes * scale, child: Container(key: ValueKey('goal-tick-$i'), height: 1.5, color: theme.textFaint)),
                          Container(
                            key: ValueKey('bar-$i'),
                            height: p.minutes > 0 ? (p.minutes * scale).clamp(3.0, _height) : 2.0,
                            decoration: BoxDecoration(
                              color: p.minutes == 0 ? theme.textFaint : (p.reachedGoal ? AppColors.kincha400 : AppColors.kincha400.withValues(alpha: 0.35)),
                              borderRadius: BorderRadius.circular(2),
                              border: _selected == i ? Border.all(color: theme.colorScheme.onSurface, width: 1.5) : null,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
          if (series.isNotEmpty)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [for (final i in _labelIndices(series.length)) Text(formatDayMonth(series[i].start), style: TextStyle(fontSize: 11, color: theme.textMuted))],
            ),
        ],
      ),
    );
  }
}

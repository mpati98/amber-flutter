import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../shared/utils/date_format.dart';
import '../../../shared/utils/vn_time.dart';
import '../models/task.dart';
import '../utils/timeline.dart';
import 'task_detail_sheet.dart';

const _rowHeight = 56.0;
const _headerHeight = 32.0;
const _barHeight = 28.0;
const _minDayWidth = 22.0;

/// Bề rộng cột nhãn: ~150 ở bề hẹp, tới 240 ở bề rộng.
double timelineLabelWidth(double available) => available < 600 ? 150 : (available < 900 ? 200 : 240);

/// Màu thanh theo trạng thái, lấy từ theme và khác nhau cả về độ sáng:
/// Chờ (xám mờ, tối nhất) < Thẩm định (secondary, vừa) < Đang làm (primary, sáng nhất); Xong là kiểu viền.
({Color? fill, Color text, Color border}) _statusStyle(ColorScheme cs, TaskStatus s) => switch (s) {
      TaskStatus.inProgress => (fill: cs.primary, text: cs.onPrimary, border: cs.primary),
      TaskStatus.review => (fill: cs.secondary, text: cs.onSecondary, border: cs.secondary),
      TaskStatus.done => (fill: null, text: cs.onSurface.withValues(alpha: 0.5), border: cs.onSurface.withValues(alpha: 0.5)),
      _ => (fill: cs.onSurface.withValues(alpha: 0.22), text: cs.onSurface, border: cs.onSurface.withValues(alpha: 0.35)),
    };

/// Ngày dùng để xếp / đặt dấu mốc: việc mốc đặt tại hạn.
String? _anchor(Task t) => t.dueDate ?? t.startDate;

String? _rangeLabel(Task t) {
  final a = t.startDate, b = t.dueDate;
  if (a != null && b != null && a != b) return '${formatDayMonth(a)} – ${formatDayMonth(b)}';
  final one = b ?? a;
  return one == null ? null : formatDayMonth(one);
}

/// Tab Lịch: lưới tuần với một dòng mỗi việc có ngày, cột nhãn cố định bên trái, lưới cuộn ngang.
/// Chỉ để xem (không kéo thả); chạm nhãn / thanh mở trang chi tiết việc.
class TaskTimeline extends StatelessWidget {
  const TaskTimeline({super.key, required this.projectId, required this.tasks, this.projectStart, this.projectEnd});

  final String projectId;
  final List<Task> tasks;
  final String? projectStart;
  final String? projectEnd;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final muted = TextStyle(fontSize: 12, color: cs.onSurface.withValues(alpha: 0.6));
    final dated = tasks.where((t) => t.startDate != null || t.dueDate != null).toList()
      ..sort((a, b) {
        final c = (a.startDate ?? a.dueDate!).compareTo(b.startDate ?? b.dueDate!);
        if (c != 0) return c;
        final d = (a.dueDate ?? a.startDate!).compareTo(b.dueDate ?? b.startDate!);
        return d != 0 ? d : a.title.compareTo(b.title);
      });
    final unscheduled = tasks.where((t) => t.startDate == null && t.dueDate == null).toList();
    final today = vnToday();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: 16,
      children: [
        if (dated.isEmpty)
          Text('Chưa có việc nào có ngày.', style: muted)
        else ...[
          const _Legend(),
          _Grid(
            projectId: projectId,
            tasks: dated,
            window: computeTimelineWindow(
              projectStart: projectStart,
              projectEnd: projectEnd,
              taskDates: [for (final t in dated) (start: t.startDate, due: t.dueDate)],
              today: today,
            ),
            today: today,
          ),
        ],
        if (unscheduled.isNotEmpty) _Unscheduled(projectId: projectId, tasks: unscheduled),
      ],
    );
  }
}

class _Legend extends StatelessWidget {
  const _Legend();

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final muted = TextStyle(fontSize: 12, color: cs.onSurface.withValues(alpha: 0.7));
    Widget item(String label, Widget swatch) => Row(mainAxisSize: MainAxisSize.min, spacing: 6, children: [swatch, Text(label, style: muted)]);
    Widget swatch(TaskStatus s) {
      final st = _statusStyle(cs, s);
      return Container(
        width: 14,
        height: 10,
        decoration: BoxDecoration(color: st.fill, border: Border.all(color: st.border), borderRadius: BorderRadius.circular(2)),
      );
    }

    return Wrap(
      spacing: 14,
      runSpacing: 6,
      children: [
        for (final s in const [TaskStatus.prep, TaskStatus.inProgress, TaskStatus.review, TaskStatus.done]) item(s.label, swatch(s)),
        item('Mốc', _Diamond(color: cs.onSurface.withValues(alpha: 0.8), filled: true, size: 10)),
      ],
    );
  }
}

class _Diamond extends StatelessWidget {
  const _Diamond({required this.color, required this.filled, this.size = 16});

  final Color color;
  final bool filled;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Transform.rotate(
      angle: math.pi / 4,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(color: filled ? color : null, border: Border.all(color: color, width: 1.5)),
      ),
    );
  }
}

class _Grid extends StatefulWidget {
  const _Grid({required this.projectId, required this.tasks, required this.window, required this.today});

  final String projectId;
  final List<Task> tasks;
  final TimelineWindow window;
  final String today;

  @override
  State<_Grid> createState() => _GridState();
}

class _GridState extends State<_Grid> {
  ScrollController? _scroll;

  @override
  void dispose() {
    _scroll?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final window = widget.window;
    return LayoutBuilder(
      builder: (context, constraints) {
        final labelW = timelineLabelWidth(constraints.maxWidth);
        final gridAvail = math.max(0.0, constraints.maxWidth - labelW);
        // Màn rộng: lưới giãn cho vừa khung; hẹp: mỗi ngày tối thiểu _minDayWidth rồi cuộn ngang.
        final dayW = math.max(_minDayWidth, gridAvail / window.days);
        final totalW = dayW * window.days;
        // Lần đầu mở: cuộn để thấy tuần hiện tại (kèm 1 tuần trước nó).
        _scroll ??= ScrollController(
          initialScrollOffset: math.max(
            0.0,
            math.min(math.max(0.0, totalW - gridAvail), (window.offsetOf(mondayOf(widget.today)) - 7) * dayW),
          ),
        );
        final todayIdx = window.offsetOf(widget.today);
        final currentWeek = window.offsetOf(mondayOf(widget.today)) ~/ 7;
        final height = _headerHeight + _rowHeight * widget.tasks.length;

        return SizedBox(
          height: height,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: labelW,
                child: Column(
                  children: [
                    const SizedBox(height: _headerHeight),
                    for (final t in widget.tasks) _LabelCell(projectId: widget.projectId, task: t),
                  ],
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  controller: _scroll,
                  scrollDirection: Axis.horizontal,
                  child: SizedBox(
                    width: totalW,
                    height: height,
                    child: Stack(
                      children: [
                        // Hàng đầu: mỗi tuần một ô, ghi ngày thứ Hai.
                        for (var w = 0; w < window.weeks; w++)
                          Positioned(
                            left: w * 7 * dayW,
                            top: 0,
                            width: 7 * dayW,
                            height: _headerHeight,
                            child: Container(
                              alignment: Alignment.centerLeft,
                              padding: const EdgeInsets.only(left: 6),
                              decoration: BoxDecoration(
                                color: w == currentWeek ? cs.primary.withValues(alpha: 0.18) : null,
                                border: Border(left: BorderSide(color: cs.onSurface.withValues(alpha: 0.12))),
                              ),
                              child: Text(
                                formatDayMonth(window.weekStart(w)),
                                key: ValueKey('week-$w'),
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: w == currentWeek ? FontWeight.w700 : FontWeight.w400,
                                  color: w == currentWeek ? cs.primary : cs.onSurface.withValues(alpha: 0.6),
                                ),
                              ),
                            ),
                          ),
                        // Đường kẻ ngang giữa các dòng.
                        for (var r = 0; r < widget.tasks.length; r++)
                          Positioned(
                            left: 0,
                            right: 0,
                            top: _headerHeight + r * _rowHeight,
                            height: _rowHeight,
                            child: DecoratedBox(
                              decoration: BoxDecoration(border: Border(top: BorderSide(color: cs.onSurface.withValues(alpha: 0.08)))),
                            ),
                          ),
                        for (var r = 0; r < widget.tasks.length; r++)
                          ..._rowShapes(context, widget.tasks[r], r, dayW, window),
                        // Vạch dọc "hôm nay".
                        if (todayIdx >= 0 && todayIdx < window.days)
                          Positioned(
                            key: const ValueKey('today-line'),
                            left: (todayIdx + 0.5) * dayW - 1,
                            top: 0,
                            bottom: 0,
                            width: 2,
                            child: IgnorePointer(child: ColoredBox(color: cs.error.withValues(alpha: 0.7))),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  List<Widget> _rowShapes(BuildContext context, Task t, int row, double dayW, TimelineWindow window) {
    final cs = Theme.of(context).colorScheme;
    final st = _statusStyle(cs, t.status);
    final top = _headerHeight + row * _rowHeight;
    void open() => showTaskDetail(context, projectId: widget.projectId, taskId: t.id);

    if (t.isMilestone) {
      final at = _anchor(t)!;
      if (!window.contains(at)) return const [];
      const size = 16.0;
      return [
        Positioned(
          left: (window.offsetOf(at) + 0.5) * dayW - size / 2 - 4,
          top: top + (_rowHeight - size) / 2 - 4,
          width: size + 8,
          height: size + 8,
          child: Semantics(
            button: true,
            label: 'Mốc ${t.title}',
            child: GestureDetector(
              key: ValueKey('milestone-${t.id}'),
              behavior: HitTestBehavior.opaque,
              onTap: open,
              child: Center(
                child: _Diamond(color: t.status == TaskStatus.done ? st.border : (st.fill ?? st.border), filled: t.status != TaskStatus.done),
              ),
            ),
          ),
        ),
      ];
    }

    final bar = timelineBar(t.startDate, t.dueDate, window);
    if (bar == null) return const [];
    final width = math.max(10.0, bar.length * dayW - 2);
    return [
      Positioned(
        left: bar.offset * dayW + 1,
        top: top + (_rowHeight - _barHeight) / 2,
        width: width,
        height: _barHeight,
        child: Semantics(
          button: true,
          label: '${t.title}, ${t.status.label}',
          child: InkWell(
            key: ValueKey('bar-${t.id}'),
            onTap: open,
            borderRadius: BorderRadius.circular(4),
            child: Ink(
              decoration: BoxDecoration(
                color: st.fill,
                border: Border.all(color: st.border),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Center(
                // Đủ rộng thì ghi tên trạng thái bên trong thanh.
                child: width >= 72
                    ? Text(
                        t.status.label,
                        maxLines: 1,
                        overflow: TextOverflow.clip,
                        style: TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: st.text),
                      )
                    : const SizedBox.shrink(),
              ),
            ),
          ),
        ),
      ),
    ];
  }
}

class _LabelCell extends StatelessWidget {
  const _LabelCell({required this.projectId, required this.task});

  final String projectId;
  final Task task;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final attention = task.attention;
    final sub = attention?.label ?? _rangeLabel(task) ?? '';
    return SizedBox(
      key: ValueKey('timeline-row-${task.id}'),
      height: _rowHeight,
      child: InkWell(
        onTap: () => showTaskDetail(context, projectId: projectId, taskId: task.id),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                task.title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(fontSize: 13, height: 1.15, color: cs.onSurface),
              ),
              if (sub.isNotEmpty)
                Text(
                  sub,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 11,
                    color: attention != null ? cs.error : cs.onSurface.withValues(alpha: 0.6),
                    fontWeight: attention != null ? FontWeight.w500 : FontWeight.w400,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Unscheduled extends StatelessWidget {
  const _Unscheduled({required this.projectId, required this.tasks});

  final String projectId;
  final List<Task> tasks;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final muted = TextStyle(fontSize: 12, color: cs.onSurface.withValues(alpha: 0.6));
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text('Chưa xếp lịch', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: cs.primary)),
        const SizedBox(height: 4),
        for (final t in tasks)
          InkWell(
            key: ValueKey('unscheduled-${t.id}'),
            onTap: () => showTaskDetail(context, projectId: projectId, taskId: t.id),
            child: ConstrainedBox(
              constraints: const BoxConstraints(minHeight: 44),
              child: Row(
                spacing: 8,
                children: [
                  Expanded(child: Text(t.title, maxLines: 2, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 14, color: cs.onSurface))),
                  Text(t.status.label, style: muted),
                ],
              ),
            ),
          ),
      ],
    );
  }
}

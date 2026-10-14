import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../shared/widgets/scroll_card.dart';
import '../models/routine.dart';
import '../providers/nghi_su_duong_provider.dart';
import '../utils/workout_form.dart';
import 'routine_form.dart';
import 'workout_log_sheet.dart';

/// Dòng phụ: lịch lặp, "nghỉ hôm nay" nếu không đến hạn, rồi "chuỗi n ngày".
String routineSubtitle(Routine r) => [
      weekdaysLabel(r.weekdays),
      if (!r.dueToday) 'nghỉ hôm nay',
      'chuỗi ${r.streak} ngày',
    ].join(' · ');

/// Thẻ "Việc hằng ngày": đếm đã làm / đến hạn hôm nay, mỗi việc một dòng (tick, tên, lịch, 7 ô, sửa).
class RoutinesCard extends ConsumerWidget {
  const RoutinesCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = Theme.of(context).colorScheme;
    final muted = TextStyle(fontSize: 12, color: cs.onSurface.withValues(alpha: 0.6));
    final async = ref.watch(routinesProvider);
    final routines = async.value;
    final dueCount = routines?.where((r) => r.dueToday).length ?? 0;
    final doneCount = routines?.where((r) => r.dueToday && r.doneToday).length ?? 0;

    return ScrollCard(
      glow: ScrollCardGlow.kincha,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: 8,
        children: [
          Row(
            children: [
              Expanded(
                child: Wrap(
                  spacing: 8,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Text('Việc hằng ngày', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: cs.primary)),
                    if (routines != null) Text('$doneCount / $dueCount hôm nay', style: muted),
                  ],
                ),
              ),
              TextButton.icon(
                onPressed: () => showRoutineForm(context),
                icon: const Icon(Icons.add, size: 18),
                label: const Text('Thêm'),
              ),
            ],
          ),
          if (routines == null)
            Text(async.hasError ? 'Không tải được việc hằng ngày.' : 'Đang tải...', style: muted)
          else if (routines.isEmpty)
            Text('Chưa có việc hằng ngày nào.', style: muted)
          else
            for (final r in routines) _RoutineRow(key: ValueKey('routine-${r.id}'), routine: r),
          Text('7 ngày gần nhất · ô cuối là hôm nay', style: muted),
        ],
      ),
    );
  }
}

class _RoutineRow extends ConsumerStatefulWidget {
  const _RoutineRow({super.key, required this.routine});

  final Routine routine;

  @override
  ConsumerState<_RoutineRow> createState() => _RoutineRowState();
}

class _RoutineRowState extends ConsumerState<_RoutineRow> {
  bool _sending = false;

  Future<void> _toggle(bool done) async {
    if (_sending) return;
    setState(() => _sending = true); // khoá dòng trong lúc gửi
    try {
      await ref.read(routinesProvider.notifier).setDoneToday(widget.routine, done);
    } catch (e) {
      if (mounted) {
        final message = routineErrorMessage(e, 'Không cập nhật được việc hằng ngày, thử lại nhé.');
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
      }
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final r = widget.routine;
    final dim = r.dueToday ? 1.0 : 0.5;
    final workout = r.isWorkout;
    final study = r.isStudy;
    // WORKOUT: bấm vào việc (đến hạn hôm nay) mở sheet ghi buổi tập thay vì tick.
    final openSheet = workout && r.dueToday ? () => showWorkoutLogSheet(context, r) : null;
    final body = Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 4,
        children: [
          Text(
            r.name,
            style: TextStyle(
              fontSize: 14,
              color: cs.onSurface.withValues(alpha: dim),
              decoration: r.doneToday && !workout ? TextDecoration.lineThrough : null,
            ),
          ),
          if (study)
            Text(
              '${r.todayMinutes ?? 0} / ${r.goalMinutes ?? 0} phút',
              key: ValueKey('study-progress-${r.id}'),
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: cs.primary),
            ),
          if (workout && r.doneToday)
            Text(
              workoutSummary(r.todayLog),
              key: ValueKey('workout-summary-${r.id}'),
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: cs.primary),
            ),
          Text(routineSubtitle(r), style: TextStyle(fontSize: 12, color: cs.onSurface.withValues(alpha: 0.6 * dim + 0.1))),
          _WeekDots(routine: r),
        ],
      ),
    );
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (study)
          // Không tick tay: tự tính từ nhật ký học; bấm vào việc → màn Học tập của Trà Đình.
          Padding(
            padding: const EdgeInsets.all(12),
            child: Icon(r.doneToday ? Icons.check_circle : Icons.school_outlined, key: ValueKey('study-icon-${r.id}'), color: r.doneToday ? cs.primary : null),
          )
        else if (workout)
          IconButton(
            key: ValueKey('workout-open-${r.id}'),
            tooltip: r.doneToday ? 'Sửa buổi tập hôm nay' : 'Ghi buổi tập hôm nay',
            onPressed: openSheet,
            color: r.doneToday ? cs.primary : null,
            icon: Icon(r.doneToday ? Icons.check_circle : Icons.fitness_center_outlined),
          )
        else
          Checkbox(
            // Chỉ tick được khi đến hạn hôm nay.
            value: r.doneToday,
            onChanged: r.dueToday && !_sending ? (v) => _toggle(v ?? false) : null,
          ),
        Expanded(
          child: study
              ? InkWell(key: ValueKey('study-open-${r.id}'), onTap: () => context.push('/tra-dinh'), child: body)
              : openSheet == null
                  ? body
                  : InkWell(onTap: openSheet, child: body),
        ),
        IconButton(
          tooltip: 'Sửa việc hằng ngày',
          visualDensity: VisualDensity.compact,
          onPressed: () => showRoutineForm(context, routine: r),
          icon: const Icon(Icons.edit_outlined),
        ),
      ],
    );
  }
}

/// 7 ô nhỏ theo last7: đã làm → tô đầy; đến hạn mà chưa làm → chỉ viền; không đến hạn → rất mờ.
/// Ô cuối (hôm nay) viền đậm hơn.
class _WeekDots extends StatelessWidget {
  const _WeekDots({required this.routine});

  final Routine routine;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final days = routine.last7;
    final doneCount = days.where((d) => d.done).length;
    return Semantics(
      label: '$doneCount trên ${days.length} ngày gần nhất',
      child: ExcludeSemantics(
        child: Row(
          key: ValueKey('dots-${routine.id}'),
          mainAxisSize: MainAxisSize.min,
          spacing: 4,
          children: [
            for (final (i, d) in days.indexed)
              Container(
                key: ValueKey('dot-${routine.id}-$i'),
                width: 14,
                height: 14,
                decoration: BoxDecoration(
                  color: d.done ? cs.primary : null,
                  borderRadius: BorderRadius.circular(3),
                  border: Border.all(
                    color: d.due || d.done ? cs.primary.withValues(alpha: d.done ? 1 : 0.6) : cs.onSurface.withValues(alpha: 0.1),
                    width: i == days.length - 1 ? 2.2 : 1,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

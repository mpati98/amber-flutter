import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/utils/api_error.dart';
import '../../../shared/widgets/scroll_card.dart';
import '../models/routine.dart';
import '../providers/nghi_su_duong_provider.dart';
import 'routine_form.dart';

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
        final message = apiErrorCode(e) == 'not_scheduled'
            ? 'Hôm nay không phải ngày của việc này.'
            : apiErrorMessage(e, 'Không cập nhật được việc hằng ngày, thử lại nhé.');
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
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Checkbox(
          // Chỉ tick được khi đến hạn hôm nay.
          value: r.doneToday,
          onChanged: r.dueToday && !_sending ? (v) => _toggle(v ?? false) : null,
        ),
        Expanded(
          child: Padding(
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
                    decoration: r.doneToday ? TextDecoration.lineThrough : null,
                  ),
                ),
                Text(routineSubtitle(r), style: TextStyle(fontSize: 12, color: cs.onSurface.withValues(alpha: 0.6 * dim + 0.1))),
                _WeekDots(routine: r),
              ],
            ),
          ),
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

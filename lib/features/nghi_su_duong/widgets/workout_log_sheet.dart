import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/widgets/form_bits.dart';
import '../models/routine.dart';
import '../providers/nghi_su_duong_provider.dart';
import '../utils/workout_form.dart';

/// Sheet ghi buổi tập hôm nay của routine WORKOUT. Mở bằng showFinanceSheet.
Future<void> showWorkoutLogSheet(BuildContext context, Routine routine) =>
    showFinanceSheet<void>(context, WorkoutLogSheet(routine: routine));

/// Một dòng bài tập: các ô nhập giữ controller riêng để xoá dòng giữa danh sách không làm lệch chữ.
class _Row {
  _Row(ExerciseDraft d, VoidCallback onChanged)
    : measure = d.measure,
      name = TextEditingController(text: d.name),
      sets = TextEditingController(text: d.sets),
      reps = TextEditingController(text: d.reps),
      seconds = TextEditingController(text: d.seconds) {
    for (final c in [name, sets, reps, seconds]) {
      c.addListener(onChanged);
    }
  }

  final Object id = Object();
  ExerciseMeasure measure;
  final TextEditingController name, sets, reps, seconds;

  ExerciseDraft get draft => ExerciseDraft(
    name: name.text,
    measure: measure,
    sets: sets.text,
    reps: reps.text,
    seconds: seconds.text,
  );

  void dispose() {
    for (final c in [name, sets, reps, seconds]) {
      c.dispose();
    }
  }
}

class WorkoutLogSheet extends ConsumerStatefulWidget {
  const WorkoutLogSheet({super.key, required this.routine});

  final Routine routine;

  @override
  ConsumerState<WorkoutLogSheet> createState() => _WorkoutLogSheetState();
}

class _WorkoutLogSheetState extends ConsumerState<WorkoutLogSheet> {
  late final TextEditingController _minutes;
  late final List<_Row> _rows;
  bool _busy = false;
  bool _submitted = false; // chỉ hiện lỗi từng ô sau lần Lưu đầu tiên
  String? _error;

  bool get _hasLog => widget.routine.todayLog != null;

  @override
  void initState() {
    super.initState();
    // Đã có log hôm nay → sửa log đó. Chưa có → điền bài từ buổi gần nhất, để trống số phút.
    final log = widget.routine.todayLog;
    final source =
        log?.exercises ?? widget.routine.lastWorkout ?? const <Exercise>[];
    _minutes = TextEditingController(
      text: log?.durationMinutes?.toString() ?? '',
    )..addListener(_onEdited);
    _rows = [
      for (final e in source) _Row(ExerciseDraft.fromExercise(e), _onEdited),
    ];
  }

  /// Sau lần Lưu đầu, lỗi từng ô cập nhật theo lúc gõ.
  void _onEdited() {
    if (_submitted && mounted) setState(() {});
  }

  @override
  void dispose() {
    _minutes.dispose();
    for (final r in _rows) {
      r.dispose();
    }
    super.dispose();
  }

  WorkoutFormResult get _result => validateWorkoutForm(
    minutesText: _minutes.text,
    rows: [for (final r in _rows) r.draft],
  );

  Future<void> _save() async {
    if (_busy) return;
    setState(() => _submitted = true);
    final result = _result;
    if (!result.isValid) return;
    setState(() {
      _busy = true; // khoá ngay: bấm Lưu hai lần chỉ gửi một lần
      _error = null;
    });
    try {
      await ref
          .read(routinesProvider.notifier)
          .saveWorkout(
            widget.routine,
            durationMinutes: result.minutes!,
            exercises: result.exercises,
          );
      if (mounted) Navigator.of(context).pop();
    } catch (e) {
      if (mounted) {
        setState(() {
          _busy = false;
          _error = routineErrorMessage(
            e,
            'Không lưu được buổi tập, thử lại nhé.',
          );
        });
      }
    }
  }

  Future<void> _delete() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xoá buổi tập?'),
        content: const Text('Xoá buổi tập hôm nay cùng danh sách bài?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Huỷ'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('Xoá'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await ref
          .read(routinesProvider.notifier)
          .setDoneToday(widget.routine, false);
      if (mounted) Navigator.of(context).pop();
    } catch (e) {
      if (mounted) {
        setState(() {
          _busy = false;
          _error = routineErrorMessage(
            e,
            'Không xoá được buổi tập, thử lại nhé.',
          );
        });
      }
    }
  }

  void _addRow() =>
      setState(() => _rows.add(_Row(const ExerciseDraft(), _onEdited)));

  void _removeRow(int i) {
    final row = _rows[i];
    setState(() => _rows.removeAt(i));
    // Dòng còn nằm trên cây tới hết khung hình này — huỷ controller sau đó.
    WidgetsBinding.instance.addPostFrameCallback((_) => row.dispose());
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final muted = TextStyle(
      fontSize: 12,
      color: cs.onSurface.withValues(alpha: 0.6),
    );
    final result = _submitted ? _result : null;
    return FinanceSheetBody(
      title: _hasLog ? 'Sửa buổi tập hôm nay' : 'Ghi buổi tập hôm nay',
      children: [
        Text(
          widget.routine.name,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: cs.primary,
          ),
        ),
        TextField(
          key: const ValueKey('workout-minutes'),
          controller: _minutes,
          keyboardType: TextInputType.number,
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
            LengthLimitingTextInputFormatter(4),
          ],
          decoration: InputDecoration(
            labelText: 'Tổng số phút',
            errorText: result?.minutesError,
          ),
        ),
        Row(
          children: [
            Expanded(child: Text('Các bài đã tập', style: muted)),
            Text('${_rows.length} / $maxExercises', style: muted),
          ],
        ),
        for (final (i, r) in _rows.indexed)
          _ExerciseRow(
            key: ValueKey(r.id),
            index: i,
            row: r,
            error: result?.rowErrors[i],
            onMeasure: (m) => setState(() => r.measure = m),
            onRemove: _busy ? null : () => _removeRow(i),
          ),
        if (_rows.isEmpty)
          Text('Chưa có bài nào — chỉ ghi số phút cũng được.', style: muted),
        if (result?.listError != null)
          Text(result!.listError!, style: TextStyle(color: cs.error)),
        OutlinedButton.icon(
          key: const ValueKey('workout-add-row'),
          onPressed: _busy || _rows.length >= maxExercises ? null : _addRow,
          icon: const Icon(Icons.add, size: 18),
          label: const Text('Thêm bài'),
        ),
        sheetError(context, _error),
        FilledButton(
          onPressed: _busy ? null : _save,
          child: Text(_busy ? 'Đang lưu...' : 'Lưu'),
        ),
        if (_hasLog)
          OutlinedButton(
            onPressed: _busy ? null : _delete,
            style: OutlinedButton.styleFrom(
              foregroundColor: cs.error,
              side: BorderSide(color: cs.error),
            ),
            child: const Text('Xoá buổi tập'),
          ),
      ],
    );
  }
}

class _ExerciseRow extends StatelessWidget {
  const _ExerciseRow({
    super.key,
    required this.index,
    required this.row,
    required this.error,
    required this.onMeasure,
    required this.onRemove,
  });

  final int index;
  final _Row row;
  final String? error;
  final ValueChanged<ExerciseMeasure> onMeasure;
  final VoidCallback? onRemove;

  Widget _number(String key, TextEditingController c, String label) => Expanded(
    child: TextField(
      key: ValueKey('$key-$index'),
      controller: c,
      keyboardType: TextInputType.number,
      inputFormatters: [
        FilteringTextInputFormatter.digitsOnly,
        LengthLimitingTextInputFormatter(6),
      ],
      decoration: InputDecoration(labelText: label),
    ),
  );

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 8, 4, 12),
      decoration: BoxDecoration(
        border: Border.all(color: error == null ? cs.outlineVariant : cs.error),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: 8,
        children: [
          Row(
            children: [
              Expanded(
                child: TextField(
                  key: ValueKey('exercise-name-$index'),
                  controller: row.name,
                  maxLength: maxExerciseName,
                  decoration: const InputDecoration(
                    labelText: 'Tên bài',
                    counterText: '',
                  ),
                ),
              ),
              IconButton(
                tooltip: 'Xoá bài ${index + 1}',
                onPressed: onRemove,
                icon: const Icon(Icons.delete_outline),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceRow<ExerciseMeasure>(
              options: {for (final m in ExerciseMeasure.values) m: m.label},
              selected: row.measure,
              onSelected: onMeasure,
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: Row(
              spacing: 12,
              children: switch (row.measure) {
                ExerciseMeasure.reps => [
                  _number('exercise-reps', row.reps, 'Số lần'),
                ],
                ExerciseMeasure.setsReps => [
                  _number('exercise-sets', row.sets, 'Số hiệp'),
                  _number('exercise-reps', row.reps, 'Số lần'),
                ],
                ExerciseMeasure.duration => [
                  _number('exercise-seconds', row.seconds, 'Số giây'),
                ],
              },
            ),
          ),
          if (error != null)
            Text(error!, style: TextStyle(color: cs.error, fontSize: 12)),
        ],
      ),
    );
  }
}

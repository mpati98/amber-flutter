import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../shared/theme/app_theme.dart';
import '../../../../shared/widgets/form_bits.dart';
import '../../../nghi_su_duong/models/routine.dart' show weekdayShort;
import '../models/study_subject.dart';
import '../providers/hoc_tap_provider.dart';
import '../utils/hoc_tap_errors.dart';

/// Form môn học: thêm ([subjectId] null) hoặc sửa / xoá. Mở bằng showFinanceSheet.
Future<void> showSubjectSheet(BuildContext context, {String? subjectId}) =>
    showFinanceSheet<void>(context, SubjectSheet(subjectId: subjectId));

class SubjectSheet extends ConsumerStatefulWidget {
  const SubjectSheet({super.key, this.subjectId});

  final String? subjectId;

  @override
  ConsumerState<SubjectSheet> createState() => _SubjectSheetState();
}

class _SubjectSheetState extends ConsumerState<SubjectSheet> {
  final _name = TextEditingController();
  final _goal = TextEditingController();
  final _video = TextEditingController(text: '40');
  final Set<int> _review = {7};
  bool _loaded = false;
  bool _busy = false;
  String? _error;

  bool get _editing => widget.subjectId != null;

  @override
  void dispose() {
    _name.dispose();
    _goal.dispose();
    _video.dispose();
    super.dispose();
  }

  void _fill(StudySubject s) {
    _name.text = s.name;
    _goal.text = s.dailyGoalMinutes?.toString() ?? '';
    _video.text = s.videoMinutesPerDay.toString();
    _review
      ..clear()
      ..addAll(s.reviewWeekdays);
    _loaded = true;
  }

  int? _minutes(String text) {
    final n = int.tryParse(text.trim());
    return n != null && n >= 1 && n <= 1440 ? n : null;
  }

  Future<void> _save() async {
    final name = _name.text.trim();
    final goalText = _goal.text.trim();
    final goal = goalText.isEmpty ? null : _minutes(goalText);
    final video = _minutes(_video.text);
    if (name.isEmpty) return setState(() => _error = 'Nhập tên môn.');
    if (goalText.isNotEmpty && goal == null) return setState(() => _error = 'Mục tiêu mỗi ngày từ 1 đến 1440 phút (để trống nếu không đặt).');
    if (video == null) return setState(() => _error = 'Phút video mỗi ngày từ 1 đến 1440.');
    if (_review.length > 6) return setState(() => _error = 'Chọn tối đa 6 ngày ôn tập.');
    setState(() {
      _busy = true;
      _error = null;
    });
    final body = <String, Object?>{'name': name, 'dailyGoalMinutes': goal, 'videoMinutesPerDay': video, 'reviewWeekdays': (_review.toList()..sort())};
    try {
      final actions = ref.read(hocTapActionsProvider);
      if (_editing) {
        await actions.updateSubject(widget.subjectId!, body);
      } else {
        final created = await actions.createSubject(body);
        ref.read(selectedSubjectIdProvider.notifier).select(created.id);
      }
      if (mounted) Navigator.of(context).pop();
    } catch (e) {
      if (mounted) setState(() => (_busy = false, _error = hocTapErrorMessage(e)));
    }
  }

  Future<void> _delete() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xoá môn học?'),
        content: const Text('Xoá môn này cùng mọi khóa học, phần và nhật ký học của nó?'),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(false), child: const Text('Huỷ')),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: Theme.of(context).colorScheme.error),
            child: const Text('Xoá'),
          ),
        ],
      ),
    );
    if (ok != true || !mounted) return;
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await ref.read(hocTapActionsProvider).deleteSubject(widget.subjectId!);
      if (mounted) Navigator.of(context).pop();
    } catch (e) {
      if (mounted) setState(() => (_busy = false, _error = hocTapErrorMessage(e)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    if (_editing && !_loaded) {
      final subjects = ref.watch(studySubjectsProvider);
      final found = subjects.value?.where((s) => s.id == widget.subjectId).firstOrNull;
      if (found != null) _fill(found);
      if (!_loaded) {
        return FinanceSheetBody(
          title: 'Sửa môn học',
          children: [Padding(padding: const EdgeInsets.all(24), child: Center(child: subjects.hasError ? const Text('Không tải được môn học.') : const CircularProgressIndicator()))],
        );
      }
    }
    final muted = TextStyle(fontSize: 12, color: theme.textMuted);
    return FinanceSheetBody(
      title: _editing ? 'Sửa môn học' : 'Thêm môn học',
      children: [
        TextField(key: const ValueKey('subject-name'), controller: _name, maxLength: 100, decoration: const InputDecoration(labelText: 'Tên môn', counterText: '')),
        TextField(
          key: const ValueKey('subject-goal'),
          controller: _goal,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(labelText: 'Mục tiêu mỗi ngày (phút)', helperText: 'Để trống nếu không đặt mục tiêu'),
        ),
        TextField(
          key: const ValueKey('subject-video'),
          controller: _video,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(labelText: 'Video mỗi ngày (phút)', helperText: 'Phần còn lại của mục tiêu dành cho luyện tập'),
        ),
        Text('Ngày ôn tập (không xếp video)', style: muted),
        Wrap(
          spacing: 6,
          runSpacing: 6,
          children: [
            for (var d = 1; d <= 7; d++)
              FilterChip(
                key: ValueKey('review-$d'),
                label: Text(weekdayShort(d)),
                selected: _review.contains(d),
                showCheckmark: false,
                selectedColor: AppColors.kincha400,
                labelStyle: TextStyle(fontSize: 13, color: _review.contains(d) ? AppColors.ink950 : null),
                onSelected: (on) => setState(() => on ? _review.add(d) : _review.remove(d)),
              ),
          ],
        ),
        sheetError(context, _error),
        FilledButton(key: const ValueKey('subject-save'), onPressed: _busy ? null : _save, child: Text(_editing ? 'Lưu' : 'Thêm môn')),
        if (_editing)
          TextButton(
            key: const ValueKey('subject-delete'),
            onPressed: _busy ? null : _delete,
            style: TextButton.styleFrom(foregroundColor: theme.colorScheme.error),
            child: const Text('Xoá môn'),
          ),
      ],
    );
  }
}

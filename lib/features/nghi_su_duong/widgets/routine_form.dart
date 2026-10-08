import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/utils/api_error.dart';
import '../../../shared/widgets/form_bits.dart';
import '../models/routine.dart';
import '../providers/nghi_su_duong_provider.dart';
import '../services/nghi_su_duong_api.dart';

/// Form việc hằng ngày: thêm ([routine] null) hoặc sửa / xoá [routine]. Mở bằng showFinanceSheet.
Future<void> showRoutineForm(BuildContext context, {Routine? routine}) =>
    showFinanceSheet<void>(context, RoutineForm(routine: routine));

class RoutineForm extends ConsumerStatefulWidget {
  const RoutineForm({super.key, this.routine});

  final Routine? routine;

  @override
  ConsumerState<RoutineForm> createState() => _RoutineFormState();
}

class _RoutineFormState extends ConsumerState<RoutineForm> {
  late final _name = TextEditingController(text: widget.routine?.name ?? '');
  late final Set<int> _days = {...?widget.routine?.weekdays, if (widget.routine == null) ...const [1, 2, 3, 4, 5, 6, 7]};
  bool _busy = false;
  String? _nameError;
  String? _daysError;
  String? _error;

  bool get _editing => widget.routine != null;

  @override
  void initState() {
    super.initState();
    _name.addListener(() => setState(() => _nameError = null));
  }

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  List<int> get _sortedDays => _days.toList()..sort();

  /// Khi sửa: chỉ các trường khác bản gốc.
  Map<String, Object?> get _patch {
    final r = widget.routine!;
    final original = ({...r.weekdays}.toList()..sort());
    return {
      if (_name.text.trim() != r.name) 'name': _name.text.trim(),
      if (_sortedDays.join(',') != original.join(',')) 'weekdays': _sortedDays,
    };
  }

  bool get _canSave => !_busy && (!_editing || _patch.isNotEmpty);

  Future<void> _save() async {
    if (_busy) return;
    if (_name.text.trim().isEmpty) {
      setState(() => _nameError = 'Nhập tên việc.');
      return;
    }
    if (_days.isEmpty) {
      setState(() => _daysError = 'Chọn ít nhất một ngày trong tuần.');
      return;
    }
    setState(() {
      _busy = true; // khoá ngay: bấm Lưu hai lần chỉ gửi một lần
      _error = null;
    });
    try {
      final api = ref.read(nghiSuDuongApiProvider);
      if (_editing) {
        await api.updateRoutine(widget.routine!.id, _patch);
      } else {
        await api.createRoutine(name: _name.text.trim(), weekdays: _sortedDays);
      }
      ref.invalidate(routinesProvider);
      if (mounted) Navigator.of(context).pop();
    } catch (e) {
      if (mounted) {
        setState(() {
          _busy = false;
          _error = apiErrorMessage(e, 'Không lưu được việc, thử lại nhé.');
        });
      }
    }
  }

  Future<void> _delete() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xoá việc hằng ngày?'),
        content: const Text('Xoá việc này cùng lịch sử đã làm?'),
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
    if (confirmed != true || !mounted) return;
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await ref.read(nghiSuDuongApiProvider).deleteRoutine(widget.routine!.id);
      ref.invalidate(routinesProvider);
      if (mounted) Navigator.of(context).pop();
    } catch (e) {
      if (mounted) {
        setState(() {
          _busy = false;
          _error = apiErrorMessage(e, 'Không xoá được việc, thử lại nhé.');
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final muted = TextStyle(fontSize: 12, color: cs.onSurface.withValues(alpha: 0.6));
    return FinanceSheetBody(
      title: _editing ? 'Sửa việc hằng ngày' : 'Thêm việc hằng ngày',
      children: [
        TextField(
          controller: _name,
          maxLength: 255,
          decoration: InputDecoration(labelText: 'Tên việc', counterText: '', errorText: _nameError),
        ),
        Row(
          children: [
            Expanded(child: Text('Lặp lại vào', style: muted)),
            Text(_days.isEmpty ? 'Chưa chọn ngày' : weekdaysLabel(_days), style: muted),
          ],
        ),
        // 7 nút bật / tắt: Wrap để không tràn ở bề hẹp.
        Wrap(
          spacing: 6,
          runSpacing: 6,
          children: [
            for (final d in const [1, 2, 3, 4, 5, 6, 7])
              FilterChip(
                label: Text(weekdayShort(d)),
                selected: _days.contains(d),
                showCheckmark: false,
                onSelected: (on) => setState(() {
                  on ? _days.add(d) : _days.remove(d);
                  _daysError = null;
                }),
              ),
          ],
        ),
        if (_daysError != null) Text(_daysError!, style: TextStyle(color: cs.error)),
        sheetError(context, _error),
        FilledButton(onPressed: _canSave ? _save : null, child: Text(_busy ? 'Đang lưu...' : 'Lưu')),
        if (_editing)
          OutlinedButton(
            onPressed: _busy ? null : _delete,
            style: OutlinedButton.styleFrom(foregroundColor: cs.error, side: BorderSide(color: cs.error)),
            child: const Text('Xoá'),
          ),
      ],
    );
  }
}

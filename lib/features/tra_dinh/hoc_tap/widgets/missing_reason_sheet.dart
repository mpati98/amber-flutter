import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../shared/theme/app_theme.dart';
import '../../../../shared/utils/date_format.dart';
import '../../../../shared/widgets/form_bits.dart';
import '../models/study_enums.dart';
import '../providers/hoc_tap_provider.dart';
import '../services/hoc_tap_api.dart';
import '../utils/hoc_tap_errors.dart';
import 'log_sheet.dart';

/// Sheet hỏi lý do các ngày chưa đủ mục tiêu: lần lượt từng ngày (cũ trước). Xong hết thì đóng.
Future<void> showMissingReasonSheet(
  BuildContext context, {
  required String subjectId,
  required String subjectName,
  required int goalMinutes,
  required List<String> dates,
}) => showFinanceSheet<void>(context, MissingReasonSheet(subjectId: subjectId, subjectName: subjectName, goalMinutes: goalMinutes, dates: dates));

class MissingReasonSheet extends ConsumerStatefulWidget {
  const MissingReasonSheet({super.key, required this.subjectId, required this.subjectName, required this.goalMinutes, required this.dates});

  final String subjectId;
  final String subjectName;
  final int goalMinutes;
  final List<String> dates;

  @override
  ConsumerState<MissingReasonSheet> createState() => _MissingReasonSheetState();
}

class _MissingReasonSheetState extends ConsumerState<MissingReasonSheet> {
  late final List<String> _dates = [...widget.dates]..sort();
  final _text = TextEditingController();
  Map<String, int> _minutes = {};
  int _index = 0;
  ReasonCode? _reason;
  bool _busy = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _text.addListener(() => setState(() {}));
    _loadMinutes();
  }

  @override
  void dispose() {
    _text.dispose();
    super.dispose();
  }

  Future<void> _loadMinutes() async {
    if (_dates.isEmpty) return;
    try {
      final logs = await ref.read(hocTapApiProvider).getLogs(from: _dates.first, to: _dates.last, subjectId: widget.subjectId);
      final byDate = <String, int>{};
      for (final l in logs) {
        byDate[l.logDate] = (byDate[l.logDate] ?? 0) + l.minutes;
      }
      if (mounted) setState(() => _minutes = byDate);
    } catch (_) {
      // Không có số phút thì chỉ thiếu dòng "đã học X/Y"; vẫn ghi được lý do.
    }
  }

  void _advance() {
    if (_index >= _dates.length - 1) {
      Navigator.of(context).pop();
      return;
    }
    setState(() {
      _index++;
      _reason = null;
      _text.clear();
      _busy = false;
      _error = null;
    });
  }

  Future<void> _save() async {
    if (_busy || !reasonValid(_reason, _text.text)) return;
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      final text = _text.text.trim();
      await ref.read(hocTapActionsProvider).putReason(widget.subjectId, _dates[_index], code: _reason!, text: text.isEmpty ? null : text);
      if (mounted) _advance();
    } catch (e) {
      if (mounted) setState(() => (_busy = false, _error = hocTapErrorMessage(e)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    if (_dates.isEmpty) return FinanceSheetBody(title: 'Lý do chưa đủ mục tiêu', children: const [Text('Không còn ngày nào thiếu lý do.')]);
    final date = _dates[_index];
    final last = _index == _dates.length - 1;
    return FinanceSheetBody(
      title: 'Lý do chưa đủ mục tiêu',
      children: [
        Text('${widget.subjectName} · ngày ${_index + 1}/${_dates.length}', style: TextStyle(fontSize: 12, color: theme.textMuted)),
        Text(
          '${formatDayMonth(date)} · đã học ${_minutes[date] ?? 0}/${widget.goalMinutes} phút',
          key: const ValueKey('reason-day'),
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: AppColors.kincha400),
        ),
        Text('Hôm đó vì sao chưa đủ?', style: TextStyle(fontSize: 13, color: theme.textMuted)),
        ReasonPicker(selected: _reason, onSelected: (r) => setState(() => _reason = r), text: _text),
        sheetError(context, _error),
        FilledButton(key: const ValueKey('reason-save'), onPressed: !_busy && reasonValid(_reason, _text.text) ? _save : null, child: Text(last ? 'Lưu' : 'Lưu và tiếp')),
        TextButton(key: const ValueKey('reason-skip'), onPressed: _busy ? null : _advance, child: Text(last ? 'Để sau' : 'Bỏ qua ngày này')),
      ],
    );
  }
}

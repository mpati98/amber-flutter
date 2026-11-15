import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../../shared/utils/api_error.dart';
import '../../../shared/widgets/form_bits.dart';
import '../../../shared/widgets/list_frame.dart';
import '../models/sleep_log.dart';
import '../services/sleep_api.dart';
import '../utils/sleep_format.dart';

/// Mở form ghi / sửa giấc ngủ. Trả true khi đã lưu hoặc xoá.
Future<bool?> showSleepForm(BuildContext context, {required String today, SleepLog? existing}) =>
    showFinanceSheet<bool>(context, SleepFormSheet(today: today, existing: existing));

/// Form giấc ngủ: đêm nào (đêm qua / đêm trước / ngày đang sửa), giờ + phút, chất lượng, ghi chú.
class SleepFormSheet extends ConsumerStatefulWidget {
  const SleepFormSheet({super.key, required this.today, this.existing});

  final String today;
  final SleepLog? existing;

  @override
  ConsumerState<SleepFormSheet> createState() => _SleepFormSheetState();
}

class _SleepFormSheetState extends ConsumerState<SleepFormSheet> {
  late String _date = widget.existing?.date ?? widget.today;
  late final _hours = TextEditingController(text: widget.existing == null ? '' : '${widget.existing!.sleepMinutes ~/ 60}');
  late final _minutes = TextEditingController(text: widget.existing == null ? '' : '${widget.existing!.sleepMinutes % 60}');
  late final _note = TextEditingController(text: widget.existing?.note ?? '');
  late int _quality = widget.existing?.quality ?? 0; // 0 = không chấm
  bool _busy = false;
  String? _error;

  @override
  void dispose() {
    _hours.dispose();
    _minutes.dispose();
    _note.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final parsed = parseSleepInput(_hours.text, _minutes.text);
    if (parsed.error != null) return setState(() => _error = parsed.error);
    setState(() { _busy = true; _error = null; });
    try {
      await ref.read(sleepApiProvider).save(date: _date, sleepMinutes: parsed.minutes!, quality: _quality == 0 ? null : _quality, note: _note.text);
      if (mounted) Navigator.of(context).pop(true);
    } catch (e) {
      if (mounted) setState(() { _busy = false; _error = apiErrorMessage(e, 'Không lưu được giấc ngủ.'); });
    }
  }

  Future<void> _delete() async {
    setState(() { _busy = true; _error = null; });
    try {
      await ref.read(sleepApiProvider).delete(widget.existing!.date);
      if (mounted) Navigator.of(context).pop(true);
    } catch (e) {
      if (mounted) setState(() { _busy = false; _error = apiErrorMessage(e, 'Không xoá được.'); });
    }
  }

  @override
  Widget build(BuildContext context) {
    final yesterday = isoMinusDays(widget.today, 1);
    final dates = {
      widget.today: 'Đêm qua (dậy ${shortDate(widget.today)})',
      yesterday: 'Đêm trước (dậy ${shortDate(yesterday)})',
      if (widget.existing != null && widget.existing!.date != widget.today && widget.existing!.date != yesterday)
        widget.existing!.date: 'Dậy ngày ${shortDate(widget.existing!.date)}',
    };
    return FinanceSheetBody(
      title: widget.existing == null ? 'Ghi giấc ngủ' : 'Sửa giấc ngủ',
      children: [
        if (widget.existing == null)
          ChoiceRow<String>(options: dates, selected: _date, onSelected: (v) => setState(() => _date = v))
        else
          Text(dates[_date] ?? _date),
        Row(
          spacing: 10,
          children: [
            Expanded(
              child: TextField(
                key: const ValueKey('sleep-hours'),
                controller: _hours,
                keyboardType: TextInputType.number,
                decoration: designInput('Giờ (vd 7)'),
              ),
            ),
            Expanded(
              child: TextField(
                key: const ValueKey('sleep-minutes'),
                controller: _minutes,
                keyboardType: TextInputType.number,
                decoration: designInput('Phút (vd 30)'),
              ),
            ),
          ],
        ),
        const Text('Ngủ có ngon không?'),
        ChoiceRow<int>(options: const {0: 'Không chấm', ...sleepQualityLabels}, selected: _quality, onSelected: (v) => setState(() => _quality = v)),
        TextField(controller: _note, maxLength: 500, decoration: designInput('Ghi chú (tuỳ chọn)')),
        sheetError(context, _error),
        DesignButton.primary(label: _busy ? 'Đang lưu…' : 'Lưu', onPressed: _busy ? null : _save, minHeight: 44),
        if (widget.existing != null) DesignButton.outline(label: 'Xoá đêm này', onPressed: _busy ? null : _delete, minHeight: 40),
      ],
    );
  }
}

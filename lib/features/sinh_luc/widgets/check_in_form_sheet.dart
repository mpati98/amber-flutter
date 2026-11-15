import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../../shared/widgets/form_bits.dart';
import '../../../shared/widgets/list_frame.dart';
import '../models/health_inputs.dart';
import '../services/health_inputs_api.dart';
import '../utils/health_format.dart';
import '../utils/sleep_format.dart';

/// Mở form check-in trưa (`slot = 'noon'`) hoặc tối (`'evening'`). Trả true khi đã lưu hoặc xoá.
Future<bool?> showCheckInForm(BuildContext context, {required String today, required String slot, CheckIn? existing}) =>
    showFinanceSheet<bool>(context, CheckInFormSheet(today: today, slot: slot, existing: existing));

/// Trưa: tự chấm thể lực 1–5. Tối: phút tập, phút thể thao, ngày nghỉ hợp lệ. Ngày: hôm nay / hôm qua (sửa thì giữ ngày cũ).
/// Bỏ lỡ check-in không bị phạt — kinh tế dùng giá trị trung tính.
class CheckInFormSheet extends ConsumerStatefulWidget {
  const CheckInFormSheet({super.key, required this.today, required this.slot, this.existing});

  final String today;
  final String slot;
  final CheckIn? existing;

  @override
  ConsumerState<CheckInFormSheet> createState() => _CheckInFormSheetState();
}

class _CheckInFormSheetState extends ConsumerState<CheckInFormSheet> {
  late String _date = widget.existing?.date ?? widget.today;
  late int _stamina = widget.existing?.staminaSelf ?? 0; // 0 = chưa chọn
  late final _exercise = TextEditingController(text: widget.existing?.exerciseMinutes?.toString() ?? '');
  late final _sport = TextEditingController(text: widget.existing?.sportMinutes?.toString() ?? '');
  late bool _restDay = widget.existing?.restDay ?? false;
  bool _busy = false;
  String? _error;

  bool get _noon => widget.slot == 'noon';

  @override
  void dispose() {
    _exercise.dispose();
    _sport.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final api = ref.read(healthInputsApiProvider);
    Future<CheckIn> Function() call;
    if (_noon) {
      if (_stamina == 0) return setState(() => _error = 'Chọn mức thể lực.');
      call = () => api.saveNoon(date: _date, staminaSelf: _stamina);
    } else {
      final ex = parseOptionalMinutes(_exercise.text, 'Phút tập');
      final sp = parseOptionalMinutes(_sport.text, 'Phút thể thao');
      final err = ex.error ?? sp.error;
      if (err != null) return setState(() => _error = err);
      call = () => api.saveEvening(date: _date, exerciseMinutes: ex.minutes, sportMinutes: sp.minutes, restDay: _restDay);
    }
    setState(() { _busy = true; _error = null; });
    try {
      await call();
      if (mounted) Navigator.of(context).pop(true);
    } catch (e) {
      if (mounted) setState(() { _busy = false; _error = healthInputError(e, 'Không lưu được check-in.'); });
    }
  }

  Future<void> _delete() async {
    setState(() { _busy = true; _error = null; });
    try {
      await ref.read(healthInputsApiProvider).deleteCheckIn(widget.existing!.date, widget.slot);
      if (mounted) Navigator.of(context).pop(true);
    } catch (e) {
      if (mounted) setState(() { _busy = false; _error = healthInputError(e, 'Không xoá được.'); });
    }
  }

  @override
  Widget build(BuildContext context) {
    final yesterday = isoMinusDays(widget.today, 1);
    final dates = {widget.today: 'Hôm nay (${shortDate(widget.today)})', yesterday: 'Hôm qua (${shortDate(yesterday)})'};
    final what = _noon ? 'check-in trưa' : 'check-in tối';
    return FinanceSheetBody(
      title: widget.existing == null ? (_noon ? 'Check-in trưa' : 'Check-in tối') : 'Sửa $what',
      children: [
        if (widget.existing == null)
          ChoiceRow<String>(options: dates, selected: _date, onSelected: (v) => setState(() => _date = v))
        else
          Text(dates[_date] ?? 'Ngày ${shortDate(_date)}'),
        if (_noon) ...[
          const Text('Thể lực lúc này thế nào?'),
          ChoiceRow<int>(options: staminaSelfLabels, selected: _stamina, onSelected: (v) => setState(() => _stamina = v)),
        ] else ...[
          Row(
            spacing: 10,
            children: [
              Expanded(
                child: TextField(
                  key: const ValueKey('checkin-exercise'),
                  controller: _exercise,
                  enabled: !_restDay,
                  keyboardType: TextInputType.number,
                  decoration: designInput('Phút tập'),
                ),
              ),
              Expanded(
                child: TextField(
                  key: const ValueKey('checkin-sport'),
                  controller: _sport,
                  enabled: !_restDay,
                  keyboardType: TextInputType.number,
                  decoration: designInput('Phút thể thao'),
                ),
              ),
            ],
          ),
          const Text('Hôm nay là ngày nghỉ hợp lệ? (không bị tính thiếu vận động)'),
          ChoiceRow<bool>(options: const {false: 'Không', true: 'Ngày nghỉ'}, selected: _restDay, onSelected: (v) => setState(() => _restDay = v)),
        ],
        sheetError(context, _error),
        DesignButton.primary(label: _busy ? 'Đang lưu…' : 'Lưu', onPressed: _busy ? null : _save, minHeight: 44),
        if (widget.existing != null) DesignButton.outline(label: 'Xoá $what', onPressed: _busy ? null : _delete, minHeight: 40),
      ],
    );
  }
}

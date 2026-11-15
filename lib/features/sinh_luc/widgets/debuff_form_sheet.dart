import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../../shared/widgets/form_bits.dart';
import '../../../shared/widgets/list_frame.dart';
import '../models/health_inputs.dart';
import '../services/health_inputs_api.dart';
import '../utils/health_format.dart';
import '../utils/sleep_format.dart';

/// Mở form thêm / sửa debuff. Trả true khi đã lưu, đánh dấu khỏi, mở lại hoặc xoá.
Future<bool?> showDebuffForm(BuildContext context, {required String today, Debuff? existing}) =>
    showFinanceSheet<bool>(context, DebuffFormSheet(today: today, existing: existing));

/// Thêm: mức, tên (tuỳ chọn), bắt đầu từ lúc nào. Sửa: đổi mức / tên, "Đã khỏi" (hết từ bây giờ) hoặc "Mở lại", xoá nếu nhập nhầm.
/// Debuff chỉ nới luật (trừ Sức khoẻ, miễn phạt trễ hạn), không bao giờ phạt thêm.
class DebuffFormSheet extends ConsumerStatefulWidget {
  const DebuffFormSheet({super.key, required this.today, this.existing});

  final String today;
  final Debuff? existing;

  @override
  ConsumerState<DebuffFormSheet> createState() => _DebuffFormSheetState();
}

class _DebuffFormSheetState extends ConsumerState<DebuffFormSheet> {
  late String _level = widget.existing?.level ?? 'light';
  late final _label = TextEditingController(text: widget.existing?.label ?? '');
  String _start = 'now'; // now | today | yesterday
  bool _busy = false;
  String? _error;

  @override
  void dispose() {
    _label.dispose();
    super.dispose();
  }

  Future<void> _run(Future<void> Function() action, String fallback) async {
    setState(() { _busy = true; _error = null; });
    try {
      await action();
      if (mounted) Navigator.of(context).pop(true);
    } catch (e) {
      if (mounted) setState(() { _busy = false; _error = healthInputError(e, fallback); });
    }
  }

  /// Đầu ngày theo giờ VN (00:00 +07:00).
  String _dayStart(String iso) => '${iso}T00:00:00+07:00';

  Future<void> _save() {
    final api = ref.read(healthInputsApiProvider);
    final e = widget.existing;
    if (e == null) {
      final startedAt = switch (_start) {
        'today' => _dayStart(widget.today),
        'yesterday' => _dayStart(isoMinusDays(widget.today, 1)),
        _ => null,
      };
      return _run(() => api.createDebuff(level: _level, label: _label.text, startedAt: startedAt), 'Không lưu được debuff.');
    }
    return _run(() => api.updateDebuff(e.id, level: _level, label: _label.text), 'Không lưu được debuff.');
  }

  @override
  Widget build(BuildContext context) {
    final e = widget.existing;
    final api = ref.read(healthInputsApiProvider);
    return FinanceSheetBody(
      title: e == null ? 'Thêm debuff' : 'Sửa debuff',
      children: [
        const Text('Mức độ (trừ thẳng vào Sức khoẻ khi còn hiệu lực)'),
        ChoiceRow<String>(
          options: {for (final k in debuffLevels.keys) k: debuffLevelLabel(k)},
          selected: _level,
          onSelected: (v) => setState(() => _level = v),
        ),
        TextField(key: const ValueKey('debuff-label'), controller: _label, maxLength: 255, decoration: designInput('Tên (vd Cảm, Đau lưng) — tuỳ chọn')),
        if (e == null) ...[
          const Text('Bắt đầu từ'),
          ChoiceRow<String>(
            options: const {'now': 'Bây giờ', 'today': 'Đầu ngày hôm nay', 'yesterday': 'Đầu ngày hôm qua'},
            selected: _start,
            onSelected: (v) => setState(() => _start = v),
          ),
        ] else
          Text(debuffSubtitle(e)),
        sheetError(context, _error),
        DesignButton.primary(label: _busy ? 'Đang lưu…' : 'Lưu', onPressed: _busy ? null : _save, minHeight: 44),
        if (e != null && e.endedAt == null)
          DesignButton.outline(
            key: const ValueKey('debuff-end'),
            label: 'Đã khỏi',
            onPressed: _busy ? null : () => _run(() => api.updateDebuff(e.id, ended: true), 'Không cập nhật được.'),
            minHeight: 40,
          ),
        if (e != null && e.endedAt != null)
          DesignButton.outline(
            key: const ValueKey('debuff-reopen'),
            label: 'Mở lại (chưa khỏi)',
            onPressed: _busy ? null : () => _run(() => api.updateDebuff(e.id, ended: false), 'Không cập nhật được.'),
            minHeight: 40,
          ),
        if (e != null)
          DesignButton.outline(
            label: 'Xoá (nhập nhầm)',
            onPressed: _busy ? null : () => _run(() => api.deleteDebuff(e.id), 'Không xoá được.'),
            minHeight: 40,
          ),
      ],
    );
  }
}

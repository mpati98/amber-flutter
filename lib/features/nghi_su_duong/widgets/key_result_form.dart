import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/utils/api_error.dart';
import '../../../shared/widgets/form_bits.dart';
import '../models/key_result.dart';
import '../providers/nghi_su_duong_provider.dart';
import '../services/nghi_su_duong_api.dart';

/// Form thêm KR ([kr] null) hoặc sửa / xoá KR của dự án [projectId].
Future<void> showKeyResultForm(BuildContext context, {required String projectId, KeyResult? kr}) =>
    showFinanceSheet<void>(context, KeyResultForm(projectId: projectId, kr: kr));

class KeyResultForm extends ConsumerStatefulWidget {
  const KeyResultForm({super.key, required this.projectId, this.kr});

  final String projectId;
  final KeyResult? kr;

  @override
  ConsumerState<KeyResultForm> createState() => _KeyResultFormState();
}

class _KeyResultFormState extends ConsumerState<KeyResultForm> {
  late final _name = TextEditingController(text: widget.kr?.name ?? '');
  late final _target = TextEditingController(
    text: widget.kr != null && widget.kr!.mode == KrMode.manual ? '${widget.kr!.target}' : '',
  );
  late final _unit = TextEditingController(text: widget.kr?.unit ?? '');
  late KrMode _mode = widget.kr?.mode ?? KrMode.auto;
  bool _busy = false;
  String? _error;

  bool get _editing => widget.kr != null;

  @override
  void initState() {
    super.initState();
    for (final c in [_name, _target, _unit]) {
      c.addListener(() => setState(() {}));
    }
  }

  @override
  void dispose() {
    _name.dispose();
    _target.dispose();
    _unit.dispose();
    super.dispose();
  }

  int? get _targetValue => int.tryParse(_target.text.trim());

  bool get _valid => _name.text.trim().isNotEmpty && (_mode == KrMode.auto || (_targetValue ?? 0) >= 1);

  /// Khi sửa: chỉ gửi trường thật sự đổi. Server tự bỏ target/current của KR AUTO.
  Map<String, Object?> get _patch {
    final k = widget.kr!;
    final unit = _unit.text.trim();
    return {
      if (_name.text.trim() != k.name) 'name': _name.text.trim(),
      if (_mode != k.mode) 'mode': _mode.apiValue,
      if (_mode == KrMode.manual && (_mode != k.mode || _targetValue != k.target)) 'target': _targetValue,
      if (unit != (k.unit ?? '')) 'unit': unit.isEmpty ? null : unit,
    };
  }

  bool get _canSave => !_busy && _valid && (!_editing || _patch.isNotEmpty);

  Future<void> _save() async {
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      final api = ref.read(nghiSuDuongApiProvider);
      if (_editing) {
        await api.updateKeyResult(widget.projectId, widget.kr!.id, _patch);
      } else {
        final unit = _unit.text.trim();
        await api.createKeyResult(
          widget.projectId,
          name: _name.text.trim(),
          mode: _mode,
          unit: unit.isEmpty ? null : unit,
          target: _mode == KrMode.manual ? _targetValue : null,
        );
      }
      refreshProjectData(ref.invalidate, widget.projectId);
      if (mounted) Navigator.of(context).pop();
    } catch (e) {
      if (mounted) {
        setState(() {
          _busy = false;
          _error = apiErrorMessage(e, 'Không lưu được KR, thử lại nhé.');
        });
      }
    }
  }

  Future<void> _delete() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xoá KR?'),
        content: const Text('Xoá KR này? Các việc đang gắn sẽ thành không gắn.'),
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
      await ref.read(nghiSuDuongApiProvider).deleteKeyResult(widget.projectId, widget.kr!.id);
      refreshProjectData(ref.invalidate, widget.projectId);
      if (mounted) Navigator.of(context).pop();
    } catch (e) {
      if (mounted) {
        setState(() {
          _busy = false;
          _error = apiErrorMessage(e, 'Không xoá được KR, thử lại nhé.');
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final label = TextStyle(fontSize: 12, color: cs.onSurface.withValues(alpha: 0.6));
    return FinanceSheetBody(
      title: _editing ? 'Sửa KR' : 'Thêm KR',
      children: [
        TextField(
          controller: _name,
          maxLength: 255,
          decoration: const InputDecoration(labelText: 'Tên KR', counterText: ''),
        ),
        Text('Cách tính', style: label),
        ChoiceRow<KrMode>(
          options: const {KrMode.auto: 'Tự đếm từ việc đã gắn', KrMode.manual: 'Nhập tay theo con số'},
          selected: _mode,
          onSelected: (m) => setState(() => _mode = m),
        ),
        if (_mode == KrMode.manual) ...[
          TextField(
            controller: _target,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(labelText: 'Mục tiêu (số nguyên ≥ 1)'),
          ),
          TextField(
            controller: _unit,
            maxLength: 32,
            decoration: const InputDecoration(labelText: 'Đơn vị (tuỳ chọn)', counterText: ''),
          ),
        ],
        sheetError(context, _error),
        FilledButton(
          onPressed: _canSave ? _save : null,
          child: Text(_busy ? 'Đang lưu...' : (_editing ? 'Lưu' : 'Thêm')),
        ),
        if (_editing)
          OutlinedButton(
            onPressed: _busy ? null : _delete,
            style: OutlinedButton.styleFrom(foregroundColor: cs.error, side: BorderSide(color: cs.error)),
            child: const Text('Xoá KR'),
          ),
      ],
    );
  }
}

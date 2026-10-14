import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../shared/theme/app_theme.dart';
import '../../../../shared/utils/duration_format.dart';
import '../models/parsed_sections.dart';
import '../services/hoc_tap_api.dart';
import '../utils/hoc_tap_errors.dart';

/// Kết quả hiện tại của ô dán: [pending] = đang chờ debounce / gọi parse (chưa đáng tin để lưu).
typedef ParsedChanged = void Function(ParsedSections result, {required bool pending, required bool failed});

/// Ô dán mục lục các phần: debounce 500ms rồi gọi sections/parse; hiện danh sách đọc được + tổng thời lượng,
/// dòng bị bỏ qua tô đỏ kèm số dòng.
class SectionsPasteField extends ConsumerStatefulWidget {
  const SectionsPasteField({super.key, required this.onChanged, this.label = 'Các phần (dán mục lục)', this.controller});

  final ParsedChanged onChanged;
  final String label;
  final TextEditingController? controller;

  static const debounce = Duration(milliseconds: 500);

  @override
  ConsumerState<SectionsPasteField> createState() => _SectionsPasteFieldState();
}

class _SectionsPasteFieldState extends ConsumerState<SectionsPasteField> {
  late final TextEditingController _text = widget.controller ?? TextEditingController();
  Timer? _timer;
  int _generation = 0;
  ParsedSections _result = const ParsedSections();
  String? _error;

  @override
  void dispose() {
    _timer?.cancel();
    if (widget.controller == null) _text.dispose();
    super.dispose();
  }

  void _onText(String value) {
    _timer?.cancel();
    final gen = ++_generation;
    if (value.trim().isEmpty) {
      setState(() {
        _result = const ParsedSections();
        _error = null;
      });
      widget.onChanged(_result, pending: false, failed: false);
      return;
    }
    widget.onChanged(_result, pending: true, failed: false); // chưa parse xong → chặn lưu
    _timer = Timer(SectionsPasteField.debounce, () async {
      try {
        final parsed = await ref.read(hocTapApiProvider).parseSections(value);
        if (!mounted || gen != _generation) return;
        setState(() {
          _result = parsed;
          _error = null;
        });
        widget.onChanged(parsed, pending: false, failed: false);
      } catch (e) {
        if (!mounted || gen != _generation) return;
        setState(() => _error = hocTapErrorMessage(e, 'Không đọc được các phần, thử lại'));
        widget.onChanged(const ParsedSections(), pending: false, failed: true);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: 8,
      children: [
        TextField(
          key: const ValueKey('sections-text'),
          controller: _text,
          minLines: 4,
          maxLines: 10,
          onChanged: _onText,
          decoration: InputDecoration(labelText: widget.label, alignLabelWithHint: true, hintText: 'Tên phần ... 1h 30min (mỗi dòng một phần, kết thúc bằng thời lượng)'),
        ),
        if (_error != null) Text(_error!, style: TextStyle(color: theme.colorScheme.error, fontSize: 12)),
        if (_result.sections.isNotEmpty)
          Column(
            key: const ValueKey('parsed-list'),
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              for (final (i, s) in _result.sections.indexed)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 2),
                  child: Row(
                    children: [
                      SizedBox(width: 24, child: Text('${i + 1}.', style: TextStyle(fontSize: 12, color: theme.textMuted))),
                      Expanded(child: Text(s.title, style: const TextStyle(fontSize: 13))),
                      Text(formatDuration(s.durationMinutes), style: TextStyle(fontSize: 12, color: theme.textMuted)),
                    ],
                  ),
                ),
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  '${_result.sections.length} phần · ${formatDuration(_result.totalMinutes)}',
                  key: const ValueKey('parsed-total'),
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.kincha400),
                ),
              ),
            ],
          ),
        for (final k in _result.skipped)
          Text(
            'Dòng ${k.line} chưa đọc được: ${k.text}',
            key: ValueKey('skipped-${k.line}'),
            style: TextStyle(fontSize: 12, color: theme.colorScheme.error),
          ),
      ],
    );
  }
}

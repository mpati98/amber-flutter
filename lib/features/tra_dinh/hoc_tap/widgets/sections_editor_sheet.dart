import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../shared/widgets/form_bits.dart';
import '../models/course.dart';
import '../models/parsed_sections.dart';
import '../providers/hoc_tap_provider.dart';
import '../services/hoc_tap_api.dart';
import '../utils/hoc_tap_errors.dart';
import 'sections_paste_field.dart';

/// Sửa danh sách phần của khóa đã có. Giữ id của phần cũ để PUT không làm mất trạng thái xong.
Future<void> showSectionsEditorSheet(BuildContext context, {required String courseId, required List<CourseSection> sections}) =>
    showFinanceSheet<void>(context, SectionsEditorSheet(courseId: courseId, sections: sections));

class _Row {
  _Row({this.id, String title = '', int? minutes})
    : title = TextEditingController(text: title),
      minutes = TextEditingController(text: minutes?.toString() ?? '');

  final String? id;
  final TextEditingController title;
  final TextEditingController minutes;
  final key = UniqueKey();

  void dispose() {
    title.dispose();
    minutes.dispose();
  }
}

class SectionsEditorSheet extends ConsumerStatefulWidget {
  const SectionsEditorSheet({super.key, required this.courseId, required this.sections});

  final String courseId;
  final List<CourseSection> sections;

  @override
  ConsumerState<SectionsEditorSheet> createState() => _SectionsEditorSheetState();
}

class _SectionsEditorSheetState extends ConsumerState<SectionsEditorSheet> {
  late final List<_Row> _rows = [for (final s in widget.sections) _Row(id: s.id, title: s.title, minutes: s.durationMinutes)];
  bool _pasting = false;
  ParsedSections _parsed = const ParsedSections();
  bool _pending = false;
  bool _busy = false;
  String? _error;

  @override
  void dispose() {
    for (final r in _rows) {
      r.dispose();
    }
    super.dispose();
  }

  void _move(int i, int delta) {
    final j = i + delta;
    if (j < 0 || j >= _rows.length) return;
    setState(() => _rows.insert(j, _rows.removeAt(i)));
  }

  void _remove(int i) => setState(() => _rows.removeAt(i).dispose());

  void _appendParsed() {
    setState(() {
      for (final s in _parsed.sections) {
        _rows.add(_Row(title: s.title, minutes: s.durationMinutes));
      }
      _pasting = false;
      _parsed = const ParsedSections();
    });
  }

  Future<void> _save() async {
    final inputs = <SectionInput>[];
    for (final r in _rows) {
      final title = r.title.text.trim();
      final minutes = int.tryParse(r.minutes.text.trim());
      if (title.isEmpty || minutes == null || minutes < 0) {
        setState(() => _error = 'Mỗi phần cần có tên và số phút (0 trở lên).');
        return;
      }
      inputs.add(SectionInput(id: r.id, title: title, durationMinutes: minutes));
    }
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await ref.read(hocTapActionsProvider).putSections(widget.courseId, inputs);
      if (mounted) Navigator.of(context).pop();
    } catch (e) {
      if (mounted) setState(() => (_busy = false, _error = hocTapErrorMessage(e)));
    }
  }

  @override
  Widget build(BuildContext context) {
    return FinanceSheetBody(
      title: 'Sửa các phần',
      children: [
        for (final (i, r) in _rows.indexed)
          Column(
            key: r.key,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextField(key: ValueKey('row-title-$i'), controller: r.title, decoration: InputDecoration(labelText: 'Phần ${i + 1}', isDense: true)),
              const SizedBox(height: 6),
              Row(
                children: [
                  SizedBox(
                    width: 110,
                    child: TextField(key: ValueKey('row-minutes-$i'), controller: r.minutes, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Phút', isDense: true)),
                  ),
                  const Spacer(),
                  IconButton(tooltip: 'Lên', visualDensity: VisualDensity.compact, onPressed: i == 0 ? null : () => _move(i, -1), icon: const Icon(Icons.arrow_upward, size: 20)),
                  IconButton(tooltip: 'Xuống', visualDensity: VisualDensity.compact, onPressed: i == _rows.length - 1 ? null : () => _move(i, 1), icon: const Icon(Icons.arrow_downward, size: 20)),
                  IconButton(tooltip: 'Xoá phần', visualDensity: VisualDensity.compact, onPressed: () => _remove(i), icon: const Icon(Icons.close, size: 20)),
                ],
              ),
              const Divider(height: 16),
            ],
          ),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            OutlinedButton.icon(key: const ValueKey('add-row'), onPressed: () => setState(() => _rows.add(_Row())), icon: const Icon(Icons.add, size: 18), label: const Text('Thêm dòng')),
            OutlinedButton(key: const ValueKey('paste-more'), onPressed: () => setState(() => _pasting = !_pasting), child: const Text('Dán thêm')),
          ],
        ),
        if (_pasting) ...[
          SectionsPasteField(
            label: 'Dán các phần cần thêm',
            onChanged: (result, {required pending, required failed}) => setState(() {
              _parsed = result;
              _pending = pending;
            }),
          ),
          FilledButton.tonal(
            key: const ValueKey('append-parsed'),
            onPressed: _pending || _parsed.sections.isEmpty || _parsed.skipped.isNotEmpty ? null : _appendParsed,
            child: const Text('Nối vào cuối'),
          ),
        ],
        sheetError(context, _error),
        FilledButton(key: const ValueKey('sections-save'), onPressed: _busy ? null : _save, child: const Text('Lưu các phần')),
      ],
    );
  }
}

import 'package:material_ui/material_ui.dart';
import '../../../../shared/widgets/design_page.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../shared/theme/app_theme.dart';
import '../../../../shared/widgets/app_bar_back.dart';
import '../models/study_card.dart';
import '../providers/card_provider.dart';
import '../utils/card_format.dart';
import '../utils/card_prompt.dart';
import '../utils/log_labels.dart';
import '../widgets/card_widgets.dart';
import '../widgets/hoc_tap_common.dart';

/// Nhập thẻ từ Claude: dán mảng JSON → Xem trước (không lưu) → Lưu. Còn lỗi thì không lưu được.
class CardImportScreen extends StatelessWidget {
  const CardImportScreen({super.key, this.subjectId});

  final String? subjectId;

  @override
  Widget build(BuildContext context) =>
      CardSubjectGate(subjectId: subjectId, title: 'Nhập thẻ từ Claude', builder: (context, id, name) => _Import(key: ValueKey('import-$id'), subjectId: id));
}

class _Import extends ConsumerStatefulWidget {
  const _Import({super.key, required this.subjectId});

  final String subjectId;

  @override
  ConsumerState<_Import> createState() => _ImportState();
}

class _ImportState extends ConsumerState<_Import> {
  final _text = TextEditingController();
  ParsedCards? _parsed;
  String? _logId; // buổi học gắn vào thẻ (không chọn = null)
  bool _parsing = false;
  bool _saving = false;
  String? _error;

  String get _libraryPath => '/tra-dinh/hoc-tap/the?subjectId=${widget.subjectId}';

  @override
  void dispose() {
    _text.dispose();
    super.dispose();
  }

  bool get _canSave => !_saving && !_parsing && _parsed != null && !_parsed!.hasErrors && _parsed!.cards.isNotEmpty;

  /// Gõ lại thì kết quả xem trước cũ không còn đúng: bỏ nó, buộc xem trước lại trước khi lưu.
  void _onTextChanged(String _) => setState(() {
    _parsed = null;
    _error = null;
  });

  Future<void> _preview() async {
    if (_text.text.trim().isEmpty || _parsing) return;
    setState(() {
      _parsing = true;
      _error = null;
    });
    try {
      final parsed = await ref.read(cardActionsProvider).parse(widget.subjectId, _text.text);
      if (mounted) setState(() => (_parsing = false, _parsed = parsed));
    } catch (e) {
      if (mounted) setState(() => (_parsing = false, _parsed = null, _error = cardErrorMessage(e)));
    }
  }

  Future<void> _save() async {
    final parsed = _parsed;
    if (!_canSave || parsed == null) return;
    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      final result = await ref.read(cardActionsProvider).import(widget.subjectId, parsed.cards, logId: _logId);
      if (!mounted) return;
      // Thẻ đã có và thẻ lặp đã được bỏ ở bước xem trước; cộng vào số "bỏ qua" cho người dùng thấy đủ.
      final skipped = result.skipped + parsed.existing.length + parsed.duplicates.length;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Đã lưu ${result.created} thẻ, bỏ qua $skipped thẻ')));
      goBackOr(context, _libraryPath);
    } catch (e) {
      if (mounted) setState(() => (_saving = false, _error = cardErrorMessage(e)));
    }
  }

  /// Chép lời nhắc kèm các chủ đề đang có trong môn (lỗi tải chủ đề thì ghi "none yet").
  Future<void> _copyPrompt() async {
    var topics = const <String>[];
    try {
      topics = [for (final t in await ref.read(cardTopicsProvider(widget.subjectId).future)) t.topic];
    } catch (_) {}
    await Clipboard.setData(ClipboardData(text: cardPrompt(topics)));
    if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Đã sao chép lời nhắc cho Claude')));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final parsed = _parsed;
    return DesignScaffold(
      // fallback hằng số (test chặn tái phát yêu cầu `const AppBarBack`): mở thẳng URL rồi bấm quay lại → kho thẻ của môn đầu tiên.
      title: 'Nhập thẻ từ Claude',
      backFallback: '/tra-dinh/hoc-tap/the',
      bottomNavigationBar: parsed == null
          ? null
          : SafeArea(
              child: Center(
                heightFactor: 1,
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 640),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
                    child: FilledButton(key: const ValueKey('import-save'), onPressed: _canSave ? _save : null, child: Text(_saving ? 'Đang lưu…' : 'Lưu ${parsed.cards.length} thẻ')),
                  ),
                ),
              ),
            ),
      body: HocTapBody(
        child: ListView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
          children: [
            Text('Dán mảng JSON Claude trả về. Xem trước không lưu gì.', style: TextStyle(fontSize: 13, color: theme.textMuted)),
            const SizedBox(height: 10),
            OutlinedButton.icon(key: const ValueKey('import-copy-prompt'), onPressed: _copyPrompt, icon: const Icon(Icons.copy, size: 18), label: const Text('Sao chép lời nhắc cho Claude')),
            const SizedBox(height: 12),
            TextField(
              key: const ValueKey('import-text'),
              controller: _text,
              minLines: 6,
              maxLines: 12,
              keyboardType: TextInputType.multiline,
              style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
              decoration: const InputDecoration(hintText: '[{"phrase": "look forward to", "meaning": "...", "example": "...", "kind": "PHRASAL_VERB", "topics": ["daily life"]}]', border: OutlineInputBorder()),
              onChanged: _onTextChanged,
            ),
            _LessonPicker(subjectId: widget.subjectId, selected: _logId, onChanged: (id) => setState(() => _logId = id)),
            const SizedBox(height: 10),
            FilledButton.tonal(
              key: const ValueKey('import-preview'),
              onPressed: _text.text.trim().isEmpty || _parsing || _saving ? null : _preview,
              child: Text(_parsing ? 'Đang đọc…' : 'Xem trước'),
            ),
            if (_error != null) Padding(padding: const EdgeInsets.only(top: 10), child: Text(_error!, key: const ValueKey('import-error'), style: TextStyle(color: theme.colorScheme.error))),
            if (parsed != null) ...[const SizedBox(height: 16), _Preview(parsed: parsed)],
          ],
        ),
      ),
    );
  }
}

class _Preview extends StatelessWidget {
  const _Preview({required this.parsed});

  final ParsedCards parsed;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final parts = [
      '${parsed.cards.length} thẻ hợp lệ',
      if (parsed.existing.isNotEmpty) '${parsed.existing.length} đã có',
      if (parsed.duplicates.isNotEmpty) '${parsed.duplicates.length} lặp',
      if (parsed.errors.isNotEmpty) '${parsed.errors.length} lỗi',
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: 8,
      children: [
        Text(parts.join(' · '), key: const ValueKey('preview-summary'), style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
        if (parsed.hasErrors)
          Container(
            key: const ValueKey('preview-errors'),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(border: Border.all(color: theme.colorScheme.error.withValues(alpha: 0.6)), borderRadius: BorderRadius.circular(AppTheme.darkRadius)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 4,
              children: [
                Text('Cần sửa trước khi lưu', style: TextStyle(fontWeight: FontWeight.w600, color: theme.colorScheme.error)),
                for (final (i, e) in parsed.errors.indexed) Text(parseErrorLine(e), key: ValueKey('import-error-$i'), style: const TextStyle(fontSize: 13)),
              ],
            ),
          ),
        for (final c in parsed.cards) _PreviewCard(item: c),
        for (final e in parsed.existing)
          Opacity(
            key: ValueKey('preview-existing-${e.index}'),
            opacity: 0.5,
            child: _PreviewBox(
              children: [
                Text(e.phrase, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
                Text('đã có trong kho, sẽ không được lưu', style: TextStyle(fontSize: 12, color: theme.textMuted)),
              ],
            ),
          ),
        for (final d in parsed.duplicates)
          Text(
            'Thẻ ${d.index + 1} "${d.phrase}" lặp${d.firstIndex == null ? '' : ' với thẻ ${d.firstIndex! + 1}'}, chỉ giữ một thẻ.',
            key: ValueKey('preview-duplicate-${d.index}'),
            style: TextStyle(fontSize: 12, color: theme.textMuted),
          ),
      ],
    );
  }
}

class _PreviewBox extends StatelessWidget {
  const _PreviewBox({super.key, required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: theme.colorScheme.surface, border: Border.all(color: theme.colorScheme.onSurface.withValues(alpha: 0.12)), borderRadius: BorderRadius.circular(AppTheme.darkRadius)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, spacing: 4, children: children),
    );
  }
}

class _PreviewCard extends StatelessWidget {
  const _PreviewCard({required this.item});

  final ParsedCardItem item;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return _PreviewBox(
      key: ValueKey('preview-card-${item.index}'),
      children: [
        Text(item.phrase, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
        Text(item.meaning, style: TextStyle(fontSize: 13, color: theme.textMuted)),
        Text(item.example, style: TextStyle(fontSize: 13, fontStyle: FontStyle.italic, color: theme.textMuted)),
        if (item.note != null) Text(item.note!, style: TextStyle(fontSize: 12, color: theme.textMuted)),
        const SizedBox(height: 2),
        ChipScrollRow(children: [KindTag(item.kind), for (final t in item.topics) TopicTag(t)]),
      ],
    );
  }
}

/// "Gắn vào buổi học" (không bắt buộc): các buổi học bài 14 ngày gần nhất của môn. Chưa tải xong, tải lỗi hoặc không có
/// buổi nào → ẩn hẳn, không chặn việc nhập thẻ.
class _LessonPicker extends ConsumerWidget {
  const _LessonPicker({required this.subjectId, required this.selected, required this.onChanged});

  final String subjectId;
  final String? selected;
  final ValueChanged<String?> onChanged;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final logs = ref.watch(recentLessonLogsProvider(subjectId)).value;
    if (logs == null || logs.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: DropdownButtonFormField<String?>(
        key: ValueKey('import-lesson-${logs.any((l) => l.id == selected) ? selected : null}'),
        initialValue: logs.any((l) => l.id == selected) ? selected : null,
        isExpanded: true,
        decoration: const InputDecoration(labelText: 'Gắn vào buổi học (không bắt buộc)'),
        items: [
          const DropdownMenuItem<String?>(value: null, child: Text('Không gắn buổi học')),
          for (final l in logs) DropdownMenuItem<String?>(value: l.id, child: Text(lessonPickLabel(l), overflow: TextOverflow.ellipsis)),
        ],
        onChanged: onChanged,
      ),
    );
  }
}

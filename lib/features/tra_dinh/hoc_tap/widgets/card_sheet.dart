import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../shared/theme/app_theme.dart';
import '../../../../shared/widgets/form_bits.dart';
import '../models/study_card.dart';
import '../providers/card_provider.dart';
import '../utils/card_format.dart';
import 'card_widgets.dart';

/// Form thêm một thẻ ([card] null) hoặc xem / sửa / tạm dừng / xoá [card]. Mở bằng showFinanceSheet;
/// trả về true khi đã lưu hoặc xoá (màn kho thẻ tải lại danh sách), đóng bằng X → null.
Future<bool?> showCardSheet(BuildContext context, {required String subjectId, StudyCard? card}) =>
    showFinanceSheet<bool>(context, CardSheet(subjectId: subjectId, card: card));

const maxCardTopics = 3;

class CardSheet extends ConsumerStatefulWidget {
  const CardSheet({super.key, required this.subjectId, this.card});

  final String subjectId;
  final StudyCard? card;

  @override
  ConsumerState<CardSheet> createState() => _CardSheetState();
}

class _CardSheetState extends ConsumerState<CardSheet> {
  late final _phrase = TextEditingController(text: widget.card?.phrase ?? '');
  late final _meaning = TextEditingController(text: widget.card?.meaning ?? '');
  late final _example = TextEditingController(text: widget.card?.example ?? '');
  late final _note = TextEditingController(text: widget.card?.note ?? '');
  final _topicInput = TextEditingController();
  late CardKind? _kind = widget.card == null || widget.card!.kind == CardKind.unknown ? null : widget.card!.kind;
  late final List<String> _topics = [...?widget.card?.topics];
  late bool _suspended = widget.card?.suspended ?? false;
  bool _busy = false;
  String? _error;

  bool get _editing => widget.card != null;

  @override
  void initState() {
    super.initState();
    for (final c in [_phrase, _meaning, _example]) {
      c.addListener(() => setState(() {}));
    }
  }

  @override
  void dispose() {
    for (final c in [_phrase, _meaning, _example, _note, _topicInput]) {
      c.dispose();
    }
    super.dispose();
  }

  bool get _canSave =>
      !_busy && _phrase.text.trim().isNotEmpty && _meaning.text.trim().isNotEmpty && _example.text.trim().isNotEmpty && (_editing || _kind != null);

  String? _blankToNull(TextEditingController c) => c.text.trim().isEmpty ? null : c.text.trim();

  /// Thêm chủ đề từ ô nhập (cho phép nhiều chủ đề cách nhau bằng dấu phẩy): chữ thường, bỏ khoảng thừa, không trùng, tối đa 3.
  void _addTopics(String raw) {
    setState(() {
      for (final part in raw.split(',')) {
        final t = part.trim().toLowerCase().replaceAll(RegExp(r'\s+'), ' ');
        if (t.isEmpty || _topics.contains(t) || _topics.length >= maxCardTopics) continue;
        _topics.add(t);
      }
      _topicInput.clear();
    });
  }

  Future<void> _save() async {
    if (!_canSave) return;
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      final actions = ref.read(cardActionsProvider);
      if (_editing) {
        await actions.patch(widget.card!.id, {
          'phrase': _phrase.text.trim(),
          'meaning': _meaning.text.trim(),
          'example': _example.text.trim(),
          'note': _blankToNull(_note),
          'kind': ?_kind?.api,
          'topics': _topics,
          'suspended': _suspended,
        });
      } else {
        await actions.create({
          'subjectId': widget.subjectId,
          'phrase': _phrase.text.trim(),
          'meaning': _meaning.text.trim(),
          'example': _example.text.trim(),
          'note': ?_blankToNull(_note),
          'kind': _kind!.api,
          'topics': _topics,
        });
      }
      if (mounted) Navigator.of(context).pop(true);
    } catch (e) {
      if (mounted) setState(() => (_busy = false, _error = cardErrorMessage(e)));
    }
  }

  Future<void> _delete() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xoá thẻ này?'),
        content: Text('"${widget.card!.phrase}" và các lượt ôn của thẻ sẽ bị xoá, không khôi phục được.'),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(false), child: const Text('Giữ lại')),
          TextButton(
            key: const ValueKey('card-delete-confirm'),
            onPressed: () => Navigator.of(context).pop(true),
            child: Text('Xoá', style: TextStyle(color: Theme.of(context).colorScheme.error)),
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
      await ref.read(cardActionsProvider).delete(widget.card!.id);
      if (mounted) Navigator.of(context).pop(true);
    } catch (e) {
      if (mounted) setState(() => (_busy = false, _error = cardErrorMessage(e)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final suggestions = [
      for (final t in ref.watch(cardTopicsProvider(widget.subjectId)).value ?? const <TopicCount>[])
        if (!_topics.contains(t.topic)) t.topic,
    ].take(12).toList();
    return FinanceSheetBody(
      title: _editing ? 'Thẻ từ vựng' : 'Thêm thẻ',
      children: [
        TextField(key: const ValueKey('card-phrase'), controller: _phrase, maxLength: 255, decoration: const InputDecoration(labelText: 'Cụm từ', counterText: '')),
        TextField(key: const ValueKey('card-meaning'), controller: _meaning, minLines: 1, maxLines: 3, decoration: const InputDecoration(labelText: 'Nghĩa tiếng Anh')),
        TextField(key: const ValueKey('card-example'), controller: _example, minLines: 2, maxLines: 4, decoration: const InputDecoration(labelText: 'Câu ví dụ (có chứa cụm)')),
        TextField(key: const ValueKey('card-note'), controller: _note, minLines: 1, maxLines: 3, decoration: const InputDecoration(labelText: 'Ghi chú (không bắt buộc)')),
        const Text('Loại', style: TextStyle(fontWeight: FontWeight.w600)),
        ChipScrollRow(
          children: [
            for (final k in CardKind.values.where((k) => k != CardKind.unknown))
              FilterPill(key: ValueKey('card-kind-${k.api}'), label: k.label, selected: _kind == k, onSelected: () => setState(() => _kind = k)),
          ],
        ),
        Text('Chủ đề (tối đa $maxCardTopics)', style: const TextStyle(fontWeight: FontWeight.w600)),
        if (_topics.isNotEmpty)
          ChipScrollRow(
            children: [
              for (final t in _topics) InputChip(key: ValueKey('card-topic-$t'), label: Text(t), onDeleted: () => setState(() => _topics.remove(t))),
            ],
          ),
        if (_topics.length < maxCardTopics) ...[
          TextField(
            key: const ValueKey('card-topic-input'),
            controller: _topicInput,
            textInputAction: TextInputAction.done,
            decoration: InputDecoration(
              labelText: 'Thêm chủ đề (chữ thường, cách nhau bằng dấu phẩy)',
              suffixIcon: IconButton(key: const ValueKey('card-topic-add'), icon: const Icon(Icons.add), onPressed: () => _addTopics(_topicInput.text)),
            ),
            onSubmitted: _addTopics,
          ),
          if (suggestions.isNotEmpty)
            ChipScrollRow(children: [for (final t in suggestions) ActionChip(key: ValueKey('card-topic-suggest-$t'), label: Text(t), onPressed: () => _addTopics(t))]),
        ] else
          Text('Đã đủ $maxCardTopics chủ đề.', style: TextStyle(fontSize: 12, color: theme.textMuted)),
        if (_editing) ...[
          SwitchListTile(
            key: const ValueKey('card-suspended'),
            contentPadding: EdgeInsets.zero,
            title: const Text('Tạm dừng ôn thẻ này'),
            subtitle: const Text('Thẻ tạm dừng không vào hàng ôn hằng ngày'),
            value: _suspended,
            onChanged: _busy ? null : (v) => setState(() => _suspended = v),
          ),
          _ReadOnlyInfo(card: widget.card!),
        ],
        sheetError(context, _error),
        FilledButton(key: const ValueKey('card-save'), onPressed: _canSave ? _save : null, child: Text(_editing ? 'Lưu' : 'Thêm thẻ')),
        if (_editing)
          TextButton(
            key: const ValueKey('card-delete'),
            onPressed: _busy ? null : _delete,
            child: Text('Xoá thẻ', style: TextStyle(color: theme.colorScheme.error)),
          ),
      ],
    );
  }
}

/// Giai đoạn, hạn ôn, số lần ôn: chỉ xem (đổi bằng cách ôn thẻ).
class _ReadOnlyInfo extends StatelessWidget {
  const _ReadOnlyInfo({required this.card});

  final StudyCard card;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    Widget row(String k, String v, {Key? key}) => Row(
      children: [
        Expanded(child: Text(k, style: TextStyle(fontSize: 13, color: theme.textMuted))),
        Text(v, key: key, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
      ],
    );
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: theme.colorScheme.onSurface.withValues(alpha: 0.05), borderRadius: BorderRadius.circular(AppTheme.darkRadius)),
      child: Column(
        spacing: 6,
        children: [
          row('Giai đoạn', card.stage.label, key: const ValueKey('info-stage')),
          row('Hạn ôn', card.stage == CardStage.newCard ? 'Chưa có (thẻ mới)' : cardDateLabel(card.dueAt), key: const ValueKey('info-due')),
          row('Đã ôn', '${card.reviewCount} lần', key: const ValueKey('info-reviews')),
          row('Chưa nhớ', '${card.notYetCount} lần', key: const ValueKey('info-notyet')),
        ],
      ),
    );
  }
}

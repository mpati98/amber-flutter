import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../shared/widgets/form_bits.dart';
import '../models/study_card.dart';
import '../providers/card_provider.dart';
import 'card_widgets.dart';

/// Lọc theo loại và chủ đề. Trả về bộ lọc mới (giữ giai đoạn và ô tìm của [current]); đóng bằng X → null.
Future<CardFilter?> showCardFilterSheet(BuildContext context, {required String subjectId, required CardFilter current}) =>
    showFinanceSheet<CardFilter>(context, CardFilterSheet(subjectId: subjectId, current: current));

class CardFilterSheet extends ConsumerStatefulWidget {
  const CardFilterSheet({super.key, required this.subjectId, required this.current});

  final String subjectId;
  final CardFilter current;

  @override
  ConsumerState<CardFilterSheet> createState() => _CardFilterSheetState();
}

class _CardFilterSheetState extends ConsumerState<CardFilterSheet> {
  late CardKind? _kind = widget.current.kind;
  late String? _topic = widget.current.topic;

  @override
  Widget build(BuildContext context) {
    final topics = ref.watch(cardTopicsProvider(widget.subjectId));
    return FinanceSheetBody(
      title: 'Lọc thẻ',
      children: [
        const Text('Loại', style: TextStyle(fontWeight: FontWeight.w600)),
        ChipScrollRow(
          children: [
            FilterPill(key: const ValueKey('kind-all'), label: 'Tất cả', selected: _kind == null, onSelected: () => setState(() => _kind = null)),
            for (final k in CardKind.values.where((k) => k != CardKind.unknown))
              FilterPill(key: ValueKey('kind-${k.api}'), label: k.label, selected: _kind == k, onSelected: () => setState(() => _kind = k)),
          ],
        ),
        const Text('Chủ đề', style: TextStyle(fontWeight: FontWeight.w600)),
        switch (topics) {
          AsyncData(:final value) when value.isEmpty => Text('Chưa có chủ đề nào.', style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.62))),
          AsyncData(:final value) => ChipScrollRow(
            children: [
              FilterPill(key: const ValueKey('topic-all'), label: 'Tất cả', selected: _topic == null, onSelected: () => setState(() => _topic = null)),
              for (final t in value) FilterPill(key: ValueKey('topic-${t.topic}'), label: '${t.topic} (${t.cards})', selected: _topic == t.topic, onSelected: () => setState(() => _topic = t.topic)),
            ],
          ),
          AsyncError() => Row(spacing: 8, children: [const Text('Không tải được chủ đề.'), TextButton(onPressed: () => ref.invalidate(cardTopicsProvider(widget.subjectId)), child: const Text('Thử lại'))]),
          _ => const Padding(padding: EdgeInsets.all(8), child: Center(child: CircularProgressIndicator())),
        },
        FilledButton(
          key: const ValueKey('filter-apply'),
          onPressed: () => Navigator.of(context).pop(widget.current.copyWith(kind: _kind, topic: _topic)),
          child: const Text('Áp dụng'),
        ),
        TextButton(
          key: const ValueKey('filter-clear'),
          onPressed: () => Navigator.of(context).pop(widget.current.copyWith(kind: null, topic: null)),
          child: const Text('Xoá bộ lọc loại và chủ đề'),
        ),
      ],
    );
  }
}

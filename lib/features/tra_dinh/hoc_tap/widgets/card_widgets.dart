import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../shared/widgets/app_bar_back.dart';
import '../providers/hoc_tap_provider.dart';
import '../utils/async_view.dart';
import 'hoc_tap_common.dart';

import '../../../../shared/theme/app_theme.dart';
import '../../../../shared/widgets/tag.dart';
import '../models/study_card.dart';
import '../utils/card_format.dart';

/// Hàng chip cuộn NGANG, không bao giờ xuống dòng (Wrap bị vỡ bố cục trên iPhone cũ).
class ChipScrollRow extends StatelessWidget {
  const ChipScrollRow({super.key, required this.children, this.padding = EdgeInsets.zero});

  final List<Widget> children;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) => SingleChildScrollView(
    scrollDirection: Axis.horizontal,
    padding: padding,
    child: Row(spacing: 6, children: children),
  );
}

/// Chip chọn dùng màu của theme (nền primary khi chọn), không dùng token AppColors.
class FilterPill extends StatelessWidget {
  const FilterPill({super.key, required this.label, required this.selected, required this.onSelected});

  final String label;
  final bool selected;
  final VoidCallback onSelected;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return ChoiceChip(
      label: Text(label),
      selected: selected,
      showCheckmark: false,
      selectedColor: scheme.primary,
      labelStyle: TextStyle(fontSize: 13, color: selected ? scheme.onPrimary : null),
      onSelected: (_) => onSelected(),
    );
  }
}

/// Nhãn loại thẻ: chữ và viền màu vàng (primary của theme).
class KindTag extends StatelessWidget {
  const KindTag(this.kind, {super.key});

  final CardKind kind;

  @override
  Widget build(BuildContext context) => Tag(label: kind.label, color: Theme.of(context).colorScheme.primary, borderAlpha: 0.7);
}

/// Nhãn chủ đề: xám.
class TopicTag extends StatelessWidget {
  const TopicTag(this.topic, {super.key});

  final String topic;

  @override
  Widget build(BuildContext context) => Tag(label: topic, color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.55), variant: TagVariant.tonal, backgroundAlpha: 0.12);
}

/// Một dòng của kho thẻ: cụm, nghĩa tiếng Anh, loại và nhãn hạn ôn.
class CardRow extends StatelessWidget {
  const CardRow({super.key, required this.card, required this.onTap, this.now});

  final StudyCard card;
  final VoidCallback onTap;
  final DateTime? now;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final due = cardDueLabel(card, now: now);
    final dueColor = switch (due) {
      'Hôm nay' => theme.colorScheme.primary,
      'Mới' => theme.success,
      _ => theme.textMuted,
    };
    return Opacity(
      opacity: card.suspended ? 0.55 : 1,
      child: Material(
        color: theme.colorScheme.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppTheme.darkRadius), side: BorderSide(color: theme.colorScheme.onSurface.withValues(alpha: 0.12))),
        child: InkWell(
          key: ValueKey('card-${card.id}'),
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppTheme.darkRadius),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 12,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    spacing: 3,
                    children: [
                      Text(card.phrase, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
                      if (card.pronunciation != null) Text(card.pronunciation!, key: ValueKey('pron-${card.id}'), style: TextStyle(fontSize: 12, color: theme.textMuted)),
                      Text(card.meaning, maxLines: 2, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 13, color: theme.textMuted)),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  spacing: 6,
                  children: [
                    Text(due, key: ValueKey('due-${card.id}'), style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: dueColor)),
                    KindTag(card.kind),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Xác định môn cho các màn kho thẻ: dùng [subjectId] nếu có, không thì môn đầu tiên của Tổng quan.
/// Chưa có môn nào / lỗi tải Tổng quan → khung màn có nút quay lại và thông báo.
class CardSubjectGate extends ConsumerWidget {
  const CardSubjectGate({super.key, this.subjectId, required this.title, required this.builder});

  final String? subjectId;
  final String title;
  final Widget Function(BuildContext context, String subjectId, String? subjectName) builder;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final overview = ref.watch(studyOverviewProvider);
    final subjects = overview.value?.subjects ?? const [];
    if (subjectId != null) {
      final name = subjects.where((s) => s.subjectId == subjectId).map((s) => s.name).firstOrNull;
      return builder(context, subjectId!, name);
    }
    Widget frame(Widget body) => Scaffold(
      appBar: AppBar(leading: const AppBarBack(fallback: '/tra-dinh'), title: Text(title)),
      body: Center(child: body),
    );
    return switch (overview.settled) {
      AsyncData(:final value) when value.subjects.isEmpty => frame(Padding(padding: const EdgeInsets.all(32), child: Text('Chưa có môn học nào. Tạo môn ở Tổng quan trước.', textAlign: TextAlign.center, style: TextStyle(color: Theme.of(context).textMuted)))),
      AsyncData(:final value) => builder(context, value.subjects.first.subjectId, value.subjects.first.name),
      AsyncError() => frame(HocTapLoadError(what: 'danh sách môn', onRetry: () => ref.invalidate(studyOverviewProvider))),
      _ => frame(const CircularProgressIndicator()),
    };
  }
}

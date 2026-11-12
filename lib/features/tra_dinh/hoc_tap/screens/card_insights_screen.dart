import 'package:material_ui/material_ui.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../shared/theme/app_theme.dart';
import '../../../../shared/widgets/app_bar_back.dart';
import '../models/study_card.dart';
import '../models/study_card_insights.dart';
import '../providers/card_provider.dart';
import '../utils/card_insights_prompt.dart';
import '../widgets/card_widgets.dart';
import '../widgets/hoc_tap_common.dart';

/// Nhóm khó của kho thẻ: các nhóm (loại / chủ đề / buổi học) có nhiều thẻ từng bị Chưa nhớ, thẻ hay quên, và nút chép
/// số liệu cho Claude phân tích. Các nhóm tích luỹ suốt đời thẻ; chỉ số tổng đầu trang theo kỳ 7 / 30 / 90 ngày.
class CardInsightsScreen extends StatelessWidget {
  const CardInsightsScreen({super.key, this.subjectId});

  final String? subjectId;

  @override
  Widget build(BuildContext context) =>
      CardSubjectGate(subjectId: subjectId, title: 'Nhóm khó', builder: (context, id, name) => _Insights(key: ValueKey('insights-$id'), subjectId: id));
}

class _Insights extends ConsumerWidget {
  const _Insights({super.key, required this.subjectId});

  final String subjectId;

  Future<void> _copy(BuildContext context, WidgetRef ref, CardInsights insights) async {
    var topics = const <String>[];
    try {
      topics = [for (final t in await ref.read(cardTopicsProvider(subjectId).future)) t.topic];
    } catch (_) {} // không tải được chủ đề: vẫn chép, ghi "none yet"
    await Clipboard.setData(ClipboardData(text: buildInsightsPrompt(insights: insights, topics: topics)));
    if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Đã sao chép cho Claude')));
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(cardInsightsProvider(subjectId));
    final notifier = ref.read(cardInsightsProvider(subjectId).notifier);
    final s = async.value;
    final insights = s?.insights;
    final canCopy = insights != null && s?.error == null && !(s?.loading ?? true) && (insights.hasGroups || insights.hardestCards.isNotEmpty);

    return Scaffold(
      appBar: AppBar(leading: const AppBarBack(fallback: '/tra-dinh/hoc-tap/the'), title: const Text('Nhóm khó')),
      bottomNavigationBar: insights == null
          ? null
          : SafeArea(
              child: Center(
                heightFactor: 1,
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 640),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      spacing: 6,
                      children: [
                        SizedBox(
                          width: double.infinity,
                          child: FilledButton.icon(key: const ValueKey('insights-copy'), onPressed: canCopy ? () => _copy(context, ref, insights) : null, icon: const Icon(Icons.copy, size: 18), label: const Text('Sao chép cho Claude phân tích')),
                        ),
                        if (!canCopy && !(s?.loading ?? false))
                          Text('Chưa có nhóm khó hay thẻ hay quên để phân tích.', key: const ValueKey('insights-copy-hint'), textAlign: TextAlign.center, style: TextStyle(fontSize: 12, color: Theme.of(context).textMuted)),
                      ],
                    ),
                  ),
                ),
              ),
            ),
      body: HocTapBody(
        child: switch (async) {
          AsyncData(:final value) when value.error != null => ListView(children: [_PeriodPicker(days: value.days, onChanged: notifier.setDays), HocTapLoadError(what: 'thống kê nhóm khó', onRetry: notifier.reload)]),
          AsyncData(:final value) when value.insights != null => RefreshIndicator(
            onRefresh: notifier.reload,
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
              children: [
                _PeriodPicker(days: value.days, onChanged: notifier.setDays),
                SizedBox(height: 3, child: value.loading ? const LinearProgressIndicator(key: ValueKey('insights-loading')) : null),
                const SizedBox(height: 12),
                _Body(insights: value.insights!),
              ],
            ),
          ),
          AsyncError() => ListView(children: [HocTapLoadError(what: 'thống kê nhóm khó', onRetry: () => ref.invalidate(cardInsightsProvider(subjectId)))]),
          _ => const Center(child: CircularProgressIndicator()),
        },
      ),
    );
  }
}

/// Chọn kỳ 7 / 30 / 90 ngày. Cuộn ngang nếu máy hẹp / chữ lớn thay vì tràn.
class _PeriodPicker extends StatelessWidget {
  const _PeriodPicker({required this.days, required this.onChanged});

  final int days;
  final void Function(int days) onChanged;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
    child: SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: SegmentedButton<int>(
        key: const ValueKey('insights-days'),
        showSelectedIcon: false,
        segments: [for (final d in insightPeriods) ButtonSegment(value: d, label: Text('$d ngày'))],
        selected: {days},
        onSelectionChanged: (v) => onChanged(v.first),
      ),
    ),
  );
}

class _Body extends StatelessWidget {
  const _Body({required this.insights});

  final CardInsights insights;

  @override
  Widget build(BuildContext context) {
    final i = insights;
    final theme = Theme.of(context);
    final empty = !i.hasGroups;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: 14,
      children: [
        IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            spacing: 8,
            children: [
              Expanded(child: _Tile(key: const ValueKey('tile-reviews'), valueKey: const ValueKey('tile-reviews-value'), label: 'Lượt ôn', value: '${i.totals.reviews}')),
              Expanded(child: _Tile(key: const ValueKey('tile-notyet'), valueKey: const ValueKey('tile-notyet-value'), label: 'Chưa nhớ', value: '${i.totals.notYetPercent}%')),
              Expanded(child: _Tile(key: const ValueKey('tile-promoted'), valueKey: const ValueKey('tile-promoted-value'), label: 'Thẻ lên Hàng tuần', value: '${i.totals.promotedToWeekly}')),
            ],
          ),
        ),
        if (empty)
          _Panel(
            key: const ValueKey('insights-empty'),
            children: [Text('Chưa đủ dữ liệu: một nhóm cần ít nhất ${i.minCards} thẻ từng bị đánh Chưa nhớ mới hiện ở đây.', style: TextStyle(fontSize: 14, color: theme.textMuted))],
          )
        else ...[
          _GroupSection(keyName: 'kind', title: 'Theo loại', groups: i.byKind, minCards: i.minCards, labelOf: (g) => CardKind.fromApi(g.key) == CardKind.unknown ? g.label : CardKind.fromApi(g.key).label),
          _GroupSection(keyName: 'topic', title: 'Theo chủ đề', groups: i.byTopic, minCards: i.minCards, labelOf: (g) => g.label),
          _GroupSection(keyName: 'lesson', title: 'Theo buổi học', groups: i.byLesson, minCards: i.minCards, labelOf: (g) => g.label),
        ],
        if (i.hardestCards.isNotEmpty)
          _Panel(
            key: const ValueKey('hardest-section'),
            children: [
              const HocTapSectionTitle('Thẻ hay quên'),
              for (final c in i.hardestCards)
                Row(
                  key: ValueKey('hardest-${c.id}'),
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: 8,
                  children: [
                    Expanded(child: Text(c.phrase, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600))),
                    Flexible(child: Text('${c.notYetCount} lần chưa nhớ', textAlign: TextAlign.end, style: TextStyle(fontSize: 12, color: theme.textMuted))),
                  ],
                ),
            ],
          ),
        Text(
          'Nhóm tính trên toàn bộ lịch sử của thẻ (thẻ đã Chưa nhớ rồi Đã nhớ vẫn tính). Tổng lượt ôn chỉ tính trong kỳ đã chọn.',
          key: const ValueKey('insights-footnote'),
          style: TextStyle(fontSize: 12, color: theme.textFaint),
        ),
      ],
    );
  }
}

/// Khung một phần: viền mảnh, nền surface của theme.
class _Panel extends StatelessWidget {
  const _Panel({super.key, required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: scheme.surface, borderRadius: BorderRadius.circular(AppTheme.darkRadius), border: Border.all(color: scheme.onSurface.withValues(alpha: 0.14))),
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, spacing: 12, children: children),
    );
  }
}

class _Tile extends StatelessWidget {
  const _Tile({super.key, required this.valueKey, required this.label, required this.value});

  final Key valueKey;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: theme.colorScheme.surface, borderRadius: BorderRadius.circular(AppTheme.darkRadius), border: Border.all(color: theme.colorScheme.onSurface.withValues(alpha: 0.14))),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 4,
        children: [
          Text(label, style: TextStyle(fontSize: 12, color: theme.textMuted)),
          Text(value, key: valueKey, style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: theme.colorScheme.primary)),
        ],
      ),
    );
  }
}

/// Một phần "Theo loại / chủ đề / buổi học": các dòng đúng thứ tự server gửi; rỗng thì một dòng giải thích ngắn.
class _GroupSection extends StatelessWidget {
  const _GroupSection({required this.keyName, required this.title, required this.groups, required this.minCards, required this.labelOf});

  final String keyName;
  final String title;
  final List<InsightGroup> groups;
  final int minCards;
  final String Function(InsightGroup g) labelOf;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return _Panel(
      key: ValueKey('section-$keyName'),
      children: [
        HocTapSectionTitle(title),
        if (groups.isEmpty)
          Text('Chưa đủ dữ liệu (cần ít nhất $minCards thẻ từng chưa nhớ).', key: ValueKey('section-empty-$keyName'), style: TextStyle(fontSize: 13, color: theme.textFaint)),
        for (final g in groups)
          Column(
            key: ValueKey('row-$keyName-${g.key}'),
            crossAxisAlignment: CrossAxisAlignment.stretch,
            spacing: 4,
            children: [
              Text(labelOf(g), style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
              Text('${g.everNotYetCards}/${g.totalCards} thẻ từng chưa nhớ · ${g.percent}%', style: TextStyle(fontSize: 12, color: theme.textMuted)),
              ClipRRect(
                borderRadius: BorderRadius.circular(AppTheme.darkRadius),
                child: LinearProgressIndicator(key: ValueKey('bar-$keyName-${g.key}'), minHeight: 4, value: g.rate),
              ),
            ],
          ),
      ],
    );
  }
}

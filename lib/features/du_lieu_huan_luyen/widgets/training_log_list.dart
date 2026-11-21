import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../features/amber_brain/providers/brain_status_provider.dart';
import '../../../features/amber_brain/widgets/log_push_banner.dart';
import '../../../shared/theme/design_tokens.dart';
import '../../../shared/utils/vn_time.dart';
import '../../../shared/widgets/list_frame.dart';
import '../models/training_log.dart';
import '../providers/training_log_provider.dart';
import 'outcome_tag.dart';

/// "dd/MM HH:mm" theo giờ Việt Nam.
String formatLogTime(DateTime t) {
  final d = vnNow(t);
  String two(int n) => n.toString().padLeft(2, '0');
  return '${two(d.day)}/${two(d.month)} ${two(d.hour)}:${two(d.minute)}';
}

/// Đầu khung "Danh sách" của tầng 4: số mẫu đủ điều kiện (+ theo agent), cảnh báo đồng bộ log của amber-brain,
/// rồi 3 hàng chip lọc. Chỉ xem; không sửa nội dung log từ app.
class TrainingLogListHeader extends ConsumerWidget {
  const TrainingLogListHeader({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final connection = ref.watch(brainStatusProvider);
    final stats = ref.watch(trainingStatsProvider);
    final logPush = connection.shouldWarnLogPush ? logPushMessage(connection.status?.logPush, vietnamese: true) : null;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: 6,
      children: [
        Text(
          stats.when(
            loading: () => 'Đang tải số liệu...',
            error: (_, _) => 'Không tải được số liệu',
            data: (s) => '${s.eligible} mẫu đủ điều kiện train · ${s.total} dòng nhật ký',
          ),
          key: const ValueKey('training-stats'),
          style: DesignText.muted,
        ),
        if (stats.value case final s? when s.byAgent.isNotEmpty)
          Text(s.byAgent.map((a) => '${agentLabel(a.agent)}: ${a.eligible}').join(' · '), style: DesignText.muted),
        if (logPush != null)
          Container(
            key: const Key('log-push-banner'),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: DesignColors.danger.withValues(alpha: 0.1),
              border: Border.all(color: DesignColors.danger.withValues(alpha: 0.4)),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              spacing: 6,
              children: [
                const Icon(Icons.sync_problem_outlined, size: 16, color: DesignColors.danger),
                Expanded(child: Text(logPush, style: const TextStyle(fontSize: 13, color: DesignColors.danger))),
              ],
            ),
          ),
        const _Filters(),
      ],
    );
  }
}

/// Thân khung "Danh sách" của tầng 4: các dòng (lọc thêm theo [query] trên câu gốc / agent / công cụ của trang đã tải)
/// + "Tải thêm". Bấm một dòng → [onSelect]; dòng [selectedId] viền vàng.
class TrainingLogList extends ConsumerWidget {
  const TrainingLogList({super.key, required this.onSelect, this.selectedId, this.query = ''});

  final ValueChanged<TrainingLogSummary> onSelect;
  final String? selectedId;
  final String query;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final list = ref.watch(logListProvider);
    final q = query.trim().toLowerCase();
    bool match(TrainingLogSummary l) =>
        q.isEmpty || [l.userInput, l.agent, agentLabel(l.agent), l.toolName ?? ''].any((x) => x.toLowerCase().contains(q));
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: 8,
      children: list.when(
        loading: () => const [
          Padding(
            padding: EdgeInsets.all(24),
            child: Center(child: CircularProgressIndicator(color: DesignColors.gold)),
          ),
        ],
        error: (_, _) => [
          _Message('Không tải được nhật ký.', action: 'Thử lại', onAction: () => ref.invalidate(logListProvider)),
        ],
        data: (s) {
          final items = s.items.where(match).toList();
          return [
            if (items.isEmpty) const _Message('Chưa có dòng nhật ký nào khớp bộ lọc.'),
            for (final item in items) LogRow(item, selected: item.id == selectedId, onTap: () => onSelect(item)),
            if (s.hasMore)
              Center(
                child: s.loadingMore
                    ? const CircularProgressIndicator(color: DesignColors.gold)
                    : DesignButton.outline(
                        label: s.loadMoreError ? 'Không tải thêm được — thử lại' : 'Tải thêm',
                        onPressed: () => ref.read(logListProvider.notifier).loadMore(),
                      ),
              ),
          ];
        },
      ),
    );
  }
}

class _Message extends StatelessWidget {
  const _Message(this.text, {this.action, this.onAction});

  final String text;
  final String? action;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 16),
    child: Column(
      spacing: 8,
      children: [
        Text(text, textAlign: TextAlign.center, style: DesignText.muted),
        if (action != null) DesignButton.outline(label: action!, onPressed: onAction),
      ],
    ),
  );
}

/// 3 hàng chip lọc (cuộn ngang): agent (lấy từ thống kê) · kết quả · tuyến LOCAL / CLOUD.
class _Filters extends ConsumerWidget {
  const _Filters();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final f = ref.watch(logFilterProvider);
    final notifier = ref.read(logFilterProvider.notifier);
    // Danh sách agent lấy từ thống kê (chỉ agent đã có dữ liệu); chưa tải được thì chỉ còn "Mọi agent" (+ agent đang chọn).
    final agents = <String>{
      ...?ref.watch(trainingStatsProvider).value?.byAgent.map((a) => a.agent),
      ?f.agent,
    }.toList()..sort();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: 6,
      children: [
        DesignChipRow<String?>(
          items: [(null, 'Mọi agent'), for (final a in agents) (a, agentLabel(a))],
          selected: f.agent,
          onSelected: notifier.setAgent,
        ),
        DesignChipRow<LogOutcome?>(
          items: [(null, 'Mọi kết quả'), for (final o in LogOutcome.values) (o, o.label)],
          selected: f.outcome,
          onSelected: notifier.setOutcome,
        ),
        DesignChipRow<TrainingRoute?>(
          items: [(null, 'Mọi tuyến'), for (final r in TrainingRoute.values) (r, r.apiValue)],
          selected: f.route,
          onSelected: notifier.setRoute,
        ),
      ],
    );
  }
}

/// Một dòng nhật ký: giờ · agent · kết quả · công cụ · tuyến (kèm model khi CLOUD) · đã sửa / đã loại, rồi câu gốc 2 dòng.
class LogRow extends StatelessWidget {
  const LogRow(this.log, {super.key, required this.onTap, this.selected = false});

  final TrainingLogSummary log;
  final VoidCallback onTap;

  /// Dòng đang mở ở khung Nội dung — viền vàng.
  final bool selected;

  @override
  Widget build(BuildContext context) {
    return FrameTile(
      key: ValueKey('log-${log.id}'),
      onTap: onTap,
      borderColor: selected ? DesignColors.gold : null,
      padding: const EdgeInsets.all(10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 6,
        children: [
          Wrap(
            spacing: 6,
            runSpacing: 4,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Text(formatLogTime(log.createdAt), style: DesignText.muted),
              DesignPill(agentLabel(log.agent), color: DesignColors.muted),
              OutcomeTag(log.outcome),
              ToolStatus(toolName: log.toolName, toolOk: log.toolOk),
              if (log.route case final route?)
                DesignPill(
                  route == TrainingRoute.cloud && log.cloudModel != null ? 'CLOUD · ${log.cloudModel}' : route.apiValue,
                  color: route == TrainingRoute.cloud ? DesignColors.info : DesignColors.gold,
                ),
              if (log.hasCorrection || log.correctedOutput != null) const DesignPill('Đã sửa', color: DesignColors.success),
              if (log.excludeFromTraining) const DesignPill('Đã loại', color: DesignColors.muted),
            ],
          ),
          Text(
            log.userInput.isEmpty ? '(không có câu gốc)' : log.userInput,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: DesignText.body,
          ),
        ],
      ),
    );
  }
}

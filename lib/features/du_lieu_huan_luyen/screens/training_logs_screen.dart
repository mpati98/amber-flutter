import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../features/amber_brain/providers/brain_status_provider.dart';
import '../../../features/amber_brain/widgets/log_push_banner.dart';
import '../../../shared/theme/design_tokens.dart';
import '../../../shared/utils/vn_time.dart';
import '../../../shared/widgets/design_page.dart';
import '../../../shared/widgets/list_frame.dart';
import '../../../shared/widgets/overview_block.dart';
import '../models/training_log.dart';
import '../providers/training_log_provider.dart';
import '../widgets/outcome_tag.dart';

/// "dd/MM HH:mm" theo giờ Việt Nam.
String formatLogTime(DateTime t) {
  final d = vnNow(t);
  String two(int n) => n.toString().padLeft(2, '0');
  return '${two(d.day)}/${two(d.month)} ${two(d.hour)}:${two(d.minute)}';
}

/// Dữ liệu huấn luyện (Tầng 4): Tổng quan (số mẫu đủ điều kiện, theo agent, cảnh báo đồng bộ log) → khung có 3 hàng chip lọc
/// (agent, kết quả, tuyến) + các dòng nhật ký. Chỉ xem; không sửa nội dung log từ app.
class TrainingLogsScreen extends ConsumerWidget {
  const TrainingLogsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final list = ref.watch(logListProvider);
    final connection = ref.watch(brainStatusProvider);
    final stats = ref.watch(trainingStatsProvider);
    final logPush = connection.shouldWarnLogPush ? logPushMessage(connection.status?.logPush, vietnamese: true) : null;

    return DesignPage(
      title: 'Dữ liệu huấn luyện',
      backFallback: '/tang-kinh-cac',
      onRefresh: () async {
        ref.invalidate(trainingStatsProvider);
        ref.invalidate(logListProvider);
        await ref.read(logListProvider.future).catchError((_) => const LogListState());
      },
      overview: OverviewBlock(
        title: 'Tổng quan',
        labelWidth: 90,
        rows: [
          OverviewRow.muted(
            label: 'Đủ điều kiện',
            text: stats.when(
              loading: () => 'Đang tải số liệu...',
              error: (_, _) => 'Không tải được số liệu',
              data: (s) => '${s.eligible} mẫu đủ điều kiện train · ${s.total} dòng nhật ký',
            ),
          ),
          if (stats.value case final s? when s.byAgent.isNotEmpty)
            OverviewRow.muted(
              label: 'Theo agent',
              text: s.byAgent.map((a) => '${agentLabel(a.agent)}: ${a.eligible}').join(' · '),
            ),
        ],
        footer: logPush == null
            ? null
            : Container(
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
      ),
      content: (context, _) => ListFrame(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          spacing: 8,
          children: [
            const _Filters(),
            ...list.when(
              loading: () => const [
                Padding(
                  padding: EdgeInsets.all(24),
                  child: Center(child: CircularProgressIndicator(color: DesignColors.gold)),
                ),
              ],
              error: (_, _) => [
                _Message('Không tải được nhật ký.', action: 'Thử lại', onAction: () => ref.invalidate(logListProvider)),
              ],
              data: (s) => s.items.isEmpty
                  ? [const _Message('Chưa có dòng nhật ký nào khớp bộ lọc.')]
                  : [
                      for (final item in s.items) _LogRow(item),
                      if (s.hasMore)
                        Center(
                          child: s.loadingMore
                              ? const CircularProgressIndicator(color: DesignColors.gold)
                              : DesignButton.outline(
                                  label: s.loadMoreError ? 'Không tải thêm được — thử lại' : 'Tải thêm',
                                  onPressed: () => ref.read(logListProvider.notifier).loadMore(),
                                ),
                        ),
                    ],
            ),
          ],
        ),
      ),
      hint: 'Chạm vào một dòng để xem và đánh giá',
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
class _LogRow extends StatelessWidget {
  const _LogRow(this.log);

  final TrainingLogSummary log;

  @override
  Widget build(BuildContext context) {
    return FrameTile(
      key: ValueKey('log-${log.id}'),
      onTap: () => context.push('/tang-kinh-cac/du-lieu-huan-luyen/${log.id}'),
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

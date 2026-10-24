import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../features/amber_brain/providers/brain_status_provider.dart';
import '../../../features/amber_brain/widgets/log_push_banner.dart';
import '../../../shared/theme/app_theme.dart';
import '../../../shared/utils/vn_time.dart';
import '../../../shared/widgets/scroll_card.dart';
import '../../../shared/widgets/tag.dart';
import '../models/training_log.dart';
import '../providers/training_log_provider.dart';
import '../widgets/outcome_tag.dart';
import '../../../shared/widgets/app_bar_back.dart';

/// "dd/MM HH:mm" theo giờ Việt Nam.
String formatLogTime(DateTime t) {
  final d = vnNow(t);
  String two(int n) => n.toString().padLeft(2, '0');
  return '${two(d.day)}/${two(d.month)} ${two(d.hour)}:${two(d.minute)}';
}

/// Dữ liệu huấn luyện: nhật ký các lượt gọi mô hình của amber-brain. Chỉ xem; không sửa nội dung log từ app.
class TrainingLogsScreen extends ConsumerWidget {
  const TrainingLogsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final list = ref.watch(logListProvider);
    final connection = ref.watch(brainStatusProvider);
    Future<void> refresh() async {
      ref.invalidate(trainingStatsProvider);
      ref.invalidate(logListProvider);
      await ref
          .read(logListProvider.future)
          .catchError((_) => const LogListState());
    }

    return Scaffold(
      appBar: AppBar(
        leading: const AppBarBack(fallback: '/tang-kinh-cac'),
        title: const Text('Dữ liệu huấn luyện'),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 640),
          child: RefreshIndicator(
            onRefresh: refresh,
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              children: [
                if (connection.shouldWarnLogPush)
                  LogPushBanner(
                    status: connection.status?.logPush,
                    vietnamese: true,
                  ),
                const _StatsHeader(),
                const SizedBox(height: 16),
                const _Filters(),
                const SizedBox(height: 16),
                ...list.when(
                  loading: () => const [
                    Padding(
                      padding: EdgeInsets.all(32),
                      child: Center(child: CircularProgressIndicator()),
                    ),
                  ],
                  error: (_, _) => [
                    _Message(
                      'Không tải được nhật ký.',
                      action: 'Thử lại',
                      onAction: () => ref.invalidate(logListProvider),
                    ),
                  ],
                  data: (s) => s.items.isEmpty
                      ? [
                          const _Message(
                            'Chưa có dòng nhật ký nào khớp bộ lọc.',
                          ),
                        ]
                      : [
                          for (final item in s.items) _LogRow(item),
                          if (s.hasMore)
                            Padding(
                              padding: const EdgeInsets.only(top: 8),
                              child: s.loadingMore
                                  ? const Center(
                                      child: CircularProgressIndicator(),
                                    )
                                  : OutlinedButton(
                                      onPressed: () => ref
                                          .read(logListProvider.notifier)
                                          .loadMore(),
                                      child: Text(
                                        s.loadMoreError
                                            ? 'Không tải thêm được — thử lại'
                                            : 'Tải thêm',
                                      ),
                                    ),
                            ),
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

class _Message extends StatelessWidget {
  const _Message(this.text, {this.action, this.onAction});

  final String text;
  final String? action;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 24),
    child: Column(
      children: [
        Text(
          text,
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.white.withValues(alpha: 0.5)),
        ),
        if (action != null)
          TextButton(onPressed: onAction, child: Text(action!)),
      ],
    ),
  );
}

/// Dòng thống kê trên đầu: số mẫu đủ điều kiện train, tách theo agent.
class _StatsHeader extends ConsumerWidget {
  const _StatsHeader();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final style = TextStyle(
      fontSize: 13,
      height: 1.5,
      color: Colors.white.withValues(alpha: 0.7),
    );
    return ScrollCard(
      glow: ScrollCardGlow.kincha,
      child: ref
          .watch(trainingStatsProvider)
          .when(
            loading: () => Text('Đang tải số liệu...', style: style),
            error: (_, _) => Text('Không tải được số liệu', style: style),
            data: (s) => Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${s.eligible} mẫu đủ điều kiện train · ${s.total} dòng nhật ký',
                  style: style.copyWith(
                    color: AppColors.kincha200,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (s.byAgent.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    s.byAgent
                        .map((a) => '${agentLabel(a.agent)}: ${a.eligible}')
                        .join(' · '),
                    style: style,
                  ),
                ],
              ],
            ),
          ),
    );
  }
}

class _Filters extends ConsumerWidget {
  const _Filters();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final f = ref.watch(logFilterProvider);
    final notifier = ref.read(logFilterProvider.notifier);
    // Danh sách agent lấy từ thống kê (chỉ agent đã có dữ liệu); chưa tải được thì chỉ còn "Tất cả" (+ agent đang chọn).
    final agents = <String>{
      ...?ref.watch(trainingStatsProvider).value?.byAgent.map((a) => a.agent),
      ?f.agent,
    }.toList()..sort();

    Widget chip(String label, bool selected, VoidCallback onTap) => ChoiceChip(
      label: Text(label),
      selected: selected,
      onSelected: (_) => onTap(),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: 8,
          runSpacing: 4,
          children: [
            chip('Mọi agent', f.agent == null, () => notifier.setAgent(null)),
            for (final a in agents)
              chip(agentLabel(a), f.agent == a, () => notifier.setAgent(a)),
          ],
        ),
        const SizedBox(height: 4),
        Wrap(
          spacing: 8,
          runSpacing: 4,
          children: [
            chip(
              'Mọi kết quả',
              f.outcome == null,
              () => notifier.setOutcome(null),
            ),
            for (final o in LogOutcome.values)
              chip(o.label, f.outcome == o, () => notifier.setOutcome(o)),
          ],
        ),
        const SizedBox(height: 4),
        Wrap(
          spacing: 8,
          runSpacing: 4,
          children: [
            chip('Mọi tuyến', f.route == null, () => notifier.setRoute(null)),
            for (final route in TrainingRoute.values)
              chip(
                route.apiValue,
                f.route == route,
                () => notifier.setRoute(route),
              ),
          ],
        ),
      ],
    );
  }
}

class _LogRow extends StatelessWidget {
  const _LogRow(this.log);

  final TrainingLogSummary log;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        key: ValueKey('log-${log.id}'),
        borderRadius: BorderRadius.circular(8),
        onTap: () =>
            context.push('/tang-kinh-cac/du-lieu-huan-luyen/${log.id}'),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Wrap(
                spacing: 8,
                runSpacing: 4,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  Text(
                    formatLogTime(log.createdAt),
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.white.withValues(alpha: 0.5),
                    ),
                  ),
                  Tag(
                    label: agentLabel(log.agent),
                    color: AppColors.shuiro500,
                    foregroundColor: Colors.white.withValues(alpha: 0.8),
                  ),
                  OutcomeTag(log.outcome),
                  ToolStatus(toolName: log.toolName, toolOk: log.toolOk),
                  if (log.route case final route?)
                    Tag(
                      label:
                          route == TrainingRoute.cloud && log.cloudModel != null
                          ? 'CLOUD · ${log.cloudModel}'
                          : route.apiValue,
                      color: route == TrainingRoute.cloud
                          ? Theme.of(context).colorScheme.secondary
                          : Theme.of(context).colorScheme.primary,
                      foregroundColor: Theme.of(context).colorScheme.onSurface,
                    ),
                  if (log.hasCorrection || log.correctedOutput != null)
                    Tag(
                      label: 'Đã sửa',
                      color: Theme.of(context).colorScheme.tertiary,
                      foregroundColor: Theme.of(context).colorScheme.onSurface,
                    ),
                  if (log.excludeFromTraining)
                    Tag(
                      label: 'Đã loại',
                      color: Colors.white,
                      foregroundColor: Colors.white.withValues(alpha: 0.6),
                      borderAlpha: 0.2,
                    ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                log.userInput.isEmpty ? '(không có câu gốc)' : log.userInput,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

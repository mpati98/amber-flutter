import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../shared/widgets/scroll_card.dart';
import '../../../shared/widgets/tag.dart';
import '../models/project_summary.dart';
import '../models/task.dart';

/// Đường dẫn mở dự án và trang chi tiết đúng việc đó.
String attentionLocation(AttentionItem a) => '/du-an/${a.projectId}?task=${a.taskId}';

/// Thẻ "Cần chú ý": việc quá hạn / nằm im ở các dự án đang triển khai (summary.attention).
class AttentionCard extends StatelessWidget {
  const AttentionCard({super.key, required this.items, required this.loading, required this.failed});

  final List<AttentionItem>? items;
  final bool loading;
  final bool failed;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final muted = TextStyle(fontSize: 12, color: cs.onSurface.withValues(alpha: 0.6));
    final list = items;

    return ScrollCard(
      glow: ScrollCardGlow.shuiro,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: 8,
        children: [
          Row(
            children: [
              Expanded(child: Text('Cần chú ý', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: cs.primary))),
              if (list != null) Text('${list.length} việc', style: muted),
            ],
          ),
          if (list == null)
            Text(failed ? 'Không tải được việc cần chú ý.' : 'Đang tải...', style: muted)
          else if (list.isEmpty)
            Text('Không có việc nào cần chú ý.', style: muted)
          else
            for (final a in list)
              InkWell(
                key: ValueKey('attention-${a.taskId}'),
                onTap: () => context.push(attentionLocation(a)),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(minHeight: 48),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    child: Row(
                      spacing: 8,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(a.title, maxLines: 2, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 14, color: cs.onSurface)),
                              Text(
                                '${a.projectName} · ${TaskStatus.fromApi(a.status).label}',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: muted,
                              ),
                            ],
                          ),
                        ),
                        Tag(label: a.isOverdue ? 'Quá hạn ${a.days} ngày' : 'Nằm im ${a.days} ngày', color: cs.error),
                      ],
                    ),
                  ),
                ),
              ),
        ],
      ),
    );
  }
}

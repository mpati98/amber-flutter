import 'package:material_ui/material_ui.dart';
import 'package:go_router/go_router.dart';

import '../../../shared/widgets/scroll_card.dart';
import '../../../shared/widgets/tag.dart';
import '../models/project_summary.dart';
import '../models/task.dart';
import 'routines_card.dart' show nsdCardHeaderHeight;

/// Đường dẫn mở dự án và trang chi tiết đúng việc đó.
String attentionLocation(AttentionItem a) => '/du-an/${a.projectId}?task=${a.taskId}';

/// Thẻ "Cần chú ý": việc quá hạn / nằm im ở các dự án đang triển khai (summary.attention).
///
/// [fill] (bố cục dashboard của màn Dự án): thẻ lấp chiều cao cha cấp; đầu thẻ cao [nsdCardHeaderHeight] như
/// "Việc hằng ngày" bên cạnh (tiêu đề thẳng hàng), danh sách cuộn bên trong. Mặc định false: cao theo nội dung.
class AttentionCard extends StatelessWidget {
  const AttentionCard({super.key, required this.items, required this.loading, required this.failed, this.fill = false});

  final List<AttentionItem>? items;
  final bool loading;
  final bool failed;
  final bool fill;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final muted = TextStyle(fontSize: 12, color: cs.onSurface.withValues(alpha: 0.6));
    final list = items;

    final header = Row(
      children: [
        Expanded(
          child: Text(
            'Cần chú ý',
            maxLines: fill ? 1 : null,
            overflow: fill ? TextOverflow.ellipsis : null,
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: cs.primary),
          ),
        ),
        if (list != null) Text('${list.length} việc', style: muted),
      ],
    );
    final body = <Widget>[
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
    ];

    return ScrollCard(
      glow: ScrollCardGlow.shuiro,
      child: fill
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              spacing: 8,
              children: [
                SizedBox(height: nsdCardHeaderHeight, child: header),
                Expanded(
                  child: SingleChildScrollView(
                    key: const ValueKey('attention-scroll'),
                    child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, spacing: 8, children: body),
                  ),
                ),
              ],
            )
          : Column(crossAxisAlignment: CrossAxisAlignment.stretch, spacing: 8, children: [header, ...body]),
    );
  }
}

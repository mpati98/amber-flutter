import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../shared/theme/app_theme.dart';
import '../../../../shared/utils/date_format.dart';
import '../../../../shared/widgets/scroll_card.dart';
import '../../../nghi_su_duong/models/routine.dart' show weekdayShort;
import '../models/study_overview.dart';
import '../providers/hoc_tap_provider.dart';
import 'hoc_tap_common.dart';

/// "dd/MM" kèm thứ viết tắt của một ngày "YYYY-MM-DD": "CN 08/11". Ngày không đọc được → trả nguyên văn.
String weekdayDateLabel(String isoDate) {
  final d = DateTime.tryParse(isoDate);
  return d == null ? isoDate : '${weekdayShort(d.weekday)} ${formatDayMonth(isoDate)}';
}

/// Khối "Thẻ hôm nay" của Tổng quan cho môn đang chọn. Backend cũ chưa có khối `cards` → không hiện gì.
class CardsTodayBlock extends ConsumerWidget {
  const CardsTodayBlock({super.key, required this.subject});

  final SubjectOverview subject;

  Future<void> _open(BuildContext context, WidgetRef ref, String path) async {
    await context.push(path);
    ref.invalidate(studyOverviewProvider); // quay lại giữa chừng cũng phải thấy số thẻ đã ôn mới
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cards = subject.cards;
    if (cards == null) return const SizedBox.shrink();
    final theme = Theme.of(context);
    final id = subject.subjectId;
    final done = cards.planned > 0 && cards.finished >= cards.planned;
    final started = cards.finished > 0;
    final next = cards.nextReviewDay;

    return ScrollCard(
      child: Column(
        key: const ValueKey('cards-today'),
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: 10,
        children: [
          const HocTapSectionTitle('Thẻ hôm nay'),
          if (cards.planned == 0)
            Text('Thẻ hôm nay: chưa bắt đầu · tối đa ${cards.quota} thẻ', key: const ValueKey('cards-status'), style: const TextStyle(fontSize: 14))
          else if (done)
            Text('Hôm nay đã ôn xong ${cards.planned} thẻ', key: const ValueKey('cards-status'), style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: theme.success))
          else ...[
            Text('Đã ôn ${cards.finished} / ${cards.planned} thẻ', key: const ValueKey('cards-status'), style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
            ClipRRect(
              borderRadius: BorderRadius.circular(AppTheme.darkRadius),
              child: LinearProgressIndicator(key: const ValueKey('cards-progress'), minHeight: 4, value: (cards.finished / cards.planned).clamp(0.0, 1.0)),
            ),
          ],
          if (next != null) Text('Ngày ôn tập kế tiếp: ${weekdayDateLabel(next)}', key: const ValueKey('cards-next-review'), style: TextStyle(fontSize: 12, color: theme.textMuted)),
          if (!done)
            FilledButton(
              key: const ValueKey('cards-start'),
              onPressed: () => _open(context, ref, '/tra-dinh/hoc-tap/the/on?subjectId=$id'),
              child: Text(started ? 'Tiếp tục ôn' : 'Bắt đầu ôn'),
            ),
          // Hai nút phụ cạnh nhau; máy hẹp / chữ lớn thì tự xuống dòng thay vì tràn.
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              OutlinedButton.icon(
                key: const ValueKey('open-card-library'),
                onPressed: () => _open(context, ref, '/tra-dinh/hoc-tap/the?subjectId=$id'),
                icon: const Icon(Icons.style_outlined),
                label: const Text('Kho thẻ'),
              ),
              OutlinedButton.icon(
                key: const ValueKey('open-card-insights'),
                onPressed: () => _open(context, ref, '/tra-dinh/hoc-tap/the/thong-ke?subjectId=$id'),
                icon: const Icon(Icons.insights_outlined),
                label: const Text('Thống kê thẻ'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

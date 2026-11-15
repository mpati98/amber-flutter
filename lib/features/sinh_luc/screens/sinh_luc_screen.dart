import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../../shared/theme/design_tokens.dart';
import '../../../shared/utils/api_error.dart';
import '../../../shared/utils/vn_time.dart';
import '../../../shared/widgets/design_page.dart';
import '../../../shared/widgets/list_frame.dart';
import '../../../shared/widgets/overview_block.dart';
import '../models/sleep_log.dart';
import '../services/sleep_api.dart';
import '../utils/sleep_format.dart';
import '../widgets/sleep_form_sheet.dart';

/// `/sinh-luc`: giấc ngủ tự ghi mỗi sáng — đầu vào chỉ số Sức khoẻ (kinh tế amber-v4, cùng phút tập) trên màn chủ 3D.
/// Mở từ nút "Ghi giấc ngủ" trong bảng chi tiết của Amber.
class SinhLucScreen extends ConsumerWidget {
  const SinhLucScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(sleepHistoryProvider);
    final history = async.value;
    final today = history?.today ?? vnToday();
    final logs = history?.logs ?? const <SleepLog>[];
    final lastNight = logs.where((l) => l.date == today).firstOrNull;
    final week = logs.where((l) => l.date.compareTo(isoMinusDays(today, 6)) >= 0).toList();
    final avg = week.isEmpty ? null : week.fold<int>(0, (s, l) => s + l.sleepMinutes) ~/ week.length;

    Future<void> open([SleepLog? existing]) async {
      final saved = await showSleepForm(context, today: today, existing: existing);
      if (saved == true) ref.invalidate(sleepHistoryProvider);
    }

    return DesignPage(
      title: 'Sức khoẻ',
      onRefresh: () async => ref.refresh(sleepHistoryProvider.future),
      overview: OverviewBlock(
        title: 'Giấc ngủ',
        labelWidth: 90,
        rows: [
          OverviewRow.muted(
            label: 'Đêm qua',
            text: lastNight == null ? 'Chưa ghi' : '${sleepDuration(lastNight.sleepMinutes)}${lastNight.quality == null ? '' : ' · ${sleepQualityLabels[lastNight.quality]}'}',
            onTap: () => open(lastNight),
          ),
          OverviewRow.muted(label: 'TB 7 ngày', text: avg == null ? '–' : '${sleepDuration(avg)} (${week.length} đêm)'),
        ],
      ),
      content: (context, size) => ListFrame(
        child: switch (async) {
          AsyncValue(:final error?) when history == null => Padding(
            padding: const EdgeInsets.all(12),
            child: Text(apiErrorMessage(error, 'Không tải được giấc ngủ.'), style: DesignText.muted),
          ),
          _ when history == null => const Padding(padding: EdgeInsets.all(24), child: Center(child: CircularProgressIndicator())),
          _ when logs.isEmpty => Padding(
            padding: const EdgeInsets.all(12),
            child: Text('Chưa có đêm nào. Ghi mỗi sáng để Sức khoẻ dùng dữ liệu thật (chưa có thì đang dùng giá trị trung tính).', style: DesignText.muted),
          ),
          _ => FrameRows(
            children: [
              for (final l in logs)
                FrameRow(
                  key: ValueKey('sleep-${l.date}'),
                  glyph: '眠',
                  title: '${shortDate(l.date)} · ${sleepDuration(l.sleepMinutes)}',
                  subtitle: [if (l.quality != null) sleepQualityLabels[l.quality], if (l.note != null) l.note].join(' · ').ifEmpty(null),
                  onTap: () => open(l),
                ),
            ],
          ),
        },
      ),
      hint: 'Sức khoẻ = nửa giấc ngủ (6,5–8 giờ + chất lượng) + nửa vận động (30 phút/ngày), làm mượt qua nhiều ngày; debuff trừ thẳng. Bỏ lỡ một ngày không bị trừ.',
      footer: Center(
        child: DesignButton.primary(
          key: const ValueKey('sleep-add'),
          label: lastNight == null ? 'Ghi giấc ngủ đêm qua' : 'Ghi đêm khác',
          onPressed: () => open(),
          minHeight: 40,
        ),
      ),
    );
  }
}

extension on String {
  String? ifEmpty(String? fallback) => isEmpty ? fallback : this;
}

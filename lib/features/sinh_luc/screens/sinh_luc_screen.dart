import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../../shared/theme/design_tokens.dart';
import '../../../shared/utils/api_error.dart';
import '../../../shared/utils/vn_time.dart';
import '../../../shared/widgets/design_page.dart';
import '../../../shared/widgets/list_frame.dart';
import '../../../shared/widgets/overview_block.dart';
import '../models/health_inputs.dart';
import '../models/sleep_log.dart';
import '../services/health_inputs_api.dart';
import '../services/sleep_api.dart';
import '../utils/health_format.dart';
import '../utils/sleep_format.dart';
import '../widgets/check_in_form_sheet.dart';
import '../widgets/debuff_form_sheet.dart';
import '../widgets/sleep_form_sheet.dart';

enum _Tab { sleep, checkIn, debuff }

/// `/sinh-luc` — Sức khoẻ: mọi đầu vào Sức khoẻ của kinh tế amber-v4 (màn chủ 3D).
/// Giấc ngủ mỗi sáng (`/api/du-an/sleep`), check-in trưa / tối (`/api/du-an/check-ins`), debuff (`/api/du-an/debuffs`).
/// Mở từ nút "Ghi giấc ngủ" trong bảng chi tiết của Amber.
class SinhLucScreen extends ConsumerStatefulWidget {
  const SinhLucScreen({super.key});

  @override
  ConsumerState<SinhLucScreen> createState() => _SinhLucScreenState();
}

class _SinhLucScreenState extends ConsumerState<SinhLucScreen> {
  _Tab _tab = _Tab.sleep;

  @override
  Widget build(BuildContext context) {
    final sleepAsync = ref.watch(sleepHistoryProvider);
    final checkAsync = ref.watch(checkInHistoryProvider);
    final debuffAsync = ref.watch(debuffsProvider);
    final history = sleepAsync.value;
    final today = history?.today ?? checkAsync.value?.today ?? vnToday();
    final logs = history?.logs ?? const <SleepLog>[];
    final lastNight = logs.where((l) => l.date == today).firstOrNull;
    final week = logs.where((l) => l.date.compareTo(isoMinusDays(today, 6)) >= 0).toList();
    final avg = week.isEmpty ? null : week.fold<int>(0, (s, l) => s + l.sleepMinutes) ~/ week.length;
    final checks = checkAsync.value;
    final noon = checks?.find(today, 'noon');
    final evening = checks?.find(today, 'evening');
    final activeDebuffs = (debuffAsync.value ?? const <Debuff>[]).where((d) => d.active).toList();

    Future<void> openSleep([SleepLog? existing]) async {
      if (await showSleepForm(context, today: today, existing: existing) == true) ref.invalidate(sleepHistoryProvider);
    }

    Future<void> openCheckIn(String slot, [CheckIn? existing]) async {
      if (await showCheckInForm(context, today: today, slot: slot, existing: existing) == true) ref.invalidate(checkInHistoryProvider);
    }

    Future<void> openDebuff([Debuff? existing]) async {
      if (await showDebuffForm(context, today: today, existing: existing) == true) ref.invalidate(debuffsProvider);
    }

    return DesignPage(
      title: 'Sức khoẻ',
      onRefresh: () async {
        ref.invalidate(checkInHistoryProvider);
        ref.invalidate(debuffsProvider);
        await ref.refresh(sleepHistoryProvider.future).then((_) {});
      },
      overview: OverviewBlock(
        title: 'Hôm nay',
        labelWidth: 90,
        rows: [
          OverviewRow.muted(
            label: 'Đêm qua',
            text: lastNight == null ? 'Chưa ghi' : '${sleepDuration(lastNight.sleepMinutes)}${lastNight.quality == null ? '' : ' · ${sleepQualityLabels[lastNight.quality]}'}',
            onTap: () => openSleep(lastNight),
          ),
          OverviewRow.muted(label: 'TB 7 ngày', text: avg == null ? '–' : '${sleepDuration(avg)} (${week.length} đêm)'),
          OverviewRow.muted(
            label: 'Trưa',
            text: noon == null ? 'Chưa check-in' : 'Thể lực: ${staminaSelfLabels[noon.staminaSelf] ?? '–'}',
            onTap: () => openCheckIn('noon', noon),
          ),
          OverviewRow.muted(label: 'Tối', text: evening == null ? 'Chưa check-in' : eveningSummary(evening), onTap: () => openCheckIn('evening', evening)),
          OverviewRow.muted(
            label: 'Debuff',
            text: activeDebuffs.isEmpty ? 'Không có' : activeDebuffs.map((d) => '${debuffTitle(d)} (${debuffLevels[d.level]?.$1.toLowerCase() ?? d.level})').join(', '),
            onTap: () => setState(() => _tab = _Tab.debuff),
          ),
        ],
      ),
      content: (context, size) => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: 10,
        children: [
          DesignChipRow<_Tab>(
            items: const [(_Tab.sleep, 'Giấc ngủ'), (_Tab.checkIn, 'Check-in'), (_Tab.debuff, 'Debuff')],
            selected: _tab,
            onSelected: (t) => setState(() => _tab = t),
          ),
          ListFrame(
            child: switch (_tab) {
              _Tab.sleep => _sleepList(sleepAsync, logs, openSleep),
              _Tab.checkIn => _checkInList(checkAsync, openCheckIn),
              _Tab.debuff => _debuffList(debuffAsync, openDebuff),
            },
          ),
        ],
      ),
      hint: switch (_tab) {
        _Tab.sleep => 'Sức khoẻ = nửa giấc ngủ (6,5–8 giờ + chất lượng) + nửa vận động (30 phút/ngày), làm mượt qua nhiều ngày; debuff trừ thẳng. Bỏ lỡ một ngày không bị trừ.',
        _Tab.checkIn => 'Trưa: tự chấm thể lực. Tối: phút tập, phút thể thao (tính 1,5 lần), hoặc ngày nghỉ hợp lệ. Có check-in tối thì dùng số này thay phút buổi tập. Bỏ lỡ không bị phạt.',
        _Tab.debuff => 'Debuff trừ thẳng Sức khoẻ (nhẹ −10, vừa −25, nặng −40) tới khi đánh dấu "Đã khỏi", và trong thời gian đó việc trễ hạn không bị phạt.',
      },
      footer: Center(
        child: Wrap(
          spacing: 10,
          runSpacing: 8,
          alignment: WrapAlignment.center,
          children: switch (_tab) {
            _Tab.sleep => [
              DesignButton.primary(
                key: const ValueKey('sleep-add'),
                label: lastNight == null ? 'Ghi giấc ngủ đêm qua' : 'Ghi đêm khác',
                onPressed: () => openSleep(),
                minHeight: 40,
              ),
            ],
            _Tab.checkIn => [
              DesignButton.primary(key: const ValueKey('checkin-noon'), label: 'Check-in trưa', onPressed: () => openCheckIn('noon', noon), minHeight: 40),
              DesignButton.primary(key: const ValueKey('checkin-evening'), label: 'Check-in tối', onPressed: () => openCheckIn('evening', evening), minHeight: 40),
            ],
            _Tab.debuff => [DesignButton.primary(key: const ValueKey('debuff-add'), label: 'Thêm debuff', onPressed: () => openDebuff(), minHeight: 40)],
          },
        ),
      ),
    );
  }

  Widget _message(String text) => Padding(padding: const EdgeInsets.all(12), child: Text(text, style: DesignText.muted));
  static const _loading = Padding(padding: EdgeInsets.all(24), child: Center(child: CircularProgressIndicator()));

  Widget _sleepList(AsyncValue<SleepHistory> async, List<SleepLog> logs, void Function([SleepLog?]) open) => switch (async) {
    AsyncValue(:final error?) when async.value == null => _message(apiErrorMessage(error, 'Không tải được giấc ngủ.')),
    _ when async.value == null => _loading,
    _ when logs.isEmpty => _message('Chưa có đêm nào. Ghi mỗi sáng để Sức khoẻ dùng dữ liệu thật (chưa có thì đang dùng giá trị trung tính).'),
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
  };

  Widget _checkInList(AsyncValue<CheckInHistory> async, void Function(String, [CheckIn?]) open) => switch (async) {
    AsyncValue(:final error?) when async.value == null => _message(apiErrorMessage(error, 'Không tải được check-in.')),
    _ when async.value == null => _loading,
    AsyncValue(:final value?) when value.checkIns.isEmpty => _message('Chưa có check-in nào trong 14 ngày.'),
    AsyncValue(:final value?) => FrameRows(
      children: [
        for (final c in value.checkIns)
          FrameRow(key: ValueKey('checkin-${c.date}-${c.slot}'), glyph: c.isNoon ? '午' : '夕', title: checkInTitle(c), onTap: () => open(c.slot, c)),
      ],
    ),
    _ => _loading,
  };

  Widget _debuffList(AsyncValue<List<Debuff>> async, void Function([Debuff?]) open) => switch (async) {
    AsyncValue(:final error?) when async.value == null => _message(apiErrorMessage(error, 'Không tải được debuff.')),
    _ when async.value == null => _loading,
    AsyncValue(:final value?) when value.isEmpty => _message('Không có debuff nào trong 30 ngày.'),
    AsyncValue(:final value?) => FrameRows(
      children: [
        for (final d in value)
          FrameRow(key: ValueKey('debuff-${d.id}'), glyph: '病', title: debuffTitle(d), subtitle: debuffSubtitle(d), onTap: () => open(d)),
      ],
    ),
    _ => _loading,
  };
}

extension on String {
  String? ifEmpty(String? fallback) => isEmpty ? fallback : this;
}

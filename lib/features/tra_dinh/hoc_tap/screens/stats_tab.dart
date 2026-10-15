import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../shared/theme/app_theme.dart';
import '../../../../shared/utils/date_format.dart';
import '../../../../shared/utils/duration_format.dart';
import '../../../../shared/widgets/progress_bar.dart';
import '../../../../shared/widgets/scroll_card.dart';
import '../../../../shared/widgets/tag.dart';
import '../models/study_enums.dart';
import '../models/study_stats.dart';
import '../models/study_subject.dart';
import '../providers/hoc_tap_provider.dart';
import '../utils/async_view.dart';
import '../widgets/hoc_tap_common.dart';
import '../widgets/log_sheet.dart' show reasonChoices;
import '../widgets/stats_chart.dart';
import '../widgets/subject_sheet.dart';
import 'course_detail_screen.dart' show courseStatusColor;

const _weekdayNames = ['Thứ Hai', 'Thứ Ba', 'Thứ Tư', 'Thứ Năm', 'Thứ Sáu', 'Thứ Bảy', 'Chủ nhật'];
const _ranges = {'7': '7 ngày', '30': '30 ngày', 'all': 'Tất cả'};

/// "14/10/2026" từ "2026-10-14".
String formatFullDate(String iso) {
  final p = iso.split('-');
  return p.length == 3 ? '${p[2]}/${p[1]}/${p[0]}' : iso;
}

/// Tab Thống kê: khoảng + môn nằm trên URL `?tab=stats&range=7|30|all&subject=<id|all>`.
class StatsTab extends ConsumerWidget {
  const StatsTab({super.key, this.range, this.subject});

  final String? range;
  final String? subject;

  void _go(BuildContext context, String range, String? subjectId) => context.go('/tra-dinh?tab=stats&range=$range&subject=${subjectId ?? 'all'}');

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final subjectsAsync = ref.watch(studySubjectsProvider);
    final selectedId = ref.watch(selectedSubjectIdProvider);
    final r = _ranges.containsKey(range) ? range! : '30';

    return HocTapBody(
      onRefresh: () async {
        ref.invalidate(studyStatsProvider);
        ref.invalidate(studySubjectsProvider);
        await ref.read(studySubjectsProvider.future);
      },
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
        children: [
          switch (subjectsAsync.settled) {
            AsyncData(:final value) when value.isEmpty => Column(
              spacing: 10,
              children: [
                Text('Chưa có môn học nào nên chưa có thống kê.', style: TextStyle(color: Theme.of(context).textMuted)),
                FilledButton(key: const ValueKey('stats-create-subject'), onPressed: () => showSubjectSheet(context), child: const Text('Tạo môn đầu tiên')),
              ],
            ),
            AsyncData(:final value) => _Loaded(
              subjects: value,
              range: r,
              // subject=all → tất cả môn; không có / id lạ → môn đang chọn ở Tổng quan (hoặc môn đầu tiên).
              subjectId: subject == 'all' ? null : (value.any((s) => s.id == subject) ? subject : (value.any((s) => s.id == selectedId) ? selectedId : value.first.id)),
              onGo: (rg, id) => _go(context, rg, id),
            ),
            AsyncError() => HocTapLoadError(what: 'môn học', onRetry: () => ref.invalidate(studySubjectsProvider)),
            _ => const Padding(padding: EdgeInsets.symmetric(vertical: 48), child: Center(child: CircularProgressIndicator())),
          },
        ],
      ),
    );
  }
}

class _Loaded extends ConsumerWidget {
  const _Loaded({required this.subjects, required this.range, required this.subjectId, required this.onGo});

  final List<StudySubject> subjects;
  final String range;
  final String? subjectId;
  final void Function(String range, String? subjectId) onGo;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(studyStatsProvider(StatsQuery(subjectId: subjectId, range: range)));
    Widget chip(String label, bool selected, VoidCallback onTap, String key) => ChoiceChip(
      key: ValueKey(key),
      label: Text(label),
      selected: selected,
      showCheckmark: false,
      selectedColor: AppColors.kincha400,
      labelStyle: TextStyle(fontSize: 13, color: selected ? AppColors.ink950 : null),
      onSelected: (_) => onTap(),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: 12,
      children: [
        Wrap(spacing: 6, runSpacing: 6, children: [for (final e in _ranges.entries) chip(e.value, e.key == range, () => onGo(e.key, subjectId), 'range-${e.key}')]),
        Wrap(
          spacing: 6,
          runSpacing: 6,
          children: [
            chip('Tất cả môn', subjectId == null, () => onGo(range, null), 'stats-subject-all'),
            for (final s in subjects) chip(s.name, subjectId == s.id, () => onGo(range, s.id), 'stats-subject-${s.id}'),
          ],
        ),
        switch (async.settled) {
          AsyncData(:final value) => _StatsBody(stats: value, range: range, subjects: subjects, single: subjectId != null),
          AsyncError() => HocTapLoadError(what: 'thống kê', onRetry: () => ref.invalidate(studyStatsProvider)),
          _ => const Padding(padding: EdgeInsets.symmetric(vertical: 48), child: Center(child: CircularProgressIndicator())),
        },
      ],
    );
  }
}

class _StatsBody extends StatelessWidget {
  const _StatsBody({required this.stats, required this.range, required this.subjects, required this.single});

  final StudyStats stats;
  final String range;
  final List<StudySubject> subjects;
  final bool single;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final s = stats;
    final goalText = s.goalDaysTotal == 0 ? '—' : '${s.goalDaysMet}/${s.goalDaysTotal}';
    final rangeText = _ranges[range] ?? range;
    final summary = '$rangeText, trung bình ${s.avgPerDay} phút mỗi ngày, đạt mục tiêu ${s.goalDaysMet}/${s.goalDaysTotal} ngày';
    final maxCourse = s.byCourse.fold<int>(0, (m, c) => c.minutes > m ? c.minutes : m);
    final reasons = [for (final e in reasonChoices.entries) if (s.reasonCounts.of(e.key) > 0) '${e.value} ${s.reasonCounts.of(e.key)}'];
    final deltas = [
      for (final d in s.overallDeltaDays)
        if (d.deltaDays != null) (name: subjects.where((x) => x.id == d.subjectId).firstOrNull?.name, delta: d.deltaDays!),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: 12,
      children: [
        if (!s.hasLogs)
          ScrollCard(
            child: Column(
              key: const ValueKey('stats-empty'),
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 6,
              children: [
                const HocTapSectionTitle('Chưa có buổi học'),
                Text('Chưa có buổi học nào trong khoảng này. Ghi buổi học đầu tiên ở tab Tổng quan để bắt đầu có thống kê.', style: TextStyle(fontSize: 13, color: theme.textMuted)),
              ],
            ),
          )
        else ...[
          Row(
            spacing: 8,
            children: [
              Expanded(child: _Tile(label: 'Tổng thời gian', value: formatDuration(s.totalMinutes), keyName: 'tile-total')),
              Expanded(child: _Tile(label: 'Số buổi', value: '${s.logCount}', keyName: 'tile-logs')),
            ],
          ),
          Row(
            spacing: 8,
            children: [
              Expanded(child: _Tile(label: 'Trung bình/ngày', value: formatDuration(s.avgPerDay), keyName: 'tile-avg')),
              Expanded(child: _Tile(label: 'Ngày đạt mục tiêu', value: goalText, keyName: 'tile-goal')),
            ],
          ),
          ScrollCard(
            glow: ScrollCardGlow.kincha,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              spacing: 10,
              children: [
                HocTapSectionTitle(s.isWeekly ? 'Phút theo tuần' : 'Phút theo ngày'),
                StatsBarChart(series: s.series, weekly: s.isWeekly, summary: summary),
              ],
            ),
          ),
          ScrollCard(
            child: Column(
              key: const ValueKey('by-course'),
              crossAxisAlignment: CrossAxisAlignment.stretch,
              spacing: 10,
              children: [
                const HocTapSectionTitle('Theo khóa'),
                for (final c in s.byCourse)
                  Column(
                    key: ValueKey('by-course-${c.courseId ?? 'review'}'),
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    spacing: 4,
                    children: [
                      Row(
                        children: [
                          Expanded(child: Text(c.courseId == null ? 'Ôn tập' : c.title, style: const TextStyle(fontSize: 14))),
                          Text('${formatDuration(c.minutes)} · ${c.logCount} buổi', style: TextStyle(fontSize: 12, color: theme.textMuted)),
                        ],
                      ),
                      ProgressBar(value: c.minutes.toDouble(), max: maxCourse.toDouble()),
                    ],
                  ),
              ],
            ),
          ),
          Row(
            spacing: 8,
            children: [
              Expanded(child: _Tile(label: 'Ngày học dài nhất', value: s.longestDay == null ? '—' : '${formatDayMonth(s.longestDay!.date)} · ${formatDuration(s.longestDay!.minutes)}', keyName: 'tile-longest')),
              Expanded(child: _Tile(label: 'Thứ học nhiều nhất', value: s.topWeekday == null ? '—' : '${_weekdayNames[(s.topWeekday!.weekday - 1).clamp(0, 6)]} · ${formatDuration(s.topWeekday!.minutes)}', keyName: 'tile-weekday')),
            ],
          ),
          if (reasons.isNotEmpty)
            ScrollCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: 6,
                children: [const HocTapSectionTitle('Lý do dừng sớm'), Text(reasons.join(' · '), key: const ValueKey('reasons'), style: const TextStyle(fontSize: 14))],
              ),
            ),
        ],
        if (s.vsPlan.isNotEmpty) _PlanCard(stats: s, deltas: deltas, single: single),
      ],
    );
  }
}

class _Tile extends StatelessWidget {
  const _Tile({required this.label, required this.value, required this.keyName});

  final String label;
  final String value;
  final String keyName;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      key: ValueKey(keyName),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(border: Border.all(color: theme.colorScheme.onSurface.withValues(alpha: 0.12)), borderRadius: BorderRadius.circular(AppTheme.darkRadius)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: TextStyle(fontSize: 12, color: theme.textMuted)),
          const SizedBox(height: 2),
          Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}

class _PlanCard extends StatelessWidget {
  const _PlanCard({required this.stats, required this.deltas, required this.single});

  final StudyStats stats;
  final List<({String? name, int delta})> deltas;
  final bool single;

  String _line(PlanEntry e) {
    final delta = deltaLabel(e.deltaDays);
    if (e.status == CourseStatus.done) {
      return ['Xong ${e.finishedDate == null ? '—' : formatDayMonth(e.finishedDate!)}', ?delta].join(' · ');
    }
    return [
      e.forecastFinishDate == null ? 'Chưa có dự kiến xong' : 'Dự kiến xong ${formatFullDate(e.forecastFinishDate!)}',
      if (e.baselineFinishDate != null) 'gốc ${formatDayMonth(e.baselineFinishDate!)}',
      ?delta,
    ].join(' · ');
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ScrollCard(
      child: Column(
        key: const ValueKey('vs-plan'),
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: 10,
        children: [
          const HocTapSectionTitle('So với kế hoạch'),
          for (final e in stats.vsPlan)
            Column(
              key: ValueKey('plan-${e.courseId}'),
              crossAxisAlignment: CrossAxisAlignment.stretch,
              spacing: 4,
              children: [
                Row(
                  spacing: 8,
                  children: [
                    Expanded(child: Text(e.title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600))),
                    Tag(label: e.status.label, color: courseStatusColor(context, e.status), variant: TagVariant.tonal),
                    Text('${e.progressPct}%', style: TextStyle(fontSize: 12, color: theme.textMuted)),
                  ],
                ),
                ProgressBar(value: e.progressPct.toDouble(), max: 100),
                Text(_line(e), key: ValueKey('plan-line-${e.courseId}'), style: TextStyle(fontSize: 12, color: e.deltaDays == null ? theme.textMuted : deltaColor(context, e.deltaDays!))),
              ],
            ),
          for (final (i, d) in deltas.indexed)
            Text(
              '${single || d.name == null ? '' : '${d.name} · '}Cả lộ trình: ${deltaLabel(d.delta)}',
              key: ValueKey('overall-$i'),
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: deltaColor(context, d.delta)),
            ),
        ],
      ),
    );
  }
}

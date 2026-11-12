import 'package:material_ui/material_ui.dart';

import '../../../../shared/theme/design_tokens.dart';
import '../../../../shared/utils/date_format.dart';
import '../../../../shared/utils/duration_format.dart';
import '../../../../shared/widgets/list_frame.dart';
import '../../../../shared/widgets/overview_block.dart';
import '../models/study_overview.dart';
import 'missing_reason_sheet.dart';
import 'subject_sheet.dart';

/// Khối "Tổng quan hôm nay" của Trà Đình (design/ref/tra-dinh.html), thay cho thẻ Hôm nay cũ (bỏ vòng tiến độ và dải 7 chấm):
/// Hôm nay (phút / mục tiêu · còn bao nhiêu) · Chuỗi · Tuần này · hộp "Thiếu N ngày" bấm mở danh sách ngày.
class TodayOverview extends StatelessWidget {
  const TodayOverview({super.key, required this.overview, required this.subject});

  final StudyOverview overview;
  final SubjectOverview subject;

  @override
  Widget build(BuildContext context) {
    final today = subject.today;
    final goal = subject.goalMinutes;
    final week = overview.week;
    // Chuỗi ngày và ngày thiếu lý do do overview tính; backend cũ không có → ẩn. Môn không mục tiêu thì không có chuỗi.
    final streak = goal == null ? null : subject.streak;
    final pending = [...subject.pendingReasonDates]..sort((a, b) => b.compareTo(a));

    return OverviewBlock(
      key: const ValueKey('today-main'),
      title: 'Tổng quan hôm nay',
      labelWidth: 90,
      rows: [
        OverviewRow(
          label: 'Hôm nay',
          child: Wrap(
            spacing: 6,
            runSpacing: 4,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              if (goal == null) ...[
                Text('${today.minutes} phút', key: const ValueKey('today-minutes'), style: DesignText.muted),
                InkWell(
                  key: const ValueKey('set-goal'),
                  onTap: () => showSubjectSheet(context, subjectId: subject.subjectId),
                  child: const Text('Đặt mục tiêu ›', style: TextStyle(fontSize: 13, color: DesignColors.gold)),
                ),
              ] else ...[
                Text('${today.minutes} / $goal phút', key: const ValueKey('today-minutes'), style: DesignText.muted),
                if (!today.done && goal > today.minutes)
                  Text(
                    '· còn ${goal - today.minutes} phút để đủ mục tiêu',
                    key: const ValueKey('today-remaining'),
                    style: DesignText.muted,
                  ),
                if (today.done) const DesignPill('Đủ mục tiêu', color: DesignColors.success),
              ],
              if (today.reason case final r?) DesignPill('Dừng sớm: ${r.label}', color: DesignColors.warning),
            ],
          ),
        ),
        if (streak != null)
          OverviewRow(label: 'Chuỗi', child: Text('$streak ngày', key: const ValueKey('today-streak'), style: DesignText.muted)),
        if (week.goalMinutes > 0)
          OverviewRow(
            label: 'Tuần này',
            child: Text(
              '${formatDuration(week.minutes)} / ${formatDuration(week.goalMinutes)}',
              key: const ValueKey('week-summary'),
              style: DesignText.muted,
            ),
          ),
      ],
      footer: pending.isEmpty ? null : _PendingBox(subject: subject, dates: pending),
    );
  }
}

/// Hộp cảnh báo vàng "⚠ Thiếu N ngày gần đây · bấm để xem"; mở ra liệt kê ngày + nút nhập lý do (sheet đi lần lượt từng ngày).
class _PendingBox extends StatefulWidget {
  const _PendingBox({required this.subject, required this.dates});

  final SubjectOverview subject;
  final List<String> dates;

  @override
  State<_PendingBox> createState() => _PendingBoxState();
}

class _PendingBoxState extends State<_PendingBox> {
  bool _open = false;

  @override
  Widget build(BuildContext context) {
    final n = widget.dates.length;
    return Material(
      color: const Color(0xFF2A2208),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: const BorderSide(color: Color(0xFF6B5A1C)),
      ),
      child: InkWell(
        key: const ValueKey('today-pending'),
        borderRadius: BorderRadius.circular(8),
        onTap: () => setState(() => _open = !_open),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 4,
            children: [
              Text(
                '⚠ Thiếu lý do $n ngày gần đây · ${_open ? 'bấm để thu gọn' : 'bấm để xem'}',
                style: const TextStyle(fontSize: 13, color: DesignColors.gold),
              ),
              if (_open) ...[
                Text(
                  widget.dates.map(formatDayMonth).join(', '),
                  key: const ValueKey('today-pending-dates'),
                  style: const TextStyle(fontSize: 13, color: Color(0xFFD8C98F)),
                ),
                InkWell(
                  key: const ValueKey('today-pending-open'),
                  onTap: () => showMissingReasonSheet(
                    context,
                    subjectId: widget.subject.subjectId,
                    subjectName: widget.subject.name,
                    goalMinutes: widget.subject.goalMinutes ?? 0,
                    dates: widget.dates,
                  ),
                  child: const Padding(
                    padding: EdgeInsets.symmetric(vertical: 4),
                    child: Text('Nhập lý do ›', style: TextStyle(fontSize: 13, color: DesignColors.gold, fontWeight: FontWeight.w700)),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

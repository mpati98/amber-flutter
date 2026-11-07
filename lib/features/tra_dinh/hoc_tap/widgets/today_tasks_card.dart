import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../shared/theme/app_theme.dart';
import '../../../../shared/utils/date_format.dart';
import '../../../../shared/widgets/scroll_card.dart';
import '../../../nghi_su_duong/models/routine.dart' show weekdayShort;
import '../models/study_log.dart';
import '../models/study_overview.dart';
import '../providers/hoc_tap_provider.dart';
import '../utils/log_labels.dart';
import '../utils/next_action.dart';
import 'course_form_sheet.dart';
import 'hoc_tap_common.dart';
import 'log_sheet.dart';
import 'overview_cards.dart';

/// "dd/MM" kèm thứ viết tắt của một ngày "YYYY-MM-DD": "CN 08/11". Ngày không đọc được → trả nguyên văn.
String weekdayDateLabel(String isoDate) {
  final d = DateTime.tryParse(isoDate);
  return d == null
      ? isoDate
      : '${weekdayShort(d.weekday)} ${formatDayMonth(isoDate)}';
}

/// Dòng phụ của hàng Luyện AI: số phút đã luyện hôm nay. Backend cũ không trả `minutesByActivity` thì không khẳng định
/// "0 phút" (chưa chắc đúng), giữ câu giới thiệu cũ.
String _practiceSubtitle(MinutesByActivity m) {
  if (!m.hasData) return 'Trò chuyện, làm bài test, xem trình độ';
  return m.practice > 0
      ? 'Đã luyện ${m.practice} phút hôm nay'
      : 'Trò chuyện, làm bài test · 0 phút';
}

/// Khối "Việc hôm nay": Ôn thẻ, Học bài tiếp, Luyện nói với AI. Chỉ việc tiếp theo ([nextTodayAction]) có nút vàng.
class TodayTasksCard extends ConsumerWidget {
  const TodayTasksCard({super.key, required this.subject});

  final SubjectOverview subject;

  Future<void> _openCards(BuildContext context, WidgetRef ref) async {
    await context.push(
      '/tra-dinh/hoc-tap/the/on?subjectId=${subject.subjectId}',
    );
    ref.invalidate(
      studyOverviewProvider,
    ); // quay lại giữa chừng cũng phải thấy số thẻ đã ôn mới
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final action = nextTodayAction(subject);
    final cards = subject.cards;
    final next = subject.next;
    final logs =
        ref.watch(studyTodayLogsProvider(subject.subjectId)).value ??
        const <StudyLog>[];

    return ScrollCard(
      child: Column(
        key: const ValueKey('today-tasks'),
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: 4,
        children: [
          const HocTapSectionTitle('Việc hôm nay'),
          // Backend cũ chưa có khối `cards` thì không hiện hàng Ôn thẻ.
          if (cards != null)
            _cardsRow(
              context,
              ref,
              theme,
              cards,
              action == TodayAction.reviewCards,
            ),
          if (next != null)
            _TaskRow(
              key: const ValueKey('task-lesson'),
              icon: Icons.menu_book_outlined,
              title: next.minutes == null
                  ? next.sectionTitle
                  : '${next.sectionTitle} · ${next.minutes} phút',
              subtitle: next.courseTitle,
              button: 'Học tiếp',
              primary: action == TodayAction.nextLesson,
              onTap: () =>
                  context.push('/tra-dinh/hoc-tap/courses/${next.courseId}'),
            )
          else
            _TaskRow(
              key: const ValueKey('task-lesson'),
              icon: Icons.menu_book_outlined,
              title: 'Học bài tiếp',
              subtitle: 'Chưa có khóa đang học',
              button: 'Thêm khóa ›',
              quiet: true,
              onTap: () =>
                  showCourseFormSheet(context, subjectId: subject.subjectId),
            ),
          // Luôn mở được và không có dấu tick riêng: luyện bao nhiêu cũng được.
          _TaskRow(
            key: const ValueKey('task-practice'),
            icon: Icons.record_voice_over_outlined,
            title: 'Luyện nói với AI',
            subtitle: _practiceSubtitle(subject.today.byActivity),
            button: 'Luyện',
            primary: action == TodayAction.practice,
            onTap: () => context.push(
              '/tra-dinh/luyen-tap?subjectId=${subject.subjectId}',
            ),
          ),
          if (logs.isNotEmpty) ...[
            const Divider(height: 20),
            for (final l in logs) _LogRow(log: l),
          ],
          Align(
            alignment: Alignment.centerLeft,
            // Label dài: để Text tự xuống dòng thay vì tràn khi chữ phóng to (TextButton.icon không xuống dòng).
            child: TextButton(
              key: const ValueKey('manual-log'),
              onPressed: () =>
                  showLogSheet(context, subjectId: subject.subjectId),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                spacing: 8,
                children: [
                  Icon(Icons.edit_note),
                  Flexible(child: Text('Ghi buổi học thủ công')),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _cardsRow(
    BuildContext context,
    WidgetRef ref,
    ThemeData theme,
    CardsToday cards,
    bool primary,
  ) {
    final next = cards.nextReviewDay;
    // Môn chắc chắn chưa có thẻ (total == 0): không có gì để ôn, chỉ mời nhập thẻ. Không phải việc cần làm → không nút vàng.
    if (cards.total == 0) {
      return _TaskRow(
        key: const ValueKey('task-cards'),
        icon: Icons.style_outlined,
        title: 'Ôn thẻ',
        statusKey: const ValueKey('cards-status'),
        status: 'Chưa có thẻ',
        button: 'Nhập thẻ ›',
        buttonKey: const ValueKey('cards-import'),
        quiet: true,
        onTap: () => context.push(
          '/tra-dinh/hoc-tap/the/them?subjectId=${subject.subjectId}',
        ),
      );
    }
    final done = cards.planned > 0 && cards.finished >= cards.planned;
    if (done) {
      return _TaskRow(
        key: const ValueKey('task-cards'),
        icon: Icons.style_outlined,
        title: 'Ôn thẻ',
        statusKey: const ValueKey('cards-status'),
        status: '${cards.planned} / ${cards.planned} · xong',
        subtitle: next == null
            ? null
            : 'Ngày ôn tập kế tiếp: ${weekdayDateLabel(next)}',
        subtitleKey: const ValueKey('cards-next-review'),
        done: true,
      );
    }
    return _TaskRow(
      key: const ValueKey('task-cards'),
      icon: Icons.style_outlined,
      title: 'Ôn thẻ',
      statusKey: const ValueKey('cards-status'),
      status: cards.planned == 0
          ? 'Chưa bắt đầu · tối đa ${cards.quota} thẻ'
          : '${cards.finished} / ${cards.planned} thẻ',
      subtitle: next == null
          ? null
          : 'Ngày ôn tập kế tiếp: ${weekdayDateLabel(next)}',
      subtitleKey: const ValueKey('cards-next-review'),
      button: cards.finished > 0 ? 'Tiếp tục' : 'Bắt đầu',
      buttonKey: const ValueKey('cards-start'),
      primary: primary,
      onTap: () => _openCards(context, ref),
    );
  }
}

/// Một hàng việc: icon, tên + trạng thái, và một nút bên phải (vàng khi [primary], viền khi không, chữ khi [quiet]).
class _TaskRow extends StatelessWidget {
  const _TaskRow({
    super.key,
    required this.icon,
    required this.title,
    this.status,
    this.statusKey,
    this.subtitle,
    this.subtitleKey,
    this.button,
    this.buttonKey,
    this.primary = false,
    this.quiet = false,
    this.done = false,
    this.onTap,
  });

  final IconData icon;
  final String title;
  final String? status;
  final Key? statusKey;
  final String? subtitle;
  final Key? subtitleKey;
  final String? button;
  final Key? buttonKey;
  final bool primary;
  final bool quiet;
  final bool done;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final style = ButtonStyle(
      visualDensity: VisualDensity.compact,
      padding: WidgetStateProperty.all(
        const EdgeInsets.symmetric(horizontal: 14),
      ),
    );
    final b = button;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        spacing: 12,
        children: [
          Icon(icon, size: 22, color: done ? theme.success : theme.textMuted),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 2,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (status != null)
                  Text(
                    status!,
                    key: statusKey,
                    style: TextStyle(
                      fontSize: 13,
                      color: done ? theme.success : null,
                    ),
                  ),
                if (subtitle != null)
                  Text(
                    subtitle!,
                    key: subtitleKey,
                    style: TextStyle(fontSize: 12, color: theme.textMuted),
                  ),
              ],
            ),
          ),
          if (done)
            Icon(
              Icons.check_circle,
              key: const ValueKey('task-done'),
              color: theme.success,
            )
          else if (b != null)
            // Giới hạn bề ngang nút: chữ phóng to thì nhãn nút xuống dòng, không đẩy hàng tràn khỏi thẻ.
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 124),
              child: primary
                  ? FilledButton(
                      key: buttonKey,
                      style: style,
                      onPressed: onTap,
                      child: Text(b, textAlign: TextAlign.center),
                    )
                  : quiet
                  ? TextButton(
                      key: buttonKey,
                      onPressed: onTap,
                      child: Text(b, textAlign: TextAlign.center),
                    )
                  : OutlinedButton(
                      key: buttonKey,
                      style: style,
                      onPressed: onTap,
                      child: Text(b, textAlign: TextAlign.center),
                    ),
            ),
        ],
      ),
    );
  }
}

class _LogRow extends StatelessWidget {
  const _LogRow({required this.log});

  final StudyLog log;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final sections = log.sections
        .map((s) => s.markedDone ? '${s.title} ✓' : s.title)
        .join(', ');
    return InkWell(
      key: ValueKey('today-log-${log.id}'),
      onTap: () => showLogSheet(context, editing: log),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 48,
              child: Text(
                vnClock(log.createdAt),
                style: TextStyle(fontSize: 12, color: theme.textMuted),
              ),
            ),
            SizedBox(
              width: 44,
              child: Text(
                '${log.minutes}p',
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            Expanded(
              child: Text(
                [
                  logTitle(
                    activity: log.activity,
                    courseTitle: log.courseTitle,
                  ),
                  if (sections.isNotEmpty) sections,
                ].join(' · '),
                style: TextStyle(fontSize: 12, color: theme.textMuted),
              ),
            ),
            Icon(Icons.edit_outlined, size: 14, color: theme.textFaint),
          ],
        ),
      ),
    );
  }
}

import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../shared/theme/design_tokens.dart';
import '../../../../shared/utils/date_format.dart';
import '../../../../shared/widgets/list_frame.dart';
import '../../../nghi_su_duong/models/routine.dart' show weekdayShort;
import '../models/study_log.dart';
import '../models/study_overview.dart';
import '../providers/hoc_tap_provider.dart';
import '../utils/log_labels.dart';
import '../utils/next_action.dart';
import 'course_form_sheet.dart';
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

/// Các dòng việc hôm nay trong khung của Trà Đình (design/ref/tra-dinh.html): Ôn thẻ, Học bài tiếp, Luyện nói với AI,
/// rồi các buổi đã ghi hôm nay (bấm để sửa). Chỉ việc tiếp theo ([nextTodayAction]) có nút vàng.
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
    final action = nextTodayAction(subject);
    final cards = subject.cards;
    final next = subject.next;
    final logs =
        ref.watch(studyTodayLogsProvider(subject.subjectId)).value ??
        const <StudyLog>[];

    return Column(
        key: const ValueKey('today-tasks'),
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: 8,
        children: [
          // Backend cũ chưa có khối `cards` thì không hiện hàng Ôn thẻ.
          if (cards != null)
            _cardsRow(
              context,
              ref,
              cards,
              action == TodayAction.reviewCards,
            ),
          if (next != null)
            _TaskRow(
              key: const ValueKey('task-lesson'),
              glyph: '學',
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
              glyph: '學',
              title: 'Học bài tiếp',
              subtitle: 'Chưa có khóa đang học',
              button: 'Thêm khóa ›',
              onTap: () =>
                  showCourseFormSheet(context, subjectId: subject.subjectId),
            ),
          // Luôn mở được và không có dấu tick riêng: luyện bao nhiêu cũng được.
          _TaskRow(
            key: const ValueKey('task-practice'),
            glyph: '談',
            title: 'Luyện nói với AI',
            subtitle: _practiceSubtitle(subject.today.byActivity),
            button: 'Luyện',
            primary: action == TodayAction.practice,
            onTap: () => context.push(
              '/tra-dinh/luyen-tap?subjectId=${subject.subjectId}',
            ),
          ),
          if (logs.isNotEmpty)
            Container(
              key: const ValueKey('today-logs'),
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 6),
              decoration: BoxDecoration(
                border: Border.all(color: DesignColors.panelBorder),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text('Đã ghi hôm nay', style: DesignText.muted),
                  for (final l in logs) _LogRow(log: l),
                ],
              ),
            ),
        ],
    );
  }

  Widget _cardsRow(
    BuildContext context,
    WidgetRef ref,
    CardsToday cards,
    bool primary,
  ) {
    final next = cards.nextReviewDay;
    // Môn chắc chắn chưa có thẻ (total == 0): không có gì để ôn, chỉ mời nhập thẻ. Không phải việc cần làm → không nút vàng.
    if (cards.total == 0) {
      return _TaskRow(
        key: const ValueKey('task-cards'),
        glyph: '復',
        title: 'Ôn thẻ',
        statusKey: const ValueKey('cards-status'),
        status: 'Chưa có thẻ',
        button: 'Nhập thẻ ›',
        buttonKey: const ValueKey('cards-import'),
        onTap: () => context.push(
          '/tra-dinh/hoc-tap/the/them?subjectId=${subject.subjectId}',
        ),
      );
    }
    final done = cards.planned > 0 && cards.finished >= cards.planned;
    if (done) {
      return _TaskRow(
        key: const ValueKey('task-cards'),
        glyph: '復',
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
      glyph: '復',
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

/// Một dòng việc: chữ Hán, tên + trạng thái, và một nút bên phải (vàng khi [primary], viền vàng khi không).
class _TaskRow extends StatelessWidget {
  const _TaskRow({
    super.key,
    required this.glyph,
    required this.title,
    this.status,
    this.statusKey,
    this.subtitle,
    this.subtitleKey,
    this.button,
    this.buttonKey,
    this.primary = false,
    this.done = false,
    this.onTap,
  });

  final String glyph;
  final String title;
  final String? status;
  final Key? statusKey;
  final String? subtitle;
  final Key? subtitleKey;
  final String? button;
  final Key? buttonKey;
  final bool primary;
  final bool done;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final b = button;
    final label = b == null ? null : Text(b, textAlign: TextAlign.center);
    return FrameTile(
      onTap: null,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      child: Row(
        spacing: 12,
        children: [
          GlyphCircle(glyph),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: DesignText.bold),
                if (status != null)
                  Text(
                    status!,
                    key: statusKey,
                    style: done ? const TextStyle(fontSize: 13, color: DesignColors.success) : DesignText.muted,
                  ),
                if (subtitle != null) Text(subtitle!, key: subtitleKey, style: DesignText.muted),
              ],
            ),
          ),
          if (done)
            const Icon(Icons.check_circle, key: ValueKey('task-done'), color: DesignColors.success)
          else if (label != null)
            // Giới hạn bề ngang nút: chữ phóng to thì nhãn nút xuống dòng, không đẩy hàng tràn khỏi khung.
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 124),
              child: primary
                  ? FilledButton(key: buttonKey, style: _primaryStyle, onPressed: onTap, child: label)
                  : OutlinedButton(key: buttonKey, style: _outlineStyle, onPressed: onTap, child: label),
            ),
        ],
      ),
    );
  }
}

// Nút theo bản mẫu: `.btn` vàng chữ tối, `.btn.o` viền vàng (cả Thêm khóa, Nhập thẻ).
final _shape = RoundedRectangleBorder(borderRadius: BorderRadius.circular(6));
const _pad = EdgeInsets.symmetric(horizontal: 12, vertical: 6);

final _primaryStyle = FilledButton.styleFrom(
  backgroundColor: DesignColors.gold,
  foregroundColor: const Color(0xFF1A1A1A),
  padding: _pad,
  minimumSize: const Size(0, 32),
  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
  shape: _shape,
  textStyle: DesignText.serif(fontSize: 13),
);

final _outlineStyle = OutlinedButton.styleFrom(
  foregroundColor: DesignColors.gold,
  side: const BorderSide(color: DesignColors.gold),
  padding: _pad,
  minimumSize: const Size(0, 32),
  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
  shape: _shape,
  textStyle: DesignText.serif(fontSize: 13),
);

class _LogRow extends StatelessWidget {
  const _LogRow({required this.log});

  final StudyLog log;

  @override
  Widget build(BuildContext context) {
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
                style: const TextStyle(fontSize: 12, color: DesignColors.muted),
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
                style: const TextStyle(fontSize: 12, color: DesignColors.muted),
              ),
            ),
            const Icon(Icons.edit_outlined, size: 14, color: DesignColors.muted),
          ],
        ),
      ),
    );
  }
}

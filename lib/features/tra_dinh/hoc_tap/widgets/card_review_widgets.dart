import 'package:material_ui/material_ui.dart';

import '../../../../shared/theme/app_theme.dart';
import '../models/study_card_queue.dart';
import '../utils/card_format.dart';
import '../utils/card_mask.dart';
import 'card_widgets.dart';
import 'speak_button.dart';

const _cardRadius = 20.0;

/// Khung thẻ lớn bo tròn dùng cho cả mặt trước và mặt sau.
class ReviewCardFrame extends StatelessWidget {
  const ReviewCardFrame({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: BorderRadius.circular(_cardRadius),
        border: Border.all(color: scheme.onSurface.withValues(alpha: 0.14)),
      ),
      child: child,
    );
  }
}

/// Nhãn nhỏ viết hoa màu primary đầu thẻ.
class _TopLabel extends StatelessWidget {
  const _TopLabel(this.text);

  final String text;

  @override
  Widget build(BuildContext context) =>
      Text(text, key: const ValueKey('review-label'), style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, letterSpacing: 1.2, color: Theme.of(context).colorScheme.primary));
}

/// Mặt trước: câu ví dụ với cụm bị thay bằng chỗ trống gạch chân + gợi ý nghĩa; không tìm thấy cụm trong câu thì
/// KHÔNG hiện câu ví dụ, chỉ hiện nghĩa (câu ví dụ để dành cho mặt sau).
class ReviewQuestion extends StatelessWidget {
  const ReviewQuestion({super.key, required this.card});

  final QueueCard card;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final masked = maskPhrase(card.card.example, card.card.phrase);
    final example = TextStyle(fontSize: 20, height: 1.5, color: theme.colorScheme.onSurface);
    return ReviewCardFrame(
      child: Column(
        key: const ValueKey('review-question'),
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 16,
        children: [
          _TopLabel(masked == null ? 'NHỚ LẠI CỤM TỪ CÓ NGHĨA:' : 'ĐIỀN CỤM TỪ CÒN THIẾU'),
          if (masked != null) ...[
            Text.rich(
              key: const ValueKey('review-example'),
              TextSpan(
                style: example,
                children: [
                  TextSpan(text: masked.before),
                  // Chỗ trống: khoảng trắng không ngắt dòng có gạch chân.
                  TextSpan(text: ' ' * 12, style: TextStyle(decoration: TextDecoration.underline, decorationColor: theme.colorScheme.primary, decorationThickness: 2)),
                  TextSpan(text: masked.after),
                ],
              ),
            ),
            Text('Gợi ý: ${card.card.meaning}', key: const ValueKey('review-hint'), style: TextStyle(fontSize: 15, color: theme.colorScheme.secondary)),
          ] else
            Text(card.card.meaning, key: const ValueKey('review-meaning'), style: example),
        ],
      ),
    );
  }
}

/// Mặt sau: cụm, câu đầy đủ (cụm in đậm), nghĩa, rồi loại / chủ đề / ghi chú.
class ReviewAnswer extends StatelessWidget {
  const ReviewAnswer({super.key, required this.card});

  final QueueCard card;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final c = card.card;
    final masked = maskPhrase(c.example, c.phrase);
    final body = TextStyle(fontSize: 17, height: 1.5, color: theme.colorScheme.onSurface);
    return ReviewCardFrame(
      child: Column(
        key: const ValueKey('review-answer'),
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 14,
        children: [
          Row(
            children: [
              Expanded(child: Text(c.phrase, key: const ValueKey('review-phrase'), style: TextStyle(fontSize: 28, fontWeight: FontWeight.w700, height: 1.2, color: theme.colorScheme.primary))),
              SpeakButton(key: const ValueKey('speak-phrase'), text: c.phrase),
            ],
          ),
          if (c.pronunciation != null) Text(c.pronunciation!, key: const ValueKey('review-pronunciation'), style: TextStyle(fontSize: 14, color: theme.textMuted)),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text.rich(
                  key: const ValueKey('review-answer-example'),
                  TextSpan(
                    style: body,
                    children: masked == null
                        ? [TextSpan(text: c.example)]
                        : [TextSpan(text: masked.before), TextSpan(text: masked.match, style: const TextStyle(fontWeight: FontWeight.w700)), TextSpan(text: masked.after)],
                  ),
                ),
              ),
              SpeakButton(key: const ValueKey('speak-example'), text: c.example, small: true),
            ],
          ),
          const Align(alignment: Alignment.centerRight, child: SpeechSpeedToggle()),
          Text(c.meaning, key: const ValueKey('review-answer-meaning'), style: TextStyle(fontSize: 15, color: theme.colorScheme.secondary)),
          const Divider(height: 8),
          ChipScrollRow(children: [KindTag(c.kind), for (final t in c.topics) TopicTag(t)]),
          if (c.note != null && c.note!.trim().isNotEmpty) Text(c.note!, key: const ValueKey('review-note'), style: TextStyle(fontSize: 13, color: theme.textMuted)),
        ],
      ),
    );
  }
}

/// Ba nút đánh giá bằng nhau, cao tối thiểu 72, mỗi nút có tiêu đề và dòng nhỏ về lần ôn kế (từ `next` của server).
/// [onRate] null (đang gọi API) → khoá cả ba nút.
class RatingButtons extends StatelessWidget {
  const RatingButtons({super.key, required this.card, required this.onRate, this.now});

  final QueueCard card;
  final void Function(CardRating rating)? onRate;
  final DateTime? now;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final amber = theme.brightness == Brightness.dark ? Colors.amber.shade300 : Colors.amber.shade800;
    Widget button(CardRating r, String title, Color color) {
      final next = card.next[r];
      final sub = next == null ? '' : ratingDueLabel(card: card.card, rating: r, next: next, now: now);
      return Expanded(
        child: _RatingButton(key: ValueKey('rate-${r.name}'), subtitleKey: ValueKey('sub-${r.name}'), title: title, subtitle: sub, color: color, onPressed: onRate == null ? null : () => onRate!(r)),
      );
    }

    // IntrinsicHeight + stretch: ba nút luôn cao bằng nhau kể cả khi một nút có dòng nhỏ xuống hàng (chữ phóng to).
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: 8,
        children: [
          button(CardRating.notYet, 'Chưa nhớ', theme.colorScheme.error),
          button(CardRating.reviewAgain, 'Cần ôn lại', amber),
          button(CardRating.remembered, 'Đã nhớ', theme.success),
        ],
      ),
    );
  }
}

class _RatingButton extends StatelessWidget {
  const _RatingButton({super.key, required this.subtitleKey, required this.title, required this.subtitle, required this.color, required this.onPressed});

  final Key subtitleKey;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) => OutlinedButton(
    onPressed: onPressed,
    style: OutlinedButton.styleFrom(
      minimumSize: const Size(0, 72), // cao tối thiểu 72: chữ phóng to thì nút cao thêm, không tràn
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
      foregroundColor: color,
      disabledForegroundColor: color.withValues(alpha: 0.4),
      backgroundColor: color.withValues(alpha: 0.14),
      side: BorderSide(color: color.withValues(alpha: onPressed == null ? 0.25 : 0.7)),
    ),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      spacing: 2,
      children: [
        Text(title, textAlign: TextAlign.center, maxLines: 2, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
        if (subtitle.isNotEmpty) Text(subtitle, key: subtitleKey, textAlign: TextAlign.center, maxLines: 2, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w400)),
      ],
    ),
  );
}

/// Chip đếm nhỏ ở đầu màn ôn: "Đến hạn 5".
class ReviewCountChip extends StatelessWidget {
  const ReviewCountChip({super.key, required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(AppTheme.darkRadius), border: Border.all(color: scheme.onSurface.withValues(alpha: 0.25))),
      child: Text(label, style: TextStyle(fontSize: 12, color: scheme.onSurface.withValues(alpha: 0.85))),
    );
  }
}

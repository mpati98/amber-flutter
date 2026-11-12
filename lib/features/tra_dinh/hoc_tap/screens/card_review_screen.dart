import 'dart:async';

import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../shared/widgets/app_bar_back.dart';
import '../models/study_card_queue.dart';
import '../providers/card_review_provider.dart';
import '../utils/card_format.dart';
import '../widgets/card_review_widgets.dart';
import '../widgets/card_widgets.dart';
import '../widgets/hoc_tap_common.dart';
import 'card_session_end_screen.dart';

const _libraryPath = '/tra-dinh/hoc-tap/the';

/// Ôn thẻ: mỗi lần một thẻ (mặt trước → Hiện đáp án → mặt sau + ba nút đánh giá), chờ thẻ "Chưa nhớ" quay lại,
/// rồi màn kết thúc phiên. Logic phiên nằm ở [CardReviewNotifier].
class CardReviewScreen extends StatelessWidget {
  const CardReviewScreen({super.key, this.subjectId});

  final String? subjectId;

  @override
  Widget build(BuildContext context) =>
      CardSubjectGate(subjectId: subjectId, title: 'Ôn thẻ', builder: (context, id, name) => _Review(key: ValueKey('review-$id'), subjectId: id, subjectName: name));
}

class _Review extends ConsumerWidget {
  const _Review({super.key, required this.subjectId, this.subjectName});

  final String subjectId;
  final String? subjectName;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.watch(cardReviewProvider(subjectId));
    final notifier = ref.read(cardReviewProvider(subjectId).notifier);
    // Thông báo ngắn (409, lỗi mạng): hiện một lần rồi xoá khỏi state.
    ref.listen(cardReviewProvider(subjectId), (prev, next) {
      final m = next.message;
      if (m != null && m != prev?.message) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(m)));
        notifier.ackMessage();
      }
    });

    return switch (s.phase) {
      ReviewPhase.loading => const _Frame(body: Center(child: CircularProgressIndicator())),
      ReviewPhase.error => _Frame(body: Center(child: HocTapLoadError(what: 'hàng ôn thẻ', onRetry: notifier.load))),
      ReviewPhase.empty => _Frame(body: _Empty(subjectId: subjectId)),
      ReviewPhase.done => CardSessionEndScreen(subjectId: subjectId, subjectName: subjectName, session: s),
      ReviewPhase.waiting => _Active(state: s, body: _Waiting(state: s, subjectId: subjectId), bottom: null),
      ReviewPhase.question || ReviewPhase.answer => _Active(
        state: s,
        body: s.current == null
            ? const SizedBox.shrink()
            : SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
                child: s.phase == ReviewPhase.question ? ReviewQuestion(card: s.current!) : ReviewAnswer(card: s.current!),
              ),
        bottom: s.current == null
            ? null
            : s.phase == ReviewPhase.question
            ? SizedBox(
                width: double.infinity,
                height: 52,
                child: FilledButton(key: const ValueKey('review-show-answer'), onPressed: notifier.showAnswer, child: const Text('Hiện đáp án', style: TextStyle(fontSize: 16))),
              )
            : RatingButtons(card: s.current!, onRate: s.busy ? null : notifier.rate, now: ref.read(cardReviewClockProvider)()),
      ),
    };
  }
}

/// Khung màn không có thẻ (tải, lỗi, trống): chỉ nút quay lại và tiêu đề.
class _Frame extends StatelessWidget {
  const _Frame({required this.body});

  final Widget body;

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(leading: const AppBarBack(fallback: _libraryPath), title: const Text('Ôn thẻ')),
    body: HocTapBody(child: body),
  );
}

/// Khung màn đang ôn: tiêu đề + "đã ôn / kế hoạch" bên phải, thanh tiến độ mảnh, ba chip đếm còn lại; nút ở dưới cùng.
class _Active extends StatelessWidget {
  const _Active({required this.state, required this.body, required this.bottom});

  final CardReviewState state;
  final Widget body;
  final Widget? bottom;

  @override
  Widget build(BuildContext context) {
    final p = state.progress;
    return Scaffold(
      appBar: AppBar(
        leading: const AppBarBack(fallback: _libraryPath),
        title: const Text('Ôn thẻ'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Center(child: Text('${p.finished} / ${p.planned}', key: const ValueKey('review-count'), style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600))),
          ),
        ],
      ),
      body: HocTapBody(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            LinearProgressIndicator(key: const ValueKey('review-progress'), minHeight: 3, value: p.planned == 0 ? 0 : (p.finished / p.planned).clamp(0.0, 1.0)),
            Padding(
              padding: const EdgeInsets.only(top: 10, bottom: 2),
              child: ChipScrollRow(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                children: [
                  ReviewCountChip(key: const ValueKey('chip-due'), label: 'Đến hạn ${p.remainingOf(CardBucket.due)}'),
                  ReviewCountChip(key: const ValueKey('chip-new'), label: 'Mới ${p.remainingOf(CardBucket.newCard)}'),
                  ReviewCountChip(key: const ValueKey('chip-extra'), label: 'Ôn thêm ${p.remainingExtra}'),
                ],
              ),
            ),
            Expanded(child: body),
          ],
        ),
      ),
      bottomNavigationBar: bottom == null
          ? null
          : SafeArea(
              child: Center(
                heightFactor: 1,
                child: ConstrainedBox(constraints: const BoxConstraints(maxWidth: 640), child: Padding(padding: const EdgeInsets.fromLTRB(16, 8, 16, 12), child: bottom)),
              ),
            ),
    );
  }
}

/// Hôm nay không có thẻ nào trong kế hoạch.
class _Empty extends StatelessWidget {
  const _Empty({required this.subjectId});

  final String subjectId;

  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        key: const ValueKey('review-empty'),
        mainAxisSize: MainAxisSize.min,
        spacing: 12,
        children: [
          const Text('Hôm nay chưa có thẻ cần ôn', textAlign: TextAlign.center, style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
          Text('Thêm thẻ mới hoặc chờ thẻ đến hạn ôn.', textAlign: TextAlign.center, style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.62))),
          FilledButton.tonal(key: const ValueKey('review-empty-library'), onPressed: () => goBackOr(context, '$_libraryPath?subjectId=$subjectId'), child: const Text('Mở kho thẻ')),
        ],
      ),
    ),
  );
}

/// Hết thẻ cần hiện ngay, còn thẻ "Chưa nhớ" sẽ quay lại trong hôm nay: đếm ngược, tự tải lại khi tới giờ.
class _Waiting extends ConsumerStatefulWidget {
  const _Waiting({required this.state, required this.subjectId});

  final CardReviewState state;
  final String subjectId;

  @override
  ConsumerState<_Waiting> createState() => _WaitingState();
}

class _WaitingState extends ConsumerState<_Waiting> {
  static const _retryAfter = Duration(seconds: 5);

  Timer? _timer;
  DateTime? _lastLoad;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) => _tick());
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  DateTime get _now => ref.read(cardReviewClockProvider)();

  /// Mỗi giây vẽ lại đồng hồ; tới giờ thì tải lại hàng (nếu server vẫn chưa coi là đến hạn thì thử lại sau 5 giây, không dồn dập).
  void _tick() {
    final due = widget.state.soonestDueAt;
    if (due == null || !mounted) return;
    setState(() {});
    if (!due.isAfter(_now) && (_lastLoad == null || _now.difference(_lastLoad!) >= _retryAfter)) {
      _lastLoad = _now;
      ref.read(cardReviewProvider(widget.subjectId).notifier).load(quiet: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final due = widget.state.soonestDueAt;
    final left = due == null ? Duration.zero : due.difference(_now);
    final n = widget.state.waitingCount;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          key: const ValueKey('review-waiting'),
          mainAxisSize: MainAxisSize.min,
          spacing: 12,
          children: [
            Icon(Icons.hourglass_top, size: 40, color: theme.colorScheme.primary),
            Text('${n < 1 ? 1 : n} thẻ quay lại sau ${waitMinutes(left)} phút', key: const ValueKey('review-waiting-title'), textAlign: TextAlign.center, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600)),
            Text(countdownLabel(left), key: const ValueKey('review-countdown'), style: TextStyle(fontSize: 40, fontWeight: FontWeight.w300, color: theme.colorScheme.primary, fontFeatures: const [FontFeature.tabularFigures()])),
            Text('Tự tải lại khi đến giờ.', style: TextStyle(fontSize: 13, color: theme.colorScheme.onSurface.withValues(alpha: 0.62))),
            const SizedBox(height: 4),
            FilledButton.tonal(key: const ValueKey('review-finish'), onPressed: ref.read(cardReviewProvider(widget.subjectId).notifier).finish, child: const Text('Kết thúc phiên')),
          ],
        ),
      ),
    );
  }
}

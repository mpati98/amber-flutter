import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../shared/theme/app_theme.dart';
import '../../../../shared/widgets/app_bar_back.dart';
import '../models/study_enums.dart';
import '../providers/card_review_provider.dart';
import '../providers/hoc_tap_provider.dart';
import '../utils/hoc_tap_errors.dart';
import '../widgets/card_widgets.dart';
import '../widgets/hoc_tap_common.dart';

const _quickMinutes = [10, 15, 20, 30];
const _minMinutes = 1;
const _maxMinutes = 1440;

/// Xong phiên ôn: tổng kết số thẻ, nhập số phút đã ôn (lưu thành buổi CARD_REVIEW, cộng vào mục tiêu ngày) hoặc bỏ qua.
class CardSessionEndScreen extends ConsumerStatefulWidget {
  const CardSessionEndScreen({super.key, required this.subjectId, required this.session, this.subjectName});

  final String subjectId;
  final String? subjectName;
  final CardReviewState session;

  @override
  ConsumerState<CardSessionEndScreen> createState() => _CardSessionEndScreenState();
}

class _CardSessionEndScreenState extends ConsumerState<CardSessionEndScreen> {
  final _minutes = TextEditingController();
  bool _busy = false;
  String? _error;

  @override
  void dispose() {
    _minutes.dispose();
    super.dispose();
  }

  /// Số phút đã nhập nếu hợp lệ (1–1440), không thì null.
  int? get _typed {
    final n = int.tryParse(_minutes.text.trim());
    return n != null && n >= _minMinutes && n <= _maxMinutes ? n : null;
  }

  bool get _invalidText => _minutes.text.trim().isNotEmpty && _typed == null;

  void _leave() {
    ref.invalidate(studyOverviewProvider);
    context.go('/tra-dinh'); // về màn Học tập; hàng ôn là autoDispose nên lần sau mở sẽ tải mới
  }

  Future<void> _save() async {
    final n = _typed;
    if (n == null || _busy) return;
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      // createLog làm mới Tổng quan, buổi học hôm nay, lịch, thống kê và việc hằng ngày (routine STUDY).
      await ref.read(hocTapActionsProvider).createLog({'subjectId': widget.subjectId, 'activity': LogActivity.cardReview.api, 'minutes': n});
      if (mounted) _leave();
    } catch (e) {
      if (mounted) setState(() => (_busy = false, _error = hocTapErrorMessage(e)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final s = widget.session;
    final goal = ref.watch(studyOverviewProvider).value?.subjects.where((x) => x.subjectId == widget.subjectId).map((x) => x.goalMinutes).firstOrNull;
    final logs = ref.watch(studyTodayLogsProvider(widget.subjectId)).value;
    final lesson = logs?.where((l) => l.activity == LogActivity.lesson).fold<int>(0, (n, l) => n + l.minutes) ?? 0;
    final cards = (logs?.where((l) => l.activity == LogActivity.cardReview).fold<int>(0, (n, l) => n + l.minutes) ?? 0) + (_typed ?? 0);
    final total = lesson + cards;

    return Scaffold(
      appBar: AppBar(leading: const AppBarBack(fallback: '/tra-dinh'), title: const Text('Xong phiên ôn')),
      body: HocTapBody(
        child: ListView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          padding: const EdgeInsets.fromLTRB(16, 24, 16, 24),
          children: [
            Text('Hôm nay đã ôn ${s.progress.finished} / ${s.progress.planned} thẻ', key: const ValueKey('end-title'), style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w700, height: 1.25)),
            const SizedBox(height: 14),
            ChipScrollRow(
              children: [
                _CountChip(key: const ValueKey('end-chip-notYet'), label: 'Chưa nhớ ${s.notYet}', color: theme.colorScheme.error),
                _CountChip(key: const ValueKey('end-chip-again'), label: 'Cần ôn lại ${s.again}', color: theme.brightness == Brightness.dark ? Colors.amber.shade300 : Colors.amber.shade800),
                _CountChip(key: const ValueKey('end-chip-remembered'), label: 'Đã nhớ ${s.remembered}', color: theme.success),
              ],
            ),
            const SizedBox(height: 28),
            const Text('Số phút bạn đã ôn thẻ', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            TextField(
              key: const ValueKey('end-minutes'),
              controller: _minutes,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly, LengthLimitingTextInputFormatter(4)],
              decoration: InputDecoration(hintText: 'Số phút (1–1440)', suffixText: 'phút', errorText: _invalidText ? 'Nhập từ $_minMinutes đến $_maxMinutes phút' : null, border: const OutlineInputBorder()),
              onChanged: (_) => setState(() => _error = null),
            ),
            const SizedBox(height: 10),
            ChipScrollRow(
              children: [
                for (final m in _quickMinutes)
                  FilterPill(key: ValueKey('end-quick-$m'), label: '$m', selected: _typed == m, onSelected: () => setState(() => _minutes.text = '$m')),
              ],
            ),
            if (logs != null) ...[
              const SizedBox(height: 24),
              if (goal != null) ...[
                Text('${widget.subjectName ?? 'Môn học'} hôm nay: $total / $goal phút', key: const ValueKey('end-goal-text'), style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(AppTheme.darkRadius),
                  child: LinearProgressIndicator(key: const ValueKey('end-goal-bar'), minHeight: 8, value: goal == 0 ? 1 : (total / goal).clamp(0.0, 1.0), color: total >= goal ? theme.success : theme.colorScheme.primary),
                ),
                const SizedBox(height: 8),
              ],
              Text('$lesson phút học bài + $cards phút ôn thẻ', key: const ValueKey('end-breakdown'), style: TextStyle(fontSize: 13, color: theme.textMuted)),
            ],
            if (_error != null) Padding(padding: const EdgeInsets.only(top: 12), child: Text(_error!, key: const ValueKey('end-error'), style: TextStyle(color: theme.colorScheme.error))),
            const SizedBox(height: 28),
            FilledButton(key: const ValueKey('end-save'), onPressed: _typed == null || _busy ? null : _save, child: Text(_busy ? 'Đang lưu…' : 'Lưu số phút')),
            const SizedBox(height: 8),
            TextButton(key: const ValueKey('end-skip'), onPressed: _busy ? null : _leave, child: const Text('Bỏ qua')),
          ],
        ),
      ),
    );
  }
}

class _CountChip extends StatelessWidget {
  const _CountChip({super.key, required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
    decoration: BoxDecoration(color: color.withValues(alpha: 0.14), borderRadius: BorderRadius.circular(AppTheme.darkRadius), border: Border.all(color: color.withValues(alpha: 0.6))),
    child: Text(label, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: color)),
  );
}

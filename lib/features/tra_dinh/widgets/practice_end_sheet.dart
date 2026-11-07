import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/theme/app_theme.dart';
import '../../../shared/widgets/form_bits.dart';
import '../hoc_tap/providers/hoc_tap_provider.dart';
import '../hoc_tap/utils/hoc_tap_errors.dart';

/// Sheet cuối phiên luyện AI: "Luyện X phút" điền sẵn, sửa được 1–1440, Lưu / Bỏ qua. Trả về câu thông báo khi đã lưu,
/// null khi bỏ qua / đóng. Không tự ghi: giữ đúng tinh thần "mục tiêu cứng: tự báo, không tự động".
Future<String?> showPracticeEndSheet(
  BuildContext context, {
  required String sessionId,
  required String subjectId,
  required int minutes,
}) => showFinanceSheet<String>(context, PracticeEndSheet(sessionId: sessionId, subjectId: subjectId, minutes: minutes));

class PracticeEndSheet extends ConsumerStatefulWidget {
  const PracticeEndSheet({super.key, required this.sessionId, required this.subjectId, required this.minutes});

  final String sessionId;
  final String subjectId;
  final int minutes;

  @override
  ConsumerState<PracticeEndSheet> createState() => _PracticeEndSheetState();
}

class _PracticeEndSheetState extends ConsumerState<PracticeEndSheet> {
  late final _minutes = TextEditingController(text: '${widget.minutes}');
  bool _busy = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _minutes.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _minutes.dispose();
    super.dispose();
  }

  int get _input => int.tryParse(_minutes.text.trim()) ?? 0;

  Future<void> _save() async {
    if (_busy) return;
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      // KHÔNG gửi courseId / sections (server từ chối); practiceSessionId để mỗi phiên chỉ ghi một lần.
      final r = await ref.read(hocTapActionsProvider).createLog({
        'subjectId': widget.subjectId,
        'activity': 'PRACTICE',
        'minutes': _input,
        'practiceSessionId': widget.sessionId,
      });
      final t = r.today;
      final today = t.goalMinutes == null ? '${t.minutes} phút' : '${t.minutes}/${t.goalMinutes}';
      if (mounted) Navigator.of(context).pop('Đã ghi $_input phút luyện AI · hôm nay $today');
    } catch (e) {
      // Mã lạ / lỗi mạng → câu chung, không lộ lỗi kỹ thuật; 409 practice_already_logged có câu riêng.
      if (mounted) setState(() => (_busy = false, _error = hocTapErrorMessage(e)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final subject = ref.watch(studySubjectsProvider).value?.where((s) => s.id == widget.subjectId).firstOrNull;
    final canSave = !_busy && _input >= 1 && _input <= 1440;
    return FinanceSheetBody(
      title: 'Luyện ${_input >= 1 ? _input : widget.minutes} phút',
      children: [
        Text(
          subject == null ? 'Ghi vào mục tiêu phút của hôm nay.' : 'Ghi vào mục tiêu phút của hôm nay · ${subject.name}.',
          key: const ValueKey('practice-end-header'),
          style: TextStyle(fontSize: 13, color: theme.textMuted),
        ),
        TextField(
          key: const ValueKey('practice-end-minutes'),
          controller: _minutes,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(labelText: 'Số phút luyện AI', suffixText: 'phút', helperText: 'Tự ước tính từ các tin nhắn, sửa nếu chưa đúng'),
        ),
        sheetError(context, _error),
        FilledButton(key: const ValueKey('practice-end-save'), onPressed: canSave ? _save : null, child: const Text('Lưu')),
        TextButton(key: const ValueKey('practice-end-skip'), onPressed: _busy ? null : () => Navigator.of(context).pop(), child: const Text('Bỏ qua')),
      ],
    );
  }
}

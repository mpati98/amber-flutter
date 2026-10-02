import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/widgets/form_bits.dart';
import '../models/practice_session.dart';
import '../providers/tra_dinh_provider.dart';
import '../services/tra_dinh_api.dart';

/// Port NewPracticeSessionModal: chọn mode + tên tuỳ chọn. Trả về buổi vừa tạo
/// (null nếu đóng) để nơi gọi điều hướng thẳng vào buổi đó như web.
Future<PracticeSession?> showNewPracticeSessionModal(BuildContext context) =>
    showFinanceSheet<PracticeSession>(context, const NewPracticeSessionModal());

class NewPracticeSessionModal extends ConsumerStatefulWidget {
  const NewPracticeSessionModal({super.key});

  @override
  ConsumerState<NewPracticeSessionModal> createState() => _NewPracticeSessionModalState();
}

class _NewPracticeSessionModalState extends ConsumerState<NewPracticeSessionModal> {
  final _name = TextEditingController();
  var _mode = PracticeMode.conversation;
  bool _submitting = false;
  String? _error;

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    setState(() {
      _submitting = true;
      _error = null;
    });
    final name = _name.text.trim();
    try {
      final created = await ref.read(traDinhApiProvider).createSession(mode: _mode, name: name.isEmpty ? null : name);
      ref.invalidate(practiceSessionsProvider);
      if (mounted) Navigator.of(context).pop(created);
    } on DioException {
      if (mounted) {
        setState(() {
          _submitting = false;
          _error = 'Không tạo được buổi luyện, thử lại nhé.';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return FinanceSheetBody(
      title: 'Bắt đầu buổi luyện mới',
      children: [
        ChoiceRow<PracticeMode>(
          options: {for (final m in PracticeMode.selectable) m: m.label},
          selected: _mode,
          onSelected: (m) => setState(() => _mode = m),
        ),
        TextField(
          controller: _name,
          autofocus: true,
          decoration: const InputDecoration(hintText: 'Tên buổi luyện (tuỳ chọn)'),
        ),
        sheetError(context, _error),
        FilledButton(onPressed: _submitting ? null : _submit, child: Text(_submitting ? 'Đang tạo...' : 'Bắt đầu')),
      ],
    );
  }
}

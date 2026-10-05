import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/widgets/form_bits.dart';
import '../models/project.dart';
import '../providers/nghi_su_duong_provider.dart';
import '../services/nghi_su_duong_api.dart';

/// Port NewProjectModal (calendar/NewProjectModal.tsx): chỉ có tên, tạo project STANDARD.
Future<void> showNewProjectModal(BuildContext context) => showFinanceSheet<void>(context, const NewProjectModal());

class NewProjectModal extends ConsumerStatefulWidget {
  const NewProjectModal({super.key});

  @override
  ConsumerState<NewProjectModal> createState() => _NewProjectModalState();
}

class _NewProjectModalState extends ConsumerState<NewProjectModal> {
  final _name = TextEditingController();
  bool _submitting = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _name.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  bool get _canSubmit => !_submitting && _name.text.trim().isNotEmpty;

  Future<void> _submit() async {
    setState(() {
      _submitting = true;
      _error = null;
    });
    try {
      await ref.read(nghiSuDuongApiProvider).createProject(name: _name.text.trim(), type: ProjectType.standard);
      // Trang chính Nghị Sự Đường cũng đọc provider này (card Dự án).
      ref.invalidate(duAnOverviewProvider);
      if (mounted) Navigator.of(context).pop();
    } on DioException {
      if (mounted) {
        setState(() {
          _submitting = false;
          _error = 'Không tạo được dự án, thử lại nhé.';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return FinanceSheetBody(
      title: 'Thêm dự án',
      children: [
        TextField(
          controller: _name,
          decoration: const InputDecoration(hintText: 'VD: Sự kiện tháng 11'),
          onSubmitted: (_) => _canSubmit ? _submit() : null,
        ),
        if (_error != null) Text(_error!, style: TextStyle(color: Theme.of(context).colorScheme.error)),
        FilledButton(
          onPressed: _canSubmit ? _submit : null,
          child: Text(_submitting ? 'Đang tạo...' : 'Tạo'),
        ),
      ],
    );
  }
}

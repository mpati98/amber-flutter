import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/project.dart';
import '../providers/nghi_su_duong_provider.dart';
import '../services/nghi_su_duong_api.dart';

/// Port NewProjectModal (calendar/NewProjectModal.tsx): chỉ có tên, tạo project STANDARD.
Future<void> showNewProjectModal(BuildContext context) => showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      constraints: const BoxConstraints(maxWidth: 560),
      builder: (_) => const NewProjectModal(),
    );

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
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          spacing: 12,
          children: [
            Text('Thêm dự án', style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontSize: 20)),
            TextField(
              controller: _name,
              autofocus: true,
              decoration: const InputDecoration(hintText: 'VD: Sự kiện tháng 11'),
              onSubmitted: (_) => _canSubmit ? _submit() : null,
            ),
            if (_error != null) Text(_error!, style: TextStyle(color: Theme.of(context).colorScheme.error)),
            FilledButton(
              onPressed: _canSubmit ? _submit : null,
              child: Text(_submitting ? 'Đang tạo...' : 'Tạo'),
            ),
          ],
        ),
      ),
    );
  }
}

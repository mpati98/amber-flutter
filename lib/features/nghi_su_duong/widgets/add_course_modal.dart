import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/utils/vn_time.dart';
import '../../../shared/widgets/form_bits.dart';
import '../models/course.dart';
import '../providers/learn_provider.dart';
import '../providers/nghi_su_duong_provider.dart';
import '../services/learn_api.dart';

/// Port AddCourseModal: tên, nguồn, lĩnh vực, trạng thái.
Future<void> showAddCourseModal(BuildContext context) => showFinanceSheet<void>(context, const AddCourseModal());

class AddCourseModal extends ConsumerStatefulWidget {
  const AddCourseModal({super.key});

  @override
  ConsumerState<AddCourseModal> createState() => _AddCourseModalState();
}

class _AddCourseModalState extends ConsumerState<AddCourseModal> {
  final _name = TextEditingController();
  final _source = TextEditingController();
  final _field = TextEditingController();
  var _status = CourseStatus.planned;
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
    _source.dispose();
    _field.dispose();
    super.dispose();
  }

  String? _trimmedOrNull(TextEditingController c) => c.text.trim().isEmpty ? null : c.text.trim();

  Future<void> _submit() async {
    setState(() {
      _submitting = true;
      _error = null;
    });
    final today = vnToday();
    try {
      await ref
          .read(learnApiProvider)
          .createCourse(
            name: _name.text.trim(),
            source: _trimmedOrNull(_source),
            field: _trimmedOrNull(_field),
            status: _status,
            // Cùng quy tắc với màn chi tiết: Đang học → ngày bắt đầu, Đã xong →
            // ngày kết thúc (web chỉ điền startDate khi tạo).
            startDate: _status == CourseStatus.inProgress ? today : null,
            endDate: _status == CourseStatus.completed ? today : null,
          );
      ref.invalidate(coursesProvider);
      ref.invalidate(learnOverviewProvider);
      if (mounted) Navigator.of(context).pop();
    } on DioException {
      if (mounted) {
        setState(() {
          _submitting = false;
          _error = 'Không tạo được khóa học, thử lại nhé.';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return FinanceSheetBody(
      title: 'Thêm khóa học',
      children: [
        TextField(
          controller: _name,
          autofocus: true,
          decoration: const InputDecoration(hintText: 'Tên khóa (VD: CS50, React Advanced)'),
        ),
        TextField(
          controller: _source,
          decoration: const InputDecoration(hintText: 'Nguồn (Udemy, Coursera...)'),
        ),
        TextField(
          controller: _field,
          decoration: const InputDecoration(hintText: 'Lĩnh vực (VD: Lập trình web)'),
        ),
        ChoiceRow<CourseStatus>(
          options: {for (final s in CourseStatus.values.where((s) => s != CourseStatus.unknown)) s: s.label},
          selected: _status,
          onSelected: (s) => setState(() => _status = s),
        ),
        sheetError(context, _error),
        FilledButton(
          onPressed: !_submitting && _name.text.trim().isNotEmpty ? _submit : null,
          child: Text(_submitting ? 'Đang tạo...' : 'Tạo khóa học'),
        ),
      ],
    );
  }
}

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/utils/duration_format.dart';
import '../../../shared/utils/vn_time.dart';
import '../../../shared/widgets/form_bits.dart';
import '../providers/learn_provider.dart';
import '../providers/nghi_su_duong_provider.dart';
import '../services/learn_api.dart';

/// Port AddLessonModal: tên bài, ngày học (mặc định hôm nay theo giờ VN),
/// số phút, ghi chú.
Future<void> showAddLessonModal(BuildContext context, {required String courseId}) =>
    showFinanceSheet<void>(context, AddLessonModal(courseId: courseId));

String _iso(DateTime d) =>
    '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

class AddLessonModal extends ConsumerStatefulWidget {
  const AddLessonModal({super.key, required this.courseId});

  final String courseId;

  @override
  ConsumerState<AddLessonModal> createState() => _AddLessonModalState();
}

class _AddLessonModalState extends ConsumerState<AddLessonModal> {
  final _title = TextEditingController();
  final _minutes = TextEditingController();
  final _note = TextEditingController();

  /// "YYYY-MM-DD"; null = không ghi ngày.
  String? _studiedAt = vnToday();
  bool _submitting = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _title.addListener(() => setState(() {}));
    _minutes.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _title.dispose();
    _minutes.dispose();
    _note.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final today = vnNow();
    final current = _studiedAt == null ? today : DateTime.parse(_studiedAt!);
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime(current.year, current.month, current.day),
      firstDate: DateTime(2000),
      lastDate: DateTime(today.year, today.month, today.day), // không cho chọn ngày tương lai
      helpText: 'Ngày học',
    );
    if (picked != null) setState(() => _studiedAt = _iso(picked));
  }

  Future<void> _submit() async {
    setState(() {
      _submitting = true;
      _error = null;
    });
    try {
      final note = _note.text.trim();
      final minutes = int.tryParse(_minutes.text);
      await ref
          .read(learnApiProvider)
          .createLesson(
            widget.courseId,
            title: _title.text.trim(),
            studiedAt: _studiedAt,
            durationMinutes: minutes != null && minutes > 0 ? minutes : null, // backend chỉ nhận số dương
            note: note.isEmpty ? null : note,
          );
      ref.invalidate(lessonsProvider(widget.courseId));
      ref.invalidate(coursesProvider); // danh sách hiện số bài / tổng thời lượng
      ref.invalidate(learnOverviewProvider); // "Gần nhất" ở trang chính
      if (mounted) Navigator.of(context).pop();
    } on DioException {
      if (mounted) {
        setState(() {
          _submitting = false;
          _error = 'Không thêm được bài học, thử lại nhé.';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final minutes = int.tryParse(_minutes.text);
    final p = _studiedAt?.split('-');
    return FinanceSheetBody(
      title: 'Thêm bài học',
      children: [
        TextField(
          controller: _title,
          decoration: const InputDecoration(hintText: 'Tên bài học'),
        ),
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: _pickDate,
                icon: const Icon(Icons.event, size: 18),
                label: Text(p == null ? 'Chọn ngày học' : 'Ngày học: ${int.parse(p[2])}/${int.parse(p[1])}/${p[0]}'),
              ),
            ),
            if (_studiedAt != null)
              IconButton(
                tooltip: 'Không ghi ngày',
                onPressed: () => setState(() => _studiedAt = null),
                icon: const Icon(Icons.close, size: 18),
              ),
          ],
        ),
        TextField(
          controller: _minutes,
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          decoration: InputDecoration(
            hintText: 'Thời lượng (phút)',
            helperText: minutes != null && minutes > 0 ? '= ${formatDuration(minutes)}' : null,
          ),
        ),
        TextField(
          controller: _note,
          decoration: const InputDecoration(hintText: 'Ghi chú (tuỳ chọn)'),
        ),
        sheetError(context, _error),
        FilledButton(
          onPressed: !_submitting && _title.text.trim().isNotEmpty ? _submit : null,
          child: Text(_submitting ? 'Đang thêm...' : 'Thêm bài học'),
        ),
      ],
    );
  }
}

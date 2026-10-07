import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/utils/date_format.dart';
import '../../../shared/utils/vn_time.dart';
import '../../../shared/widgets/form_bits.dart';
import '../models/project.dart';
import '../models/project_summary.dart';
import '../providers/nghi_su_duong_provider.dart';
import '../services/nghi_su_duong_api.dart';

/// Form "Thêm dự án" (STANDARD): tên (bắt buộc), mục tiêu, ngày bắt đầu (mặc định
/// hôm nay giờ VN), hạn (có thể để trống).
Future<void> showNewProjectModal(BuildContext context) => showFinanceSheet<void>(context, const NewProjectModal());

String _iso(DateTime d) =>
    '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

const _endBeforeStartMessage = 'Hạn phải sau ngày bắt đầu.';

class NewProjectModal extends ConsumerStatefulWidget {
  const NewProjectModal({super.key});

  @override
  ConsumerState<NewProjectModal> createState() => _NewProjectModalState();
}

class _NewProjectModalState extends ConsumerState<NewProjectModal> {
  final _name = TextEditingController();
  final _goal = TextEditingController();
  String _startDate = vnToday();
  String? _endDate;
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
    _goal.dispose();
    super.dispose();
  }

  bool get _canSubmit => !_submitting && _name.text.trim().isNotEmpty;

  Future<void> _pickDate({required bool isStart}) async {
    final current = DateTime.parse((isStart ? _startDate : _endDate) ?? _startDate);
    final picked = await showDatePicker(
      context: context,
      initialDate: current,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      helpText: isStart ? 'Ngày bắt đầu' : 'Hạn',
    );
    if (picked == null) return;
    setState(() => isStart ? _startDate = _iso(picked) : _endDate = _iso(picked));
  }

  Future<void> _submit() async {
    // ISO "YYYY-MM-DD" so sánh chuỗi được.
    if (_endDate != null && _endDate!.compareTo(_startDate) < 0) {
      setState(() => _error = _endBeforeStartMessage);
      return;
    }
    setState(() {
      _submitting = true;
      _error = null;
    });
    try {
      final goal = _goal.text.trim();
      await ref
          .read(nghiSuDuongApiProvider)
          .createProject(
            name: _name.text.trim(),
            type: ProjectType.standard,
            goal: goal.isEmpty ? null : goal,
            startDate: _startDate,
            endDate: _endDate,
          );
      // Trang chính Nghị Sự Đường và màn Dự án đều đọc các provider này.
      ref.invalidate(duAnOverviewProvider);
      ref.invalidate(duAnSummaryProvider);
      ref.read(duAnFilterProvider.notifier).select(ProjectStatus.active);
      if (mounted) Navigator.of(context).pop();
    } on DioException catch (e) {
      if (!mounted) return;
      final endBeforeStart = switch (e.response?.data) {
        {'error': 'end_before_start'} => true,
        _ => false,
      };
      setState(() {
        _submitting = false;
        _error = endBeforeStart ? _endBeforeStartMessage : 'Không tạo được dự án, thử lại nhé.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return FinanceSheetBody(
      title: 'Thêm dự án',
      children: [
        TextField(
          controller: _name,
          maxLength: 255,
          decoration: const InputDecoration(labelText: 'Tên dự án', hintText: 'VD: Sự kiện tháng 11', counterText: ''),
        ),
        TextField(
          controller: _goal,
          minLines: 2,
          maxLines: 5,
          textInputAction: TextInputAction.newline,
          decoration: const InputDecoration(labelText: 'Mục tiêu', hintText: 'Dự án này nhằm đạt điều gì?'),
        ),
        OutlinedButton(
          onPressed: () => _pickDate(isStart: true),
          child: Align(alignment: Alignment.centerLeft, child: Text('Bắt đầu: ${formatDayMonth(_startDate)}/${_startDate.substring(0, 4)}')),
        ),
        Row(
          spacing: 8,
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () => _pickDate(isStart: false),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(_endDate == null ? 'Hạn: để trống' : 'Hạn: ${formatDayMonth(_endDate!)}/${_endDate!.substring(0, 4)}'),
                ),
              ),
            ),
            if (_endDate != null)
              IconButton(
                tooltip: 'Bỏ hạn',
                onPressed: () => setState(() => _endDate = null),
                icon: const Icon(Icons.close),
              ),
          ],
        ),
        sheetError(context, _error),
        FilledButton(
          onPressed: _canSubmit ? _submit : null,
          child: Text(_submitting ? 'Đang tạo...' : 'Tạo'),
        ),
      ],
    );
  }
}

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/utils/date_format.dart';
import '../../../shared/widgets/form_bits.dart';
import '../models/project_detail.dart';
import '../models/project_summary.dart';
import '../providers/nghi_su_duong_provider.dart';
import '../services/nghi_su_duong_api.dart';

/// Form "Sửa dự án": tên (bắt buộc), mục tiêu, bắt đầu, hạn (để trống được), trạng thái.
/// Chỉ gửi các trường thật sự đổi.
Future<void> showEditProjectModal(BuildContext context, ProjectDetail project) =>
    showFinanceSheet<void>(context, EditProjectModal(project: project));

String _iso(DateTime d) =>
    '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

String _full(String iso) => '${formatDayMonth(iso)}/${iso.substring(0, 4)}';

const _endBeforeStartMessage = 'Hạn phải sau ngày bắt đầu.';

class EditProjectModal extends ConsumerStatefulWidget {
  const EditProjectModal({super.key, required this.project});

  final ProjectDetail project;

  @override
  ConsumerState<EditProjectModal> createState() => _EditProjectModalState();
}

class _EditProjectModalState extends ConsumerState<EditProjectModal> {
  late final _name = TextEditingController(text: widget.project.name);
  late final _goal = TextEditingController(text: widget.project.goal ?? '');
  late String? _startDate = widget.project.startDate;
  late String? _endDate = widget.project.endDate;
  late ProjectStatus _status = widget.project.status;
  bool _busy = false;
  String? _error;

  bool get _isDone => widget.project.status == ProjectStatus.done;

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

  /// Chỉ các trường khác bản gốc; chuỗi rỗng ở mục tiêu → null (xoá mục tiêu).
  Map<String, Object?> get _patch {
    final p = widget.project;
    final goal = _goal.text.trim();
    return {
      if (_name.text.trim() != p.name) 'name': _name.text.trim(),
      if (goal != (p.goal ?? '')) 'goal': goal.isEmpty ? null : goal,
      if (_startDate != p.startDate) 'startDate': _startDate,
      if (_endDate != p.endDate) 'endDate': _endDate,
      if (!_isDone && _status != p.status) 'status': _status.apiValue,
    };
  }

  bool get _canSave => !_busy && _name.text.trim().isNotEmpty && _patch.isNotEmpty;

  Future<void> _pickDate({required bool isStart}) async {
    final current = DateTime.parse((isStart ? _startDate : _endDate) ?? _startDate ?? _iso(DateTime.now()));
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

  Future<void> _save() async {
    // ISO "YYYY-MM-DD" so sánh chuỗi được.
    if (_startDate != null && _endDate != null && _endDate!.compareTo(_startDate!) < 0) {
      setState(() => _error = _endBeforeStartMessage);
      return;
    }
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await ref.read(nghiSuDuongApiProvider).updateProject(widget.project.id, _patch);
      refreshProjectData(ref.invalidate, widget.project.id);
      if (mounted) Navigator.of(context).pop();
    } on DioException catch (e) {
      if (!mounted) return;
      final endBeforeStart = switch (e.response?.data) {
        {'error': 'end_before_start'} => true,
        _ => false,
      };
      setState(() {
        _busy = false;
        _error = endBeforeStart ? _endBeforeStartMessage : 'Không lưu được dự án, thử lại nhé.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final label = TextStyle(fontSize: 12, color: cs.onSurface.withValues(alpha: 0.6));
    return FinanceSheetBody(
      title: 'Sửa dự án',
      children: [
        TextField(
          controller: _name,
          maxLength: 255,
          decoration: const InputDecoration(labelText: 'Tên dự án', counterText: ''),
        ),
        TextField(
          controller: _goal,
          minLines: 2,
          maxLines: 5,
          textInputAction: TextInputAction.newline,
          decoration: const InputDecoration(labelText: 'Mục tiêu'),
        ),
        OutlinedButton(
          onPressed: () => _pickDate(isStart: true),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text(_startDate == null ? 'Bắt đầu: chưa có' : 'Bắt đầu: ${_full(_startDate!)}'),
          ),
        ),
        Row(
          spacing: 8,
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () => _pickDate(isStart: false),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(_endDate == null ? 'Hạn: để trống' : 'Hạn: ${_full(_endDate!)}'),
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
        // Chuyển sang "Đã xong" phải qua "Đóng dự án" (lưu tài liệu tổng kết); dự án đã xong thì ẩn ô này
        // (mở lại bằng menu "Mở lại dự án").
        if (!_isDone) ...[
          Text('Trạng thái', style: label),
          ChoiceRow<ProjectStatus>(
            options: const {ProjectStatus.active: 'Đang triển khai', ProjectStatus.paused: 'Tạm dừng'},
            selected: _status,
            onSelected: (s) => setState(() => _status = s),
          ),
        ],
        sheetError(context, _error),
        FilledButton(
          onPressed: _canSave ? _save : null,
          child: Text(_busy ? 'Đang lưu...' : 'Lưu'),
        ),
      ],
    );
  }
}

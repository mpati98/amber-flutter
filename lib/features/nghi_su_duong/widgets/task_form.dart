import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/utils/api_error.dart';
import '../../../shared/utils/date_format.dart';
import '../../../shared/utils/vn_time.dart';
import '../../../shared/widgets/form_bits.dart';
import '../models/key_result.dart';
import '../models/task.dart';
import '../providers/nghi_su_duong_provider.dart';
import '../services/nghi_su_duong_api.dart';

/// Form việc: thêm ([task] null, trong dự án [projectId]) hoặc sửa [task]. Mở bằng showFinanceSheet.
Future<void> showTaskForm(
  BuildContext context, {
  required String projectId,
  required List<KeyResult> keyResults,
  Task? task,
}) =>
    showFinanceSheet<void>(context, TaskForm(projectId: projectId, keyResults: keyResults, task: task));

const maxChecklistItems = 50;
const defaultNotifyLeadDays = 3;

const _endBeforeStartMessage = 'Hạn phải sau ngày bắt đầu.';
const _notifyNeedsDueMessage = 'Cần có hạn để bật thông báo.';
const _checklistFailedMessage = 'Đã lưu việc nhưng chưa lưu được checklist. Bấm Lưu để thử lại.';

String _iso(DateTime d) =>
    '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

String _full(String iso) => '${formatDayMonth(iso)}/${iso.substring(0, 4)}';

/// Một mục checklist đang soạn trong form.
class _Draft {
  _Draft({this.id, String text = '', this.done = false}) : controller = TextEditingController(text: text);

  final String? id;
  final TextEditingController controller;
  bool done;
  final key = UniqueKey();
}

class TaskForm extends ConsumerStatefulWidget {
  const TaskForm({super.key, required this.projectId, required this.keyResults, this.task});

  final String projectId;
  final List<KeyResult> keyResults;
  final Task? task;

  @override
  ConsumerState<TaskForm> createState() => _TaskFormState();
}

class _TaskFormState extends ConsumerState<TaskForm> {
  /// Việc đang sửa; null = đang thêm. Sau khi POST xong mà PUT checklist lỗi, form chuyển sang
  /// sửa việc vừa tạo (giá trị này đổi từ null sang việc vừa tạo).
  late Task? _original = widget.task;

  late final _title = TextEditingController(text: _original?.title ?? '');
  late final _description = TextEditingController(text: _original?.description ?? '');
  late final _prepLead = TextEditingController(text: '${_original?.prepLeadDays ?? defaultNotifyLeadDays}');
  late TaskStatus _status = _original == null || _original!.status == TaskStatus.unknown ? TaskStatus.prep : _original!.status;
  late String? _startDate = _original?.startDate;
  late String? _dueDate = _original?.dueDate;
  late bool _milestone = _original?.isMilestone ?? false;
  late String? _krId = _original?.krId;
  late bool _notify = _original?.notifyDeadline ?? false;
  late final List<_Draft> _drafts = [
    for (final i in _original?.checklistItems ?? const <ChecklistItem>[]) _Draft(id: i.id, text: i.text, done: i.done),
  ];

  bool _busy = false;
  String? _error;
  String? _titleError;
  String? _prepError;

  bool get _editing => _original != null;

  @override
  void initState() {
    super.initState();
    // Ô nhập đổi → dựng lại để cập nhật trạng thái nút Lưu (khi sửa mà chưa đổi gì thì khoá).
    _title.addListener(() => setState(() => _titleError = null));
    _description.addListener(() => setState(() {}));
    _prepLead.addListener(() => setState(() => _prepError = null));
  }

  @override
  void dispose() {
    _title.dispose();
    _description.dispose();
    _prepLead.dispose();
    for (final d in _drafts) {
      d.controller.dispose();
    }
    super.dispose();
  }

  // ---- giá trị hiện tại của form ----

  String get _descText => _description.text.trim();

  /// Số ngày báo trước nhập vào; null nếu không hợp lệ (0–60).
  int? get _prepValue {
    final v = int.tryParse(_prepLead.text.trim());
    return v == null || v < 0 || v > 60 ? null : v;
  }

  /// Checklist hiện tại, bỏ mục để trống.
  List<ChecklistDraft> get _items => [
        for (final d in _drafts)
          if (d.controller.text.trim().isNotEmpty)
            ChecklistDraft(id: d.id, text: d.controller.text.trim(), done: d.done),
      ];

  bool get _checklistChanged {
    final before = _original?.checklistItems ?? const <ChecklistItem>[];
    final now = _items;
    if (before.length != now.length) return true;
    for (var i = 0; i < now.length; i++) {
      if (now[i].id != before[i].id || now[i].text != before[i].text || now[i].done != before[i].done) return true;
    }
    return false;
  }

  /// Chỉ các trường khác bản gốc (dùng khi sửa). Giá trị null = xoá.
  Map<String, Object?> get _patch {
    final o = _original!;
    final prep = _prepValue;
    return {
      if (_title.text.trim() != o.title) 'title': _title.text.trim(),
      if (_status != o.status) 'status': _status.apiValue,
      if (_startDate != o.startDate) 'startDate': _startDate,
      if (_dueDate != o.dueDate) 'dueDate': _dueDate,
      if (_milestone != o.isMilestone) 'isMilestone': _milestone,
      if (_krId != o.krId) 'krId': _krId,
      if (_notify != o.notifyDeadline) 'notifyDeadline': _notify,
      // Bản gốc chưa đặt prepLeadDays nghĩa là mặc định 3 — chỉ gửi khi giá trị thật sự khác.
      if (_notify && prep != null && prep != (o.prepLeadDays ?? defaultNotifyLeadDays)) 'prepLeadDays': prep,
      if (_descText != (o.description ?? '')) 'description': _descText.isEmpty ? null : _descText,
    };
  }

  bool get _hasChanges => _patch.isNotEmpty || _checklistChanged;

  // Số ngày báo trước sai vẫn cho bấm Lưu để hiện câu báo lỗi.
  bool get _canSave => !_busy && (!_editing || _hasChanges || (_notify && _prepValue == null));

  // ---- thao tác ----

  Future<void> _pickDate({required bool isStart}) async {
    final current = DateTime.parse((isStart ? _startDate : _dueDate) ?? _startDate ?? vnToday());
    final picked = await showDatePicker(
      context: context,
      initialDate: current,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      helpText: isStart ? 'Ngày bắt đầu' : 'Hạn',
    );
    if (picked == null) return;
    setState(() => isStart ? _startDate = _iso(picked) : _dueDate = _iso(picked));
  }

  void _clearDue() => setState(() {
        _dueDate = null;
        _notify = false; // thông báo hạn cần có hạn
      });

  void _addDraft() {
    if (_drafts.length >= maxChecklistItems) return;
    setState(() => _drafts.add(_Draft()));
  }

  void _removeDraft(_Draft d) {
    setState(() => _drafts.remove(d));
    d.controller.dispose();
  }

  String _errorFor(Object e, String fallback) {
    if (e is DioException) {
      switch (e.response?.data) {
        case {'error': 'end_before_start'}:
          return _endBeforeStartMessage;
        case {'error': 'notify_requires_due_date'}:
          return _notifyNeedsDueMessage;
      }
    }
    return apiErrorMessage(e, fallback);
  }

  Future<void> _save() async {
    if (_busy) return;
    if (_title.text.trim().isEmpty) {
      setState(() => _titleError = 'Nhập tên việc.');
      return;
    }
    if (_notify && _prepValue == null) {
      setState(() => _prepError = 'Báo trước từ 0 đến 60 ngày.');
      return;
    }
    // Khoá ngay (đồng bộ) để bấm Lưu hai lần chỉ gửi một lần.
    setState(() {
      _busy = true;
      _error = null;
    });
    final api = ref.read(nghiSuDuongApiProvider);
    var taskWritten = false; // đã ghi gì đó lên server → màn chi tiết cần làm mới kể cả khi lỗi
    var createdNow = false; // việc vừa được tạo trong lần bấm Lưu này
    var inChecklistStep = false;
    try {
      if (!_editing) {
        final created = await api.createTask(
          projectId: widget.projectId,
          title: _title.text.trim(),
          status: _status,
          startDate: _startDate,
          dueDate: _dueDate,
          isMilestone: _milestone,
          krId: _krId,
          notifyDeadline: _notify,
          prepLeadDays: _notify ? _prepValue : null,
          description: _descText.isEmpty ? null : _descText,
        );
        // Từ đây việc đã tồn tại: nếu bước sau lỗi, form chuyển sang sửa việc này.
        _original = created;
        taskWritten = createdNow = true;
      } else {
        final patch = _patch;
        if (patch.isNotEmpty) {
          _original = await api.updateTask(_original!.id, patch);
          taskWritten = true;
        }
      }
      if (_checklistChanged) {
        inChecklistStep = true;
        final saved = await api.putChecklist(_original!.id, _items);
        taskWritten = true;
        _original = _original!.copyWith(checklistItems: saved);
      }
      refreshProjectData(ref.invalidate, widget.projectId);
      if (mounted) Navigator.of(context).pop();
    } catch (e) {
      if (taskWritten) refreshProjectData(ref.invalidate, widget.projectId);
      if (!mounted) return;
      setState(() {
        _busy = false;
        _error = createdNow && inChecklistStep ? _checklistFailedMessage : _errorFor(e, 'Không lưu được việc, thử lại nhé.');
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final label = TextStyle(fontSize: 12, color: cs.onSurface.withValues(alpha: 0.6));
    return FinanceSheetBody(
      title: _editing ? 'Sửa việc' : 'Thêm việc',
      children: [
        TextField(
          controller: _title,
          maxLength: 255,
          decoration: InputDecoration(labelText: 'Tên việc', counterText: '', errorText: _titleError),
        ),
        Text('Trạng thái', style: label),
        ChoiceRow<TaskStatus>(
          options: {
            for (final s in const [TaskStatus.prep, TaskStatus.inProgress, TaskStatus.review, TaskStatus.done]) s: s.label,
          },
          selected: _status,
          onSelected: (s) => setState(() => _status = s),
        ),
        _DateRow(
          label: 'Bắt đầu',
          value: _startDate,
          onPick: () => _pickDate(isStart: true),
          onClear: () => setState(() => _startDate = null),
        ),
        _DateRow(label: 'Hạn', value: _dueDate, onPick: () => _pickDate(isStart: false), onClear: _clearDue),
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          title: const Text('Là mốc'),
          value: _milestone,
          onChanged: (v) => setState(() => _milestone = v),
        ),
        DropdownButtonFormField<String?>(
          initialValue: widget.keyResults.any((k) => k.id == _krId) ? _krId : null,
          isExpanded: true,
          decoration: const InputDecoration(labelText: 'Gắn với KR'),
          items: [
            const DropdownMenuItem<String?>(value: null, child: Text('Không gắn')),
            for (final (i, k) in widget.keyResults.indexed)
              DropdownMenuItem<String?>(
                value: k.id,
                child: Text('KR ${i + 1} · ${k.name}', overflow: TextOverflow.ellipsis),
              ),
          ],
          onChanged: (v) => setState(() => _krId = v),
        ),
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          title: const Text('Thông báo hạn'),
          subtitle: _dueDate == null ? const Text('Cần đặt hạn trước') : null,
          // Chỉ bật được khi đã có Hạn.
          value: _notify && _dueDate != null,
          onChanged: _dueDate == null ? null : (v) => setState(() => _notify = v),
        ),
        if (_notify && _dueDate != null)
          TextField(
            controller: _prepLead,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(labelText: 'Báo trước (ngày)', errorText: _prepError),
          ),
        TextField(
          controller: _description,
          minLines: 3,
          maxLines: 8,
          textInputAction: TextInputAction.newline,
          decoration: const InputDecoration(labelText: 'Nội dung'),
        ),
        Text('Checklist', style: label),
        for (final d in _drafts)
          Row(
            key: d.key,
            children: [
              Checkbox(value: d.done, onChanged: (v) => setState(() => d.done = v ?? false)),
              Expanded(
                child: TextField(
                  controller: d.controller,
                  maxLength: 500,
                  decoration: const InputDecoration(hintText: 'Nội dung mục', counterText: ''),
                  onChanged: (_) => setState(() {}),
                ),
              ),
              IconButton(tooltip: 'Xoá mục', onPressed: () => _removeDraft(d), icon: const Icon(Icons.close)),
            ],
          ),
        Align(
          alignment: Alignment.centerLeft,
          child: TextButton.icon(
            onPressed: _drafts.length >= maxChecklistItems ? null : _addDraft,
            icon: const Icon(Icons.add, size: 18),
            label: Text(_drafts.length >= maxChecklistItems ? 'Tối đa $maxChecklistItems mục' : 'Thêm mục'),
          ),
        ),
        sheetError(context, _error),
        FilledButton(
          onPressed: _canSave ? _save : null,
          child: Text(_busy ? 'Đang lưu...' : 'Lưu'),
        ),
      ],
    );
  }
}

class _DateRow extends StatelessWidget {
  const _DateRow({required this.label, required this.value, required this.onPick, required this.onClear});

  final String label;
  final String? value;
  final VoidCallback onPick;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    return Row(
      spacing: 8,
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: onPick,
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(value == null ? '$label: chưa có' : '$label: ${_full(value!)}'),
            ),
          ),
        ),
        if (value != null) IconButton(tooltip: 'Xoá ngày ${label.toLowerCase()}', onPressed: onClear, icon: const Icon(Icons.close)),
      ],
    );
  }
}

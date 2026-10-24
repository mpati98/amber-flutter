import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/widgets/form_bits.dart';
import '../services/training_log_api.dart';

const _actionLabels = <String, String>{
  'task_add': 'Thêm việc',
  'task_list': 'Danh sách việc',
  'task_complete': 'Hoàn thành việc',
  'expense_add': 'Thêm thu chi',
  'expense_query': 'Tra cứu thu chi',
  'tutor': 'Gia sư',
  'news': 'Tin tức',
  'clarify': 'Cần làm rõ',
  'chitchat': 'Trò chuyện',
};

class TrainingLogCorrectionSheet extends ConsumerStatefulWidget {
  const TrainingLogCorrectionSheet({
    super.key,
    required this.logId,
    required this.initialValue,
    required this.hasCorrection,
  });

  final String logId;
  final Object? initialValue;
  final bool hasCorrection;

  @override
  ConsumerState<TrainingLogCorrectionSheet> createState() =>
      _TrainingLogCorrectionSheetState();
}

class _TrainingLogCorrectionSheetState
    extends ConsumerState<TrainingLogCorrectionSheet> {
  final _formKey = GlobalKey<FormState>();
  late String _action;
  late Map<String, dynamic> _values;
  bool _missingIsList = false;
  bool _busy = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    final source = widget.initialValue is Map
        ? Map<String, dynamic>.from(widget.initialValue! as Map)
        : <String, dynamic>{};
    final candidate = source['action'];
    _action = candidate is String && _actionLabels.containsKey(candidate)
        ? candidate
        : 'chitchat';
    _values = _defaultValues(_action);
    for (final key in _values.keys.toList()) {
      if (source.containsKey(key)) _values[key] = source[key];
    }
    _normalizeChoices();
    _missingIsList = source['missing'] is List;
  }

  Map<String, dynamic> _defaultValues(String action) => switch (action) {
    'task_add' => {'system': 'work', 'title': '', 'deadline_text': null},
    'task_list' => {'system': null, 'range_text': ''},
    'task_complete' => {'title': ''},
    'expense_add' => {
      'type': 'expense',
      'amount_text': null,
      'category': 'Food',
      'note': '',
      'date_text': null,
    },
    'expense_query' => {'type': 'expense', 'category': null, 'range_text': ''},
    'tutor' => {'mode': 'explain', 'text': ''},
    'news' => {'topic': null, 'range_text': null},
    'clarify' => {'intent': '', 'missing': '', 'reply': ''},
    _ => {'reply': ''},
  };

  void _normalizeChoices() {
    final choices = switch (_action) {
      'task_add' => {
        'system': ['work', 'personal'],
      },
      'task_list' => {
        'system': ['work', 'personal'],
      },
      'expense_add' => {
        'type': ['expense', 'income'],
        'category': [
          'Food',
          'Rent',
          'Transport',
          'Shopping',
          'Other',
          'Uncategorized',
        ],
      },
      'expense_query' => {
        'type': ['expense', 'income'],
        'category': [
          'Food',
          'Rent',
          'Transport',
          'Shopping',
          'Other',
          'Uncategorized',
        ],
      },
      'tutor' => {
        'mode': ['explain', 'correct', 'translate', 'quiz'],
      },
      _ => <String, List<String>>{},
    };
    for (final entry in choices.entries) {
      final current = _values[entry.key];
      final nullable =
          (_action == 'task_list' && entry.key == 'system') ||
          (_action == 'expense_query' && entry.key == 'category');
      if (current == null && nullable) continue;
      if (current is! String || !entry.value.contains(current)) {
        _values[entry.key] = nullable ? null : entry.value.first;
      }
    }
  }

  void _changeAction(String? action) {
    if (action == null || action == _action) return;
    setState(() {
      _action = action;
      _values = _defaultValues(action);
      _normalizeChoices();
      _missingIsList = false;
      _error = null;
    });
  }

  String _textValue(String key) {
    final value = _values[key];
    if (key == 'missing' && value is List) return value.join(', ');
    return value is String || value is num ? value.toString() : '';
  }

  Widget _textField(
    String key,
    String label, {
    bool required = false,
    bool nullable = true,
    bool multiline = false,
  }) => TextFormField(
    key: ValueKey('correction-field-$_action-$key'),
    initialValue: _textValue(key),
    maxLines: multiline ? 3 : 1,
    decoration: InputDecoration(labelText: label),
    validator: required
        ? (value) => value == null || value.trim().isEmpty
              ? 'Vui lòng nhập $label.'
              : null
        : null,
    onSaved: (value) {
      final text = value?.trim() ?? '';
      if (key == 'missing' && _missingIsList) {
        _values[key] = text
            .split(',')
            .map((part) => part.trim())
            .where((part) => part.isNotEmpty)
            .toList();
      } else {
        _values[key] = text.isEmpty && nullable ? null : text;
      }
    },
  );

  String _optionLabel(String option) => switch (option) {
    'work' => 'Công việc',
    'personal' => 'Cá nhân',
    'expense' => 'Chi',
    'income' => 'Thu',
    'Food' => 'Ăn uống',
    'Rent' => 'Nhà ở',
    'Transport' => 'Di chuyển',
    'Shopping' => 'Mua sắm',
    'Other' => 'Khác',
    'Uncategorized' => 'Chưa phân loại',
    'explain' => 'Giải thích',
    'correct' => 'Sửa lỗi',
    'translate' => 'Dịch',
    'quiz' => 'Luyện tập',
    _ => option,
  };

  Widget _choice(
    String key,
    String label,
    List<String> options, {
    String? nullableLabel,
  }) {
    final current = _values[key];
    final selected = current is String && options.contains(current)
        ? current
        : nullableLabel == null
        ? options.first
        : _nullOption;
    return DropdownButtonFormField<String>(
      key: ValueKey('correction-choice-$_action-$key'),
      initialValue: selected,
      decoration: InputDecoration(labelText: label),
      items: [
        if (nullableLabel != null)
          DropdownMenuItem(value: _nullOption, child: Text(nullableLabel)),
        for (final option in options)
          DropdownMenuItem(value: option, child: Text(_optionLabel(option))),
      ],
      onChanged: (value) {
        if (value != null) _values[key] = value == _nullOption ? null : value;
      },
    );
  }

  static const _nullOption = '__null__';

  List<Widget> _actionFields() => switch (_action) {
    'task_add' => [
      _choice('system', 'Nhóm', ['work', 'personal']),
      _textField('title', 'Tên việc', required: true),
      _textField('deadline_text', 'Hạn (không bắt buộc)'),
    ],
    'task_list' => [
      _choice('system', 'Nhóm', ['work', 'personal'], nullableLabel: 'Tất cả'),
      _textField('range_text', 'Khoảng thời gian', required: true),
    ],
    'task_complete' => [_textField('title', 'Tên việc', required: true)],
    'expense_add' => [
      _choice('type', 'Loại', ['expense', 'income']),
      _textField('amount_text', 'Số tiền (không bắt buộc)'),
      _choice('category', 'Danh mục', [
        'Food',
        'Rent',
        'Transport',
        'Shopping',
        'Other',
        'Uncategorized',
      ]),
      _textField('note', 'Ghi chú', nullable: false),
      _textField('date_text', 'Ngày (không bắt buộc)'),
    ],
    'expense_query' => [
      _choice('type', 'Loại', ['expense', 'income']),
      _choice('category', 'Danh mục', [
        'Food',
        'Rent',
        'Transport',
        'Shopping',
        'Other',
        'Uncategorized',
      ], nullableLabel: 'Tất cả'),
      _textField('range_text', 'Khoảng thời gian', required: true),
    ],
    'tutor' => [
      _choice('mode', 'Chế độ', ['explain', 'correct', 'translate', 'quiz']),
      _textField('text', 'Nội dung', required: true, multiline: true),
    ],
    'news' => [
      _textField('topic', 'Chủ đề (không bắt buộc)'),
      _textField('range_text', 'Khoảng thời gian (không bắt buộc)'),
    ],
    'clarify' => [
      _textField('intent', 'Ý định', required: true),
      _textField(
        'missing',
        'Thông tin còn thiếu (ngăn cách bằng dấu phẩy)',
        required: true,
      ),
      _textField('reply', 'Câu hỏi làm rõ', required: true, multiline: true),
    ],
    _ => [_textField('reply', 'Câu trả lời', required: true, multiline: true)],
  };

  Map<String, dynamic> _buildOutput() {
    return <String, dynamic>{'action': _action, ..._values};
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await ref
          .read(trainingLogApiProvider)
          .setCorrection(widget.logId, _buildOutput());
      if (mounted) Navigator.of(context).pop(true);
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _busy = false;
        _error = error is DioException && error.response?.statusCode == 400
            ? 'Đáp án chưa đúng định dạng. Vui lòng kiểm tra các trường bắt buộc.'
            : 'Không lưu được đáp án. Vui lòng thử lại.';
      });
    }
  }

  Future<void> _clear() async {
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await ref.read(trainingLogApiProvider).setCorrection(widget.logId, null);
      if (mounted) Navigator.of(context).pop(true);
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _busy = false;
        _error = 'Không xoá được bản sửa. Vui lòng thử lại.';
      });
    }
  }

  @override
  Widget build(BuildContext context) => FinanceSheetBody(
    title: 'Sửa đáp án huấn luyện',
    children: [
      DropdownButtonFormField<String>(
        key: const ValueKey('correction-action'),
        initialValue: _action,
        decoration: const InputDecoration(labelText: 'Loại hành động'),
        items: [
          for (final entry in _actionLabels.entries)
            DropdownMenuItem(value: entry.key, child: Text(entry.value)),
        ],
        onChanged: _busy ? null : _changeAction,
      ),
      Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            for (final field in _actionFields())
              Padding(padding: const EdgeInsets.only(top: 12), child: field),
          ],
        ),
      ),
      if (_error != null)
        Text(
          _error!,
          key: const ValueKey('correction-error'),
          style: TextStyle(color: Theme.of(context).colorScheme.error),
        ),
      FilledButton(
        onPressed: _busy ? null : _save,
        child: Text(_busy ? 'Đang lưu…' : 'Lưu đáp án'),
      ),
      if (widget.hasCorrection)
        TextButton(
          onPressed: _busy ? null : _clear,
          child: const Text('Xoá bản sửa'),
        ),
    ],
  );
}

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/theme/app_theme.dart';
import '../../../shared/utils/currency.dart';
import '../../../shared/widgets/form_bits.dart';
import '../models/finance_category.dart';
import '../providers/finance_provider.dart';
import '../services/finance_api.dart';

/// Port SetBudgetModal. Khác web: backend upsert theo danh mục, nên chọn danh
/// mục đã có ngân sách thì ô hạn mức tự điền hạn mức hiện tại (web để trống,
/// không biết mình đang sửa hay tạo mới).
/// [currentLimits]: categoryId → hạn mức đang có (từ summary.budgetProgress).
Future<void> showSetBudgetModal(
  BuildContext context, {
  required String projectId,
  required String projectName,
  required Map<String, double> currentLimits,
}) => showFinanceSheet<void>(
  context,
  SetBudgetModal(projectId: projectId, projectName: projectName, currentLimits: currentLimits),
);

class SetBudgetModal extends ConsumerStatefulWidget {
  const SetBudgetModal({super.key, required this.projectId, required this.projectName, required this.currentLimits});

  final String projectId;
  final String projectName;
  final Map<String, double> currentLimits;

  @override
  ConsumerState<SetBudgetModal> createState() => _SetBudgetModalState();
}

class _SetBudgetModalState extends ConsumerState<SetBudgetModal> {
  final _limit = TextEditingController();
  String? _categoryId;
  bool _submitting = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _limit.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _limit.dispose();
    super.dispose();
  }

  void _selectCategory(String? id) {
    setState(() {
      _categoryId = id;
      final existing = id == null ? null : widget.currentLimits[id];
      _limit.text = existing == null ? '' : existing.round().toString();
    });
  }

  Future<void> _submit() async {
    setState(() {
      _submitting = true;
      _error = null;
    });
    try {
      await ref
          .read(financeApiProvider)
          .setBudget(projectId: widget.projectId, categoryId: _categoryId!, limitAmount: double.parse(_limit.text));
      ref.invalidate(financeSummaryProvider(widget.projectId)); // budgetProgress nằm trong summary
      ref.invalidate(financeBudgetsProvider(widget.projectId));
      if (mounted) Navigator.of(context).pop();
    } on DioException {
      if (mounted) {
        setState(() {
          _submitting = false;
          _error = 'Không lưu được ngân sách, thử lại nhé.';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final categories = ref.watch(financeCategoriesProvider);
    final expense = categories.value?.where((c) => c.kind == MoneyKind.expense).toList();
    // Chọn sẵn danh mục chi đầu tiên khi danh sách vừa tải xong (như web).
    if (_categoryId == null && expense != null && expense.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && _categoryId == null) _selectCategory(expense.first.id);
      });
    }
    final existing = _categoryId == null ? null : widget.currentLimits[_categoryId];
    final limit = int.tryParse(_limit.text) ?? 0;

    return FinanceSheetBody(
      title: 'Đặt ngân sách — ${widget.projectName}',
      children: [
        if (expense == null)
          const Text('Đang tải danh mục...')
        else if (expense.isEmpty)
          const Text('Chưa có danh mục chi tiêu — tạo danh mục trước đã.')
        else
          DropdownButtonFormField<String>(
            initialValue: _categoryId,
            isExpanded: true,
            decoration: const InputDecoration(labelText: 'Danh mục chi'),
            items: [
              for (final c in expense)
                DropdownMenuItem(
                  value: c.id,
                  child: Text(
                    '${c.icon != null ? '${c.icon} ' : ''}${c.name}${widget.currentLimits.containsKey(c.id) ? '  · đã đặt' : ''}',
                  ),
                ),
            ],
            onChanged: _selectCategory,
          ),
        MoneyField(controller: _limit, hint: 'Hạn mức (VND)'),
        if (existing != null)
          Text(
            'Đang có hạn mức ${formatVnd(existing)} — lưu sẽ cập nhật.',
            style: const TextStyle(fontSize: 12, color: AppColors.yugen300),
          ),
        sheetError(context, _error),
        FilledButton(
          onPressed: !_submitting && _categoryId != null && limit > 0 ? _submit : null,
          child: Text(_submitting ? 'Đang lưu...' : 'Lưu'),
        ),
      ],
    );
  }
}

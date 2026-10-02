import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/widgets/form_bits.dart';
import '../models/finance_category.dart';
import '../providers/finance_provider.dart';
import '../providers/nghi_su_duong_provider.dart';
import '../services/finance_api.dart';

/// Port AddTransactionModal. Không có ô chọn ngày — như web, giao dịch ghi
/// vào lúc tạo (service có hỗ trợ occurredAt nhưng UI chưa dùng).
Future<void> showAddTransactionModal(BuildContext context, {required String projectId}) =>
    showFinanceSheet<void>(context, AddTransactionModal(projectId: projectId));

class AddTransactionModal extends ConsumerStatefulWidget {
  const AddTransactionModal({super.key, required this.projectId});

  final String projectId;

  @override
  ConsumerState<AddTransactionModal> createState() => _AddTransactionModalState();
}

class _AddTransactionModalState extends ConsumerState<AddTransactionModal> {
  final _amount = TextEditingController();
  final _note = TextEditingController();
  var _kind = MoneyKind.expense;
  String? _accountId;

  /// null = "Chưa phân loại".
  String? _categoryId;
  bool _defaultsApplied = false;
  bool _submitting = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _amount.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _amount.dispose();
    _note.dispose();
    super.dispose();
  }

  List<FinanceCategory> _ofKind(List<FinanceCategory>? all, MoneyKind kind) =>
      all?.where((c) => c.kind == kind).toList() ?? const [];

  /// Giống web: đổi thu/chi thì chọn danh mục đầu tiên của loại mới (danh mục
  /// cũ thuộc loại kia không còn hợp lệ).
  void _selectKind(MoneyKind kind) {
    final first = _ofKind(ref.read(financeCategoriesProvider).value, kind).firstOrNull;
    setState(() {
      _kind = kind;
      _categoryId = first?.id;
    });
  }

  Future<void> _submit() async {
    setState(() {
      _submitting = true;
      _error = null;
    });
    try {
      final note = _note.text.trim();
      await ref.read(financeApiProvider).createTransaction(
            projectId: widget.projectId,
            accountId: _accountId!,
            categoryId: _categoryId,
            kind: _kind,
            amount: double.parse(_amount.text),
            note: note.isEmpty ? null : note,
          );
      ref.invalidate(financeTransactionsProvider(widget.projectId));
      ref.invalidate(financeSummaryProvider(widget.projectId)); // thu/chi, ngân sách
      ref.invalidate(financeAccountsProvider); // số dư ví
      ref.invalidate(financeOverviewProvider); // card Tài chính ở trang chính
      if (mounted) Navigator.of(context).pop();
    } on DioException catch (e) {
      if (mounted) {
        setState(() {
          _submitting = false;
          _error = e.response?.data is Map && (e.response!.data as Map)['error'] == 'project_archived'
              ? 'Tháng này đã kết thúc, không thêm giao dịch được nữa.'
              : 'Không tạo được giao dịch, thử lại nhé.';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final accounts = ref.watch(financeAccountsProvider).value;
    final allCategories = ref.watch(financeCategoriesProvider).value;
    // Mặc định ví đầu tiên + danh mục chi đầu tiên, khi dữ liệu vừa có (như web).
    if (!_defaultsApplied && accounts != null && allCategories != null) {
      _defaultsApplied = true;
      _accountId = accounts.firstOrNull?.id;
      _categoryId = _ofKind(allCategories, _kind).firstOrNull?.id;
    }
    final categories = _ofKind(allCategories, _kind);
    final amount = int.tryParse(_amount.text) ?? 0;

    return FinanceSheetBody(
      title: 'Thêm giao dịch',
      children: [
        ChoiceRow<MoneyKind>(
          options: const {MoneyKind.expense: 'Chi tiêu', MoneyKind.income: 'Thu nhập'},
          selected: _kind,
          onSelected: _selectKind,
        ),
        MoneyField(controller: _amount, hint: 'Số tiền (VND)', autofocus: true),
        if (accounts == null || allCategories == null)
          const Text('Đang tải ví và danh mục...')
        else ...[
          DropdownButtonFormField<String>(
            initialValue: _accountId,
            isExpanded: true,
            decoration: const InputDecoration(labelText: 'Ví'),
            items: [for (final a in accounts) DropdownMenuItem(value: a.id, child: Text(a.name))],
            onChanged: (v) => setState(() => _accountId = v),
          ),
          // key theo loại: đổi thu/chi thì dựng lại dropdown với giá trị mới.
          DropdownButtonFormField<String?>(
            key: ValueKey(_kind),
            initialValue: _categoryId,
            isExpanded: true,
            decoration: const InputDecoration(labelText: 'Danh mục'),
            items: [
              const DropdownMenuItem<String?>(value: null, child: Text('Chưa phân loại')),
              for (final c in categories)
                DropdownMenuItem<String?>(
                  value: c.id,
                  child: Text('${c.icon != null ? '${c.icon} ' : ''}${c.name}'),
                ),
            ],
            onChanged: (v) => setState(() => _categoryId = v),
          ),
        ],
        TextField(controller: _note, decoration: const InputDecoration(hintText: 'Ghi chú (tuỳ chọn)')),
        if (accounts != null && accounts.isEmpty) const Text('Chưa có ví nào — tạo ví trước đã.'),
        sheetError(context, _error),
        FilledButton(
          onPressed: !_submitting && _accountId != null && amount > 0 ? _submit : null,
          child: Text(_submitting ? 'Đang lưu...' : 'Lưu'),
        ),
      ],
    );
  }
}

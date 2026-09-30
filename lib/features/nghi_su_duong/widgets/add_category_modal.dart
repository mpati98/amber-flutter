import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/finance_category.dart';
import '../providers/finance_provider.dart';
import '../services/finance_api.dart';
import 'finance_form_bits.dart';

/// Port AddCategoryModal. Icon là ô nhập thường như web (gõ/dán 1 emoji),
/// không có bảng chọn emoji.
Future<void> showAddCategoryModal(BuildContext context) => showFinanceSheet<void>(context, const AddCategoryModal());

class AddCategoryModal extends ConsumerStatefulWidget {
  const AddCategoryModal({super.key});

  @override
  ConsumerState<AddCategoryModal> createState() => _AddCategoryModalState();
}

class _AddCategoryModalState extends ConsumerState<AddCategoryModal> {
  final _name = TextEditingController();
  final _icon = TextEditingController();
  var _kind = MoneyKind.expense; // mặc định Chi tiêu, như web
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
    _icon.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    setState(() {
      _submitting = true;
      _error = null;
    });
    try {
      final icon = _icon.text.trim();
      await ref.read(financeApiProvider).createCategory(
            name: _name.text.trim(),
            icon: icon.isEmpty ? null : icon,
            kind: _kind,
          );
      ref.invalidate(financeCategoriesProvider);
      if (mounted) Navigator.of(context).pop();
    } on DioException {
      if (mounted) {
        setState(() {
          _submitting = false;
          _error = 'Không tạo được danh mục, thử lại nhé.';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return FinanceSheetBody(
      title: 'Thêm danh mục',
      children: [
        ChoiceRow<MoneyKind>(
          options: const {MoneyKind.expense: 'Chi tiêu', MoneyKind.income: 'Thu nhập'},
          selected: _kind,
          onSelected: (k) => setState(() => _kind = k),
        ),
        Row(
          spacing: 8,
          children: [
            SizedBox(
              width: 64,
              child: TextField(
                controller: _icon,
                textAlign: TextAlign.center,
                decoration: const InputDecoration(hintText: '🍜'),
              ),
            ),
            Expanded(
              child: TextField(
                controller: _name,
                autofocus: true,
                decoration: const InputDecoration(hintText: 'Tên danh mục (VD: Ăn uống)'),
              ),
            ),
          ],
        ),
        sheetError(context, _error),
        FilledButton(
          onPressed: !_submitting && _name.text.trim().isNotEmpty ? _submit : null,
          child: Text(_submitting ? 'Đang tạo...' : 'Tạo danh mục'),
        ),
      ],
    );
  }
}

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/widgets/form_bits.dart';
import '../models/finance_account.dart';
import '../providers/finance_provider.dart';
import '../providers/nghi_su_duong_provider.dart';
import '../services/finance_api.dart';

/// Port AddAccountModal. [projectId] = tháng đang xem, để tải lại tổng số dư.
Future<void> showAddAccountModal(BuildContext context, {required String projectId}) =>
    showFinanceSheet<void>(context, AddAccountModal(projectId: projectId));

class AddAccountModal extends ConsumerStatefulWidget {
  const AddAccountModal({super.key, required this.projectId});

  final String projectId;

  @override
  ConsumerState<AddAccountModal> createState() => _AddAccountModalState();
}

class _AddAccountModalState extends ConsumerState<AddAccountModal> {
  final _name = TextEditingController();
  final _balance = TextEditingController();
  var _type = AccountType.cash;
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
    _balance.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    setState(() {
      _submitting = true;
      _error = null;
    });
    try {
      await ref.read(financeApiProvider).createAccount(
            name: _name.text.trim(),
            type: _type,
            currentBalance: double.tryParse(_balance.text) ?? 0, // trống = 0, như web
          );
      ref.invalidate(financeAccountsProvider);
      ref.invalidate(financeSummaryProvider(widget.projectId)); // tổng số dư
      ref.invalidate(financeOverviewProvider); // card Tài chính ở trang chính
      if (mounted) Navigator.of(context).pop();
    } on DioException {
      if (mounted) {
        setState(() {
          _submitting = false;
          _error = 'Không tạo được ví, thử lại nhé.';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return FinanceSheetBody(
      title: 'Thêm ví',
      children: [
        TextField(
          controller: _name,
          autofocus: true,
          decoration: const InputDecoration(hintText: 'Tên ví (VD: Vietcombank, Momo)'),
        ),
        ChoiceRow<AccountType>(
          options: {
            for (final t in AccountType.values.where((t) => t != AccountType.unknown)) t: t.label,
          },
          selected: _type,
          onSelected: (t) => setState(() => _type = t),
        ),
        MoneyField(controller: _balance, hint: 'Số dư ban đầu (VND, để trống nếu = 0)'),
        sheetError(context, _error),
        FilledButton(
          onPressed: !_submitting && _name.text.trim().isNotEmpty ? _submit : null,
          child: Text(_submitting ? 'Đang tạo...' : 'Tạo ví'),
        ),
      ],
    );
  }
}

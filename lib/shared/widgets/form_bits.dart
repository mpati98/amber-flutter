import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../theme/app_theme.dart';
import '../utils/currency.dart';

/// Hàng nút chọn 1 trong nhiều (kiểu nút kincha khi chọn như các modal web).
class ChoiceRow<T> extends StatelessWidget {
  const ChoiceRow({super.key, required this.options, required this.selected, required this.onSelected});

  final Map<T, String> options;
  final T selected;
  final ValueChanged<T> onSelected;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 6,
      runSpacing: 6,
      children: [
        for (final e in options.entries)
          ChoiceChip(
            label: Text(e.value),
            selected: selected == e.key,
            showCheckmark: false,
            selectedColor: AppColors.kincha400,
            labelStyle: TextStyle(fontSize: 13, color: selected == e.key ? AppColors.ink950 : null),
            onSelected: (_) => onSelected(e.key),
          ),
      ],
    );
  }
}

/// Ô nhập số tiền VND: chỉ nhận chữ số, hiện số đã định dạng bên dưới để dễ
/// đọc số dài ("2940000" → "= 2.940.000₫").
class MoneyField extends StatelessWidget {
  const MoneyField({super.key, required this.controller, required this.hint, this.autofocus = false});

  final TextEditingController controller;
  final String hint;
  final bool autofocus;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<TextEditingValue>(
      valueListenable: controller,
      builder: (context, value, _) {
        final amount = int.tryParse(value.text);
        return TextField(
          controller: controller,
          autofocus: autofocus,
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          decoration: InputDecoration(
            hintText: hint,
            helperText: amount != null && amount > 0 ? '= ${formatVnd(amount)}' : null,
          ),
        );
      },
    );
  }
}

/// Khung bottom sheet chung của 4 modal tài chính.
Future<T?> showFinanceSheet<T>(BuildContext context, Widget child) => showModalBottomSheet<T>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      constraints: const BoxConstraints(maxWidth: 560),
      builder: (_) => child,
    );

class FinanceSheetBody extends StatelessWidget {
  const FinanceSheetBody({super.key, required this.title, required this.children});

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          spacing: 12,
          children: [
            Text(title, style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontSize: 20)),
            ...children,
          ],
        ),
      ),
    );
  }
}

Widget sheetError(BuildContext context, String? error) =>
    error == null ? const SizedBox.shrink() : Text(error, style: TextStyle(color: Theme.of(context).colorScheme.error));

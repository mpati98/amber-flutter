import 'dart:async';

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
  const MoneyField({super.key, required this.controller, required this.hint});

  final TextEditingController controller;
  final String hint;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<TextEditingValue>(
      valueListenable: controller,
      builder: (context, value, _) {
        final amount = int.tryParse(value.text);
        return TextField(
          controller: controller,
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

/// Form nhập liệu chung (tài chính, học tập, Trà Đình) — màn hình đầy đủ, nội
/// dung căn từ trên xuống. Trước đây là bottom sheet bám đáy: trên Safari iOS
/// (bàn phím chỉ co visual viewport, layout viewport giữ nguyên) phần đầu form
/// bị đẩy khuất dưới thanh trạng thái và thừa khoảng trống phía trên bàn phím.
/// Kết quả trả về như cũ: `Navigator.pop(value)` trong form → Future hoàn tất với value;
/// đóng bằng X / nút quay lại → null.
Future<T?> showFinanceSheet<T>(BuildContext context, Widget child) => showDialog<T>(
  context: context,
  useRootNavigator: true,
  // Đầy màn hình: AppBar tự chừa thanh trạng thái, body có SafeArea riêng.
  useSafeArea: false,
  builder: (context) {
    final media = MediaQuery.of(context);
    // Dialog tự cộng viewInsets (bàn phím) vào padding rồi xoá viewInsets cho
    // widget con. Giấu viewInsets khỏi Dialog và trả lại cho bên trong, để
    // Scaffold (resizeToAvoidBottomInset) là nơi DUY NHẤT xử lý bàn phím.
    return MediaQuery(
      data: media.removeViewInsets(removeBottom: true),
      child: Dialog.fullscreen(
        child: MediaQuery(data: media, child: child),
      ),
    );
  },
);

/// Khung của form trong [showFinanceSheet]: AppBar (nút X + tiêu đề), nội dung
/// cuộn căn trên, nút hành động chính là phần tử cuối của [children] (không ghim đáy).
/// KHÔNG cộng viewInsets ở đây — Scaffold đã co body khi có bàn phím.
class FinanceSheetBody extends StatefulWidget {
  const FinanceSheetBody({super.key, required this.title, required this.children});

  final String title;
  final List<Widget> children;

  @override
  State<FinanceSheetBody> createState() => _FinanceSheetBodyState();
}

class _FinanceSheetBodyState extends State<FinanceSheetBody> {
  /// Chờ bàn phím mở xong (iOS ~250ms) rồi mới cuộn tới trường đang focus.
  static const _keyboardSettle = Duration(milliseconds: 300);

  FocusNode? _lastFocus;
  Timer? _scrollTimer;

  @override
  void initState() {
    super.initState();
    FocusManager.instance.addListener(_onFocusChanged);
  }

  @override
  void dispose() {
    FocusManager.instance.removeListener(_onFocusChanged);
    _scrollTimer?.cancel();
    super.dispose();
  }

  /// Trường trong form này vừa được focus → sau khi bàn phím hiện xong, cuộn
  /// cho trường nằm trong vùng nhìn thấy (form dài, trường ở dưới).
  void _onFocusChanged() {
    final node = FocusManager.instance.primaryFocus;
    if (node == null || node == _lastFocus) return;
    _lastFocus = node;
    final ctx = node.context;
    if (ctx == null || ctx.findAncestorStateOfType<_FinanceSheetBodyState>() != this) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollTimer?.cancel();
      _scrollTimer = Timer(_keyboardSettle, () {
        final target = node.context;
        if (!mounted || !node.hasPrimaryFocus || target == null || !target.mounted) return;
        Scrollable.ensureVisible(target, alignment: 0.1, duration: const Duration(milliseconds: 200));
      });
    });
    // Post-frame callback không tự xin frame — đổi focus không phải lúc nào cũng rebuild.
    WidgetsBinding.instance.ensureVisualUpdate();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        leading: const CloseButton(),
        titleSpacing: 0,
        title: Text(widget.title, style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontSize: 20)),
      ),
      body: SafeArea(
        top: false, // AppBar đã chừa thanh trạng thái
        child: SingleChildScrollView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
          child: Align(
            alignment: Alignment.topCenter,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 560), // màn rộng: giữ cột form như sheet cũ
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                spacing: 12,
                children: widget.children,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

Widget sheetError(BuildContext context, String? error) =>
    error == null ? const SizedBox.shrink() : Text(error, style: TextStyle(color: Theme.of(context).colorScheme.error));

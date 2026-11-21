import 'package:dio/dio.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/theme/design_tokens.dart';
import '../../../shared/widgets/app_toast.dart';
import '../../../shared/widgets/form_bits.dart';
import '../../../shared/widgets/list_frame.dart';
import '../models/reading_goal.dart';
import '../providers/tang_kinh_cac_provider.dart';
import '../services/reading_goal_api.dart';

// Kế hoạch đọc (trước là tầng 3 riêng) — nay nằm ở đầu cố định khung Danh sách của tầng Sách: [ReadingGoalStrip] + form
// đặt / sửa mục tiêu mở dạng modal ([showReadingGoalSheet]).

/// Tiến độ mục tiêu đọc năm [year]: "x / y sách" + thanh (khi có mục tiêu), số trang đã đọc, ghi chú; nút đặt / sửa mục tiêu.
class ReadingGoalStrip extends ConsumerWidget {
  const ReadingGoalStrip({super.key, required this.year});

  final int year;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final goal = ref.watch(readingGoalProvider(year));
    final g = goal.value;
    final target = g?.targetBooks;
    final hasTarget = target != null && target > 0;
    return Column(
      key: const ValueKey('reading-goal-strip'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: 2,
      children: [
        Row(
          spacing: 8,
          children: [
            Expanded(
              child: Text(
                'MỤC TIÊU ĐỌC $year',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 12, letterSpacing: 1, color: DesignColors.gold),
              ),
            ),
            // Co được: khung Danh sách hẹp (điện thoại, chữ phóng to) không đẩy tràn hàng.
            Flexible(
              child: FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerRight,
                child: DesignButton.outline(
                  key: const ValueKey('goal-edit'),
                  label: hasTarget ? 'Sửa mục tiêu' : 'Đặt mục tiêu',
                  onPressed: g == null ? null : () => showReadingGoalSheet(context, year),
                ),
              ),
            ),
          ],
        ),
        Text(
          switch (goal) {
            AsyncData(value: final v) => v.targetBooks == null ? '${v.booksRead} sách · chưa đặt mục tiêu' : '${v.booksRead} / ${v.targetBooks} sách',
            AsyncError() => 'Không tải được tiến độ.',
            _ => 'Đang tải…',
          },
          key: const ValueKey('goal-progress'),
          style: DesignText.muted,
        ),
        // Chưa đặt mục tiêu thì không có mẫu số → không vẽ thanh.
        if (g != null && hasTarget) DesignProgressBar(g.booksRead * 100 / target),
        if (g != null)
          Text(
            [
              '${g.pagesRead} trang đã đọc',
              if (g.note case final n? when n.trim().isNotEmpty) n.trim(),
            ].join(' · '),
            key: const ValueKey('goal-pages'),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: DesignText.muted,
          ),
      ],
    );
  }
}

/// Form đặt / sửa mục tiêu năm [year] (form toàn màn chung — [showFinanceSheet]). Chỉ 2 ô như web: số sách, ghi chú
/// (web không có ô targetPages dù model / API có). Lưu xong đóng form.
Future<void> showReadingGoalSheet(BuildContext context, int year) => showFinanceSheet<void>(context, ReadingGoalSheet(year: year));

class ReadingGoalSheet extends ConsumerStatefulWidget {
  const ReadingGoalSheet({super.key, required this.year});

  final int year;

  @override
  ConsumerState<ReadingGoalSheet> createState() => _ReadingGoalSheetState();
}

class _ReadingGoalSheetState extends ConsumerState<ReadingGoalSheet> {
  late final ReadingGoal? _initial = ref.read(readingGoalProvider(widget.year)).value;
  late final _targetBooks = TextEditingController(text: _initial?.targetBooks?.toString() ?? '');
  late final _note = TextEditingController(text: _initial?.note ?? '');
  bool _saving = false;

  @override
  void dispose() {
    _targetBooks.dispose();
    _note.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    try {
      // Giống web: ô trống gửi null (xoá mục tiêu/ghi chú); targetPages không gửi → giữ nguyên.
      await ref.read(readingGoalApiProvider).upsertReadingGoal(
        widget.year,
        targetBooks: int.tryParse(_targetBooks.text),
        note: _note.text.trim().isEmpty ? null : _note.text.trim(),
      );
      ref.invalidate(readingGoalProvider(widget.year));
      if (!mounted) return;
      showToast(context, 'Đã lưu mục tiêu.', type: ToastType.success);
      Navigator.of(context).pop();
    } on DioException {
      if (mounted) {
        showToast(context, 'Không lưu được mục tiêu, thử lại nhé.', type: ToastType.error);
        setState(() => _saving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return FinanceSheetBody(
      title: 'Mục tiêu đọc ${widget.year}',
      children: [
        TextField(
          key: const ValueKey('goal-books'),
          controller: _targetBooks,
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          decoration: const InputDecoration(labelText: 'Số sách muốn đọc'),
        ),
        TextField(
          key: const ValueKey('goal-note'),
          controller: _note,
          minLines: 2,
          maxLines: 5,
          decoration: const InputDecoration(labelText: 'Ghi chú định hướng đọc năm nay'),
        ),
        FilledButton(
          key: const ValueKey('goal-save'),
          onPressed: _saving ? null : _save,
          child: Text(_saving ? 'Đang lưu...' : 'Lưu mục tiêu'),
        ),
      ],
    );
  }
}

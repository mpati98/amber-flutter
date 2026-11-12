import 'package:dio/dio.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/theme/design_tokens.dart';
import '../../../shared/widgets/app_toast.dart';
import '../../../shared/widgets/design_page.dart';
import '../../../shared/widgets/list_frame.dart';
import '../../../shared/widgets/overview_block.dart';
import '../models/reading_goal.dart';
import '../providers/tang_kinh_cac_provider.dart';
import '../services/reading_goal_api.dart';

/// /tang-kinh-cac/ke-hoach-doc (Tầng 3): Tổng quan = tiến độ năm hiện tại (sách / mục tiêu + thanh, trang đã đọc, ghi chú)
/// → khung "Đặt mục tiêu" (số sách, ghi chú). Form chỉ có 2 ô như web — web không có ô targetPages dù model/API có.
class KeHoachDocScreen extends ConsumerStatefulWidget {
  const KeHoachDocScreen({super.key});

  @override
  ConsumerState<KeHoachDocScreen> createState() => _KeHoachDocScreenState();
}

class _KeHoachDocScreenState extends ConsumerState<KeHoachDocScreen> {
  final _year = DateTime.now().year;
  final _targetBooks = TextEditingController();
  final _note = TextEditingController();
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    // Điền form từ dữ liệu server, cả lần đầu lẫn sau khi lưu (giống web gọi lại load()).
    ref.listenManual(readingGoalProvider(_year), (_, next) {
      final goal = next.value;
      if (goal == null) return;
      _targetBooks.text = goal.targetBooks?.toString() ?? '';
      _note.text = goal.note ?? '';
    }, fireImmediately: true);
  }

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
        _year,
        targetBooks: int.tryParse(_targetBooks.text),
        note: _note.text.trim().isEmpty ? null : _note.text.trim(),
      );
      ref.invalidate(readingGoalProvider(_year));
      if (mounted) showToast(context, 'Đã lưu mục tiêu.', type: ToastType.success);
    } on DioException {
      if (mounted) showToast(context, 'Không lưu được mục tiêu, thử lại nhé.', type: ToastType.error);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final goal = ref.watch(readingGoalProvider(_year));

    return DesignPage(
      title: 'Kế hoạch đọc',
      backFallback: '/tang-kinh-cac',
      onRefresh: () => ref.refresh(readingGoalProvider(_year).future),
      overview: OverviewBlock(
        title: 'Tiến độ $_year',
        labelWidth: 90,
        rows: switch (goal) {
          AsyncData(:final value) => _progressRows(value),
          AsyncError() => [OverviewRow.muted(label: 'Sách', text: 'Không tải được tiến độ.')],
          _ => [OverviewRow.muted(label: 'Sách', text: 'Đang tải…')],
        },
      ),
      content: (context, _) => ListFrame(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          spacing: 10,
          children: [
            Text(
              'ĐẶT MỤC TIÊU CHO $_year',
              style: const TextStyle(fontSize: 13, letterSpacing: 1, color: DesignColors.gold),
            ),
            TextField(
              key: const ValueKey('goal-books'),
              controller: _targetBooks,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              style: DesignText.body,
              cursorColor: DesignColors.gold,
              decoration: designInput('Số sách muốn đọc'),
            ),
            TextField(
              key: const ValueKey('goal-note'),
              controller: _note,
              minLines: 2,
              maxLines: 5,
              style: DesignText.body,
              cursorColor: DesignColors.gold,
              decoration: designInput('Ghi chú định hướng đọc năm nay...'),
            ),
            Align(
              alignment: Alignment.centerRight,
              child: DesignButton.primary(
                key: const ValueKey('goal-save'),
                label: _saving ? 'Đang lưu...' : 'Lưu mục tiêu',
                onPressed: _saving ? null : _save,
                minHeight: 40,
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _progressRows(ReadingGoal g) {
    final target = g.targetBooks;
    return [
      OverviewRow(
        label: 'Sách',
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              target == null ? '${g.booksRead} sách · chưa đặt mục tiêu' : '${g.booksRead} / $target sách',
              key: const ValueKey('goal-progress'),
              style: DesignText.muted,
            ),
            // Chưa đặt mục tiêu thì không có mẫu số → không vẽ thanh.
            if (target != null && target > 0) DesignProgressBar(g.booksRead * 100 / target),
          ],
        ),
      ),
      OverviewRow.muted(label: 'Trang', text: '${g.pagesRead} trang đã đọc'),
      if (g.note != null)
        OverviewRow(
          label: 'Ghi chú',
          child: Text(g.note!, style: DesignText.muted.copyWith(fontStyle: FontStyle.italic)),
        ),
    ];
  }
}

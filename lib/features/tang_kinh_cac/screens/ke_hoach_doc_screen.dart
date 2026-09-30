import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/theme/app_theme.dart';
import '../../../shared/widgets/progress_ring.dart';
import '../../../shared/widgets/scroll_card.dart';
import '../models/reading_goal.dart';
import '../providers/tang_kinh_cac_provider.dart';
import '../services/reading_goal_api.dart';

/// Port /tang-kinh-cac/ke-hoach-doc: thẻ tiến độ năm hiện tại + form mục tiêu.
/// Form chỉ có đúng 2 ô như web (số sách, ghi chú) — web không có ô
/// targetPages dù model/API có field này.
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
    final messenger = ScaffoldMessenger.of(context);
    try {
      // Giống web: ô trống gửi null (xoá mục tiêu/ghi chú); targetPages không gửi → giữ nguyên.
      await ref.read(readingGoalApiProvider).upsertReadingGoal(
            _year,
            targetBooks: int.tryParse(_targetBooks.text),
            note: _note.text.trim().isEmpty ? null : _note.text.trim(),
          );
      ref.invalidate(readingGoalProvider(_year));
      messenger.showSnackBar(const SnackBar(content: Text('Đã lưu mục tiêu.')));
    } on DioException {
      messenger.showSnackBar(const SnackBar(content: Text('Không lưu được mục tiêu, thử lại nhé.')));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final goal = ref.watch(readingGoalProvider(_year));

    return Scaffold(
      appBar: AppBar(title: const Text('Kế hoạch đọc')),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 640),
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              goal.when(
                data: (g) => _ProgressCard(goal: g),
                loading: () => const ScrollCard(
                  glow: ScrollCardGlow.kincha,
                  child: SizedBox(height: 128, child: Center(child: CircularProgressIndicator())),
                ),
                error: (_, _) => ScrollCard(
                  glow: ScrollCardGlow.kincha,
                  child: Text('Không tải được tiến độ.', style: TextStyle(color: Colors.white.withValues(alpha: 0.4))),
                ),
              ),
              const SizedBox(height: 24), // gap-6
              ScrollCard(
                glow: ScrollCardGlow.yugen,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  spacing: 12, // space-y-3
                  children: [
                    _CardLabel('ĐẶT MỤC TIÊU CHO $_year', color: AppColors.yugen300),
                    const SizedBox(height: 4),
                    TextField(
                      controller: _targetBooks,
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      decoration: const InputDecoration(hintText: 'Số sách muốn đọc'),
                    ),
                    TextField(
                      controller: _note,
                      minLines: 2,
                      maxLines: 5,
                      decoration: const InputDecoration(hintText: 'Ghi chú định hướng đọc năm nay...'),
                    ),
                    FilledButton(
                      onPressed: _saving ? null : _save,
                      child: Text(_saving ? 'Đang lưu...' : 'Lưu mục tiêu'),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ProgressCard extends StatelessWidget {
  const _ProgressCard({required this.goal});

  final ReadingGoal goal;

  @override
  Widget build(BuildContext context) {
    final serif = Theme.of(context).textTheme.headlineSmall;
    return ScrollCard(
      glow: ScrollCardGlow.kincha,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _CardLabel('TIẾN ĐỘ ${goal.year}', color: AppColors.kincha400),
          const SizedBox(height: 16), // mb-4
          Row(
            spacing: 24, // gap-6
            children: [
              // Chưa đặt mục tiêu: max 1 → vòng 0% (booksRead không vẽ được khi thiếu mẫu số).
              ProgressRing(
                value: goal.targetBooks == null ? 0 : goal.booksRead.toDouble(),
                max: (goal.targetBooks ?? 1).toDouble(),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text.rich(
                      TextSpan(
                        text: '${goal.booksRead}',
                        style: serif?.copyWith(fontSize: 20, color: Colors.white),
                        children: [
                          TextSpan(
                            text: ' / ${goal.targetBooks ?? '?'} sách',
                            style: TextStyle(color: Colors.white.withValues(alpha: 0.4)),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${goal.pagesRead} trang đã đọc',
                      style: TextStyle(fontSize: 14, color: Colors.white.withValues(alpha: 0.5)),
                    ),
                    if (goal.note != null) ...[
                      const SizedBox(height: 8),
                      Text(
                        goal.note!,
                        style: const TextStyle(fontSize: 14, fontStyle: FontStyle.italic, color: AppColors.yugen300),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _CardLabel extends StatelessWidget {
  const _CardLabel(this.text, {required this.color});

  final String text;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(fontSize: 12, letterSpacing: 12 * 0.05, color: color.withValues(alpha: 0.8)),
    );
  }
}

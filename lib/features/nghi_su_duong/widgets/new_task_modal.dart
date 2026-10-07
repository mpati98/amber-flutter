import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/theme/app_theme.dart';
import '../../../shared/utils/vn_time.dart';
import '../../../shared/widgets/form_bits.dart';
import '../providers/nghi_su_duong_provider.dart';
import '../services/nghi_su_duong_api.dart';
import 'task_badges.dart';

/// Form "Thêm việc" cho đúng một dự án ([projectId] cố định, không có ô chọn dự án và không
/// phụ thuộc danh sách dự án đang chạy — dùng được cả khi dự án đang Tạm dừng hoặc Đã xong).
/// Giống web: urgency luôn 2, ngày bắt đầu và hạn mặc định là hôm nay theo giờ VN.
Future<void> showNewTaskModal(BuildContext context, {required String projectId}) =>
    showFinanceSheet<void>(context, NewTaskModal(projectId: projectId));

class NewTaskModal extends ConsumerStatefulWidget {
  const NewTaskModal({super.key, required this.projectId});

  final String projectId;

  @override
  ConsumerState<NewTaskModal> createState() => _NewTaskModalState();
}

class _NewTaskModalState extends ConsumerState<NewTaskModal> {
  final _title = TextEditingController();
  int _importance = 2; // mặc định TB, như web
  bool _submitting = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _title.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _title.dispose();
    super.dispose();
  }

  bool get _canSubmit => !_submitting && _title.text.trim().isNotEmpty;

  Future<void> _submit() async {
    setState(() {
      _submitting = true;
      _error = null;
    });
    final today = vnToday();
    try {
      await ref.read(nghiSuDuongApiProvider).createTask(
            projectId: widget.projectId,
            title: _title.text.trim(),
            importance: _importance,
            urgency: 2,
            startDate: today,
            dueDate: today,
          );
      // Bảng việc, tiến độ dự án (tổng số việc đổi), summary, cảnh báo hạn việc.
      refreshProjectData(ref.invalidate, widget.projectId);
      if (mounted) Navigator.of(context).pop();
    } on DioException {
      if (mounted) {
        setState(() {
          _submitting = false;
          _error = 'Không tạo được việc, thử lại nhé.';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final d = vnNow();
    return FinanceSheetBody(
      title: 'Thêm việc',
      children: [
        TextField(
          controller: _title,
          decoration: const InputDecoration(hintText: 'Tên việc'),
          onSubmitted: (_) => _canSubmit ? _submit() : null,
        ),
        Row(
          children: [
            Expanded(
              child: Text(
                'Hôm nay, ${d.day}/${d.month}',
                style: TextStyle(fontSize: 12, color: Colors.white.withValues(alpha: 0.4)),
              ),
            ),
            // Chọn độ quan trọng bằng chính ImportanceTag (Cao → Thấp như web).
            for (final level in const [3, 2, 1])
              Padding(
                padding: const EdgeInsets.only(left: 6),
                child: _ImportanceChoice(
                  level: level,
                  selected: _importance == level,
                  onTap: () => setState(() => _importance = level),
                ),
              ),
          ],
        ),
        if (_error != null) Text(_error!, style: TextStyle(color: Theme.of(context).colorScheme.error)),
        FilledButton(
          onPressed: _canSubmit ? _submit : null,
          child: Text(_submitting ? 'Đang tạo...' : 'Tạo việc'),
        ),
      ],
    );
  }
}

/// ImportanceTag làm nút chọn: mức đang chọn rõ màu + viền kincha, còn lại mờ.
class _ImportanceChoice extends StatelessWidget {
  const _ImportanceChoice({required this.level, required this.selected, required this.onTap});

  final int level;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: selected,
      label: 'Độ quan trọng ${level == 3 ? 'Cao' : level == 2 ? 'TB' : 'Thấp'}',
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Container(
          padding: const EdgeInsets.all(3),
          decoration: BoxDecoration(
            border: Border.all(color: selected ? AppColors.kincha400 : Colors.transparent, width: 1.5),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Opacity(opacity: selected ? 1 : 0.35, child: ImportanceTag(level)),
        ),
      ),
    );
  }
}

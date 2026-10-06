import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/widgets/form_bits.dart';
import '../models/feed_source.dart';
import '../services/kieu_lau_api.dart';

/// Mở form toàn màn hình chung; trả về nguồn vừa tạo, hoặc null nếu đóng.
Future<FeedSource?> showAddFeedSourceDialog(BuildContext context) =>
    showFinanceSheet<FeedSource>(context, const AddFeedSourceDialog());

/// Port tối thiểu từ AddFeedSourceModal (web). Trả về [FeedSource] vừa tạo
/// qua `Navigator.pop`, hoặc null nếu huỷ.
class AddFeedSourceDialog extends ConsumerStatefulWidget {
  const AddFeedSourceDialog({super.key});

  @override
  ConsumerState<AddFeedSourceDialog> createState() => _AddFeedSourceDialogState();
}

class _AddFeedSourceDialogState extends ConsumerState<AddFeedSourceDialog> {
  final _name = TextEditingController();
  final _url = TextEditingController();
  bool _submitting = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    // Nút "Thêm" bật/tắt theo nội dung 2 ô.
    _name.addListener(() => setState(() {}));
    _url.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _name.dispose();
    _url.dispose();
    super.dispose();
  }

  bool get _canSubmit => !_submitting && _name.text.trim().isNotEmpty && _url.text.trim().isNotEmpty;

  Future<void> _submit() async {
    setState(() {
      _submitting = true;
      _error = null;
    });
    try {
      final created = await ref.read(kieuLauApiProvider).addFeedSource(_name.text.trim(), _url.text.trim());
      if (mounted) Navigator.of(context).pop(created);
    } on DioException {
      if (mounted) {
        setState(() {
          _submitting = false;
          _error = 'Không thêm được nguồn — kiểm tra lại URL nhé.';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return FinanceSheetBody(
      title: 'Thêm nguồn tin',
      children: [
        TextField(
          controller: _name,
          decoration: const InputDecoration(hintText: 'Tên nguồn (VD: TechCrunch)'),
        ),
        TextField(
          controller: _url,
          keyboardType: TextInputType.url,
          decoration: const InputDecoration(hintText: 'URL RSS (VD: https://example.com/feed)'),
          onSubmitted: (_) => _canSubmit ? _submit() : null,
        ),
        sheetError(context, _error),
        FilledButton(
          onPressed: _canSubmit ? _submit : null,
          child: Text(_submitting ? 'Đang thêm...' : 'Thêm'),
        ),
      ],
    );
  }
}

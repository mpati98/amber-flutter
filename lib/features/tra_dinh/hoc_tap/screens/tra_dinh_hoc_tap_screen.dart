import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../shared/widgets/app_bar_back.dart';
import '../providers/hoc_tap_provider.dart';
import '../widgets/log_sheet.dart';
import 'overview_tab.dart';

/// /tra-dinh: màn "Hôm nay" của Trà Đình (phòng học hằng ngày). Lịch dự kiến, Thống kê, quản lý khóa / môn nằm ở Nghị Sự Đường
/// (/hoc-tap...). Các liên kết cũ `/tra-dinh?tab=…` được router chuyển hướng (xem app_router.dart).
///
/// `?openLog=1&subjectId=…` (từ thẻ routine STUDY): chọn môn đó, tự mở sheet ghi buổi học MỘT lần rồi xoá query khỏi URL.
class TraDinhHocTapScreen extends ConsumerStatefulWidget {
  const TraDinhHocTapScreen({super.key, this.openLog = false, this.subjectId});

  final bool openLog;
  final String? subjectId;

  @override
  ConsumerState<TraDinhHocTapScreen> createState() => _TraDinhHocTapScreenState();
}

class _TraDinhHocTapScreenState extends ConsumerState<TraDinhHocTapScreen> {
  @override
  void initState() {
    super.initState();
    if (widget.openLog) WidgetsBinding.instance.addPostFrameCallback((_) => _openLog());
  }

  @override
  void didUpdateWidget(TraDinhHocTapScreen old) {
    super.didUpdateWidget(old);
    // Chỉ khi openLog vừa bật (false → true): sau khi mở sheet ta xoá query nên không lặp lại.
    if (widget.openLog && !old.openLog) WidgetsBinding.instance.addPostFrameCallback((_) => _openLog());
  }

  void _openLog() {
    if (!mounted) return;
    final subjectId = widget.subjectId;
    if (subjectId != null) ref.read(selectedSubjectIdProvider.notifier).select(subjectId);
    context.go('/tra-dinh'); // xoá openLog / subjectId khỏi URL → Hôm nay
    showLogSheet(context, subjectId: subjectId);
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(leading: const AppBarBack(label: 'Trà Đình'), leadingWidth: 130, title: const Text('Hôm nay')),
    body: const OverviewTab(),
  );
}

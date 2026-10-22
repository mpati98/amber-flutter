import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../shared/theme/app_theme.dart';
import '../providers/hoc_tap_provider.dart';
import '../widgets/log_sheet.dart';
import 'overview_tab.dart';
import 'schedule_tab.dart';
import 'stats_tab.dart';
import '../../../../shared/widgets/app_bar_back.dart';

const hocTapTabs = ['overview', 'schedule', 'stats'];

/// /tra-dinh: Học tập của Trà Đình, 3 tab Tổng quan | Lịch | Thống kê. Tab lưu ở `?tab=`.
///
/// `?openLog=1&subjectId=…` (từ thẻ routine STUDY): mở tab Tổng quan, tự mở sheet ghi buổi học MỘT lần rồi xoá query khỏi URL.
class TraDinhHocTapScreen extends ConsumerStatefulWidget {
  const TraDinhHocTapScreen({super.key, this.tab, this.openLog = false, this.subjectId, this.view, this.date, this.range, this.subject});

  final String? tab;

  /// Tab Lịch: `week` | `month` và ngày mốc "YYYY-MM-DD".
  final String? view;
  final String? date;

  /// Tab Thống kê: `7` | `30` | `all` và môn (`all` = tất cả môn, không có = môn đang chọn).
  final String? range;
  final String? subject;
  final bool openLog;
  final String? subjectId;

  @override
  ConsumerState<TraDinhHocTapScreen> createState() => _TraDinhHocTapScreenState();
}

class _TraDinhHocTapScreenState extends ConsumerState<TraDinhHocTapScreen> with SingleTickerProviderStateMixin {
  late final _controller = TabController(length: hocTapTabs.length, vsync: this, initialIndex: _indexOf(widget.tab));

  static int _indexOf(String? tab) {
    final i = hocTapTabs.indexOf(tab ?? '');
    return i < 0 ? 0 : i;
  }

  @override
  void initState() {
    super.initState();
    if (widget.openLog) WidgetsBinding.instance.addPostFrameCallback((_) => _openLog());
    _rememberSchedule();
    _controller.addListener(() {
      if (_controller.indexIsChanging) return;
      final tab = hocTapTabs[_controller.index];
      if (tab == (widget.tab ?? 'overview')) return;
      // Quay lại tab Lịch: khôi phục chế độ + ngày đang xem (giữ trong provider, mất khi tải lại trang).
      final nav = tab == 'schedule' ? ref.read(scheduleNavProvider) : null;
      context.go(nav == null ? '/tra-dinh?tab=$tab' : '/tra-dinh?tab=$tab&view=${nav.view}&date=${nav.date}');
    });
  }

  @override
  void didUpdateWidget(TraDinhHocTapScreen old) {
    super.didUpdateWidget(old);
    _rememberSchedule();
    // Chỉ khi openLog vừa bật (false → true): sau khi mở sheet ta xoá query nên không lặp lại.
    if (widget.openLog && !old.openLog) WidgetsBinding.instance.addPostFrameCallback((_) => _openLog());
    final i = _indexOf(widget.tab);
    if (i != _controller.index) _controller.animateTo(i);
  }

  /// URL đang ở tab Lịch với view/date → nhớ lại cho lần chuyển tab sau.
  void _rememberSchedule() {
    final view = widget.view;
    final date = widget.date;
    if (widget.tab == 'schedule' && (view == 'week' || view == 'month') && date != null) {
      Future.microtask(() {
        if (mounted) ref.read(scheduleNavProvider.notifier).remember(view!, date);
      });
    }
  }

  void _openLog() {
    if (!mounted) return;
    final subjectId = widget.subjectId;
    if (subjectId != null) ref.read(selectedSubjectIdProvider.notifier).select(subjectId);
    context.go('/tra-dinh'); // xoá openLog / subjectId / tab khỏi URL → Tổng quan
    showLogSheet(context, subjectId: subjectId);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: const AppBarBack(),
        title: const Text('Trà Đình'),
        bottom: TabBar(
          controller: _controller,
          indicatorColor: AppColors.kincha400,
          tabs: const [Tab(text: 'Tổng quan'), Tab(text: 'Lịch'), Tab(text: 'Thống kê')],
        ),
      ),
      body: TabBarView(
        controller: _controller,
        children: [const OverviewTab(), ScheduleTab(view: widget.view, date: widget.date), StatsTab(range: widget.range, subject: widget.subject)],
      ),
    );
  }
}

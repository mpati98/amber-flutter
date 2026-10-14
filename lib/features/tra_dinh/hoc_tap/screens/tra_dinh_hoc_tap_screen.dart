import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../shared/theme/app_theme.dart';
import '../providers/hoc_tap_provider.dart';
import '../widgets/log_sheet.dart';
import 'overview_tab.dart';

const hocTapTabs = ['overview', 'schedule', 'stats'];

/// /tra-dinh: Học tập của Trà Đình, 3 tab Tổng quan | Lịch | Thống kê. Tab lưu ở `?tab=`.
///
/// `?openLog=1&subjectId=…` (từ thẻ routine STUDY): mở tab Tổng quan, tự mở sheet ghi buổi học MỘT lần rồi xoá query khỏi URL.
class TraDinhHocTapScreen extends ConsumerStatefulWidget {
  const TraDinhHocTapScreen({super.key, this.tab, this.openLog = false, this.subjectId});

  final String? tab;
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
    _controller.addListener(() {
      if (_controller.indexIsChanging) return;
      final tab = hocTapTabs[_controller.index];
      if (tab != (widget.tab ?? 'overview')) context.go('/tra-dinh?tab=$tab');
    });
  }

  @override
  void didUpdateWidget(TraDinhHocTapScreen old) {
    super.didUpdateWidget(old);
    // Chỉ khi openLog vừa bật (false → true): sau khi mở sheet ta xoá query nên không lặp lại.
    if (widget.openLog && !old.openLog) WidgetsBinding.instance.addPostFrameCallback((_) => _openLog());
    final i = _indexOf(widget.tab);
    if (i != _controller.index) _controller.animateTo(i);
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
        title: const Text('Trà Đình'),
        bottom: TabBar(
          controller: _controller,
          indicatorColor: AppColors.kincha400,
          tabs: const [Tab(text: 'Tổng quan'), Tab(text: 'Lịch'), Tab(text: 'Thống kê')],
        ),
      ),
      body: TabBarView(
        controller: _controller,
        children: const [OverviewTab(), _Placeholder('Lịch'), _Placeholder('Thống kê')],
      ),
    );
  }
}

class _Placeholder extends StatelessWidget {
  const _Placeholder(this.name);

  final String name;

  @override
  Widget build(BuildContext context) => Center(
    child: Text('$name — đang xây', key: ValueKey('placeholder-$name'), style: TextStyle(color: Theme.of(context).textMuted)),
  );
}

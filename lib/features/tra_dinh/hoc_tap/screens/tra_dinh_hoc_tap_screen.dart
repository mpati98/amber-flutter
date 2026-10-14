import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../shared/theme/app_theme.dart';
import 'overview_tab.dart';

const hocTapTabs = ['overview', 'schedule', 'stats'];

/// /tra-dinh: Học tập của Trà Đình, 3 tab Tổng quan | Lịch | Thống kê. Tab lưu ở `?tab=`.
class TraDinhHocTapScreen extends StatefulWidget {
  const TraDinhHocTapScreen({super.key, this.tab});

  final String? tab;

  @override
  State<TraDinhHocTapScreen> createState() => _TraDinhHocTapScreenState();
}

class _TraDinhHocTapScreenState extends State<TraDinhHocTapScreen> with SingleTickerProviderStateMixin {
  late final _controller = TabController(length: hocTapTabs.length, vsync: this, initialIndex: _indexOf(widget.tab));

  static int _indexOf(String? tab) {
    final i = hocTapTabs.indexOf(tab ?? '');
    return i < 0 ? 0 : i;
  }

  @override
  void initState() {
    super.initState();
    _controller.addListener(() {
      if (_controller.indexIsChanging) return;
      final tab = hocTapTabs[_controller.index];
      if (tab != (widget.tab ?? 'overview')) context.go('/tra-dinh?tab=$tab');
    });
  }

  @override
  void didUpdateWidget(TraDinhHocTapScreen old) {
    super.didUpdateWidget(old);
    final i = _indexOf(widget.tab);
    if (i != _controller.index) _controller.animateTo(i);
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

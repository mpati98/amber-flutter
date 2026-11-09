import 'package:flutter/material.dart';

import '../../../shared/widgets/app_bar_back.dart';
import '../../tra_dinh/hoc_tap/screens/stats_tab.dart';

/// /hoc-tap/thong-ke: Thống kê ở Nghị Sự Đường. Thân màn là đúng [StatsTab] của Trà Đình; URL: `?range=7|30|all&subject=<id|all>`.
class HocTapStatsScreen extends StatelessWidget {
  const HocTapStatsScreen({super.key, this.range, this.subject});

  final String? range;
  final String? subject;

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      leading: const AppBarBack(
        fallback: '/hoc-tap/chi-tiet',
        label: 'Chi tiết kế hoạch',
      ),
      leadingWidth: 190,
      title: const Text('Thống kê'),
    ),
    body: StatsTab(
      range: range,
      subject: subject,
      base: '/hoc-tap/thong-ke',
      replaceRoute: true,
    ),
  );
}

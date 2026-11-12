import 'package:material_ui/material_ui.dart';

import '../../../shared/widgets/design_page.dart';
import '../../tra_dinh/hoc_tap/screens/stats_tab.dart';

/// /hoc-tap/thong-ke: Thống kê ở Nghị Sự Đường. Thân màn là đúng [StatsTab] của Trà Đình; URL: `?range=7|30|all&subject=<id|all>`.
class HocTapStatsScreen extends StatelessWidget {
  const HocTapStatsScreen({super.key, this.range, this.subject});

  final String? range;
  final String? subject;

  // Thân màn tự cuộn nên chỉ bọc khung chung (DesignScaffold), không đặt vào DesignPage.
  @override
  Widget build(BuildContext context) => DesignScaffold(
    title: 'Thống kê',
    backFallback: '/hoc-tap/chi-tiet',
    body: StatsTab(
      range: range,
      subject: subject,
      base: '/hoc-tap/thong-ke',
      replaceRoute: true,
    ),
  );
}

import 'package:material_ui/material_ui.dart';

import '../../../shared/widgets/design_page.dart';
import '../../tra_dinh/hoc_tap/screens/schedule_tab.dart';

/// /hoc-tap/lich: Lịch dự kiến ở Nghị Sự Đường. Thân màn là đúng [ScheduleTab] của Trà Đình (cùng provider, cùng chọn môn,
/// cùng nhập lý do ở dòng ngày thiếu); chỉ khác URL: `?view=week|month&date=YYYY-MM-DD`.
class HocTapScheduleScreen extends StatelessWidget {
  const HocTapScheduleScreen({super.key, this.view, this.date});

  final String? view;
  final String? date;

  // Thân màn tự cuộn nên chỉ bọc khung chung (DesignScaffold), không đặt vào DesignPage.
  @override
  Widget build(BuildContext context) => DesignScaffold(
    title: 'Lịch dự kiến',
    backFallback: '/hoc-tap/chi-tiet',
    body: ScheduleTab(
      view: view,
      date: date,
      base: '/hoc-tap/lich',
      replaceRoute: true,
    ),
  );
}

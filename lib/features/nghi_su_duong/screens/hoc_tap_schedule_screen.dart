import 'package:material_ui/material_ui.dart';

import '../../../shared/widgets/app_bar_back.dart';
import '../../tra_dinh/hoc_tap/screens/schedule_tab.dart';

/// /hoc-tap/lich: Lịch dự kiến ở Nghị Sự Đường. Thân màn là đúng [ScheduleTab] của Trà Đình (cùng provider, cùng chọn môn,
/// cùng nhập lý do ở dòng ngày thiếu); chỉ khác URL: `?view=week|month&date=YYYY-MM-DD`.
class HocTapScheduleScreen extends StatelessWidget {
  const HocTapScheduleScreen({super.key, this.view, this.date});

  final String? view;
  final String? date;

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      leading: const AppBarBack(
        fallback: '/hoc-tap/chi-tiet',
        label: 'Chi tiết kế hoạch',
      ),
      leadingWidth: 190,
      title: const Text('Lịch dự kiến'),
    ),
    body: ScheduleTab(
      view: view,
      date: date,
      base: '/hoc-tap/lich',
      replaceRoute: true,
    ),
  );
}

import 'package:material_ui/material_ui.dart';
import 'package:go_router/go_router.dart';

import '../../../shared/widgets/app_bar_back.dart';
import '../../tra_dinh/hoc_tap/widgets/hoc_tap_common.dart';
import '../widgets/plan_widgets.dart';

/// /hoc-tap/chi-tiet: các lối vào phần ít dùng của Học tập. Lịch dự kiến và Thống kê là màn của Nghị Sự Đường (/hoc-tap/lich,
/// /hoc-tap/thong-ke); Muốn mua, Khóa đã xong và Thùng rác là màn Trà Đình hiện có. Không nút vàng.
/// Không có hàng "Lý do thiếu": lý do được nhập ở dòng ngày thiếu trong Lịch dự kiến, Thống kê chỉ tổng hợp lại.
class HocTapPlanDetailScreen extends StatelessWidget {
  const HocTapPlanDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final rows = <(String, String, String)>[
      ('plan-schedule', 'Lịch dự kiến', '/hoc-tap/lich'),
      ('plan-stats', 'Thống kê', '/hoc-tap/thong-ke'),
      ('plan-wishlist', 'Muốn mua', '/tra-dinh/hoc-tap/wishlist'),
      ('plan-done', 'Khóa đã xong', '/tra-dinh/hoc-tap/courses?status=DONE'),
      ('plan-trash', 'Thùng rác', '/tra-dinh/hoc-tap/thung-rac'),
    ];
    return Scaffold(
      appBar: AppBar(
        leading: const AppBarBack(fallback: '/hoc-tap', label: 'Học tập'),
        leadingWidth: 120,
        title: const Text('Chi tiết kế hoạch'),
      ),
      body: HocTapBody(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            for (final (key, label, route) in rows)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: PlanNavRow(
                  key: ValueKey(key),
                  label: label,
                  onTap: () => context.push(route),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

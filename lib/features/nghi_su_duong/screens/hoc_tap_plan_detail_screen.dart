import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../shared/widgets/app_bar_back.dart';
import '../../tra_dinh/hoc_tap/widgets/hoc_tap_common.dart';
import '../widgets/plan_widgets.dart';

/// /hoc-tap/chi-tiet: các lối vào phần phức tạp của Học tập (đều là màn Trà Đình hiện có). Không nút vàng.
/// "Lý do thiếu" chưa có màn riêng: nhập lý do ở dòng ngày thiếu trong tab Lịch (và thẻ Hôm nay), tổng hợp ở khối "Lý do dừng sớm" của Thống kê.
class HocTapPlanDetailScreen extends StatelessWidget {
  const HocTapPlanDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final rows = <(String, String, String)>[
      ('plan-schedule', 'Lịch dự kiến', '/tra-dinh?tab=schedule'),
      ('plan-stats', 'Thống kê', '/tra-dinh?tab=stats'),
      ('plan-reasons', 'Lý do thiếu', '/tra-dinh?tab=schedule'),
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

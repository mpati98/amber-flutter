import 'package:amber_flutter/features/kieu_lau/models/activity_log_entry.dart';
import 'package:amber_flutter/features/kieu_lau/models/alert.dart';
import 'package:amber_flutter/features/kieu_lau/providers/kieu_lau_provider.dart';
import 'package:amber_flutter/features/nghi_su_duong/models/project_summary.dart';
import 'package:amber_flutter/features/nghi_su_duong/screens/du_an_screen.dart';
import 'package:amber_flutter/features/nghi_su_duong/services/ats_tasks_api.dart';
import 'package:amber_flutter/features/nghi_su_duong/services/finance_api.dart';
import 'package:amber_flutter/features/nghi_su_duong/services/nghi_su_duong_api.dart';
import 'package:amber_flutter/features/nghi_su_duong/widgets/ats_tasks_card.dart';
import 'package:amber_flutter/features/nghi_su_duong/widgets/attention_card.dart';
import 'package:amber_flutter/features/nghi_su_duong/widgets/project_card.dart';
import 'package:amber_flutter/features/nghi_su_duong/widgets/routines_card.dart';
import 'package:amber_flutter/shared/providers/auth_provider.dart';
import 'package:amber_flutter/shared/services/api_client.dart';
import 'package:amber_flutter/shared/theme/app_theme.dart';
import 'package:amber_flutter/shared/widgets/design_page.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import 'ats_test_support.dart';
import 'detail_test_support.dart';

// Màn Dự án dạng dashboard trên web rộng (≥ 1024) và đủ cao (≥ 640): vừa đúng một màn, các khung cân xứng.

class _FakeAuth extends AuthController {
  @override
  Future<AuthState> build() async => const Authenticated({'name': 'Test'});
}

ProjectSummary _proj(String id, String name) => ProjectSummary(
  id: id,
  name: name,
  goal: 'Mục tiêu $name',
  status: ProjectStatus.active,
  startDate: null,
  endDate: null,
  krProgress: null,
  taskTotal: 0,
  taskDone: 0,
  taskDoing: 0,
  attentionCount: 0,
  nextMilestone: null,
  finance: const ProjectFinance(income: 0, expense: 0, net: 0),
);

AttentionItem _att(String id) =>
    AttentionItem(taskId: id, title: 'Việc chú ý $id', status: 'IN_PROGRESS', projectId: 'p1', projectName: 'Dự án', kind: 'OVERDUE', days: 2);

/// Dữ liệu vừa: 2 việc hằng ngày, 1 việc chú ý, 4 dự án, 5 việc ATS. [heavy]: nhiều việc ở mọi khối để buộc cuộn trong thẻ.
Future<void> _pump(WidgetTester tester, Size size, {bool heavy = false}) async {
  final api = FakeApi(project: mkProject(), tasks: [])
    ..routines = [for (var i = 0; i < (heavy ? 12 : 2); i++) mkRoutine('r$i', 'Việc hằng ngày $i', streak: i)]
    ..summaryAttention = [for (var i = 0; i < (heavy ? 9 : 1); i++) _att('a$i')]
    ..summaryProjects = [for (var i = 0; i < (heavy ? 14 : 4); i++) _proj('p$i', 'Dự án $i')];
  final ats = FakeAtsTasksApi(
    data: atsData([
      for (var i = 0; i < (heavy ? 30 : 5); i++)
        atsTaskJson('t$i', title: 'Việc ATS $i', status: null, dueDate: '2026-11-${(10 + i % 18).toString()}', project: {'atsId': 'g${i % 3}', 'name': 'Nhóm ${i % 3}', 'type': 'FAIR', 'archived': false}),
    ]),
  );
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  final router = GoRouter(
    initialLocation: '/du-an',
    routes: [GoRoute(path: '/du-an', builder: (_, _) => const DuAnScreen())],
  );
  addTearDown(router.dispose);
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        apiClientProvider.overrideWithValue(offlineDio()),
        nghiSuDuongApiProvider.overrideWithValue(api),
        atsTasksApiProvider.overrideWithValue(ats),
        financeApiProvider.overrideWithValue(FakeFinanceApi()),
        authControllerProvider.overrideWith(_FakeAuth.new),
        notificationsProvider.overrideWith((ref) async => (alerts: const <Alert>[], recentActivity: const <ActivityLogEntry>[])),
      ],
      child: MaterialApp.router(theme: AppTheme.darkTheme, routerConfig: router),
    ),
  );
  await tester.pumpAndSettle();
}

Rect _rect(WidgetTester tester, Finder f) => tester.getRect(f);

/// Các khẳng định chung của dashboard ở cỡ [size].
void _expectDashboard(WidgetTester tester, Size size) {
  expect(tester.takeException(), isNull);
  expect(find.byKey(const ValueKey('du-an-dashboard')), findsOneWidget);
  expect(find.byType(DesignPage), findsNothing, reason: 'không dùng khung cuộn trang của DesignPage');

  // Trang không cuộn: khung nằm gọn trong màn, đáy chừa 88 cho nút chat.
  final dash = _rect(tester, find.byKey(const ValueKey('du-an-dashboard')));
  expect(dash.bottom, closeTo(size.height - 88, 1));

  // Hai thẻ hàng Hôm nay cao bằng nhau, tiêu đề thẳng hàng.
  final routines = _rect(tester, find.byType(RoutinesCard));
  final attention = _rect(tester, find.byType(AttentionCard));
  expect((routines.height - attention.height).abs(), lessThanOrEqualTo(1), reason: 'cao bằng nhau');
  expect((routines.top - attention.top).abs(), lessThanOrEqualTo(1));
  final t1 = tester.getTopLeft(find.text('Việc hằng ngày')).dy;
  final t2 = tester.getTopLeft(find.text('Cần chú ý')).dy;
  expect((t1 - t2).abs(), lessThanOrEqualTo(1), reason: 'tiêu đề thẳng hàng');

  // Hàng Hôm nay tối đa ~35% cột phải.
  final right = _rect(tester, find.byKey(const ValueKey('du-an-right-column')));
  expect(_rect(tester, find.byKey(const ValueKey('du-an-today-row'))).height, lessThanOrEqualTo(right.height * 0.35 + 1));

  // Đỉnh "Tổng quan" = đỉnh "Hôm nay"; đáy "Công việc ATS" = đáy "Dự án".
  final left = _rect(tester, find.byKey(const ValueKey('du-an-left-column')));
  final today = _rect(tester, find.byKey(const ValueKey('du-an-today-frame')));
  final projects = _rect(tester, find.byKey(const ValueKey('du-an-projects-frame')));
  final ats = _rect(tester, find.byType(AtsTasksCard));
  expect((left.top - today.top).abs(), lessThanOrEqualTo(1));
  expect((ats.bottom - projects.bottom).abs(), lessThanOrEqualTo(1), reason: 'đáy hai cột bằng nhau');
  expect(ats.bottom, lessThanOrEqualTo(size.height));
}

void main() {
  for (final size in const [Size(1920, 1000), Size(1366, 768), Size(1257, 690)]) {
    testWidgets('dashboard ${size.width.toInt()}×${size.height.toInt()}: không cuộn trang, khung cân xứng', (tester) async {
      await _pump(tester, size);
      _expectDashboard(tester, size);
      // Không cắt 6 dòng / "Xem thêm" ở dashboard (danh sách cuộn trong thẻ).
      expect(find.byKey(const ValueKey('ats-more')), findsNothing);
      expect(find.byType(ProjectCard), findsWidgets);
    });
  }

  testWidgets('dashboard nhiều dữ liệu (1366×768): mọi khối cuộn BÊN TRONG, đầu thẻ cố định, không tràn', (tester) async {
    const size = Size(1366, 768);
    await _pump(tester, size, heavy: true);
    _expectDashboard(tester, size);

    // Mỗi vùng cuộn trong thẻ thật sự cuộn được (nội dung dài hơn khung).
    for (final key in ['routines-scroll', 'attention-scroll', 'ats-scroll', 'projects-scroll']) {
      final pos = tester.state<ScrollableState>(find.descendant(of: find.byKey(ValueKey(key)), matching: find.byType(Scrollable)).first).position;
      expect(pos.maxScrollExtent, greaterThan(0), reason: '$key phải cuộn được');
    }
    // ATS ở dashboard: hiện đủ dòng (không cắt 6), không có "Xem thêm".
    expect(find.byKey(const ValueKey('ats-more')), findsNothing);

    // Cuộn danh sách ATS: đầu thẻ (nút Đồng bộ ngay) đứng yên.
    final syncBefore = tester.getTopLeft(find.byKey(const ValueKey('ats-sync')));
    await tester.drag(find.byKey(const ValueKey('ats-scroll')), const Offset(0, -300));
    await tester.pumpAndSettle();
    expect(tester.getTopLeft(find.byKey(const ValueKey('ats-sync'))), syncBefore);
    expect(tester.takeException(), isNull);
  });

  testWidgets('web rộng nhưng thấp (1366×600): về bố cục cuộn trang của DesignPage', (tester) async {
    await _pump(tester, const Size(1366, 600));
    expect(find.byKey(const ValueKey('du-an-dashboard')), findsNothing);
    expect(find.byType(DesignPage), findsOneWidget);
    // Vẫn 2 cột như trước: ATS dưới Tổng quan ở cột trái, có giới hạn 6 dòng.
    expect(find.byKey(const ValueKey('du-an-left-column')), findsOneWidget);
    expect(find.byKey(const ValueKey('ats-scroll')), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('điện thoại (390×844): bố cục cũ — DesignPage cuộn trang, thứ tự Tổng quan → Hôm nay → ATS → Dự án', (tester) async {
    await _pump(tester, const Size(390, 844));
    expect(find.byKey(const ValueKey('du-an-dashboard')), findsNothing);
    expect(find.byType(DesignPage), findsOneWidget);
    expect(find.byKey(const ValueKey('routines-scroll')), findsNothing, reason: 'thẻ cao theo nội dung');
    // ListView của DesignPage chỉ có một con (dựng sẵn cả cột) nên đo vị trí được mà không cần cuộn.
    final hom = tester.getTopLeft(find.byType(RoutinesCard)).dy;
    final ats = tester.getTopLeft(find.byType(AtsTasksCard)).dy;
    final duAn = tester.getTopLeft(find.byType(ProjectCard).first).dy;
    expect(hom < ats && ats < duAn, isTrue);
    expect(tester.takeException(), isNull);
  });

  testWidgets('máy tính bảng (800×1000): bố cục cũ, không dashboard', (tester) async {
    await _pump(tester, const Size(800, 1000));
    expect(find.byKey(const ValueKey('du-an-dashboard')), findsNothing);
    expect(find.byType(DesignPage), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}

import 'package:amber_flutter/features/amber_brain/providers/brain_status_provider.dart';
import 'package:amber_flutter/features/kieu_lau/models/activity_log_entry.dart';
import 'package:amber_flutter/features/kieu_lau/models/alert.dart';
import 'package:amber_flutter/features/kieu_lau/providers/kieu_lau_provider.dart';
import 'package:amber_flutter/features/nghi_su_duong/models/finance_category.dart';
import 'package:amber_flutter/features/nghi_su_duong/models/finance_summary.dart';
import 'package:amber_flutter/features/nghi_su_duong/models/finance_transaction.dart';
import 'package:amber_flutter/features/nghi_su_duong/models/overview.dart';
import 'package:amber_flutter/features/nghi_su_duong/models/project.dart';
import 'package:amber_flutter/features/nghi_su_duong/providers/finance_provider.dart';
import 'package:amber_flutter/features/nghi_su_duong/providers/nghi_su_duong_provider.dart';
import 'package:amber_flutter/features/nghi_su_duong/screens/finance_month_screen.dart';
import 'package:amber_flutter/features/nghi_su_duong/screens/nghi_su_duong_screen.dart';
import 'package:amber_flutter/features/nghi_su_duong/screens/project_detail_screen.dart';
import 'package:amber_flutter/features/nghi_su_duong/services/ats_tasks_api.dart';
import 'package:amber_flutter/features/nghi_su_duong/services/finance_api.dart';
import 'package:amber_flutter/features/nghi_su_duong/services/nghi_su_duong_api.dart';
import 'package:amber_flutter/features/tra_dinh/hoc_tap/models/study_overview.dart';
import 'package:amber_flutter/features/tra_dinh/hoc_tap/providers/hoc_tap_provider.dart';
import 'package:amber_flutter/shared/router/app_router.dart' show nsdLegacyRedirect;
import 'package:amber_flutter/shared/services/api_client.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../amber_brain/fake_brain.dart';
import '../tra_dinh/hoc_tap/hoc_tap_test_support.dart';
import 'ats_test_support.dart';
import 'detail_test_support.dart';

// Dựng màn Nghị Sự Đường (một màn) với API / provider giả. Route giống app_router: /du-an, /finance redirect về màn chính,
// chi tiết dự án / tháng là màn thật, /hoc-tap là màn đích giả.

FinanceOverview nsdOverview({num balance = 2500000, String? monthId = 'm11', String monthName = 'Tháng 11/2026'}) => FinanceOverview(
  currentBalance: balance,
  totalIncome: 0,
  totalExpense: 0,
  activeProjectId: monthId,
  activeProjectName: monthId == null ? null : monthName,
);

Project nsdMonth(String id, String name, {String start = '2026-11-01', String end = '2026-11-30', bool archived = false}) => Project(
  id: id,
  name: name,
  type: ProjectType.finance,
  startDate: start,
  endDate: end,
  archivedAt: archived ? DateTime(2026) : null,
);

FinanceSummary nsdSummary(String id, String name, {double income = 0, double expense = 0, List<BudgetProgress> budgets = const []}) =>
    FinanceSummary(
      projectId: id,
      projectName: name,
      startDate: '2026-11-01',
      endDate: '2099-12-31',
      totalBalance: 0,
      totalIncome: income,
      totalExpense: expense,
      netThisMonth: income - expense,
      budgetProgress: budgets,
    );

/// Tháng hiện tại theo lịch VN của máy chạy test có trong danh sách → không hiện "Bắt đầu tháng mới".
List<Project> nsdCurrentMonths() {
  final now = DateTime.now().toUtc().add(const Duration(hours: 7));
  final m = now.month.toString().padLeft(2, '0');
  return [nsdMonth('m11', 'Tháng 11/2026', start: '${now.year}-$m-01')];
}

class NsdHarness {
  NsdHarness(this.api, this.finance, this.ats, this.router);

  final NghiSuDuongApi api;
  final FakeFinanceApi finance;
  final FakeAtsTasksApi ats;
  final GoRouter router;
}

Future<NsdHarness> pumpNsd(
  WidgetTester tester, {
  NghiSuDuongApi? api,
  FakeFinanceApi? finance,
  FakeAtsTasksApi? ats,
  FinanceOverview? overview,
  List<Project>? months,
  Map<String, FinanceSummary>? summaries,
  StudyOverview? study,
  Object? studyError,
  List<Alert> alerts = const [],
  Size size = const Size(1280, 720),
  String location = '/nghi-su-duong',
  List<Override> extra = const [],
}) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  final nsd = api ?? FakeApi(project: mkProject(), tasks: []);
  final fin = finance ?? FakeFinanceApi();
  final atsApi = ats ?? FakeAtsTasksApi();
  final monthList = months ?? nsdCurrentMonths();
  final sums = summaries ?? {for (final m in monthList) m.id: nsdSummary(m.id, m.name)};
  final router = GoRouter(
    initialLocation: location,
    routes: [
      GoRoute(path: '/', builder: (_, _) => const Scaffold(body: Text('HOME'))),
      GoRoute(path: '/nghi-su-duong', builder: (_, _) => const NghiSuDuongScreen()),
      GoRoute(path: '/du-an', redirect: nsdLegacyRedirect),
      GoRoute(
        path: '/du-an/:projectId',
        builder: (_, s) => ProjectDetailScreen(projectId: s.pathParameters['projectId']!, initialTaskId: s.uri.queryParameters['task']),
      ),
      GoRoute(path: '/finance', redirect: nsdLegacyRedirect),
      GoRoute(path: '/finance/:projectId', builder: (_, s) => FinanceMonthScreen(projectId: s.pathParameters['projectId']!)),
      GoRoute(path: '/hoc-tap', builder: (_, _) => const Scaffold(body: Text('ĐÍCH /hoc-tap'))),
    ],
  );
  addTearDown(router.dispose);
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        apiClientProvider.overrideWithValue(offlineDio()),
        brainStatusProvider.overrideWith(() => FixedBrainStatus()),
        nghiSuDuongApiProvider.overrideWithValue(nsd),
        financeApiProvider.overrideWithValue(fin),
        atsTasksApiProvider.overrideWithValue(atsApi),
        financeOverviewProvider.overrideWith((ref) async => overview ?? nsdOverview()),
        financeProjectsProvider.overrideWith((ref) async => monthList),
        financeSummaryProvider.overrideWith((ref, id) async => sums[id] ?? nsdSummary(id, id)),
        financeTransactionsProvider.overrideWith((ref, id) async => fin.transactions.where((t) => t.projectId == id).toList()),
        studyOverviewProvider.overrideWith((ref) async {
          if (studyError != null) throw studyError;
          return study ?? StudyOverview.fromJson(fixtureMap('overview'));
        }),
        notificationsProvider.overrideWith((ref) async => (alerts: alerts, recentActivity: const <ActivityLogEntry>[])),
        ...extra,
      ],
      child: MaterialApp.router(theme: ThemeData.dark(), routerConfig: router),
    ),
  );
  await tester.pumpAndSettle();
  return NsdHarness(nsd, fin, atsApi, router);
}

/// Mọi Scrollable DỌC phải nằm trong một ZoneFrame (khung thường hoặc modal mở rộng) — trang không cuộn.
void expectNoPageScroll(WidgetTester tester) {
  final frames = find.byWidgetPredicate((w) => w.key is ValueKey<String> && (w.key! as ValueKey<String>).value.startsWith('zone-frame-'));
  var vertical = 0;
  for (final e in find.byType(Scrollable).evaluate()) {
    final s = e.widget as Scrollable;
    if (axisDirectionToAxis(s.axisDirection) != Axis.vertical) continue;
    vertical++;
    expect(find.ancestor(of: find.byWidget(s), matching: frames), findsWidgets, reason: 'Scrollable dọc ngoài ZoneFrame');
  }
  expect(vertical, greaterThan(0));
}

Finder nsdFrame(String title) => find.byKey(ValueKey('zone-frame-$title'));

Future<void> nsdTab(WidgetTester tester, String id) async {
  await tester.ensureVisible(find.byKey(ValueKey('zone-tab-$id')));
  await tester.pumpAndSettle();
  await tester.tap(find.byKey(ValueKey('zone-tab-$id')));
  await tester.pumpAndSettle();
}

/// Giao dịch thuộc tháng tài chính [monthId].
FinanceTransaction nsdTx(String id, String monthId, {double amount = 50000, MoneyKind kind = MoneyKind.expense, String? note}) =>
    FinanceTransaction(
      id: id,
      projectId: monthId,
      accountId: 'w1',
      kind: kind,
      amount: amount,
      note: note,
      occurredAt: DateTime.utc(2026, 11, 10, 3),
      categoryName: note ?? 'Ăn uống',
      accountName: 'Ví',
    );

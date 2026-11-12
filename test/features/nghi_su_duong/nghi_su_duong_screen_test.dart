import 'package:amber_flutter/features/amber_brain/providers/brain_status_provider.dart';
import 'package:amber_flutter/features/nghi_su_duong/models/finance_summary.dart';
import 'package:amber_flutter/features/nghi_su_duong/models/overview.dart';
import 'package:amber_flutter/features/nghi_su_duong/providers/finance_provider.dart';
import 'package:amber_flutter/features/nghi_su_duong/providers/nghi_su_duong_provider.dart';
import 'package:amber_flutter/features/nghi_su_duong/screens/nghi_su_duong_screen.dart';
import 'package:amber_flutter/features/tra_dinh/hoc_tap/models/study_overview.dart';
import 'package:amber_flutter/features/tra_dinh/hoc_tap/providers/hoc_tap_provider.dart';
import 'package:amber_flutter/shared/theme/design_tokens.dart';
import 'package:amber_flutter/shared/widgets/list_frame.dart';
import 'package:amber_flutter/shared/widgets/overview_block.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import '../amber_brain/fake_brain.dart';
import '../tra_dinh/hoc_tap/hoc_tap_test_support.dart';

FinanceOverview _finance({num balance = -1165565, String? month = 'thang-11'}) => FinanceOverview(
  currentBalance: balance,
  totalIncome: 0,
  totalExpense: 0,
  activeProjectId: month,
  activeProjectName: month == null ? null : 'Tháng 11/2026',
);

FinanceSummary _month() => FinanceSummary(
  projectId: 'thang-11',
  projectName: 'Tháng 11/2026',
  startDate: '2026-11-01',
  endDate: '2026-11-30',
  totalBalance: 0,
  totalIncome: 10,
  totalExpense: 4384567,
  netThisMonth: 0,
  budgetProgress: const [],
);

DuAnOverview _projects(List<int> progress) => DuAnOverview(
  year: 2026,
  activeProjects: [
    for (final (i, p) in progress.indexed)
      ActiveProject(id: 'p$i', name: i == 0 ? 'Test' : 'Dự án $i', totalTasks: 10, doneTasks: p ~/ 10, progressPct: p),
  ],
  completedThisYear: 1,
  upcomingProjects: const [],
);

Future<void> _pump(
  WidgetTester tester, {
  FinanceOverview? finance,
  DuAnOverview? projects,
  Size size = const Size(390, 1200),
}) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  final router = GoRouter(
    initialLocation: '/nghi-su-duong',
    routes: [
      GoRoute(path: '/', builder: (_, _) => const Scaffold(body: Text('HOME'))),
      GoRoute(path: '/nghi-su-duong', builder: (_, _) => const NghiSuDuongScreen()),
      for (final p in ['/du-an', '/finance', '/hoc-tap'])
        GoRoute(path: p, builder: (_, _) => Scaffold(body: Text('ĐÍCH $p'))),
    ],
  );
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        brainStatusProvider.overrideWith(() => FixedBrainStatus()),
        duAnOverviewProvider.overrideWith((ref) async => projects ?? _projects([0])),
        financeOverviewProvider.overrideWith((ref) async => finance ?? _finance()),
        financeSummaryProvider.overrideWith((ref, id) async => _month()),
        studyOverviewProvider.overrideWith((ref) async => StudyOverview.fromJson(fixtureMap('overview'))),
      ],
      child: MaterialApp.router(theme: ThemeData.dark(), routerConfig: router),
    ),
  );
  await tester.pumpAndSettle();
}

Finder _in(String key, String text) => find.descendant(of: find.byKey(ValueKey(key)), matching: find.text(text));

void main() {
  testWidgets('bố cục: ← + tên → Tổng quan 3 dòng → khung 3 mục → gợi ý', (tester) async {
    await _pump(tester);
    expect(find.text('Nghị Sự Đường'), findsOneWidget);
    expect(find.byKey(const ValueKey('design-top-bar-back')), findsOneWidget);
    expect(find.text('TỔNG QUAN'), findsOneWidget);
    expect(find.byType(OverviewRow), findsNWidgets(3));
    for (final k in ['nsd-du-an', 'nsd-finance', 'nsd-hoc-tap']) {
      expect(find.descendant(of: find.byType(ListFrame), matching: find.byKey(ValueKey(k))), findsOneWidget, reason: k);
    }
    expect(find.text('Chạm vào một mục để vào'), findsOneWidget);
    expect(find.text('1 đang chạy · 1 xong năm nay'), findsOneWidget);
  });

  testWidgets('số dư âm: số đỏ cỡ lớn, nhãn "Âm quỹ", viền đỏ sẫm, Thu / Chi của tháng; tổng quan có tên tháng', (tester) async {
    await _pump(tester);
    final balance = tester.widget<Text>(find.byKey(const ValueKey('nsd-balance')));
    expect(balance.data, '-1.165.565₫');
    expect(balance.style?.color, DesignColors.danger);
    expect(balance.style?.fontSize, 20);
    expect(_in('nsd-finance', 'Âm quỹ'), findsOneWidget);
    expect(_in('nsd-finance', 'Thu 10₫ · Chi 4.384.567₫'), findsOneWidget);
    final tile = tester.widget<FrameTile>(find.descendant(of: find.byKey(const ValueKey('nsd-finance')), matching: find.byType(FrameTile)));
    expect(tile.borderColor, const Color(0xFF7A2F2F));
    expect(find.textContaining('Tháng 11/2026'), findsOneWidget);
  });

  testWidgets('số dư dương: không đỏ, không "Âm quỹ", viền thường', (tester) async {
    await _pump(tester, finance: _finance(balance: 2500000));
    expect(tester.widget<Text>(find.byKey(const ValueKey('nsd-balance'))).style?.color, DesignColors.text);
    expect(find.text('Âm quỹ'), findsNothing);
    final tile = tester.widget<FrameTile>(find.descendant(of: find.byKey(const ValueKey('nsd-finance')), matching: find.byType(FrameTile)));
    expect(tile.borderColor, isNull);
  });

  testWidgets('chưa mở tháng tài chính → báo trong mục Tài chính', (tester) async {
    await _pump(tester, finance: _finance(month: null, balance: 0));
    expect(_in('nsd-finance', 'Chưa mở tháng tài chính này.'), findsOneWidget);
  });

  testWidgets('dự án: 1 dự án → "tên · %"; nhiều → "N dự án · trung bình %"; rỗng → câu báo, không có thanh', (tester) async {
    await _pump(tester);
    expect(_in('nsd-du-an', 'Test · 0%'), findsOneWidget);
    expect(find.descendant(of: find.byKey(const ValueKey('nsd-du-an')), matching: find.byType(DesignProgressBar)), findsOneWidget);

    await tester.pumpWidget(const SizedBox());
    await _pump(tester, projects: _projects([20, 60]));
    expect(_in('nsd-du-an', '2 dự án · trung bình 40%'), findsOneWidget);

    await tester.pumpWidget(const SizedBox());
    await _pump(tester, projects: _projects(const []));
    expect(_in('nsd-du-an', 'Chưa có dự án nào đang triển khai.'), findsOneWidget);
    expect(find.byType(DesignProgressBar), findsNothing);
  });

  for (final (key, path) in [('nsd-du-an', '/du-an'), ('nsd-finance', '/finance'), ('nsd-hoc-tap', '/hoc-tap')]) {
    testWidgets('bấm $key → $path', (tester) async {
      await _pump(tester);
      await tester.tap(find.byKey(ValueKey(key)));
      await tester.pumpAndSettle();
      expect(find.text('ĐÍCH $path'), findsOneWidget);
    });
  }

  testWidgets('← về Home khi mở thẳng', (tester) async {
    await _pump(tester);
    await tester.tap(find.byKey(const ValueKey('design-top-bar-back')));
    await tester.pumpAndSettle();
    expect(find.text('HOME'), findsOneWidget);
  });

  testWidgets('web rộng: tổng quan bên trái, khung bên phải', (tester) async {
    await _pump(tester, size: const Size(1440, 900));
    final overview = tester.getRect(find.byType(OverviewBlock));
    final frame = tester.getRect(find.byType(ListFrame));
    expect(overview.width, 380);
    expect(frame.left, greaterThan(overview.right));
    expect(frame.top, overview.top);
  });

  testWidgets('320 px, chữ ×2,0: không tràn', (tester) async {
    tester.platformDispatcher.textScaleFactorTestValue = 2.0;
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
    await _pump(tester, size: const Size(320, 1600));
    expect(tester.takeException(), isNull);
  });
}

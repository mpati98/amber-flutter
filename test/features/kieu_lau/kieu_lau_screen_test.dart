import 'package:amber_flutter/features/amber_brain/providers/brain_status_provider.dart';
import 'package:amber_flutter/features/kieu_lau/models/activity_log_entry.dart';
import 'package:amber_flutter/features/kieu_lau/models/alert.dart';
import 'package:amber_flutter/features/kieu_lau/models/feed_article.dart';
import 'package:amber_flutter/features/kieu_lau/models/feed_source.dart';
import 'package:amber_flutter/features/kieu_lau/providers/kieu_lau_provider.dart';
import 'package:amber_flutter/features/kieu_lau/screens/kieu_lau_screen.dart';
import 'package:amber_flutter/features/kieu_lau/services/kieu_lau_api.dart';
import 'package:amber_flutter/features/kieu_lau/utils/activity_groups.dart';
import 'package:amber_flutter/shared/theme/design_tokens.dart';
import 'package:amber_flutter/shared/widgets/list_frame.dart';
import 'package:dio/dio.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import '../amber_brain/fake_brain.dart';

/// 11/11/2026 theo giờ VN (UTC+7) ở [hour] giờ.
DateTime _vn(int day, [int hour = 12]) => DateTime.utc(2026, 11, day, hour - 7);

ActivityLogEntry _e(String source, String action, String title, DateTime at) =>
    ActivityLogEntry(id: '$title$at', source: source, action: action, title: title, createdAt: at);

/// Dữ liệu giống bản mẫu: 4 giao dịch cùng ngày, mở tháng, 4 lần học cùng khóa, 1 buổi ôn thẻ.
final _activity = [
  _e('FINANCE', 'finance.transaction_created', 'ăn sáng', _vn(11, 8)),
  _e('FINANCE', 'finance.transaction_created', 'cafe', _vn(11, 10)),
  _e('FINANCE', 'finance.transaction_created', 'ăn trưa', _vn(11, 12)),
  _e('FINANCE', 'finance.transaction_created', 'ăn tối', _vn(11, 19)),
  _e('FINANCE', 'finance.month_started', 'Tài chính — Tháng 11/2026', _vn(11, 7)),
  for (var h = 8; h < 12; h++) _e('TRA_DINH', 'study_log.created', 'PostgreSQL DBA – Part 1', _vn(9, h)),
  _e('TRA_DINH', 'study_card.imported', 'Nhập 15 thẻ từ vựng', _vn(7)),
  _e('DU_AN', 'task.created', 'Viết báo cáo', _vn(6)),
];

class _FakeApi extends KieuLauApi {
  _FakeApi() : super(Dio());

  int refreshes = 0;
  final deleted = <String>[];
  FeedRefreshResult result = (refreshed: 2, failed: const <String>[]);

  @override
  Future<FeedRefreshResult> refreshFeeds() async {
    refreshes++;
    return result;
  }

  @override
  Future<void> deleteFeedSource(String id) async => deleted.add(id);
}

Future<_FakeApi> _pump(
  WidgetTester tester, {
  List<Alert> alerts = const [],
  List<ActivityLogEntry>? activity,
  List<FeedSource> sources = const [],
  List<FeedArticle> articles = const [],
  Size size = const Size(390, 1400),
}) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  final api = _FakeApi();
  final router = GoRouter(
    initialLocation: '/kieu-lau',
    routes: [
      GoRoute(
        path: '/kieu-lau',
        builder: (_, _) => const KieuLauScreen(),
        routes: [GoRoute(path: 'nhac', builder: (_, _) => const Scaffold(body: Text('ĐÍCH nhạc')))],
      ),
      for (final p in ['/finance', '/tra-dinh', '/du-an', '/tang-kinh-cac/du-lieu-huan-luyen'])
        GoRoute(path: p, builder: (_, _) => Scaffold(body: Text('ĐÍCH $p'))),
    ],
  );
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        brainStatusProvider.overrideWith(() => FixedBrainStatus()),
        kieuLauApiProvider.overrideWithValue(api),
        notificationsProvider.overrideWith((ref) async => (alerts: alerts, recentActivity: activity ?? _activity)),
        feedSourcesProvider.overrideWith((ref) async => sources),
        feedArticlesProvider.overrideWith((ref) async => articles),
      ],
      child: MaterialApp.router(theme: ThemeData.dark(), routerConfig: router),
    ),
  );
  await tester.pumpAndSettle();
  return api;
}

List<String> _rowTitles(WidgetTester tester) => [
  for (final r in tester.widgetList<FrameRow>(find.byType(FrameRow))) r.title,
];

/// Hàng chip cuộn ngang: font của flutter_test rộng hơn font thật nên chip cuối có thể nằm ngoài khung nhìn → cuộn tới trước.
Future<void> _chip(WidgetTester tester, String label) async {
  await tester.ensureVisible(find.byKey(ValueKey('chip-$label')));
  await tester.pumpAndSettle();
  await tester.tap(find.byKey(ValueKey('chip-$label')));
  await tester.pumpAndSettle();
}

void main() {
  group('groupActivity', () {
    test('cùng nguồn + action + ngày VN gộp; tên khác → liệt kê + "N mục"; tên trùng → ×N; mới trước', () {
      final g = groupActivity(_activity);
      expect(g.map((x) => x.title), [
        'ăn tối, ăn trưa, cafe, ăn sáng',
        'Tài chính — Tháng 11/2026',
        'PostgreSQL DBA – Part 1',
        'Nhập 15 thẻ từ vựng',
        'Viết báo cáo',
      ]);
      expect(g[0].subtitle, '4 mục · 11/11');
      expect(g[0].repeat, isNull);
      expect(g[1].subtitle, '11/11');
      expect(g[2].repeat, 4);
      expect(g[2].shortDate, '9/11');
      expect(g[3].repeat, isNull);
    });

    test('ranh giới ngày theo giờ VN: 23:30 và 00:30 hôm sau là hai dòng', () {
      final g = groupActivity([
        _e('FINANCE', 'finance.transaction_created', 'a', _vn(10, 23).add(const Duration(minutes: 30))),
        _e('FINANCE', 'finance.transaction_created', 'b', _vn(11, 0).add(const Duration(minutes: 30))),
      ]);
      expect(g.map((x) => x.day), ['2026-11-11', '2026-11-10']);
    });

    test('tên trùng lẫn tên khác: bỏ trùng trong danh sách nhưng vẫn đếm đủ số mục', () {
      final g = groupActivity([
        _e('FINANCE', 'finance.transaction_created', 'cafe', _vn(11, 8)),
        _e('FINANCE', 'finance.transaction_created', 'cafe', _vn(11, 9)),
        _e('FINANCE', 'finance.transaction_created', 'ăn trưa', _vn(11, 12)),
      ]).single;
      expect(g.title, 'ăn trưa, cafe');
      expect(g.subtitle, '3 mục · 11/11');
    });
  });

  testWidgets('tổng quan: Nhạc (bấm mở thư viện) + Cần chú ý xanh khi không có cảnh báo', (tester) async {
    await _pump(tester);
    expect(find.text('Kiều Lâu'), findsOneWidget);
    final ok = tester.widget<Text>(find.text('Không có gì cần chú ý. Mọi thứ ổn.'));
    expect(ok.style?.color, DesignColors.success);
    await tester.tap(find.byKey(const ValueKey('kl-music')));
    await tester.pumpAndSettle();
    expect(find.text('ĐÍCH nhạc'), findsOneWidget);
  });

  testWidgets('có cảnh báo: mỗi cảnh báo một dòng đỏ, bấm mở href', (tester) async {
    await _pump(
      tester,
      alerts: const [Alert(id: 'task:1', kind: 'TASK_DUE', title: 'Trễ hạn: Viết báo cáo', detail: '2 ngày', href: '/du-an')],
    );
    expect(find.text('Không có gì cần chú ý. Mọi thứ ổn.'), findsNothing);
    await tester.tap(find.byKey(const ValueKey('kl-alert-task:1')));
    await tester.pumpAndSettle();
    expect(find.text('ĐÍCH /du-an'), findsOneWidget);
  });

  testWidgets('khung: 4 chip, "Tất cả" sẵn; nhật ký đã gộp, nhãn ×4 xanh lam', (tester) async {
    await _pump(tester);
    for (final c in ['Tất cả', 'Tài chính', 'Học tập', 'Tin tức']) {
      expect(find.byKey(ValueKey('chip-$c')), findsOneWidget);
    }
    expect(_rowTitles(tester), [
      'ăn tối, ăn trưa, cafe, ăn sáng',
      'Tài chính — Tháng 11/2026',
      'PostgreSQL DBA – Part 1',
      'Nhập 15 thẻ từ vựng',
      'Viết báo cáo',
    ]);
    expect(find.text('4 mục · 11/11'), findsOneWidget);
    final pill = tester.widget<DesignPill>(find.byType(DesignPill));
    expect((pill.text, pill.color), ('×4', DesignColors.info));
    expect(find.text('Chạm vào một mục để xem chi tiết'), findsOneWidget);
  });

  testWidgets('chip lọc: Tài chính chỉ FINANCE; Học tập chỉ học; quay lại Tất cả', (tester) async {
    await _pump(tester);
    await _chip(tester, 'Tài chính');
    expect(_rowTitles(tester), ['ăn tối, ăn trưa, cafe, ăn sáng', 'Tài chính — Tháng 11/2026']);
    await _chip(tester, 'Học tập');
    expect(_rowTitles(tester), ['PostgreSQL DBA – Part 1', 'Nhập 15 thẻ từ vựng']);
    await _chip(tester, 'Tất cả');
    expect(_rowTitles(tester), hasLength(5));
  });

  for (final (i, path) in [(0, '/finance'), (2, '/tra-dinh'), (4, '/du-an')]) {
    testWidgets('bấm dòng nhật ký $i → $path', (tester) async {
      await _pump(tester);
      await tester.tap(find.byKey(ValueKey('kl-activity-$i')));
      await tester.pumpAndSettle();
      expect(find.text('ĐÍCH $path'), findsOneWidget);
    });
  }

  testWidgets('chưa có hoạt động / lọc ra rỗng → câu báo', (tester) async {
    await _pump(tester, activity: const []);
    expect(find.text('Chưa có hoạt động nào.'), findsOneWidget);

    await tester.pumpWidget(const SizedBox());
    await _pump(tester, activity: [_e('DU_AN', 'task.created', 'x', _vn(11))]);
    await _chip(tester, 'Tài chính');
    expect(find.text('Không có mục nào.'), findsOneWidget);
  });

  group('chip Tin tức', () {
    final sources = [FeedSource(id: 's1', name: 'VnExpress', url: 'https://x', createdAt: DateTime(2026))];
    final articles = [
      FeedArticle(id: 'a1', title: 'Tin một', url: 'https://x/1', sourceName: 'VnExpress', publishedAt: DateTime(2026, 11, 10)),
    ];

    testWidgets('hiện nguồn, "+ Nguồn", Làm mới và bài báo; nhật ký ẩn', (tester) async {
      await _pump(tester, sources: sources, articles: articles);
      await _chip(tester, 'Tin tức');
      expect(find.byKey(const ValueKey('kl-source-s1')), findsOneWidget);
      expect(find.byKey(const ValueKey('kl-add-source')), findsOneWidget);
      expect(find.byKey(const ValueKey('kl-article-a1')), findsOneWidget);
      expect(find.text('VnExpress · 10/11/2026'), findsOneWidget);
      expect(_rowTitles(tester), ['Tin một']);
    });

    testWidgets('Làm mới → gọi API, toast thành công; nguồn lỗi → toast cảnh báo', (tester) async {
      final api = await _pump(tester, sources: sources, articles: articles);
      await _chip(tester, 'Tin tức');
      await tester.tap(find.byKey(const ValueKey('kl-refresh')));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 750));
      expect(api.refreshes, 1);
      expect(find.byKey(const ValueKey('toast-success')), findsOneWidget);

      api.result = (refreshed: 1, failed: const ['Báo X']);
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const ValueKey('kl-refresh')));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 750));
      expect(find.text('Không làm mới được: Báo X'), findsOneWidget);
      expect(find.byKey(const ValueKey('toast-warning')), findsOneWidget);
    });

    testWidgets('chưa có nguồn → Làm mới tắt, câu hướng dẫn', (tester) async {
      await _pump(tester);
      await _chip(tester, 'Tin tức');
      expect(tester.widget<OutlinedButton>(find.descendant(of: find.byKey(const ValueKey('kl-refresh')), matching: find.byType(OutlinedButton))).onPressed, isNull);
      expect(find.text('Chưa có tin nào — thêm nguồn rồi bấm "Làm mới".'), findsOneWidget);
    });

    testWidgets('xoá nguồn → gọi API với đúng id', (tester) async {
      final api = await _pump(tester, sources: sources);
      await _chip(tester, 'Tin tức');
      await tester.tap(find.byTooltip('Xoá nguồn VnExpress'));
      await tester.pumpAndSettle();
      expect(api.deleted, ['s1']);
    });
  });

  testWidgets('320 px, chữ ×2,0: không tràn (cả khi mở Tin tức)', (tester) async {
    tester.platformDispatcher.textScaleFactorTestValue = 2.0;
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
    await _pump(
      tester,
      size: const Size(320, 2400),
      alerts: const [Alert(id: 'b', kind: 'BUDGET_EXCEEDED', title: 'Vượt ngân sách ăn uống', href: '/finance')],
    );
    expect(tester.takeException(), isNull);
    await _chip(tester, 'Tin tức');
    expect(tester.takeException(), isNull);
  });
}

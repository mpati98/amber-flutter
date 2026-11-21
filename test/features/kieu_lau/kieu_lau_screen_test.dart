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
import 'package:flutter/services.dart' show LogicalKeyboardKey;
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
  Size size = const Size(1280, 720),
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
      for (final p in ['/nghi-su-duong', '/du-an', '/tra-dinh', '/tang-kinh-cac/du-lieu-huan-luyen'])
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

Future<void> _tab(WidgetTester tester, String id) async {
  await tester.ensureVisible(find.byKey(ValueKey('zone-tab-$id')));
  await tester.pumpAndSettle();
  await tester.tap(find.byKey(ValueKey('zone-tab-$id')));
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
    expect(find.byKey(const ValueKey('kl-hint')), findsOneWidget);
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

  // Tài chính / Dự án mở thẳng màn Nghị Sự Đường (một màn) — /finance, /du-an cũ chỉ còn là redirect.
  for (final (i, path) in [(0, '/nghi-su-duong'), (2, '/tra-dinh'), (4, '/nghi-su-duong')]) {
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

  testWidgets('320 px, chữ ×2,0: không tràn ở cả 3 tab (cả khi mở Tin tức)', (tester) async {
    tester.platformDispatcher.textScaleFactorTestValue = 2.0;
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
    await _pump(
      tester,
      size: const Size(320, 640),
      alerts: const [Alert(id: 'b', kind: 'BUDGET_EXCEEDED', title: 'Vượt ngân sách ăn uống', href: '/finance')],
    );
    expect(tester.takeException(), isNull);
    for (final tab in ['alerts', 'activity']) {
      await _tab(tester, tab);
      expect(tester.takeException(), isNull);
    }
    await _chip(tester, 'Tin tức');
    expect(tester.takeException(), isNull);
  });

  group('bố cục vừa một màn', () {
    /// Mọi Scrollable dọc phải nằm trong một ZoneFrame (khung thường hoặc modal mở rộng) — trang không cuộn.
    void expectNoPageScroll(WidgetTester tester) {
      final frames = find.byWidgetPredicate((w) => w.key is ValueKey<String> && (w.key as ValueKey<String>).value.startsWith('zone-frame-'));
      var vertical = 0;
      for (final e in find.byType(Scrollable).evaluate()) {
        final s = e.widget as Scrollable;
        if (axisDirectionToAxis(s.axisDirection) != Axis.vertical) continue;
        vertical++;
        expect(find.ancestor(of: find.byWidget(s), matching: frames), findsWidgets, reason: 'Scrollable dọc ngoài ZoneFrame');
      }
      expect(vertical, greaterThan(0), reason: 'phép kiểm phải gặp ít nhất vùng cuộn của các khung');
    }

    for (final size in const [Size(1920, 1080), Size(1280, 720)]) {
      testWidgets('${size.width.toInt()}×${size.height.toInt()}: 3 khung cùng lúc, không tràn, không cuộn trang', (tester) async {
        await _pump(
          tester,
          size: size,
          alerts: [for (var i = 0; i < 30; i++) Alert(id: 'a$i', kind: 'TASK_DUE', title: 'Trễ hạn $i', href: '/du-an')],
          activity: [for (var i = 0; i < 40; i++) _e('DU_AN', 'task.created', 'Việc $i', _vn(11).subtract(Duration(days: i)))],
        );
        expect(tester.takeException(), isNull);
        for (final t in ['Tổng quan', 'Cần chú ý', 'Hoạt động']) {
          expect(find.byKey(ValueKey('zone-frame-$t')), findsOneWidget);
        }
        expect(find.byKey(const ValueKey('zone-tab-overview')), findsNothing);
        expectNoPageScroll(tester);

        // Cột trái : cột phải = 1 : 2; khung không vượt màn; Tổng quan cao vừa nội dung, Cần chú ý lấp phần còn lại.
        final overview = tester.getRect(find.byKey(const ValueKey('zone-frame-Tổng quan')));
        final alerts = tester.getRect(find.byKey(const ValueKey('zone-frame-Cần chú ý')));
        final activity = tester.getRect(find.byKey(const ValueKey('zone-frame-Hoạt động')));
        expect(activity.width / overview.width, closeTo(2, 0.05));
        expect(overview.left, 16);
        expect(activity.right, size.width - 16);
        expect(overview.height, lessThan(alerts.height));
        expect(alerts.bottom, activity.bottom);
        expect(activity.bottom, lessThanOrEqualTo(size.height - 16));
      });
    }

    testWidgets('800×1000 (600–1023): 2 cột, Tổng quan + Cần chú ý chia đều bên trái, Hoạt động bên phải', (tester) async {
      await _pump(tester, size: const Size(800, 1000));
      expect(tester.takeException(), isNull);
      expectNoPageScroll(tester);
      final overview = tester.getRect(find.byKey(const ValueKey('zone-frame-Tổng quan')));
      final alerts = tester.getRect(find.byKey(const ValueKey('zone-frame-Cần chú ý')));
      final activity = tester.getRect(find.byKey(const ValueKey('zone-frame-Hoạt động')));
      expect(overview.height, closeTo(alerts.height, 0.5));
      expect(overview.width, closeTo(activity.width, 0.5));
      expect(activity.bottom, alerts.bottom);
    });

    testWidgets('390×844: 3 tab, tab đang chọn lấp chiều cao; không tràn, không cuộn trang', (tester) async {
      await _pump(tester, size: const Size(390, 844));
      expect(tester.takeException(), isNull);
      expect(find.byKey(const ValueKey('zone-frame-Tổng quan')), findsOneWidget);
      expect(find.byKey(const ValueKey('zone-frame-Hoạt động')), findsNothing);
      expectNoPageScroll(tester);

      await _tab(tester, 'alerts');
      expect(find.text('Không có gì cần chú ý. Mọi thứ ổn.'), findsOneWidget);
      await _tab(tester, 'activity');
      expect(_rowTitles(tester), hasLength(5));
      final frame = tester.getRect(find.byKey(const ValueKey('zone-frame-Hoạt động')));
      expect(frame.bottom, closeTo(844 - 16, 0.5));
      expect(tester.takeException(), isNull);
      expectNoPageScroll(tester);
    });

    testWidgets('mở rộng Hoạt động: modal toàn màn, chip đồng bộ với khung; đóng bằng nút và bằng Esc', (tester) async {
      await _pump(tester, size: const Size(1280, 720));
      await tester.tap(find.byKey(const ValueKey('zone-expand-Hoạt động')));
      await tester.pumpAndSettle();
      final modal = find.byKey(const ValueKey('zone-expanded-Hoạt động'));
      expect(modal, findsOneWidget);
      expect(tester.getSize(modal), const Size(1280, 720));
      expect(tester.takeException(), isNull);
      expectNoPageScroll(tester);

      // Lọc trong modal → khung gốc cũng đổi theo.
      await tester.tap(find.descendant(of: modal, matching: find.byKey(const ValueKey('chip-Tài chính'))));
      await tester.pumpAndSettle();
      expect(find.descendant(of: modal, matching: find.byType(FrameRow)), findsNWidgets(2));

      await tester.tap(find.byKey(const ValueKey('zone-expanded-close')));
      await tester.pumpAndSettle();
      expect(modal, findsNothing);
      expect(_rowTitles(tester), ['ăn tối, ăn trưa, cafe, ăn sáng', 'Tài chính — Tháng 11/2026']);

      await tester.tap(find.byKey(const ValueKey('zone-expand-Hoạt động')));
      await tester.pumpAndSettle();
      expect(modal, findsOneWidget);
      await tester.sendKeyEvent(LogicalKeyboardKey.escape);
      await tester.pumpAndSettle();
      expect(modal, findsNothing);
    });
  });
}

import 'package:amber_flutter/features/amber_brain/models/brain_models.dart';
import 'package:amber_flutter/features/amber_brain/providers/brain_status_provider.dart';
import 'package:amber_flutter/features/amber_brain/widgets/amber_chat_dock.dart';
import 'package:amber_flutter/features/du_do/screens/du_do_screen.dart';
import 'package:amber_flutter/features/du_do/widgets/today_rows.dart';
import 'package:amber_flutter/features/kieu_lau/models/activity_log_entry.dart';
import 'package:amber_flutter/features/kieu_lau/models/alert.dart';
import 'package:amber_flutter/features/kieu_lau/providers/kieu_lau_provider.dart';
import 'package:amber_flutter/features/kieu_lau/services/kieu_lau_api.dart';
import 'package:amber_flutter/features/nghi_su_duong/models/finance_summary.dart';
import 'package:amber_flutter/features/nghi_su_duong/models/overview.dart';
import 'package:amber_flutter/features/nghi_su_duong/providers/finance_provider.dart';
import 'package:amber_flutter/features/nghi_su_duong/providers/nghi_su_duong_provider.dart';
import 'package:amber_flutter/features/tra_dinh/hoc_tap/models/study_overview.dart';
import 'package:amber_flutter/features/tra_dinh/hoc_tap/providers/hoc_tap_provider.dart';
import 'package:amber_flutter/shared/providers/auth_provider.dart';
import 'package:amber_flutter/shared/theme/design_tokens.dart';
import 'package:amber_flutter/shared/widgets/design_top_bar.dart';
import 'package:amber_flutter/shared/widgets/list_frame.dart';
import 'package:amber_flutter/shared/widgets/overview_block.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import '../amber_brain/fake_brain.dart';
import '../tra_dinh/hoc_tap/hoc_tap_test_support.dart';

Alert _alert(String id) => Alert(id: id, kind: 'TASK_DUE', title: 'Trễ hạn $id', href: '/du-an');

const _online = BrainConnection(
  link: BrainLink.online,
  apiHost: 'localhost:3000',
  status: BrainStatus(serverEnv: 'DEV', serverHost: 'localhost:3000', ollama: 'up', model: 'm'),
);

const _financeOverview = FinanceOverview(
  currentBalance: 0,
  totalIncome: 0,
  totalExpense: 0,
  activeProjectId: 'thang-11',
  activeProjectName: 'Tháng 11',
);

FinanceSummary _summary({required double net, required double expense}) => FinanceSummary(
  projectId: 'thang-11',
  projectName: 'Tháng 11',
  startDate: '2026-11-01',
  endDate: '2026-11-30',
  totalBalance: 0,
  totalIncome: expense + net,
  totalExpense: expense,
  netThisMonth: net,
  budgetProgress: const [],
);

SubjectOverview _subject({int? goal, int minutes = 0, CardsToday? cards}) => SubjectOverview(
  subjectId: 's$goal$minutes',
  name: 'Tiếng Anh',
  goalMinutes: goal,
  today: TodayInfo(minutes: minutes, logCount: 0, done: false),
  cards: cards,
);

StudyOverview _study(List<SubjectOverview> subjects) {
  final base = StudyOverview.fromJson(fixtureMap('overview'));
  return StudyOverview(today: base.today, week: base.week, subjects: subjects);
}

DuAnOverview _projects(List<int> progress) => DuAnOverview(
  year: 2026,
  activeProjects: [
    for (final (i, p) in progress.indexed)
      ActiveProject(id: 'p$i', name: 'Dự án $i', totalTasks: 10, doneTasks: p ~/ 10, progressPct: p),
  ],
  completedThisYear: 0,
  upcomingProjects: const [],
);

/// Đã đăng nhập (biết email); ghi lại số lần gọi logout.
class _FakeAuth extends AuthController {
  int logouts = 0;

  @override
  Future<AuthState> build() async => const Authenticated({'id': 'u', 'email': 'me@duangmai.io.vn', 'name': 'Me'});

  @override
  Future<void> logout() async {
    logouts++;
    state = const AsyncData(Unauthenticated());
  }
}

Future<KieuLauNotifications> _withAlerts(int n) async =>
    (alerts: [for (var i = 0; i < n; i++) _alert('$i')], recentActivity: const <ActivityLogEntry>[]);

/// Home + 5 đích giả: mỗi đích hiện đúng đường dẫn của nó để kiểm tra điều hướng.
Future<void> _pump(
  WidgetTester tester, {
  _FakeAuth? auth,
  Future<KieuLauNotifications> Function()? notifications,
  BrainConnection brain = _online,
  Future<FinanceOverview> Function()? finance,
  FinanceSummary? summary,
  Future<StudyOverview> Function()? study,
  Future<DuAnOverview> Function()? projects,
}) async {
  Widget dest(String path) => Scaffold(appBar: AppBar(), body: Text('ĐÍCH $path'));
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        notificationsProvider.overrideWith((ref) => (notifications ?? () => _withAlerts(0))()),
        brainStatusProvider.overrideWith(() => FixedBrainStatus(brain)),
        authControllerProvider.overrideWith(() => auth ?? _FakeAuth()),
        financeOverviewProvider.overrideWith((ref) => (finance ?? () async => _financeOverview)()),
        financeSummaryProvider.overrideWith((ref, id) async => summary ?? _summary(net: 0, expense: 0)),
        studyOverviewProvider.overrideWith((ref) => (study ?? () async => _study(const []))()),
        duAnOverviewProvider.overrideWith((ref) => (projects ?? () async => _projects(const []))()),
      ],
      child: MaterialApp.router(
        theme: ThemeData.dark(),
        routerConfig: GoRouter(
          routes: [
            GoRoute(path: '/', builder: (_, _) => const DuDoScreen()),
            for (final p in ['/tang-kinh-cac', '/nghi-su-duong', '/kieu-lau', '/tra-dinh', '/login'])
              GoRoute(path: p, builder: (_, _) => dest(p)),
          ],
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

/// Màu của đoạn đầu tiên trong nội dung dòng (Text.rich: gốc → span của mình → các con).
Color? _firstSpanColor(WidgetTester tester, String label) {
  final row = find.ancestor(of: find.text(label), matching: find.byType(OverviewRow));
  final rich = tester.widgetList<RichText>(find.descendant(of: row, matching: find.byType(RichText))).last;
  final mine = (rich.text as TextSpan).children!.single as TextSpan;
  return (mine.children!.first as TextSpan).style?.color;
}

String _rowText(WidgetTester tester, String label) {
  final row = find.ancestor(of: find.text(label), matching: find.byType(OverviewRow));
  final rich = find.descendant(of: row, matching: find.byType(RichText));
  return tester.widgetList<RichText>(rich).map((r) => r.text.toPlainText()).where((t) => t != label).join();
}

void main() {
  testWidgets('bố cục: thanh trên "Âm Dương Giới" không có nút quay lại → Cập nhật hôm nay → khung 4 tòa', (tester) async {
    await _pump(tester);
    expect(find.descendant(of: find.byType(DesignTopBar), matching: find.text('Âm Dương Giới')), findsOneWidget);
    expect(find.byKey(const ValueKey('design-top-bar-back')), findsNothing);
    expect(find.text('CẬP NHẬT HÔM NAY'), findsOneWidget);
    expect(find.byType(OverviewRow), findsNWidgets(3));
    for (final (name, sub) in [
      ('Tàng Kinh Các', 'Lưu trữ & tri thức'),
      ('Nghị Sự Đường', 'Việc & tiền bạc'),
      ('Kiều Lâu', 'Thông báo & tin tức'),
      ('Trà Đình', 'Học tập & luyện tập'),
    ]) {
      final tile = find.ancestor(of: find.text(name), matching: find.byType(FrameTile));
      expect(find.descendant(of: find.byType(ListFrame), matching: tile), findsOneWidget, reason: name);
      expect(find.descendant(of: tile, matching: find.text(sub)), findsOneWidget, reason: sub);
    }
    expect(find.text('Chạm vào một tòa nhà để vào'), findsOneWidget);
  });

  for (final (name, path) in [
    ('Tàng Kinh Các', '/tang-kinh-cac'),
    ('Nghị Sự Đường', '/nghi-su-duong'),
    ('Kiều Lâu', '/kieu-lau'),
    ('Trà Đình', '/tra-dinh'),
  ]) {
    testWidgets('bấm $name → push $path, back về Home', (tester) async {
      await _pump(tester);
      await tester.tap(find.byKey(ValueKey('building-$path')));
      await tester.pumpAndSettle();
      expect(find.text('ĐÍCH $path'), findsOneWidget);
      await tester.tap(find.byType(BackButton));
      await tester.pumpAndSettle();
      expect(find.byType(DuDoScreen), findsOneWidget);
    });
  }

  group('menu tài khoản (logo Amber góc phải)', () {
    Future<void> openMenu(WidgetTester tester) async {
      await tester.tap(find.byKey(const ValueKey('account-menu-button')));
      await tester.pumpAndSettle();
    }

    testWidgets('logo là ảnh Amber, không còn chữ A; bấm mở menu: email, Cài đặt, Đăng xuất (không có mục Amber)', (tester) async {
      await _pump(tester);
      expect(find.descendant(of: find.byType(DesignTopBar), matching: find.byKey(const ValueKey('amber-logo'))), findsOneWidget);
      expect(find.text('A'), findsNothing);
      expect(find.text('Cài đặt'), findsNothing); // chưa mở
      await openMenu(tester);
      expect(find.text('me@duangmai.io.vn'), findsOneWidget);
      expect(find.text('Trò chuyện với Amber'), findsNothing);
      expect(find.text('Cài đặt'), findsOneWidget);
      expect(find.text('Đăng xuất'), findsOneWidget);
      expect(find.text('Đăng nhập'), findsNothing);
    });

    testWidgets('chat Amber là nút nổi góc phải dưới, bấm mở khung chat ngay trên Home', (tester) async {
      await _pump(tester);
      final toggle = tester.getRect(find.byKey(const ValueKey('amber-chat-toggle')));
      final screen = tester.view.physicalSize / tester.view.devicePixelRatio;
      expect(toggle.right, greaterThan(screen.width - 80));
      expect(toggle.bottom, greaterThan(screen.height - 80));
      await tester.tap(find.byKey(const ValueKey('amber-chat-toggle')));
      await tester.pumpAndSettle();
      expect(find.byType(AmberChatPanel), findsOneWidget);
      expect(find.byType(DuDoScreen), findsOneWidget); // không chuyển màn
    });

    testWidgets('Cài đặt → toast "Chưa có màn Cài đặt"', (tester) async {
      await _pump(tester);
      await openMenu(tester);
      await tester.tap(find.text('Cài đặt'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 750));
      expect(find.text('Chưa có màn Cài đặt'), findsOneWidget);
      expect(find.byKey(const ValueKey('toast-info')), findsOneWidget);
    });

    testWidgets('Đăng xuất → gọi logout một lần, menu đóng, mục đổi thành Đăng nhập', (tester) async {
      final auth = _FakeAuth();
      await _pump(tester, auth: auth);
      await openMenu(tester);
      await tester.tap(find.text('Đăng xuất'));
      await tester.pumpAndSettle();
      expect(auth.logouts, 1);
      expect(find.text('Đăng xuất'), findsNothing);
      await openMenu(tester);
      expect(find.text('Đăng nhập'), findsOneWidget);
      await tester.tap(find.text('Đăng nhập'));
      await tester.pumpAndSettle();
      expect(find.text('ĐÍCH /login'), findsOneWidget);
    });
  });

  group('responsive', () {
    Future<void> at(WidgetTester tester, double width) async {
      tester.view.physicalSize = Size(width, 1000);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      await _pump(tester);
    }

    Rect rectOf(WidgetTester tester, String path) => tester.getRect(find.byKey(ValueKey('building-$path')));

    testWidgets('điện thoại (390): xếp dọc, 4 tòa 2×2, lề 14', (tester) async {
      await at(tester, 390);
      final overview = tester.getRect(find.byType(OverviewBlock));
      final frame = tester.getRect(find.byType(ListFrame));
      expect(overview.left, 14);
      expect(overview.width, 390 - 28);
      expect(frame.top, greaterThan(overview.bottom));
      expect(rectOf(tester, '/nghi-su-duong').top, rectOf(tester, '/tang-kinh-cac').top);
      expect(rectOf(tester, '/kieu-lau').top, greaterThan(rectOf(tester, '/tang-kinh-cac').bottom));
    });

    testWidgets('máy tính bảng (800): cột 760 giữa màn, xếp dọc, 4 tòa một hàng', (tester) async {
      await at(tester, 800);
      final overview = tester.getRect(find.byType(OverviewBlock));
      expect(overview.width, 760 - 48);
      expect(overview.left, (800 - 760) / 2 + 24);
      final top = rectOf(tester, '/tang-kinh-cac').top;
      for (final p in ['/nghi-su-duong', '/kieu-lau', '/tra-dinh']) {
        expect(rectOf(tester, p).top, top, reason: p);
      }
    });

    testWidgets('web rộng (1920): cột 1120 giữa màn, tổng quan 380 bên trái, khung 2×2 bên phải; thanh trên căn theo cột', (tester) async {
      await at(tester, 1920);
      final overview = tester.getRect(find.byType(OverviewBlock));
      final frame = tester.getRect(find.byType(ListFrame));
      final left = (1920 - 1120) / 2 + 24;
      expect(overview.left, left);
      expect(overview.width, 380);
      expect(frame.left, greaterThan(overview.right));
      expect(frame.top, overview.top);
      expect(frame.right, 1920 - left);
      expect(rectOf(tester, '/kieu-lau').top, greaterThan(rectOf(tester, '/tang-kinh-cac').bottom));
      // Tên màn và logo thẳng mép cột nội dung, không dạt ra mép màn.
      final title = tester.getRect(find.descendant(of: find.byType(DesignTopBar), matching: find.text('Âm Dương Giới')));
      final logo = tester.getRect(find.byKey(const ValueKey('account-menu-button')));
      expect(title.left, left);
      expect(logo.right, 1920 - left);
    });
  });

  group('Tin tức', () {
    testWidgets('0 cảnh báo → "Không có tin mới. Mọi thứ ổn."', (tester) async {
      await _pump(tester);
      expect(find.text('Không có tin mới. Mọi thứ ổn.'), findsOneWidget);
    });

    testWidgets('có cảnh báo → số cảnh báo màu đỏ + tiêu đề cảnh báo đầu', (tester) async {
      await _pump(tester, notifications: () => _withAlerts(3));
      expect(_rowText(tester, 'Tin tức'), '3 cảnh báo · Trễ hạn 0 và 2 tin khác');
      expect(_firstSpanColor(tester, 'Tin tức'), DesignColors.danger);
    });

    testWidgets('API lỗi → dòng báo không tải được, các dòng khác vẫn hiện', (tester) async {
      await _pump(tester, notifications: () => Future.error(Exception('offline')));
      expect(find.text('Không tải được tin.'), findsOneWidget);
      expect(find.text('Chạm vào một tòa nhà để vào'), findsOneWidget);
    });
  });

  group('Chi tiêu (số dư ví · chi tháng này)', () {
    FinanceOverview balance(num b, {String? month = 'thang-11'}) =>
        FinanceOverview(currentBalance: b, totalIncome: 0, totalExpense: 0, activeProjectId: month);

    testWidgets('số dư âm → đỏ + tổng chi tháng đang mở (không dùng chênh lệch thu − chi)', (tester) async {
      await _pump(tester, finance: () async => balance(-1165565), summary: _summary(net: -42, expense: 4384567));
      expect(_rowText(tester, 'Chi tiêu'), '-1.165.565₫ · chi 4.384.567₫ tháng này');
      expect(_firstSpanColor(tester, 'Chi tiêu'), DesignColors.danger);
    });

    testWidgets('số dư dương → không tô đỏ', (tester) async {
      await _pump(tester, finance: () async => balance(500000), summary: _summary(net: -1, expense: 100000));
      expect(_rowText(tester, 'Chi tiêu'), '500.000₫ · chi 100.000₫ tháng này');
      expect(_firstSpanColor(tester, 'Chi tiêu'), isNot(DesignColors.danger));
    });

    testWidgets('chưa mở tháng tài chính → vẫn hiện số dư, kèm lời nhắc', (tester) async {
      await _pump(tester, finance: () async => balance(250000, month: null));
      expect(_rowText(tester, 'Chi tiêu'), '250.000₫ · chưa mở tháng tài chính này');
    });
  });

  group('Task', () {
    test('ghép thẻ còn ôn, phút học / mục tiêu và dự án đang chạy', () {
      final study = _study([
        _subject(goal: 30, minutes: 10, cards: const CardsToday(planned: 20, finished: 5)),
        _subject(goal: 15, minutes: 20, cards: const CardsToday(planned: 8, finished: 8)),
        _subject(), // không mục tiêu, không thẻ → bỏ qua
      ]);
      expect(taskSummary(study, _projects([0, 50])), 'Ôn 15 thẻ · học 30/45 phút · 2 dự án 25%');
    });

    test('ôn hết thẻ hôm nay, không có dự án', () {
      final study = _study([_subject(goal: 30, minutes: 30, cards: const CardsToday(planned: 10, finished: 10))]);
      expect(taskSummary(study, _projects(const [])), 'Đã ôn xong thẻ · học 30/30 phút');
    });

    test('chỉ có dự án (Trà Đình chưa tải / lỗi) → viết hoa chữ đầu', () {
      expect(taskSummary(null, _projects([40])), '1 dự án 40%');
      expect(taskSummary(_study([_subject(cards: const CardsToday())]), null), 'Không có việc nào hôm nay.');
    });

    testWidgets('hiện trên màn từ dữ liệu provider', (tester) async {
      await _pump(
        tester,
        study: () async => _study([_subject(goal: 30, minutes: 0, cards: const CardsToday(planned: 12))]),
        projects: () async => _projects([0]),
      );
      expect(find.text('Ôn 12 thẻ · học 0/30 phút · 1 dự án 0%'), findsOneWidget);
    });

    testWidgets('cả hai API lỗi → "Không tải được việc hôm nay."', (tester) async {
      await _pump(tester, study: () => Future.error(Exception('x')), projects: () => Future.error(Exception('y')));
      expect(find.text('Không tải được việc hôm nay.'), findsOneWidget);
    });
  });

  testWidgets('320 px, chữ ×2,0: không tràn', (tester) async {
    tester.view.physicalSize = const Size(320, 900);
    tester.view.devicePixelRatio = 1;
    tester.platformDispatcher.textScaleFactorTestValue = 2.0;
    addTearDown(tester.view.reset);
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
    await _pump(
      tester,
      notifications: () => _withAlerts(2),
      summary: _summary(net: -1165565, expense: 4384567),
      study: () async => _study([_subject(goal: 30, cards: const CardsToday(planned: 20))]),
      projects: () async => _projects([0]),
    );
    expect(tester.takeException(), isNull);
  });
}

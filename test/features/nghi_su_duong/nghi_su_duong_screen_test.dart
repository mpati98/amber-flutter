import 'dart:async';

import 'package:amber_flutter/features/kieu_lau/models/alert.dart';
import 'package:amber_flutter/features/nghi_su_duong/models/finance_summary.dart';
import 'package:amber_flutter/features/nghi_su_duong/models/project.dart';
import 'package:amber_flutter/features/nghi_su_duong/models/project_summary.dart';
import 'package:amber_flutter/features/nghi_su_duong/models/task.dart';
import 'package:amber_flutter/features/nghi_su_duong/screens/finance_month_screen.dart';
import 'package:amber_flutter/features/nghi_su_duong/screens/nghi_su_duong_screen.dart';
import 'package:amber_flutter/features/nghi_su_duong/screens/project_detail_screen.dart';
import 'package:amber_flutter/features/nghi_su_duong/utils/nsd_notices.dart';
import 'package:amber_flutter/features/nghi_su_duong/widgets/project_card.dart';
import 'package:amber_flutter/shared/theme/design_tokens.dart';
import 'package:amber_flutter/shared/utils/currency.dart';
import 'package:amber_flutter/shared/widgets/list_frame.dart';
import 'package:dio/dio.dart';
import 'package:flutter/services.dart' show LogicalKeyboardKey;
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

import 'detail_test_support.dart';
import 'nsd_screen_support.dart';

ProjectSummary _p(
  String id,
  String name, {
  ProjectStatus status = ProjectStatus.active,
  int total = 0,
  int done = 0,
  int attention = 0,
  NextMilestone? milestone,
  String? end,
}) => ProjectSummary(
  id: id,
  name: name,
  status: status,
  endDate: end,
  taskTotal: total,
  taskDone: done,
  taskDoing: 0,
  attentionCount: attention,
  nextMilestone: milestone,
);

AttentionItem _att(String taskId, String title, {String kind = 'OVERDUE', int days = 3}) =>
    AttentionItem(taskId: taskId, title: title, status: 'PREP', projectId: 'p1', projectName: 'Sự kiện tháng 11', kind: kind, days: days);

const _budgetAlert = Alert(id: 'budget:b1', kind: 'BUDGET_EXCEEDED', title: 'Vượt ngân sách "Ăn uống"', href: '/finance/m11');
const _taskAlert = Alert(id: 'task:t9', kind: 'TASK_DUE', title: 'Sắp/đã trễ hạn: "Nộp hồ sơ"', detail: '2026-11-23', href: '/du-an');
const _learnAlert = Alert(id: 'learn:s1', kind: 'LEARN_INACTIVE', title: 'Lâu chưa học', href: '/tra-dinh');

FakeApi _api({List<ProjectSummary> projects = const [], List<AttentionItem> attention = const [], List<Task> tasks = const []}) =>
    FakeApi(project: mkProject(), tasks: [...tasks])
      ..summaryProjects = [...projects]
      ..summaryAttention = [...attention];

/// Dữ liệu đủ dài để mọi khung phải cuộn bên trong.
FakeApi _busyApi() => _api(
  projects: [for (var i = 0; i < 12; i++) _p('p$i', 'Dự án số $i có tên khá dài', total: 10, done: i % 10, end: '2026-12-${10 + i}')],
  attention: [for (var i = 0; i < 8; i++) _att('a$i', 'Việc quá hạn $i')],
)..routines = [for (var i = 0; i < 8; i++) mkRoutine('r$i', 'Việc hằng ngày $i')];

FakeFinanceApi _busyFinance() => FakeFinanceApi(transactions: [for (var i = 0; i < 30; i++) nsdTx('tx$i', 'm11', note: 'Chi $i')]);

void main() {
  group('bố cục một màn', () {
    for (final size in const [Size(1920, 1080), Size(1280, 720)]) {
      testWidgets('${size.width.toInt()}×${size.height.toInt()}: 5 khung, 3 cột 2 / 3 / 2, không tràn, không cuộn trang', (tester) async {
        await pumpNsd(tester, size: size, api: _busyApi(), finance: _busyFinance(), alerts: const [_budgetAlert, _taskAlert]);
        expect(tester.takeException(), isNull);
        for (final t in ['Cần chú ý', 'Hôm nay', 'Công việc ATS', 'Dự án', 'Tài chính']) {
          expect(nsdFrame(t), findsOneWidget, reason: t);
        }
        expect(find.byKey(const ValueKey('zone-tab-projects')), findsNothing);
        expectNoPageScroll(tester);

        final left = tester.getRect(nsdFrame('Hôm nay'));
        final mid = tester.getRect(nsdFrame('Dự án'));
        final right = tester.getRect(nsdFrame('Tài chính'));
        expect(left.left, 16);
        expect(right.right, size.width - 16);
        expect(left.right, lessThan(mid.left));
        expect(mid.right, lessThan(right.left));
        expect(mid.width / left.width, closeTo(1.5, 0.05));
        expect(right.width, closeTo(left.width, 1));
        // Cột trái: Cần chú ý → Hôm nay → ATS; đáy ATS = đáy hai cột kia.
        final notice = tester.getRect(nsdFrame('Cần chú ý'));
        final ats = tester.getRect(nsdFrame('Công việc ATS'));
        expect(notice.bottom, lessThan(left.top));
        expect(left.bottom, lessThan(ats.top));
        expect(ats.bottom, closeTo(mid.bottom, 0.5));
        expect(right.bottom, closeTo(mid.bottom, 0.5));
        expect(mid.bottom, lessThanOrEqualTo(size.height - 16));
      });
    }

    testWidgets('800×1000: 2 cột (Dự án, Tài chính, Hôm nay | Cần chú ý, ATS), không tràn, không cuộn trang', (tester) async {
      await pumpNsd(tester, size: const Size(800, 1000), api: _busyApi(), finance: _busyFinance());
      expect(tester.takeException(), isNull);
      expectNoPageScroll(tester);
      final projects = tester.getRect(nsdFrame('Dự án'));
      final notice = tester.getRect(nsdFrame('Cần chú ý'));
      expect(projects.left, 16);
      expect(notice.left, greaterThan(projects.right));
      expect(tester.getRect(nsdFrame('Tài chính')).left, projects.left);
      expect(tester.getRect(nsdFrame('Hôm nay')).left, projects.left);
      expect(tester.getRect(nsdFrame('Công việc ATS')).left, notice.left);
    });

    testWidgets('390×844: tab Dự án / Tài chính / Hôm nay / Cần chú ý / ATS; mỗi tab không tràn, không cuộn trang', (tester) async {
      await pumpNsd(tester, size: const Size(390, 844), api: _busyApi(), finance: _busyFinance());
      expect(find.byKey(const ValueKey('zone-tab-projects')), findsOneWidget);
      expect(nsdFrame('Dự án'), findsOneWidget, reason: 'tab đầu là Dự án');
      expect(nsdFrame('Tài chính'), findsNothing);
      for (final (tab, title) in const [
        ('finance', 'Tài chính'),
        ('today', 'Hôm nay'),
        ('attention', 'Cần chú ý'),
        ('ats', 'Công việc ATS'),
        ('projects', 'Dự án'),
      ]) {
        await nsdTab(tester, tab);
        expect(nsdFrame(title), findsOneWidget, reason: title);
        expect(tester.getRect(nsdFrame(title)).bottom, closeTo(844 - 16, 0.5), reason: 'tab $title lấp chiều cao');
        expect(tester.takeException(), isNull);
        expectNoPageScroll(tester);
      }
    });

    testWidgets('320 px, chữ ×2,0: không tràn ở mọi tab', (tester) async {
      tester.platformDispatcher.textScaleFactorTestValue = 2.0;
      addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
      await pumpNsd(tester, size: const Size(320, 640), api: _busyApi(), finance: _busyFinance(), alerts: const [_budgetAlert]);
      expect(tester.takeException(), isNull);
      for (final tab in ['finance', 'today', 'attention', 'ats']) {
        await nsdTab(tester, tab);
        expect(tester.takeException(), isNull, reason: tab);
      }
    });

    testWidgets('không còn dòng gợi ý "Chạm vào một mục…"', (tester) async {
      await pumpNsd(tester);
      expect(find.textContaining('Chạm vào'), findsNothing);
    });
  });

  group('Cần chú ý', () {
    test('buildNsdNotices: âm quỹ → cảnh báo backend (bỏ LEARN) → quá hạn chưa trùng → routine chưa xong', () {
      final n = buildNsdNotices(
        finance: nsdOverview(balance: -1165565),
        alerts: const [_budgetAlert, _taskAlert, _learnAlert],
        attention: [_att('t9', 'Nộp hồ sơ'), _att('t1', 'Soạn kế hoạch', days: 15), _att('t2', 'Nằm im', kind: 'IDLE')],
        routines: [mkRoutine('a', 'Tập thể dục'), mkRoutine('b', 'Uống nước', done: {6}), mkRoutine('c', 'Họp', dueToday: false)],
      );
      expect(n.map((x) => x.id), ['balance', 'budget:b1', 'task:t9', 'task:t1', 'routines']);
      expect(n[0].level, NsdNoticeLevel.bad);
      expect(n[1].href, '/finance/m11', reason: 'href chi tiết giữ nguyên');
      expect(n[2].href, isNull, reason: '/du-an chỉ redirect về chính màn này');
      expect(n[3].href, '/du-an/p1?task=t1');
      expect(n[4].detail, 'Tập thể dục');
      expect(n[0].toWorld(), {'text': 'Âm quỹ · ${formatVnd(-1165565)}', 'lvl': 'bad'});
    });

    test('việc nằm im QUÁ 7 ngày (IDLE của summary) gộp một dòng "N việc nằm im", đứng trước routine', () {
      final n = buildNsdNotices(
        attention: [
          _att('t1', 'Quá hạn', days: 2),
          _att('i1', 'Đứng 8 ngày', kind: 'IDLE', days: 8),
          _att('i2', 'Đứng 30 ngày', kind: 'IDLE', days: 30),
          _att('i3', 'Đứng đúng 7 ngày', kind: 'IDLE', days: 7),
        ],
        routines: [mkRoutine('a', 'Tập thể dục')],
      );
      expect(n.map((x) => x.id), ['task:t1', 'idle', 'routines']);
      final idle = n[1];
      expect(idle.title, '2 việc nằm im');
      expect(idle.tasks.map((t) => t.taskId), ['i1', 'i2']);
      expect(idle.href, isNull);
      expect(idle.toWorld(), {'text': '2 việc nằm im · quá 7 ngày chưa cập nhật', 'lvl': 'warn'}, reason: 'popup cảnh 3D dùng chung nguồn');
      expect(buildNsdNotices(attention: [_att('i3', 'x', kind: 'IDLE', days: 7)]), isEmpty);
    });

    testWidgets('chạm "N việc nằm im" → modal liệt kê; chạm một việc → chi tiết dự án mở đúng việc', (tester) async {
      await pumpNsd(
        tester,
        api: _api(
          attention: [_att('i1', 'Việc đứng lâu', kind: 'IDLE', days: 9), _att('i2', 'Việc khác', kind: 'IDLE', days: 12)],
          tasks: [mkTask('i1', 'Việc đứng lâu', TaskStatus.inProgress), mkTask('i2', 'Việc khác', TaskStatus.inProgress)],
        ),
      );
      expect(find.descendant(of: nsdFrame('Cần chú ý'), matching: find.textContaining('2 việc nằm im', findRichText: true)), findsOneWidget);
      await tester.tap(find.byKey(const ValueKey('nsd-notice-idle')));
      await tester.pumpAndSettle();
      expect(find.widgetWithText(AppBar, '2 việc nằm im'), findsOneWidget);
      expect(find.text('Sự kiện tháng 11 · nằm im 9 ngày'), findsOneWidget);
      await tester.tap(find.byKey(const ValueKey('idle-task-i2')));
      await tester.pumpAndSettle();
      expect(find.byType(ProjectDetailScreen), findsOneWidget);
      expect(find.widgetWithText(AppBar, 'Chi tiết việc'), findsOneWidget);
    });

    test('attentionLocation: mở dự án kèm id việc', () {
      expect(attentionLocation(_att('t9', 'x')), '/du-an/p1?task=t9');
    });

    testWidgets('hiện từng dòng; bấm dòng có href mở đúng màn (vượt ngân sách → chi tiết tháng)', (tester) async {
      await pumpNsd(tester, overview: nsdOverview(balance: -100000), alerts: const [_budgetAlert, _taskAlert]);
      expect(find.descendant(of: nsdFrame('Cần chú ý'), matching: find.textContaining('Âm quỹ', findRichText: true)), findsOneWidget);
      expect(find.byKey(const ValueKey('nsd-notice-task:t9')), findsOneWidget);
      expect(find.descendant(of: find.byKey(const ValueKey('nsd-notice-task:t9')), matching: find.byType(InkWell)), findsNothing);
      await tester.tap(find.byKey(const ValueKey('nsd-notice-budget:b1')));
      await tester.pumpAndSettle();
      expect(find.byType(FinanceMonthScreen), findsOneWidget);
    });

    testWidgets('việc quá hạn → mở chi tiết dự án và đúng việc', (tester) async {
      await pumpNsd(
        tester,
        api: _api(attention: [_att('t2', 'Việc hai')], tasks: [mkTask('t1', 'Việc một', TaskStatus.prep), mkTask('t2', 'Việc hai', TaskStatus.prep)]),
      );
      await tester.tap(find.byKey(const ValueKey('nsd-notice-task:t2')));
      await tester.pumpAndSettle();
      expect(find.byType(ProjectDetailScreen), findsOneWidget);
      expect(find.widgetWithText(AppBar, 'Chi tiết việc'), findsOneWidget);
    });

    testWidgets('không có gì → "Mọi thứ ổn."', (tester) async {
      await pumpNsd(tester);
      expect(find.byKey(const ValueKey('nsd-all-ok')), findsOneWidget);
      expect(tester.widget<Text>(find.byKey(const ValueKey('nsd-all-ok'))).style?.color, DesignColors.success);
    });
  });

  group('Hôm nay', () {
    testWidgets('việc hằng ngày + học tập; bấm học tập → /hoc-tap', (tester) async {
      await pumpNsd(tester, api: _api()..routines = [mkRoutine('a', 'Tập thể dục')]);
      final today = nsdFrame('Hôm nay');
      expect(find.descendant(of: today, matching: find.text('Việc hằng ngày')), findsOneWidget);
      expect(find.descendant(of: today, matching: find.text('Tập thể dục')), findsOneWidget);
      expect(find.descendant(of: today, matching: find.byKey(const ValueKey('nsd-study-next'))), findsOneWidget);
      expect(tester.widget<Text>(find.byKey(const ValueKey('nsd-study-week'))).data, matches(RegExp(r'^Tuần \d+ / \d+ phút · chuỗi \d+ ngày$')));
      await tester.ensureVisible(find.byKey(const ValueKey('nsd-hoc-tap')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const ValueKey('nsd-hoc-tap')));
      await tester.pumpAndSettle();
      expect(find.text('ĐÍCH /hoc-tap'), findsOneWidget);
    });

    testWidgets('học tập lỗi tải → dòng báo, vẫn bấm được', (tester) async {
      await pumpNsd(tester, studyError: Exception('x'));
      expect(find.descendant(of: find.byKey(const ValueKey('nsd-hoc-tap')), matching: find.text('Không tải được số liệu.')), findsOneWidget);
    });
  });

  group('Dự án', () {
    final projects = [
      _p('p1', 'Sự kiện tháng 11', total: 4, done: 1, attention: 2, milestone: const NextMilestone(id: 'm', title: 'Chốt địa điểm', dueDate: '2026-11-25')),
      _p('p2', 'Học Flutter', total: 0, end: '2026-12-31'),
      _p('p3', 'Tạm nghỉ', status: ProjectStatus.paused),
      _p('p4', 'Xong rồi', status: ProjectStatus.done, total: 3, done: 3),
    ];

    testWidgets('khung: chỉ dự án đang triển khai — tên, nhãn, %, hạn gần nhất, thanh tiến độ', (tester) async {
      await pumpNsd(tester, api: _api(projects: projects));
      expect(find.byKey(const ValueKey('nsd-project-p1')), findsOneWidget);
      expect(find.byKey(const ValueKey('nsd-project-p2')), findsOneWidget);
      expect(find.byKey(const ValueKey('nsd-project-p3')), findsNothing);
      expect(find.byKey(const ValueKey('nsd-project-p4')), findsNothing);
      expect(find.textContaining('2 việc cần xử lý · 25% · Chốt địa điểm · 25/11', findRichText: true), findsOneWidget);
      expect(find.textContaining('Mới tạo · 0% · Hạn 31/12', findRichText: true), findsOneWidget);
      expect(find.descendant(of: find.byKey(const ValueKey('nsd-project-p1')), matching: find.byType(DesignProgressBar)), findsOneWidget);
      expect(projectTaskPct(projects[3]), 100);
    });

    testWidgets('bấm dự án → màn chi tiết dự án', (tester) async {
      await pumpNsd(tester, api: _api(projects: projects));
      await tester.tap(find.byKey(const ValueKey('nsd-project-p1')));
      await tester.pumpAndSettle();
      expect(find.byType(ProjectDetailScreen), findsOneWidget);
    });

    testWidgets('mở rộng: thẻ đầy đủ theo nhóm, có cả tạm dừng và đã xong; Esc đóng', (tester) async {
      await pumpNsd(tester, api: _api(projects: projects));
      await tester.tap(find.byKey(const ValueKey('zone-expand-Dự án')));
      await tester.pumpAndSettle();
      final modal = find.byKey(const ValueKey('zone-expanded-Dự án'));
      expect(modal, findsOneWidget);
      expect(tester.takeException(), isNull);
      for (final s in ['ACTIVE', 'PAUSED', 'DONE']) {
        expect(find.byKey(ValueKey('nsd-projects-$s')), findsOneWidget);
      }
      expect(find.descendant(of: modal, matching: find.byType(ProjectCard)), findsNWidgets(4));
      expect(find.descendant(of: modal, matching: find.text('Xong rồi')), findsOneWidget);
      await tester.sendKeyEvent(LogicalKeyboardKey.escape);
      await tester.pumpAndSettle();
      expect(modal, findsNothing);
    });

    testWidgets('"+ Dự án" mở form thêm dự án', (tester) async {
      await pumpNsd(tester);
      await tester.tap(find.byKey(const ValueKey('add-project')));
      await tester.pumpAndSettle();
      expect(find.text('Thêm dự án'), findsWidgets);
    });

    testWidgets('chưa có dự án đang triển khai → câu báo', (tester) async {
      await pumpNsd(tester, api: _api(projects: [projects[3]]));
      expect(find.text('Chưa có dự án nào đang triển khai.'), findsOneWidget);
    });
  });

  group('Tài chính', () {
    final months = [nsdCurrentMonths().single, nsdMonth('m10', 'Tháng 10/2026', start: '2026-10-01', end: '2026-10-31', archived: true)];
    final summaries = {
      'm11': nsdSummary('m11', 'Tháng 11/2026', income: 1000000, expense: 4384567, budgets: const [
        BudgetProgress(categoryId: 'c1', categoryName: 'Ăn uống', limitAmount: 2000000, spent: 2500000),
        BudgetProgress(categoryId: 'c2', categoryName: 'Đi lại', limitAmount: 1000000, spent: 200000),
      ]),
      'm10': nsdSummary('m10', 'Tháng 10/2026', income: 9000000, expense: 3000000),
    };
    FakeFinanceApi fin() => FakeFinanceApi(transactions: [nsdTx('a', 'm11', note: 'Phở'), nsdTx('b', 'm11', note: 'Xăng'), nsdTx('c', 'm10', note: 'Tiền nhà')]);

    testWidgets('đầu khung: số dư âm đỏ + "Âm quỹ", thu / chi / chênh lệch tháng, thanh ngân sách gộp; thân: giao dịch tháng này', (tester) async {
      await pumpNsd(tester, overview: nsdOverview(balance: -1165565), months: months, summaries: summaries, finance: fin());
      final frame = nsdFrame('Tài chính');
      final balance = tester.widget<Text>(find.byKey(const ValueKey('nsd-balance')));
      expect(balance.style?.color, DesignColors.danger);
      expect(find.descendant(of: frame, matching: find.text('Âm quỹ')), findsOneWidget);
      expect(find.descendant(of: frame, matching: find.text('Tháng 11/2026 ›')), findsOneWidget);
      expect(find.descendant(of: frame, matching: find.textContaining('Chênh lệch')), findsOneWidget);
      expect(find.descendant(of: find.byKey(const ValueKey('nsd-budget')), matching: find.textContaining('vượt 1 mục', findRichText: true)), findsOneWidget);
      expect(find.byKey(const ValueKey('tx-a')), findsOneWidget);
      expect(find.byKey(const ValueKey('tx-b')), findsOneWidget);
      expect(find.byKey(const ValueKey('tx-c')), findsNothing, reason: 'giao dịch tháng khác');
      expect(find.byKey(const ValueKey('start-month')), findsNothing);
    });

    testWidgets('bấm tên tháng → màn chi tiết tháng', (tester) async {
      await pumpNsd(tester, months: months, summaries: summaries, finance: fin());
      await tester.tap(find.byKey(const ValueKey('nsd-month-open')));
      await tester.pumpAndSettle();
      expect(tester.widget<FinanceMonthScreen>(find.byType(FinanceMonthScreen)).projectId, 'm11');
    });

    testWidgets('"+ Giao dịch" mở form có sẵn cho tháng đang mở', (tester) async {
      await pumpNsd(tester, months: months, summaries: summaries, finance: fin());
      await tester.tap(find.byKey(const ValueKey('add-transaction')));
      await tester.pumpAndSettle();
      expect(find.text('Thêm giao dịch'), findsWidgets);
    });

    testWidgets('chưa mở tháng nào → "+ Giao dịch" tắt, câu báo', (tester) async {
      await pumpNsd(tester, overview: nsdOverview(monthId: null), months: months, summaries: summaries);
      expect(tester.widget<OutlinedButton>(find.descendant(of: find.byKey(const ValueKey('add-transaction')), matching: find.byType(OutlinedButton))).onPressed, isNull);
      expect(find.text('Chưa mở tháng tài chính này.'), findsOneWidget);
    });

    testWidgets('modal mở rộng: danh sách tháng, chọn tháng khác → giao dịch tháng đó ngay trong modal; vẫn vào được chi tiết tháng', (tester) async {
      await pumpNsd(tester, size: const Size(1280, 900), months: months, summaries: summaries, finance: fin());
      await tester.tap(find.byKey(const ValueKey('zone-expand-Tài chính')));
      await tester.pumpAndSettle();
      final modal = find.byKey(const ValueKey('zone-expanded-Tài chính'));
      expect(modal, findsOneWidget);
      expect(tester.takeException(), isNull);
      expectNoPageScroll(tester);
      Finder inModal(Finder f) => find.descendant(of: modal, matching: f);

      expect(inModal(find.byKey(const ValueKey('month-m11'))), findsOneWidget);
      expect(inModal(find.byKey(const ValueKey('month-m10'))), findsOneWidget);
      expect(inModal(find.byKey(const ValueKey('nsd-month-view-m11'))), findsOneWidget, reason: 'mặc định tháng đang mở');
      expect(inModal(find.byKey(const ValueKey('tx-a'))), findsOneWidget);

      await tester.tap(inModal(find.byKey(const ValueKey('month-m10'))));
      await tester.pumpAndSettle();
      expect(inModal(find.byKey(const ValueKey('nsd-month-view-m10'))), findsOneWidget);
      expect(inModal(find.byKey(const ValueKey('tx-c'))), findsOneWidget);
      expect(inModal(find.byKey(const ValueKey('tx-a'))), findsNothing);
      expect(inModal(find.text('Chênh lệch ${formatVnd(6000000)}')), findsWidgets);

      await tester.tap(inModal(find.byKey(const ValueKey('month-detail-m10'))));
      await tester.pumpAndSettle();
      expect(tester.widget<FinanceMonthScreen>(find.byType(FinanceMonthScreen)).projectId, 'm10');
    });

    testWidgets('modal trên màn hẹp: chọn tháng bằng hàng chip', (tester) async {
      await pumpNsd(tester, size: const Size(390, 844), months: months, summaries: summaries, finance: fin());
      await nsdTab(tester, 'finance');
      await tester.tap(find.byKey(const ValueKey('zone-expand-Tài chính')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const ValueKey('month-chip-m10')));
      await tester.pumpAndSettle();
      expect(find.byKey(const ValueKey('tx-c')), findsOneWidget);
      expect(tester.takeException(), isNull);
      await tester.tap(find.byKey(const ValueKey('zone-expanded-close')));
      await tester.pumpAndSettle();
      expect(find.byKey(const ValueKey('zone-expanded-Tài chính')), findsNothing);
    });
  });

  group('Bắt đầu tháng mới (chuyển từ màn "Tài chính cá nhân")', () {
    testWidgets('bấm → khoá nút + spinner → gọi đúng 1 lần → mở chi tiết tháng vừa tạo; lỗi → toast, nút mở lại', (tester) async {
      final fin = _StartFinanceApi();
      await pumpNsd(tester, months: [nsdMonth('m10', 'Tháng 10/2026', start: '2026-10-01')], finance: fin);
      final button = find.widgetWithText(FilledButton, 'Bắt đầu tháng mới');
      expect(button, findsOneWidget);
      await tester.tap(button);
      await tester.pump();
      expect(find.text('Đang tạo tháng mới...'), findsOneWidget);
      expect(tester.widget<FilledButton>(find.widgetWithText(FilledButton, 'Đang tạo tháng mới...')).onPressed, isNull);
      await tester.tap(find.text('Đang tạo tháng mới...'));
      await tester.pump();
      expect(fin.startCalls, 1);
      fin.pending!.complete(nsdMonth('moi', 'Tháng mới'));
      await tester.pumpAndSettle();
      expect(tester.widget<FinanceMonthScreen>(find.byType(FinanceMonthScreen)).projectId, 'moi');

      Navigator.of(tester.element(find.byType(FinanceMonthScreen))).pop();
      await tester.pumpAndSettle();
      fin.fail = true;
      await tester.tap(find.widgetWithText(FilledButton, 'Bắt đầu tháng mới'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 750));
      expect(find.text('Không bắt đầu được tháng mới, thử lại nhé.'), findsOneWidget);
      expect(tester.widget<FilledButton>(find.widgetWithText(FilledButton, 'Bắt đầu tháng mới')).onPressed, isNotNull);
      expect(find.byType(NghiSuDuongScreen), findsOneWidget);
    });
  });
}

class _StartFinanceApi extends FakeFinanceApi {
  int startCalls = 0;
  bool fail = false;
  Completer<Project>? pending;

  @override
  Future<Project> startNewMonth() {
    startCalls++;
    if (fail) return Future.error(DioException(requestOptions: RequestOptions(path: '/api/finance/projects')));
    pending = Completer<Project>();
    return pending!.future;
  }
}

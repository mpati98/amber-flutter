import 'dart:async';

import 'package:amber_flutter/features/nghi_su_duong/models/project_summary.dart';
import 'package:amber_flutter/features/nghi_su_duong/models/routine.dart';
import 'package:amber_flutter/features/nghi_su_duong/models/task.dart';
import 'package:amber_flutter/features/nghi_su_duong/services/finance_api.dart';
import 'package:amber_flutter/features/nghi_su_duong/screens/du_an_screen.dart';
import 'package:amber_flutter/features/nghi_su_duong/screens/project_detail_screen.dart';
import 'package:amber_flutter/features/nghi_su_duong/services/nghi_su_duong_api.dart';
import 'package:amber_flutter/features/nghi_su_duong/widgets/attention_card.dart';
import 'package:amber_flutter/features/nghi_su_duong/widgets/routines_card.dart';
import 'package:amber_flutter/shared/providers/auth_provider.dart';
import 'package:amber_flutter/shared/services/api_client.dart';
import 'package:amber_flutter/shared/widgets/scroll_card.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import 'package:amber_flutter/features/kieu_lau/models/activity_log_entry.dart';
import 'package:amber_flutter/features/kieu_lau/models/alert.dart';
import 'package:amber_flutter/features/kieu_lau/providers/kieu_lau_provider.dart';

import 'detail_test_support.dart';

// Thẻ "Việc hằng ngày" và "Cần chú ý" trên màn Dự án. API giả.

class _FakeAuth extends AuthController {
  @override
  Future<AuthState> build() async => const Authenticated({'name': 'Test'});
}

DioException _badRequest(String code) {
  final req = RequestOptions(path: '/api/du-an/routines/x/logs/2026-10-08');
  return DioException(
    requestOptions: req,
    type: DioExceptionType.badResponse,
    response: Response(requestOptions: req, statusCode: 400, data: {'error': code}),
  );
}

Future<FakeApi> _pump(
  WidgetTester tester, {
  List<Routine> routines = const [],
  List<AttentionItem> attention = const [],
  List<Task> tasks = const [],
  double width = 390,
}) async {
  final api = FakeApi(project: mkProject(), tasks: [...tasks])
    ..routines = [...routines]
    ..summaryAttention = [...attention];
  tester.view.physicalSize = Size(width, 2400);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  final router = GoRouter(
    initialLocation: '/du-an',
    routes: [
      GoRoute(
        path: '/du-an',
        builder: (_, _) => const DuAnScreen(),
        routes: [
          GoRoute(
            path: ':projectId',
            builder: (_, s) => ProjectDetailScreen(projectId: s.pathParameters['projectId']!, initialTaskId: s.uri.queryParameters['task']),
          ),
        ],
      ),
    ],
  );
  addTearDown(router.dispose);
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        apiClientProvider.overrideWithValue(offlineDio()),
        nghiSuDuongApiProvider.overrideWithValue(api),
        financeApiProvider.overrideWithValue(FakeFinanceApi()),
        authControllerProvider.overrideWith(_FakeAuth.new),
        notificationsProvider.overrideWith((ref) async => (alerts: const <Alert>[], recentActivity: const <ActivityLogEntry>[])),
      ],
      child: MaterialApp.router(theme: ThemeData.dark(), routerConfig: router),
    ),
  );
  await tester.pumpAndSettle();
  return api;
}

Finder _row(String id) => find.byKey(ValueKey('routine-$id'));
Finder _checkbox(String id) => find.descendant(of: _row(id), matching: find.byType(Checkbox));
bool _checked(WidgetTester t, String id) => t.widget<Checkbox>(_checkbox(id)).value!;
Finder _top(Finder f) => find.descendant(of: find.byType(Dialog).last, matching: f);
Finder _saveButton() => find.byType(FilledButton).last;

AttentionItem _att(String taskId, String title, {String kind = 'OVERDUE', int days = 3, String status = 'PREP'}) =>
    AttentionItem(taskId: taskId, title: title, status: status, projectId: 'p1', projectName: 'Sự kiện tháng 11', kind: kind, days: days);

void main() {
  group('hàm thuần', () {
    test('weekdaysLabel: đủ 7 ngày → Hằng ngày, ngược lại "T2 · T4 · T6" (sắp xếp, bỏ trùng)', () {
      expect(weekdaysLabel(const [1, 2, 3, 4, 5, 6, 7]), 'Hằng ngày');
      expect(weekdaysLabel(const [5, 1, 3]), 'T2 · T4 · T6');
      expect(weekdaysLabel(const [6, 7]), 'T7 · CN');
      expect(weekdaysLabel(const [1, 1, 3]), 'T2 · T4');
    });

    test('routineSubtitle: lịch, "nghỉ hôm nay" khi không đến hạn, chuỗi', () {
      expect(routineSubtitle(mkRoutine('a', 'A', streak: 3)), 'Hằng ngày · chuỗi 3 ngày');
      expect(routineSubtitle(mkRoutine('b', 'B', weekdays: const [1, 3, 5], dueToday: false)), 'T2 · T4 · T6 · nghỉ hôm nay · chuỗi 0 ngày');
    });

    test('Routine.fromJson và withDoneToday', () {
      final r = Routine.fromJson({
        'id': 'r', 'name': 'N', 'weekdays': [1, 2], 'dueToday': true, 'doneToday': false, 'streak': 2,
        'last7': [for (var i = 0; i < 7; i++) {'date': '2026-10-0${i + 2}', 'due': true, 'done': i < 2}],
      });
      expect(r.weekdays, [1, 2]);
      expect((r.streak, r.last7.length), (2, 7));
      final done = r.withDoneToday(true);
      expect((done.doneToday, done.streak, done.last7.last.done), (true, 3, true));
      final undone = done.withDoneToday(false);
      expect((undone.doneToday, undone.streak, undone.last7.last.done), (false, 2, false));
      expect(mkRoutine('z', 'Z').withDoneToday(false).streak, 0, reason: 'không âm');
    });

    test('attentionLocation: mở dự án kèm id việc', () {
      expect(attentionLocation(_att('t9', 'x')), '/du-an/p1?task=t9');
    });
  });

  group('thẻ Việc hằng ngày', () {
    final three = [
      mkRoutine('a', 'Uống nước', streak: 2, done: {4, 5}),
      mkRoutine('b', 'Tập thể dục', done: {6}, streak: 1),
      mkRoutine('c', 'Họp tuần', weekdays: const [1], dueToday: false, dueDays: {0}),
    ];

    testWidgets('ba trạng thái dòng; đếm "x / y hôm nay"; chữ lịch lặp', (tester) async {
      await _pump(tester, routines: three);
      expect(find.text('Việc hằng ngày'), findsOneWidget);
      expect(find.text('1 / 2 hôm nay'), findsOneWidget, reason: 'chỉ đếm việc đến hạn hôm nay');
      // a: đến hạn, chưa làm — tick được
      expect(_checked(tester, 'a'), isFalse);
      expect(tester.widget<Checkbox>(_checkbox('a')).onChanged, isNotNull);
      // b: đã làm — tên gạch ngang
      expect(_checked(tester, 'b'), isTrue);
      expect(tester.widget<Text>(find.text('Tập thể dục')).style?.decoration, TextDecoration.lineThrough);
      expect(tester.widget<Text>(find.text('Uống nước')).style?.decoration, isNull);
      // c: không đến hạn — ô tick khoá, tên mờ, ghi "nghỉ hôm nay"
      expect(tester.widget<Checkbox>(_checkbox('c')).onChanged, isNull);
      expect(find.text('T2 · nghỉ hôm nay · chuỗi 0 ngày'), findsOneWidget);
      expect(find.text('Hằng ngày · chuỗi 2 ngày'), findsOneWidget);
      expect(tester.widget<Text>(find.text('Họp tuần')).style!.color!.a, lessThan(tester.widget<Text>(find.text('Uống nước')).style!.color!.a));
      expect(find.text('7 ngày gần nhất · ô cuối là hôm nay'), findsOneWidget);
    });

    testWidgets('7 ô: đã làm tô đầy; đến hạn chưa làm chỉ viền; không đến hạn rất mờ; ô cuối viền đậm; nhãn trợ năng', (tester) async {
      await _pump(tester, routines: [mkRoutine('a', 'A', done: {0, 2, 4, 5, 6}, dueDays: {0, 1, 2, 3, 4, 5, 6}), mkRoutine('c', 'C', dueDays: {0, 6}, dueToday: true)]);
      BoxDecoration deco(String r, int i) => (tester.widget<Container>(find.byKey(ValueKey('dot-$r-$i'))).decoration as BoxDecoration);
      expect(find.byKey(const ValueKey('dots-a')), findsOneWidget);
      expect(deco('a', 0).color, isNotNull, reason: 'đã làm → tô đầy');
      expect(deco('a', 1).color, isNull, reason: 'đến hạn chưa làm → chỉ viền');
      expect(deco('a', 1).border!.top.color.a, greaterThan(0.3));
      expect(deco('c', 3).color, isNull);
      expect(deco('c', 3).border!.top.color.a, lessThan(0.2), reason: 'không đến hạn → rất mờ');
      expect(deco('a', 6).border!.top.width, greaterThan(deco('a', 5).border!.top.width), reason: 'ô cuối viền đậm hơn');
      expect(find.byWidgetPredicate((w) => w is Semantics && w.properties.label == '5 trên 7 ngày gần nhất'), findsOneWidget);
    });

    testWidgets('trống → "Chưa có việc hằng ngày nào."', (tester) async {
      await _pump(tester);
      expect(find.text('Chưa có việc hằng ngày nào.'), findsOneWidget);
    });

    testWidgets('tick: cập nhật lạc quan ngay, PUT log hôm nay, rồi thay bằng routine server trả về', (tester) async {
      final api = await _pump(tester, routines: [mkRoutine('a', 'Uống nước', streak: 1, done: {5})]);
      api.routineGate = Completer();
      await tester.tap(_checkbox('a'));
      await tester.pump();
      expect(_checked(tester, 'a'), isTrue, reason: 'đổi ngay trước khi server trả lời');
      expect(find.text('1 / 1 hôm nay'), findsOneWidget);
      expect(api.routineMarks, ['PUT a']);
      expect(tester.widget<Checkbox>(_checkbox('a')).onChanged, isNull, reason: 'khoá dòng khi đang gửi');
      api.routineGate!.complete();
      await tester.pumpAndSettle();
      expect(_checked(tester, 'a'), isTrue);
      expect(find.text('Hằng ngày · chuỗi 2 ngày'), findsOneWidget);
      expect(tester.widget<Checkbox>(_checkbox('a')).onChanged, isNotNull);

      await tester.tap(_checkbox('a'));
      await tester.pumpAndSettle();
      expect(api.routineMarks, ['PUT a', 'DELETE a']);
      expect(_checked(tester, 'a'), isFalse);
    });

    testWidgets('tick lỗi not_scheduled: câu báo riêng, trả lại bản cũ', (tester) async {
      final api = await _pump(tester, routines: [mkRoutine('a', 'Uống nước')]);
      api.routineError = _badRequest('not_scheduled');
      await tester.tap(_checkbox('a'));
      await tester.pumpAndSettle();
      expect(find.text('Hôm nay không phải ngày của việc này.'), findsWidgets);
      expect(_checked(tester, 'a'), isFalse);
    });

    testWidgets('tick lỗi: trả lại bản cũ và báo lỗi', (tester) async {
      final api = await _pump(tester, routines: [mkRoutine('a', 'Uống nước')]);
      api.routineError = DioException(requestOptions: RequestOptions(path: '/x'), error: 'down');
      await tester.tap(_checkbox('a'));
      await tester.pumpAndSettle();
      expect(_checked(tester, 'a'), isFalse, reason: 'trả lại');
      expect(find.text('0 / 1 hôm nay'), findsOneWidget);
      expect(find.text('Không cập nhật được việc hằng ngày, thử lại nhé.'), findsWidgets);
    });

    testWidgets('bấm tick hai lần liên tiếp chỉ gửi một lần', (tester) async {
      final api = await _pump(tester, routines: [mkRoutine('a', 'Uống nước')]);
      api.routineGate = Completer();
      await tester.tap(_checkbox('a'));
      await tester.pump();
      await tester.tap(_checkbox('a'), warnIfMissed: false);
      await tester.pump();
      expect(api.routineMarks, hasLength(1));
      api.routineGate!.complete();
      await tester.pumpAndSettle();
      expect(api.routineMarks, hasLength(1));
    });
  });

  group('form việc hằng ngày', () {
    Future<void> openAdd(WidgetTester tester) async {
      await tester.tap(find.text('Thêm'));
      await tester.pumpAndSettle();
      expect(find.widgetWithText(AppBar, 'Thêm việc hằng ngày'), findsOneWidget);
    }

    Future<void> openEdit(WidgetTester tester) async {
      await tester.tap(find.byTooltip('Sửa việc hằng ngày'));
      await tester.pumpAndSettle();
      expect(find.widgetWithText(AppBar, 'Sửa việc hằng ngày'), findsOneWidget);
    }

    testWidgets('thêm: mặc định bật cả 7 ngày; tên trống và bỏ hết ngày bị chặn', (tester) async {
      final api = await _pump(tester);
      await openAdd(tester);
      expect(find.byType(FilterChip), findsNWidgets(7));
      expect(tester.widgetList<FilterChip>(find.byType(FilterChip)).every((c) => c.selected), isTrue);
      expect(find.text('Hằng ngày'), findsOneWidget);
      expect(FocusManager.instance.primaryFocus?.context?.widget, isNot(isA<EditableText>()));

      await tester.tap(_saveButton());
      await tester.pumpAndSettle();
      expect(find.text('Nhập tên việc.'), findsOneWidget);
      expect(api.routineCreates, isEmpty);

      await tester.enterText(find.widgetWithText(TextField, 'Tên việc'), 'Đọc sách');
      for (final d in ['T2', 'T3', 'T4', 'T5', 'T6', 'T7', 'CN']) {
        await tester.tap(find.widgetWithText(FilterChip, d));
      }
      await tester.pump();
      expect(find.text('Chưa chọn ngày'), findsOneWidget);
      await tester.tap(_saveButton());
      await tester.pumpAndSettle();
      expect(find.text('Chọn ít nhất một ngày trong tuần.'), findsOneWidget);
      expect(api.routineCreates, isEmpty);
    });

    testWidgets('thêm: chữ lịch lặp cập nhật theo nút; gửi weekdays đã sắp xếp; danh sách làm mới', (tester) async {
      final api = await _pump(tester);
      await openAdd(tester);
      await tester.enterText(find.widgetWithText(TextField, 'Tên việc'), '  Đọc sách ');
      for (final d in ['T3', 'T5', 'T7', 'CN']) {
        await tester.tap(find.widgetWithText(FilterChip, d));
      }
      await tester.pump();
      expect(find.text('T2 · T4 · T6'), findsOneWidget);
      await tester.tap(_saveButton());
      await tester.pumpAndSettle();
      expect(api.routineCreates.single, {'name': 'Đọc sách', 'weekdays': [1, 3, 5]});
      expect(find.byType(Dialog), findsNothing);
      expect(find.text('Đọc sách'), findsOneWidget);
    });

    testWidgets('sửa: chưa đổi thì khoá Lưu; chỉ gửi trường đổi', (tester) async {
      final api = await _pump(tester, routines: [mkRoutine('a', 'Uống nước')]);
      await openEdit(tester);
      expect(tester.widget<FilledButton>(_saveButton()).onPressed, isNull);
      await tester.tap(find.widgetWithText(FilterChip, 'CN'));
      await tester.pump();
      await tester.tap(_saveButton());
      await tester.pumpAndSettle();
      expect(api.routineUpdates.single, {'id': 'a', 'weekdays': [1, 2, 3, 4, 5, 6]});

      await openEdit(tester);
      await tester.enterText(find.widgetWithText(TextField, 'Tên việc'), 'Uống đủ nước');
      await tester.pump();
      await tester.tap(_saveButton());
      await tester.pumpAndSettle();
      expect(api.routineUpdates.last, {'id': 'a', 'name': 'Uống đủ nước'});
      expect(find.text('Uống đủ nước'), findsOneWidget);
    });

    testWidgets('xoá: hộp xác nhận; Huỷ không xoá; Xoá thì xoá và đóng form', (tester) async {
      final api = await _pump(tester, routines: [mkRoutine('a', 'Uống nước')]);
      await openEdit(tester);
      await tester.tap(find.widgetWithText(OutlinedButton, 'Xoá'));
      await tester.pumpAndSettle();
      expect(find.text('Xoá việc này cùng lịch sử đã làm?'), findsOneWidget);
      await tester.tap(find.text('Huỷ'));
      await tester.pumpAndSettle();
      expect(api.routineDeletes, isEmpty);

      await tester.tap(find.widgetWithText(OutlinedButton, 'Xoá'));
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(TextButton, 'Xoá'));
      await tester.pumpAndSettle();
      expect(api.routineDeletes, ['a']);
      expect(find.byType(Dialog), findsNothing);
      expect(find.text('Uống nước'), findsNothing);
      expect(find.text('Chưa có việc hằng ngày nào.'), findsOneWidget);
    });

    testWidgets('khoá Lưu khi đang gửi (bấm hai lần chỉ một request); không tràn khi bàn phím mở ở 390', (tester) async {
      final api = await _pump(tester);
      await openAdd(tester);
      await tester.enterText(find.widgetWithText(TextField, 'Tên việc'), 'Đọc sách');
      tester.view.viewInsets = const FakeViewPadding(bottom: 300);
      addTearDown(tester.view.resetViewInsets);
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      api.routineGate = Completer();
      await tester.tap(_saveButton());
      await tester.pump();
      await tester.tap(_saveButton(), warnIfMissed: false);
      await tester.pump();
      expect(api.routineCreates, hasLength(1));
      api.routineGate!.complete();
      await tester.pumpAndSettle();
      expect(api.routineCreates, hasLength(1));
    });
  });

  group('thẻ Cần chú ý', () {
    testWidgets('hiện tên việc, "dự án · trạng thái", nhãn cảnh báo, số lượng', (tester) async {
      await _pump(tester, attention: [_att('t1', 'Soạn kế hoạch', days: 15), _att('t2', 'Chốt địa điểm', kind: 'IDLE', days: 6, status: 'IN_PROGRESS')]);
      expect(find.text('Cần chú ý'), findsOneWidget);
      expect(find.text('2 việc'), findsOneWidget);
      expect(find.text('Soạn kế hoạch'), findsOneWidget);
      expect(find.text('Sự kiện tháng 11 · Chờ'), findsOneWidget);
      expect(find.text('Sự kiện tháng 11 · Đang làm'), findsOneWidget);
      expect(find.text('Quá hạn 15 ngày'), findsOneWidget);
      expect(find.text('Nằm im 6 ngày'), findsOneWidget);
    });

    testWidgets('trống → "Không có việc nào cần chú ý."', (tester) async {
      await _pump(tester);
      expect(find.text('Không có việc nào cần chú ý.'), findsOneWidget);
      expect(find.text('0 việc'), findsOneWidget);
    });

    testWidgets('chạm một mục → mở màn dự án và trang chi tiết đúng việc', (tester) async {
      await _pump(tester, attention: [_att('t2', 'Việc hai')], tasks: [mkTask('t1', 'Việc một', TaskStatus.prep), mkTask('t2', 'Việc hai', TaskStatus.prep)]);
      await tester.tap(find.byKey(const ValueKey('attention-t2')));
      await tester.pumpAndSettle();
      expect(find.byType(ProjectDetailScreen), findsOneWidget);
      expect(find.widgetWithText(AppBar, 'Chi tiết việc'), findsOneWidget);
      expect(_top(find.text('Việc hai')), findsOneWidget);
      expect(_top(find.text('Việc một')), findsNothing);
    });

    testWidgets('việc không còn tồn tại → chỉ mở màn dự án', (tester) async {
      await _pump(tester, attention: [_att('gone', 'Đã xoá')], tasks: [mkTask('t1', 'Việc một', TaskStatus.prep)]);
      await tester.tap(find.byKey(const ValueKey('attention-gone')));
      await tester.pumpAndSettle();
      expect(find.byType(ProjectDetailScreen), findsOneWidget);
      expect(find.text('Chi tiết việc'), findsNothing);
      expect(find.byType(Dialog), findsNothing);
    });
  });

  group('bố cục', () {
    final routines = [mkRoutine('a', 'Một việc hằng ngày có tên khá dài để thử xuống dòng', weekdays: const [1, 2, 3, 4, 5, 6], streak: 12, done: {1, 2, 3, 4, 5, 6})];
    final attention = [_att('t1', 'Một việc quá hạn có tên cũng khá dài để thử cắt hai dòng thôi nhé', days: 120)];

    testWidgets('390: xếp dọc, "Việc hằng ngày" trước "Cần chú ý"; không tràn', (tester) async {
      await _pump(tester, routines: routines, attention: attention);
      expect(tester.takeException(), isNull);
      final r = tester.getTopLeft(find.text('Việc hằng ngày'));
      final a = tester.getTopLeft(find.text('Cần chú ý'));
      expect(a.dy, greaterThan(r.dy));
      expect(a.dx, r.dx);
    });

    testWidgets('1200: hai thẻ cạnh nhau; không tràn', (tester) async {
      await _pump(tester, routines: routines, attention: attention, width: 1200);
      expect(tester.takeException(), isNull);
      Offset cardOf(String title) => tester.getTopLeft(find.ancestor(of: find.text(title), matching: find.byType(ScrollCard)).first);
      final r = cardOf('Việc hằng ngày');
      final a = cardOf('Cần chú ý');
      expect(a.dy, r.dy, reason: 'cùng hàng');
      expect(a.dx, greaterThan(r.dx + 200));
    });

    testWidgets('khu "Dự án" vẫn nằm bên dưới', (tester) async {
      await _pump(tester, routines: routines, attention: attention);
      expect(tester.getTopLeft(find.text('Thêm dự án')).dy, greaterThan(tester.getTopLeft(find.text('Cần chú ý')).dy));
    });
  });
}

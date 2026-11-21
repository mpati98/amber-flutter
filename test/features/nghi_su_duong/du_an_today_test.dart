import 'dart:async';

import 'package:amber_flutter/features/nghi_su_duong/models/routine.dart';
import 'package:amber_flutter/features/nghi_su_duong/widgets/routines_card.dart';
import 'package:dio/dio.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';


import 'detail_test_support.dart';
import 'nsd_screen_support.dart';

// Thẻ "Việc hằng ngày" (khung Hôm nay của màn Nghị Sự Đường). API giả. Cần chú ý: nghi_su_duong_screen_test.dart.

DioException _badRequest(String code) {
  final req = RequestOptions(path: '/api/du-an/routines/x/logs/2026-10-08');
  return DioException(
    requestOptions: req,
    type: DioExceptionType.badResponse,
    response: Response(requestOptions: req, statusCode: 400, data: {'error': code}),
  );
}

/// Màn Nghị Sự Đường ở web rộng và cao: khung "Hôm nay" đủ chỗ cho mọi dòng việc hằng ngày.
Future<FakeApi> _pump(WidgetTester tester, {List<Routine> routines = const []}) async {
  final api = FakeApi(project: mkProject(), tasks: [])..routines = [...routines];
  await pumpNsd(tester, api: api, size: const Size(1280, 2400));
  return api;
}

Finder _row(String id) => find.byKey(ValueKey('routine-$id'));
Finder _checkbox(String id) => find.descendant(of: _row(id), matching: find.byType(Checkbox));
bool _checked(WidgetTester t, String id) => t.widget<Checkbox>(_checkbox(id)).value!;
Finder _saveButton() => find.byType(FilledButton).last;


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
      expect(api.routineCreates.single, {'name': 'Đọc sách', 'weekdays': [1, 3, 5], 'kind': 'CHECK'});
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
}

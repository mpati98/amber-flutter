import 'dart:async';

import 'package:amber_flutter/features/nghi_su_duong/models/key_result.dart';
import 'package:amber_flutter/features/nghi_su_duong/models/task.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'detail_test_support.dart';

// Trang chi tiết việc + form việc (thêm / sửa). API giả.

DioException _badRequest(String code) {
  final req = RequestOptions(path: '/api/tasks');
  return DioException(
    requestOptions: req,
    type: DioExceptionType.badResponse,
    response: Response(requestOptions: req, statusCode: 400, data: {'error': code}),
  );
}

final _krs = [mkKr('k1', 'Bán vé', target: 4), mkKr('k2', 'Truyền thông', mode: KrMode.auto)];

Task _full({
  String id = 'a',
  String? description = 'Dòng một\nDòng hai',
  List<ChecklistItem> checklist = const [
    ChecklistItem(id: 'c1', text: 'Mục một', done: true, position: 0),
    ChecklistItem(id: 'c2', text: 'Mục hai', done: false, position: 1),
  ],
}) =>
    Task(
      id: id,
      projectId: 'p1',
      krId: 'k2',
      title: 'Soạn kế hoạch',
      description: description,
      status: TaskStatus.inProgress,
      importance: 2,
      urgency: 2,
      durationMinutes: 15,
      startDate: '2026-10-06',
      dueDate: '2026-10-20',
      isMilestone: true,
      notifyDeadline: true,
      prepLeadDays: 5,
      checklistItems: checklist,
      attention: const TaskAttention(kind: 'OVERDUE', days: 2),
      createdAt: DateTime.utc(2026, 10, 1),
    );

Future<FakeApi> _openDetail(WidgetTester tester, {Task? task, double width = 390}) async {
  final api = await pumpDetail(tester, project: mkProject(krs: _krs), tasks: [task ?? _full()], width: width);
  await tester.tap(find.text('Soạn kế hoạch'));
  await tester.pumpAndSettle();
  return api;
}

Finder _field(String label) => find.widgetWithText(TextField, label);
/// Form nằm trên cùng (route sau cùng) nên nút Lưu là FilledButton cuối.
Finder _saveButton() => find.byType(FilledButton).last;

/// Chỉ tìm trong hộp thoại trên cùng (bảng việc phía dưới cũng có chữ trùng).
Finder _top(Finder f) => find.descendant(of: find.byType(Dialog).last, matching: f);
bool _canSave(WidgetTester tester) => tester.widget<FilledButton>(_saveButton()).onPressed != null;
Switch _switchOf(WidgetTester tester, String title) =>
    tester.widget<Switch>(find.descendant(of: find.widgetWithText(SwitchListTile, title), matching: find.byType(Switch)));

Future<void> _openEditForm(WidgetTester tester) async {
  await tester.tap(find.widgetWithText(FilledButton, 'Sửa'));
  await tester.pumpAndSettle();
  expect(find.widgetWithText(AppBar, 'Sửa việc'), findsOneWidget);
}

Future<void> _openNewForm(WidgetTester tester) async {
  await tester.tap(find.text('Thêm việc'));
  await tester.pumpAndSettle();
  expect(find.widgetWithText(AppBar, 'Thêm việc'), findsOneWidget);
}

void main() {
  group('trang chi tiết việc', () {
    testWidgets('hiện đủ các dòng thông tin, nội dung, checklist', (tester) async {
      await _openDetail(tester);
      expect(find.widgetWithText(AppBar, 'Chi tiết việc'), findsOneWidget);
      expect(find.text('KR 2 · Truyền thông'), findsOneWidget);
      expect(_top(find.text('Quá hạn 2 ngày')), findsOneWidget);
      for (final (label, value) in [
        ('Trạng thái', 'Đang làm'),
        ('Bắt đầu', '06/10'),
        ('Hạn', '20/10'),
        ('Loại', 'Mốc'),
        ('Thông báo hạn', 'Báo trước 5 ngày'),
      ]) {
        expect(_top(find.text(label)), findsOneWidget, reason: label);
        expect(_top(find.text(value)), findsOneWidget, reason: value);
      }
      expect(find.text('Dòng một\nDòng hai'), findsOneWidget, reason: 'giữ xuống dòng');
      expect(_top(find.text('1 / 2')), findsOneWidget);
      expect(find.text('Mục một'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('trường trống: "Chưa có", "Việc", "Tắt", mặc định 3 ngày, "Chưa có nội dung.", "Chưa có mục nào."', (tester) async {
      await _openDetail(
        tester,
        task: mkTask('a', 'Soạn kế hoạch', TaskStatus.prep),
      );
      expect(find.text('Không gắn KR'), findsWidgets);
      expect(find.text('Chưa có'), findsNWidgets(2));
      expect(find.text('Việc'), findsOneWidget);
      expect(find.text('Tắt'), findsOneWidget);
      expect(find.text('Chưa có nội dung.'), findsOneWidget);
      expect(find.text('Chưa có mục nào.'), findsOneWidget);
      expect(find.text('0 / 0'), findsOneWidget);
    });

    testWidgets('thông báo bật mà chưa đặt prepLeadDays → "Báo trước 3 ngày"', (tester) async {
      final t = Task(
        id: 'a', projectId: 'p1', title: 'Soạn kế hoạch', status: TaskStatus.prep, importance: 2, urgency: 2,
        durationMinutes: 15, dueDate: '2026-10-20', notifyDeadline: true,
      );
      await _openDetail(tester, task: t);
      expect(find.text('Báo trước 3 ngày'), findsOneWidget);
    });

    testWidgets('tick một mục: PATCH đúng, số đếm đổi ngay (lạc quan)', (tester) async {
      final api = await _openDetail(tester);
      api.gate = Completer();
      await tester.tap(find.byKey(const ValueKey('check-c2')));
      await tester.pump();
      expect(_top(find.text('2 / 2')), findsOneWidget, reason: 'đổi ngay khi chưa có trả lời');
      expect(api.checklistPatches.single, {'taskId': 'a', 'itemId': 'c2', 'done': true, 'text': null});
      // khoá trong lúc gửi: chạm lại không gửi thêm
      await tester.tap(find.byKey(const ValueKey('check-c2')), warnIfMissed: false);
      await tester.pump();
      expect(api.checklistPatches, hasLength(1));
      api.gate!.complete();
      await tester.pumpAndSettle();
      expect(_top(find.text('2 / 2')), findsOneWidget);
      expect(api.checklistPatches, hasLength(1));
    });

    testWidgets('tick lỗi: trả lại trạng thái cũ và báo lỗi', (tester) async {
      final api = await _openDetail(tester);
      api.checklistPatchError = DioException(requestOptions: RequestOptions(path: '/x'), error: 'down');
      await tester.tap(find.byKey(const ValueKey('check-c2')));
      await tester.pumpAndSettle();
      expect(_top(find.text('1 / 2')), findsOneWidget, reason: 'trả lại');
      expect(find.text('Không cập nhật được mục checklist, thử lại nhé.'), findsWidgets);
    });

    testWidgets('Xoá việc: hộp xác nhận; Huỷ không xoá; Xoá thì xoá, đóng trang, thẻ biến mất', (tester) async {
      final api = await _openDetail(tester);
      await tester.tap(find.text('Xoá việc'));
      await tester.pumpAndSettle();
      expect(find.text('Xoá việc này cùng nội dung và checklist?'), findsOneWidget);
      await tester.tap(find.text('Huỷ'));
      await tester.pumpAndSettle();
      expect(api.taskDeletes, isEmpty);
      expect(find.widgetWithText(AppBar, 'Chi tiết việc'), findsOneWidget);

      await tester.tap(find.text('Xoá việc'));
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(TextButton, 'Xoá'));
      await tester.pumpAndSettle();
      expect(api.taskDeletes, ['a']);
      expect(find.byType(Dialog), findsNothing);
      expect(find.text('Soạn kế hoạch'), findsNothing);
    });

    testWidgets('Sửa → lưu → quay về trang chi tiết với dữ liệu mới', (tester) async {
      final api = await _openDetail(tester);
      await _openEditForm(tester);
      await tester.enterText(_field('Tên việc'), 'Tên mới');
      await tester.pump();
      await tester.tap(_saveButton());
      await tester.pumpAndSettle();
      expect(api.taskUpdates.single, {'id': 'a', 'title': 'Tên mới'});
      expect(find.widgetWithText(AppBar, 'Chi tiết việc'), findsOneWidget);
      expect(find.text('Tên mới'), findsWidgets);
    });
  });

  group('form việc — sửa', () {
    testWidgets('không đổi gì thì Lưu khoá, không gọi API', (tester) async {
      final api = await _openDetail(tester);
      await _openEditForm(tester);
      expect(_canSave(tester), isFalse);
      expect(api.taskUpdates, isEmpty);
      expect(api.checklistPuts, isEmpty);
      expect(FocusManager.instance.primaryFocus?.context?.widget, isNot(isA<EditableText>()), reason: 'không autofocus');
    });

    testWidgets('chỉ gửi trường đã đổi; checklist không đổi thì không gọi PUT', (tester) async {
      final api = await _openDetail(tester);
      await _openEditForm(tester);
      await tester.tap(find.widgetWithText(ChoiceChip, 'Thẩm định'));
      await tester.tap(find.widgetWithText(SwitchListTile, 'Là mốc'));
      await tester.pump();
      expect(_canSave(tester), isTrue);
      await tester.tap(_saveButton());
      await tester.pumpAndSettle();
      expect(api.taskUpdates.single, {'id': 'a', 'status': 'REVIEW', 'isMilestone': false});
      expect(api.checklistPuts, isEmpty);
    });

    testWidgets('chỉ sửa checklist: gọi PUT, không PATCH; mục để trống bị bỏ; id mục cũ được giữ', (tester) async {
      final api = await _openDetail(tester);
      await _openEditForm(tester);
      await tester.tap(find.text('Thêm mục'));
      await tester.pump();
      await tester.tap(find.text('Thêm mục'));
      await tester.pump();
      final fields = find.widgetWithText(TextField, '');
      expect(fields, findsWidgets);
      await tester.enterText(find.byType(TextField).at(find.byType(TextField).evaluate().length - 2), 'Mục ba');
      await tester.pump();
      await tester.tap(find.byTooltip('Xoá mục').first); // bỏ "Mục một"
      await tester.pump();
      await tester.tap(_saveButton());
      await tester.pumpAndSettle();
      expect(api.taskUpdates, isEmpty);
      expect(api.checklistPuts.single, [
        {'id': 'c2', 'text': 'Mục hai', 'done': false},
        {'id': null, 'text': 'Mục ba', 'done': false},
      ]);
    });

    testWidgets('xoá Hạn → công tắc thông báo tự tắt; gửi dueDate null và notifyDeadline false', (tester) async {
      final api = await _openDetail(tester);
      await _openEditForm(tester);
      expect(_switchOf(tester, 'Thông báo hạn').value, isTrue);
      expect(find.text('Báo trước (ngày)'), findsOneWidget);
      await tester.tap(find.byTooltip('Xoá ngày hạn'));
      await tester.pump();
      expect(_switchOf(tester, 'Thông báo hạn').value, isFalse);
      expect(_switchOf(tester, 'Thông báo hạn').onChanged, isNull, reason: 'khoá khi chưa có hạn');
      expect(find.text('Báo trước (ngày)'), findsNothing);
      await tester.tap(_saveButton());
      await tester.pumpAndSettle();
      expect(api.taskUpdates.single, {'id': 'a', 'dueDate': null, 'notifyDeadline': false});
    });

    testWidgets('đổi số ngày báo trước và nội dung; xoá nội dung gửi null', (tester) async {
      final api = await _openDetail(tester);
      await _openEditForm(tester);
      await tester.enterText(_field('Báo trước (ngày)'), '10');
      await tester.enterText(_field('Nội dung'), '   ');
      await tester.pump();
      await tester.tap(_saveButton());
      await tester.pumpAndSettle();
      expect(api.taskUpdates.single, {'id': 'a', 'prepLeadDays': 10, 'description': null});
    });

    testWidgets('báo trước ngoài 0–60 → báo lỗi, không gửi', (tester) async {
      final api = await _openDetail(tester);
      await _openEditForm(tester);
      await tester.enterText(_field('Báo trước (ngày)'), '99');
      await tester.pump();
      await tester.tap(_saveButton());
      await tester.pumpAndSettle();
      expect(find.text('Báo trước từ 0 đến 60 ngày.'), findsOneWidget);
      expect(api.taskUpdates, isEmpty);
    });

    testWidgets('gắn KR: dropdown có "Không gắn" và từng KR', (tester) async {
      final api = await _openDetail(tester);
      await _openEditForm(tester);
      await tester.tap(find.byType(DropdownButtonFormField<String?>));
      await tester.pumpAndSettle();
      expect(find.text('Không gắn'), findsOneWidget);
      expect(find.text('KR 1 · Bán vé'), findsOneWidget);
      await tester.tap(find.text('Không gắn').last);
      await tester.pumpAndSettle();
      await tester.tap(_saveButton());
      await tester.pumpAndSettle();
      expect(api.taskUpdates.single, {'id': 'a', 'krId': null});
    });
  });

  group('form việc — thêm', () {
    testWidgets('tên trống → "Nhập tên việc.", không gửi', (tester) async {
      final api = await pumpDetail(tester, project: mkProject(krs: _krs));
      await _openNewForm(tester);
      expect(find.text('Không gắn'), findsWidgets);
      await tester.tap(_saveButton());
      await tester.pumpAndSettle();
      expect(find.text('Nhập tên việc.'), findsOneWidget);
      expect(api.taskCreates, isEmpty);
    });

    testWidgets('công tắc thông báo khoá khi chưa có Hạn', (tester) async {
      await pumpDetail(tester);
      await _openNewForm(tester);
      expect(_switchOf(tester, 'Thông báo hạn').onChanged, isNull);
      expect(_switchOf(tester, 'Thông báo hạn').value, isFalse);
    });

    testWidgets('không có ô độ quan trọng; mặc định trạng thái Chờ', (tester) async {
      await pumpDetail(tester);
      await _openNewForm(tester);
      expect(find.text('Mức quan trọng'), findsNothing);
      expect(tester.widget<ChoiceChip>(find.widgetWithText(ChoiceChip, 'Chờ')).selected, isTrue);
    });

    testWidgets('thêm có checklist: POST rồi PUT; mục trống bị bỏ; đóng form', (tester) async {
      final api = await pumpDetail(tester);
      await _openNewForm(tester);
      await tester.enterText(_field('Tên việc'), '  Việc mới ');
      await tester.enterText(_field('Nội dung'), 'Ghi chú');
      await tester.tap(find.text('Thêm mục'));
      await tester.pump();
      await tester.tap(find.text('Thêm mục'));
      await tester.pump();
      final boxes = find.byType(TextField);
      final n = boxes.evaluate().length;
      await tester.enterText(boxes.at(n - 2), 'Mục A');
      await tester.pump();
      await tester.tap(_saveButton());
      await tester.pumpAndSettle();
      expect(api.taskCreates.single['title'], 'Việc mới');
      expect(api.taskCreates.single['description'], 'Ghi chú');
      expect(api.taskCreates.single['status'], TaskStatus.prep);
      expect(api.checklistPuts.single, [
        {'id': null, 'text': 'Mục A', 'done': false},
      ]);
      expect(find.byType(Dialog), findsNothing);
      expect(find.text('Việc mới'), findsOneWidget);
    });

    testWidgets('thêm không checklist: chỉ POST, không PUT', (tester) async {
      final api = await pumpDetail(tester);
      await _openNewForm(tester);
      await tester.enterText(_field('Tên việc'), 'Chỉ việc');
      await tester.pump();
      await tester.tap(_saveButton());
      await tester.pumpAndSettle();
      expect(api.taskCreates, hasLength(1));
      expect(api.checklistPuts, isEmpty);
    });

    testWidgets('POST được mà PUT lỗi: giữ form, chuyển sang sửa việc vừa tạo; Lưu lại chỉ gửi PUT', (tester) async {
      final api = await pumpDetail(tester);
      await _openNewForm(tester);
      await tester.enterText(_field('Tên việc'), 'Việc mới');
      await tester.tap(find.text('Thêm mục'));
      await tester.pump();
      await tester.enterText(find.byType(TextField).at(find.byType(TextField).evaluate().length - 1), 'Mục A');
      await tester.pump();
      api.checklistPutError = DioException(requestOptions: RequestOptions(path: '/x'), error: 'down');
      await tester.tap(_saveButton());
      await tester.pumpAndSettle();
      expect(find.text('Đã lưu việc nhưng chưa lưu được checklist. Bấm Lưu để thử lại.'), findsOneWidget);
      expect(find.widgetWithText(AppBar, 'Sửa việc'), findsOneWidget, reason: 'chuyển sang chế độ sửa');
      expect(api.taskCreates, hasLength(1));
      expect(find.text('Việc mới'), findsWidgets, reason: 'bảng đã được làm mới với việc vừa tạo');

      api.checklistPutError = null;
      await tester.tap(_saveButton());
      await tester.pumpAndSettle();
      expect(api.taskCreates, hasLength(1), reason: 'không tạo lại việc');
      expect(api.taskUpdates, isEmpty, reason: 'không PATCH khi trường không đổi');
      expect(api.checklistPuts, hasLength(2));
      expect(find.byType(Dialog), findsNothing);
    });

    testWidgets('lỗi end_before_start và notify_requires_due_date → đúng câu báo', (tester) async {
      final api = await pumpDetail(tester);
      await _openNewForm(tester);
      await tester.enterText(_field('Tên việc'), 'Việc');
      await tester.pump();
      api.taskCreateError = _badRequest('end_before_start');
      await tester.tap(_saveButton());
      await tester.pumpAndSettle();
      expect(find.text('Hạn phải sau ngày bắt đầu.'), findsOneWidget);
      api.taskCreateError = _badRequest('notify_requires_due_date');
      await tester.tap(_saveButton());
      await tester.pumpAndSettle();
      expect(find.text('Cần có hạn để bật thông báo.'), findsOneWidget);
      expect(find.text('Hạn phải sau ngày bắt đầu.'), findsNothing);
      expect(find.widgetWithText(AppBar, 'Thêm việc'), findsOneWidget, reason: 'form vẫn mở');
    });

    testWidgets('bấm Lưu hai lần chỉ gửi một lần', (tester) async {
      final api = await pumpDetail(tester);
      await _openNewForm(tester);
      await tester.enterText(_field('Tên việc'), 'Việc');
      await tester.pump();
      api.gate = Completer();
      await tester.tap(_saveButton());
      await tester.pump();
      expect(_canSave(tester), isFalse, reason: 'khoá trong lúc gửi');
      await tester.tap(_saveButton(), warnIfMissed: false);
      await tester.pump();
      expect(api.taskCreates, hasLength(1));
      api.gate!.complete();
      await tester.pumpAndSettle();
      expect(api.taskCreates, hasLength(1));
    });

    testWidgets('chặn ở 50 mục checklist', (tester) async {
      await pumpDetail(tester);
      await _openNewForm(tester);
      for (var i = 0; i < 50; i++) {
        await tester.tap(find.text('Thêm mục'));
        await tester.pump();
      }
      expect(find.text('Tối đa 50 mục'), findsOneWidget);
      expect(tester.widget<TextButton>(find.widgetWithText(TextButton, 'Tối đa 50 mục')).onPressed, isNull);
    });

    testWidgets('bề rộng 390: không tràn, kể cả khi bàn phím mở', (tester) async {
      await pumpDetail(tester, project: mkProject(krs: _krs));
      await _openNewForm(tester);
      tester.view.viewInsets = const FakeViewPadding(bottom: 300);
      addTearDown(tester.view.resetViewInsets);
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    });
  });
}

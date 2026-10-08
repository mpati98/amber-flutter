import 'dart:async';

import 'package:amber_flutter/features/nghi_su_duong/models/finance_category.dart';
import 'package:amber_flutter/features/nghi_su_duong/models/task.dart';
import 'package:amber_flutter/features/nghi_su_duong/utils/project_finance.dart';
import 'package:amber_flutter/features/nghi_su_duong/widgets/project_finance_tab.dart';
import 'package:amber_flutter/features/nghi_su_duong/widgets/project_transaction_form.dart';
import 'package:amber_flutter/shared/utils/date_format.dart';
import 'package:amber_flutter/shared/utils/vn_time.dart';
import 'package:amber_flutter/shared/widgets/scroll_card.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'detail_test_support.dart';

// Tab Thu-chi + thẻ Thu-chi ở đầu trang + form giao dịch. API giả.

DioException _badRequest(String code) {
  final req = RequestOptions(path: '/api/finance/transactions');
  return DioException(
    requestOptions: req,
    type: DioExceptionType.badResponse,
    response: Response(requestOptions: req, statusCode: 400, data: {'error': code}),
  );
}

String _dm(DateTime at) => formatDayMonth(vnToday(at));

final _txs = [
  mkTx('t1', amount: 100000, note: 'Thuê loa', categoryId: 'c-rent', accountId: 'w1'),
  mkTx('t2', kind: MoneyKind.income, amount: 500000, categoryId: 'c-sal', accountId: 'w2'),
  mkTx('t3', amount: 20000),
];

Future<(FakeApi, FakeFinanceApi)> _pump(WidgetTester tester, {FakeFinanceApi? fin, double width = 390}) async {
  final f = fin ?? FakeFinanceApi(transactions: _txs);
  final api = await pumpDetail(tester, finance: f, width: width, project: mkProject(krs: [mkKr('k1', 'Bán vé', target: 4)]));
  return (api, f);
}

Future<void> _openFinanceTab(WidgetTester tester) async {
  await tester.tap(find.widgetWithText(ChoiceChip, 'Thu-chi'));
  await tester.pumpAndSettle();
}

Finder _saveButton() => find.byType(FilledButton).last;
bool _canSave(WidgetTester tester) => tester.widget<FilledButton>(_saveButton()).onPressed != null;
Finder _field(String label) => find.widgetWithText(TextField, label);

Future<void> _openAddForm(WidgetTester tester) async {
  await _openFinanceTab(tester);
  await tester.tap(find.text('Thêm giao dịch'));
  await tester.pumpAndSettle();
  expect(find.widgetWithText(AppBar, 'Thêm giao dịch'), findsOneWidget);
}

Future<void> _openEditForm(WidgetTester tester, String id) async {
  await _openFinanceTab(tester);
  await tester.tap(find.descendant(of: find.byKey(ValueKey('tx-$id')), matching: find.byTooltip('Sửa giao dịch')));
  await tester.pumpAndSettle();
  expect(find.widgetWithText(AppBar, 'Sửa giao dịch'), findsOneWidget);
}

void main() {
  group('hàm thuần', () {
    test('FinanceTotals: thu, chi, ròng (có thể âm)', () {
      final t = FinanceTotals.of(_txs);
      expect((t.income, t.expense, t.net), (500000, 120000, 380000));
      final neg = FinanceTotals.of([mkTx('x', amount: 100000)]);
      expect(neg.net, -100000);
      expect(FinanceTotals.of(const []).net, 0);
    });

    test('signedMoney: +…₫ cho Thu, −…₫ cho Chi', () {
      expect(signedMoney(MoneyKind.income, 500000), '+500.000₫');
      expect(signedMoney(MoneyKind.expense, 100000), '−100.000₫');
    });

    test('tiêu đề / dòng phụ của giao dịch', () {
      final a = mkTx('a', note: '  Thuê loa ', categoryId: 'c-rent');
      expect(transactionTitle(a), 'Thuê loa');
      expect(transactionTitle(mkTx('b', categoryId: 'c-food')), 'Ăn uống');
      expect(transactionTitle(mkTx('c')), 'Giao dịch');
      expect(transactionTitle(mkTx('d', note: '   ', categoryId: 'c-food')), 'Ăn uống');
      expect(transactionSubtitle(a), '${_dm(a.occurredAt)} · Chi · Thuê địa điểm · Tiền mặt');
      expect(transactionSubtitle(mkTx('e', kind: MoneyKind.income, accountId: 'w2')), '${_dm(DateTime.now())} · Thu · Momo');
    });

    test('occurredAtFor: hôm nay → lúc này; ngày khác → 12:00 giờ VN (05:00Z)', () {
      final now = DateTime.utc(2026, 10, 8, 3, 30); // 10:30 giờ VN ngày 08/10
      expect(occurredAtFor('2026-10-08', now: now), now);
      expect(occurredAtFor('2026-10-03', now: now), DateTime.utc(2026, 10, 3, 5));
      // Qua nửa đêm giờ VN: 18:00Z ngày 7/10 đã là 01:00 ngày 8/10 ở VN.
      final late = DateTime.utc(2026, 10, 7, 18);
      expect(occurredAtFor('2026-10-08', now: late), late);
      expect(occurredAtFor('2026-10-07', now: late), DateTime.utc(2026, 10, 7, 5));
    });
  });

  group('thẻ ở đầu trang', () {
    testWidgets('Thu, Chi, Ròng, số giao dịch; "Xem và sửa" chuyển sang tab Thu-chi', (tester) async {
      await _pump(tester);
      expect(find.text('Thu-chi của dự án'), findsOneWidget);
      expect(find.text('3 giao dịch gắn với dự án'), findsOneWidget);
      expect(find.text('500.000₫'), findsOneWidget);
      expect(find.text('120.000₫'), findsOneWidget);
      expect(find.text('380.000₫'), findsOneWidget);
      expect(tester.widget<ChoiceChip>(find.widgetWithText(ChoiceChip, 'Bảng')).selected, isTrue);

      await tester.tap(find.text('Xem và sửa'));
      await tester.pumpAndSettle();
      expect(tester.widget<ChoiceChip>(find.widgetWithText(ChoiceChip, 'Thu-chi')).selected, isTrue);
      expect(find.text('Thuê loa'), findsOneWidget);
    });

    testWidgets('ròng âm có dấu trừ', (tester) async {
      await _pump(tester, fin: FakeFinanceApi(transactions: [mkTx('x', amount: 100000)]));
      expect(find.text('-100.000₫'), findsOneWidget);
    });

    testWidgets('390: thẻ nằm dưới khối KR; 1200: cạnh khối KR; không tràn', (tester) async {
      await _pump(tester);
      expect(tester.takeException(), isNull);
      expect(tester.getTopLeft(find.text('Thu-chi của dự án')).dy, greaterThan(tester.getTopLeft(find.text('Kết quả then chốt')).dy));
      expect(tester.getTopLeft(find.text('Thu-chi của dự án')).dx, tester.getTopLeft(find.text('Kết quả then chốt')).dx);

      await _pump(tester, width: 1200);
      expect(tester.takeException(), isNull);
      Offset cardOf(String title) => tester.getTopLeft(find.ancestor(of: find.text(title), matching: find.byType(ScrollCard)).first);
      expect(cardOf('Thu-chi của dự án').dy, cardOf('Kết quả then chốt').dy, reason: 'cùng hàng');
      expect(cardOf('Thu-chi của dự án').dx, greaterThan(cardOf('Kết quả then chốt').dx));
    });
  });

  group('tab Thu-chi', () {
    testWidgets('ẩn "x / y việc xong" và "Thêm việc", có "Thêm giao dịch"; đổi lại Bảng thì hiện lại', (tester) async {
      await pumpDetail(tester, tasks: [mkTask('a', 'A', TaskStatus.done)], finance: FakeFinanceApi(transactions: _txs));
      expect(find.text('1 / 1 việc xong'), findsOneWidget);
      expect(find.text('Thêm việc'), findsOneWidget);
      await _openFinanceTab(tester);
      expect(find.text('1 / 1 việc xong'), findsNothing);
      expect(find.text('Thêm việc'), findsNothing);
      expect(find.text('Thêm giao dịch'), findsOneWidget);
      await tester.tap(find.widgetWithText(ChoiceChip, 'Bảng'));
      await tester.pumpAndSettle();
      expect(find.text('1 / 1 việc xong'), findsOneWidget);
      expect(find.text('Thêm giao dịch'), findsNothing);
    });

    testWidgets('dòng tổng và danh sách: dòng chính, dòng phụ, số tiền + / −', (tester) async {
      await _pump(tester);
      await _openFinanceTab(tester);
      expect(find.byKey(const ValueKey('total-Thu')), findsOneWidget);
      expect(tester.widget<Text>(find.byKey(const ValueKey('total-Thu'))).data, '500.000₫');
      expect(tester.widget<Text>(find.byKey(const ValueKey('total-Chi'))).data, '120.000₫');
      expect(tester.widget<Text>(find.byKey(const ValueKey('total-Ròng'))).data, '380.000₫');
      final today = _dm(DateTime.now());
      expect(find.text('Thuê loa'), findsOneWidget);
      expect(find.text('$today · Chi · Thuê địa điểm · Tiền mặt'), findsOneWidget);
      expect(find.text('Lương'), findsOneWidget, reason: 'không có ghi chú → tên danh mục');
      expect(find.text('Giao dịch'), findsOneWidget, reason: 'không ghi chú, không danh mục');
      expect(find.text('+500.000₫'), findsOneWidget);
      expect(find.text('−100.000₫'), findsOneWidget);
      // thứ tự giữ nguyên như API (mới trước)
      final ys = [for (final id in ['t1', 't2', 't3']) tester.getTopLeft(find.byKey(ValueKey('tx-$id'))).dy];
      expect(ys, orderedEquals([...ys]..sort()));
      expect(tester.takeException(), isNull);
    });

    testWidgets('trống → "Chưa có giao dịch nào gắn với dự án này."', (tester) async {
      await _pump(tester, fin: FakeFinanceApi());
      await _openFinanceTab(tester);
      expect(find.text('Chưa có giao dịch nào gắn với dự án này.'), findsOneWidget);
    });

    testWidgets('xoá: hộp xác nhận; Huỷ không xoá; Xoá thì xoá và danh sách cập nhật', (tester) async {
      final (_, fin) = await _pump(tester);
      await _openFinanceTab(tester);
      Future<void> tapDelete() => tester.tap(find.descendant(of: find.byKey(const ValueKey('tx-t1')), matching: find.byTooltip('Xoá giao dịch')));
      await tapDelete();
      await tester.pumpAndSettle();
      expect(find.text('Xoá giao dịch này? Số dư ví sẽ được hoàn lại.'), findsOneWidget);
      await tester.tap(find.text('Huỷ'));
      await tester.pumpAndSettle();
      expect(fin.deletes, isEmpty);

      await tapDelete();
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(TextButton, 'Xoá'));
      await tester.pumpAndSettle();
      expect(fin.deletes, ['t1']);
      expect(find.text('Thuê loa'), findsNothing);
      expect(find.text('2 giao dịch gắn với dự án'), findsOneWidget, reason: 'thẻ ở đầu trang cũng cập nhật');
    });
  });

  group('form thêm', () {
    testWidgets('mặc định Chi, ví đầu tiên, hôm nay; không autofocus', (tester) async {
      await _pump(tester, fin: FakeFinanceApi());
      await _openAddForm(tester);
      expect(tester.widget<ChoiceChip>(find.widgetWithText(ChoiceChip, 'Chi')).selected, isTrue);
      expect(find.text('Tiền mặt'), findsOneWidget, reason: 'ví đầu tiên được chọn sẵn');
      final today = vnToday();
      expect(find.text('Ngày: ${formatDayMonth(today)}/${today.substring(0, 4)}'), findsOneWidget);
      expect(FocusManager.instance.primaryFocus?.context?.widget, isNot(isA<EditableText>()));
    });

    testWidgets('số tiền 0 hoặc trống bị chặn; thiếu ví bị chặn', (tester) async {
      await _pump(tester, fin: FakeFinanceApi());
      await _openAddForm(tester);
      expect(_canSave(tester), isFalse, reason: 'chưa nhập số tiền');
      await tester.enterText(_field('Số tiền (VND)'), '0');
      await tester.pump();
      expect(_canSave(tester), isFalse);
      await tester.enterText(_field('Số tiền (VND)'), '50000');
      await tester.pump();
      expect(_canSave(tester), isTrue);
    });

    testWidgets('không có ví → báo, Lưu khoá', (tester) async {
      final fin = FakeFinanceApi(accounts: const []);
      await _pump(tester, fin: fin);
      await _openAddForm(tester);
      await tester.enterText(_field('Số tiền (VND)'), '50000');
      await tester.pump();
      expect(find.text('Chưa có ví nào — tạo ví trước đã.'), findsOneWidget);
      expect(_canSave(tester), isFalse);
    });

    testWidgets('danh mục chỉ hiện loại đang chọn; đổi loại bỏ danh mục không cùng loại', (tester) async {
      await _pump(tester, fin: FakeFinanceApi());
      await _openAddForm(tester);
      Future<void> openCategories() async {
        await tester.tap(find.byType(DropdownButtonFormField<String?>));
        await tester.pumpAndSettle();
      }

      await openCategories();
      expect(find.text('🍜 Ăn uống'), findsOneWidget);
      expect(find.text('Thuê địa điểm'), findsOneWidget);
      expect(find.text('💰 Lương'), findsNothing, reason: 'danh mục thu không hiện khi đang Chi');
      await tester.tap(find.text('🍜 Ăn uống').last);
      await tester.pumpAndSettle();

      await tester.tap(find.widgetWithText(ChoiceChip, 'Thu'));
      await tester.pumpAndSettle();
      expect(find.text('🍜 Ăn uống'), findsNothing, reason: 'đã bỏ chọn danh mục khác loại');
      expect(find.text('Chưa phân loại'), findsOneWidget);
      await openCategories();
      expect(find.text('💰 Lương'), findsOneWidget);
      expect(find.text('🍜 Ăn uống'), findsNothing);
    });

    testWidgets('ngày chỉ chọn được từ ngày 1 của tháng hiện tại tới hôm nay (giờ VN)', (tester) async {
      await _pump(tester, fin: FakeFinanceApi());
      await _openAddForm(tester);
      await tester.tap(find.textContaining('Ngày: '));
      await tester.pumpAndSettle();
      final picker = tester.widget<CalendarDatePicker>(find.byType(CalendarDatePicker));
      final today = vnToday();
      expect(picker.firstDate, DateTime.parse('${today.substring(0, 8)}01'));
      expect(picker.lastDate, DateTime.parse(today));
    });

    testWidgets('lưu: POST không có projectId, có linkedProjectId; hôm nay gửi lúc này; làm mới danh sách', (tester) async {
      final (_, fin) = await _pump(tester, fin: FakeFinanceApi());
      await _openAddForm(tester);
      await tester.enterText(_field('Số tiền (VND)'), '100000');
      await tester.enterText(_field('Ghi chú (tuỳ chọn)'), '  Thuê loa  ');
      await tester.pump();
      final before = DateTime.now();
      await tester.tap(_saveButton());
      await tester.pumpAndSettle();
      final c = fin.creates.single;
      expect(c['projectId'], isNull, reason: 'server tự chọn tháng');
      expect(c['linkedProjectId'], 'p1');
      expect((c['kind'], c['amount'], c['accountId'], c['note'], c['categoryId']), (MoneyKind.expense, 100000.0, 'w1', 'Thuê loa', null));
      final at = c['occurredAt'] as DateTime;
      expect(at.difference(before).inSeconds.abs(), lessThan(30));
      expect(find.byType(Dialog), findsNothing);
      expect(find.text('Thuê loa'), findsOneWidget, reason: 'danh sách đã làm mới');
    });

    testWidgets('hai câu lỗi: finance_month_not_found và project_archived', (tester) async {
      final (_, fin) = await _pump(tester, fin: FakeFinanceApi());
      await _openAddForm(tester);
      await tester.enterText(_field('Số tiền (VND)'), '100000');
      await tester.pump();
      fin.createError = _badRequest('finance_month_not_found');
      await tester.tap(_saveButton());
      await tester.pumpAndSettle();
      expect(find.text('Tháng này chưa mở sổ tài chính.'), findsOneWidget);
      fin.createError = _badRequest('project_archived');
      await tester.tap(_saveButton());
      await tester.pumpAndSettle();
      expect(find.text('Tháng này đã khoá sổ.'), findsOneWidget);
      expect(find.text('Tháng này chưa mở sổ tài chính.'), findsNothing);
      expect(find.byType(Dialog), findsOneWidget, reason: 'form vẫn mở');
    });

    testWidgets('bấm Lưu hai lần chỉ gửi một lần', (tester) async {
      final (_, fin) = await _pump(tester, fin: FakeFinanceApi());
      await _openAddForm(tester);
      await tester.enterText(_field('Số tiền (VND)'), '100000');
      await tester.pump();
      fin.gate = Completer();
      await tester.tap(_saveButton());
      await tester.pump();
      expect(_canSave(tester), isFalse, reason: 'khoá trong lúc gửi');
      await tester.tap(_saveButton(), warnIfMissed: false);
      await tester.pump();
      expect(fin.creates, hasLength(1));
      fin.gate!.complete();
      await tester.pumpAndSettle();
      expect(fin.creates, hasLength(1));
    });

    testWidgets('390: không tràn kể cả khi bàn phím mở', (tester) async {
      await _pump(tester, fin: FakeFinanceApi());
      await _openAddForm(tester);
      tester.view.viewInsets = const FakeViewPadding(bottom: 300);
      addTearDown(tester.view.resetViewInsets);
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    });
  });

  group('form sửa', () {
    testWidgets('ngày chỉ đọc kèm dòng hướng dẫn; chưa đổi gì thì khoá Lưu', (tester) async {
      await _pump(tester);
      await _openEditForm(tester, 't1');
      final today = vnToday();
      expect(find.text('Ngày: ${formatDayMonth(today)}/${today.substring(0, 4)}'), findsOneWidget);
      expect(find.text('Muốn đổi ngày thì xoá giao dịch rồi thêm lại.'), findsOneWidget);
      expect(find.widgetWithText(OutlinedButton, 'Ngày: ${formatDayMonth(today)}/${today.substring(0, 4)}'), findsNothing, reason: 'không bấm được');
      expect(_canSave(tester), isFalse);
    });

    testWidgets('chỉ gửi trường đã đổi', (tester) async {
      final (_, fin) = await _pump(tester);
      await _openEditForm(tester, 't1');
      await tester.enterText(_field('Số tiền (VND)'), '150000');
      await tester.enterText(_field('Ghi chú (tuỳ chọn)'), 'Thuê loa lớn');
      await tester.pump();
      expect(_canSave(tester), isTrue);
      await tester.tap(_saveButton());
      await tester.pumpAndSettle();
      expect(fin.updates.single, {'id': 't1', 'amount': 150000, 'note': 'Thuê loa lớn'});
      expect(find.text('Thuê loa lớn'), findsOneWidget);
    });

    testWidgets('đổi loại sang Thu và ví: gửi kind và accountId; xoá ghi chú gửi null', (tester) async {
      final (_, fin) = await _pump(tester);
      await _openEditForm(tester, 't1');
      await tester.tap(find.widgetWithText(ChoiceChip, 'Thu'));
      await tester.pumpAndSettle();
      await tester.tap(find.byType(DropdownButtonFormField<String>));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Momo').last);
      await tester.pumpAndSettle();
      await tester.enterText(_field('Ghi chú (tuỳ chọn)'), '');
      await tester.pump();
      await tester.tap(_saveButton());
      await tester.pumpAndSettle();
      // danh mục "Thuê địa điểm" là loại Chi nên bị bỏ khi đổi sang Thu → categoryId null
      expect(fin.updates.single, {'id': 't1', 'kind': 'INCOME', 'accountId': 'w2', 'categoryId': null, 'note': null});
    });

    testWidgets('bỏ gắn khỏi dự án: hộp xác nhận; Huỷ không gọi API; đồng ý thì PATCH linkedProjectId null', (tester) async {
      final (_, fin) = await _pump(tester);
      await _openEditForm(tester, 't1');
      await tester.tap(find.text('Bỏ gắn khỏi dự án'));
      await tester.pumpAndSettle();
      expect(find.text('Giao dịch vẫn nằm trong sổ thu-chi của tháng, chỉ không còn tính vào dự án này.'), findsOneWidget);
      await tester.tap(find.text('Huỷ'));
      await tester.pumpAndSettle();
      expect(fin.updates, isEmpty);

      await tester.tap(find.text('Bỏ gắn khỏi dự án'));
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(TextButton, 'Bỏ gắn'));
      await tester.pumpAndSettle();
      expect(fin.updates.single, {'id': 't1', 'linkedProjectId': null});
      expect(find.byType(Dialog), findsNothing);
      expect(find.text('Thuê loa'), findsNothing, reason: 'không còn trong danh sách của dự án');
    });

    testWidgets('lỗi khi sửa: câu báo; bấm Lưu hai lần chỉ gửi một lần', (tester) async {
      final (_, fin) = await _pump(tester);
      await _openEditForm(tester, 't1');
      await tester.enterText(_field('Số tiền (VND)'), '150000');
      await tester.pump();
      fin.gate = Completer();
      fin.updateError = _badRequest('project_archived');
      await tester.tap(_saveButton());
      await tester.pump();
      await tester.tap(_saveButton(), warnIfMissed: false);
      await tester.pump();
      expect(fin.updates, hasLength(1));
      fin.gate!.complete();
      await tester.pumpAndSettle();
      expect(find.text('Tháng này đã khoá sổ.'), findsOneWidget);
    });
  });
}

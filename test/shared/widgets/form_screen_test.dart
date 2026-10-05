import 'package:amber_flutter/features/nghi_su_duong/models/finance_account.dart';
import 'package:amber_flutter/features/nghi_su_duong/models/finance_category.dart';
import 'package:amber_flutter/features/nghi_su_duong/models/finance_transaction.dart';
import 'package:amber_flutter/features/nghi_su_duong/providers/finance_provider.dart';
import 'package:amber_flutter/features/nghi_su_duong/services/finance_api.dart';
import 'package:amber_flutter/features/nghi_su_duong/widgets/add_account_modal.dart';
import 'package:amber_flutter/features/nghi_su_duong/widgets/add_category_modal.dart';
import 'package:amber_flutter/features/nghi_su_duong/widgets/add_course_modal.dart';
import 'package:amber_flutter/features/nghi_su_duong/widgets/add_lesson_modal.dart';
import 'package:amber_flutter/features/nghi_su_duong/widgets/add_transaction_modal.dart';
import 'package:amber_flutter/features/nghi_su_duong/widgets/set_budget_modal.dart';
import 'package:amber_flutter/features/tra_dinh/models/practice_session.dart';
import 'package:amber_flutter/features/tra_dinh/services/tra_dinh_api.dart';
import 'package:amber_flutter/features/tra_dinh/widgets/new_practice_session_modal.dart';
import 'package:amber_flutter/shared/services/api_client.dart';
import 'package:amber_flutter/shared/widgets/form_bits.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

// Form nhập liệu chung (showFinanceSheet + FinanceSheetBody): màn hình đầy đủ
// thay cho bottom sheet — xem form_bits.dart. Không gọi mạng: mọi request còn
// sót tới Dio đều bị chặn và đếm ([_offlineDio]).

/// iPhone 390x844 (DPR 3), tai thỏ 47pt; bàn phím số + thanh phụ trợ 366pt.
const _screen = Size(390, 844);
const _statusBar = 47.0;
const _keyboard = 366.0;

void _phone(WidgetTester tester, {bool keyboard = false}) {
  tester.view.devicePixelRatio = 3;
  tester.view.physicalSize = _screen * 3;
  // Như iOS báo: bàn phím mở thì padding.bottom về 0 (bàn phím che vạch home),
  // viewPadding giữ nguyên.
  tester.view.viewPadding = const FakeViewPadding(top: _statusBar * 3, bottom: 34 * 3);
  tester.view.padding = FakeViewPadding(top: _statusBar * 3, bottom: keyboard ? 0 : 34 * 3);
  tester.view.viewInsets = FakeViewPadding(bottom: keyboard ? _keyboard * 3 : 0);
  addTearDown(tester.view.reset);
}

var _blockedRequests = 0;

/// Dio chặn mọi request (không có gì ra mạng thật).
Dio _offlineDio() => Dio()
  ..interceptors.add(
    InterceptorsWrapper(
      onRequest: (o, h) {
        _blockedRequests++;
        h.reject(DioException(requestOptions: o, error: 'network blocked in test'));
      },
    ),
  );

FinanceTransaction _tx(String id, double amount) => FinanceTransaction.fromJson({
  'id': id, 'userId': 'u', 'projectId': 'p1', 'accountId': 'a1', 'categoryId': 'c1',
  'kind': 'EXPENSE', 'amount': '$amount', 'note': null,
  'occurredAt': '2026-10-05T02:00:00.000Z', 'createdAt': '2026-10-05T02:00:00.000Z',
});

/// FinanceApi giả: [transactions] / [categories] là "DB".
class _FakeFinanceApi extends FinanceApi {
  _FakeFinanceApi() : super(_offlineDio());

  final transactions = <FinanceTransaction>[_tx('t1', 40000)];
  final categories = <FinanceCategory>[
    const FinanceCategory(id: 'c1', name: 'Ăn uống', icon: '🍜', kind: MoneyKind.expense),
  ];
  int creates = 0;

  @override
  Future<List<FinanceAccount>> getAccounts() async => [
    FinanceAccount.fromJson({'id': 'a1', 'name': 'Cash', 'type': 'CASH', 'currentBalance': '100000', 'archivedAt': null}),
  ];

  @override
  Future<List<FinanceCategory>> getCategories({MoneyKind? kind}) async => List.of(categories);

  @override
  Future<List<FinanceTransaction>> getTransactions(String projectId) async => List.of(transactions);

  @override
  Future<FinanceTransaction> createTransaction({
    required String projectId,
    required String accountId,
    String? categoryId,
    required MoneyKind kind,
    required double amount,
    String? note,
    DateTime? occurredAt,
  }) async {
    creates++;
    final t = _tx('t${transactions.length + 1}', amount);
    transactions.add(t);
    return t;
  }

  @override
  Future<FinanceCategory> createCategory({required String name, String? icon, required MoneyKind kind}) async {
    creates++;
    final c = FinanceCategory(id: 'c${categories.length + 1}', name: name, icon: icon, kind: kind);
    categories.add(c);
    return c;
  }
}

class _FakeTraDinhApi extends TraDinhApi {
  _FakeTraDinhApi() : super(_offlineDio());

  @override
  Future<PracticeSession> createSession({required PracticeMode mode, String? name}) async =>
      PracticeSession(id: 's-new', name: name ?? 'Buổi mới', mode: mode, createdAt: DateTime.utc(2026, 10, 5));
}

/// Màn hình phía sau form: danh sách giao dịch + danh mục, và nút mở từng form.
class _Host extends ConsumerWidget {
  const _Host({required this.onResult});

  final void Function(Object?) onResult;

  static final openers = <String, Future<Object?> Function(BuildContext)>{
    'Thêm giao dịch': (c) => showAddTransactionModal(c, projectId: 'p1'),
    'Đặt ngân sách — Tháng 10': (c) =>
        showSetBudgetModal(c, projectId: 'p1', projectName: 'Tháng 10', currentLimits: const {}),
    'Thêm ví': (c) => showAddAccountModal(c, projectId: 'p1'),
    'Thêm danh mục': showAddCategoryModal,
    'Thêm khóa học': showAddCourseModal,
    'Thêm bài học': (c) => showAddLessonModal(c, courseId: 'course1'),
    'Bắt đầu buổi luyện mới': showNewPracticeSessionModal,
  };

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final txs = ref.watch(financeTransactionsProvider('p1')).value;
    final cats = ref.watch(financeCategoriesProvider).value;
    return Scaffold(
      body: ListView(
        children: [
          Text('Giao dịch: ${txs?.length ?? '...'}'),
          Text('Danh mục: ${cats?.length ?? '...'}'),
          for (final e in openers.entries)
            TextButton(onPressed: () async => onResult(await e.value(context)), child: Text('mở ${e.key}')),
        ],
      ),
    );
  }
}

class _Harness {
  final finance = _FakeFinanceApi();
  final traDinh = _FakeTraDinhApi();
  final results = <Object?>[];
  int resultCount = 0;

  Future<void> pump(WidgetTester tester, {bool router = false}) async {
    _blockedRequests = 0;
    Widget host = _Host(onResult: (r) {
      resultCount++;
      results.add(r);
    });
    Widget scope(Widget app) => ProviderScope(
      overrides: [
        apiClientProvider.overrideWithValue(_offlineDio()),
        financeApiProvider.overrideWithValue(finance),
        traDinhApiProvider.overrideWithValue(traDinh),
      ],
      child: app,
    );
    if (router) {
      final r = GoRouter(routes: [GoRoute(path: '/', builder: (_, _) => host)]);
      addTearDown(r.dispose);
      await tester.pumpWidget(scope(MaterialApp.router(theme: ThemeData.dark(), routerConfig: r)));
    } else {
      await tester.pumpWidget(scope(MaterialApp(theme: ThemeData.dark(), home: host)));
    }
    await tester.pumpAndSettle();
  }

  Future<void> open(WidgetTester tester, String title) async {
    await tester.tap(find.text('mở $title'));
    await tester.pumpAndSettle();
  }
}

void main() {
  group('khung form chung', () {
    for (final title in _Host.openers.keys) {
      testWidgets('$title: màn hình đầy đủ (Dialog.fullscreen), không phải bottom sheet; đóng bằng X → null',
          (tester) async {
        _phone(tester);
        final h = _Harness();
        await h.pump(tester);
        await h.open(tester, title);

        expect(find.byType(BottomSheet), findsNothing);
        final dialog = find.byType(Dialog);
        expect(dialog, findsOneWidget);
        expect(tester.getRect(dialog), Offset.zero & _screen, reason: 'phủ kín màn hình');
        expect(find.widgetWithText(AppBar, title), findsOneWidget);
        // Không trường nào tự focus (iOS không mở bàn phím nếu không do chạm).
        expect(FocusManager.instance.primaryFocus?.context?.widget, isNot(isA<EditableText>()));
        // Nút hành động chính là phần tử cuối của nội dung cuộn, không ghim đáy.
        final column = tester.widget<Column>(
          find.descendant(of: find.byType(SingleChildScrollView), matching: find.byType(Column)).first,
        );
        expect(column.children.last, isA<FilledButton>());

        await tester.tap(find.byType(CloseButton));
        await tester.pumpAndSettle();
        expect(dialog, findsNothing);
        expect(h.resultCount, 1);
        expect(h.results.single, isNull);
        expect(_blockedRequests, 0, reason: 'không request nào lọt tới Dio');
      });
    }

    testWidgets('đóng bằng thao tác quay lại (nút back hệ thống) → null, cả với go_router', (tester) async {
      _phone(tester);
      for (final router in [false, true]) {
        final h = _Harness();
        await h.pump(tester, router: router);
        for (final title in _Host.openers.keys) {
          await h.open(tester, title);
          expect(find.byType(Dialog), findsOneWidget, reason: title);
          await tester.binding.handlePopRoute();
          await tester.pumpAndSettle();
          expect(find.byType(Dialog), findsNothing, reason: '$title (router: $router)');
        }
        expect(h.results, List.filled(_Host.openers.length, null));
        expect(find.text('Giao dịch: 1'), findsOneWidget, reason: 'màn hình phía sau vẫn còn');
      }
    });

    testWidgets('bàn phím chỉ được trừ MỘT lần: vùng cuộn kết thúc đúng ở mép trên bàn phím', (tester) async {
      _phone(tester, keyboard: true);
      final h = _Harness();
      await h.pump(tester);
      await h.open(tester, 'Thêm giao dịch');

      final scroll = tester.getRect(find.byType(SingleChildScrollView));
      expect(scroll.bottom, _screen.height - _keyboard); // 478, không thừa khoảng trống
      // Dialog không tự co theo bàn phím (Scaffold là nơi duy nhất xử lý).
      expect(tester.getRect(find.byType(Dialog)).height, _screen.height);
      final scaffold = tester.widget<Scaffold>(
        find.descendant(of: find.byType(Dialog), matching: find.byType(Scaffold)),
      );
      expect(scaffold.resizeToAvoidBottomInset, isTrue);
    });

    testWidgets('Thêm giao dịch khi có bàn phím: Số tiền, Ví, Danh mục nằm trọn trong vùng nhìn thấy, '
        'không gì dưới thanh trạng thái, nút Lưu cuộn tới được', (tester) async {
      _phone(tester, keyboard: true);
      final h = _Harness();
      await h.pump(tester);
      await h.open(tester, 'Thêm giao dịch');

      const visibleBottom = 844.0 - _keyboard;
      final close = tester.getRect(find.byType(CloseButton));
      expect(close.top, greaterThanOrEqualTo(_statusBar));
      final appBarBottom = tester.getRect(find.byType(AppBar)).bottom;
      for (final f in [
        find.widgetWithText(TextField, 'Số tiền (VND)'),
        find.widgetWithText(DropdownButtonFormField<String>, 'Ví'),
        find.widgetWithText(DropdownButtonFormField<String?>, 'Danh mục'),
      ]) {
        final r = tester.getRect(f);
        expect(r.top, greaterThanOrEqualTo(appBarBottom), reason: '$f');
        expect(r.bottom, lessThanOrEqualTo(visibleBottom), reason: '$f');
      }
      // Thứ tự giữ nguyên: Thu/Chi → Số tiền → Ví → Danh mục → Ghi chú → Lưu.
      final ys = [
        find.text('Chi tiêu'),
        find.widgetWithText(TextField, 'Số tiền (VND)'),
        find.text('Ví'),
        find.text('Danh mục'),
        find.widgetWithText(TextField, 'Ghi chú (tuỳ chọn)'),
      ].map((f) => tester.getRect(f).top).toList();
      expect(ys, orderedEquals([...ys]..sort()));

      final save = find.widgetWithText(FilledButton, 'Lưu');
      await tester.scrollUntilVisible(save, 50, scrollable: find.byType(Scrollable).last);
      expect(tester.getRect(save).bottom, lessThanOrEqualTo(visibleBottom));
    });

    testWidgets('focus một trường ở dưới (đang khuất) của form dài → sau khi bàn phím mở (~300ms) tự cuộn tới, alignment 0.1',
        (tester) async {
      _phone(tester, keyboard: true);
      // Trường "giả" là Focus thuần (không phải TextField, vốn tự showOnScreen)
      // để chỉ đo đúng logic ensureVisible của FinanceSheetBody.
      final node = FocusNode();
      addTearDown(node.dispose);
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData.dark(),
          home: Builder(
            builder: (context) => TextButton(
              onPressed: () => showFinanceSheet<void>(
                context,
                FinanceSheetBody(
                  title: 'Form dài',
                  children: [
                    for (var i = 0; i < 12; i++) SizedBox(height: 60, child: Text('Trường $i')),
                    Focus(focusNode: node, child: const SizedBox(height: 60, child: Text('Trường cuối'))),
                    // Còn nội dung phía dưới → cuộn được tới đúng alignment, không chạm đáy.
                    for (var i = 0; i < 8; i++) SizedBox(height: 60, child: Text('Sau $i')),
                    FilledButton(onPressed: () {}, child: const Text('Lưu')),
                  ],
                ),
              ),
              child: const Text('mở'),
            ),
          ),
        ),
      );
      await tester.tap(find.text('mở'));
      await tester.pumpAndSettle();
      final viewport = tester.getRect(find.byType(SingleChildScrollView));
      expect(tester.getRect(find.text('Trường cuối')).top, greaterThan(viewport.bottom), reason: 'ban đầu khuất');

      node.requestFocus();
      await tester.pump(); // frame áp dụng focus (+ post-frame callback)
      await tester.pump(const Duration(milliseconds: 200));
      expect(tester.getRect(find.text('Trường cuối')).top, greaterThan(viewport.bottom), reason: 'chưa tới 300ms');
      // Bộ đếm 300ms tính từ frame sau khi focus được áp dụng — chờ dư rồi để cuộn xong.
      await tester.pump(const Duration(milliseconds: 400));
      await tester.pumpAndSettle();
      final top = tester.getRect(find.text('Trường cuối')).top;
      expect(top, closeTo(viewport.top + 0.1 * (viewport.height - 60), 1));
    });
  });

  group('kết quả trả về vẫn cập nhật màn hình phía sau', () {
    testWidgets('Thêm giao dịch: Lưu → đóng form, danh sách giao dịch tải lại', (tester) async {
      _phone(tester);
      final h = _Harness();
      await h.pump(tester);
      expect(find.text('Giao dịch: 1'), findsOneWidget);

      await h.open(tester, 'Thêm giao dịch');
      await tester.enterText(find.widgetWithText(TextField, 'Số tiền (VND)'), '25000');
      await tester.pump();
      expect(find.text('= 25.000₫'), findsOneWidget);
      await tester.tap(find.widgetWithText(FilledButton, 'Lưu'));
      await tester.pumpAndSettle();

      expect(find.byType(Dialog), findsNothing);
      expect(h.finance.creates, 1);
      expect(find.text('Giao dịch: 2'), findsOneWidget);
      expect(h.results, [null]); // form tài chính pop() không kèm giá trị, như trước
    });

    testWidgets('Thêm danh mục: Thêm → danh sách danh mục tải lại; mở rồi đóng X thì không tạo gì', (tester) async {
      _phone(tester);
      final h = _Harness();
      await h.pump(tester);
      await h.open(tester, 'Thêm danh mục');
      await tester.tap(find.byType(CloseButton));
      await tester.pumpAndSettle();
      expect(h.finance.creates, 0);
      expect(find.text('Danh mục: 1'), findsOneWidget);

      await h.open(tester, 'Thêm danh mục');
      await tester.enterText(find.widgetWithText(TextField, 'Tên danh mục (VD: Ăn uống)'), 'Đi lại');
      await tester.pump();
      await tester.tap(find.byType(FilledButton));
      await tester.pumpAndSettle();
      expect(find.byType(Dialog), findsNothing);
      expect(find.text('Danh mục: 2'), findsOneWidget);
    });

    testWidgets('Bắt đầu buổi luyện mới: pop(created) → nơi gọi nhận đúng PracticeSession', (tester) async {
      _phone(tester);
      final h = _Harness();
      await h.pump(tester);
      await h.open(tester, 'Bắt đầu buổi luyện mới');
      await tester.enterText(find.widgetWithText(TextField, 'Tên buổi luyện (tuỳ chọn)'), 'Phỏng vấn');
      await tester.tap(find.widgetWithText(FilledButton, 'Bắt đầu'));
      await tester.pumpAndSettle();

      expect(find.byType(Dialog), findsNothing);
      final created = h.results.single as PracticeSession;
      expect(created.id, 's-new');
      expect(created.name, 'Phỏng vấn');
    });
  });
}

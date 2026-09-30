import 'dart:async';

import 'package:amber_flutter/features/nghi_su_duong/models/finance_account.dart';
import 'package:amber_flutter/features/nghi_su_duong/models/finance_summary.dart';
import 'package:amber_flutter/features/nghi_su_duong/models/finance_transaction.dart';
import 'package:amber_flutter/features/nghi_su_duong/models/overview.dart';
import 'package:amber_flutter/features/nghi_su_duong/models/project.dart';
import 'package:amber_flutter/features/nghi_su_duong/providers/nghi_su_duong_provider.dart';
import 'package:amber_flutter/features/nghi_su_duong/screens/finance_month_screen.dart';
import 'package:amber_flutter/features/nghi_su_duong/screens/finance_screen.dart';
import 'package:amber_flutter/features/nghi_su_duong/services/finance_api.dart';
import 'package:amber_flutter/features/nghi_su_duong/utils/finance_month.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

/// FinanceApi giả — không gọi mạng, không đụng DB. Danh sách tháng rỗng nên
/// nút "Bắt đầu tháng mới" luôn hiện, bất kể hôm nay là ngày mấy.
class _FakeFinanceApi extends FinanceApi {
  _FakeFinanceApi() : super(Dio());

  // Tháng "vừa tạo" = tháng hiện tại theo lịch VN (như backend), để sau khi tạo
  // hasCurrentFinanceMonth thấy nó và ẩn nút — test chạy đúng ở mọi thời điểm.
  final created = Project(
    id: 'thang-moi',
    name: 'Tài chính — Tháng mới',
    type: ProjectType.finance,
    startDate: '${vnMonthKey()}-01',
    endDate: '${vnMonthKey()}-28',
  );
  int startCalls = 0;
  int listCalls = 0;
  Completer<Project>? pendingStart;
  bool failStart = false;

  @override
  Future<List<Project>> getFinanceProjects() async {
    listCalls++;
    return startCalls > 0 && !failStart ? [created] : [];
  }

  @override
  Future<Project> startNewMonth() {
    startCalls++;
    if (failStart) return Future.error(DioException(requestOptions: RequestOptions()));
    pendingStart = Completer<Project>();
    return pendingStart!.future;
  }

  @override
  Future<FinanceSummary> getFinanceSummary(String projectId) async => FinanceSummary(
        projectId: projectId,
        projectName: created.name,
        startDate: created.startDate!,
        endDate: created.endDate!,
        totalBalance: 0,
        totalIncome: 0,
        totalExpense: 0,
        netThisMonth: 0,
        budgetProgress: const [],
      );

  @override
  Future<List<FinanceAccount>> getAccounts() async => const [];

  @override
  Future<List<FinanceTransaction>> getTransactions(String projectId) async => const [];
}

Future<void> _pump(WidgetTester tester, _FakeFinanceApi api) async {
  await tester.pumpWidget(ProviderScope(
    overrides: [
      financeApiProvider.overrideWithValue(api),
      // Card Tài chính ở trang chính — chỉ cần không gọi mạng.
      financeOverviewProvider.overrideWith((ref) async => const FinanceOverview(
            currentBalance: 0,
            totalIncome: 0,
            totalExpense: 0,
          )),
    ],
    // Theme mặc định: AppTheme dùng google_fonts, tải font qua mạng trong test.
    child: MaterialApp(theme: ThemeData.dark(), home: const FinanceScreen()),
  ));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('bấm → khoá nút + spinner → gọi đúng 1 lần → mở màn chi tiết của tháng vừa tạo', (tester) async {
    final api = _FakeFinanceApi();
    await _pump(tester, api);

    final button = find.widgetWithText(FilledButton, 'Bắt đầu tháng mới');
    expect(button, findsOneWidget);

    await tester.tap(button);
    await tester.pump(); // đang chờ startNewMonth

    expect(find.text('Đang tạo tháng mới...'), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    final disabled = tester.widget<FilledButton>(find.widgetWithText(FilledButton, 'Đang tạo tháng mới...'));
    expect(disabled.onPressed, isNull);

    // Bấm thêm lần nữa trong lúc chờ: không gọi lại.
    await tester.tap(find.text('Đang tạo tháng mới...'));
    await tester.pump();
    expect(api.startCalls, 1);

    final listCallsBefore = api.listCalls;
    api.pendingStart!.complete(api.created);
    await tester.pumpAndSettle();

    // Mở đúng màn chi tiết của project trả về (không tìm lại trong danh sách).
    final month = tester.widget<FinanceMonthScreen>(find.byType(FinanceMonthScreen));
    expect(month.projectId, 'thang-moi');
    expect(find.text('Tài chính — Tháng mới'), findsWidgets);

    // Quay lại: danh sách đã được tải lại (invalidate) và có tháng mới, nút ẩn.
    Navigator.of(tester.element(find.byType(FinanceMonthScreen))).pop();
    await tester.pumpAndSettle();
    expect(api.listCalls, greaterThan(listCallsBefore));
    expect(find.text('Tài chính — Tháng mới'), findsOneWidget);
    expect(find.widgetWithText(FilledButton, 'Bắt đầu tháng mới'), findsNothing);
  });

  testWidgets('lỗi → SnackBar, nút mở lại, không điều hướng', (tester) async {
    final api = _FakeFinanceApi()..failStart = true;
    await _pump(tester, api);

    await tester.tap(find.widgetWithText(FilledButton, 'Bắt đầu tháng mới'));
    await tester.pumpAndSettle();

    expect(find.text('Không bắt đầu được tháng mới, thử lại nhé.'), findsOneWidget);
    expect(find.byType(FinanceMonthScreen), findsNothing);
    final button = tester.widget<FilledButton>(find.widgetWithText(FilledButton, 'Bắt đầu tháng mới'));
    expect(button.onPressed, isNotNull);
  });
}

import 'package:amber_flutter/features/tra_dinh/hoc_tap/screens/tra_dinh_hoc_tap_screen.dart';
import 'package:amber_flutter/features/tra_dinh/hoc_tap/services/hoc_tap_api.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import 'hoc_tap_test_support.dart';

// Màn Trà Đình (Tổng quan / Lịch / Thống kê) phải luôn có đường về Âm Dương Giới — kể cả khi mở thẳng URL (PWA trên iPhone)
// hay sau khi đổi tab (context.go thay cả stack).

late GoRouter _router;

Future<void> _pump(WidgetTester tester, String location, {bool pushed = false}) async {
  tester.view.physicalSize = const Size(390, 3600);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  _router = GoRouter(
    initialLocation: pushed ? '/' : location,
    routes: [
      GoRoute(path: '/', builder: (_, _) => const Scaffold(body: Text('Âm Dương Giới'))),
      GoRoute(
        path: '/tra-dinh',
        builder: (_, state) => TraDinhHocTapScreen(
          tab: state.uri.queryParameters['tab'],
          openLog: state.uri.queryParameters['openLog'] == '1',
          subjectId: state.uri.queryParameters['subjectId'],
          view: state.uri.queryParameters['view'],
          date: state.uri.queryParameters['date'],
          range: state.uri.queryParameters['range'],
          subject: state.uri.queryParameters['subject'],
        ),
      ),
    ],
  );
  await tester.pumpWidget(
    ProviderScope(overrides: [hocTapApiProvider.overrideWithValue(FakeHocTapApi())], child: MaterialApp.router(theme: ThemeData.dark(), routerConfig: _router)),
  );
  await tester.pumpAndSettle();
  if (pushed) {
    _router.push(location);
    await tester.pumpAndSettle();
  }
}

String _loc() => _router.routeInformationProvider.value.uri.toString();

Future<void> _back(WidgetTester tester) async {
  expect(find.byType(BackButton), findsOneWidget);
  await tester.tap(find.byType(BackButton));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('mở thẳng /tra-dinh (app đã cài mở lại): có nút quay lại, bấm → Âm Dương Giới', (tester) async {
    await _pump(tester, '/tra-dinh');
    expect(_router.canPop(), isFalse);
    expect(find.text('Trà Đình'), findsOneWidget);
    await _back(tester);
    expect(find.text('Âm Dương Giới'), findsOneWidget);
    expect(_loc(), '/');
  });

  testWidgets('mở bằng push từ Âm Dương Giới: bấm quay lại là pop', (tester) async {
    await _pump(tester, '/tra-dinh', pushed: true);
    expect(_router.canPop(), isTrue);
    await _back(tester);
    expect(find.text('Âm Dương Giới'), findsOneWidget);
    expect(_router.canPop(), isFalse);
  });

  testWidgets('đổi tab Lịch / Thống kê (context.go) xong vẫn quay về được Âm Dương Giới', (tester) async {
    await _pump(tester, '/tra-dinh', pushed: true);
    for (final (label, tab) in [('Lịch', 'schedule'), ('Thống kê', 'stats')]) {
      await tester.tap(find.widgetWithText(Tab, label));
      await tester.pumpAndSettle();
      expect(_loc(), contains('tab=$tab'));
      expect(_router.canPop(), isFalse, reason: 'tab đổi bằng go() đã thay stack — mũi tên tự thêm của Flutter không còn');
      expect(find.byType(BackButton), findsOneWidget);
    }
    await _back(tester);
    expect(find.text('Âm Dương Giới'), findsOneWidget);
    expect(_loc(), '/');
  });

  testWidgets('?openLog=1: mở sheet ghi buổi học, đóng sheet xong vẫn có nút quay lại', (tester) async {
    final subjectId = FakeHocTapApi().subjects.first.id;
    await _pump(tester, '/tra-dinh?openLog=1&subjectId=$subjectId');
    expect(find.textContaining('Chỉ ghi cho hôm nay.'), findsOneWidget);
    expect(_loc(), '/tra-dinh'); // query đã bị xoá khỏi URL (go) → không còn trang nào bên dưới
    await tester.tap(find.byType(CloseButton));
    await tester.pumpAndSettle();
    expect(find.textContaining('Chỉ ghi cho hôm nay.'), findsNothing);
    await _back(tester);
    expect(_loc(), '/');
  });
}

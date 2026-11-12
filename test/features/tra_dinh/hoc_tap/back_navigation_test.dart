import 'package:amber_flutter/features/tra_dinh/hoc_tap/screens/tra_dinh_hoc_tap_screen.dart';
import 'package:amber_flutter/features/tra_dinh/hoc_tap/services/hoc_tap_api.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import 'hoc_tap_test_support.dart';

// Màn Hôm nay của Trà Đình phải luôn có đường về Âm Dương Giới — kể cả khi mở thẳng URL (PWA trên iPhone)
// hay sau khi context.go thay cả stack.

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
          openLog: state.uri.queryParameters['openLog'] == '1',
          subjectId: state.uri.queryParameters['subjectId'],
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
  expect(find.byKey(const ValueKey('app-bar-back-label')), findsOneWidget);
  await tester.tap(find.byKey(const ValueKey('app-bar-back-label')));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('mở thẳng /tra-dinh (app đã cài mở lại): có nút quay lại, bấm → Âm Dương Giới', (tester) async {
    await _pump(tester, '/tra-dinh');
    expect(_router.canPop(), isFalse);
    expect(find.text('‹ Trà Đình'), findsOneWidget);
    expect(find.text('Hôm nay'), findsWidgets);
    expect(find.byType(TabBar), findsNothing);
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

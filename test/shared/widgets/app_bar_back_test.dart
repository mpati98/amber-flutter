import 'dart:async';
import 'dart:io';

import 'package:amber_flutter/shared/widgets/app_bar_back.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

// Nút quay lại dùng chung: pop nếu còn trang, không thì go(fallback) — mặc định '/' (Âm Dương Giới).

GoRouter _router(String initial) => GoRouter(
  initialLocation: initial,
  routes: [
    GoRoute(path: '/', builder: (_, _) => const Scaffold(body: Text('home'))),
    GoRoute(
      path: '/tower',
      builder: (_, _) => Scaffold(appBar: AppBar(leading: const AppBarBack(), title: const Text('Tower')), body: const Text('tower body')),
      routes: [
        GoRoute(
          path: 'sub',
          builder: (_, _) => Scaffold(appBar: AppBar(leading: const AppBarBack(fallback: '/tower'), title: const Text('Sub')), body: const Text('sub body')),
        ),
      ],
    ),
  ],
);

String _loc(GoRouter r) => r.routeInformationProvider.value.uri.toString();

Future<void> _pump(WidgetTester tester, GoRouter router) async {
  await tester.pumpWidget(MaterialApp.router(theme: ThemeData.dark(), routerConfig: router));
  await tester.pumpAndSettle();
}

Future<void> _tapBack(WidgetTester tester) async {
  expect(find.byType(BackButton), findsOneWidget);
  await tester.tap(find.byType(BackButton));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('mở thẳng một tháp (không có trang bên dưới): có nút quay lại, bấm → Âm Dương Giới "/"', (tester) async {
    final router = _router('/tower');
    await _pump(tester, router);
    expect(router.canPop(), isFalse);
    expect(find.text('tower body'), findsOneWidget);
    await _tapBack(tester);
    expect(find.text('home'), findsOneWidget);
    expect(_loc(router), '/');
  });

  testWidgets('mở bằng push từ "/": bấm quay lại là pop (không go thêm)', (tester) async {
    final router = _router('/');
    await _pump(tester, router);
    unawaited(router.push('/tower'));
    await tester.pumpAndSettle();
    expect(router.canPop(), isTrue);
    await _tapBack(tester);
    expect(find.text('home'), findsOneWidget);
    expect(router.canPop(), isFalse);
  });

  testWidgets('đổi tab bằng context.go (thay cả stack) không làm mất đường về', (tester) async {
    final router = _router('/');
    await _pump(tester, router);
    unawaited(router.push('/tower'));
    await tester.pumpAndSettle();
    router.go('/tower?tab=stats'); // đúng cách các tab của Trà Đình đổi URL
    await tester.pumpAndSettle();
    expect(router.canPop(), isFalse, reason: 'go() đã bỏ trang "/" bên dưới → mũi tên mặc định của AppBar sẽ biến mất');
    await _tapBack(tester);
    expect(find.text('home'), findsOneWidget);
    expect(_loc(router), '/');
  });

  testWidgets('trang con mở thẳng: quay về trang cha [fallback], không phải "/"', (tester) async {
    final router = _router('/tower/sub');
    await _pump(tester, router);
    await _tapBack(tester);
    expect(find.text('tower body'), findsOneWidget);
    expect(_loc(router), '/tower');
    await _tapBack(tester); // tháp mở ở stack trống → lên "/"
    expect(_loc(router), '/');
  });

  testWidgets('mũi tên mặc định của nền tảng và tooltip cho trình đọc màn hình', (tester) async {
    await _pump(tester, _router('/tower'));
    expect(find.byTooltip('Back'), findsOneWidget);
    expect(find.byType(BackButtonIcon), findsOneWidget);
  });

  testWidgets('không có GoRouter trong cây: pop Navigator thường, ở trang gốc thì không làm gì và không ném lỗi', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) => Scaffold(
            appBar: AppBar(leading: const AppBarBack(), title: const Text('root')),
            body: TextButton(
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute<void>(builder: (_) => Scaffold(appBar: AppBar(leading: const AppBarBack(), title: const Text('pushed')))),
              ),
              child: const Text('open'),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.byType(BackButton));
    await tester.pumpAndSettle();
    expect(find.text('root'), findsOneWidget); // trang gốc: bấm không đi đâu
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
    expect(find.text('pushed'), findsOneWidget);
    await tester.tap(find.byType(BackButton));
    await tester.pumpAndSettle();
    expect(find.text('root'), findsOneWidget);
    expect(find.text('pushed'), findsNothing);
  });

  test('mọi màn trong lib/features có AppBar đều dùng AppBarBack làm leading (chặn tái phát)', () {
    final missing = <String>[];
    var screens = 0;
    for (final f in Directory('lib/features').listSync(recursive: true).whereType<File>().where((f) => f.path.endsWith('.dart'))) {
      final src = f.readAsStringSync();
      for (final m in RegExp(r'appBar:\s*AppBar\(').allMatches(src)) {
        screens++;
        if (!src.substring(m.end).trimLeft().startsWith('leading: const AppBarBack(')) missing.add(f.path);
      }
    }
    expect(missing, isEmpty, reason: 'AppBar không có nút quay lại dự phòng: $missing');
    expect(screens, greaterThanOrEqualTo(22));
  });
}

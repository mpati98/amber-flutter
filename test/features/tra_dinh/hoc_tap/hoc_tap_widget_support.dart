import 'package:amber_flutter/features/tra_dinh/hoc_tap/services/hoc_tap_api.dart';
import 'package:amber_flutter/features/nghi_su_duong/services/nghi_su_duong_api.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

/// Đường dẫn đã mở bằng push/go trong test (để kiểm tra điều hướng).
final visited = <String>[];

/// Bọc [home] ở '/', các route con của Trà Đình là màn giả ghi lại đường dẫn.
Future<void> pumpHocTap(
  WidgetTester tester,
  Widget home, {
  required HocTapApi api,
  NghiSuDuongApi? routinesApi,
  double width = 390,
  List<Override> overrides = const [],
}) async {
  visited.clear();
  tester.view.physicalSize = Size(width, 2600);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  final router = GoRouter(
    routes: [
      GoRoute(path: '/', builder: (_, _) => home),
      GoRoute(
        path: '/tra-dinh/:rest(.*)',
        builder: (_, state) {
          visited.add(state.uri.toString());
          return Scaffold(body: Text('stub ${state.uri}'));
        },
      ),
      GoRoute(
        path: '/tra-dinh',
        builder: (_, state) {
          visited.add(state.uri.toString());
          return const Scaffold(body: Text('stub /tra-dinh'));
        },
      ),
    ],
  );
  await tester.pumpWidget(
    ProviderScope(
      overrides: [hocTapApiProvider.overrideWithValue(api), ?routinesApiOverride(routinesApi), ...overrides],
      child: MaterialApp.router(theme: ThemeData.dark(), routerConfig: router),
    ),
  );
  await tester.pumpAndSettle();
}

Override? routinesApiOverride(NghiSuDuongApi? api) => api == null ? null : nghiSuDuongApiProvider.overrideWithValue(api);

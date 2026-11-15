import 'package:amber_flutter/features/amber_brain/providers/brain_status_provider.dart';
import 'package:amber_flutter/features/sinh_luc/models/sleep_log.dart';
import 'package:amber_flutter/features/sinh_luc/screens/sinh_luc_screen.dart';
import 'package:amber_flutter/features/sinh_luc/services/sleep_api.dart';
import 'package:amber_flutter/shared/providers/auth_provider.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../amber_brain/fake_brain.dart';

class _FakeSleepApi extends SleepApi {
  _FakeSleepApi(this.logs) : super(Dio());

  List<SleepLog> logs;
  final saved = <Map<String, Object?>>[];
  final deleted = <String>[];

  @override
  Future<SleepHistory> history({int days = 14}) async => SleepHistory(today: '2026-11-15', logs: List.of(logs));

  @override
  Future<SleepLog> save({required String date, required int sleepMinutes, int? quality, String? note}) async {
    saved.add({'date': date, 'sleepMinutes': sleepMinutes, 'quality': quality, 'note': note});
    final l = SleepLog(date: date, sleepMinutes: sleepMinutes, quality: quality, note: note);
    logs = [l, ...logs.where((x) => x.date != date)];
    return l;
  }

  @override
  Future<void> delete(String date) async {
    deleted.add(date);
    logs = logs.where((x) => x.date != date).toList();
  }
}

class _Auth extends AuthController {
  @override
  Future<AuthState> build() async => const Authenticated({'id': 'u', 'email': 'me@example.invalid'});
}

const _offline = BrainConnection(link: BrainLink.offline, apiHost: 'localhost:3000');

Future<_FakeSleepApi> _pump(WidgetTester tester, List<SleepLog> logs) async {
  final api = _FakeSleepApi(logs);
  await tester.pumpWidget(ProviderScope(
    overrides: [
      sleepApiProvider.overrideWithValue(api),
      brainStatusProvider.overrideWith(() => FixedBrainStatus(_offline)),
      authControllerProvider.overrideWith(_Auth.new),
    ],
    child: MaterialApp.router(
      theme: ThemeData.dark(),
      routerConfig: GoRouter(routes: [GoRoute(path: '/', builder: (_, _) => const SinhLucScreen())]),
    ),
  ));
  await tester.pumpAndSettle();
  return api;
}

void main() {
  testWidgets('chưa có đêm nào: hướng dẫn + nút ghi đêm qua; ghi 7 giờ 30, chất lượng Tốt', (tester) async {
    final api = await _pump(tester, const []);
    expect(find.textContaining('đang dùng đêm mẫu'), findsOneWidget);
    expect(find.text('Chưa ghi'), findsOneWidget);
    await tester.tap(find.text('Ghi giấc ngủ đêm qua'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Lưu'));
    await tester.pumpAndSettle();
    expect(find.text('Nhập số giờ đã ngủ.'), findsOneWidget);
    await tester.enterText(find.byKey(const ValueKey('sleep-hours')), '7');
    await tester.enterText(find.byKey(const ValueKey('sleep-minutes')), '30');
    await tester.tap(find.text('Tốt'));
    await tester.tap(find.text('Lưu'));
    await tester.pumpAndSettle();
    expect(api.saved.single, {'date': '2026-11-15', 'sleepMinutes': 450, 'quality': 4, 'note': ''});
    expect(find.byKey(const ValueKey('sleep-2026-11-15')), findsOneWidget);
    expect(find.text('7 giờ 30 · Tốt'), findsOneWidget);
  });

  testWidgets('có dữ liệu: trung bình 7 ngày, chạm một đêm để sửa / xoá', (tester) async {
    final api = await _pump(tester, const [
      SleepLog(date: '2026-11-15', sleepMinutes: 480, quality: 5),
      SleepLog(date: '2026-11-14', sleepMinutes: 360),
      SleepLog(date: '2026-11-01', sleepMinutes: 600),
    ]);
    expect(find.text('7 giờ (2 đêm)'), findsOneWidget, reason: 'đêm 01/11 nằm ngoài 7 ngày');
    await tester.tap(find.byKey(const ValueKey('sleep-2026-11-14')));
    await tester.pumpAndSettle();
    expect(find.text('Sửa giấc ngủ'), findsOneWidget);
    await tester.tap(find.text('Xoá đêm này'));
    await tester.pumpAndSettle();
    expect(api.deleted, ['2026-11-14']);
    expect(find.byKey(const ValueKey('sleep-2026-11-14')), findsNothing);
  });

  testWidgets('320 px, chữ ×2,0: không tràn', (tester) async {
    tester.view.physicalSize = const Size(320, 700);
    tester.view.devicePixelRatio = 1;
    tester.platformDispatcher.textScaleFactorTestValue = 2.0;
    addTearDown(() { tester.view.reset(); tester.platformDispatcher.clearTextScaleFactorTestValue(); });
    await _pump(tester, const [SleepLog(date: '2026-11-15', sleepMinutes: 480, quality: 3, note: 'Thức giấc giữa đêm vì mưa to')]);
    expect(tester.takeException(), isNull);
  });
}

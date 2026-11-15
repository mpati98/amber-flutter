import 'package:amber_flutter/features/amber_brain/providers/brain_status_provider.dart';
import 'package:amber_flutter/features/du_do/widgets/world_home.dart';
import 'package:amber_flutter/features/du_do/world/world_api.dart';
import 'package:amber_flutter/features/du_do/world/world_bridge.dart';
import 'package:amber_flutter/features/kieu_lau/models/music_track.dart';
import 'package:amber_flutter/features/kieu_lau/services/music_api.dart';
import 'package:amber_flutter/shared/providers/auth_provider.dart';
import 'package:amber_flutter/shared/services/token_storage.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../amber_brain/fake_brain.dart';

class _FakeWorldApi extends WorldApi {
  _FakeWorldApi() : super(Dio());
  int summaries = 0;

  @override
  Future<WorldSummary> getSummary({String? since}) async {
    summaries++;
    return const WorldSummary(stats: {}, events: [], cursor: null);
  }

  @override
  Future<Map<String, dynamic>> getWeather() async => const {};
}

class _FakeMusicApi extends MusicApi {
  _FakeMusicApi() : super(Dio(), TokenStorage());

  @override
  Future<List<MusicTrack>> getTracks() async => const [];
}

class _Auth extends AuthController {
  @override
  Future<AuthState> build() async => const Authenticated({'id': 'u', 'email': 'me@example.invalid'});
}

void main() {
  testWidgets('màn khác đè lên → setPaused(true); quay về → setPaused(false) + nạp lại dữ liệu', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final calls = <(String, List<Object?>)>[];
    final bridge = WorldBridge()..attach((m, a) => calls.add((m, a)));
    final api = _FakeWorldApi();
    final router = GoRouter(routes: [
      GoRoute(path: '/', builder: (_, _) => WorldHome(onSwitchTo2D: () {}, bridge: bridge)),
      GoRoute(path: '/finance', builder: (_, _) => const Scaffold(body: Text('TÀI CHÍNH'))),
    ]);
    await tester.pumpWidget(ProviderScope(
      overrides: [
        worldApiProvider.overrideWithValue(api),
        musicApiProvider.overrideWithValue(_FakeMusicApi()),
        brainStatusProvider.overrideWith(() => FixedBrainStatus()),
        authControllerProvider.overrideWith(_Auth.new),
      ],
      child: MaterialApp.router(theme: ThemeData.dark(), routerConfig: router),
    ));
    bridge.receive(const WorldReady());
    await tester.pumpAndSettle();
    expect(api.summaries, 1, reason: 'cảnh sẵn sàng → nạp dữ liệu');

    bridge.receive(const WorldNavigate('/finance'));
    await tester.pumpAndSettle();
    expect(find.text('TÀI CHÍNH'), findsOneWidget);
    expect(calls.where((c) => c.$1 == 'setPaused').last.$2, [true]);

    router.pop();
    await tester.pumpAndSettle();
    expect(calls.where((c) => c.$1 == 'setPaused').last.$2, [false]);
    expect(api.summaries, 2, reason: 'quay về màn chủ → nạp lại');
    bridge.dispose();
  });

  testWidgets('cảnh báo quá chậm / không hỗ trợ → onFallback; bậc bình thường thì không', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final bridge = WorldBridge()..attach((_, _) {});
    final reasons = <String>[];
    await tester.pumpWidget(ProviderScope(
      overrides: [
        worldApiProvider.overrideWithValue(_FakeWorldApi()),
        musicApiProvider.overrideWithValue(_FakeMusicApi()),
        brainStatusProvider.overrideWith(() => FixedBrainStatus()),
        authControllerProvider.overrideWith(_Auth.new),
      ],
      child: MaterialApp(theme: ThemeData.dark(), home: WorldHome(onSwitchTo2D: () {}, onFallback: reasons.add, bridge: bridge)),
    ));
    bridge.receive(const WorldQuality(tier: 'low', extra: 1, fps: 24));
    await tester.pump();
    expect(reasons, isEmpty);
    bridge.receive(const WorldQuality(tier: 'low', extra: 3, fps: 11, tooSlow: true));
    await tester.pump();
    bridge.receive(const WorldUnsupported('software_webgl'));
    await tester.pump();
    expect(reasons, ['too_slow', 'unsupported']);
    bridge.dispose();
  });
}

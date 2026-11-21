import 'package:amber_flutter/features/amber_brain/providers/brain_status_provider.dart';
import 'package:amber_flutter/features/du_do/widgets/world_home.dart';
import 'package:amber_flutter/features/du_do/world/world_api.dart';
import 'package:amber_flutter/features/du_do/world/world_bridge.dart';
import 'package:amber_flutter/features/kieu_lau/models/music_track.dart';
import 'package:amber_flutter/features/kieu_lau/models/activity_log_entry.dart';
import 'package:amber_flutter/features/kieu_lau/models/alert.dart';
import 'package:amber_flutter/features/kieu_lau/services/kieu_lau_api.dart';
import 'package:amber_flutter/features/kieu_lau/services/music_api.dart';
import 'package:amber_flutter/features/nghi_su_duong/models/overview.dart';
import 'package:amber_flutter/features/nghi_su_duong/models/project_summary.dart';
import 'package:amber_flutter/features/nghi_su_duong/models/routine.dart';
import 'package:amber_flutter/features/nghi_su_duong/services/nghi_su_duong_api.dart';
import 'package:amber_flutter/features/tang_kinh_cac/models/document.dart';
import 'package:amber_flutter/features/tang_kinh_cac/models/publication.dart';
import 'package:amber_flutter/features/tang_kinh_cac/models/reading_goal.dart';
import 'package:amber_flutter/features/tang_kinh_cac/services/document_api.dart';
import 'package:amber_flutter/features/tang_kinh_cac/services/publication_api.dart';
import 'package:amber_flutter/features/tang_kinh_cac/services/reading_goal_api.dart';
import 'package:amber_flutter/features/tra_dinh/hoc_tap/models/study_overview.dart';
import 'package:amber_flutter/features/tra_dinh/hoc_tap/services/hoc_tap_api.dart';
import 'package:amber_flutter/shared/providers/auth_provider.dart';
import 'package:amber_flutter/shared/services/token_storage.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../amber_brain/fake_brain.dart';
import '../../tra_dinh/hoc_tap/hoc_tap_test_support.dart' show fixtureMap;

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

class _FakeKieuLauApi extends KieuLauApi {
  _FakeKieuLauApi() : super(Dio());

  @override
  Future<KieuLauNotifications> getNotifications() async => (alerts: const <Alert>[], recentActivity: const <ActivityLogEntry>[]);
}

/// Popup Nghị Sự Đường: 1 cảnh báo âm quỹ + 1 routine chưa xong.
class _FakeNsdApi extends NghiSuDuongApi {
  _FakeNsdApi() : super(Dio());

  @override
  Future<FinanceOverview> getFinanceOverview({int? year}) async =>
      const FinanceOverview(currentBalance: -1000, totalIncome: 0, totalExpense: 0);

  @override
  Future<DuAnSummary> getDuAnSummary() async => const DuAnSummary(projects: [], attention: []);

  @override
  Future<List<Routine>> getRoutines({String? date}) async => const [];
}

class _FakePublicationApi extends PublicationApi {
  _FakePublicationApi() : super(Dio());

  @override
  Future<List<Publication>> getPublications({PublicationStatus? status, PublicationFormat? format, String? search}) async => const [];
}

class _FakeDocumentApi extends DocumentApi {
  _FakeDocumentApi() : super(Dio());

  @override
  Future<List<Document>> getDocuments({DocumentType? type, String? search, bool? pinned, String? topicId}) async => const [];
}

class _FakeGoalApi extends ReadingGoalApi {
  _FakeGoalApi() : super(Dio());

  @override
  Future<ReadingGoal> getReadingGoal(int year) async => ReadingGoal(year: year, booksRead: 0, pagesRead: 0);
}

class _FakeHocTapApi extends HocTapApi {
  _FakeHocTapApi() : super(Dio());

  @override
  Future<StudyOverview> getOverview() async => StudyOverview.fromJson(fixtureMap('overview_cards'));
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
        kieuLauApiProvider.overrideWithValue(_FakeKieuLauApi()),
        nghiSuDuongApiProvider.overrideWithValue(_FakeNsdApi()),
        publicationApiProvider.overrideWithValue(_FakePublicationApi()),
        documentApiProvider.overrideWithValue(_FakeDocumentApi()),
        readingGoalApiProvider.overrideWithValue(_FakeGoalApi()),
        hocTapApiProvider.overrideWithValue(_FakeHocTapApi()),
        brainStatusProvider.overrideWith(() => FixedBrainStatus()),
        authControllerProvider.overrideWith(_Auth.new),
      ],
      child: MaterialApp.router(theme: ThemeData.dark(), routerConfig: router),
    ));
    bridge.receive(const WorldReady());
    await tester.pumpAndSettle();
    expect(api.summaries, 1, reason: 'cảnh sẵn sàng → nạp dữ liệu');
    final notices = {for (final c in calls.where((c) => c.$1 == 'setTowerNotices')) c.$2.first: c.$2.last as List};
    expect(notices['nghisu']!.map((n) => (n as Map)['lvl']), ['bad'], reason: 'cùng nguồn với khung Cần chú ý: âm quỹ');
    expect(notices['tangkinh']!.map((n) => (n as Map)['text']), ['Chưa đặt mục tiêu đọc năm ${DateTime.now().year}']);
    expect(notices['tradinh'], isNotEmpty, reason: 'Trà Đình: từ Tổng quan học tập');
    expect((notices['tradinh']!.first as Map)['text'], startsWith('Hôm nay '));

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
        kieuLauApiProvider.overrideWithValue(_FakeKieuLauApi()),
        nghiSuDuongApiProvider.overrideWithValue(_FakeNsdApi()),
        publicationApiProvider.overrideWithValue(_FakePublicationApi()),
        documentApiProvider.overrideWithValue(_FakeDocumentApi()),
        readingGoalApiProvider.overrideWithValue(_FakeGoalApi()),
        hocTapApiProvider.overrideWithValue(_FakeHocTapApi()),
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

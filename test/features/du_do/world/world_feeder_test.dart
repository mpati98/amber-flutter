import 'package:amber_flutter/features/du_do/world/world_api.dart';
import 'package:amber_flutter/features/du_do/world/world_bridge.dart';
import 'package:amber_flutter/features/du_do/world/world_feeder.dart';
import 'package:amber_flutter/features/kieu_lau/models/music_track.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:amber_flutter/features/nghi_su_duong/utils/nsd_notices.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _FakeWorldApi extends WorldApi {
  _FakeWorldApi({this.summary, this.failWeather = false}) : super(Dio());

  final WorldSummary? summary;
  final bool failWeather;
  final sinceSeen = <String?>[];

  @override
  Future<WorldSummary> getSummary({String? since}) async {
    sinceSeen.add(since);
    if (summary == null) throw DioException(requestOptions: RequestOptions());
    return summary!;
  }

  @override
  Future<Map<String, dynamic>> getWeather() async {
    if (failWeather) throw DioException(requestOptions: RequestOptions());
    return {'code': 61, 'temp': 27.0, 'sunrise': 5.75, 'sunset': 17.5, 'source': 'Open-Meteo'};
  }
}

WorldActivity _a(String t, [String from = 'nghisu']) => WorldActivity(from: from, lvl: 'ok', text: t);

MusicTrack _track(String title, String? url) => MusicTrack.fromJson({
  'id': title, 'title': title, 'artist': null, 'blobUrl': 'x', 'blobPathname': 'x', 'sizeBytes': 1, 'position': 0, 'streamUrl': url,
});

void main() {
  late List<(String, List<Object?>)> calls;
  late WorldBridge bridge;

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    calls = [];
    bridge = WorldBridge()..attach((m, a) => calls.add((m, a)));
    bridge.receive(const WorldReady());
  });

  test('đẩy chỉ số, sự kiện, thời tiết, nhạc; lưu con trỏ và gửi lại ở lần sau', () async {
    final api = _FakeWorldApi(summary: WorldSummary(
      stats: {'kyNang': {'v': 70, 'src': 'Trung bình 2 kỹ năng'}},
      events: [_a('Chi 50.000đ'), _a('Học 30 phút', 'tradinh')],
      cursor: '2026-11-15T03:00:00.123456Z',
    ));
    final f = WorldFeeder(bridge: bridge, api: api, loadTracks: () async => [_track('Bài A', 'https://api/x?token=t'), _track('Không URL', null)]);
    await f.refresh();
    expect(calls.map((c) => c.$1), containsAll(['setStats', 'push', 'setWeather', 'music.setLibrary']));
    expect(calls.where((c) => c.$1 == 'push').map((c) => (c.$2.first as Map)['text']), ['Chi 50.000đ', 'Học 30 phút']);
    final lib = calls.firstWhere((c) => c.$1 == 'music.setLibrary').$2.first as List;
    expect(lib.length, 1, reason: 'bỏ bài không có streamUrl');
    expect((await SharedPreferences.getInstance()).getString(worldCursorPrefKey), '2026-11-15T03:00:00.123456Z');
    await f.refresh();
    expect(api.sinceSeen, [null, '2026-11-15T03:00:00.123456Z']);
  });

  test('phần lỗi bị bỏ qua, phần khác vẫn chạy; lỗi tóm tắt thì giữ con trỏ cũ', () async {
    SharedPreferences.setMockInitialValues({worldCursorPrefKey: 'cu'});
    final f = WorldFeeder(bridge: bridge, api: _FakeWorldApi(failWeather: true), loadTracks: () async => throw Exception('x'));
    await f.refresh();
    expect(calls.map((c) => c.$1), isEmpty);
    expect((await SharedPreferences.getInstance()).getString(worldCursorPrefKey), 'cu');
  });

  test('kinh tế: chuyển nguyên khối economy cho setEconomy; thiếu thì gửi null để gỡ', () async {
    final economy = {
      'stamina': {'v': 61.6, 'max': 88},
      'nguyenTe': {'balance': 42.4, 'earnedToday': 18.8, 'dailyCap': 100},
      'shadow': true,
      'log': [
        {'text': 'Học: Tiếng Anh', 'nguyenTe': 10, 'stamina': -3, 'at': '2026-11-15T03:00:00.000Z'},
      ],
    };
    final parsed = WorldSummary.fromJson({'stats': {}, 'events': [], 'cursor': null, 'economy': economy});
    await WorldFeeder(bridge: bridge, api: _FakeWorldApi(summary: parsed), loadTracks: () async => []).refresh();
    final call = calls.firstWhere((c) => c.$1 == 'setEconomy');
    expect(call.$2.single, economy);

    calls.clear();
    final old = WorldSummary.fromJson({'stats': {}, 'events': [], 'cursor': null});
    expect(old.economy, isNull);
    await WorldFeeder(bridge: bridge, api: _FakeWorldApi(summary: old), loadTracks: () async => []).refresh();
    expect(calls.firstWhere((c) => c.$1 == 'setEconomy').$2.single, isNull);
  });

  test('pickEvents: quá 6 thì gộp phần cũ thành một dòng', () {
    final many = [for (var i = 0; i < 10; i++) _a('việc $i')];
    final picked = pickEvents(many);
    expect(picked.length, 7);
    expect(picked.first['text'], contains('4 hoạt động khác'));
    expect(picked.last['text'], 'việc 9');
    expect(pickEvents(many.sublist(0, 3)).length, 3);
  });

  test('Nghị Sự Đường: setTowerNotices("nghisu", tối đa 3 dòng {text, lvl}); rỗng vẫn gửi để cảnh hiện "Mọi thứ ổn"; lỗi thì bỏ qua', () async {
    SharedPreferences.setMockInitialValues({});
    final notices = [for (var i = 0; i < 5; i++) NsdNotice(id: 'n$i', title: 'Cảnh báo $i', level: i == 0 ? NsdNoticeLevel.bad : NsdNoticeLevel.warn)];
    await WorldFeeder(bridge: bridge, api: _FakeWorldApi(), loadTracks: () async => [], loadNsdNotices: () async => notices).refresh();
    final call = calls.firstWhere((c) => c.$1 == 'setTowerNotices').$2;
    expect(call.first, 'nghisu');
    expect(call.last, [
      {'text': 'Cảnh báo 0', 'lvl': 'bad'},
      {'text': 'Cảnh báo 1', 'lvl': 'warn'},
      {'text': 'Cảnh báo 2', 'lvl': 'warn'},
    ]);

    calls.clear();
    await WorldFeeder(bridge: bridge, api: _FakeWorldApi(), loadTracks: () async => [], loadNsdNotices: () async => const []).refresh();
    expect(calls.firstWhere((c) => c.$1 == 'setTowerNotices').$2, ['nghisu', <Object?>[]]);

    calls.clear();
    await WorldFeeder(bridge: bridge, api: _FakeWorldApi(), loadTracks: () async => [], loadNsdNotices: () async => throw Exception('x')).refresh();
    expect(calls.where((c) => c.$1 == 'setTowerNotices'), isEmpty);
  });
}

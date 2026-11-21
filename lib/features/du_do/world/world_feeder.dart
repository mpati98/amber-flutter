import 'package:shared_preferences/shared_preferences.dart';

import '../../kieu_lau/models/music_track.dart';
import '../../nghi_su_duong/utils/nsd_notices.dart';
import 'world_api.dart';
import 'world_bridge.dart';

/// Mốc nhật ký hoạt động đã đẩy vào cảnh (con trỏ của backend, có micro giây).
const worldCursorPrefKey = 'world.cursor';

/// Quá lâu thì bỏ phần cảnh báo Nghị Sự Đường của lần nạp này (lần sau thử lại).
const nsdNoticesTimeout = Duration(seconds: 15);

/// Số dòng cảnh báo tối đa trên popup một tòa của cảnh.
const maxTowerNotices = 3;

/// Nhiều hơn số này thì gộp phần cũ thành một dòng, tránh dội hàng loạt toast + cầu sáng.
const maxWorldEvents = 6;

/// Nạp dữ liệu thật vào cảnh 3D — gọi khi có "trigger" (cảnh sẵn sàng, quay lại màn chủ, app trở lại foreground), không polling.
/// Mỗi phần lỗi riêng thì bỏ qua phần đó: cảnh vẫn chạy với phần còn lại.
class WorldFeeder {
  WorldFeeder({required this.bridge, required this.api, required this.loadTracks, this.prefs, this.loadNsdNotices});

  final WorldBridge bridge;
  final WorldApi api;
  final Future<List<MusicTrack>> Function() loadTracks;
  final Future<SharedPreferences> Function()? prefs;

  /// Cảnh báo của Nghị Sự Đường (cùng nguồn với khung "Cần chú ý" — `fetchNsdNotices`) cho popup của tòa trong cảnh.
  final Future<List<NsdNotice>> Function()? loadNsdNotices;

  bool _busy = false;

  Future<void> refresh() async {
    if (_busy) return;
    _busy = true;
    try {
      await Future.wait([_summary(), _weather(), _music(), _nsd()]);
    } finally {
      _busy = false;
    }
  }

  Future<void> _summary() async {
    final p = await (prefs ?? SharedPreferences.getInstance)();
    try {
      final s = await api.getSummary(since: p.getString(worldCursorPrefKey));
      bridge.call('setStats', [s.stats]);
      // Luôn gửi (kể cả null) để cảnh gỡ thẻ cũ khi backend không tính được kinh tế.
      bridge.call('setEconomy', [s.economy]);
      for (final e in pickEvents(s.events)) {
        bridge.call('push', [e]);
      }
      if (s.cursor != null) await p.setString(worldCursorPrefKey, s.cursor!);
    } catch (_) {
      // giữ con trỏ cũ: lần sau đọc lại đúng từ chỗ đó
    }
  }

  Future<void> _weather() async {
    try {
      final w = await api.getWeather();
      if (w['code'] != null) bridge.call('setWeather', [w]);
    } catch (_) {}
  }

  /// Popup Nghị Sự Đường chỉ hiện tối đa [maxTowerNotices] dòng; gửi cả danh sách rỗng để cảnh hiện "Mọi thứ ổn".
  Future<void> _nsd() async {
    final load = loadNsdNotices;
    if (load == null) return;
    try {
      // Có giới hạn thời gian: 4 request gộp lại, một cái treo không được giữ cờ _busy (chặn mọi lần nạp sau).
      final notices = await load().timeout(nsdNoticesTimeout);
      bridge.call('setTowerNotices', [
        'nghisu',
        [for (final n in notices.take(maxTowerNotices)) n.toWorld()],
      ]);
    } catch (_) {}
  }

  Future<void> _music() async {
    try {
      final tracks = await loadTracks();
      // một tham số duy nhất là mảng track: setLibrary([{title, artist, url}, …])
      bridge.call('music.setLibrary', [
        [
          for (final t in tracks)
            if (t.streamUrl != null) {'title': t.title, 'artist': t.artist, 'url': t.streamUrl},
        ],
      ]);
    } catch (_) {}
  }
}

/// Sự kiện cũ trước. Quá [maxWorldEvents] thì một dòng "… và N hoạt động khác" rồi tới [maxWorldEvents] dòng mới nhất.
List<Map<String, Object?>> pickEvents(List<WorldActivity> events) {
  if (events.length <= maxWorldEvents) return [for (final e in events) e.toPush()];
  final skipped = events.length - maxWorldEvents;
  return [
    {'from': 'kieulau', 'lvl': 'info', 'text': 'Trong lúc bạn vắng: $skipped hoạt động khác (xem ở Kiều Lâu)'},
    for (final e in events.sublist(skipped)) e.toPush(),
  ];
}

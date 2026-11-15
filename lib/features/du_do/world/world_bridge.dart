import 'dart:async';

/// Sự kiện iframe Âm Dương Giới gửi lên (`{source: 'amber-world', type, ...}`).
sealed class WorldEvent {
  const WorldEvent();
}

/// Thế giới đã dựng xong, nhận lệnh được.
class WorldReady extends WorldEvent {
  const WorldReady();
}

/// Bảng chi tiết công trình mở / đóng ([towerId] null khi đóng).
class WorldSheet extends WorldEvent {
  const WorldSheet({required this.open, this.towerId});
  final bool open;
  final String? towerId;
}

/// Thế giới xin điều hướng vào màn 2D (vd nút trong bảng chi tiết).
class WorldNavigate extends WorldEvent {
  const WorldNavigate(this.path);
  final String path;
}

/// Bậc chất lượng cảnh đang chạy (Giai đoạn 4). [tooSlow]: bậc thấp nhất vẫn quá chậm → nên chuyển sang 2D.
class WorldQuality extends WorldEvent {
  const WorldQuality({required this.tier, required this.extra, this.fps, this.tooSlow = false});
  final String tier;
  final int extra;
  final double? fps;
  final bool tooSlow;
}

/// Thiết bị không nên chạy 3D (vd WebGL chạy bằng phần mềm) — cảnh không dựng.
class WorldUnsupported extends WorldEvent {
  const WorldUnsupported(this.reason);
  final String reason;
}

/// Cầu nối Flutter ↔ iframe. Gọi [call] trước khi iframe sẵn sàng thì lệnh được giữ lại và gửi khi nhận [WorldReady].
/// Tên lệnh và tham số theo hợp đồng `window.AmberWorld` (push, setStat, select, setMode, setWeather, music.*).
class WorldBridge {
  final _events = StreamController<WorldEvent>.broadcast();
  final _pending = <(String, List<Object?>)>[];
  void Function(String method, List<Object?> args)? _send;
  bool _ready = false;

  Stream<WorldEvent> get events => _events.stream;
  bool get ready => _ready;

  void call(String method, [List<Object?> args = const []]) {
    if (_ready && _send != null) {
      _send!(method, args);
    } else {
      _pending.add((method, args));
    }
  }

  /// Dùng nội bộ bởi world_view_web.dart.
  void attach(void Function(String method, List<Object?> args) send) => _send = send;

  /// Dùng nội bộ bởi world_view_web.dart (và test).
  void receive(WorldEvent e) {
    if (e is WorldReady) {
      _ready = true;
      for (final (m, a) in _pending) {
        _send?.call(m, a);
      }
      _pending.clear();
    }
    _events.add(e);
  }

  void dispose() {
    _send = null;
    _ready = false;
    _pending.clear();
    _events.close();
  }
}

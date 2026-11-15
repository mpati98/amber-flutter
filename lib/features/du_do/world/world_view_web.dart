import 'dart:js_interop';
import 'dart:ui_web' as ui_web;

import 'package:material_ui/material_ui.dart';
import 'package:web/web.dart' as web;

import 'world_bridge.dart';

bool? _supported;

/// Trình duyệt có WebGL2 thì chạy cảnh 3D; không thì màn chủ giữ lưới 2D.
bool worldSupported() {
  return _supported ??= (() {
    try {
      final canvas = web.document.createElement('canvas') as web.HTMLCanvasElement;
      return canvas.getContext('webgl2') != null;
    } catch (_) {
      return false;
    }
  })();
}

var _viewSeq = 0;

/// iframe `world/index.html` (cùng nguồn với app) phủ kín vùng của widget.
/// Mỗi lần vào màn là một iframe mới; rời màn thì Flutter gỡ iframe, trình duyệt thu hồi toàn bộ WebGL / âm thanh.
class WorldView extends StatefulWidget {
  const WorldView({super.key, required this.bridge, this.retry = false});

  final WorldBridge bridge;

  /// Người dùng bật lại 3D sau khi bị chuyển sang 2D → cảnh quên bậc đã hạ, đo lại từ đầu.
  final bool retry;

  @override
  State<WorldView> createState() => _WorldViewState();
}

class _WorldViewState extends State<WorldView> {
  late final String _viewType = 'amber-world-${_viewSeq++}';
  web.HTMLIFrameElement? _frame;
  JSFunction? _onMessage;

  @override
  void initState() {
    super.initState();
    ui_web.platformViewRegistry.registerViewFactory(_viewType, (int _) {
      final frame = web.document.createElement('iframe') as web.HTMLIFrameElement
        ..src = widget.retry ? 'world/index.html?retry=1' : 'world/index.html'
        ..allow = 'autoplay'
        ..title = 'Âm Dương Giới';
      frame.style
        ..border = '0'
        ..width = '100%'
        ..height = '100%'
        ..display = 'block';
      _frame = frame;
      return frame;
    });

    widget.bridge.attach((method, args) {
      final msg = {'source': 'amber-flutter', 'type': 'call', 'method': method, 'args': args}.jsify();
      _frame?.contentWindow?.postMessage(msg, web.window.location.origin.toJS);
    });

    _onMessage = ((web.MessageEvent e) {
      if (e.origin != web.window.location.origin) return;
      if (_frame == null || e.source != _frame!.contentWindow) return;
      final data = e.data.dartify();
      if (data is! Map || data['source'] != 'amber-world') return;
      final event = switch (data['type']) {
        'ready' => const WorldReady(),
        'sheet' => WorldSheet(open: data['open'] == true, towerId: data['id'] as String?),
        'navigate' when data['path'] is String => WorldNavigate(data['path'] as String),
        'quality' => WorldQuality(
          tier: data['tier'] as String? ?? '',
          extra: (data['extra'] as num?)?.toInt() ?? 0,
          fps: (data['fps'] as num?)?.toDouble(),
          tooSlow: data['tooSlow'] == true,
        ),
        'unsupported' => WorldUnsupported(data['reason'] as String? ?? ''),
        _ => null,
      };
      if (event != null) widget.bridge.receive(event);
    }).toJS;
    web.window.addEventListener('message', _onMessage);
  }

  @override
  void dispose() {
    web.window.removeEventListener('message', _onMessage);
    _frame?.src = 'about:blank';
    _frame = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => HtmlElementView(viewType: _viewType);
}

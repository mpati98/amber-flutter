import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../shared/theme/design_tokens.dart';
import '../../amber_brain/widgets/amber_chat_dock.dart';
import '../../auth/widgets/account_menu.dart';
import '../../kieu_lau/services/music_api.dart';
import '../world/world_api.dart';
import '../world/world_bridge.dart';
import '../world/world_feeder.dart';
import '../world/world_view.dart';

/// Màn chủ dạng 3D: cảnh Âm Dương Giới phủ kín (HUD, nhạc, thời tiết nằm trong cảnh).
/// Góc trái dưới (góc trống của cảnh): nút chat Amber, logo mở menu tài khoản, nút về lưới 2D.
/// Bảng chi tiết công trình trên màn hẹp (< 760, khớp CSS của cảnh) trải hết đáy → ẩn các nút này khi bảng mở.
class WorldHome extends ConsumerStatefulWidget {
  const WorldHome({super.key, required this.onSwitchTo2D, this.bridge});

  final VoidCallback onSwitchTo2D;

  /// Cho phép bên ngoài (Giai đoạn 2: lớp dữ liệu) đẩy dữ liệu vào cảnh. Null thì tự tạo.
  final WorldBridge? bridge;

  @override
  ConsumerState<WorldHome> createState() => _WorldHomeState();
}

class _WorldHomeState extends ConsumerState<WorldHome> {
  late final WorldBridge _bridge = widget.bridge ?? WorldBridge();
  late final WorldFeeder _feeder = WorldFeeder(
    bridge: _bridge,
    api: ref.read(worldApiProvider),
    loadTracks: () => ref.read(musicApiProvider).getTracks(),
  );
  late final AppLifecycleListener _life;
  StreamSubscription<WorldEvent>? _sub;
  bool _sheetOpen = false;
  bool _routeCurrent = true;
  bool _appVisible = true;

  /// Cảnh chỉ vẽ khi màn chủ đang ở trên cùng và app đang hiện (tiết kiệm pin; âm thanh của cảnh vẫn chạy).
  void _syncPaused() => _bridge.call('setPaused', [!(_routeCurrent && _appVisible)]);

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // ModalRoute.of đăng ký phụ thuộc: có màn khác đè lên / gỡ xuống thì hàm này chạy lại
    final current = ModalRoute.of(context)?.isCurrent ?? true;
    if (current == _routeCurrent) return;
    _routeCurrent = current;
    _syncPaused();
    if (current && _bridge.ready) _feeder.refresh(); // trigger: quay về màn chủ
  }

  @override
  void initState() {
    super.initState();
    // Trigger nạp dữ liệu: app trở lại foreground; cảnh sẵn sàng; quay về màn chủ (didChangeDependencies)
    _life = AppLifecycleListener(
      onHide: () { _appVisible = false; _syncPaused(); },
      onShow: () { _appVisible = true; _syncPaused(); },
      onResume: () { if (_bridge.ready) _feeder.refresh(); },
    );
    _sub = _bridge.events.listen((e) {
      if (!mounted) return;
      switch (e) {
        case WorldSheet(:final open):
          setState(() => _sheetOpen = open);
        case WorldNavigate(:final path):
          context.push(path); // tạm dừng + nạp lại khi quay về: didChangeDependencies
        case WorldReady():
          _feeder.refresh();
      }
    });
  }

  @override
  void dispose() {
    _sub?.cancel();
    _life.dispose();
    if (widget.bridge == null) _bridge.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D1426),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final hideControls = _sheetOpen && constraints.maxWidth < 760;
          final edge = constraints.maxWidth >= DesignLayout.medium ? 20.0 : 12.0;
          final bottomInset = MediaQuery.paddingOf(context).bottom;
          return AmberChatDock(
            left: true,
            hideButton: hideControls,
            child: Stack(
              children: [
                Positioned.fill(child: WorldView(bridge: _bridge)),
                if (!hideControls)
                  Positioned(
                    left: edge,
                    bottom: edge + bottomInset + 52 + 10,
                    child: Row(
                      spacing: 8,
                      children: [
                        const _Glass(child: Padding(padding: EdgeInsets.all(6), child: AccountMenu())),
                        _Glass(
                          child: InkWell(
                            key: const ValueKey('world-switch-2d'),
                            borderRadius: BorderRadius.circular(999),
                            onTap: widget.onSwitchTo2D,
                            child: const Padding(
                              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 9),
                              child: Text('2D', style: TextStyle(color: DesignColors.text, fontWeight: FontWeight.w600)),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}

/// Nền kính mờ giống HUD của cảnh (rgba(14,18,32,.62), viền trắng 12%).
class _Glass extends StatelessWidget {
  const _Glass({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0x9E0E1220),
      shape: const StadiumBorder(side: BorderSide(color: Color(0x1FFFFFFF))),
      clipBehavior: Clip.antiAlias,
      child: child,
    );
  }
}

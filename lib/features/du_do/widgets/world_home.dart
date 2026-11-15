import 'dart:async';

import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../shared/theme/design_tokens.dart';
import '../../amber_brain/widgets/amber_chat_dock.dart';
import '../../auth/widgets/account_menu.dart';
import '../world/world_bridge.dart';
import '../world/world_view.dart';

/// Màn chủ dạng 3D: cảnh Âm Dương Giới phủ kín (HUD, nhạc, thời tiết nằm trong cảnh).
/// Góc trái dưới (góc trống của cảnh): nút chat Amber, logo mở menu tài khoản, nút về lưới 2D.
/// Bảng chi tiết công trình trên màn hẹp (< 760, khớp CSS của cảnh) trải hết đáy → ẩn các nút này khi bảng mở.
class WorldHome extends StatefulWidget {
  const WorldHome({super.key, required this.onSwitchTo2D, this.bridge});

  final VoidCallback onSwitchTo2D;

  /// Cho phép bên ngoài (Giai đoạn 2: lớp dữ liệu) đẩy dữ liệu vào cảnh. Null thì tự tạo.
  final WorldBridge? bridge;

  @override
  State<WorldHome> createState() => _WorldHomeState();
}

class _WorldHomeState extends State<WorldHome> {
  late final WorldBridge _bridge = widget.bridge ?? WorldBridge();
  StreamSubscription<WorldEvent>? _sub;
  bool _sheetOpen = false;

  @override
  void initState() {
    super.initState();
    _sub = _bridge.events.listen((e) {
      if (!mounted) return;
      switch (e) {
        case WorldSheet(:final open):
          setState(() => _sheetOpen = open);
        case WorldNavigate(:final path):
          context.push(path);
        case WorldReady():
          break;
      }
    });
  }

  @override
  void dispose() {
    _sub?.cancel();
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

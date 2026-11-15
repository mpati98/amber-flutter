import 'package:material_ui/material_ui.dart';

import 'world_bridge.dart';

/// Ngoài web: không có cảnh 3D.
bool worldSupported() => false;

class WorldView extends StatelessWidget {
  const WorldView({super.key, required this.bridge});

  final WorldBridge bridge;

  @override
  Widget build(BuildContext context) => const SizedBox.shrink();
}

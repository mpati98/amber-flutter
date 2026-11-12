import 'package:material_ui/material_ui.dart';

import '../theme/design_tokens.dart';

/// Màu viền của [ScrollCard] — tương ứng prop `glow` bên web cũ, quy về bảng màu của bộ thiết kế mới.
enum ScrollCardGlow {
  /// Viền panel thường.
  yugen(DesignColors.panelBorder),

  /// Viền đỏ mờ (cảnh báo / âm).
  shuiro(Color(0x73FF7B7B)),

  /// Viền vàng mờ (mục nổi bật).
  kincha(Color(0x73F0D68A));

  const ScrollCardGlow(this.color);

  final Color color;
}

/// Thẻ của các màn con cũ, vẽ theo bộ thiết kế mới (design/DESIGN.md) để nằm hài hoà trong `ListFrame` / `DesignPage`:
/// nền panel `#0e1430`, viền theo [glow], bo 10, lề trong 14. Chữ mặc định Gelasio màu chữ chính.
///
/// Material (không phải Container tô nền) để ListTile / InkWell bên trong vẽ được hiệu ứng bấm.
class ScrollCard extends StatelessWidget {
  const ScrollCard({
    super.key,
    required this.child,
    this.glow = ScrollCardGlow.yugen,
  });

  final Widget child;
  final ScrollCardGlow glow;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: DesignColors.panel,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: BorderSide(color: glow.color),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: DefaultTextStyle.merge(style: DesignText.body, child: child),
      ),
    );
  }
}

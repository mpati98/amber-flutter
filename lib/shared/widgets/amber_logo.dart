import 'package:material_ui/material_ui.dart';

/// Logo Amber (vòng vàng), cùng ảnh với icon app. Ảnh đã có quầng sáng sẵn nên không thêm bóng.
class AmberLogo extends StatelessWidget {
  const AmberLogo({super.key, this.size = 36});

  static const asset = 'assets/images/amber_logo.png';

  final double size;

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      asset,
      key: const ValueKey('amber-logo'),
      width: size,
      height: size,
      filterQuality: FilterQuality.medium,
      semanticLabel: 'Amber',
      // Thiếu ảnh (test không nạp asset) vẫn giữ đúng chỗ.
      errorBuilder: (_, _, _) => SizedBox.square(dimension: size),
    );
  }
}

import 'package:google_fonts/google_fonts.dart';
import 'package:material_ui/material_ui.dart';

/// Màu + chữ của bộ thiết kế mới (design/DESIGN.md, bản mẫu design/ref/*.html).
/// Hex lấy nguyên văn từ bản mẫu; các màn đã chuyển sang bố cục mới dùng token này thay cho [AppColors].
abstract final class DesignColors {
  static const bgTop = Color(0xFF070B18);
  static const bgBottom = Color(0xFF0C1230);

  /// Ánh vàng góc trên trái của nền (`#f3e6b333`).
  static const bgGlow = Color(0x33F3E6B3);

  static const text = Color(0xFFE8E6F0);
  static const muted = Color(0xFFA9B0D0);
  static const gold = Color(0xFFF0D68A);
  static const danger = Color(0xFFFF7B7B);

  // Không có trong DESIGN.md (chỉ có đỏ): chọn cùng độ sáng với đỏ để đọc được trên nền panel. Dùng cho toast, thẻ kết quả.
  static const success = Color(0xFF7EE0A8);
  static const warning = Color(0xFFF5B86B);
  static const info = Color(0xFF8FA8FF);

  /// Nền thanh trên, khối tổng quan, ô trong khung.
  static const panel = Color(0xFF0E1430);
  static const panelHover = Color(0xFF151D44);
  static const panelBorder = Color(0xFF2C3766);
  static const topBarBorder = Color(0xFF26305A);

  /// Đường kẻ giữa các dòng của khối tổng quan.
  static const rowDivider = Color(0xFF1F2850);

  /// Khung danh sách.
  static const frame = Color(0xFF0A1028);
  static const frameBorder = Color(0xFF3A4580);
}

/// Bản mẫu dùng Georgia, nhưng Flutter web không dùng được font cài trên máy (kể cả iPhone) nên rơi về Roboto.
/// Thay bằng Gelasio (Google Fonts, thiết kế khớp số đo với Georgia), tải qua google_fonts như Inter của theme.
///
/// google_fonts đặt tên font theo từng độ đậm: `copyWith(fontWeight: bold)` trên [body] chỉ ra chữ đậm giả,
/// nên chữ đậm phải dùng [bold] (hoặc [serif] với `fontWeight`) để tải đúng file Gelasio Bold.
abstract final class DesignText {
  static TextStyle serif({double? fontSize, FontWeight? fontWeight, Color? color, double? height, double? letterSpacing}) =>
      GoogleFonts.gelasio(fontSize: fontSize, fontWeight: fontWeight, color: color, height: height, letterSpacing: letterSpacing);

  /// `font: 14px/1.45 Georgia,serif`.
  static final body = serif(fontSize: 14, height: 1.45, color: DesignColors.text);

  /// Chữ đậm, cỡ + màu kế thừa từ DefaultTextStyle.
  static final bold = serif(fontWeight: FontWeight.w700);

  static const muted = TextStyle(fontSize: 13, color: DesignColors.muted);
}

/// Bề ngang theo cỡ màn: điện thoại giữ đúng bản mẫu (lề 14), máy tính bảng / web rộng hơn và có lề lớn hơn.
abstract final class DesignLayout {
  /// Dưới mốc này là điện thoại (bố cục bản mẫu).
  static const double medium = 600;

  /// Từ mốc này là màn rộng (web trên máy tính): tổng quan và khung nội dung đặt cạnh nhau.
  static const double wide = 1024;

  static double maxContentWidth(double screenWidth) =>
      screenWidth >= wide ? 1120 : (screenWidth >= medium ? 760 : screenWidth);

  static double gutter(double screenWidth) => screenWidth >= medium ? 24 : 14;
}

/// Nền chung: gradient dọc + ánh vàng góc trên trái, chữ mặc định Gelasio.
class DesignBackground extends StatelessWidget {
  const DesignBackground({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [DesignColors.bgTop, DesignColors.bgBottom],
        ),
      ),
      child: CustomPaint(
        painter: const _GlowPainter(),
        child: DefaultTextStyle.merge(style: DesignText.body, child: child),
      ),
    );
  }
}

/// `radial-gradient(circle at 15% 6%, #f3e6b333 0, transparent 120px)`.
class _GlowPainter extends CustomPainter {
  const _GlowPainter();

  @override
  void paint(Canvas canvas, Size size) {
    // Neo theo cột nội dung (giữa màn khi web rộng), không theo mép màn — trên màn 1920 ánh sáng mới nằm cạnh tiêu đề.
    final contentWidth = size.width.clamp(0, DesignLayout.maxContentWidth(size.width)).toDouble();
    final left = (size.width - contentWidth) / 2;
    final center = Offset(left + contentWidth * 0.15, (size.height * 0.06).clamp(0, 56).toDouble());
    const radius = 120.0;
    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..shader = const RadialGradient(
          colors: [DesignColors.bgGlow, Color(0x00F3E6B3)],
        ).createShader(Rect.fromCircle(center: center, radius: radius)),
    );
  }

  @override
  bool shouldRepaint(_GlowPainter oldDelegate) => false;
}

import 'package:material_ui/material_ui.dart';

/// Nền màn đăng nhập theo design/ref/login.html: trời đêm có sao, trăng góc trên trái, một dải núi, mặt nước từ 62%.
/// Toạ độ theo % khung như CSS của bản mẫu.
class LoginScene extends StatelessWidget {
  const LoginScene({super.key});

  @override
  Widget build(BuildContext context) {
    final top = MediaQuery.paddingOf(context).top; // trăng không nằm dưới tai thỏ
    return Stack(
      children: [
        const Positioned.fill(child: CustomPaint(painter: _ScenePainter())),
        Positioned(
          left: 22,
          top: top + 18,
          child: Container(
            key: const ValueKey('login-moon'),
            width: 46,
            height: 46,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Color(0xFFF3E6B3),
              boxShadow: [BoxShadow(color: Color(0x44F3E6B3), blurRadius: 40, spreadRadius: 18)],
            ),
          ),
        ),
      ],
    );
  }
}

class _ScenePainter extends CustomPainter {
  const _ScenePainter();

  // linear-gradient(#050816 0%, #0c1230 45%, #1a2250 62%, #0a0f26 62%, #0b1030 100%): 62% là chân trời, cắt cứng.
  static const _colors = [Color(0xFF050816), Color(0xFF0C1230), Color(0xFF1A2250), Color(0xFF0A0F26), Color(0xFF0B1030)];
  static const _stops = [0.0, 0.45, 0.62, 0.62, 1.0];

  // Ô sao 440×120 lặp lại: (x, y, bán kính, độ đục) lấy từ background-image của .stars.
  static const _tile = Size(440, 120);
  static const _stars = [
    (20.0, 30.0, 1.0, 0x88),
    (90.0, 80.0, 1.0, 0x99),
    (150.0, 20.0, 1.5, 0xFF),
    (230.0, 60.0, 1.0, 0x88),
    (330.0, 35.0, 1.0, 0xAA),
    (400.0, 90.0, 1.5, 0x99),
  ];

  // clip-path của .mt (% của dải núi).
  static const _mountain = [
    (0, 100), (0, 60), (12, 20), (25, 55), (40, 10), (55, 50), (70, 15), (85, 55), (100, 30), (100, 100), //
  ];

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    canvas.drawRect(
      rect,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: _colors,
          stops: _stops,
        ).createShader(rect),
    );

    // .stars phủ từ đỉnh tới 62% (inset: 0 0 38% 0).
    final starsBottom = size.height * 0.62;
    canvas.save();
    canvas.clipRect(Rect.fromLTRB(0, 0, size.width, starsBottom));
    for (var ty = 0.0; ty < starsBottom; ty += _tile.height) {
      for (var tx = 0.0; tx < size.width; tx += _tile.width) {
        for (final (x, y, r, a) in _stars) {
          canvas.drawCircle(Offset(tx + x, ty + y), r, Paint()..color = Colors.white.withAlpha(a));
        }
      }
    }
    canvas.restore();

    // .mt: top 52%, cao 12%, nền #1a2252.
    final box = Rect.fromLTWH(0, size.height * 0.52, size.width, size.height * 0.12);
    final path = Path();
    for (final (i, (px, py)) in _mountain.indexed) {
      final p = Offset(box.left + box.width * px / 100, box.top + box.height * py / 100);
      i == 0 ? path.moveTo(p.dx, p.dy) : path.lineTo(p.dx, p.dy);
    }
    path.close();
    canvas.drawPath(path, Paint()..color = const Color(0xFF1A2252));
  }

  @override
  bool shouldRepaint(_ScenePainter oldDelegate) => false;
}

import 'package:flutter/material.dart';

/// Viền nét đứt bo góc bọc quanh [child] (kế hoạch dự kiến, khác với buổi học thật có viền liền).
class DashedBorder extends StatelessWidget {
  const DashedBorder({super.key, required this.child, required this.color, this.radius = 6, this.strokeWidth = 1.2, this.dash = 5, this.gap = 4});

  final Widget child;
  final Color color;
  final double radius;
  final double strokeWidth;
  final double dash;
  final double gap;

  @override
  Widget build(BuildContext context) =>
      CustomPaint(foregroundPainter: _DashedPainter(color, radius, strokeWidth, dash, gap), child: child);
}

class _DashedPainter extends CustomPainter {
  _DashedPainter(this.color, this.radius, this.strokeWidth, this.dash, this.gap);

  final Color color;
  final double radius;
  final double strokeWidth;
  final double dash;
  final double gap;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;
    final path = Path()..addRRect(RRect.fromRectAndRadius(Offset.zero & size, Radius.circular(radius)));
    for (final metric in path.computeMetrics()) {
      for (var d = 0.0; d < metric.length; d += dash + gap) {
        canvas.drawPath(metric.extractPath(d, (d + dash).clamp(0, metric.length)), paint);
      }
    }
  }

  @override
  bool shouldRepaint(_DashedPainter old) => old.color != color || old.radius != radius || old.strokeWidth != strokeWidth;
}

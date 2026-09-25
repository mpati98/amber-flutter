import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// Port từ vòng tiến độ SVG trong amber-v3/src/app/tang-kinh-cac/ke-hoach-doc/page.tsx:
/// viewBox 100, r = 42, stroke 8, bắt đầu từ đỉnh, cung kincha-400 chạy từ 0
/// tới pct trong 1s easeOut, số % ở giữa (font-serif-display text-2xl).
class ProgressRing extends StatelessWidget {
  const ProgressRing({
    super.key,
    required this.value,
    required this.max,
    this.size = 128, // h-32 w-32
  });

  final double value;
  final double max;
  final double size;

  @override
  Widget build(BuildContext context) {
    final pct = max > 0 ? (value / max).clamp(0.0, 1.0) : 0.0;

    return SizedBox.square(
      dimension: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: pct),
            duration: const Duration(seconds: 1),
            curve: Curves.easeOut,
            builder: (context, t, _) => CustomPaint(
              size: Size.square(size),
              painter: _RingPainter(progress: t),
            ),
          ),
          // text-2xl = 24px → headlineSmall (24, Noto Serif trong darkTheme).
          Text(
            '${(pct * 100).round()}%',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(color: Colors.white),
          ),
        ],
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  _RingPainter({required this.progress});

  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    // Quy đổi từ viewBox 100 sang kích thước thật, như SVG tự scale.
    final scale = size.shortestSide / 100;
    final center = size.center(Offset.zero);
    final radius = 42 * scale;
    final strokeWidth = 8 * scale;

    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..color = Colors.white.withValues(alpha: 0.1),
    );

    if (progress <= 0) return;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2,
      2 * math.pi * progress,
      false,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round
        ..color = AppColors.kincha400,
    );
  }

  @override
  bool shouldRepaint(_RingPainter oldDelegate) => oldDelegate.progress != progress;
}

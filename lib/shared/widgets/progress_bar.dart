import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// Port từ ProgressBar trong amber-v3/src/components/tang-kinh-cac/ui.tsx:
/// track `h-1.5 rounded-full bg-white/10`, fill gradient yugen-500 → kincha-400.
///
/// [fillColor] thay gradient bằng màu đơn — dùng cho biến thể ngân sách
/// (BudgetProgressRow bên web: kincha-400, hoặc shuiro-500 khi vượt hạn mức).
/// Không nhận nhãn: nơi gọi tự dựng dòng chữ trên/dưới thanh, giống bên web.
class ProgressBar extends StatelessWidget {
  const ProgressBar({
    super.key,
    required this.value,
    required this.max,
    this.fillColor,
  });

  final double value;
  final double max;
  final Color? fillColor;

  static const _radius = BorderRadius.all(Radius.circular(999));

  @override
  Widget build(BuildContext context) {
    final pct = max > 0 ? (value / max).clamp(0.0, 1.0) : 0.0;

    return Container(
      height: 6, // h-1.5
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.1),
        borderRadius: _radius,
      ),
      alignment: Alignment.centerLeft,
      // begin để trống: lần đầu vẽ thẳng giá trị cuối, chỉ animate khi pct đổi
      // (như transition-all bên web).
      child: TweenAnimationBuilder<double>(
        tween: Tween(end: pct),
        duration: const Duration(milliseconds: 300),
        curve: Curves.fastOutSlowIn, // = cubic-bezier(0.4, 0, 0.2, 1), easing mặc định của Tailwind
        builder: (context, t, _) => FractionallySizedBox(
          widthFactor: t,
          heightFactor: 1,
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: fillColor,
              gradient: fillColor == null
                  ? const LinearGradient(colors: [AppColors.yugen500, AppColors.kincha400])
                  : null,
              borderRadius: _radius,
            ),
          ),
        ),
      ),
    );
  }
}

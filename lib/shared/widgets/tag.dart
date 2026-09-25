import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

enum TagVariant {
  /// Viền màu, không nền — StatusBadge, TypeTag bên web.
  outlined,

  /// Nền màu mờ (mặc định 20%), chữ cùng màu — TaskStatusBadge bên web.
  tonal,

  /// Nền màu đặc — ImportanceTag bên web.
  solid,
}

/// Nhãn nhỏ dùng chung, thay cho StatusBadge / TypeTag / TaskStatusBadge /
/// ImportanceTag bên amber-v3. Widget chỉ nhận label + màu + kiểu; bảng
/// trạng thái → (label, màu, kiểu) do từng feature tự giữ.
class Tag extends StatelessWidget {
  const Tag({
    super.key,
    required this.label,
    required this.color,
    this.variant = TagVariant.outlined,
    this.uppercase = false,
    this.borderAlpha = 0.4,
    this.backgroundAlpha = 0.2,
    this.foregroundColor,
    this.fontSize = 11,
    this.fontWeight = FontWeight.normal,
    this.letterSpacingEm,
    this.padding = const EdgeInsets.symmetric(horizontal: 8, vertical: 2), // px-2 py-0.5
  });

  final String label;
  final Color color;
  final TagVariant variant;

  /// TypeTag viết hoa (kèm tracking-wider), StatusBadge thì không.
  final bool uppercase;

  /// Độ mờ tuyệt đối của viền, chỉ dùng cho [TagVariant.outlined].
  final double borderAlpha;

  /// Độ mờ của nền, chỉ dùng cho [TagVariant.tonal] (TaskStatusBadge PREP: 0.1).
  final double backgroundAlpha;

  /// Màu chữ khi khác [color]: bắt buộc cho solid nền sáng (kincha-400 +
  /// ink-950), hoặc khi web dùng 2 sắc độ (nền emerald-400, chữ emerald-300).
  /// Mặc định: trắng với solid, [color] với outlined/tonal.
  final Color? foregroundColor;

  final double fontSize;

  /// TaskStatusBadge / ImportanceTag dùng font-medium (w500).
  final FontWeight fontWeight;

  /// Khoảng cách chữ theo em. Null = tracking-wider (0.05) khi [uppercase],
  /// tracking-wide (0.025) khi không. ImportanceTag không có tracking: truyền 0.
  final double? letterSpacingEm;

  /// ImportanceTag dùng px-1.5 (6px) thay vì px-2.
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    final fg = foregroundColor ?? (variant == TagVariant.solid ? Colors.white : color);

    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: switch (variant) {
          TagVariant.outlined => null,
          TagVariant.tonal => color.withValues(alpha: backgroundAlpha),
          TagVariant.solid => color,
        },
        border: variant == TagVariant.outlined
            ? Border.all(color: color.withValues(alpha: borderAlpha))
            : null,
        borderRadius: BorderRadius.circular(AppTheme.darkRadius), // rounded-sm
      ),
      child: Text(
        uppercase ? label.toUpperCase() : label,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: fg,
              fontSize: fontSize,
              fontWeight: fontWeight,
              height: 1.5,
              letterSpacing: fontSize * (letterSpacingEm ?? (uppercase ? 0.05 : 0.025)),
            ),
      ),
    );
  }
}

import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// Màu viền của [ScrollCard] — tương ứng prop `glow` bên web.
enum ScrollCardGlow {
  yugen(AppColors.yugen500),
  shuiro(AppColors.shuiro500),
  kincha(AppColors.kincha400);

  const ScrollCardGlow(this.color);

  final Color color;
}

/// Port từ ScrollCard trong amber-v3/src/components/tang-kinh-cac/ui.tsx:
/// `rounded-sm border bg-ink-900/60 p-5`, một khối duy nhất bọc [child].
///
/// Bên web viền là white/10 và chỉ đổi sang màu glow khi hover
/// (`hover:border-[var(--glow)]`). Trên thiết bị cảm ứng không có hover, nên
/// ở đây glow được dùng làm màu viền tĩnh, luôn hiển thị. Đây là điều chỉnh
/// có chủ đích khi chuyển nền tảng, không phải port sót.
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
    return Container(
      padding: const EdgeInsets.all(20), // p-5 = 1.25rem
      decoration: BoxDecoration(
        color: AppColors.ink900.withValues(alpha: 0.6),
        border: Border.all(color: glow.color),
        borderRadius: BorderRadius.circular(AppTheme.darkRadius),
      ),
      child: child,
    );
  }
}

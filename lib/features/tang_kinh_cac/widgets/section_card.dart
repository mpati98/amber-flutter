import 'package:flutter/material.dart';

import '../../../shared/theme/app_theme.dart';
import '../../../shared/widgets/scroll_card.dart';

/// Port SectionCard (tang-kinh-cac/SectionCard.tsx): icon, tiêu đề serif, mô tả,
/// số liệu ở đáy. Bên web "Vào xem →" và viền màu chỉ hiện khi hover — trên
/// cảm ứng không có hover nên luôn hiện (giống cách ScrollCard xử lý glow).
class SectionCard extends StatelessWidget {
  const SectionCard({
    super.key,
    required this.icon,
    required this.title,
    required this.description,
    required this.stat,
    required this.glow,
    required this.onTap,
  });

  final String icon;
  final String title;
  final String description;
  final String stat;
  final ScrollCardGlow glow;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: ScrollCard(
        glow: glow,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(icon, style: const TextStyle(fontSize: 30)), // text-3xl
            const SizedBox(height: 16), // mt-4
            Text(title, style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontSize: 20, color: Colors.white)),
            const SizedBox(height: 8), // mt-2
            Text(
              description,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(fontSize: 14, height: 1.6, color: Colors.white.withValues(alpha: 0.5)),
            ),
            const SizedBox(height: 20), // mt-5
            Row(
              children: [
                Expanded(
                  child: Text(
                    stat,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontSize: 12, color: Colors.white.withValues(alpha: 0.4)),
                  ),
                ),
                const SizedBox(width: 12),
                const Text('Vào xem →', style: TextStyle(fontSize: 14, color: AppColors.kincha200)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

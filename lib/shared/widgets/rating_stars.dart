import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// Gộp 2 thứ bên amber-v3:
/// - RatingStars tĩnh (tang-kinh-cac/ui.tsx): `text-sm tracking-tight`, 5 ký tự ★.
/// - Phần chọn sao trong BookDetailModal: 5 nút ★ `text-xl`, `flex gap-1`.
///
/// Truyền [onChanged] để bật chế độ chọn (nơi gọi đặt `size: 20`).
class RatingStars extends StatelessWidget {
  const RatingStars({
    super.key,
    required this.rating,
    this.size = 14,
    this.onChanged,
  });

  final int? rating;
  final double size;
  final ValueChanged<int>? onChanged;

  static final _dim = Colors.white.withValues(alpha: 0.2);

  Color _colorFor(int i) => i <= (rating ?? 0) ? AppColors.kincha400 : _dim;

  @override
  Widget build(BuildContext context) {
    final onChanged = this.onChanged;
    final base = Theme.of(context).textTheme.bodyMedium?.copyWith(fontSize: size);

    // Chế độ chọn luôn hiện 5 sao, kể cả khi chưa có rating — bên web modal
    // cũng vậy, nếu ẩn đi thì không chọn được sao đầu tiên.
    if (onChanged != null) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        spacing: 4, // gap-1
        children: [
          for (var i = 1; i <= 5; i++)
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => onChanged(i),
              child: Text('★', style: base?.copyWith(color: _colorFor(i))),
            ),
        ],
      );
    }

    final r = (rating ?? 0).clamp(0, 5);
    if (r == 0) return const SizedBox.shrink();
    return Text.rich(
      TextSpan(
        style: base?.copyWith(letterSpacing: size * -0.025), // tracking-tight
        children: [
          TextSpan(text: '★' * r, style: const TextStyle(color: AppColors.kincha400)),
          TextSpan(text: '★' * (5 - r), style: TextStyle(color: _dim)),
        ],
      ),
    );
  }
}

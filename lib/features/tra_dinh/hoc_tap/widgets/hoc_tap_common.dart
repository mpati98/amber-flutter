import 'package:flutter/material.dart';

import '../../../../shared/theme/app_theme.dart';
import '../../../../shared/utils/date_format.dart';

/// "sớm 2 ngày" / "trễ 3 ngày" / "đúng kế hoạch"; null nếu chưa có mốc so sánh.
String? deltaLabel(int? deltaDays) {
  if (deltaDays == null) return null;
  if (deltaDays == 0) return 'đúng kế hoạch';
  return deltaDays < 0 ? 'sớm ${-deltaDays} ngày' : 'trễ $deltaDays ngày';
}

/// Màu cho độ lệch: sớm/đúng → màu thành công, trễ → màu lỗi.
Color deltaColor(BuildContext context, int deltaDays) {
  final theme = Theme.of(context);
  return deltaDays <= 0 ? theme.success : theme.colorScheme.error;
}

/// "dự kiến xong 23/10" (kèm "· sớm 2 ngày" nếu có).
String forecastLine(String? forecastFinishDate, int? deltaDays) {
  if (forecastFinishDate == null) return 'Chưa có dự kiến xong';
  final delta = deltaLabel(deltaDays);
  return 'Dự kiến xong ${formatDayMonth(forecastFinishDate)}${delta == null ? '' : ' · $delta'}';
}

class HocTapSectionTitle extends StatelessWidget {
  const HocTapSectionTitle(this.text, {super.key});

  final String text;

  @override
  Widget build(BuildContext context) =>
      Text(text, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500, letterSpacing: 0.3, color: AppColors.kincha400));
}

/// Dòng báo lỗi tải + nút thử lại.
class HocTapLoadError extends StatelessWidget {
  const HocTapLoadError({super.key, required this.what, required this.onRetry});

  final String what;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 24),
    child: Column(
      spacing: 8,
      children: [
        Text('Không tải được $what.', style: TextStyle(color: Theme.of(context).textMuted)),
        OutlinedButton(onPressed: onRetry, child: const Text('Thử lại')),
      ],
    ),
  );
}

/// Khung màn con của Học tập: nền, giới hạn bề ngang 640 như các màn Trà Đình khác.
class HocTapBody extends StatelessWidget {
  const HocTapBody({super.key, required this.child, this.onRefresh});

  final Widget child;
  final Future<void> Function()? onRefresh;

  @override
  Widget build(BuildContext context) {
    final content = onRefresh == null ? child : RefreshIndicator(onRefresh: onRefresh!, child: child);
    return Center(child: ConstrainedBox(constraints: const BoxConstraints(maxWidth: 640), child: content));
  }
}

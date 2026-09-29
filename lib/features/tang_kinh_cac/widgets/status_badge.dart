import 'package:flutter/material.dart';

import '../../../shared/theme/app_theme.dart';
import '../../../shared/widgets/tag.dart';
import '../models/publication.dart';

extension PublicationStatusLabel on PublicationStatus {
  String get label => switch (this) {
        PublicationStatus.toRead => 'Muốn đọc',
        PublicationStatus.reading => 'Đang đọc',
        PublicationStatus.read => 'Đã đọc',
        PublicationStatus.abandoned => 'Bỏ dở',
        PublicationStatus.unknown => 'Không rõ',
      };
}

extension PublicationFormatLabel on PublicationFormat {
  String get label => switch (this) {
        PublicationFormat.physical => 'Sách giấy',
        PublicationFormat.ebook => 'Ebook',
        PublicationFormat.audiobook => 'Audiobook',
        PublicationFormat.unknown => 'Không rõ',
      };
}

/// Port StatusBadge (tang-kinh-cac/ui.tsx): viền màu /40, chữ 11px.
class StatusBadge extends StatelessWidget {
  const StatusBadge(this.status, {super.key});

  final PublicationStatus status;

  @override
  Widget build(BuildContext context) {
    return switch (status) {
      // Web: chữ yugen-300, viền yugen-500/40.
      PublicationStatus.toRead =>
        Tag(label: status.label, color: AppColors.yugen500, foregroundColor: AppColors.yugen300),
      PublicationStatus.reading => Tag(label: status.label, color: AppColors.kincha400),
      // Web: chữ emerald-300, viền emerald-400/40.
      PublicationStatus.read =>
        Tag(label: status.label, color: AppColors.emerald400, foregroundColor: AppColors.emerald300),
      PublicationStatus.abandoned => Tag(label: status.label, color: AppColors.shuiro500),
      // Web fallback: chữ white/60, viền white/20.
      PublicationStatus.unknown => Tag(
          label: status.label,
          color: Colors.white,
          foregroundColor: Colors.white.withValues(alpha: 0.6),
          borderAlpha: 0.2,
        ),
    };
  }
}

import 'package:material_ui/material_ui.dart';

import '../../../shared/theme/design_tokens.dart';
import '../../../shared/widgets/list_frame.dart';

/// Hàng điều hướng viền, bo góc, cao tối thiểu 52: chữ chính, [trailing] (chữ phụ) và mũi tên ›. [subtitle] là dòng phụ dưới chữ chính.
class PlanNavRow extends StatelessWidget {
  const PlanNavRow({
    super.key,
    required this.label,
    required this.onTap,
    this.subtitle,
    this.trailing,
  });

  final String label;
  final String? subtitle;
  final String? trailing;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    // Ô bấm theo bộ thiết kế mới (FrameTile): nền panel, viền, hover vàng; cao tối thiểu 52.
    return FrameTile(
      onTap: onTap,
      semanticLabel: label,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: 30),
        child: Row(
          spacing: 8,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(label, style: DesignText.bold),
                  if (subtitle != null) Text(subtitle!, style: DesignText.muted),
                ],
              ),
            ),
            if (trailing != null) Text(trailing!, style: DesignText.muted),
            const Text('›', style: TextStyle(fontSize: 20, color: DesignColors.gold)),
          ],
        ),
      ),
    );
  }
}

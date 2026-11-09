import 'package:flutter/material.dart';

import '../../../shared/theme/app_theme.dart';

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
    final theme = Theme.of(context);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        constraints: const BoxConstraints(minHeight: 52),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          border: Border.all(
            color: theme.colorScheme.onSurface.withValues(alpha: 0.15),
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          spacing: 8,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  if (subtitle != null)
                    Text(
                      subtitle!,
                      style: TextStyle(fontSize: 12, color: theme.textMuted),
                    ),
                ],
              ),
            ),
            if (trailing != null)
              Text(
                trailing!,
                style: TextStyle(fontSize: 13, color: theme.textMuted),
              ),
            Text('›', style: TextStyle(fontSize: 20, color: theme.textMuted)),
          ],
        ),
      ),
    );
  }
}

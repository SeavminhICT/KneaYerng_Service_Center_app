import 'package:flutter/material.dart';

import 'admin_notification_colors.dart';
import 'admin_notification_composer_type.dart';

/// Selectable chip representing a single [AdminComposerType] option.
class AdminNotificationTypeChip extends StatelessWidget {
  const AdminNotificationTypeChip({
    super.key,
    required this.type,
    required this.selected,
    required this.onTap,
  });
  final AdminComposerType type;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = type.color;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: selected
              ? color.withValues(alpha: 0.1)
              : const Color(0xFFF8FAFD),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected ? color : adminNotificationBorder,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              type.icon,
              size: 15,
              color: selected ? color : adminNotificationTextMuted,
            ),
            const SizedBox(width: 6),
            Text(
              type.label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
                color: selected ? color : adminNotificationTextDark,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

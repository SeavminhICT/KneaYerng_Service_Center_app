import 'package:flutter/material.dart';

import 'notification_tone.dart';

/// Segmented "All" / "Unread" tab chip used at the top of the screen.
class NotificationTabChip extends StatelessWidget {
  const NotificationTabChip({
    super.key,
    required this.label,
    required this.count,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final int count;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Ink(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          decoration: BoxDecoration(
            color: selected ? notificationPrimary : notificationSurface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: selected ? notificationPrimary : notificationBorder,
            ),
            boxShadow: selected
                ? const [
                    BoxShadow(
                      color: Color(0x224A88F7),
                      blurRadius: 18,
                      offset: Offset(0, 10),
                    ),
                  ]
                : const [],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: selected ? Colors.white : notificationTextPrimary,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: selected
                      ? Colors.white.withValues(alpha: 0.18)
                      : const Color(0xFFEFF4FF),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  '$count',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: selected ? Colors.white : notificationPrimary,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

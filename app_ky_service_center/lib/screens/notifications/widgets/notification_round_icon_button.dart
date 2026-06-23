import 'package:flutter/material.dart';

import 'notification_tone.dart';

/// Square rounded icon button (used for the filter/tune action).
class NotificationRoundIconButton extends StatelessWidget {
  const NotificationRoundIconButton({
    super.key,
    required this.icon,
    required this.onTap,
  });

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Ink(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: notificationSurface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: notificationBorder),
            boxShadow: const [
              BoxShadow(
                color: notificationShadow,
                blurRadius: 14,
                offset: Offset(0, 8),
              ),
            ],
          ),
          child: Icon(icon, size: 20, color: notificationTextPrimary),
        ),
      ),
    );
  }
}

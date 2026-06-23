import 'package:flutter/material.dart';

import 'notification_tone.dart';

/// Generic back/leading icon button used on the notification list header.
class NotificationIconBtn extends StatelessWidget {
  const NotificationIconBtn({
    super.key,
    required this.icon,
    required this.onTap,
    this.circular = false,
    this.iconSize = 20,
  });

  final IconData icon;
  final VoidCallback onTap;
  final bool circular;
  final double iconSize;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(circular ? 999 : 16),
      child: Container(
        width: circular ? 42 : 44,
        height: circular ? 42 : 44,
        decoration: BoxDecoration(
          color: Colors.white,
          shape: circular ? BoxShape.circle : BoxShape.rectangle,
          borderRadius: circular ? null : BorderRadius.circular(18),
          border: Border.all(color: notificationBorder),
          boxShadow: [
            BoxShadow(
              color: circular
                  ? notificationShadow.withAlpha(14)
                  : notificationShadow,
              blurRadius: circular ? 6 : 10,
              offset: Offset(0, circular ? 2 : 4),
            ),
          ],
        ),
        child: Icon(icon, size: iconSize, color: notificationTextPrimary),
      ),
    );
  }
}

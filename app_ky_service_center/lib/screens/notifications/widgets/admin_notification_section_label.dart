import 'package:flutter/material.dart';

import 'admin_notification_colors.dart';

/// Small uppercase-style section label used throughout the compose tab.
class AdminNotificationSectionLabel extends StatelessWidget {
  const AdminNotificationSectionLabel(this.text, {super.key});
  final String text;

  @override
  Widget build(BuildContext context) => Text(
    text,
    style: const TextStyle(
      fontSize: 12,
      fontWeight: FontWeight.w600,
      color: adminNotificationTextMuted,
      letterSpacing: 0.4,
    ),
  );
}

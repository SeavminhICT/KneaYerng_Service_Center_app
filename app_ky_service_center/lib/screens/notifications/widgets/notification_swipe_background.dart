import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';

import 'notification_tone.dart';

/// Background revealed when swiping a notification row.
class NotificationSwipeBackground extends StatelessWidget {
  const NotificationSwipeBackground({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.centerRight,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: const LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [Color(0xFFEAF1FF), Color(0xFFFEE2E2)],
        ),
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            HugeIcons.strokeRoundedMailOpen01,
            color: notificationPrimary,
            size: 20,
          ),
          SizedBox(width: 10),
          Icon(
            HugeIcons.strokeRoundedDelete02,
            color: Color(0xFFDC2626),
            size: 20,
          ),
        ],
      ),
    );
  }
}

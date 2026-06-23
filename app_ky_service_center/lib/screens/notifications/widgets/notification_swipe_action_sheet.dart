import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';

import 'notification_item.dart';
import 'notification_tone.dart';

/// Action chosen from [NotificationSwipeActionSheet].
enum NotificationSwipeAction { markRead, delete }

/// Bottom sheet presented when a notification row is swiped.
class NotificationSwipeActionSheet extends StatelessWidget {
  const NotificationSwipeActionSheet({super.key, required this.item});

  final NotificationItem item;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Container(
        decoration: const BoxDecoration(
          color: notificationSurface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        padding: const EdgeInsets.fromLTRB(20, 18, 20, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 46,
                height: 5,
                decoration: BoxDecoration(
                  color: const Color(0xFFD6DCE8),
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
            ),
            const SizedBox(height: 18),
            Text(
              item.title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: notificationTextPrimary,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'Choose what to do with this notification.',
              style: TextStyle(fontSize: 13, color: notificationTextMuted),
            ),
            const SizedBox(height: 20),
            _NotificationActionTile(
              icon: HugeIcons.strokeRoundedMailOpen01,
              iconColor: notificationPrimary,
              title: 'Mark as read',
              subtitle: 'Keep it in the list and remove the unread badge.',
              onTap: () =>
                  Navigator.of(context).pop(NotificationSwipeAction.markRead),
            ),
            const SizedBox(height: 10),
            _NotificationActionTile(
              icon: HugeIcons.strokeRoundedDelete02,
              iconColor: const Color(0xFFDC2626),
              title: 'Delete notification',
              subtitle: 'Remove it from the inbox permanently.',
              onTap: () =>
                  Navigator.of(context).pop(NotificationSwipeAction.delete),
            ),
          ],
        ),
      ),
    );
  }
}

class _NotificationActionTile extends StatelessWidget {
  const _NotificationActionTile({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: Ink(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: const Color(0xFFF8FAFD),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: notificationBorder),
          ),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: iconColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(icon, color: iconColor, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: notificationTextPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        fontSize: 12,
                        height: 1.5,
                        color: notificationTextMuted,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                HugeIcons.strokeRoundedArrowRight01,
                size: 14,
                color: notificationTextMuted,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

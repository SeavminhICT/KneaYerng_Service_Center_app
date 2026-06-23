import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';

import '../../../l10n/app_localizations.dart';
import '../../../widgets/empty_state_view.dart';
import 'notification_tone.dart';

/// Empty state shown when no notifications match the current filter.
class NotificationEmptyState extends StatelessWidget {
  const NotificationEmptyState({super.key});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return EmptyStateView(
      icon: HugeIcons.strokeRoundedNotificationOff01,
      iconColor: notificationPrimary,
      title: l.noNotifications,
      subtitle:
          'Try switching filters or pull to refresh to sync the latest updates.',
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hugeicons/hugeicons.dart';

import '../../../l10n/app_localizations.dart';
import 'notification_item.dart';
import 'notification_tone.dart';

class _NotificationStatus {
  const _NotificationStatus(this.label, this.color, this.icon);
  final String label;
  final Color color;
  final IconData icon;
}

_NotificationStatus _statusFor(NotificationItem item) {
  final title = item.title.toLowerCase();
  if (title.contains('approve') || title.contains('success') ||
      title.contains('delivered') || title.contains('confirm')) {
    return _NotificationStatus(
      'Approved',
      const Color(0xFF16A34A),
      HugeIcons.strokeRoundedCheckmarkCircle02,
    );
  }
  if (title.contains('cancel') || title.contains('reject') ||
      title.contains('fail')) {
    return _NotificationStatus(
      'Cancelled',
      const Color(0xFFDC2626),
      HugeIcons.strokeRoundedCancelCircle,
    );
  }
  if (title.contains('pending') || title.contains('process')) {
    return _NotificationStatus(
      'Pending',
      const Color(0xFFD97706),
      HugeIcons.strokeRoundedClock01,
    );
  }
  return _NotificationStatus(
    categoryLabel(item.category),
    categoryColor(item.category),
    categoryIcon(item.category),
  );
}

/// Full-screen detail view for a single notification.
class NotificationDetailScreen extends StatelessWidget {
  const NotificationDetailScreen({
    super.key,
    required this.item,
    this.onActionTap,
  });

  final NotificationItem item;
  final VoidCallback? onActionTap;

  Future<void> _copyLink(BuildContext context, String link) async {
    await Clipboard.setData(ClipboardData(text: link));
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Link copied'), duration: Duration(seconds: 1)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final status = _statusFor(item);
    final accent = status.color;
    final icon = categoryIcon(item.category);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final detailBackground = isDark
        ? const Color(0xFF0B1220)
        : Theme.of(context).scaffoldBackgroundColor;
    final detailSurface = isDark ? const Color(0xFF111C2E) : notificationSurface;
    final detailBorder = isDark ? const Color(0xFF22314A) : notificationBorder;
    final detailTitle = isDark ? const Color(0xFFE6EEFF) : notificationTextPrimary;
    final detailMuted = isDark ? const Color(0xFF9EB0CD) : notificationTextMuted;
    final detailBody = isDark ? const Color(0xFFD3E0F8) : notificationTextPrimary;
    final linkBackground = isDark
        ? const Color(0xFF18263A)
        : const Color(0xFFF7F9FD);
    final cardShadow = isDark ? const Color(0x28000000) : notificationShadow;

    return Scaffold(
      backgroundColor: detailBackground,
      appBar: AppBar(
        backgroundColor: detailSurface,
        elevation: 0,
        scrolledUnderElevation: 0,
        foregroundColor: detailTitle,
        titleSpacing: 0,
        title: Text(
          l.notifications,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: detailTitle,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 12),
            SizedBox(
              width: 104,
              height: 104,
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  Container(
                    width: 104,
                    height: 104,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          accent.withValues(alpha: 0.14),
                          accent.withValues(alpha: 0.28),
                        ],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: accent.withValues(alpha: 0.18),
                          blurRadius: 28,
                          offset: const Offset(0, 16),
                        ),
                      ],
                    ),
                    child: Icon(icon, color: accent, size: 42),
                  ),
                  Positioned(
                    right: -4,
                    bottom: -4,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: detailBackground,
                      ),
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: status.color,
                        ),
                        child: Icon(status.icon, color: Colors.white, size: 16),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
              decoration: BoxDecoration(
                color: status.color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                status.label.toUpperCase(),
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.6,
                  color: status.color,
                ),
              ),
            ),
            const SizedBox(height: 14),
            Text(
              item.title,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: detailTitle,
                height: 1.2,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(HugeIcons.strokeRoundedClock01, size: 14, color: detailMuted),
                const SizedBox(width: 4),
                Text(
                  formatNotificationTimestamp(item.timestamp),
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: detailMuted,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: detailSurface,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: detailBorder),
                boxShadow: [
                  BoxShadow(
                    color: cardShadow,
                    blurRadius: 18,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.message,
                    style: TextStyle(
                      fontSize: 15,
                      height: 1.6,
                      color: detailBody,
                    ),
                  ),
                  if (item.deepLink != null) ...[
                    SizedBox(height: 18),
                    Divider(height: 1, color: detailBorder),
                    const SizedBox(height: 18),
                    Material(
                      color: linkBackground,
                      borderRadius: BorderRadius.circular(14),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(14),
                        onTap: () => _copyLink(context, item.deepLink!),
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: detailBorder),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              const Icon(
                                HugeIcons.strokeRoundedLink01,
                                size: 18,
                                color: notificationPrimary,
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  item.deepLink!,
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: detailTitle,
                                  ),
                                ),
                              ),
                              Icon(
                                HugeIcons.strokeRoundedCopy01,
                                size: 16,
                                color: detailMuted,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            if (item.actionLabel != null) ...[
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: onActionTap,
                  icon: const Icon(
                    HugeIcons.strokeRoundedDeliveryTruck01,
                    size: 20,
                  ),
                  style: FilledButton.styleFrom(
                    backgroundColor: notificationPrimary,
                    foregroundColor: Colors.white,
                    minimumSize: const Size.fromHeight(54),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  label: Text(
                    item.actionLabel!,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

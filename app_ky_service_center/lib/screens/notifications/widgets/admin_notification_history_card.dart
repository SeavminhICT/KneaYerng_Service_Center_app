import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';

import '../../../models/admin_notification_campaign.dart';
import 'admin_notification_colors.dart';

/// Card summarizing a single sent/scheduled/draft notification campaign,
/// shown in the History tab of the admin notification panel.
class AdminNotificationHistoryCard extends StatelessWidget {
  const AdminNotificationHistoryCard({super.key, required this.entry});
  final AdminNotificationCampaignItem entry;

  @override
  Widget build(BuildContext context) {
    final statusColor = adminNotificationStatusColor(entry.status);
    final summary = entry.summary;
    return Container(
      decoration: BoxDecoration(
        color: adminNotificationSurface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: adminNotificationBorder),
      ),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              width: 4,
              decoration: BoxDecoration(
                color: statusColor,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(14),
                  bottomLeft: Radius.circular(14),
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        AdminNotificationStatusBadge(status: entry.status),
                        const Spacer(),
                        Text(
                          adminNotificationFormatDateTime(entry.createdAt),
                          style: const TextStyle(
                            color: adminNotificationTextMuted,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      entry.title,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: adminNotificationTextDark,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${entry.type}  ·  ${adminNotificationAudienceLabelFromApi(entry.audience)}',
                      style: const TextStyle(
                        color: adminNotificationTextMuted,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        AdminNotificationStatPill(
                          icon: HugeIcons.strokeRoundedUserGroup02,
                          label: '${summary.targetedUsers}',
                          color: const Color(0xFF4A88F7),
                        ),
                        const SizedBox(width: 10),
                        AdminNotificationStatPill(
                          icon: HugeIcons.strokeRoundedCheckmarkCircle02,
                          label: '${summary.delivered}',
                          color: const Color(0xFF0F9D58),
                        ),
                        if (summary.failed > 0) ...[
                          const SizedBox(width: 10),
                          AdminNotificationStatPill(
                            icon: HugeIcons.strokeRoundedAlertCircle,
                            label: '${summary.failed}',
                            color: const Color(0xFFEF4444),
                          ),
                        ],
                      ],
                    ),
                    if (entry.scheduledFor != null) ...[
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          const Icon(
                            HugeIcons.strokeRoundedTimeSchedule,
                            size: 12,
                            color: adminNotificationTextMuted,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Scheduled ${adminNotificationFormatDateTime(entry.scheduledFor)}',
                            style: const TextStyle(
                              color: adminNotificationTextMuted,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ],
                    if (summary.pushError != null) ...[
                      const SizedBox(height: 6),
                      Text(
                        summary.pushError!,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Color(0xFFEF4444),
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Small colored pill showing the campaign status (sent / scheduled / draft).
class AdminNotificationStatusBadge extends StatelessWidget {
  const AdminNotificationStatusBadge({super.key, required this.status});
  final String status;

  @override
  Widget build(BuildContext context) {
    final color = adminNotificationStatusColor(status);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        adminNotificationStatusLabel(status),
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: color,
        ),
      ),
    );
  }
}

/// Small icon + label stat used inside [AdminNotificationHistoryCard].
class AdminNotificationStatPill extends StatelessWidget {
  const AdminNotificationStatPill({
    super.key,
    required this.icon,
    required this.label,
    required this.color,
  });
  final IconData icon;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Icon(icon, size: 13, color: color),
      const SizedBox(width: 3),
      Text(
        label,
        style: TextStyle(
          fontSize: 12,
          color: color,
          fontWeight: FontWeight.w600,
        ),
      ),
    ],
  );
}

String adminNotificationFormatDateTime(DateTime? value) {
  if (value == null) return '';
  final d = value.toLocal();
  return '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')} '
      '${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';
}

String adminNotificationStatusLabel(String status) {
  switch (status.toLowerCase()) {
    case 'sent':
      return 'Sent';
    case 'scheduled':
      return 'Scheduled';
    case 'draft':
      return 'Draft';
    default:
      return status;
  }
}

Color adminNotificationStatusColor(String status) {
  switch (status.toLowerCase()) {
    case 'sent':
      return const Color(0xFF0F9D58);
    case 'scheduled':
      return const Color(0xFFF59E0B);
    case 'draft':
      return const Color(0xFF6B7280);
    default:
      return const Color(0xFF6B7280);
  }
}

String adminNotificationAudienceLabelFromApi(String audience) {
  switch (audience.toLowerCase()) {
    case 'all':
      return 'Customers + guests';
    case 'active':
      return 'Active';
    case 'new':
      return 'New';
    case 'inactive':
      return 'Inactive';
    case 'premium':
      return 'Premium';
    case 'custom':
      return 'Custom';
    default:
      return audience;
  }
}

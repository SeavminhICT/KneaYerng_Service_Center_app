import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:intl/intl.dart';

import '../../../models/pickup_ticket.dart';
import 'delivery_tracking_colors.dart';

class DeliveryTrackingTimelineStepCard extends StatelessWidget {
  const DeliveryTrackingTimelineStepCard({
    super.key,
    required this.step,
    required this.isLast,
    required this.isAlertFlow,
  });

  final TrackingTimelineStep step;
  final bool isLast;
  final bool isAlertFlow;

  @override
  Widget build(BuildContext context) {
    final isDone = step.done && !step.current;
    final isCurrent = step.current;
    final isUpcoming = !isDone && !isCurrent;

    final Color markerColor;
    final Color lineColor;
    final IconData icon;
    final Color cardColor;
    final Color cardBorder;
    final String badgeText;
    final Color badgeColor;
    final Color badgeTextColor;

    if (isCurrent && isAlertFlow) {
      markerColor = TrackingUiColors.danger;
      lineColor = const Color(0xFFFECACA);
      icon = HugeIcons.strokeRoundedCancel01;
      cardColor = TrackingUiColors.dangerSoft;
      cardBorder = const Color(0xFFFECACA);
      badgeText = 'Cancelled';
      badgeColor = const Color(0xFFFECDCA);
      badgeTextColor = const Color(0xFFB42318);
    } else if (isDone) {
      markerColor = TrackingUiColors.primary;
      lineColor = const Color(0xFFBFD1FF);
      icon = HugeIcons.strokeRoundedTick01;
      cardColor = const Color(0xFFF7F9FF);
      cardBorder = const Color(0xFFD6E1FF);
      badgeText = 'Done';
      badgeColor = TrackingUiColors.primarySoft;
      badgeTextColor = const Color(0xFF1D4ED8);
    } else if (isCurrent) {
      markerColor = TrackingUiColors.primary;
      lineColor = const Color(0xFFBFD1FF);
      icon = HugeIcons.strokeRoundedNavigator02;
      cardColor = const Color(0xFFEFF4FF);
      cardBorder = const Color(0xFFC9D8FF);
      badgeText = 'Current';
      badgeColor = TrackingUiColors.primarySoft;
      badgeTextColor = const Color(0xFF1D4ED8);
    } else {
      markerColor = const Color(0xFFCBD5E1);
      lineColor = const Color(0xFFE2E8F0);
      icon = HugeIcons.strokeRoundedMoreHorizontal;
      cardColor = Colors.white;
      cardBorder = const Color(0xFFE2E8F0);
      badgeText = 'Upcoming';
      badgeColor = const Color(0xFFF1F5F9);
      badgeTextColor = const Color(0xFF475569);
    }

    final dateText = step.at == null
        ? null
        : DateFormat('dd MMM yyyy, hh:mm a').format(step.at!);

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 32,
            child: Column(
              children: [
                Container(
                  width: 22,
                  height: 22,
                  decoration: BoxDecoration(
                    color: markerColor,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, size: 14, color: Colors.white),
                ),
                if (!isLast)
                  Container(
                    width: 2,
                    height: 62,
                    margin: const EdgeInsets.only(top: 4),
                    color: lineColor,
                  ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: cardColor,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: cardBorder),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          step.label,
                          style: TextStyle(
                            color: isUpcoming
                                ? const Color(0xFF64748B)
                                : TrackingUiColors.ink,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: badgeColor,
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(
                          badgeText,
                          style: TextStyle(
                            color: badgeTextColor,
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                  if (dateText != null) ...[
                    const SizedBox(height: 5),
                    Text(
                      dateText,
                      style: const TextStyle(
                        color: TrackingUiColors.muted,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                  if ((step.description ?? '').trim().isNotEmpty) ...[
                    const SizedBox(height: 6),
                    Text(
                      step.description!.trim(),
                      style: const TextStyle(
                        color: TrackingUiColors.muted,
                        fontSize: 12,
                        height: 1.35,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

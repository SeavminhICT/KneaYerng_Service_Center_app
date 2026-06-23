import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';

import 'delivery_tracking_colors.dart';

class DeliveryTrackingInlineWarning extends StatelessWidget {
  const DeliveryTrackingInlineWarning({super.key, required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: TrackingUiColors.dangerSoft,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFFECACA)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            HugeIcons.strokeRoundedAlertDiamond,
            color: TrackingUiColors.danger,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(
                color: TrackingUiColors.danger,
                fontWeight: FontWeight.w700,
                height: 1.35,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

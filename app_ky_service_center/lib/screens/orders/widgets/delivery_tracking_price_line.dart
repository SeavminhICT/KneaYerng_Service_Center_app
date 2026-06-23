import 'package:flutter/material.dart';

import 'delivery_tracking_colors.dart';

class DeliveryTrackingPriceLine extends StatelessWidget {
  const DeliveryTrackingPriceLine({
    super.key,
    required this.label,
    required this.value,
    this.isAccent = false,
    this.isStrong = false,
  });

  final String label;
  final String value;
  final bool isAccent;
  final bool isStrong;

  @override
  Widget build(BuildContext context) {
    Color textColor = TrackingUiColors.ink;
    if (isAccent) {
      textColor = TrackingUiColors.success;
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                color: TrackingUiColors.muted,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              color: textColor,
              fontWeight: isStrong ? FontWeight.w800 : FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

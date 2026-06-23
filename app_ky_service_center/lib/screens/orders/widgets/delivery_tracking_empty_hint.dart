import 'package:flutter/material.dart';

import 'delivery_tracking_colors.dart';

class DeliveryTrackingEmptyHint extends StatelessWidget {
  const DeliveryTrackingEmptyHint({super.key, required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFF),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: TrackingUiColors.panelBorder),
      ),
      child: Text(
        message,
        style: const TextStyle(
          color: TrackingUiColors.muted,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

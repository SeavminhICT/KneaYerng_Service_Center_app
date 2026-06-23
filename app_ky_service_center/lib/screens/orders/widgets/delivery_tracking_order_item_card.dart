import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../models/pickup_ticket.dart';
import 'delivery_tracking_colors.dart';

class DeliveryTrackingOrderItemCard extends StatelessWidget {
  const DeliveryTrackingOrderItemCard({
    super.key,
    required this.item,
    required this.money,
  });

  final PickupTicketItem item;
  final NumberFormat money;

  @override
  Widget build(BuildContext context) {
    final lineTotal = money.format(item.lineTotal);

    return Container(
      margin: const EdgeInsets.only(bottom: 9),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFF),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: TrackingUiColors.panelBorder),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              item.name,
              style: const TextStyle(
                color: TrackingUiColors.ink,
                fontWeight: FontWeight.w700,
                height: 1.3,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Text(
            'x${item.quantity}',
            style: const TextStyle(
              color: TrackingUiColors.muted,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(width: 12),
          Text(
            lineTotal,
            style: const TextStyle(
              color: TrackingUiColors.ink,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

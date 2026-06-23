import 'package:flutter/material.dart';

import 'bakong_info_row.dart';

/// Card listing order total, order number/ID, bill number, reference, and
/// the QR expiry countdown for the Bakong checkout sheet.
class BakongOrderSummaryCard extends StatelessWidget {
  const BakongOrderSummaryCard({
    super.key,
    required this.totalLabel,
    required this.total,
    required this.billNumber,
    required this.reference,
    this.orderNumber,
    this.orderId,
    this.expiresCountdown,
  });

  final String totalLabel;
  final String total;
  final String billNumber;
  final String reference;
  final String? orderNumber;
  final int? orderId;
  final String? expiresCountdown;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        children: [
          BakongInfoRow(label: totalLabel, value: '\$$total'),
          if (orderNumber != null)
            BakongInfoRow(label: 'Order No.', value: orderNumber!),
          if (orderNumber == null && orderId != null)
            BakongInfoRow(label: 'Order ID', value: orderId.toString()),
          BakongInfoRow(
            label: 'Bill No.',
            value: billNumber.isEmpty ? '-' : billNumber,
          ),
          BakongInfoRow(
            label: 'Reference',
            value: reference,
            valueStyle: const TextStyle(fontSize: 11),
          ),
          if (expiresCountdown != null)
            BakongInfoRow(label: 'Expires In', value: expiresCountdown!),
        ],
      ),
    );
  }
}

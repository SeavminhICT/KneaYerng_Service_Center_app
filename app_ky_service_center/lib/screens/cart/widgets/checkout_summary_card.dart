import 'package:flutter/material.dart';
import '../../../theme/app_fonts.dart';

import '../../../l10n/app_localizations.dart';
import 'checkout_colors.dart';
import 'checkout_summary_row.dart';
import 'checkout_surface_card.dart';

/// Live order pricing summary (subtotal/fees/discount/total) shown on the
/// payment step.
class CheckoutSummaryCard extends StatelessWidget {
  const CheckoutSummaryCard({
    super.key,
    required this.subtotal,
    required this.shipping,
    required this.tax,
    required this.discount,
    required this.total,
    required this.primary,
  });

  final double subtotal;
  final double shipping;
  final double tax;
  final double discount;
  final double total;
  final Color primary;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return CheckoutSurfaceCard(
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  l.orderSummary,
                  style: kFont(context,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: checkoutInk(context),
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: primary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  'Live total',
                  style: TextStyle(
                    color: primary,
                    fontWeight: FontWeight.w700,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: checkoutSurfaceAlt(context).withValues(alpha: 0.72),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Column(
              children: [
                CheckoutSummaryRow(label: l.subtotal, value: subtotal),
                CheckoutSummaryRow(label: l.deliveryFee, value: shipping),
                CheckoutSummaryRow(label: 'Tax', value: tax),
                if (discount > 0)
                  CheckoutSummaryRow(
                    label: 'Discount',
                    value: -discount,
                    color: const Color(0xFF16A34A),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  primary.withValues(alpha: 0.14),
                  const Color(0xFFF4F8FF),
                ],
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: primary.withValues(alpha: 0.16)),
            ),
            child: CheckoutSummaryRow(
              label: l.total,
              value: total,
              bold: true,
              color: primary,
            ),
          ),
        ],
      ),
    );
  }
}

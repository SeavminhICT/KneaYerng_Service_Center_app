import 'package:flutter/material.dart';
import '../../../theme/app_fonts.dart';

import '../../../l10n/app_localizations.dart';
import 'checkout_colors.dart';
import 'checkout_summary_row.dart';
import 'checkout_surface_card.dart';

/// Detailed pricing breakdown card shown on the confirm step.
class CheckoutReviewTotalsCard extends StatelessWidget {
  const CheckoutReviewTotalsCard({
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
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Pricing',
            style: kFont(context,
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: checkoutInk(context),
            ),
          ),
          const SizedBox(height: 12),
          CheckoutSummaryRow(label: l.subtotal, value: subtotal),
          CheckoutSummaryRow(label: 'Shipping', value: shipping),
          CheckoutSummaryRow(label: 'Tax', value: tax),
          if (discount > 0)
            CheckoutSummaryRow(
              label: 'Discount',
              value: -discount,
              color: const Color(0xFF16A34A),
            ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Divider(height: 1, color: checkoutBorder(context)),
          ),
          CheckoutSummaryRow(label: l.total, value: total, bold: true, color: primary),
        ],
      ),
    );
  }
}

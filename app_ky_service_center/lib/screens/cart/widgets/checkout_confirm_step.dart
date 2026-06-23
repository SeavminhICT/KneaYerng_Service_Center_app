import 'package:flutter/material.dart';
import '../../../theme/app_fonts.dart';
import 'package:hugeicons/hugeicons.dart';

import 'checkout_colors.dart';
import 'checkout_confirm_card.dart';
import 'checkout_review_meta_card.dart';
import 'checkout_review_totals_card.dart';

/// Step 3 of checkout: final review of delivery/pickup details, payment
/// method, and pricing before placing the order.
class CheckoutConfirmStep extends StatelessWidget {
  const CheckoutConfirmStep({
    super.key,
    required this.isPickup,
    required this.paymentLabel,
    required this.deliveryLines,
    required this.subtotal,
    required this.shipping,
    required this.tax,
    required this.discount,
    required this.total,
    required this.primary,
  });

  final bool isPickup;
  final String paymentLabel;
  final List<String> deliveryLines;
  final double subtotal;
  final double shipping;
  final double tax;
  final double discount;
  final double total;
  final Color primary;

  @override
  Widget build(BuildContext context) {
    return ListView(
      key: const ValueKey(3),
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 28),
      children: [
        Text(
          'Confirm Order',
          style: kFont(context,
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: checkoutInk(context),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          isPickup
              ? 'Review pickup, payment, and pricing before placing the order.'
              : 'Review the address, payment, and pricing before placing the order.',
          style: TextStyle(color: checkoutMuted(context), height: 1.45),
        ),
        const SizedBox(height: 14),
        CheckoutReviewMetaCard(
          orderType: isPickup ? 'Pickup' : 'Delivery',
          paymentLabel: paymentLabel,
          total: total,
          primary: primary,
        ),
        const SizedBox(height: 12),
        CheckoutConfirmCard(
          title: isPickup ? 'Pickup' : 'Delivery Address',
          icon: isPickup ? HugeIcons.strokeRoundedStore01 : HugeIcons.strokeRoundedMapsLocation01,
          lines: deliveryLines,
        ),
        const SizedBox(height: 12),
        CheckoutReviewTotalsCard(
          subtotal: subtotal,
          shipping: shipping,
          tax: tax,
          discount: discount,
          total: total,
          primary: primary,
        ),
        const SizedBox(height: 12),
      ],
    );
  }
}

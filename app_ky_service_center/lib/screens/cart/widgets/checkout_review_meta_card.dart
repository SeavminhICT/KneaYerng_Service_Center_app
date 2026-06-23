import 'package:flutter/material.dart';

import '../../../l10n/app_localizations.dart';
import 'checkout_colors.dart';
import 'checkout_surface_card.dart';

/// Three-column quick summary (order type / payment / total) shown at the
/// top of the confirm step.
class CheckoutReviewMetaCard extends StatelessWidget {
  const CheckoutReviewMetaCard({
    super.key,
    required this.orderType,
    required this.paymentLabel,
    required this.total,
    required this.primary,
  });

  final String orderType;
  final String paymentLabel;
  final double total;
  final Color primary;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return CheckoutSurfaceCard(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(
            child: _ReviewMetaItem(label: 'Order Type', value: orderType),
          ),
          Container(width: 1, height: 38, color: checkoutBorder(context)),
          Expanded(
            child: _ReviewMetaItem(
              label: l.payment,
              value: paymentLabel,
              alignEnd: true,
            ),
          ),
          Container(width: 1, height: 38, color: checkoutBorder(context)),
          Expanded(
            child: _ReviewMetaItem(
              label: l.total,
              value: '\$${total.toStringAsFixed(2)}',
              valueColor: primary,
              alignEnd: true,
            ),
          ),
        ],
      ),
    );
  }
}

class _ReviewMetaItem extends StatelessWidget {
  const _ReviewMetaItem({
    required this.label,
    required this.value,
    this.valueColor,
    this.alignEnd = false,
  });

  final String label;
  final String value;
  final Color? valueColor;
  final bool alignEnd;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Column(
        crossAxisAlignment: alignEnd
            ? CrossAxisAlignment.end
            : CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              color: checkoutMuted(context),
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: alignEnd ? TextAlign.right : TextAlign.left,
            style: TextStyle(
              color: valueColor ?? checkoutInk(context),
              fontWeight: FontWeight.w700,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}

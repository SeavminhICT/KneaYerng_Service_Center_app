import 'package:flutter/material.dart';

import 'checkout_colors.dart';

/// Generic bordered/shadowed card surface reused across the checkout flow.
class CheckoutSurfaceCard extends StatelessWidget {
  const CheckoutSurfaceCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
  });

  final Widget child;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: checkoutSurface(context),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: checkoutBorder(context)),
        boxShadow: [
          BoxShadow(
            color: checkoutShadow(context),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: child,
    );
  }
}

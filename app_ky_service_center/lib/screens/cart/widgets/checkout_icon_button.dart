import 'package:flutter/material.dart';

import 'checkout_colors.dart';

/// Small bordered icon button used for the checkout app bar back action.
class CheckoutIconButton extends StatelessWidget {
  const CheckoutIconButton({
    super.key,
    required this.icon,
    required this.onTap,
    this.circular = false,
    this.iconSize = 20,
  });

  final IconData icon;
  final VoidCallback onTap;
  final bool circular;
  final double iconSize;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(circular ? 999 : 16),
      child: Container(
        width: circular ? 42 : 44,
        height: circular ? 42 : 44,
        decoration: BoxDecoration(
          color: checkoutSurface(context),
          shape: circular ? BoxShape.circle : BoxShape.rectangle,
          borderRadius: circular ? null : BorderRadius.circular(16),
          border: Border.all(color: checkoutBorder(context)),
        ),
        child: Icon(icon, size: iconSize, color: checkoutInk(context)),
      ),
    );
  }
}

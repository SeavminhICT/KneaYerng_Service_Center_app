import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';

import 'cart_colors.dart';

/// Pill-shaped quantity stepper used inside the cart item card.
class CartQtyStepper extends StatelessWidget {
  const CartQtyStepper({super.key, required this.value, required this.onChanged});
  final int value;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 36,
      decoration: BoxDecoration(
        color: cartPrimarySoft,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _CartStepBtn(
            icon: HugeIcons.strokeRoundedRemove01,
            onTap: value > 1 ? () => onChanged(value - 1) : null,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Text(
              '$value',
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: cartInk),
            ),
          ),
          _CartStepBtn(
            icon: HugeIcons.strokeRoundedAdd01,
            onTap: () => onChanged(value + 1),
          ),
        ],
      ),
    );
  }
}

class _CartStepBtn extends StatelessWidget {
  const _CartStepBtn({required this.icon, required this.onTap});
  final IconData icon;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final enabled = onTap != null;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: SizedBox(
        width: 36,
        height: 36,
        child: Icon(
          icon,
          size: 17,
          color: enabled ? cartPrimaryDeep : cartMuted.withAlpha(100),
        ),
      ),
    );
  }
}

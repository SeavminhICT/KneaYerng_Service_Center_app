import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';

import 'cart_colors.dart';

/// Red delete background revealed when a cart item row is swiped to dismiss.
class CartDismissBackground extends StatelessWidget {
  const CartDismissBackground({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.centerRight,
      padding: const EdgeInsets.only(right: 26),
      decoration: BoxDecoration(
        color: cartDanger,
        borderRadius: BorderRadius.circular(20),
      ),
      child: const Icon(HugeIcons.strokeRoundedDelete01, color: Colors.white, size: 26),
    );
  }
}

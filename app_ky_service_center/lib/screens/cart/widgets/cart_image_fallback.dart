import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';

import 'cart_colors.dart';

/// Placeholder icon shown when a cart item has no usable product image.
class CartImageFallback extends StatelessWidget {
  const CartImageFallback({super.key, this.size = 28});
  final double size;

  @override
  Widget build(BuildContext context) {
    return Center(child: Icon(HugeIcons.strokeRoundedImageNotFound01, size: size, color: cartMuted));
  }
}

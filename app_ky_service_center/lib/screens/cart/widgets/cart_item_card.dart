import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hugeicons/hugeicons.dart';

import '../../../l10n/app_localizations.dart';
import '../../../models/cart_item.dart';
import '../../../theme/app_fonts.dart';
import '../../../widgets/app_network_image.dart';
import 'cart_colors.dart';
import 'cart_image_fallback.dart';
import 'cart_qty_stepper.dart';

/// Card showing a single cart line item: image, name, variant, price,
/// quantity stepper, and line subtotal.
class CartItemCard extends StatelessWidget {
  const CartItemCard({
    super.key,
    required this.item,
    required this.onRemove,
    required this.onQuantityChanged,
  });
  final CartItem item;
  final VoidCallback onRemove;
  final ValueChanged<int> onQuantityChanged;

  @override
  Widget build(BuildContext context) {
    final product  = item.product;
    final imageUrl = item.variantImageUrl ?? product.imageUrl;
    final variant  = item.variant?.trim().isNotEmpty == true ? item.variant!.trim() : '';
    final unitPrice = item.effectiveUnitPrice;
    final oldPrice  = product.hasDiscount && product.price > unitPrice ? product.price : null;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: cartSurface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(color: cartShadow, blurRadius: 16, offset: Offset(0, 4)),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Product image ───────────────────────────────────────────────
          Container(
            width: 76,
            height: 76,
            decoration: BoxDecoration(
              color: cartSurfaceSoft,
              borderRadius: BorderRadius.circular(16),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: imageUrl == null || imageUrl.isEmpty
                  ? const CartImageFallback(size: 26)
                  : Padding(
                      padding: const EdgeInsets.all(6),
                      child: AppNetworkImage(
                        imageUrl,
                        fit: BoxFit.contain,
                        alignment: Alignment.center,
                        errorWidget: (_, _, _) => const CartImageFallback(size: 26),
                      ),
                    ),
            ),
          ),
          const SizedBox(width: 12),
          // ── Info + controls ─────────────────────────────────────────────
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Name row + close
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        product.name,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: kmFont(context, GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: cartInk,
                          height: 1.25,
                        )),
                      ),
                    ),
                    const SizedBox(width: 6),
                    GestureDetector(
                      onTap: onRemove,
                      child: Container(
                        width: 28,
                        height: 28,
                        decoration: const BoxDecoration(
                          color: cartBg,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(HugeIcons.strokeRoundedCancel01, size: 15, color: cartMuted),
                      ),
                    ),
                  ],
                ),
                // Variant
                if (variant.isNotEmpty) ...[
                  const SizedBox(height: 3),
                  Text(
                    variant,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: cartMuted),
                  ),
                ],
                const SizedBox(height: 8),
                // Price row
                Row(
                  children: [
                    Text(
                      cartCurrency(unitPrice),
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: product.hasDiscount ? cartDanger : cartPrimaryDeep,
                        height: 1,
                      ),
                    ),
                    if (oldPrice != null) ...[
                      const SizedBox(width: 6),
                      Text(
                        cartCurrency(oldPrice),
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                          color: cartMuted,
                          decoration: TextDecoration.lineThrough,
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 10),
                // Qty + subtotal
                Row(
                  children: [
                    CartQtyStepper(value: item.quantity, onChanged: onQuantityChanged),
                    const Spacer(),
                    // Item subtotal
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          AppLocalizations.of(context).total,
                          style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: cartMuted),
                        ),
                        Text(
                          cartCurrency(item.subtotal),
                          style: kmFont(context, GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: cartInk,
                            height: 1.1,
                          )),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

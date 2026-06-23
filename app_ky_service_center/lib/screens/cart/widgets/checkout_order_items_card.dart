import 'package:flutter/material.dart';
import '../../../theme/app_fonts.dart';

import '../../../models/cart_item.dart';
import '../../../widgets/app_network_image.dart';
import 'checkout_colors.dart';
import 'checkout_surface_card.dart';

/// Card listing all cart items with thumbnail, quantity and subtotal.
class CheckoutOrderItemsCard extends StatelessWidget {
  const CheckoutOrderItemsCard({super.key, required this.items});

  final List<CartItem> items;

  @override
  Widget build(BuildContext context) {
    return CheckoutSurfaceCard(
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'Order items',
                style: kFont(context,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: checkoutInk(context),
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: checkoutSurfaceAlt(context),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  '${items.length} items',
                  style: TextStyle(
                    color: checkoutMuted(context),
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...items.map((item) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: checkoutSurfaceAlt(context).withValues(alpha: 0.72),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: SizedBox(
                        width: 58,
                        height: 58,
                        child:
                            item.product.imageUrl != null &&
                                item.product.imageUrl!.isNotEmpty
                            ? AppNetworkImage(
                                item.product.imageUrl!,
                                fit: BoxFit.cover,
                                errorWidget: (context, url, error) =>
                                    _FallbackProductTile(
                                      quantity: item.quantity,
                                    ),
                              )
                            : _FallbackProductTile(quantity: item.quantity),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.product.name,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              color: checkoutInk(context),
                              height: 1.35,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 5,
                            ),
                            decoration: BoxDecoration(
                              color: checkoutSurface(context),
                              borderRadius: BorderRadius.circular(999),
                            ),
                            child: Text(
                              'Qty ${item.quantity}',
                              style: TextStyle(
                                color: checkoutMuted(context),
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '\$${item.subtotal.toStringAsFixed(2)}',
                      style: kFont(context,
                        fontWeight: FontWeight.w700,
                        color: checkoutInk(context),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}

class _FallbackProductTile extends StatelessWidget {
  const _FallbackProductTile({required this.quantity});

  final int quantity;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: checkoutSurfaceAlt(context),
      child: Center(
        child: Container(
          width: 34,
          height: 34,
          decoration: BoxDecoration(
            color: checkoutSurface(context),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Center(
            child: Text(
              'x$quantity',
              style: kFont(context,
                fontWeight: FontWeight.w700,
                color: checkoutMuted(context),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

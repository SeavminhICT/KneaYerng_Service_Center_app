import 'package:flutter/material.dart';

import '../../../models/product.dart';
import '../../../widgets/app_network_image.dart';
import '../../products/product_detail_screen.dart';
import 'search_results_tone.dart';

/// List-style product row used by [SearchProductList].
class SearchProductRow extends StatelessWidget {
  const SearchProductRow({super.key, required this.product, required this.onAdd});

  final Product product;
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    final hasDiscount =
        product.hasDiscount && product.salePrice < product.price;

    return GestureDetector(
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => ProductDetailScreen(product: product),
        ),
      ),
      child: Container(
        decoration: BoxDecoration(
          color: searchSurface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: searchBorder),
          boxShadow: const [
            BoxShadow(color: searchShadow, blurRadius: 10, offset: Offset(0, 4)),
          ],
        ),
        child: Row(
          children: [
            // Image
            ClipRRect(
              borderRadius: const BorderRadius.horizontal(
                left: Radius.circular(16),
              ),
              child: Container(
                width: 110,
                height: 110,
                color: searchBg,
                child: product.imageUrl == null || product.imageUrl!.isEmpty
                    ? const Center(
                        child: Icon(
                          Icons.inventory_2_outlined,
                          color: searchMuted,
                          size: 30,
                        ),
                      )
                    : Padding(
                        padding: const EdgeInsets.all(10),
                        child: AppNetworkImage(
                          product.imageUrl!,
                          fit: BoxFit.contain,
                          errorWidget: (_, _, _) => const Center(
                            child: Icon(
                              Icons.inventory_2_outlined,
                              color: searchMuted,
                              size: 30,
                            ),
                          ),
                        ),
                      ),
              ),
            ),

            // Info
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if ((product.brand ?? '').isNotEmpty)
                      Text(
                        product.brand!,
                        style: const TextStyle(
                          fontSize: 10.5,
                          color: searchMuted,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    const SizedBox(height: 2),
                    Text(
                      product.name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: searchInk,
                        height: 1.3,
                      ),
                    ),
                    const SizedBox(height: 6),
                    // rating
                    Row(
                      children: [
                        const Icon(
                          Icons.star_rounded,
                          size: 13,
                          color: Colors.amber,
                        ),
                        const SizedBox(width: 3),
                        Text(
                          product.rating.toStringAsFixed(1),
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: searchInk,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                searchCurrency.format(product.salePrice),
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w800,
                                  color: hasDiscount ? searchRed : searchInk,
                                ),
                              ),
                              if (hasDiscount)
                                Text(
                                  searchCurrency.format(product.price),
                                  style: const TextStyle(
                                    fontSize: 11,
                                    color: searchMuted,
                                    decoration: TextDecoration.lineThrough,
                                  ),
                                ),
                            ],
                          ),
                        ),
                        GestureDetector(
                          onTap: onAdd,
                          child: Container(
                            height: 34,
                            width: 34,
                            decoration: BoxDecoration(
                              color: searchBlue,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(
                              Icons.add_rounded,
                              color: Colors.white,
                              size: 18,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

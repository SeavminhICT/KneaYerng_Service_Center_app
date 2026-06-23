import 'package:flutter/material.dart';

import '../../../models/product.dart';
import '../../../widgets/app_network_image.dart';
import '../../products/product_detail_screen.dart';
import 'search_results_tone.dart';

/// Grid-style product card used by [SearchProductGrid].
class SearchProductCard extends StatelessWidget {
  const SearchProductCard({super.key, required this.product, required this.onAdd});

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
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: searchBorder),
          boxShadow: const [
            BoxShadow(color: searchShadow, blurRadius: 14, offset: Offset(0, 6)),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image
            Expanded(
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(18),
                ),
                child: Container(
                  color: searchBg,
                  width: double.infinity,
                  child: product.imageUrl == null || product.imageUrl!.isEmpty
                      ? const Center(
                          child: Icon(
                            Icons.inventory_2_outlined,
                            color: searchMuted,
                            size: 36,
                          ),
                        )
                      : Padding(
                          padding: const EdgeInsets.all(12),
                          child: AppNetworkImage(
                            product.imageUrl!,
                            fit: BoxFit.contain,
                            errorWidget: (_, _, _) => const Center(
                              child: Icon(
                                Icons.inventory_2_outlined,
                                color: searchMuted,
                                size: 36,
                              ),
                            ),
                          ),
                        ),
                ),
              ),
            ),

            // Info
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Brand / Category
                  if ((product.brand ?? '').isNotEmpty ||
                      (product.categoryName ?? '').isNotEmpty)
                    Text(
                      [product.brand, product.categoryName]
                          .where((s) => s != null && s.trim().isNotEmpty)
                          .join(' · '),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 10.5,
                        color: searchMuted,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  const SizedBox(height: 3),

                  // Name
                  Text(
                    product.name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: searchInk,
                      height: 1.3,
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Price + add
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              searchCurrency.format(product.salePrice),
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w800,
                                color: hasDiscount ? searchRed : searchInk,
                              ),
                            ),
                            if (hasDiscount)
                              Text(
                                searchCurrency.format(product.price),
                                style: const TextStyle(
                                  fontSize: 10.5,
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
                          height: 32,
                          width: 32,
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
          ],
        ),
      ),
    );
  }
}

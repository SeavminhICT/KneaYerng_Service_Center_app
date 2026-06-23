import 'package:flutter/material.dart';

import '../../../models/product.dart';
import '../../../models/search_results.dart';
import 'search_product_card.dart';

/// Grid layout of [SearchProductCard]s, used for both regular products and
/// (via [accessories]) the accessories section. Accessories are currently
/// rendered as an empty product list placeholder — kept identical to the
/// pre-extraction behavior.
class SearchProductGrid extends StatelessWidget {
  const SearchProductGrid({
    super.key,
    required this.cols,
    required this.products,
    required this.onAdd,
    this.accessories = const [],
  });

  final int cols;
  final List<Product> products;
  final ValueChanged<Product> onAdd;
  final List<SearchAccessory> accessories;

  @override
  Widget build(BuildContext context) {
    final items = products;
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: items.length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: cols,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        mainAxisExtent: 260,
      ),
      itemBuilder: (_, i) =>
          SearchProductCard(product: items[i], onAdd: () => onAdd(items[i])),
    );
  }
}

import 'package:flutter/material.dart';

import '../../../models/product.dart';
import 'search_product_row.dart';

/// Vertical list layout of [SearchProductRow]s, used when list view is
/// selected instead of grid view.
class SearchProductList extends StatelessWidget {
  const SearchProductList({super.key, required this.products, required this.onAdd});

  final List<Product> products;
  final ValueChanged<Product> onAdd;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: products.length,
      separatorBuilder: (_, _) => const SizedBox(height: 10),
      itemBuilder: (_, i) => SearchProductRow(
        product: products[i],
        onAdd: () => onAdd(products[i]),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:skeletonizer/skeletonizer.dart';

import '../../../models/product.dart';
import '../../../models/search_results.dart';
import 'search_empty_state.dart';
import 'search_filter_row.dart';
import 'search_product_grid.dart';
import 'search_product_list.dart';
import 'search_results_header.dart';
import 'search_results_tone.dart';
import 'search_section_label.dart';
import 'search_service_chip.dart';

/// Sliver that renders the full search results body: header, filter chips,
/// product grid/list, accessories, related services, and empty state.
class SearchResultsSliver extends StatelessWidget {
  const SearchResultsSliver({
    super.key,
    required this.future,
    required this.isGrid,
    required this.cols,
    required this.onAdd,
    required this.onSubmit,
  });

  final Future<SearchResults> future;
  final bool isGrid;
  final int cols;
  final ValueChanged<Product> onAdd;
  final ValueChanged<String> onSubmit;

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: FutureBuilder<SearchResults>(
        future: future,
        builder: (context, snap) {
          final loading = snap.connectionState == ConnectionState.waiting;

          final results = loading
              ? SearchResults(
                  query: '',
                  products: List.generate(
                    6,
                    (i) => Product(
                      id: i,
                      name: 'Product Name Loading Here',
                      price: 99.99,
                      salePriceOverride: 79.99,
                      stock: 5,
                    ),
                  ),
                )
              : snap.data;

          if (snap.hasError) {
            return Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              child: SearchEmptyState(
                icon: Icons.wifi_off_rounded,
                title: 'Connection error',
                subtitle: 'Check your connection and try again.',
                action: 'Retry',
                onAction: () => onSubmit(''),
              ),
            );
          }

          if (results == null) return const SizedBox.shrink();

          final totalProducts = results.products.length + results.accessories.length;
          final totalAll = totalProducts + results.repairServices.length;

          return Skeletonizer(
            enabled: loading,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 12),

                  // ── Header ───────────────────────────────────────────────
                  if (!loading)
                    SearchResultsHeader(
                      query: results.query,
                      total: totalAll,
                    ),
                  if (loading)
                    Container(
                      height: 20,
                      width: 180,
                      decoration: BoxDecoration(
                        color: searchBorder,
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                  const SizedBox(height: 12),

                  // ── Filter chips ─────────────────────────────────────────
                  if (results.categories.isNotEmpty || results.brands.isNotEmpty) ...[
                    SearchFilterRow(
                      categories: results.categories.map((c) => c.name).toList(),
                      brands: results.brands,
                      onSelect: onSubmit,
                    ),
                    const SizedBox(height: 14),
                  ],

                  // ── Products ─────────────────────────────────────────────
                  if (results.products.isNotEmpty) ...[
                    isGrid
                        ? SearchProductGrid(
                            cols: cols,
                            products: results.products,
                            onAdd: onAdd,
                          )
                        : SearchProductList(
                            products: results.products,
                            onAdd: onAdd,
                          ),
                    const SizedBox(height: 16),
                  ],

                  // ── Accessories ───────────────────────────────────────────
                  if (results.accessories.isNotEmpty) ...[
                    const SearchSectionLabel('Accessories'),
                    const SizedBox(height: 10),
                    SearchProductGrid(
                      cols: cols,
                      products: [],
                      onAdd: onAdd,
                      accessories: results.accessories,
                    ),
                    const SizedBox(height: 16),
                  ],

                  // ── Repair services (compact strip) ────────────────────
                  if (results.repairServices.isNotEmpty) ...[
                    const SearchSectionLabel('Related services'),
                    const SizedBox(height: 10),
                    SizedBox(
                      height: 120,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: results.repairServices.length,
                        separatorBuilder: (_, _) => const SizedBox(width: 10),
                        itemBuilder: (_, i) =>
                            SearchServiceChip(service: results.repairServices[i]),
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],

                  // ── Empty ─────────────────────────────────────────────────
                  if (!loading && !results.hasAnyResult)
                    SearchEmptyState(
                      icon: Icons.search_off_rounded,
                      title: 'No results found',
                      subtitle: 'Try a different keyword.',
                      popularSearches: results.popularSearches,
                      onSelectPopular: onSubmit,
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

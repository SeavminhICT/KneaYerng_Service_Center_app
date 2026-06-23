import 'package:flutter/material.dart';

import '../../../models/search_suggestion.dart';
import '../../../theme/app_fonts.dart';
import 'all_products_common.dart';

/// Dropdown-style panel shown while the user is typing a search query,
/// listing live suggestions fetched from the API.
class AllProductsSearchSuggestionPanel extends StatelessWidget {
  const AllProductsSearchSuggestionPanel({
    super.key,
    required this.query,
    required this.items,
    required this.isLoading,
    required this.onSearchQuery,
    required this.onSelect,
  });

  final String query;
  final List<SearchSuggestion> items;
  final bool isLoading;
  final VoidCallback onSearchQuery;
  final ValueChanged<SearchSuggestion> onSelect;

  @override
  Widget build(BuildContext context) {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
      children: [
        Container(
          decoration: BoxDecoration(
            color: apSurface,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: apBorder),
            boxShadow: const [
              BoxShadow(color: apShadow, blurRadius: 18, offset: Offset(0, 10)),
            ],
          ),
          child: Column(
            children: [
              InkWell(
                onTap: onSearchQuery,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(18),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 12,
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.search_rounded,
                        color: apBrandBlue,
                        size: 20,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'Search "$query"',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: kmFont(context, const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: apTextPrimary,
                            fontFamily: 'SF Pro Text',
                          )),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const Divider(height: 1, color: apBorder),
              if (isLoading)
                const Padding(
                  padding: EdgeInsets.all(16),
                  child: Row(
                    children: [
                      SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                      SizedBox(width: 12),
                      Text(
                        'Loading suggestions...',
                        style: TextStyle(
                          color: apTextMuted,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                )
              else if (items.isEmpty)
                const Padding(
                  padding: EdgeInsets.all(16),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'No suggestions found.',
                      style: TextStyle(
                        color: apTextMuted,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                )
              else
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: items.length,
                  separatorBuilder: (_, _) =>
                      const Divider(height: 1, color: apBorder),
                  itemBuilder: (context, index) {
                    final suggestion = items[index];
                    return InkWell(
                      onTap: () => onSelect(suggestion),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 12,
                        ),
                        child: Row(
                          children: [
                            Container(
                              height: 38,
                              width: 38,
                              decoration: BoxDecoration(
                                color: apSurfaceAlt,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(
                                _iconForSuggestionType(suggestion.type),
                                size: 18,
                                color: apBrandBlue,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    suggestion.label,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w700,
                                      color: apTextPrimary,
                                    ),
                                  ),
                                  if (suggestion.subtitle != null &&
                                      suggestion.subtitle!
                                          .trim()
                                          .isNotEmpty) ...[
                                    const SizedBox(height: 2),
                                    Text(
                                      suggestion.subtitle!,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        fontSize: 11.5,
                                        color: apTextMuted,
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              _labelForSuggestionType(suggestion.type),
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: apBrandBlue,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Recent + popular search suggestions shown before the user types anything.
class AllProductsSearchDiscoveryList extends StatelessWidget {
  const AllProductsSearchDiscoveryList({
    super.key,
    required this.recentSearches,
    required this.popularSearches,
    required this.onSelect,
  });

  final List<String> recentSearches;
  final List<String> popularSearches;
  final ValueChanged<String> onSelect;

  @override
  Widget build(BuildContext context) {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
      children: [
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: apSurface,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: apBorder),
            boxShadow: const [
              BoxShadow(color: apShadow, blurRadius: 18, offset: Offset(0, 10)),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (recentSearches.isNotEmpty) ...[
                Text(
                  'Recent searches',
                  style: kmFont(context, const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: apTextPrimary,
                    fontFamily: 'SF Pro Text',
                  )),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: recentSearches.map((item) {
                    return _SearchChip(
                      icon: Icons.history_rounded,
                      label: item,
                      onTap: () => onSelect(item),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 14),
              ],
              Text(
                'Popular searches',
                style: kmFont(context, const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: apTextPrimary,
                  fontFamily: 'SF Pro Text',
                )),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: popularSearches.map((item) {
                  return _SearchChip(
                    icon: Icons.trending_up_rounded,
                    label: item,
                    onTap: () => onSelect(item),
                  );
                }).toList(),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _SearchChip extends StatelessWidget {
  const _SearchChip({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(999),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
        decoration: BoxDecoration(
          color: apSurfaceAlt,
          borderRadius: BorderRadius.circular(999),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14, color: apBrandBlue),
            const SizedBox(width: 6),
            Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: apTextPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

IconData _iconForSuggestionType(String type) {
  switch (type.toLowerCase()) {
    case 'product':
      return Icons.inventory_2_outlined;
    case 'accessory':
      return Icons.cable_rounded;
    case 'brand':
      return Icons.sell_outlined;
    case 'category':
      return Icons.category_outlined;
    case 'repair':
      return Icons.build_circle_outlined;
    default:
      return Icons.search_rounded;
  }
}

String _labelForSuggestionType(String type) {
  switch (type.toLowerCase()) {
    case 'product':
      return 'Product';
    case 'accessory':
      return 'Accessory';
    case 'brand':
      return 'Brand';
    case 'category':
      return 'Category';
    case 'repair':
      return 'Repair';
    default:
      return 'Search';
  }
}

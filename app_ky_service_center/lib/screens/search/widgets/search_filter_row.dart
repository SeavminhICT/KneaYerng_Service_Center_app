import 'package:flutter/material.dart';

import 'search_results_tone.dart';

/// Horizontally scrolling row of brand/category quick-filter chips shown
/// above the search results.
class SearchFilterRow extends StatelessWidget {
  const SearchFilterRow({
    super.key,
    required this.categories,
    required this.brands,
    required this.onSelect,
  });

  final List<String> categories;
  final List<String> brands;
  final ValueChanged<String> onSelect;

  @override
  Widget build(BuildContext context) {
    final chips = <String>[
      ...brands.take(4),
      ...categories.where((c) => !brands.contains(c)).take(4),
    ];

    return SizedBox(
      height: 34,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: chips.length,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (_, i) => GestureDetector(
          onTap: () => onSelect(chips[i]),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            decoration: BoxDecoration(
              color: searchSurface,
              borderRadius: BorderRadius.circular(999),
              border: Border.all(color: searchBorder),
              boxShadow: const [
                BoxShadow(color: searchShadow, blurRadius: 6, offset: Offset(0, 2)),
              ],
            ),
            child: Text(
              chips[i],
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: searchInk,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

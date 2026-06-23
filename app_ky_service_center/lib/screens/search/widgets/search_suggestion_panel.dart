import 'package:flutter/material.dart';

import '../../../models/search_suggestion.dart';
import 'search_results_tone.dart';
import 'search_suggestion_row.dart';
import 'search_suggestion_type.dart';

/// Dropdown-style panel of live search suggestions shown while the field is
/// focused with a non-empty query.
class SearchSuggestionPanel extends StatelessWidget {
  const SearchSuggestionPanel({
    super.key,
    required this.items,
    required this.query,
    required this.isLoading,
    required this.onSelect,
    required this.onSearchQuery,
  });

  final List<SearchSuggestion> items;
  final String query;
  final bool isLoading;
  final ValueChanged<SearchSuggestion> onSelect;
  final VoidCallback onSearchQuery;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: searchSurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: searchBorder),
      ),
      child: Column(
        children: [
          // "Search for X" row
          SearchSuggestionRow(
            leading: Container(
              height: 36,
              width: 36,
              decoration: BoxDecoration(
                color: searchBlueLight,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.search_rounded, color: searchBlue, size: 18),
            ),
            title: 'Search "$query"',
            onTap: onSearchQuery,
            isFirst: true,
          ),
          if (isLoading)
            const Padding(
              padding: EdgeInsets.all(14),
              child: Row(
                children: [
                  SizedBox(
                    height: 16,
                    width: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                  SizedBox(width: 10),
                  Text(
                    'Loading suggestions…',
                    style: TextStyle(color: searchMuted, fontSize: 13),
                  ),
                ],
              ),
            )
          else
            ...items.map((s) => SearchSuggestionRow(
                  leading: Container(
                    height: 36,
                    width: 36,
                    decoration: BoxDecoration(
                      color: searchBg,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      searchSuggestionIcon(s.type),
                      color: searchMuted,
                      size: 17,
                    ),
                  ),
                  title: s.label,
                  subtitle: s.subtitle,
                  badge: searchSuggestionBadge(s.type),
                  onTap: () => onSelect(s),
                  isFirst: false,
                )),
        ],
      ),
    );
  }
}

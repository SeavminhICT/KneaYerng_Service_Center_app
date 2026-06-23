import 'package:flutter/material.dart';

import 'search_results_tone.dart';
import 'search_section_label.dart';
import 'search_suggestion_chip.dart';

/// Panel shown when the search field is focused and empty, listing recent
/// and popular searches.
class SearchDiscoveryPanel extends StatelessWidget {
  const SearchDiscoveryPanel({
    super.key,
    required this.recent,
    required this.popular,
    required this.onSelect,
  });

  final List<String> recent;
  final List<String> popular;
  final ValueChanged<String> onSelect;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: searchSurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: searchBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (recent.isNotEmpty) ...[
            const SearchSectionLabel('Recent searches'),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: recent.map((s) => SearchSuggestionChip(
                icon: Icons.history_rounded,
                label: s,
                onTap: () => onSelect(s),
              )).toList(),
            ),
            const SizedBox(height: 16),
          ],
          const SearchSectionLabel('Popular searches'),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: popular.map((s) => SearchSuggestionChip(
              icon: Icons.trending_up_rounded,
              label: s,
              onTap: () => onSelect(s),
            )).toList(),
          ),
        ],
      ),
    );
  }
}

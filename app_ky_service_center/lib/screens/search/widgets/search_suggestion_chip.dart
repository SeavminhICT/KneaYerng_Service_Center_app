import 'package:flutter/material.dart';

import 'search_results_tone.dart';

/// Small pill-shaped chip with a leading icon, used for recent/popular
/// search suggestions in [SearchDiscoveryPanel].
class SearchSuggestionChip extends StatelessWidget {
  const SearchSuggestionChip({
    super.key,
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: searchBg,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: searchBorder),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 13, color: searchBlue),
            const SizedBox(width: 6),
            Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: searchInk,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

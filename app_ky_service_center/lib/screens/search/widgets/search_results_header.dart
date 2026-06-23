import 'package:flutter/material.dart';

import 'search_results_tone.dart';

/// Rich-text header showing the result count and search query, e.g.
/// "12 results for "iphone"".
class SearchResultsHeader extends StatelessWidget {
  const SearchResultsHeader({super.key, required this.query, required this.total});

  final String query;
  final int total;

  @override
  Widget build(BuildContext context) {
    return RichText(
      text: TextSpan(
        style: const TextStyle(
          fontSize: 15,
          color: searchMuted,
          fontWeight: FontWeight.w500,
        ),
        children: [
          TextSpan(
            text: '$total ',
            style: const TextStyle(
              color: searchInk,
              fontWeight: FontWeight.w800,
              fontSize: 16,
            ),
          ),
          const TextSpan(text: 'results for '),
          TextSpan(
            text: '"$query"',
            style: const TextStyle(
              color: searchBlue,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

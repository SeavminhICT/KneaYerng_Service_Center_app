import 'package:flutter/material.dart';

import 'search_results_tone.dart';

/// Small uppercase-style section heading used throughout the search results
/// screen (e.g. "Recent searches", "Accessories", "Related services").
class SearchSectionLabel extends StatelessWidget {
  const SearchSectionLabel(this.text, {super.key});
  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w800,
        color: searchMuted,
        letterSpacing: 0.4,
      ),
    );
  }
}

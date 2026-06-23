import 'package:flutter/material.dart';

import 'search_results_tone.dart';

/// Generic empty/error state card used for "no results" and connection
/// error cases, optionally showing a retry action or popular search chips.
class SearchEmptyState extends StatelessWidget {
  const SearchEmptyState({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    this.action,
    this.onAction,
    this.popularSearches = const [],
    this.onSelectPopular,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final String? action;
  final VoidCallback? onAction;
  final List<String> popularSearches;
  final ValueChanged<String>? onSelectPopular;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: searchSurface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: searchBorder),
      ),
      child: Column(
        children: [
          Container(
            height: 64,
            width: 64,
            decoration: const BoxDecoration(
              color: searchBg,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 32, color: searchMuted),
          ),
          const SizedBox(height: 14),
          Text(
            title,
            style: const TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w800,
              color: searchInk,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 13, color: searchMuted),
          ),
          if (action != null && onAction != null) ...[
            const SizedBox(height: 16),
            FilledButton(
              onPressed: onAction,
              style: FilledButton.styleFrom(backgroundColor: searchBlue),
              child: Text(action!),
            ),
          ],
          if (popularSearches.isNotEmpty && onSelectPopular != null) ...[
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: popularSearches.map((s) => GestureDetector(
                onTap: () => onSelectPopular!(s),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: searchBg,
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(color: searchBorder),
                  ),
                  child: Text(
                    s,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: searchInk,
                    ),
                  ),
                ),
              )).toList(),
            ),
          ],
        ],
      ),
    );
  }
}

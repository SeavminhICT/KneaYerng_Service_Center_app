import 'package:flutter/material.dart';

import 'search_results_tone.dart';

/// A single tappable row inside [SearchSuggestionPanel].
class SearchSuggestionRow extends StatelessWidget {
  const SearchSuggestionRow({
    super.key,
    required this.leading,
    required this.title,
    required this.onTap,
    required this.isFirst,
    this.subtitle,
    this.badge,
  });

  final Widget leading;
  final String title;
  final String? subtitle;
  final String? badge;
  final VoidCallback onTap;
  final bool isFirst;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (!isFirst) const Divider(height: 1, color: searchBorder),
        InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            child: Row(
              children: [
                leading,
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: isFirst ? FontWeight.w700 : FontWeight.w600,
                          color: isFirst ? searchBlue : searchInk,
                        ),
                      ),
                      if (subtitle != null && subtitle!.isNotEmpty) ...[
                        const SizedBox(height: 2),
                        Text(
                          subtitle!,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 11,
                            color: searchMuted,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                if (badge != null)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: searchBlueLight,
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      badge!,
                      style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: searchBlue,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

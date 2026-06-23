import 'package:flutter/material.dart';

import '../../../models/search_results.dart';
import 'search_results_tone.dart';

/// Compact card representing a repair service, shown in the horizontal
/// "Related services" strip.
class SearchServiceChip extends StatelessWidget {
  const SearchServiceChip({super.key, required this.service});

  final SearchRepairService service;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 220,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: searchBlueLight,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: searchBlue.withValues(alpha: 0.18)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                height: 30,
                width: 30,
                decoration: BoxDecoration(
                  color: searchBlue.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(9),
                ),
                child: const Icon(
                  Icons.build_circle_outlined,
                  color: searchBlue,
                  size: 16,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  service.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w700,
                    color: searchInk,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Expanded(
            child: Text(
              service.description,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 11.5,
                color: searchMuted,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

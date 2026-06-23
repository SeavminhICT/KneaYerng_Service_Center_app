import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';

import 'product_detail_tone.dart';

/// Compact star + numeric rating + review count row shown under the
/// product title.
class ProductRatingRow extends StatelessWidget {
  const ProductRatingRow({
    super.key,
    required this.tone,
    required this.rating,
    required this.ratingCount,
  });

  final ProductDetailTone tone;
  final double            rating;
  final int               ratingCount;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Icon(HugeIcons.strokeRoundedStar, size: 16, color: pdAmber),
        const SizedBox(width: 4),
        Text(
          rating.toStringAsFixed(1),
          style: TextStyle(
            fontSize:   13.5,
            fontWeight: FontWeight.w700,
            color:      tone.textPrimary,
          ),
        ),
        const SizedBox(width: 4),
        Text(
          '($ratingCount)',
          style: TextStyle(fontSize: 13, color: tone.textSub),
        ),
      ],
    );
  }
}

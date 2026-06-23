import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hugeicons/hugeicons.dart';

import '../../../theme/app_fonts.dart';
import 'product_detail_tone.dart';
import 'product_review_card.dart';
import 'product_review_entry.dart';

/// Bottom sheet listing all reviews for a product, sorted newest-first.
class ProductAllReviewsSheet extends StatelessWidget {
  const ProductAllReviewsSheet({
    super.key,
    required this.productName,
    required this.averageRating,
    required this.ratingCount,
    required this.reviews,
  });

  final String                  productName;
  final double                  averageRating;
  final int                     ratingCount;
  final List<ProductReviewEntry> reviews;

  @override
  Widget build(BuildContext context) {
    final tone          = ProductDetailTone.of(context);
    final bottomInset   = MediaQuery.viewInsetsOf(context).bottom;
    final sortedReviews = [...reviews]
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

    return AnimatedPadding(
      duration: const Duration(milliseconds: 180),
      curve:    Curves.easeOut,
      padding:  EdgeInsets.fromLTRB(0, 0, 0, bottomInset),
      child: Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.sizeOf(context).height * 0.88,
        ),
        decoration: BoxDecoration(
          color:        tone.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(22)),
        ),
        child: SafeArea(
          top: false,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Handle
              Center(
                child: Container(
                  margin: const EdgeInsets.only(top: 10),
                  width:  40,
                  height: 4,
                  decoration: BoxDecoration(
                    color:        tone.border,
                    borderRadius: BorderRadius.circular(99),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            'Reviews',
                            style: kmFont(context, GoogleFonts.inter(
                              fontSize:   18,
                              fontWeight: FontWeight.w700,
                              color:      tone.textPrimary,
                            )),
                          ),
                        ),
                        IconButton(
                          onPressed: () => Navigator.of(context).pop(),
                          icon: const Icon(HugeIcons.strokeRoundedCancel01),
                          color: tone.textSub,
                        ),
                      ],
                    ),
                    Text(
                      productName,
                      maxLines:  1,
                      overflow:  TextOverflow.ellipsis,
                      style: TextStyle(fontSize: 13, color: tone.textSub),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Text(
                          ratingCount > 0
                              ? averageRating.toStringAsFixed(1)
                              : 'New',
                          style: kmFont(context, GoogleFonts.inter(
                            fontSize:   24,
                            fontWeight: FontWeight.w700,
                            color:      tone.textPrimary,
                          )),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: ProductStarRatingRow(rating: averageRating),
                        ),
                        Text(
                          ratingCount > 0
                              ? '$ratingCount review${ratingCount == 1 ? '' : 's'}'
                              : 'No reviews',
                          style: TextStyle(
                              fontSize: 12.5, color: tone.textSub),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                  ],
                ),
              ),
              Divider(color: tone.divider, height: 1),
              Expanded(
                child: sortedReviews.isEmpty
                    ? Center(
                        child: Text(
                          'No reviews yet.',
                          style: TextStyle(color: tone.textSub),
                        ),
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.all(16),
                        itemCount:        sortedReviews.length,
                        separatorBuilder: (context, index) =>
                            const SizedBox(height: 10),
                        itemBuilder: (context, i) =>
                            ProductReviewCard(tone: tone, review: sortedReviews[i]),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

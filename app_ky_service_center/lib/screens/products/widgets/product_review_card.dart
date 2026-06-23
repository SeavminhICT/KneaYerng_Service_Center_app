import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hugeicons/hugeicons.dart';

import '../../../theme/app_fonts.dart';
import 'product_detail_tone.dart';
import 'product_review_entry.dart';

/// Star rating row (filled / half / outline icons), used in review cards
/// and review sheets.
class ProductStarRatingRow extends StatelessWidget {
  const ProductStarRatingRow({super.key, required this.rating, this.iconSize = 18});

  final double rating;
  final double iconSize;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (i) {
        final filled = rating >= i + 1;
        final half   = !filled && rating > i && rating < i + 1;
        return Padding(
          padding: EdgeInsets.only(right: i == 4 ? 0 : 4),
          child: Icon(
            filled ? HugeIcons.strokeRoundedStar
                : half ? HugeIcons.strokeRoundedStarHalf
                : HugeIcons.strokeRoundedStar,
            size:  iconSize,
            color: pdAmber,
          ),
        );
      }),
    );
  }
}

/// Single review card: avatar, author, date, star rating, comment, photos.
class ProductReviewCard extends StatelessWidget {
  const ProductReviewCard({super.key, required this.tone, required this.review});

  final ProductDetailTone  tone;
  final ProductReviewEntry review;

  @override
  Widget build(BuildContext context) {
    return Container(
      width:   double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color:        tone.white,
        borderRadius: BorderRadius.circular(14),
        border:       Border.all(color: tone.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width:  36,
                height: 36,
                decoration: BoxDecoration(
                  color:        tone.avatarBg,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Center(
                  child: Text(
                    review.author.substring(0, 1).toUpperCase(),
                    style: kmFont(context, GoogleFonts.inter(
                      fontSize:   14,
                      fontWeight: FontWeight.w700,
                      color:      tone.textPrimary,
                    )),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      review.author,
                      style: TextStyle(
                        fontSize:   13.5,
                        fontWeight: FontWeight.w600,
                        color:      tone.textPrimary,
                      ),
                    ),
                    Text(
                      review.formattedDate,
                      style: TextStyle(fontSize: 11.5, color: tone.textSub),
                    ),
                  ],
                ),
              ),
              ProductStarRatingRow(rating: review.rating.toDouble(), iconSize: 14),
            ],
          ),
          if (review.comment.trim().isNotEmpty) ...[
            const SizedBox(height: 10),
            Text(
              review.comment,
              style: TextStyle(
                fontSize: 13.5,
                height:   1.6,
                color:    tone.textPrimary,
              ),
            ),
          ],
          if (review.images.isNotEmpty) ...[
            const SizedBox(height: 10),
            Wrap(
              spacing:    6,
              runSpacing: 6,
              children: [
                for (final bytes in review.images)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: SizedBox(
                      width:  80,
                      height: 80,
                      child:  Image.memory(bytes, fit: BoxFit.cover),
                    ),
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

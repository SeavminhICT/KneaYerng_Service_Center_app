import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../theme/app_fonts.dart';
import 'reviews_preview_feedback_entry.dart';

/// Single feedback history card: avatar, name, time ago, star rating,
/// comment and any attached images. Extracted verbatim from
/// reviews_preview_screen.dart (was `_FeedbackHistoryCard`).
class ReviewsPreviewHistoryCard extends StatelessWidget {
  const ReviewsPreviewHistoryCard({
    super.key,
    required this.entry,
    required this.timeLabel,
  });

  final FeedbackEntry entry;
  final String timeLabel;

  @override
  Widget build(BuildContext context) {
    final decodedImages = entry.decodeImages();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = isDark ? Theme.of(context).scaffoldBackgroundColor : Colors.white;
    final border = isDark ? const Color(0xFF2B3442) : const Color(0xFFDCE5F2);
    final titleColor = isDark ? const Color(0xFFE6EDF7) : const Color(0xFF1E293B);
    final hintColor = isDark ? const Color(0xFF97A2B5) : const Color(0xFF64748B);
    final textBody = isDark ? const Color(0xFFD3E0F8) : const Color(0xFF334155);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: border),
        boxShadow: const [
          BoxShadow(
            color: Color(0x14000000),
            blurRadius: 12,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 18,
                backgroundColor: isDark ? const Color(0xFF1D2635) : const Color(0xFFEAF1FF),
                child: Text(
                  entry.initial,
                  style: kmFont(context, GoogleFonts.inter(
                    color: const Color(0xFF2563EB),
                    fontWeight: FontWeight.w800,
                    fontSize: 13,
                  )),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      entry.userName,
                      style: kmFont(context, GoogleFonts.inter(
                        color: titleColor,
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      )),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      timeLabel,
                      style: kmFont(context, GoogleFonts.inter(
                        color: hintColor,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      )),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF2A200B) : const Color(0xFFFFF7E6),
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(color: const Color(0xFFF3C56A)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.star_rounded,
                      size: 14,
                      color: Color(0xFFF2A93B),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${entry.rating}',
                      style: kmFont(context, GoogleFonts.inter(
                        color: isDark ? const Color(0xFFFFD17A) : const Color(0xFF7C5710),
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      )),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (entry.comment.isNotEmpty) ...[
            const SizedBox(height: 10),
            Text(
              entry.comment,
              style: kmFont(context, GoogleFonts.inter(
                color: textBody,
                fontSize: 13,
                fontWeight: FontWeight.w500,
                height: 1.4,
              )),
            ),
          ],
          if (decodedImages.isNotEmpty) ...[
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: decodedImages.map((bytes) {
                return ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: SizedBox(
                    width: 72,
                    height: 72,
                    child: Image.memory(bytes, fit: BoxFit.cover),
                  ),
                );
              }).toList(),
            ),
          ],
        ],
      ),
    );
  }
}

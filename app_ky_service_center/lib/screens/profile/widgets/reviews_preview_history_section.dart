import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:skeletonizer/skeletonizer.dart';

import '../../../theme/app_fonts.dart';
import 'reviews_preview_feedback_entry.dart';
import 'reviews_preview_history_card.dart';

/// "Feedback History" header + animated loading/empty/list switcher used by
/// reviews_preview_screen.dart.
class ReviewsPreviewHistorySection extends StatelessWidget {
  const ReviewsPreviewHistorySection({
    super.key,
    required this.isLoading,
    required this.history,
    required this.formatTimeAgo,
    required this.titleColor,
    required this.hintColor,
    required this.panelBorder,
    required this.isDark,
    required this.emptyLabel,
  });

  final bool isLoading;
  final List<FeedbackEntry> history;
  final String Function(DateTime) formatTimeAgo;
  final Color titleColor;
  final Color hintColor;
  final Color panelBorder;
  final bool isDark;
  final String emptyLabel;

  static const Color _brandBlue = Color(0xFF2563EB);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                'Feedback History',
                style: kmFont(context, GoogleFonts.inter(
                  color: titleColor,
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                )),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1D2635) : const Color(0xFFEAF1FF),
                borderRadius: BorderRadius.circular(999),
              ),
              child: Text(
                '${history.length} users',
                style: kmFont(context, GoogleFonts.inter(
                  color: _brandBlue,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                )),
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          'All user feedback appears below.',
          style: kmFont(context, GoogleFonts.inter(
            color: hintColor,
            fontSize: 13,
            fontWeight: FontWeight.w500,
          )),
        ),
        const SizedBox(height: 14),
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 220),
          child: isLoading
              ? Skeletonizer(
                  key: const ValueKey('loading_history'),
                  enabled: true,
                  child: Column(
                    children: List.generate(
                      2,
                      (index) => Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: ReviewsPreviewHistoryCard(
                          entry: FeedbackEntry(
                            id: 'mock-$index',
                            userName: 'Customer Name',
                            rating: 5,
                            comment:
                                'Mock feedback comment description for rating high-quality services.',
                            imageBase64: const [],
                            createdAt: DateTime.now(),
                          ),
                          timeLabel: 'Just now',
                        ),
                      ),
                    ),
                  ),
                )
              : history.isEmpty
              ? Container(
                  key: const ValueKey('empty_history'),
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF0F172A) : Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: panelBorder),
                  ),
                  child: Text(
                    emptyLabel,
                    style: kmFont(context, GoogleFonts.inter(
                      color: hintColor,
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    )),
                  ),
                )
              : Column(
                  key: const ValueKey('history_list'),
                  children: history.map((entry) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: ReviewsPreviewHistoryCard(
                        entry: entry,
                        timeLabel: formatTimeAgo(entry.createdAt),
                      ),
                    );
                  }).toList(),
                ),
        ),
      ],
    );
  }
}

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../theme/app_fonts.dart';

/// Top bar with back button and "Feedback Center" title used by
/// reviews_preview_screen.dart.
class ReviewsPreviewHeader extends StatelessWidget {
  const ReviewsPreviewHeader({
    super.key,
    required this.onBack,
    required this.panelBg,
    required this.panelBorder,
    required this.titleColor,
    required this.mutedColor,
  });

  final VoidCallback onBack;
  final Color panelBg;
  final Color panelBorder;
  final Color titleColor;
  final Color mutedColor;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 10, 14, 14),
      child: Row(
        children: [
          InkWell(
            onTap: onBack,
            borderRadius: BorderRadius.circular(99),
            child: Container(
              width: 38,
              height: 38,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: panelBg,
                border: Border.all(color: panelBorder),
              ),
              child: Icon(
                Icons.arrow_back_ios_new_rounded,
                size: 16,
                color: titleColor,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Feedback Center',
                  style: kmFont(context, GoogleFonts.inter(
                    color: titleColor,
                    fontSize: 19,
                    fontWeight: FontWeight.w800,
                  )),
                ),
                const SizedBox(height: 2),
                Text(
                  'Rate, comment, and share photos',
                  style: kmFont(context, GoogleFonts.inter(
                    color: mutedColor,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  )),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

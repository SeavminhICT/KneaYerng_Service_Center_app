import 'package:flutter/material.dart';

/// 5-star rating selector used on the "New Feedback" form.
class ReviewsPreviewStarRating extends StatelessWidget {
  const ReviewsPreviewStarRating({
    super.key,
    required this.rating,
    required this.onChanged,
    required this.isDark,
  });

  final int rating;
  final ValueChanged<int> onChanged;
  final bool isDark;

  static const Color _starColor = Color(0xFFF2A93B);

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: List<Widget>.generate(5, (index) {
        final star = index + 1;
        final selected = star <= rating;
        return AnimatedScale(
          duration: const Duration(milliseconds: 140),
          curve: Curves.easeOutBack,
          scale: selected ? 1 : 0.97,
          child: InkWell(
            onTap: () => onChanged(star),
            borderRadius: BorderRadius.circular(14),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 170),
              curve: Curves.easeOut,
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: selected
                    ? (isDark ? const Color(0xFF2A200B) : const Color(0xFFFFF7E6))
                    : (isDark ? const Color(0xFF0F172A) : Colors.white),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: selected
                      ? const Color(0xFFF3C56A)
                      : (isDark ? const Color(0xFF2B3442) : const Color(0xFFD6DFED)),
                ),
              ),
              child: Icon(
                selected ? Icons.star_rounded : Icons.star_border_rounded,
                color: _starColor,
                size: 22,
              ),
            ),
          ),
        );
      }),
    );
  }
}

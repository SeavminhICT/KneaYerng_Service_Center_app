import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../theme/app_fonts.dart';

/// "Comment (optional)" label + multiline text field used on the
/// "New Feedback" form.
class ReviewsPreviewCommentField extends StatelessWidget {
  const ReviewsPreviewCommentField({
    super.key,
    required this.controller,
    required this.titleColor,
    required this.hintColor,
    required this.inputBg,
    required this.inputBorder,
  });

  final TextEditingController controller;
  final Color titleColor;
  final Color hintColor;
  final Color inputBg;
  final Color inputBorder;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Comment',
              style: kmFont(context, GoogleFonts.inter(
                color: titleColor,
                fontSize: 14,
                fontWeight: FontWeight.w700,
              )),
            ),
            const SizedBox(width: 6),
            Text(
              '(optional)',
              style: kmFont(context, GoogleFonts.inter(
                color: hintColor,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              )),
            ),
          ],
        ),
        const SizedBox(height: 10),
        TextField(
          controller: controller,
          maxLines: 4,
          minLines: 4,
          style: TextStyle(color: titleColor),
          decoration: InputDecoration(
            hintText: 'Share your experience with this product.',
            hintStyle: kmFont(context, GoogleFonts.inter(
              color: hintColor.withAlpha((0.85 * 255).round()),
              fontSize: 15,
            )),
            filled: true,
            fillColor: inputBg,
            contentPadding: const EdgeInsets.all(14),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: inputBorder),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: inputBorder),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(
                color: Color(0xFF2563EB),
                width: 1.3,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

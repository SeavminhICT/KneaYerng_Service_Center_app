import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../theme/app_fonts.dart';

/// "Submit Feedback" call-to-action button with loading spinner state.
class ReviewsPreviewSubmitButton extends StatelessWidget {
  const ReviewsPreviewSubmitButton({
    super.key,
    required this.canSubmit,
    required this.isSubmitting,
    required this.isDark,
    required this.onPressed,
  });

  final bool canSubmit;
  final bool isSubmitting;
  final bool isDark;
  final VoidCallback? onPressed;

  static const Color _brandBlue = Color(0xFF2563EB);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: canSubmit ? onPressed : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: (canSubmit || isSubmitting)
              ? _brandBlue
              : (isDark ? const Color(0xFF1E293B) : const Color(0xFFE5E7EB)),
          foregroundColor: (canSubmit || isSubmitting)
              ? Colors.white
              : (isDark ? const Color(0xFF4A5568) : const Color(0xFF9CA3AF)),
          disabledBackgroundColor:
              isDark ? const Color(0xFF1E293B) : const Color(0xFFE5E7EB),
          disabledForegroundColor:
              isDark ? const Color(0xFF4A5568) : const Color(0xFF9CA3AF),
          elevation: 0,
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        child: isSubmitting
            ? const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
            : Text(
                'Submit Feedback',
                style: kmFont(context, GoogleFonts.inter(
                  fontWeight: FontWeight.w700,
                  fontSize: 15,
                )),
              ),
      ),
    );
  }
}

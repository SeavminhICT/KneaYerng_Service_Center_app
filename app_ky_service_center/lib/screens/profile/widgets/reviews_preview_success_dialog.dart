import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../l10n/app_localizations.dart';
import '../../../theme/app_fonts.dart';

/// Auto-dismissing success dialog shown after a feedback submission.
/// Extracted verbatim from reviews_preview_screen.dart
/// (was `_FeedbackSubmitSuccessDialog`).
class ReviewsPreviewSuccessDialog extends StatefulWidget {
  const ReviewsPreviewSuccessDialog({super.key});

  @override
  State<ReviewsPreviewSuccessDialog> createState() =>
      _ReviewsPreviewSuccessDialogState();
}

class _ReviewsPreviewSuccessDialogState
    extends State<ReviewsPreviewSuccessDialog> {
  bool _didClose = false;

  @override
  void initState() {
    super.initState();
    Future<void>.delayed(const Duration(milliseconds: 1400), () {
      _closeDialog();
    });
  }

  void _closeDialog() {
    if (_didClose || !mounted) return;
    _didClose = true;
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = Theme.of(context).cardColor;
    final border = isDark ? const Color(0xFF2B3442) : const Color(0xFFDCE5F2);
    final titleColor = isDark ? const Color(0xFFE6EDF7) : const Color(0xFF1E293B);
    final hintColor = isDark ? const Color(0xFF97A2B5) : const Color(0xFF64748B);

    return Material(
      type: MaterialType.transparency,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Container(
          constraints: const BoxConstraints(maxWidth: 320),
          padding: const EdgeInsets.fromLTRB(22, 22, 22, 18),
          decoration: BoxDecoration(
            color: cardBg,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: border),
            boxShadow: const [
              BoxShadow(
                color: Color(0x33000000),
                blurRadius: 22,
                offset: Offset(0, 12),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TweenAnimationBuilder<double>(
                tween: Tween<double>(begin: 0.72, end: 1),
                duration: const Duration(milliseconds: 420),
                curve: Curves.elasticOut,
                builder: (context, value, child) {
                  return Transform.scale(scale: value, child: child);
                },
                child: Container(
                  width: 74,
                  height: 74,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [Color(0xFF3B82F6), Color(0xFF2563EB)],
                    ),
                  ),
                  child: const Icon(
                    Icons.check_rounded,
                    color: Colors.white,
                    size: 40,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Feedback Submitted',
                textAlign: TextAlign.center,
                style: kmFont(context, GoogleFonts.inter(
                  color: titleColor,
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                )),
              ),
              const SizedBox(height: 8),
              Text(
                l.successfullySaved,
                textAlign: TextAlign.center,
                style: kmFont(context, GoogleFonts.inter(
                  color: hintColor,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  height: 1.45,
                )),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: _closeDialog,
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFF2563EB),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    l.done,
                    style: kmFont(context, GoogleFonts.inter(
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                    )),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

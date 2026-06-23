import 'package:flutter/material.dart';

import '../../../theme/app_fonts.dart';
import 'onboarding_design_tokens.dart';

/// Secondary "ghost" button used on the onboarding screen (e.g. "Skip").
class OnboardingGhostButton extends StatelessWidget {
  const OnboardingGhostButton({super.key, required this.label, required this.onTap});

  final String label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 46,
      child: TextButton(
        onPressed: onTap,
        style: TextButton.styleFrom(
          backgroundColor: kOnboardingPrimaryLight,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        child: Text(
          label,
          style: kFont(context,
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: kOnboardingPrimary,
          ),
        ),
      ),
    );
  }
}

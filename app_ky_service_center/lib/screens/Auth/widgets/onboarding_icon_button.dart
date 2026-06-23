import 'package:flutter/material.dart';

import 'onboarding_design_tokens.dart';

/// Small square icon button used in the top bar (e.g. back arrow).
class OnboardingIconButton extends StatelessWidget {
  const OnboardingIconButton({super.key, required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 40,
        width: 40,
        decoration: BoxDecoration(
          color: kOnboardingCardWhite,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFE5E7EB)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Icon(icon, color: kOnboardingTextHead, size: 18),
      ),
    );
  }
}

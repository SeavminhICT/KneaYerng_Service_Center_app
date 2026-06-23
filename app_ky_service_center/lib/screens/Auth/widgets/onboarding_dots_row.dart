import 'package:flutter/material.dart';

import 'onboarding_design_tokens.dart';

/// Page indicator dots row used on the onboarding screen.
class OnboardingDotsRow extends StatelessWidget {
  const OnboardingDotsRow({super.key, required this.count, required this.current});

  final int count;
  final int current;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(count, (i) {
        final active = i == current;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 280),
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: active ? 24 : 8,
          height: 8,
          decoration: BoxDecoration(
            color: active ? kOnboardingPrimary : kOnboardingDot,
            borderRadius: BorderRadius.circular(99),
          ),
        );
      }),
    );
  }
}

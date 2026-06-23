import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../theme/app_fonts.dart';
import '../../../l10n/app_localizations.dart';
import 'onboarding_design_tokens.dart';
import 'onboarding_illustration_screen1.dart';
import 'onboarding_illustration_screen2.dart';
import 'onboarding_illustration_screen3.dart';

/// One of the three feature pages of the onboarding flow (illustration +
/// title + subtitle).
class OnboardingFeaturePage extends StatelessWidget {
  const OnboardingFeaturePage({super.key, required this.pageIndex, required this.floatAnim});

  final int pageIndex;
  final Animation<double> floatAnim;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);

    final titles = [
      l.welcomeTitle1,
      l.welcomeTitle2,
      l.welcomeTitle3,
    ];

    final subtitles = [
      l.welcomeDesc1,
      l.welcomeDesc2,
      l.welcomeDesc3,
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Illustration
          _buildIllustration(context),
          const SizedBox(height: 36),
          // Text card
          Text(
            titles[pageIndex],
            textAlign: TextAlign.center,
            style: kFont(context,
              fontSize: 26,
              fontWeight: FontWeight.w700,
              height: 1.25,
              color: kOnboardingTextHead,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            subtitles[pageIndex],
            textAlign: TextAlign.center,
            style: kmFont(context, GoogleFonts.inter(
              fontSize: 14,
              fontWeight: FontWeight.w400,
              height: 1.6,
              color: kOnboardingTextSub,
            )),
          ),
        ],
      ),
    );
  }

  Widget _buildIllustration(BuildContext context) {
    final size = MediaQuery.of(context).size.width * 0.78;
    switch (pageIndex) {
      case 0:
        return OnboardingScreen1Illustration(size: size, floatAnim: floatAnim);
      case 1:
        return OnboardingScreen2Illustration(size: size);
      case 2:
        return OnboardingScreen3Illustration(size: size, floatAnim: floatAnim);
      default:
        return const SizedBox.shrink();
    }
  }
}

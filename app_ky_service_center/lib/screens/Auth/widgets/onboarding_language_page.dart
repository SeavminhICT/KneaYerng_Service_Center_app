import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hugeicons/hugeicons.dart';

import '../../../theme/app_fonts.dart';
import '../../../l10n/app_localizations.dart';
import 'onboarding_design_tokens.dart';

/// Language selection page of the onboarding flow.
class OnboardingLanguagePage extends StatelessWidget {
  const OnboardingLanguagePage({super.key, required this.selectedCode, required this.onSelect});

  static const _options = [
    _LangOption(code: 'km', label: 'ខ្មែរ', flag: '🇰🇭', name: 'Khmer'),
    _LangOption(code: 'en', label: 'English', flag: '🇺🇸', name: 'English'),
  ];

  final String? selectedCode;
  final ValueChanged<String> onSelect;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);

    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Icon
          Container(
            width: 58,
            height: 58,
            decoration: BoxDecoration(
              color: kOnboardingPrimaryLight,
              borderRadius: BorderRadius.circular(18),
            ),
            child: const Icon(HugeIcons.strokeRoundedLanguageSquare,
                color: kOnboardingPrimary, size: 30),
          ),
          const SizedBox(height: 20),
          Text(
            l.chooseYourLanguage,
            style: kFont(context,
              fontSize: 30,
              fontWeight: FontWeight.w700,
              height: 1.2,
              color: kOnboardingTextHead,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            l.languageDesc,
            style: kmFont(context, GoogleFonts.inter(
              fontSize: 14,
              color: kOnboardingTextSub,
            )),
          ),
          const SizedBox(height: 28),
          // Language options
          ...List.generate(_options.length, (i) {
            final opt = _options[i];
            final selected = selectedCode == opt.code;
            return GestureDetector(
              onTap: () => onSelect(opt.code),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.symmetric(
                    horizontal: 18, vertical: 16),
                decoration: BoxDecoration(
                  color: selected ? kOnboardingPrimaryLight : kOnboardingCardWhite,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: selected ? kOnboardingPrimary : const Color(0xFFE5E7EB),
                    width: selected ? 1.5 : 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: selected
                          ? kOnboardingPrimary.withValues(alpha: 0.1)
                          : Colors.black.withValues(alpha: 0.04),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Text(opt.flag,
                        style: const TextStyle(fontSize: 28)),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            opt.label,
                            style: kFont(context,
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: kOnboardingTextHead,
                            ),
                          ),
                          Text(
                            opt.name,
                            style: kmFont(context, GoogleFonts.inter(
                              fontSize: 12,
                              color: kOnboardingTextSub,
                            )),
                          ),
                        ],
                      ),
                    ),
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width: 22,
                      height: 22,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: selected ? kOnboardingPrimary : Colors.transparent,
                        border: Border.all(
                          color: selected ? kOnboardingPrimary : const Color(0xFFD1D5DB),
                          width: 2,
                        ),
                      ),
                      child: selected
                          ? const Icon(HugeIcons.strokeRoundedTick01,
                              color: Colors.white, size: 13)
                          : null,
                    ),
                  ],
                ),
              ),
            );
          }),
          const Spacer(),
        ],
      ),
    );
  }
}

class _LangOption {
  const _LangOption({
    required this.code,
    required this.label,
    required this.flag,
    required this.name,
  });
  final String code;
  final String label;
  final String flag;
  final String name;
}

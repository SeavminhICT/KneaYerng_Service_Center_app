import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hugeicons/hugeicons.dart';

import '../../../l10n/app_localizations.dart';
import '../../../theme/app_fonts.dart';
import 'otp_design_tokens.dart';
import 'otp_primary_button.dart';

/// Bottom sheet shown after a successful password reset.
class OtpSuccessSheet extends StatelessWidget {
  const OtpSuccessSheet({super.key});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.fromLTRB(24, 28, 24, 28),
      decoration: BoxDecoration(
        color: otpSurface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: otpBorder),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Color(0xFFEFFCF6),
            ),
            child: const Icon(
              HugeIcons.strokeRoundedTick01,
              color: Color(0xFF10B981),
              size: 30,
            ),
          ),
          const SizedBox(height: 18),
          Text(
            'Password Reset!',
            style: kFont(
              context,
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: otpTextHead,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Password reset successfully. Please login.',
            textAlign: TextAlign.center,
            style: kmFont(context, GoogleFonts.inter(
              fontSize: 14,
              color: otpTextSub,
              height: 1.6,
            )),
          ),
          const SizedBox(height: 24),
          OtpPrimaryBtn(
            label: l.back.toUpperCase(),
            loading: false,
            onTap: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hugeicons/hugeicons.dart';

import '../../../theme/app_fonts.dart';
import 'otp_design_tokens.dart';

/// Single row in the password-requirements checklist on the "new password"
/// step.
class OtpReqRow extends StatelessWidget {
  const OtpReqRow({super.key, required this.label, required this.met});
  final String label;
  final bool met;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: 16,
            height: 16,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: met ? const Color(0xFF10B981) : otpBorder,
            ),
            child: met
                ? const Icon(HugeIcons.strokeRoundedTick01, size: 10, color: Colors.white)
                : null,
          ),
          const SizedBox(width: 8),
          Text(
            label,
            style: kmFont(context, GoogleFonts.inter(
              fontSize: 12,
              color: met ? const Color(0xFF10B981) : otpTextSub,
              fontWeight: met ? FontWeight.w600 : FontWeight.w400,
            )),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../theme/app_fonts.dart';
import 'otp_design_tokens.dart';

/// Slim 3-segment progress bar shown at the top of every step of the flow.
class OtpProgressHeader extends StatelessWidget {
  const OtpProgressHeader({super.key, required this.current});
  final int current; // 0 = method, 1 = otp, 2 = new pw

  static const _labels = ['Method', 'Verification', 'New password'];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: List.generate(3, (i) {
            final active = i <= current;
            return Expanded(
              child: Container(
                height: 4,
                margin: EdgeInsets.only(right: i < 2 ? 6 : 0),
                decoration: BoxDecoration(
                  color: active ? otpPrimary : otpBorder,
                  borderRadius: BorderRadius.circular(99),
                ),
              ),
            );
          }),
        ),
        const SizedBox(height: 10),
        Text(
          'Step ${current + 1} of 3 · ${_labels[current]}',
          style: kmFont(context, GoogleFonts.inter(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: otpTextSub,
          )),
        ),
      ],
    );
  }
}

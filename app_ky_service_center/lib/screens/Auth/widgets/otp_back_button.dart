import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';

import 'otp_design_tokens.dart';

/// Circular back button used at the top-left of every step of the flow.
class OtpBackBtn extends StatelessWidget {
  const OtpBackBtn({super.key});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => Navigator.maybePop(context),
      borderRadius: BorderRadius.circular(20),
      child: Container(
        width: 40,
        height: 40,
        alignment: Alignment.center,
        decoration: const BoxDecoration(
          color: otpBg,
          shape: BoxShape.circle,
        ),
        child: const Icon(
          HugeIcons.strokeRoundedArrowLeft01,
          color: otpTextHead,
          size: 20,
        ),
      ),
    );
  }
}

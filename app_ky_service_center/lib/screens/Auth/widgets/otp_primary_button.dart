import 'package:flutter/material.dart';

import '../../../theme/app_fonts.dart';
import 'otp_design_tokens.dart';

/// Full-width primary action button with a loading / disabled state, used
/// across all steps of the forgot-password / OTP-verify flow.
class OtpPrimaryBtn extends StatelessWidget {
  const OtpPrimaryBtn({
    super.key,
    required this.label,
    required this.loading,
    required this.onTap,
    this.enabled = true,
  });
  final String label;
  final bool loading;
  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 54,
      child: ElevatedButton(
        onPressed: (loading || !enabled) ? null : onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: otpPrimary,
          disabledBackgroundColor: otpPrimary.withValues(alpha: 0.35),
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 180),
          child: loading
              ? const SizedBox(
                  key: ValueKey('spin'),
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    color: Colors.white,
                  ),
                )
              : Text(
                  label,
                  key: const ValueKey('label'),
                  style: kFont(
                    context,
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                    letterSpacing: 0.4,
                  ),
                ),
        ),
      ),
    );
  }
}

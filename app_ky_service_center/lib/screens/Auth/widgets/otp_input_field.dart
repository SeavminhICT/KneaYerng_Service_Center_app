import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../theme/app_palette.dart';
import '../../../theme/app_fonts.dart';
import 'otp_design_tokens.dart';

/// Generic phone / email text field used on the "choose method" step.
class OtpInputField extends StatelessWidget {
  const OtpInputField({
    super.key,
    required this.controller,
    required this.focusNode,
    required this.hint,
    required this.icon,
    required this.keyboard,
    required this.validator,
    required this.onSubmit,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final String hint;
  final IconData icon;
  final TextInputType keyboard;
  final String? Function(String?)? validator;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      focusNode: focusNode,
      keyboardType: keyboard,
      textInputAction: TextInputAction.done,
      onFieldSubmitted: (_) => onSubmit(),
      cursorColor: otpPrimary,
      validator: validator,
      style: kmFont(context, GoogleFonts.inter(
        fontSize: 15,
        fontWeight: FontWeight.w500,
        color: otpTextHead,
      )),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: kmFont(context, GoogleFonts.inter(fontSize: 15, color: otpIconMuted)),
        prefixIcon: Icon(icon, color: otpIconMuted, size: 20),
        prefixIconConstraints: const BoxConstraints(minWidth: 48),
        filled: true,
        fillColor: otpBg,
        isDense: true,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
        errorStyle: kmFont(context, GoogleFonts.inter(fontSize: 12, color: AppPalette.error)),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: otpPrimary, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppPalette.error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppPalette.error, width: 1.5),
        ),
      ),
    );
  }
}

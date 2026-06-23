import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hugeicons/hugeicons.dart';

import '../../../theme/app_palette.dart';
import '../../../theme/app_fonts.dart';
import 'otp_design_tokens.dart';

/// Obscurable password text field with a visibility toggle, used on the
/// "new password" step.
class OtpPasswordField extends StatelessWidget {
  const OtpPasswordField({
    super.key,
    required this.controller,
    required this.focusNode,
    this.nextFocus,
    required this.hint,
    required this.obscure,
    required this.onToggle,
    required this.validator,
    this.textInputAction = TextInputAction.next,
    this.onSubmit,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final FocusNode? nextFocus;
  final String hint;
  final bool obscure;
  final VoidCallback onToggle;
  final String? Function(String?)? validator;
  final TextInputAction textInputAction;
  final VoidCallback? onSubmit;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      focusNode: focusNode,
      obscureText: obscure,
      textInputAction: textInputAction,
      enableSuggestions: false,
      autocorrect: false,
      cursorColor: otpPrimary,
      onFieldSubmitted: (_) {
        if (nextFocus != null) {
          FocusScope.of(context).requestFocus(nextFocus);
        } else {
          onSubmit?.call();
        }
      },
      validator: validator,
      style: kmFont(context, GoogleFonts.inter(
        fontSize: 15,
        fontWeight: FontWeight.w500,
        color: otpTextHead,
      )),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: kmFont(context, GoogleFonts.inter(fontSize: 15, color: otpIconMuted)),
        prefixIcon: const Icon(
          HugeIcons.strokeRoundedSquareLock01,
          color: otpIconMuted,
          size: 20,
        ),
        prefixIconConstraints: const BoxConstraints(minWidth: 48),
        suffixIcon: IconButton(
          onPressed: onToggle,
          icon: Icon(
            obscure ? HugeIcons.strokeRoundedViewOffSlash : HugeIcons.strokeRoundedView,
            size: 20,
            color: otpIconMuted,
          ),
        ),
        suffixIconConstraints: const BoxConstraints(minWidth: 48),
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

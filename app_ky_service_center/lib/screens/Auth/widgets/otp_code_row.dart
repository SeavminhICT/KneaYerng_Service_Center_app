import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../theme/app_fonts.dart';
import '../../../theme/app_palette.dart';
import 'otp_design_tokens.dart';

/// Row of single-digit OTP entry boxes. The parent owns the controllers,
/// focus nodes and error state so the digit-shifting / paste / verify logic
/// stays in the screen's State.
class OtpCodeRow extends StatelessWidget {
  const OtpCodeRow({
    super.key,
    required this.length,
    required this.controllers,
    required this.focusNodes,
    required this.hasError,
    required this.onChanged,
  });

  final int length;
  final List<TextEditingController> controllers;
  final List<FocusNode> focusNodes;
  final bool hasError;
  final void Function(int index, String value) onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: List.generate(length, (i) {
        final hasVal = controllers[i].text.isNotEmpty;
        final focused = focusNodes[i].hasFocus;
        final isError = hasError;

        Color accent;
        Color bgColor;
        if (isError) {
          accent = AppPalette.error;
          bgColor = AppPalette.error.withValues(alpha: 0.05);
        } else if (hasVal || focused) {
          accent = otpPrimary;
          bgColor = otpPrimary.withValues(alpha: 0.05);
        } else {
          accent = otpBorder;
          bgColor = otpBg;
        }

        return AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: 46,
          height: 56,
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(12),
            border: Border(
              bottom: BorderSide(
                color: accent,
                width: hasVal || focused || isError ? 2.5 : 1.5,
              ),
            ),
          ),
          child: TextField(
            controller: controllers[i],
            focusNode: focusNodes[i],
            autofocus: i == 0,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            maxLength: 6,
            textAlign: TextAlign.center,
            cursorColor: otpPrimary,
            style: kFont(
              context,
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: isError ? AppPalette.error : otpTextHead,
            ),
            decoration: const InputDecoration(
              counterText: '',
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
              contentPadding: EdgeInsets.zero,
              hintText: '-',
              hintStyle: TextStyle(
                fontSize: 28,
                color: Color(0xFFD1D5DB),
                fontWeight: FontWeight.w400,
              ),
            ),
            onChanged: (v) => onChanged(i, v),
          ),
        );
      }),
    );
  }
}

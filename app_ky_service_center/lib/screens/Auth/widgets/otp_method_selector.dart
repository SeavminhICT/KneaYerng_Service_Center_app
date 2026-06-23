import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';

import '../../../theme/app_fonts.dart';
import 'otp_design_tokens.dart';

/// Phone / Email tab selector used on the "choose method" step.
class OtpMethodSelector extends StatelessWidget {
  const OtpMethodSelector({super.key, required this.tab});
  final TabController tab;

  @override
  Widget build(BuildContext context) {
    final isPhone = tab.index == 0;
    return Row(
      children: [
        _OtpMethodTab(
          icon: HugeIcons.strokeRoundedSmartPhone01,
          label: 'Phone',
          active: isPhone,
          onTap: () => tab.animateTo(0),
        ),
        const SizedBox(width: 10),
        _OtpMethodTab(
          icon: HugeIcons.strokeRoundedMail01,
          label: 'Email',
          active: !isPhone,
          onTap: () => tab.animateTo(1),
        ),
      ],
    );
  }
}

class _OtpMethodTab extends StatelessWidget {
  const _OtpMethodTab({
    required this.icon,
    required this.label,
    required this.active,
    required this.onTap,
  });
  final IconData icon;
  final String label;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 13),
          decoration: BoxDecoration(
            color: active ? otpPrimary.withValues(alpha: 0.08) : otpBg,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: active ? otpPrimary : otpBorder,
              width: active ? 1.5 : 1,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 18, color: active ? otpPrimary : otpIconMuted),
              const SizedBox(width: 6),
              Text(
                label,
                style: kFont(
                  context,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: active ? otpPrimary : otpTextSub,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

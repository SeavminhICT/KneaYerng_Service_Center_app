import 'package:flutter/material.dart';
import '../../../theme/app_fonts.dart';
import 'package:hugeicons/hugeicons.dart';

import 'checkout_colors.dart';
import 'checkout_surface_card.dart';

/// Contact phone number input shown on the payment step. Read-only when the
/// number was pre-filled from the user's profile, with an option to switch
/// to manual entry.
class CheckoutPhoneCard extends StatelessWidget {
  const CheckoutPhoneCard({
    super.key,
    required this.controller,
    required this.phoneFromProfile,
    required this.onUseDifferentNumber,
  });

  final TextEditingController controller;
  final bool phoneFromProfile;
  final VoidCallback onUseDifferentNumber;

  @override
  Widget build(BuildContext context) {
    return CheckoutSurfaceCard(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(HugeIcons.strokeRoundedCall02, size: 16, color: kCheckoutPrimary),
              const SizedBox(width: 8),
              Text(
                'Contact Phone',
                style: kFont(context,
                    fontSize: 14, fontWeight: FontWeight.w700, color: checkoutInk(context)),
              ),
            ],
          ),
          const SizedBox(height: 2),
          Text(
            phoneFromProfile
                ? 'Using your registered phone number.'
                : 'Enter a phone number so we can reach you about this order.',
            style: TextStyle(
                fontSize: 11, color: checkoutMuted(context), height: 1.3),
          ),
          const SizedBox(height: 8),
          TextFormField(
            controller: controller,
            readOnly: phoneFromProfile,
            keyboardType: TextInputType.phone,
            style: kFont(context,
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: phoneFromProfile ? checkoutMuted(context) : checkoutInk(context)),
            decoration: InputDecoration(
              hintText: '+855 XX XXX XXX',
              hintStyle:
                  TextStyle(color: checkoutMuted(context), fontSize: 14),
              prefixIcon: Icon(HugeIcons.strokeRoundedCall02,
                  size: 18, color: checkoutMuted(context)),
              suffixIcon: phoneFromProfile
                  ? Tooltip(
                      message: 'From your profile',
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Icon(HugeIcons.strokeRoundedSecurityLock,
                            size: 16, color: checkoutMuted(context)),
                      ),
                    )
                  : null,
              filled: true,
              fillColor: phoneFromProfile
                  ? checkoutSurfaceAlt(context)
                  : checkoutSurface(context),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide:
                    BorderSide(color: checkoutBorder(context)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide:
                    BorderSide(color: checkoutBorder(context)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide:
                    const BorderSide(color: kCheckoutPrimary, width: 1.6),
              ),
            ),
          ),
          if (phoneFromProfile)
            Padding(
              padding: const EdgeInsets.only(top: 6),
              child: GestureDetector(
                onTap: onUseDifferentNumber,
                child: Text(
                  'Use a different number',
                  style: TextStyle(
                      fontSize: 11,
                      color: kCheckoutPrimary,
                      fontWeight: FontWeight.w600),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

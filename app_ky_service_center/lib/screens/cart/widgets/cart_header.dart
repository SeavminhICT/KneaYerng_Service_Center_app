import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../l10n/app_localizations.dart';
import '../../../theme/app_fonts.dart';
import '../../../widgets/circle_back_button.dart';
import 'cart_colors.dart';

/// Header row for the cart screen: back button, title, item count badge.
class CartHeader extends StatelessWidget {
  const CartHeader({super.key, required this.totalItems, required this.onBack});
  final int totalItems;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Row(
      children: [
        CircleBackButton(onPressed: onBack, color: cartInk),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l.cart,
                style: kmFont(context, GoogleFonts.poppins(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: cartInk,
                  height: 1.1,
                )),
              ),
              Text(
                totalItems == 0
                    ? 'Review items before checkout'
                    : totalItems == 1
                        ? '1 item ready for checkout'
                        : '$totalItems items ready for checkout',
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: cartMuted),
              ),
            ],
          ),
        ),
        if (totalItems > 0)
          Container(
            width: 36,
            height: 36,
            decoration: const BoxDecoration(
              color: cartPrimarySoft,
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Text(
              '$totalItems',
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: cartPrimaryDeep),
            ),
          ),
      ],
    );
  }
}

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hugeicons/hugeicons.dart';

import '../../../l10n/app_localizations.dart';
import '../../../theme/app_fonts.dart';
import 'cart_colors.dart';

/// Empty-state view shown when the cart has no items.
class CartEmptyState extends StatelessWidget {
  const CartEmptyState({super.key, required this.onContinueShopping});
  final VoidCallback onContinueShopping;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 96,
              height: 96,
              decoration: BoxDecoration(
                color: cartPrimarySoft,
                borderRadius: BorderRadius.circular(28),
              ),
              child: const Icon(HugeIcons.strokeRoundedShoppingBag01, size: 44, color: cartPrimaryDeep),
            ),
            const SizedBox(height: 24),
            Text(
              l.emptyCart,
              textAlign: TextAlign.center,
              style: kmFont(context, GoogleFonts.poppins(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: cartInk,
                height: 1.2,
              )),
            ),
            const SizedBox(height: 10),
            const Text(
              'Browse products and add the ones you want — they will appear here.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13.5, height: 1.6, color: cartMuted),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF4B6CF7), Color(0xFF6C8FFF)],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: ElevatedButton(
                  onPressed: onContinueShopping,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  child: const Text(
                    'Continue shopping',
                    style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../l10n/app_localizations.dart';
import '../../../theme/app_fonts.dart';
import 'product_detail_tone.dart';

/// Sticky bottom purchase bar: running total summary plus
/// Add to Cart / Buy Now buttons.
class ProductBottomBar extends StatelessWidget {
  const ProductBottomBar({
    super.key,
    required this.tone,
    required this.quantity,
    required this.total,
    required this.canPurchase,
    required this.onAddToCart,
    required this.onBuyNow,
  });

  final ProductDetailTone tone;
  final int               quantity;
  final double            total;
  final bool              canPurchase;
  final VoidCallback      onAddToCart;
  final VoidCallback      onBuyNow;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 12),
      decoration: BoxDecoration(
        color: tone.white,
        border: Border(top: BorderSide(color: tone.border)),
        boxShadow: [
          BoxShadow(
            color:      tone.isDark ? Colors.transparent : const Color(0x14000000),
            blurRadius: 16,
            offset:     const Offset(0, -4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // ── Summary row ────────────────────────────────────────────────
          Row(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '$quantity item${quantity == 1 ? '' : 's'} selected',
                    style: TextStyle(
                      fontSize:   11.5,
                      color:      tone.textSub,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 1),
                  Text(
                    '\$${total.toStringAsFixed(2)}',
                    style: kmFont(context, GoogleFonts.inter(
                      fontSize:   22,
                      fontWeight: FontWeight.w800,
                      color:      tone.textPrimary,
                      height:     1,
                    )),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 10),

          // ── Buttons row ────────────────────────────────────────────────
          Row(
            children: [
              // Add to Cart
              Expanded(
                flex: 3,
                child: SizedBox(
                  height: 48,
                  child: ElevatedButton(
                    onPressed: canPurchase ? onAddToCart : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: pdAccent,
                      foregroundColor: Colors.white,
                      elevation:       0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      AppLocalizations.of(context).addToCart,
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize:   14,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),

              // Buy Now
              Expanded(
                flex: 2,
                child: SizedBox(
                  height: 48,
                  child: OutlinedButton(
                    onPressed: canPurchase ? onBuyNow : null,
                    style: OutlinedButton.styleFrom(
                      side:            const BorderSide(color: pdAccent),
                      foregroundColor: pdAccent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      AppLocalizations.of(context).buyNow,
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize:   14,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

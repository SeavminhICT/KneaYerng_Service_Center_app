import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hugeicons/hugeicons.dart';

import '../../../l10n/app_localizations.dart';
import '../../../theme/app_fonts.dart';
import 'product_detail_common.dart';
import 'product_detail_tone.dart';

/// Central price + stock + quantity stepper + running total card.
class ProductPriceQuantityCard extends StatelessWidget {
  const ProductPriceQuantityCard({
    super.key,
    required this.tone,
    required this.unitPrice,
    required this.oldPrice,
    required this.quantity,
    required this.stock,
    required this.isOutOfStock,
    required this.total,
    required this.onMinus,
    required this.onPlus,
    this.showQuantity = true,
  });

  final ProductDetailTone tone;
  final double            unitPrice;
  final double?           oldPrice;
  final int               quantity;
  final int?              stock;
  final bool              isOutOfStock;
  final double            total;
  final VoidCallback      onMinus;
  final VoidCallback      onPlus;
  final bool              showQuantity;

  @override
  Widget build(BuildContext context) {
    return Container(
      width:   double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color:        tone.white,
        borderRadius: BorderRadius.circular(16),
        border:       Border.all(color: tone.border),
        boxShadow: [
          BoxShadow(
            color:      tone.shadow,
            blurRadius: 8,
            offset:     const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Unit price row ─────────────────────────────────────────────
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'UNIT PRICE',
                      style: TextStyle(
                        fontSize:      10.5,
                        fontWeight:    FontWeight.w700,
                        color:         tone.textHint,
                        letterSpacing: 0.8,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          '\$${unitPrice.toStringAsFixed(2)}',
                          style: kmFont(context, GoogleFonts.inter(
                            fontSize:   30,
                            fontWeight: FontWeight.w800,
                            color:      pdAccent,
                            height:     1,
                          )),
                        ),
                        const SizedBox(width: 6),
                        if (oldPrice != null) ...[
                          Padding(
                            padding: const EdgeInsets.only(bottom: 3),
                            child: Text(
                              '\$${oldPrice!.toStringAsFixed(2)}',
                              style: TextStyle(
                                fontSize:   13,
                                color:      tone.textHint,
                                decoration: TextDecoration.lineThrough,
                              ),
                            ),
                          ),
                        ],
                        Padding(
                          padding: const EdgeInsets.only(bottom: 3, left: 4),
                          child: Text(
                            '/ unit',
                            style: TextStyle(
                              fontSize:   12,
                              color:      tone.textSub,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              // Stock badge
              ProductDetailStockBadge(
                tone:         tone,
                label:        isOutOfStock ? AppLocalizations.of(context).outOfStock : AppLocalizations.of(context).inStock,
                isOutOfStock: isOutOfStock,
              ),
            ],
          ),

          if (showQuantity) ...[
            const SizedBox(height: 16),
            Container(height: 1, color: tone.divider),
            const SizedBox(height: 14),

            // ── Quantity + Total row ─────────────────────────────────────
            Row(
              children: [
                // Left: Quantity control
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'QUANTITY',
                      style: TextStyle(
                        fontSize:      10.5,
                        fontWeight:    FontWeight.w700,
                        color:         tone.textHint,
                        letterSpacing: 0.8,
                      ),
                    ),
                    const SizedBox(height: 8),
                    ProductQuantityControl(
                      tone:      tone,
                      quantity:  quantity,
                      onMinus:   onMinus,
                      onPlus:    onPlus,
                      disabled:  isOutOfStock,
                    ),
                  ],
                ),

                const SizedBox(width: 16),
                Container(width: 1, height: 52, color: tone.divider),
                const SizedBox(width: 16),

                // Right: Stock info + Total
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (stock != null && !isOutOfStock)
                        Text(
                          '$stock in stock',
                          style: TextStyle(
                            fontSize:   11.5,
                            color:      tone.textSub,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      if (isOutOfStock)
                        const Text(
                          'Currently unavailable',
                          style: TextStyle(
                            fontSize:   11.5,
                            color:      pdRed,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      const SizedBox(height: 4),
                      Text(
                        'TOTAL',
                        style: TextStyle(
                          fontSize:      10.5,
                          fontWeight:    FontWeight.w700,
                          color:         tone.textHint,
                          letterSpacing: 0.8,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '\$${total.toStringAsFixed(2)}',
                        style: kmFont(context, GoogleFonts.inter(
                          fontSize:   20,
                          fontWeight: FontWeight.w800,
                          color:      tone.textPrimary,
                          height:     1,
                        )),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  Quantity Control
// ─────────────────────────────────────────────────────────────────────────────
class ProductQuantityControl extends StatelessWidget {
  const ProductQuantityControl({
    super.key,
    required this.tone,
    required this.quantity,
    required this.onMinus,
    required this.onPlus,
    this.disabled = false,
  });

  final ProductDetailTone tone;
  final int               quantity;
  final VoidCallback      onMinus;
  final VoidCallback      onPlus;
  final bool              disabled;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color:        tone.surfaceAlt,
        borderRadius: BorderRadius.circular(12),
        border:       Border.all(color: tone.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _QBtn(
            tone:     tone,
            icon:     HugeIcons.strokeRoundedMinusSign,
            onTap:    onMinus,
            disabled: quantity <= 1 || disabled,
          ),
          Container(
            width:  44,
            alignment: Alignment.center,
            child: Text(
              '$quantity',
              style: TextStyle(
                fontSize:   16,
                fontWeight: FontWeight.w700,
                color:      tone.textPrimary,
              ),
            ),
          ),
          _QBtn(
            tone:     tone,
            icon:     HugeIcons.strokeRoundedAdd01,
            onTap:    onPlus,
            disabled: disabled,
          ),
        ],
      ),
    );
  }
}

class _QBtn extends StatelessWidget {
  const _QBtn({
    required this.tone,
    required this.icon,
    required this.onTap,
    this.disabled = false,
  });

  final ProductDetailTone tone;
  final IconData          icon;
  final VoidCallback      onTap;
  final bool              disabled;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: disabled ? null : onTap,
      child: Container(
        width:  38,
        height: 38,
        alignment: Alignment.center,
        child: Icon(
          icon,
          size:  18,
          color: disabled ? tone.textHint : tone.textPrimary,
        ),
      ),
    );
  }
}

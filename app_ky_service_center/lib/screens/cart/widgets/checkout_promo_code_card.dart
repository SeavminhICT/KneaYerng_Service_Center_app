import 'package:flutter/material.dart';
import '../../../theme/app_fonts.dart';
import 'package:hugeicons/hugeicons.dart';

import 'checkout_colors.dart';
import 'checkout_surface_card.dart';

/// Promo / voucher code entry card shown on the payment step. Shows either
/// the input + apply button, or an "applied" confirmation state with a
/// remove action.
class CheckoutPromoCodeCard extends StatelessWidget {
  const CheckoutPromoCodeCard({
    super.key,
    required this.controller,
    required this.promoApplied,
    required this.applyingPromo,
    required this.appliedPromoCode,
    required this.promoError,
    required this.discount,
    required this.onApply,
    required this.onRemove,
  });

  final TextEditingController controller;
  final bool promoApplied;
  final bool applyingPromo;
  final String? appliedPromoCode;
  final String? promoError;
  final double discount;
  final VoidCallback onApply;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    return CheckoutSurfaceCard(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(HugeIcons.strokeRoundedTag01,
                  size: 16, color: kCheckoutPrimary),
              const SizedBox(width: 8),
              Text(
                'Promo Code',
                style: kFont(context,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: checkoutInk(context)),
              ),
            ],
          ),
          const SizedBox(height: 8),
          if (promoApplied) ...[
            // Applied state
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: const Color(0xFFECFDF5),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFF6EE7B7)),
              ),
              child: Row(
                children: [
                  const Icon(HugeIcons.strokeRoundedCheckmarkCircle02,
                      size: 18, color: kCheckoutSuccess),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          appliedPromoCode ?? '',
                          style: kFont(context,
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: kCheckoutSuccess),
                        ),
                        Text(
                          '- \$${discount.toStringAsFixed(2)} discount applied',
                          style: const TextStyle(
                              fontSize: 12, color: kCheckoutSuccess),
                        ),
                      ],
                    ),
                  ),
                  GestureDetector(
                    onTap: onRemove,
                    child: Icon(HugeIcons.strokeRoundedCancel01,
                        size: 18, color: checkoutMuted(context)),
                  ),
                ],
              ),
            ),
          ] else ...[
            // Input state
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextFormField(
                        controller: controller,
                        textCapitalization: TextCapitalization.characters,
                        style: kFont(context,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: checkoutInk(context)),
                        decoration: InputDecoration(
                          hintText: 'Enter promo code',
                          hintStyle: TextStyle(
                              color: checkoutMuted(context), fontSize: 14),
                          prefixIcon: Icon(HugeIcons.strokeRoundedTicket01,
                              size: 18, color: checkoutMuted(context)),
                          filled: true,
                          fillColor: checkoutSurface(context),
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 10),
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
                            borderSide: const BorderSide(
                                color: kCheckoutPrimary, width: 1.6),
                          ),
                          errorBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(
                                color: Color(0xFFEF4444)),
                          ),
                        ),
                        onFieldSubmitted: (_) => onApply(),
                      ),
                      if (promoError != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 6, left: 4),
                          child: Text(
                            promoError!,
                            style: const TextStyle(
                                fontSize: 12, color: Color(0xFFEF4444)),
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                SizedBox(
                  height: 30,
                  child: ElevatedButton(
                    onPressed: applyingPromo ? null : onApply,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: kCheckoutPrimary,
                      foregroundColor: Colors.white,
                      disabledBackgroundColor:
                          kCheckoutPrimary.withAlpha(120),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                    ),
                    child: applyingPromo
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : Text(
                            'Apply',
                            style: kFont(context,
                                fontSize: 14, fontWeight: FontWeight.w700),
                          ),
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

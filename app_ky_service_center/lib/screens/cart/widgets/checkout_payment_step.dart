import 'package:flutter/material.dart';

import '../../../models/cart_item.dart';
import '../../../services/api_service.dart';
import 'checkout_order_items_card.dart';
import 'checkout_payment_method_card.dart';
import 'checkout_phone_card.dart';
import 'checkout_promo_code_card.dart';
import 'checkout_summary_card.dart';

/// Step 2 of checkout: contact phone, promo code, payment method, order
/// items, and a live pricing summary.
class CheckoutPaymentStep extends StatelessWidget {
  const CheckoutPaymentStep({
    super.key,
    required this.phoneController,
    required this.phoneFromProfile,
    required this.onUseDifferentNumber,
    required this.promoController,
    required this.promoApplied,
    required this.applyingPromo,
    required this.appliedPromoCode,
    required this.promoError,
    required this.onApplyPromo,
    required this.onRemovePromo,
    required this.paymentMethods,
    required this.selectedPaymentIndex,
    required this.isPickup,
    required this.primary,
    required this.paymentMethodIcon,
    required this.onSelectPayment,
    required this.items,
    required this.subtotal,
    required this.shipping,
    required this.tax,
    required this.discount,
    required this.total,
  });

  final TextEditingController phoneController;
  final bool phoneFromProfile;
  final VoidCallback onUseDifferentNumber;

  final TextEditingController promoController;
  final bool promoApplied;
  final bool applyingPromo;
  final String? appliedPromoCode;
  final String? promoError;
  final VoidCallback onApplyPromo;
  final VoidCallback onRemovePromo;

  final List<CheckoutPaymentMethod> paymentMethods;
  final int selectedPaymentIndex;
  final bool isPickup;
  final Color primary;
  final IconData Function(String code) paymentMethodIcon;
  final ValueChanged<int> onSelectPayment;

  final List<CartItem> items;
  final double subtotal;
  final double shipping;
  final double tax;
  final double discount;
  final double total;

  @override
  Widget build(BuildContext context) {
    return ListView(
      key: const ValueKey(2),
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 28),
      children: [
        CheckoutPhoneCard(
          controller: phoneController,
          phoneFromProfile: phoneFromProfile,
          onUseDifferentNumber: onUseDifferentNumber,
        ),
        const SizedBox(height: 14),
        CheckoutPromoCodeCard(
          controller: promoController,
          promoApplied: promoApplied,
          applyingPromo: applyingPromo,
          appliedPromoCode: appliedPromoCode,
          promoError: promoError,
          discount: discount,
          onApply: onApplyPromo,
          onRemove: onRemovePromo,
        ),
        const SizedBox(height: 14),
        CheckoutPaymentMethodCard(
          methods: paymentMethods,
          selectedIndex: selectedPaymentIndex,
          isPickup: isPickup,
          primary: primary,
          iconForMethod: paymentMethodIcon,
          onSelect: onSelectPayment,
        ),
        const SizedBox(height: 14),
        CheckoutOrderItemsCard(items: items),
        const SizedBox(height: 14),
        CheckoutSummaryCard(
          subtotal: subtotal,
          shipping: shipping,
          tax: tax,
          discount: discount,
          total: total,
          primary: primary,
        ),
      ],
    );
  }
}

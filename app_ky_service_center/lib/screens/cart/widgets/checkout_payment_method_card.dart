import 'package:flutter/material.dart';
import '../../../theme/app_fonts.dart';

import '../../../services/api_service.dart';
import 'checkout_colors.dart';
import 'checkout_select_card.dart';
import 'checkout_surface_card.dart';

/// Payment method selector (Bakong QR / Cash on Delivery) shown on the
/// payment step.
class CheckoutPaymentMethodCard extends StatelessWidget {
  const CheckoutPaymentMethodCard({
    super.key,
    required this.methods,
    required this.selectedIndex,
    required this.isPickup,
    required this.primary,
    required this.iconForMethod,
    required this.onSelect,
  });

  final List<CheckoutPaymentMethod> methods;
  final int selectedIndex;
  final bool isPickup;
  final Color primary;
  final IconData Function(String code) iconForMethod;
  final ValueChanged<int> onSelect;

  @override
  Widget build(BuildContext context) {
    return CheckoutSurfaceCard(
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Payment method',
            style: kFont(context,
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: checkoutInk(context),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            isPickup
                ? 'Bakong QR is the only available payment method for pickup.'
                : 'Delivery orders support KHQR/Bakong QR or Cash on Delivery.',
            style: TextStyle(color: checkoutMuted(context), height: 1.45),
          ),
          const SizedBox(height: 16),
          ...List.generate(methods.length, (index) {
            final method = methods[index];
            final selected = selectedIndex == index;
            return Padding(
              padding: EdgeInsets.only(
                bottom: index == methods.length - 1 ? 0 : 12,
              ),
              child: CheckoutSelectCard(
                selected: selected,
                title: method.label,
                subtitle: method.description,
                trailing: '',
                onTap: () => onSelect(index),
                primary: primary,
                icon: iconForMethod(method.code),
                assetPath: method.code == 'aba_qr'
                    ? 'assets/images/BakongLogo.png'
                    : null,
                badge: method.code == 'aba_qr' ? 'QR Payment' : 'Pay Later',
              ),
            );
          }),
        ],
      ),
    );
  }
}

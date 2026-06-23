import 'package:flutter/material.dart';
import '../../../theme/app_fonts.dart';

import 'checkout_colors.dart';
import 'checkout_delivery_method.dart';
import 'checkout_select_card.dart';

/// Step 0 of checkout: choose pickup-from-store vs. home delivery.
class CheckoutMethodStep extends StatelessWidget {
  const CheckoutMethodStep({
    super.key,
    required this.deliveryMethods,
    required this.selectedIndex,
    required this.deliveryFee,
    required this.primary,
    required this.onSelect,
  });

  final List<CheckoutDeliveryMethod> deliveryMethods;
  final int selectedIndex;
  final double deliveryFee;
  final Color primary;
  final ValueChanged<int> onSelect;

  @override
  Widget build(BuildContext context) {
    return ListView(
      key: const ValueKey(0),
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 28),
      children: [
        Text(
          'Delivery Method',
          style: kFont(context,
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: checkoutInk(context),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'Select how you want to receive this order.',
          style: TextStyle(color: checkoutMuted(context), height: 1.45),
        ),
        const SizedBox(height: 16),
        ...List.generate(deliveryMethods.length, (index) {
          final method = deliveryMethods[index];
          final selected = selectedIndex == index;
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: CheckoutSelectCard(
              selected: selected,
              title: method.title,
              subtitle: method.description,
              trailing: method.code == 'delivery'
                  ? '+\$${deliveryFee.toStringAsFixed(2)}'
                  : 'Free',
              onTap: () => onSelect(index),
              primary: primary,
              icon: method.icon,
              assetPath: null,
              badge: method.code == 'pickup'
                  ? 'Bakong only'
                  : 'Address required',
            ),
          );
        }),
      ],
    );
  }
}

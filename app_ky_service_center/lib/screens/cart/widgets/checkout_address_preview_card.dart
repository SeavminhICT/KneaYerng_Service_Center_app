import 'package:flutter/material.dart';
import '../../../theme/app_fonts.dart';
import 'package:hugeicons/hugeicons.dart';

import 'checkout_colors.dart';
import 'checkout_surface_card.dart';

const Color _cPrimary = kCheckoutPrimary;

/// Card that previews the currently pinned delivery map location and opens
/// the map picker when tapped.
class CheckoutAddressPreviewCard extends StatelessWidget {
  const CheckoutAddressPreviewCard({
    super.key,
    required this.addressLine,
    this.coordinates,
    required this.onPick,
  });

  final String addressLine;
  final String? coordinates;
  final VoidCallback onPick;

  @override
  Widget build(BuildContext context) {
    final hasContent = addressLine.isNotEmpty;
    final iconColor = hasContent ? _cPrimary : checkoutInk(context);
    final actionBg = hasContent
        ? _cPrimary.withValues(alpha: 0.06)
        : checkoutSurfaceAlt(context);

    return CheckoutSurfaceCard(
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'Map Location',
                style: kFont(context,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: checkoutInk(context),
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: hasContent
                      ? _cPrimary.withValues(alpha: 0.1)
                      : checkoutSurfaceAlt(context),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  hasContent ? 'Pinned' : 'Required',
                  style: TextStyle(
                    color: hasContent ? _cPrimary : checkoutMuted(context),
                    fontWeight: FontWeight.w700,
                    fontSize: 11,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          InkWell(
            onTap: onPick,
            borderRadius: BorderRadius.circular(18),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: actionBg,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: hasContent
                      ? _cPrimary.withValues(alpha: 0.2)
                      : checkoutBorder(context),
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: hasContent
                          ? _cPrimary.withValues(alpha: 0.14)
                          : checkoutSurface(context),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Icon(
                      hasContent
                          ? HugeIcons.strokeRoundedLocation01
                          : HugeIcons.strokeRoundedMapsLocation01,
                      color: iconColor,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          hasContent
                              ? 'Selected delivery point'
                              : 'Choose delivery point on map',
                          style: TextStyle(
                            color: checkoutInk(context),
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          hasContent
                              ? addressLine
                              : 'Tap here to open the map and pin the customer location.',
                          style: TextStyle(
                            color: hasContent ? checkoutInk(context) : checkoutMuted(context),
                            height: 1.45,
                          ),
                        ),
                        if (coordinates != null &&
                            coordinates!.trim().isNotEmpty) ...[
                          const SizedBox(height: 10),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(999),
                            ),
                            child: Text(
                              coordinates!,
                              style: TextStyle(
                                color: checkoutMuted(context),
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: FilledButton.icon(
                  onPressed: onPick,
                  icon: Icon(
                    hasContent
                        ? HugeIcons.strokeRoundedEdit01
                        : HugeIcons.strokeRoundedMapsLocation01,
                    size: 18,
                  ),
                  label: Text(hasContent ? 'Update Pin' : 'Open Map'),
                  style: FilledButton.styleFrom(
                    backgroundColor: _cPrimary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
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

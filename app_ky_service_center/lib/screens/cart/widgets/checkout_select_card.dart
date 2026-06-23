import 'package:flutter/material.dart';
import '../../../theme/app_fonts.dart';
import 'package:hugeicons/hugeicons.dart';

import 'checkout_colors.dart';

/// Generic selectable option card (delivery method / payment method) with
/// an icon or asset image, title, badge, subtitle and trailing label.
class CheckoutSelectCard extends StatelessWidget {
  const CheckoutSelectCard({
    super.key,
    required this.selected,
    required this.title,
    required this.subtitle,
    required this.trailing,
    required this.onTap,
    required this.primary,
    required this.icon,
    this.assetPath,
    this.badge,
  });

  final bool selected;
  final String title;
  final String subtitle;
  final String trailing;
  final VoidCallback onTap;
  final Color primary;
  final IconData icon;
  final String? assetPath;
  final String? badge;

  @override
  Widget build(BuildContext context) {
    final hasAsset = assetPath != null && assetPath!.trim().isNotEmpty;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(22),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: selected ? primary.withValues(alpha: 0.06) : checkoutSurface(context),
          borderRadius: BorderRadius.circular(22),
          border: Border.all(
            color: selected ? primary : checkoutBorder(context),
            width: selected ? 1.6 : 1,
          ),
          boxShadow: selected
              ? [
                  BoxShadow(
                    color: primary.withValues(alpha: 0.1),
                    blurRadius: 20,
                    offset: const Offset(0, 12),
                  ),
                ]
              : [
                  BoxShadow(
                    color: checkoutShadow(context),
                    blurRadius: 12,
                    offset: const Offset(0, 6),
                  ),
                ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: hasAsset ? 78 : 48,
              height: hasAsset ? 42 : 48,
              decoration: BoxDecoration(
                color: hasAsset
                    ? Colors.white
                    : selected
                    ? primary.withValues(alpha: 0.14)
                    : checkoutSurfaceAlt(context),
                borderRadius: BorderRadius.circular(hasAsset ? 14 : 18),
                border: hasAsset
                    ? Border.all(
                        color: selected
                            ? primary.withValues(alpha: 0.24)
                            : checkoutBorder(context),
                      )
                    : null,
              ),
              child: hasAsset
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(13),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 6,
                        ),
                        child: Image.asset(
                          assetPath!,
                          fit: BoxFit.contain,
                          alignment: Alignment.center,
                        ),
                      ),
                    )
                  : Icon(icon, color: selected ? primary : checkoutInk(context)),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          children: [
                            Text(
                              title,
                              style: kFont(context,
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                                color: checkoutInk(context),
                              ),
                            ),
                            if (badge != null && badge!.trim().isNotEmpty)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 9,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: selected
                                      ? primary.withValues(alpha: 0.14)
                                      : checkoutSurfaceAlt(context),
                                  borderRadius: BorderRadius.circular(999),
                                ),
                                child: Text(
                                  badge!,
                                  style: TextStyle(
                                    color: selected ? primary : checkoutInk(context),
                                    fontWeight: FontWeight.w700,
                                    fontSize: 11,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                      if (trailing.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(left: 10),
                          child: Text(
                            trailing,
                            style: TextStyle(
                              color: trailing.toLowerCase() == 'free'
                                  ? kCheckoutSuccess
                                  : checkoutInk(context),
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                    ],
                  ),
                  if (subtitle.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Text(
                      subtitle,
                      style: TextStyle(
                        color: checkoutMuted(context),
                        fontSize: 13,
                        height: 1.45,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(width: 12),
            SizedBox(
              width: 30,
              height: 30,
              child: Icon(
                selected
                    ? HugeIcons.strokeRoundedCheckmarkCircle02
                    : HugeIcons.strokeRoundedRadioButton,
                size: 22,
                color: selected ? primary : checkoutMuted(context),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

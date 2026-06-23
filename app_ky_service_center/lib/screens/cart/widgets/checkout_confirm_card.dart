import 'package:flutter/material.dart';
import '../../../theme/app_fonts.dart';

import 'checkout_colors.dart';
import 'checkout_surface_card.dart';

/// Card on the confirm step showing pickup/delivery details as a primary
/// line plus secondary detail lines.
class CheckoutConfirmCard extends StatelessWidget {
  const CheckoutConfirmCard({
    super.key,
    required this.title,
    required this.lines,
    required this.icon,
  });

  final String title;
  final List<String> lines;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final visibleLines = lines.where((line) => line.trim().isNotEmpty).toList();
    final primaryLine = visibleLines.isEmpty ? '' : visibleLines.first;
    final secondaryLines = visibleLines.length > 1
        ? visibleLines.skip(1).toList()
        : const <String>[];
    return CheckoutSurfaceCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: checkoutSurfaceAlt(context),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(icon, color: kCheckoutPrimary),
              ),
              const SizedBox(width: 12),
              Text(
                title,
                style: kFont(context,
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: checkoutInk(context),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: checkoutSurfaceAlt(context),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: checkoutBorder(context)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (primaryLine.isNotEmpty)
                  Text(
                    primaryLine,
                    style: TextStyle(
                      color: checkoutInk(context),
                      fontWeight: FontWeight.w700,
                      height: 1.35,
                    ),
                  ),
                if (secondaryLines.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  ...secondaryLines.asMap().entries.map((entry) {
                    final isLast = entry.key == secondaryLines.length - 1;
                    return Padding(
                      padding: EdgeInsets.only(bottom: isLast ? 0 : 4),
                      child: Text(
                        entry.value,
                        style: TextStyle(
                          color: checkoutMuted(context),
                          fontWeight: FontWeight.w500,
                          height: 1.4,
                        ),
                      ),
                    );
                  }),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

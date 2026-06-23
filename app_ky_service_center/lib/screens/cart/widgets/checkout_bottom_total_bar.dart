import 'package:flutter/material.dart';
import '../../../theme/app_fonts.dart';

import '../../../l10n/app_localizations.dart';
import 'checkout_colors.dart';

/// Persistent bottom bar showing the running total, step hint, and the
/// primary continue/place-order button.
class CheckoutBottomTotalBar extends StatelessWidget {
  const CheckoutBottomTotalBar({
    super.key,
    required this.total,
    required this.buttonText,
    required this.onPressed,
    required this.primary,
    required this.stepLabel,
    required this.stepHint,
    this.compact = false,
  });

  final double total;
  final String buttonText;
  final VoidCallback? onPressed;
  final Color primary;
  final String stepLabel;
  final String stepHint;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return SafeArea(
      top: false,
      child: Container(
        padding: EdgeInsets.fromLTRB(
          16,
          compact ? 8 : 12,
          16,
          compact ? 12 : 16,
        ),
        decoration: BoxDecoration(
          color: checkoutSurface(context),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          border: Border(top: BorderSide(color: checkoutBorder(context))),
          boxShadow: [
            BoxShadow(
              color: checkoutShadow(context),
              blurRadius: 18,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              crossAxisAlignment: compact
                  ? CrossAxisAlignment.center
                  : CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        stepLabel,
                        style: kFont(context,
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: kCheckoutPrimary,
                        ),
                      ),
                      if (stepHint.trim().isNotEmpty) ...[
                        SizedBox(height: compact ? 2 : 4),
                        Text(
                          stepHint,
                          maxLines: compact ? 1 : 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: checkoutMuted(context),
                            height: compact ? 1.25 : 1.4,
                            fontSize: compact ? 12 : 13,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: compact ? 12 : 14,
                    vertical: compact ? 8 : 9,
                  ),
                  decoration: BoxDecoration(
                    color: checkoutSurfaceAlt(context).withValues(alpha: 0.82),
                    borderRadius: BorderRadius.circular(13),
                    border: Border.all(color: checkoutBorder(context)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        l.total,
                        style: TextStyle(
                          color: checkoutMuted(context),
                          fontWeight: FontWeight.w600,
                          fontSize: 11,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '\$${total.toStringAsFixed(2)}',
                        style: kFont(context,
                          fontWeight: FontWeight.w800,
                          fontSize: compact ? 16 : 20,
                          color: checkoutInk(context),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: compact ? 10 : 14),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: onPressed,
                style: FilledButton.styleFrom(
                  backgroundColor: primary,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(vertical: compact ? 14 : 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  elevation: 0,
                ),
                child: Text(
                  buttonText,
                  style: kFont(context,
                    fontWeight: FontWeight.w700,
                    fontSize: compact ? 14 : 15,
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

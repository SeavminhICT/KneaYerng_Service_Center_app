import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../l10n/app_localizations.dart';
import '../../../theme/app_fonts.dart';
import 'cart_colors.dart';

/// Pricing breakdown card (subtotal/shipping/tax/discount/total) shown
/// below the cart item list, with an animated total when it changes.
class CartOrderSummary extends StatefulWidget {
  const CartOrderSummary({
    super.key,
    required this.subtotal,
    required this.shipping,
    required this.tax,
    required this.discount,
    required this.total,
  });
  final double subtotal;
  final double shipping;
  final double tax;
  final double discount;
  final double total;

  @override
  State<CartOrderSummary> createState() => _CartOrderSummaryState();
}

class _CartOrderSummaryState extends State<CartOrderSummary> with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 350));
    _anim = AlwaysStoppedAnimation(widget.total);
  }

  @override
  void didUpdateWidget(covariant CartOrderSummary old) {
    super.didUpdateWidget(old);
    if (old.total != widget.total) {
      final begin = _anim.value;
      _anim = Tween<double>(begin: begin, end: widget.total)
          .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));
      _ctrl.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: cartSurface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [BoxShadow(color: cartShadow, blurRadius: 14, offset: Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l.orderSummary,
            style: kmFont(context, GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600, color: cartInk)),
          ),
          const SizedBox(height: 14),
          CartSummaryRow(label: l.subtotal, value: widget.subtotal),
          CartSummaryRow(
            label: 'Shipping',
            value: widget.shipping,
            displayText: widget.shipping == 0 ? 'Free' : null,
            valueColor: widget.shipping == 0 ? cartSuccess : null,
          ),
          if (widget.tax > 0) CartSummaryRow(label: 'Tax', value: widget.tax),
          if (widget.discount > 0)
            CartSummaryRow(
              key: const ValueKey('disc'),
              label: 'Discount',
              value: -widget.discount,
              valueColor: cartSuccess,
            ),
          const SizedBox(height: 12),
          // ── Total row ────────────────────────────────────────────────
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF4B6CF7), Color(0xFF6C8FFF)],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: AnimatedBuilder(
              animation: _ctrl,
              builder: (context, _) {
                final displayTotal = _ctrl.isAnimating ? _anim.value : widget.total;
                return Row(
                  children: [
                    Text(
                      l.total,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.white70,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      cartCurrency(displayTotal),
                      style: kmFont(context, GoogleFonts.poppins(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                        height: 1,
                      )),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class CartSummaryRow extends StatelessWidget {
  const CartSummaryRow({
    super.key,
    required this.label,
    required this.value,
    this.valueColor,
    this.displayText,
  });
  final String label;
  final double value;
  final Color? valueColor;
  final String? displayText;

  @override
  Widget build(BuildContext context) {
    final text = displayText ??
        (value < 0 ? '-${cartCurrency(value.abs())}' : cartCurrency(value));
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: cartMuted),
          ),
          const Spacer(),
          Text(
            text,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: valueColor ?? cartInk,
            ),
          ),
        ],
      ),
    );
  }
}

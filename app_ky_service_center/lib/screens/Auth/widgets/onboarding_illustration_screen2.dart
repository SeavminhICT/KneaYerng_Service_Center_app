import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hugeicons/hugeicons.dart';

import '../../../theme/app_fonts.dart';
import 'onboarding_design_tokens.dart';

/// Onboarding feature page 2 illustration: shop icons grid around a
/// phone mock.
class OnboardingScreen2Illustration extends StatelessWidget {
  const OnboardingScreen2Illustration({super.key, required this.size});

  final double size;

  @override
  Widget build(BuildContext context) {
    final h = size * 0.82;
    return SizedBox(
      width: size,
      height: h,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Big pastel circle bg
          Container(
            width: size * 0.78,
            height: size * 0.78,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: kOnboardingPrimaryLight,
            ),
          ),
          // Central phone mock
          Container(
            width: size * 0.32,
            height: size * 0.44,
            decoration: BoxDecoration(
              color: kOnboardingCardWhite,
              borderRadius: BorderRadius.circular(22),
              boxShadow: [
                BoxShadow(
                  color: kOnboardingPrimary.withValues(alpha: 0.2),
                  blurRadius: 28,
                  offset: const Offset(0, 12),
                ),
              ],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Image.asset(
                    'assets/images/Logo_KYSC.png',
                    width: 40,
                    height: 40,
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'KY Shop',
                  style: kFont(context,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: kOnboardingTextHead,
                  ),
                ),
                const SizedBox(height: 4),
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 12),
                  height: 5,
                  decoration: BoxDecoration(
                    color: kOnboardingPrimary,
                    borderRadius: BorderRadius.circular(99),
                  ),
                ),
                const SizedBox(height: 3),
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 18),
                  height: 5,
                  decoration: BoxDecoration(
                    color: kOnboardingPrimaryLight,
                    borderRadius: BorderRadius.circular(99),
                  ),
                ),
              ],
            ),
          ),
          // Top icon: Cart
          Positioned(
            top: h * 0.04,
            child: _ShopIconBubble(
              icon: HugeIcons.strokeRoundedShoppingCart01,
              label: 'Cart',
              color: kOnboardingPrimary,
            ),
          ),
          // Left icon: Wishlist
          Positioned(
            left: size * 0.01,
            child: _ShopIconBubble(
              icon: HugeIcons.strokeRoundedFavourite,
              label: 'Wishlist',
              color: const Color(0xFFFF6B8B),
            ),
          ),
          // Right icon: Payment
          Positioned(
            right: size * 0.01,
            child: _ShopIconBubble(
              icon: HugeIcons.strokeRoundedCreditCardAccept,
              label: 'Payment',
              color: kOnboardingAccent2,
            ),
          ),
          // Bottom icon: Lock
          Positioned(
            bottom: h * 0.04,
            child: _ShopIconBubble(
              icon: HugeIcons.strokeRoundedSquareLock01,
              label: 'Secure',
              color: kOnboardingAccent3,
            ),
          ),
          // Connecting lines (decorative arcs)
          Positioned.fill(
            child: CustomPaint(painter: _ConnectionLinePainter()),
          ),
        ],
      ),
    );
  }
}

class _ShopIconBubble extends StatelessWidget {
  const _ShopIconBubble({
    required this.icon,
    required this.label,
    required this.color,
  });

  final IconData icon;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 72,
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
      decoration: BoxDecoration(
        color: kOnboardingCardWhite,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.2),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: kmFont(context, GoogleFonts.inter(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: kOnboardingTextSub,
            )),
          ),
        ],
      ),
    );
  }
}

class _ConnectionLinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = kOnboardingPrimary.withValues(alpha: 0.12)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final cx = size.width / 2;
    final cy = size.height / 2;

    // Draw subtle dashed lines from center to each icon
    _drawDashedLine(canvas, paint, Offset(cx, cy), Offset(cx, cy * 0.12));
    _drawDashedLine(canvas, paint, Offset(cx, cy), Offset(cx * 0.14, cy));
    _drawDashedLine(canvas, paint, Offset(cx, cy), Offset(size.width - cx * 0.14, cy));
    _drawDashedLine(canvas, paint, Offset(cx, cy), Offset(cx, size.height - cy * 0.12));
  }

  void _drawDashedLine(Canvas canvas, Paint paint, Offset from, Offset to) {
    const dashLength = 5.0;
    const gapLength = 4.0;
    final total = (to - from).distance;
    final dir = (to - from) / total;
    double drawn = 0;
    bool dash = true;
    while (drawn < total) {
      final segLen = math.min(dash ? dashLength : gapLength, total - drawn);
      if (dash) {
        canvas.drawLine(from + dir * drawn, from + dir * (drawn + segLen), paint);
      }
      drawn += segLen;
      dash = !dash;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

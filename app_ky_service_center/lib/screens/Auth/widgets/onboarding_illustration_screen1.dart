import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hugeicons/hugeicons.dart';

import '../../../theme/app_fonts.dart';
import 'onboarding_design_tokens.dart';

/// Onboarding feature page 1 illustration: floating product cards
/// around the app logo.
class OnboardingScreen1Illustration extends StatelessWidget {
  const OnboardingScreen1Illustration({super.key, required this.size, required this.floatAnim});

  final double size;
  final Animation<double> floatAnim;

  @override
  Widget build(BuildContext context) {
    final h = size * 0.85;
    return SizedBox(
      width: size,
      height: h,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Background circle
          Container(
            width: size * 0.82,
            height: size * 0.82,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: kOnboardingPrimaryLight,
            ),
          ),
          // Center logo
          Container(
            width: size * 0.28,
            height: size * 0.28,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: kOnboardingPrimary.withValues(alpha: 0.25),
                  blurRadius: 24,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: ClipOval(
              child: Image.asset(
                'assets/images/Logo_KYSC.png',
                fit: BoxFit.cover,
              ),
            ),
          ),
          // Floating card top-left: Phone
          AnimatedBuilder(
            animation: floatAnim,
            builder: (context, child) => Positioned(
              top: h * 0.04 + floatAnim.value * 10,
              left: size * 0.02,
              child: _ProductCard(
                icon: HugeIcons.strokeRoundedSmartPhone01,
                label: 'iPhone 15',
                price: '\$xxx',
                color: const Color(0xFF5198F5),
              ),
            ),
          ),
          // Floating card top-right: Laptop
          AnimatedBuilder(
            animation: floatAnim,
            builder: (context, child) => Positioned(
              top: h * 0.08 - floatAnim.value * 8,
              right: size * 0.0,
              child: _ProductCard(
                icon: HugeIcons.strokeRoundedLaptop,
                label: 'MacBook',
                price: '\$x,xxx',
                color: const Color(0xFFFF8A65),
              ),
            ),
          ),
          // Floating card bottom-left: Watch
          AnimatedBuilder(
            animation: floatAnim,
            builder: (context, child) => Positioned(
              bottom: h * 0.04 - floatAnim.value * 8,
              left: size * 0.0,
              child: _ProductCard(
                icon: HugeIcons.strokeRoundedSmartWatch01,
                label: 'Apple Watch',
                price: '\$xx',
                color: const Color(0xFF34D399),
              ),
            ),
          ),
          // Floating card bottom-right: Headphones
          AnimatedBuilder(
            animation: floatAnim,
            builder: (context, child) => Positioned(
              bottom: h * 0.04 + floatAnim.value * 10,
              right: size * 0.01,
              child: _ProductCard(
                icon: HugeIcons.strokeRoundedHeadphones,
                label: 'AirPods',
                price: '\$xxx',
                color: const Color(0xFFA78BFA),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ProductCard extends StatelessWidget {
  const _ProductCard({
    required this.icon,
    required this.label,
    required this.price,
    required this.color,
  });

  final IconData icon;
  final String label;
  final String price;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 110,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: kOnboardingCardWhite,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.18),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 18),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: kmFont(context, GoogleFonts.inter(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: kOnboardingTextHead,
            )),
          ),
          const SizedBox(height: 2),
          Text(
            price,
            style: kFont(context,
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hugeicons/hugeicons.dart';

import '../../../theme/app_fonts.dart';
import 'onboarding_design_tokens.dart';

/// Onboarding feature page 3 illustration: delivery scooter with a
/// tracking timeline card.
class OnboardingScreen3Illustration extends StatelessWidget {
  const OnboardingScreen3Illustration({super.key, required this.size, required this.floatAnim});

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

          // Tracking timeline card
          Positioned(
            bottom: h * 0.02,
            left: 0,
            right: 0,
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 4),
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
              decoration: BoxDecoration(
                color: kOnboardingCardWhite,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: kOnboardingPrimary.withValues(alpha: 0.12),
                    blurRadius: 22,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                children: [
                  _TrackingStep(
                    icon: HugeIcons.strokeRoundedCheckmarkCircle02,
                    label: 'Order Confirmed',
                    done: true,
                  ),
                  _TrackingConnector(done: true),
                  _TrackingStep(
                    icon: HugeIcons.strokeRoundedPackage,
                    label: 'Package Ready',
                    done: true,
                  ),
                  _TrackingConnector(done: false),
                  _TrackingStep(
                    icon: HugeIcons.strokeRoundedScooterElectric,
                    label: 'Out for Delivery',
                    done: false,
                    isCurrent: true,
                  ),
                  _TrackingConnector(done: false),
                  _TrackingStep(
                    icon: HugeIcons.strokeRoundedHome01,
                    label: 'Delivered',
                    done: false,
                  ),
                ],
              ),
            ),
          ),

          // Delivery scooter card (floating top)
          AnimatedBuilder(
            animation: floatAnim,
            builder: (context, child) => Positioned(
              top: h * 0.04 + floatAnim.value * 8,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: kOnboardingPrimary,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: kOnboardingPrimary.withValues(alpha: 0.4),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(HugeIcons.strokeRoundedScooterElectric,
                        color: Colors.white, size: 26),
                    const SizedBox(width: 10),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'On the way!',
                          style: kFont(context,
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          '~15 min away',
                          style: kmFont(context, GoogleFonts.inter(
                            fontSize: 10,
                            color: Colors.white.withValues(alpha: 0.8),
                          )),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Map pin floating badge
          Positioned(
            top: h * 0.24,
            right: size * 0.04,
            child: _MapPinBadge(),
          ),

          // Package icon badge
          Positioned(
            top: h * 0.22,
            left: size * 0.04,
            child: Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: kOnboardingCardWhite,
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color: kOnboardingAccent2.withValues(alpha: 0.2),
                    blurRadius: 14,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Icon(HugeIcons.strokeRoundedPackage,
                  color: kOnboardingAccent2, size: 24),
            ),
          ),
        ],
      ),
    );
  }
}

class _TrackingStep extends StatelessWidget {
  const _TrackingStep({
    required this.icon,
    required this.label,
    required this.done,
    this.isCurrent = false,
  });

  final IconData icon;
  final String label;
  final bool done;
  final bool isCurrent;

  @override
  Widget build(BuildContext context) {
    final color = done || isCurrent ? kOnboardingPrimary : kOnboardingTextMuted;
    final bgColor = done
        ? kOnboardingPrimary.withValues(alpha: 0.12)
        : isCurrent
            ? kOnboardingPrimary.withValues(alpha: 0.08)
            : const Color(0xFFF1F3F5);

    return Row(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: bgColor,
            shape: BoxShape.circle,
          ),
          child: Icon(icon, size: 16, color: color),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            label,
            style: kmFont(context, GoogleFonts.inter(
              fontSize: 12,
              fontWeight: isCurrent ? FontWeight.w700 : FontWeight.w500,
              color: done || isCurrent ? kOnboardingTextHead : kOnboardingTextMuted,
            )),
          ),
        ),
        if (done)
          const Icon(HugeIcons.strokeRoundedTick01, size: 14, color: kOnboardingPrimary),
        if (isCurrent)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
            decoration: BoxDecoration(
              color: kOnboardingPrimary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(99),
            ),
            child: Text(
              'Live',
              style: kFont(context,
                fontSize: 9,
                fontWeight: FontWeight.w700,
                color: kOnboardingPrimary,
              ),
            ),
          ),
      ],
    );
  }
}

class _TrackingConnector extends StatelessWidget {
  const _TrackingConnector({required this.done});
  final bool done;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 15),
      child: Column(
        children: List.generate(3, (i) {
          return Container(
            width: 2,
            height: 4,
            margin: const EdgeInsets.symmetric(vertical: 1),
            decoration: BoxDecoration(
              color:
                  done ? kOnboardingPrimary : kOnboardingPrimary.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(99),
            ),
          );
        }),
      ),
    );
  }
}

class _MapPinBadge extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: kOnboardingCardWhite,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFFF6B8B).withValues(alpha: 0.2),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: const Icon(HugeIcons.strokeRoundedLocation01,
          color: Color(0xFFFF6B8B), size: 24),
    );
  }
}

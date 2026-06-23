import 'package:flutter/material.dart';
import '../../../theme/app_fonts.dart';

import 'checkout_colors.dart';

/// Static metadata describing one step of the checkout flow.
class CheckoutStepMeta {
  const CheckoutStepMeta({
    required this.label,
    required this.title,
    required this.subtitle,
    required this.icon,
  });

  final String label;
  final String title;
  final String subtitle;
  final IconData icon;
}

/// The header shown under the checkout app bar: current step title plus
/// the tappable step progress row.
class CheckoutStepHeader extends StatelessWidget {
  const CheckoutStepHeader({
    super.key,
    required this.steps,
    required this.currentStep,
    required this.primary,
    required this.onStepTap,
  });

  final List<CheckoutStepMeta> steps;
  final int currentStep;
  final Color primary;
  final ValueChanged<int> onStepTap;

  @override
  Widget build(BuildContext context) {
    final current = steps[currentStep];
    return Container(
      padding: const EdgeInsets.fromLTRB(18, 10, 18, 14),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        border: Border(
          bottom: BorderSide(color: checkoutBorder(context).withValues(alpha: 0.85)),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Text(
                  current.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: kFont(context,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: checkoutInk(context),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Text(
                'Step ${currentStep + 1} of ${steps.length}',
                style: TextStyle(
                  color: checkoutMuted(context),
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: List.generate(steps.length, (index) {
              final active = index <= currentStep;
              final isPast = index < currentStep;
              return Expanded(
                child: Padding(
                  padding: EdgeInsets.only(
                    right: index == steps.length - 1 ? 0 : 6,
                  ),
                  child: GestureDetector(
                    onTap: isPast ? () => onStepTap(index) : null,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 220),
                      height: 5,
                      decoration: BoxDecoration(
                        color: active ? primary : checkoutBorder(context),
                        borderRadius: BorderRadius.circular(999),
                      ),
                    ),
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}

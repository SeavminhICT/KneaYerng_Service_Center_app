import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';

import 'product_detail_tone.dart';

/// Row of three trust badges (secure checkout / returns / shipping) shown
/// below the variant selectors.
class ProductTrustStrip extends StatelessWidget {
  const ProductTrustStrip({super.key, required this.tone});

  final ProductDetailTone tone;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color:        tone.white,
        borderRadius: BorderRadius.circular(14),
        border:       Border.all(color: tone.border),
      ),
      child: Row(
        children: [
          Expanded(
            child: _TrustItem(
              tone:  tone,
              icon:  HugeIcons.strokeRoundedShield01,
              label: 'Secure\nCheckout',
              color: const Color(0xFF2563EB),
            ),
          ),
          _VDivider(tone: tone),
          Expanded(
            child: _TrustItem(
              tone:  tone,
              icon:  HugeIcons.strokeRoundedReturnRequest,
              label: '30-Day\nReturns',
              color: const Color(0xFF16A34A),
            ),
          ),
          _VDivider(tone: tone),
          Expanded(
            child: _TrustItem(
              tone:  tone,
              icon:  HugeIcons.strokeRoundedDeliveryTruck01,
              label: 'Fast\nShipping',
              color: const Color(0xFF7C3AED),
            ),
          ),
        ],
      ),
    );
  }
}

class _VDivider extends StatelessWidget {
  const _VDivider({required this.tone});

  final ProductDetailTone tone;

  @override
  Widget build(BuildContext context) {
    return Container(
      width:  1,
      height: 36,
      color:  tone.divider,
    );
  }
}

class _TrustItem extends StatelessWidget {
  const _TrustItem({
    required this.tone,
    required this.icon,
    required this.label,
    required this.color,
  });

  final ProductDetailTone tone;
  final IconData          icon;
  final String            label;
  final Color             color;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width:  34,
          height: 34,
          decoration: BoxDecoration(
            color:        color.withAlpha((0.10 * 255).round()),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, size: 17, color: color),
        ),
        const SizedBox(height: 6),
        Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize:   10.5,
            fontWeight: FontWeight.w600,
            color:      tone.textSub,
            height:     1.3,
          ),
        ),
      ],
    );
  }
}

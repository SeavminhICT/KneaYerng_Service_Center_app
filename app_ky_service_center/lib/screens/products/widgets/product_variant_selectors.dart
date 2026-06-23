import 'package:flutter/material.dart';

import 'product_detail_tone.dart';

/// Variant selector building blocks: the "Label · Selected" header row, the
/// plain chip button (size/condition), and the swatch chip (color).

class ProductVariantRow extends StatelessWidget {
  const ProductVariantRow({
    super.key,
    required this.tone,
    required this.label,
    required this.selected,
  });

  final ProductDetailTone tone;
  final String            label;
  final String            selected;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize:   14,
            fontWeight: FontWeight.w600,
            color:      tone.textPrimary,
          ),
        ),
        const SizedBox(width: 6),
        Text('·', style: TextStyle(color: tone.textHint)),
        const SizedBox(width: 6),
        Text(
          selected,
          style: const TextStyle(
            fontSize:   13.5,
            color:      pdAccent,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

class ProductVariantChipButton extends StatelessWidget {
  const ProductVariantChipButton({
    super.key,
    required this.tone,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final ProductDetailTone tone;
  final String            label;
  final bool              selected;
  final VoidCallback      onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 140),
        padding:  const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color:        selected ? pdAccent     : tone.surfaceAlt,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: selected ? pdAccent : tone.border,
            width: selected ? 1.5      : 1,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize:   13,
            fontWeight: FontWeight.w600,
            color:      selected ? Colors.white : tone.textPrimary,
          ),
        ),
      ),
    );
  }
}

class ProductColorChip extends StatelessWidget {
  const ProductColorChip({
    super.key,
    required this.tone,
    required this.label,
    required this.color,
    required this.selected,
    required this.onTap,
  });

  final ProductDetailTone tone;
  final String            label;
  final Color             color;
  final bool              selected;
  final VoidCallback      onTap;

  @override
  Widget build(BuildContext context) {
    final needsBorder = color.computeLuminance() > 0.85;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 140),
        padding:  const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
        decoration: BoxDecoration(
          color:        selected ? tone.accentLight : tone.surfaceAlt,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: selected ? pdAccent : tone.border,
            width: selected ? 1.5      : 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width:  20,
              height: 20,
              decoration: BoxDecoration(
                color:  color,
                shape:  BoxShape.circle,
                border: Border.all(
                  color: needsBorder ? tone.border : Colors.white54,
                ),
              ),
            ),
            const SizedBox(width: 7),
            Text(
              label,
              style: TextStyle(
                fontSize:   12.5,
                fontWeight: FontWeight.w600,
                color:      selected ? pdAccentDark : tone.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

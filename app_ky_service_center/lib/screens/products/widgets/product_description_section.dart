import 'package:flutter/material.dart';

import 'product_detail_tone.dart';

/// Expandable description text block with a "Read more / Show less"
/// toggle.
class ProductDescriptionBlock extends StatelessWidget {
  const ProductDescriptionBlock({
    super.key,
    required this.tone,
    required this.text,
    required this.expanded,
    required this.onToggle,
  });

  final ProductDetailTone tone;
  final String            text;
  final bool              expanded;
  final VoidCallback?     onToggle;

  @override
  Widget build(BuildContext context) {
    final shouldCollapse = text.length > 180;
    final visibleText    = !shouldCollapse || expanded
        ? text
        : '${text.substring(0, 180).trimRight()}...';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 160),
          child: Text(
            visibleText,
            key:   ValueKey(visibleText.length),
            style: TextStyle(
              fontSize: 14,
              height:   1.7,
              color:    tone.textPrimary,
            ),
          ),
        ),
        if (shouldCollapse && onToggle != null) ...[
          const SizedBox(height: 8),
          GestureDetector(
            onTap: onToggle,
            child: Text(
              expanded ? 'Show less' : 'Read more',
              style: const TextStyle(
                fontSize:   13.5,
                fontWeight: FontWeight.w600,
                color:      pdAccent,
              ),
            ),
          ),
        ],
      ],
    );
  }
}

/// "Key Features" bulleted list shown under the description.
class ProductFeatureBulletList extends StatelessWidget {
  const ProductFeatureBulletList({
    super.key,
    required this.tone,
    required this.items,
  });

  final ProductDetailTone tone;
  final List<String>      items;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Key Features',
          style: TextStyle(
            fontSize:   13.5,
            fontWeight: FontWeight.w700,
            color:      tone.textPrimary,
          ),
        ),
        const SizedBox(height: 10),
        for (final item in items)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: Container(
                    width:  6,
                    height: 6,
                    decoration: const BoxDecoration(
                      color: pdAccent,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    item,
                    style: TextStyle(
                      fontSize: 13.5,
                      height:   1.55,
                      color:    tone.textSub,
                    ),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

import 'package:flutter/material.dart';

import '../../../widgets/app_network_image.dart';
import 'product_detail_common.dart';
import 'product_detail_tone.dart';

/// Hero image carousel for the product detail screen: main image with
/// stock/discount badges, dot indicators, and a thumbnail rail.
class ProductImageGallery extends StatelessWidget {
  const ProductImageGallery({
    super.key,
    required this.tone,
    required this.imageUrl,
    required this.gallery,
    required this.selectedIndex,
    required this.stockLabel,
    required this.isOutOfStock,
    required this.onSelectIndex,
    this.discountLabel,
  });

  final ProductDetailTone tone;
  final String?           imageUrl;
  final List<String>      gallery;
  final int               selectedIndex;
  final String            stockLabel;
  final bool              isOutOfStock;
  final String?           discountLabel;
  final ValueChanged<int> onSelectIndex;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: tone.white,
      child: Column(
        children: [
          // Main image
          Stack(
            children: [
              Container(
                height: 300,
                width:  double.infinity,
                color:  tone.surfaceAlt,
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 260),
                  switchInCurve:  Curves.easeOutCubic,
                  switchOutCurve: Curves.easeInCubic,
                  transitionBuilder: (child, anim) => FadeTransition(
                    opacity: anim,
                    child: ScaleTransition(
                      scale: Tween<double>(begin: 0.96, end: 1.0)
                          .animate(anim),
                      child: child,
                    ),
                  ),
                  child: imageUrl == null || imageUrl!.isEmpty
                      ? const ProductDetailImageFallback(
                          key: ValueKey('empty'), size: 64)
                      : Padding(
                          padding: const EdgeInsets.all(20),
                          child: AppNetworkImage(
                            imageUrl!,
                            key: ValueKey(imageUrl),
                            fit: BoxFit.contain,
                            errorWidget: (context, url, error) =>
                                const ProductDetailImageFallback(
                                    key: ValueKey('err'), size: 64),
                          ),
                        ),
                ),
              ),

              // Top badges
              Positioned(
                top:  12,
                left: 12,
                child: Row(
                  children: [
                    if (discountLabel != null)
                      ProductDetailBadge(
                        label: discountLabel!,
                        bg:    pdRed,
                        fg:    Colors.white,
                      ),
                    if (discountLabel != null)
                      const SizedBox(width: 6),
                    ProductDetailStockBadge(
                      tone:        tone,
                      label:       stockLabel,
                      isOutOfStock: isOutOfStock,
                    ),
                  ],
                ),
              ),

              // Photo count
              if (gallery.length > 1)
                Positioned(
                  top:   12,
                  right: 12,
                  child: ProductDetailBadge(
                    label: '${gallery.length} photos',
                    bg:    tone.white,
                    fg:    tone.textSub,
                    border: tone.border,
                  ),
                ),
            ],
          ),

          // Dot indicators
          if (gallery.length > 1) ...[
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(gallery.length, (i) {
                final sel = i == selectedIndex;
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin:  const EdgeInsets.symmetric(horizontal: 3),
                  width:   sel ? 20 : 6,
                  height:  6,
                  decoration: BoxDecoration(
                    color:        sel ? pdAccent : tone.border,
                    borderRadius: BorderRadius.circular(99),
                  ),
                );
              }),
            ),
            const SizedBox(height: 10),
          ],

          // Thumbnail rail
          if (gallery.length > 1) ...[
            const SizedBox(height: 2),
            SizedBox(
              height: 70,
              child: ListView.separated(
                scrollDirection:    Axis.horizontal,
                padding:            const EdgeInsets.symmetric(horizontal: 14),
                separatorBuilder:   (context, index) => const SizedBox(width: 8),
                itemCount:          gallery.length,
                itemBuilder: (context, i) {
                  final sel = i == selectedIndex;
                  return GestureDetector(
                    onTap: () => onSelectIndex(i),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 160),
                      width:  62,
                      padding: const EdgeInsets.all(5),
                      decoration: BoxDecoration(
                        color:        sel ? tone.accentLight : tone.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: sel ? pdAccent : tone.border,
                          width: sel ? 1.5 : 1,
                        ),
                      ),
                      child: AppNetworkImage(
                        gallery[i],
                        fit: BoxFit.contain,
                        errorWidget: (context, url, error) =>
                            const ProductDetailImageFallback(size: 18),
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 12),
          ],

          // Bottom border
          Container(height: 1, color: tone.divider),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hugeicons/hugeicons.dart';

import '../../../services/cart_service.dart';
import '../../../theme/app_fonts.dart';
import 'product_detail_common.dart';
import 'product_detail_tone.dart';

/// Top app bar for the product detail screen: back button, title, favorite
/// toggle, and an optional cart icon (with live badge count).
class ProductDetailAppBar extends StatelessWidget {
  const ProductDetailAppBar({
    super.key,
    required this.tone,
    required this.title,
    required this.isFavorite,
    required this.onBack,
    required this.onFavorite,
    required this.onCartTap,
  });

  final ProductDetailTone tone;
  final String            title;
  final bool              isFavorite;
  final VoidCallback      onBack;
  final VoidCallback      onFavorite;
  final VoidCallback?     onCartTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      height:  56,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        color: tone.white,
        border: Border(
          bottom: BorderSide(color: tone.border.withAlpha((0.6 * 255).round())),
        ),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Positioned.fill(
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: onCartTap != null ? 92 : 48,
              ),
              child: Center(
                child: Text(
                  title,
                  textAlign:  TextAlign.center,
                  maxLines:   1,
                  overflow:   TextOverflow.ellipsis,
                  style: kmFont(context, GoogleFonts.inter(
                    fontSize:   16,
                    fontWeight: FontWeight.w700,
                    color:      tone.textPrimary,
                  )),
                ),
              ),
            ),
          ),
          Row(
            children: [
              ProductDetailIconBtn(
                icon:      HugeIcons.strokeRoundedArrowLeft01,
                iconColor: tone.textPrimary,
                onTap:     onBack,
              ),
              const Spacer(),
              ProductDetailIconBtn(
                icon:      HugeIcons.strokeRoundedFavourite,
                iconColor: isFavorite ? pdRed : tone.textSub,
                bg:        isFavorite ? tone.redLight : null,
                onTap:     onFavorite,
              ),
              if (onCartTap != null) ...[
                const SizedBox(width: 4),
                _CartIconBtn(tone: tone, onTap: onCartTap!),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

class _CartIconBtn extends StatelessWidget {
  const _CartIconBtn({required this.tone, required this.onTap});

  final ProductDetailTone tone;
  final VoidCallback      onTap;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: CartService.instance,
      builder: (context, _) {
        final count = CartService.instance.totalItems;
        return Stack(
          clipBehavior: Clip.none,
          children: [
            ProductDetailIconBtn(
              icon:      HugeIcons.strokeRoundedShoppingCart01,
              iconColor: tone.textPrimary,
              onTap:     onTap,
            ),
            if (count > 0)
              Positioned(
                top: 4,
                right: 4,
                child: IgnorePointer(
                  child: Container(
                    constraints: const BoxConstraints(
                      minWidth: 16,
                      minHeight: 16,
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    decoration: BoxDecoration(
                      color: pdAccent,
                      borderRadius: BorderRadius.circular(999),
                      border: Border.all(color: Colors.white, width: 1.5),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      '$count',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 8,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}

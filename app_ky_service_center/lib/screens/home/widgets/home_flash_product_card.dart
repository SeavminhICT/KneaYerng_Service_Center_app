import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hugeicons/hugeicons.dart';

import '../../../l10n/app_localizations.dart';
import '../../../models/product.dart';
import '../../../services/favorite_service.dart';
import '../../../theme/app_fonts.dart';
import '../../../widgets/app_network_image.dart';
import 'home_colors.dart';

/// Product card used in the home screen's hot sale carousel and the
/// per-category product grids. Shows a discount/tag badge, favorite
/// toggle, image, name, specs, price, and an add-to-cart button.
class HomeFlashProductCard extends StatelessWidget {
  const HomeFlashProductCard({
    super.key,
    required this.product,
    required this.onOpen,
    required this.onAdd,
  });

  final Product product;
  final VoidCallback onOpen;
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final imageUrl = product.imageUrl;
    final badge = homeProductBadgeText(product);
    final hasDiscount = product.hasDiscount;
    final originalPrice = product.price;
    final discountedPrice = product.salePrice;

    return Material(
      color: homeSurface(context),
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onOpen,
        child: Container(
          padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            color: homeSurface(context),
            border: Border.all(color: homeCardBorder(context)),
            boxShadow: const [
              BoxShadow(color: homeShadow, blurRadius: 12, offset: Offset(0, 6)),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  if (badge != null)
                    Expanded(
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: _DiscountBadge(text: badge),
                      ),
                    )
                  else
                    const Spacer(),
                  _FavoriteButton(product: product),
                ],
              ),
              const SizedBox(height: 8),
              Expanded(
                flex: 8,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(8),
                  decoration: const BoxDecoration(
                    color: Colors.transparent,
                    borderRadius: BorderRadius.all(Radius.circular(18)),
                  ),
                  child: imageUrl == null || imageUrl.isEmpty
                      ? const Icon(
                          HugeIcons.strokeRoundedImage01,
                          color: homePrimary,
                          size: 38,
                        )
                      : AppNetworkImage(
                          imageUrl,
                          fit: BoxFit.contain,
                          alignment: Alignment.center,
                          errorWidget: (context, url, error) => Icon(
                            HugeIcons.strokeRoundedImageNotFound01,
                            color: homeTextMuted(context),
                            size: 42,
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                product.name,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: kFont(context,
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: homeTextPrimary(context),
                  height: 1.25,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                homeProductSpecs(product),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: kmFont(context, GoogleFonts.manrope(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w600,
                  color: homeTextMuted(context),
                )),
              ),
              const SizedBox(height: 10),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '\$${discountedPrice.toStringAsFixed(0)}',
                          style: kFont(context,
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: hasDiscount
                                ? homeDanger
                                : homeTextPrimary(context),
                          ),
                        ),
                        if (hasDiscount && discountedPrice < originalPrice) ...[
                          const SizedBox(height: 2),
                          Text(
                            '\$${originalPrice.toStringAsFixed(2)}',
                            style: kmFont(context, GoogleFonts.manrope(
                              fontSize: 11.5,
                              color: homeTextMuted(context),
                              decoration: TextDecoration.lineThrough,
                            )),
                          ),
                        ] else
                          Text(
                            l.inStock,
                            style: kmFont(context, GoogleFonts.manrope(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: homeSuccess,
                            )),
                          ),
                      ],
                    ),
                  ),
                  _AddCircleButton(onTap: onAdd),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Builds a short, two-part spec line (e.g. "8GB | 256GB") for a product
/// card, falling back to category name or a generic label.
String homeProductSpecs(Product product) {
  final parts = <String>[];

  final firstRam = product.ramOptions.isNotEmpty
      ? product.ramOptions.first.trim()
      : null;
  final storage = product.storageCapacity?.trim();
  final ssd = product.ssd?.trim();
  final brand = product.brand?.trim();

  if (firstRam != null && firstRam.isNotEmpty) parts.add(firstRam);
  if (storage != null && storage.isNotEmpty) {
    parts.add(storage);
  } else if (ssd != null && ssd.isNotEmpty) {
    parts.add(ssd);
  }
  if (brand != null && brand.isNotEmpty) parts.add(brand);

  if (parts.isEmpty) {
    return product.categoryName?.trim().isNotEmpty == true
        ? product.categoryName!.trim()
        : 'Premium device';
  }

  return parts.take(2).join(' | ');
}

String _formatTagLabel(String raw) {
  return raw
      .replaceAll(RegExp(r'[_-]+'), ' ')
      .split(' ')
      .where((part) => part.isNotEmpty)
      .map(
        (part) => '${part[0].toUpperCase()}${part.substring(1).toLowerCase()}',
      )
      .join(' ');
}

String? _discountLabel(Product product) {
  final discount = product.discount;
  if (discount == null || discount <= 0) return null;
  final base = product.price;
  if (base <= 0) return null;
  final percent = (discount / base * 100).round().clamp(1, 90);
  return '$percent% OFF';
}

/// Badge text shown on a product card: a discount percentage if present,
/// otherwise the product tag, a "New" badge for recently created
/// products, or a generic "Featured" fallback.
String? homeProductBadgeText(Product product) {
  final discount = _discountLabel(product);
  if (discount != null) return discount;

  final tag = product.tag?.trim();
  if (tag != null && tag.isNotEmpty) {
    return _formatTagLabel(tag);
  }

  if (product.createdAt != null &&
      DateTime.now().difference(product.createdAt!).inDays <= 30) {
    return 'New';
  }

  return 'Featured';
}

class _DiscountBadge extends StatelessWidget {
  const _DiscountBadge({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    final lower = text.toLowerCase();
    final foreground = lower.contains('sale')
        ? const Color(0xFFFF7A1A)
        : lower.contains('hot')
        ? const Color(0xFFEF4444)
        : lower.contains('new')
        ? const Color(0xFF22A06B)
        : homePrimary;
    final background = foreground.withValues(alpha: 0.12);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        text,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: kmFont(context, GoogleFonts.manrope(
          color: foreground,
          fontSize: 10,
          fontWeight: FontWeight.w800,
        )),
      ),
    );
  }
}

class _FavoriteButton extends StatelessWidget {
  const _FavoriteButton({required this.product});

  final Product product;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: FavoriteService.instance,
      builder: (context, _) {
        final isFavorite = FavoriteService.instance.contains(product);
        return InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: () => FavoriteService.instance.toggle(product),
          child: Container(
            height: 34,
            width: 34,
            decoration: BoxDecoration(
              color: homeSurfaceAlt(context),
              borderRadius: BorderRadius.circular(17),
              border: Border.all(color: homeCardBorder(context)),
            ),
            child: Icon(
              HugeIcons.strokeRoundedFavourite,
              size: 18,
              color: isFavorite ? const Color(0xFFE11D48) : homeTextMuted(context),
            ),
          ),
        );
      },
    );
  }
}

class _AddCircleButton extends StatelessWidget {
  const _AddCircleButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        height: 42,
        width: 42,
        decoration: BoxDecoration(
          color: homePrimarySoft,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: homePrimary.withValues(alpha: 0.08)),
          boxShadow: [
            BoxShadow(
              color: homePrimary.withValues(alpha: 0.12),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: const Icon(
          HugeIcons.strokeRoundedShoppingCartCheckOut01,
          size: 20,
          color: homePrimary,
        ),
      ),
    );
  }
}

import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart' show ScrollDirection;
import 'package:google_fonts/google_fonts.dart';
import 'package:hugeicons/hugeicons.dart';

import '../../../models/banner_item.dart';
import '../../../models/product.dart';
import '../../../theme/app_fonts.dart';
import '../../../widgets/app_network_image.dart';
import 'home_colors.dart';

/// Hero area at the top of the home screen: either an auto-sliding banner
/// carousel (when banners are loaded) or a static fallback showcase built
/// from a matching laptop/phone product.
class HomeHeroShowcase extends StatelessWidget {
  const HomeHeroShowcase({
    super.key,
    required this.loading,
    required this.banners,
    required this.controller,
    required this.activeIndex,
    required this.onPageChanged,
    required this.onInteractionStart,
    required this.onInteractionEnd,
    required this.onIndicatorTap,
    required this.products,
    required this.onShopNow,
  });

  final bool loading;
  final List<BannerItem> banners;
  final PageController controller;
  final int activeIndex;
  final ValueChanged<int> onPageChanged;
  final VoidCallback onInteractionStart;
  final VoidCallback onInteractionEnd;
  final ValueChanged<int> onIndicatorTap;
  final List<Product> products;
  final VoidCallback onShopNow;

  static Product? _firstProductMatch(
    List<Product> products,
    List<String> keywords,
  ) {
    for (final product in products) {
      final haystack = [
        product.name,
        product.categoryName ?? '',
        product.brand ?? '',
        product.tag ?? '',
      ].join(' ').toLowerCase();
      if (keywords.any(haystack.contains)) {
        return product;
      }
    }
    return products.isEmpty ? null : products.first;
  }

  @override
  Widget build(BuildContext context) {
    if (banners.isNotEmpty) {
      return LayoutBuilder(
        builder: (context, constraints) {
          final bannerHeight = (constraints.maxWidth / (16 / 7))
              .clamp(150.0, 190.0)
              .toDouble();

          return Container(
            height: bannerHeight,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18),
              boxShadow: const [
                BoxShadow(color: homeShadow, blurRadius: 18, offset: Offset(0, 8)),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(18),
              child: Stack(
                children: [
                  NotificationListener<ScrollNotification>(
                    onNotification: (notification) {
                      if (notification is ScrollStartNotification &&
                          notification.dragDetails != null) {
                        onInteractionStart();
                      } else if (notification is ScrollEndNotification) {
                        onInteractionEnd();
                      } else if (notification is UserScrollNotification &&
                          notification.direction == ScrollDirection.idle) {
                        onInteractionEnd();
                      }
                      return false;
                    },
                    child: PageView.builder(
                      controller: controller,
                      itemCount: banners.length,
                      onPageChanged: onPageChanged,
                      itemBuilder: (context, index) {
                        final banner = banners[index];
                        return _HeroBannerSlide(item: banner, onTap: onShopNow);
                      },
                    ),
                  ),
                  if (banners.length > 1)
                    Positioned(
                      left: 0,
                      right: 0,
                      bottom: 12,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(
                          banners.length,
                          (index) => GestureDetector(
                            behavior: HitTestBehavior.opaque,
                            onTap: () => onIndicatorTap(index),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 220),
                              width: index == activeIndex ? 18 : 8,
                              height: 8,
                              margin: const EdgeInsets.symmetric(
                                horizontal: 4,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color: index == activeIndex
                                    ? Colors.white
                                    : Colors.white.withValues(alpha: 0.48),
                                borderRadius: BorderRadius.circular(999),
                                boxShadow: const [
                                  BoxShadow(
                                    color: Color(0x33000000),
                                    blurRadius: 8,
                                    offset: Offset(0, 2),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          );
        },
      );
    }

    final laptop = _firstProductMatch(products, const [
      'macbook',
      'laptop',
      'mac',
    ]);
    final phone = _firstProductMatch(products, const [
      'iphone',
      'phone',
      'mobile',
    ]);

    return LayoutBuilder(
      builder: (context, constraints) {
        final compact = constraints.maxWidth < 360;
        final heroHeight = compact ? 330.0 : 320.0;
        final textWidth = compact
            ? constraints.maxWidth * 0.72
            : math.min(214.0, constraints.maxWidth * 0.56);
        final laptopWidth = compact ? 150.0 : 188.0;
        final laptopHeight = compact ? 118.0 : 150.0;
        final phoneWidth = compact ? 60.0 : 76.0;
        final phoneHeight = compact ? 88.0 : 112.0;

        return Container(
          height: heroHeight,
          decoration: BoxDecoration(
            color: homeHeroLight,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: homeCardBorder(context)),
            boxShadow: const [
              BoxShadow(color: homeShadow, blurRadius: 18, offset: Offset(0, 8)),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(18),
            child: Stack(
              clipBehavior: Clip.hardEdge,
              children: [
                Positioned(
                  top: -14,
                  right: -18,
                  child: Container(
                    width: 170,
                    height: 170,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          homePrimary.withValues(alpha: 0.10),
                          homeHeroBlue.withValues(alpha: 0),
                        ],
                      ),
                    ),
                  ),
                ),
                Positioned(
                  right: compact ? -18 : -10,
                  bottom: 38,
                  child: IgnorePointer(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        _HeroDeviceImage(
                          product: laptop,
                          width: laptopWidth,
                          height: laptopHeight,
                          icon: HugeIcons.strokeRoundedLaptop,
                          frameColor: homePrimary,
                          surfaceColor: const Color(0xFFE8EEFF),
                        ),
                        Transform.translate(
                          offset: Offset(compact ? -8 : -10, 8),
                          child: _HeroDeviceImage(
                            product: phone,
                            width: phoneWidth,
                            height: phoneHeight,
                            icon: HugeIcons.strokeRoundedSmartPhone01,
                            frameColor: homePrimary,
                            surfaceColor: const Color(0xFFF0F3FF),
                            isPhone: true,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(18, 18, 18, 18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 7,
                        ),
                        decoration: BoxDecoration(
                          color: homeHeroPurple,
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(
                          'New Arrival',
                          style: kmFont(context, GoogleFonts.manrope(
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                            color: homeSurface(context),
                          )),
                        ),
                      ),
                      const SizedBox(height: 14),
                      SizedBox(
                        width: textWidth,
                        child: Text(
                          'Power.\nPerformance.\nPerfected.',
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                          style: kFont(context,
                            fontSize: compact ? 28 : 31,
                            height: 1.06,
                            fontWeight: FontWeight.w700,
                            color: homeTextPrimary(context),
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      SizedBox(
                        width: textWidth,
                        child: Text(
                          loading
                              ? 'Loading the latest MacBook and iPhone showcase.'
                              : 'Explore the latest MacBook and iPhone.',
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: kmFont(context, GoogleFonts.manrope(
                            fontSize: 14,
                            height: 1.45,
                            fontWeight: FontWeight.w600,
                            color: homeTextMuted(context),
                          )),
                        ),
                      ),
                      const SizedBox(height: 16),
                      FilledButton(
                        onPressed: onShopNow,
                        style: FilledButton.styleFrom(
                          backgroundColor: homePrimary,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 18,
                            vertical: 15,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(18),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'Shop Now',
                              style: kmFont(context, GoogleFonts.manrope(
                                fontWeight: FontWeight.w800,
                                fontSize: 15,
                              )),
                            ),
                            const SizedBox(width: 8),
                            const Icon(
                              HugeIcons.strokeRoundedArrowRight01,
                              size: 18,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 16,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      3,
                      (index) => Container(
                        width: index == 0 ? 18 : 8,
                        height: 8,
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        decoration: BoxDecoration(
                          color: index == 0 ? homePrimary : homeCardBorder(context),
                          borderRadius: BorderRadius.circular(999),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _HeroBannerSlide extends StatelessWidget {
  const _HeroBannerSlide({required this.item, required this.onTap});

  final BannerItem item;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final title = item.title?.trim() ?? '';
    final subtitle = item.subtitle?.trim() ?? '';
    final badge = item.badgeLabel?.trim() ?? '';
    final cta = (item.ctaLabel?.trim().isNotEmpty ?? false)
        ? item.ctaLabel!.trim()
        : 'Shop Now';
    final imageUrl = item.imageUrl?.trim();
    final hasCopy = title.isNotEmpty || subtitle.isNotEmpty || badge.isNotEmpty;

    return LayoutBuilder(
      builder: (context, constraints) {
        final compact = constraints.maxWidth < 360;
        final textWidth = compact
            ? constraints.maxWidth * 0.72
            : math.min(224.0, constraints.maxWidth * 0.60);
        final ctaTextWidth = math.max(72.0, textWidth - 62);

        return Material(
          color: homeHeroLight,
          child: InkWell(
            onTap: onTap,
            child: Stack(
              fit: StackFit.expand,
              clipBehavior: Clip.hardEdge,
              children: [
                if (imageUrl != null && imageUrl.isNotEmpty)
                  AppNetworkImage(
                    imageUrl,
                    fit: BoxFit.cover,
                    alignment: Alignment.center,
                    errorWidget: (context, url, error) =>
                        const _BannerImageFallback(),
                  )
                else
                  const _BannerImageFallback(),
                if (hasCopy)
                  DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                        colors: [
                          Colors.black.withValues(alpha: 0.68),
                          Colors.black.withValues(alpha: 0.30),
                          Colors.black.withValues(alpha: 0.02),
                        ],
                      ),
                    ),
                  ),
                if (hasCopy)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(18, 16, 18, 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (badge.isNotEmpty) ...[
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.16),
                              borderRadius: BorderRadius.circular(999),
                              border: Border.all(
                                color: Colors.white.withValues(alpha: 0.28),
                              ),
                            ),
                            child: Text(
                              badge,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: kmFont(context, GoogleFonts.manrope(
                                fontSize: 11,
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                              )),
                            ),
                          ),
                          const SizedBox(height: 8),
                        ],
                        if (title.isNotEmpty)
                          SizedBox(
                            width: textWidth,
                            child: Text(
                              title,
                              maxLines: compact ? 2 : 3,
                              overflow: TextOverflow.ellipsis,
                              style: kFont(context,
                                fontSize: compact ? 20 : 23,
                                height: 1.08,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        if (subtitle.isNotEmpty) ...[
                          const SizedBox(height: 6),
                          SizedBox(
                            width: textWidth,
                            child: Text(
                              subtitle,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: kmFont(context, GoogleFonts.manrope(
                                fontSize: 12,
                                height: 1.35,
                                fontWeight: FontWeight.w600,
                                color: Colors.white.withValues(alpha: 0.88),
                              )),
                            ),
                          ),
                        ],
                        const Spacer(),
                        SizedBox(
                          height: 38,
                          child: FilledButton(
                            onPressed: onTap,
                            style: FilledButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: homePrimary,
                              elevation: 0,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                ConstrainedBox(
                                  constraints: BoxConstraints(
                                    maxWidth: ctaTextWidth,
                                  ),
                                  child: Text(
                                    cta,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: kmFont(context, GoogleFonts.manrope(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w800,
                                    )),
                                  ),
                                ),
                                const SizedBox(width: 6),
                                const Icon(
                                  HugeIcons.strokeRoundedArrowRight01,
                                  size: 16,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _BannerImageFallback extends StatelessWidget {
  const _BannerImageFallback();

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF4B78FF), Color(0xFF7367FF)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Align(
        alignment: Alignment.centerRight,
        child: Padding(
          padding: const EdgeInsets.only(right: 26),
          child: Icon(
            HugeIcons.strokeRoundedLaptop,
            color: Colors.white.withValues(alpha: 0.62),
            size: 70,
          ),
        ),
      ),
    );
  }
}

class _HeroDeviceImage extends StatelessWidget {
  const _HeroDeviceImage({
    required this.product,
    required this.width,
    required this.height,
    required this.icon,
    required this.frameColor,
    required this.surfaceColor,
    this.isPhone = false,
  });

  final Product? product;
  final double width;
  final double height;
  final IconData icon;
  final Color frameColor;
  final Color surfaceColor;
  final bool isPhone;

  @override
  Widget build(BuildContext context) {
    final imageUrl = product?.imageUrl;
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(isPhone ? 16 : 18),
        boxShadow: [
          BoxShadow(color: homeShadow, blurRadius: 12, offset: const Offset(0, 8)),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(isPhone ? 16 : 18),
        child: DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [surfaceColor, surfaceColor.withValues(alpha: 0.84)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
            border: Border.all(color: Colors.white),
          ),
          child: imageUrl == null || imageUrl.isEmpty
              ? Center(
                  child: Icon(icon, size: isPhone ? 34 : 58, color: frameColor),
                )
              : Padding(
                  padding: EdgeInsets.all(isPhone ? 10 : 12),
                  child: AppNetworkImage(
                    imageUrl,
                    fit: BoxFit.contain,
                    alignment: Alignment.center,
                    errorWidget: (context, url, error) => Center(
                      child: Icon(
                        icon,
                        size: isPhone ? 34 : 58,
                        color: frameColor,
                      ),
                    ),
                  ),
                ),
        ),
      ),
    );
  }
}

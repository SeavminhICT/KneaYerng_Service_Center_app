import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hugeicons/hugeicons.dart';

import '../../../services/theme_service.dart';
import '../../../theme/app_fonts.dart';
import 'product_detail_tone.dart';

/// Small generic building blocks shared across the product detail screen
/// widgets: icon buttons, badges, section titles, cards, and the
/// image-not-available placeholder.

class ProductDetailIconBtn extends StatelessWidget {
  const ProductDetailIconBtn({
    super.key,
    required this.icon,
    required this.onTap,
    this.iconColor = pdTextPrimaryLight,
    this.bg,
  });

  final IconData    icon;
  final VoidCallback onTap;
  final Color       iconColor;
  final Color?      bg;

  @override
  Widget build(BuildContext context) {
    return Material(
      color:        Colors.transparent,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap:        onTap,
        borderRadius: BorderRadius.circular(12),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          width:  40,
          height: 40,
          decoration: BoxDecoration(
            color:        bg,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, size: 20, color: iconColor),
        ),
      ),
    );
  }
}

class ProductDetailSectionTitle extends StatelessWidget {
  const ProductDetailSectionTitle(
      {super.key, required this.title, required this.tone});

  final String           title;
  final ProductDetailTone tone;

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: kmFont(context, GoogleFonts.inter(
        fontSize:   15,
        fontWeight: FontWeight.w700,
        color:      tone.textPrimary,
      )),
    );
  }
}

class ProductDetailCard extends StatelessWidget {
  const ProductDetailCard({super.key, required this.tone, required this.child});

  final ProductDetailTone tone;
  final Widget            child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width:   double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color:        tone.white,
        borderRadius: BorderRadius.circular(14),
        border:       Border.all(color: tone.border),
        boxShadow: [
          BoxShadow(
            color:      tone.shadow,
            blurRadius: 6,
            offset:     const Offset(0, 1),
          ),
        ],
      ),
      child: child,
    );
  }
}

class ProductDetailBadge extends StatelessWidget {
  const ProductDetailBadge({
    super.key,
    required this.label,
    required this.bg,
    required this.fg,
    this.border,
  });

  final String label;
  final Color  bg;
  final Color  fg;
  final Color? border;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color:        bg,
        borderRadius: BorderRadius.circular(99),
        border:       border != null ? Border.all(color: border!) : null,
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize:   11.5,
          fontWeight: FontWeight.w700,
          color:      fg,
        ),
      ),
    );
  }
}

class ProductDetailStockBadge extends StatelessWidget {
  const ProductDetailStockBadge({
    super.key,
    required this.tone,
    required this.label,
    required this.isOutOfStock,
  });

  final ProductDetailTone tone;
  final String            label;
  final bool              isOutOfStock;

  @override
  Widget build(BuildContext context) {
    final color = isOutOfStock ? pdRed   : pdGreen;
    final bg    = isOutOfStock ? tone.redLight : tone.greenLight;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color:        bg,
        borderRadius: BorderRadius.circular(99),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width:  6,
            height: 6,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 5),
          Text(
            label,
            style: TextStyle(
              fontSize:   11.5,
              fontWeight: FontWeight.w700,
              color:      color,
            ),
          ),
        ],
      ),
    );
  }
}

class ProductDetailImageFallback extends StatelessWidget {
  const ProductDetailImageFallback({super.key, this.size = 32});

  final double size;

  @override
  Widget build(BuildContext context) {
    final isDark = ThemeService.instance.isDark(context);
    return Center(
      child: Icon(
        HugeIcons.strokeRoundedImageNotFound01,
        size:  size,
        color: isDark ? pdTextHintDark : pdTextHintLight,
      ),
    );
  }
}

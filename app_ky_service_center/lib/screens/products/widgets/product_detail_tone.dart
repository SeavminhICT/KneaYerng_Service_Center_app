import 'package:flutter/material.dart';

import '../../../services/theme_service.dart';

// ── Design tokens ──────────────────────────────────────────────────────────
// Each token has a light/dark pair; widgets resolve the active pair via
// `ProductDetailTone.of(context)` instead of referencing the light-only
// constants below.
const pdWhiteLight       = Color(0xFFFFFFFF);
const pdWhiteDark        = Color(0xFF161B22);
const pdSurfaceAltLight  = Color(0xFFF9FAFB);
const pdSurfaceAltDark   = Color(0xFF1D2635);
const pdDividerLight     = Color(0xFFEEF0F4);
const pdDividerDark      = Color(0xFF2B3442);
const pdBorderLight      = Color(0xFFE2E6EF);
const pdBorderDark       = Color(0xFF2B3442);
const pdTextPrimaryLight = Color(0xFF111827);
const pdTextPrimaryDark  = Color(0xFFE6EDF7);
const pdTextSubLight     = Color(0xFF6B7280);
const pdTextSubDark      = Color(0xFF97A2B5);
const pdTextHintLight    = Color(0xFF9CA3AF);
const pdTextHintDark     = Color(0xFF6B7686);
const pdAccent       = Color(0xFF2563EB);
const pdAccentLightLight = Color(0xFFEFF4FF);
const pdAccentLightDark  = Color(0xFF1B2940);
const pdAccentDark   = Color(0xFF60A5FA);
const pdGreen        = Color(0xFF16A34A);
const pdGreenLightLight  = Color(0xFFDCFCE7);
const pdGreenLightDark   = Color(0xFF12331F);
const pdRed          = Color(0xFFDC2626);
const pdRedLightLight    = Color(0xFFFEE2E2);
const pdRedLightDark     = Color(0xFF3B1419);
const pdAmber        = Color(0xFFF59E0B);
const pdAmberBgLight  = Color(0xFFFFF7ED);
const pdAmberBgDark   = Color(0xFF3A2E16);
const pdShadowLight   = Color(0x0A000000);
const pdShadowDark    = Color(0x00000000);
const pdAvatarBgLight = Color(0xFFF3F4F6);
const pdAvatarBgDark  = Color(0xFF222B3A);

/// Resolved color palette for the current brightness, threaded down to
/// every widget on the product detail screen instead of hardcoded
/// light-only colors.
class ProductDetailTone {
  const ProductDetailTone({
    required this.isDark,
    required this.white,
    required this.surfaceAlt,
    required this.divider,
    required this.border,
    required this.textPrimary,
    required this.textSub,
    required this.textHint,
    required this.accentLight,
    required this.greenLight,
    required this.redLight,
    required this.amberBg,
    required this.shadow,
    required this.avatarBg,
  });

  final bool  isDark;
  final Color white;
  final Color surfaceAlt;
  final Color divider;
  final Color border;
  final Color textPrimary;
  final Color textSub;
  final Color textHint;
  final Color accentLight;
  final Color greenLight;
  final Color redLight;
  final Color amberBg;
  final Color shadow;
  final Color avatarBg;

  factory ProductDetailTone.of(BuildContext context) {
    final isDark = ThemeService.instance.isDark(context);
    return ProductDetailTone(
      isDark:      isDark,
      white:       isDark ? pdWhiteDark       : pdWhiteLight,
      surfaceAlt:  isDark ? pdSurfaceAltDark  : pdSurfaceAltLight,
      divider:     isDark ? pdDividerDark     : pdDividerLight,
      border:      isDark ? pdBorderDark      : pdBorderLight,
      textPrimary: isDark ? pdTextPrimaryDark : pdTextPrimaryLight,
      textSub:     isDark ? pdTextSubDark     : pdTextSubLight,
      textHint:    isDark ? pdTextHintDark    : pdTextHintLight,
      accentLight: isDark ? pdAccentLightDark : pdAccentLightLight,
      greenLight:  isDark ? pdGreenLightDark  : pdGreenLightLight,
      redLight:    isDark ? pdRedLightDark    : pdRedLightLight,
      amberBg:     isDark ? pdAmberBgDark     : pdAmberBgLight,
      shadow:      isDark ? pdShadowDark      : pdShadowLight,
      avatarBg:    isDark ? pdAvatarBgDark    : pdAvatarBgLight,
    );
  }
}

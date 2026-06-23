import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Returns KantumruyPro when the locale is Khmer, otherwise Sora.
///
/// **Khmer colour rule**: KantumruyPro glyphs need full contrast to stay
/// ច្បាស់ (legible). By default the passed [color] is **ignored** for Khmer
/// and solid black (light-mode) / white (dark-mode) is used instead.
///
/// Set [forceColor] to `true` only when a specific colour absolutely must
/// render on Khmer text (e.g. countdown timer red, payment-error red).
TextStyle kFont(
  BuildContext context, {
  double? fontSize,
  FontWeight? fontWeight,
  Color? color,
  double? letterSpacing,
  double? height,
  FontStyle? fontStyle,
  TextDecoration? decoration,
  Color? decorationColor,
  /// When true, [color] is applied even on Khmer text.
  bool forceColor = false,
}) {
  final isKhmer = Localizations.localeOf(context).languageCode == 'km';
  if (isKhmer) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    // Always enforce solid 0xFF0A0000/white for Khmer unless the caller
    // explicitly opts into a custom colour via forceColor.
    final effectiveColor = forceColor
        ? (color ?? (isDark ? Colors.white : const Color(0xFF0A0000)))
        : (isDark ? Colors.white : const Color(0xFF0A0000));
    return TextStyle(
      fontFamily: 'KantumruyPro',
      package: null,
      fontSize: fontSize,
      fontWeight: FontWeight.w600,
      color: effectiveColor,
      letterSpacing: letterSpacing,
      height: height ?? 1.6,   // Khmer needs a bit more line-height to breathe
      fontStyle: fontStyle,
      decoration: decoration,
      decorationColor: decorationColor,
    );
  }
  return GoogleFonts.sora(
    fontSize: fontSize,
    fontWeight: fontWeight,
    color: color,
    letterSpacing: letterSpacing,
    height: height,
    fontStyle: fontStyle,
    decoration: decoration,
    decorationColor: decorationColor,
  );
}

/// Wraps a Latin TextStyle (e.g. `GoogleFonts.manrope(...)`, `GoogleFonts.inter(...)`,
/// a raw `TextStyle(fontFamily: 'SF Pro Text', ...)`) so Khmer locale always
/// renders with the single KantumruyPro font instead of whatever Latin font
/// the call site hardcoded. English/Latin locales are returned unchanged.
///
/// Use this at call sites that build a font-specific [TextStyle] directly
/// (rather than going through [kFont]) so Khmer text never mixes fonts
/// across screens.
TextStyle kmFont(
  BuildContext context,
  TextStyle latinStyle, {
  bool forceColor = false,
}) {
  final isKhmer = Localizations.localeOf(context).languageCode == 'km';
  if (!isKhmer) return latinStyle;

  final isDark = Theme.of(context).brightness == Brightness.dark;
  final fallbackColor = isDark ? Colors.white : const Color(0xFF0A0000);
  final effectiveColor = forceColor ? (latinStyle.color ?? fallbackColor) : fallbackColor;

  return latinStyle.copyWith(
    fontFamily: 'KantumruyPro',
    fontFamilyFallback: const [],
    color: effectiveColor,
    fontWeight: FontWeight.w600,
    height: latinStyle.height ?? 1.6,
  );
}

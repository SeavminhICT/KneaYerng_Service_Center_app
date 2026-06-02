import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Returns KantumruyPro when the locale is Khmer, otherwise Sora.
/// Color defaults to black (light) or white (dark) when not specified.
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
}) {
  final isKhmer = Localizations.localeOf(context).languageCode == 'km';
  if (isKhmer) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return TextStyle(
      fontFamily: 'KantumruyPro',
      package: null,
      fontSize: fontSize,
      fontWeight: fontWeight ?? FontWeight.w600,
      color: color ?? (isDark ? Colors.white : Colors.black),
      letterSpacing: letterSpacing,
      height: height,
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

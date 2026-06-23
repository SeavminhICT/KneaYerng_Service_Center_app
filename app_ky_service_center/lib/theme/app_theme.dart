import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  AppTheme._();

  static const Color primary = Color(0xFF4A6CF7);

  static const _khmerFont = 'KantumruyPro';

  static TextStyle _khmer(
    TextStyle? base, {
    required FontWeight weight,
    required Color textColor,
  }) {
    return (base ?? const TextStyle()).copyWith(
      fontFamily: _khmerFont,
      fontFamilyFallback: const [],
      color: textColor,
      fontWeight: weight,
    );
  }

  static TextTheme _buildTextTheme(
    TextTheme base, {
    required bool isKhmer,
    required bool isDark,
  }) {
    if (isKhmer) {
      final onBackground = isDark ? Colors.white : Colors.black87;
      final onSurface    = isDark ? Colors.white : Colors.black87;
      return base.copyWith(
        displayLarge:  _khmer(base.displayLarge,  weight: FontWeight.w700, textColor: onBackground),
        displayMedium: _khmer(base.displayMedium, weight: FontWeight.w700, textColor: onBackground),
        displaySmall:  _khmer(base.displaySmall,  weight: FontWeight.w700, textColor: onBackground),
        headlineLarge:  _khmer(base.headlineLarge,  weight: FontWeight.w700, textColor: onBackground),
        headlineMedium: _khmer(base.headlineMedium, weight: FontWeight.w700, textColor: onBackground),
        headlineSmall:  _khmer(base.headlineSmall,  weight: FontWeight.w700, textColor: onBackground),
        titleLarge:  _khmer(base.titleLarge,  weight: FontWeight.w600, textColor: onSurface),
        titleMedium: _khmer(base.titleMedium, weight: FontWeight.w600, textColor: onSurface),
        titleSmall:  _khmer(base.titleSmall,  weight: FontWeight.w600, textColor: onSurface),
        bodyLarge:  _khmer(base.bodyLarge,  weight: FontWeight.w500, textColor: onSurface),
        bodyMedium: _khmer(base.bodyMedium, weight: FontWeight.w500, textColor: onSurface),
        bodySmall:  _khmer(base.bodySmall,  weight: FontWeight.w500, textColor: onSurface),
        labelLarge:  _khmer(base.labelLarge,  weight: FontWeight.w600, textColor: onSurface),
        labelMedium: _khmer(base.labelMedium, weight: FontWeight.w600, textColor: onSurface),
        labelSmall:  _khmer(base.labelSmall,  weight: FontWeight.w600, textColor: onSurface),
      );
    }
    return GoogleFonts.soraTextTheme(base);
  }

  static ThemeData light({Locale? locale}) {
    final isKhmer = locale?.languageCode == 'km';
    final colorScheme = ColorScheme.fromSeed(
      seedColor: primary,
      brightness: Brightness.light,
    );

    final base = ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: const Color(0xFFEEF6FD),
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFFEEF6FD),
        surfaceTintColor: Colors.transparent,
        elevation: 0,
      ),
      cardColor: Colors.white,
      dividerColor: const Color(0xFFE6ECF5),
      splashFactory: InkRipple.splashFactory,
    );

    return base.copyWith(
      textTheme: _buildTextTheme(base.textTheme, isKhmer: isKhmer, isDark: false),
    );
  }

  static ThemeData dark({Locale? locale}) {
    final isKhmer = locale?.languageCode == 'km';
    final colorScheme = ColorScheme.fromSeed(
      seedColor: primary,
      brightness: Brightness.dark,
    );

    final base = ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: const Color(0xFF0F172A),
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFF0F172A),
        surfaceTintColor: Colors.transparent,
        elevation: 0,
      ),
      cardColor: const Color(0xFF161B22),
      dividerColor: const Color(0xFF2B3442),
      splashFactory: InkRipple.splashFactory,
    );

    return base.copyWith(
      textTheme: _buildTextTheme(base.textTheme, isKhmer: isKhmer, isDark: true),
    );
  }
}

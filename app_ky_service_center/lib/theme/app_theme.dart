import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  AppTheme._();

  static const Color primary = Color(0xFF4A6CF7);

  static ThemeData get light {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: primary,
      brightness: Brightness.light,
    );

    final base = ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: const Color(0xFFF8F9FB),
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFFF8F9FB),
        surfaceTintColor: Colors.transparent,
        elevation: 0,
      ),
      cardColor: Colors.white,
      dividerColor: const Color(0xFFE6ECF5),
      splashFactory: InkRipple.splashFactory,
    );

    return base.copyWith(
      textTheme: GoogleFonts.interTextTheme(base.textTheme),
    );
  }

  static ThemeData get dark {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: primary,
      brightness: Brightness.dark,
    );

    final base = ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: const Color(0xFF0D1117),
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFF0D1117),
        surfaceTintColor: Colors.transparent,
        elevation: 0,
      ),
      cardColor: const Color(0xFF161B22),
      dividerColor: const Color(0xFF2B3442),
      splashFactory: InkRipple.splashFactory,
    );

    return base.copyWith(
      textTheme: GoogleFonts.interTextTheme(base.textTheme),
    );
  }
}

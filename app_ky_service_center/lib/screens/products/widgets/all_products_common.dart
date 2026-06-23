import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// Shared design tokens and formatters used across the all-products screen
/// widgets. Kept local to this screen (not the themed ProductDetailTone)
/// since all_products_screen.dart does not yet support dark-mode theming.
const apSurface = Color(0xFFFFFFFF);
const apSurfaceAlt = Color(0xFFF1F5F9);
const apBorder = Color(0xFFE2E8F0);
const apTextPrimary = Color(0xFF0F172A);
const apTextMuted = Color(0xFF64748B);
const apBrandBlue = Color(0xFF0F6BFF);
const apSuccess = Color(0xFF0F9D58);
const apWarning = Color(0xFFF59E0B);
const apDanger = Color(0xFFDC2626);
const apShadow = Color(0x140F172A);

final NumberFormat apCurrencyFormat = NumberFormat.currency(symbol: '\$');

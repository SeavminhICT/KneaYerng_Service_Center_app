import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// Shared design tokens for the search results screen UI pieces.
///
/// Extracted from search_results_screen.dart so the split-out widget files
/// can share the exact same look without duplicating these constants.
const Color searchBg = Color(0xFFF4F6FB);
const Color searchSurface = Colors.white;
const Color searchBorder = Color(0xFFE8EDF5);
const Color searchInk = Color(0xFF0F172A);
const Color searchMuted = Color(0xFF64748B);
const Color searchBlue = Color(0xFF2563EB);
const Color searchBlueLight = Color(0xFFEEF4FF);
const Color searchRed = Color(0xFFDC2626);
const Color searchShadow = Color(0x10172554);

final NumberFormat searchCurrency =
    NumberFormat.currency(symbol: '\$', decimalDigits: 2);

import 'package:flutter/material.dart';

/// Shared design tokens for the cart screen UI pieces.
///
/// Extracted from cart_screen.dart so the split-out widget files can share
/// the exact same look without duplicating these constants.
const Color cartBg          = Color(0xFFF2F4F8);   // page background
const Color cartSurface     = Color(0xFFFFFFFF);   // card surface
const Color cartSurfaceSoft = Color(0xFFF7F9FF);   // input fill / soft accent
const Color cartBorder      = Color(0xFFE4EAF4);   // very light border (used sparingly)
const Color cartInk         = Color(0xFF1A2845);   // primary text
const Color cartMuted       = Color(0xFF8896B0);   // secondary text
const Color cartPrimaryDeep = Color(0xFF4B6CF7);   // CTA / accent
const Color cartPrimarySoft = Color(0xFFEBEEFF);   // light tint
const Color cartDanger      = Color(0xFFE05572);   // error / price
const Color cartSuccess     = Color(0xFF27A96C);   // free / applied

const Color cartShadow = Color(0x10243B6A);        // subtle shadow

String cartCurrency(double v) => '\$${v.toStringAsFixed(2)}';

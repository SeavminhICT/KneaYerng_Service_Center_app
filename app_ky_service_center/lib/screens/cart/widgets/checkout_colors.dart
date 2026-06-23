import 'package:flutter/material.dart';

/// Shared color palette and helpers for the checkout flow UI pieces.
///
/// Extracted from checkout_flow_screen.dart so the split-out widget files
/// can share the exact same look without duplicating these helpers.
const Color kCheckoutPrimary = Color(0xFF4A88F7);
const Color kCheckoutSuccess = Color(0xFF15803D);

bool isCheckoutDark(BuildContext c) =>
    Theme.of(c).brightness == Brightness.dark;

Color checkoutSurface(BuildContext c) =>
    isCheckoutDark(c) ? const Color(0xFF1C2333) : const Color(0xFFFFFFFF);

Color checkoutSurfaceAlt(BuildContext c) =>
    isCheckoutDark(c) ? const Color(0xFF252E42) : const Color(0xFFF3F4F6);

Color checkoutBorder(BuildContext c) =>
    isCheckoutDark(c) ? const Color(0xFF2D3A52) : const Color(0xFFE7ECF4);

Color checkoutInk(BuildContext c) =>
    isCheckoutDark(c) ? const Color(0xFFE2E8F0) : const Color(0xFF111827);

Color checkoutMuted(BuildContext c) =>
    isCheckoutDark(c) ? const Color(0xFF8896B0) : const Color(0xFF6B7280);

Color checkoutShadow(BuildContext c) =>
    isCheckoutDark(c) ? const Color(0x26000000) : const Color(0x0A111827);

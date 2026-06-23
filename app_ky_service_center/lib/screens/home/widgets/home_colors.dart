import 'package:flutter/material.dart';

/// Shared color tokens and brightness-aware helpers used across the home
/// screen widgets. Kept identical to the previous in-file private
/// constants so extracting widgets does not change any visuals.
const Color homeSurfaceLight = Color(0xFFFFFFFF);
const Color homeSurfaceDark = Color(0xFF161B22);
const Color homeSurfaceAltLight = Color(0xFFF1F4FA);
const Color homeSurfaceAltDark = Color(0xFF1D2635);
const Color homeCardBorderLight = Color(0xFFE5EAF2);
const Color homeCardBorderDark = Color(0xFF2B3442);
const Color homePrimary = Color(0xFF3B63FF);
const Color homePrimarySoft = Color(0xFFEAF0FF);
const Color homeTextPrimaryLight = Color(0xFF111827);
const Color homeTextPrimaryDark = Color(0xFFE6EDF7);
const Color homeTextMutedLight = Color(0xFF667085);
const Color homeTextMutedDark = Color(0xFF97A2B5);
const Color homeHeroBlue = Color(0xFF5383FF);
const Color homeHeroPurple = Color(0xFF7367FF);
const Color homeHeroLight = Color(0xFFF1F4FF);
const Color homeSuccess = Color(0xFF16A34A);
const Color homeDanger = Color(0xFFDC2626);
const Color homeShadow = Color(0x140F172A);

bool homeIsDark(BuildContext context) =>
    Theme.of(context).brightness == Brightness.dark;

Color homeBg(BuildContext context) =>
    Theme.of(context).scaffoldBackgroundColor;

Color homeSurface(BuildContext context) =>
    homeIsDark(context) ? homeSurfaceDark : homeSurfaceLight;

Color homeSurfaceAlt(BuildContext context) =>
    homeIsDark(context) ? homeSurfaceAltDark : homeSurfaceAltLight;

Color homeCardBorder(BuildContext context) =>
    homeIsDark(context) ? homeCardBorderDark : homeCardBorderLight;

Color homeTextPrimary(BuildContext context) =>
    homeIsDark(context) ? homeTextPrimaryDark : homeTextPrimaryLight;

Color homeTextMuted(BuildContext context) =>
    homeIsDark(context) ? homeTextMutedDark : homeTextMutedLight;

List<Color> homeGradient(BuildContext context) => homeIsDark(context)
    ? const [Color(0xFF0D1117), Color(0xFF111826), Color(0xFF0D1117)]
    : const [Color(0xFFF9FAFD), Color(0xFFF5F7FB), Color(0xFFF9FAFD)];

import 'package:flutter/material.dart';

/// Shared color tokens and brightness-aware helpers used across the profile
/// screen widgets. Kept identical to the previous in-file private constants
/// so extracting widgets does not change any visuals.
const Color profileBrandBlue = Color(0xFF4A88F7);
const Color profileBrandPeach = Color(0xFFEAF1FF);
const Color profileSurfaceLight = Colors.white;
const Color profileSurfaceDark = Color(0xFF161B22);
const Color profileSurfaceAltLight = Color(0xFFF6F9FF);
const Color profileSurfaceAltDark = Color(0xFF1D2635);
const Color profileBorderLight = Color(0xFFE6ECF5);
const Color profileBorderDark = Color(0xFF2B3442);
const Color profileTextPrimaryLight = Color(0xFF111827);
const Color profileTextPrimaryDark = Color(0xFFE6EDF7);
const Color profileTextMutedLight = Color(0xFF6B7280);
const Color profileTextMutedDark = Color(0xFF97A2B5);
const Color profileHeroStart = Color(0xFF4A88F7);
const Color profileHeroEnd = Color(0xFF96B5F2);
const Color profileDanger = Color(0xFFE65054);

bool profileIsDark(BuildContext context) =>
    Theme.of(context).brightness == Brightness.dark;

Color profileSurface(BuildContext context) =>
    profileIsDark(context) ? profileSurfaceDark : profileSurfaceLight;

Color profileSurfaceAlt(BuildContext context) =>
    profileIsDark(context) ? profileSurfaceAltDark : profileSurfaceAltLight;

Color profileBorder(BuildContext context) =>
    profileIsDark(context) ? profileBorderDark : profileBorderLight;

Color profileTextPrimary(BuildContext context) =>
    profileIsDark(context) ? profileTextPrimaryDark : profileTextPrimaryLight;

Color profileTextMuted(BuildContext context) =>
    profileIsDark(context) ? profileTextMutedDark : profileTextMutedLight;

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hugeicons/hugeicons.dart';

import '../../../theme/app_fonts.dart';
import 'home_colors.dart';

/// Row with a section title and an optional "View all"-style trailing
/// action, used above each home screen content section.
class HomeSectionHeader extends StatelessWidget {
  const HomeSectionHeader({
    super.key,
    required this.title,
    this.actionLabel,
    this.onTap,
  });

  final String title;
  final String? actionLabel;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          title,
          style: kmFont(context, GoogleFonts.manrope(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: homeTextPrimary(context),
          )),
        ),
        const Spacer(),
        if (actionLabel != null && onTap != null)
          GestureDetector(
            onTap: onTap,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  actionLabel!,
                  style: kmFont(context, GoogleFonts.manrope(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: homePrimary,
                  )),
                ),
                const SizedBox(width: 2),
                const Icon(
                  HugeIcons.strokeRoundedArrowRight01,
                  size: 11,
                  color: homePrimary,
                ),
              ],
            ),
          ),
      ],
    );
  }
}

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hugeicons/hugeicons.dart';

import '../../../theme/app_fonts.dart';
import 'home_colors.dart';

/// Tappable search bar shown beneath the home header. Tapping opens the
/// full search results screen (handled by the caller via [onTap]).
class HomeSearchInput extends StatelessWidget {
  const HomeSearchInput({
    super.key,
    required this.hintText,
    required this.onTap,
  });

  final String hintText;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: homeSurface(context),
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          decoration: BoxDecoration(
            color: homeSurface(context),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: homeCardBorder(context)),
            boxShadow: const [
              BoxShadow(color: homeShadow, blurRadius: 6, offset: Offset(0, 2)),
            ],
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              Icon(
                HugeIcons.strokeRoundedSearch01,
                color: homeTextMuted(context),
                size: 22,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  hintText,
                  style: kmFont(context, GoogleFonts.manrope(
                    fontSize: 14,
                    color: homeTextMuted(context),
                    fontWeight: FontWeight.w500,
                  )),
                ),
              ),
              Icon(
                HugeIcons.strokeRoundedFilterHorizontal,
                color: homeTextMuted(context),
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

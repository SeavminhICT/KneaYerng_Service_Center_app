import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../theme/app_fonts.dart';
import 'profile_colors.dart';

/// Simple title + subtitle heading used above the quick-actions and
/// settings sections of the profile screen.
class ProfileSectionHeader extends StatelessWidget {
  const ProfileSectionHeader({
    super.key,
    required this.title,
    required this.subtitle,
  });

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: kmFont(context, GoogleFonts.poppins(
            color: profileTextPrimary(context),
            fontSize: 18,
            fontWeight: FontWeight.w600,
          )),
        ),
        const SizedBox(height: 4),
        Text(
          subtitle,
          style: kmFont(context, GoogleFonts.inter(
            color: profileTextMuted(context),
            fontSize: 13,
            fontWeight: FontWeight.w500,
          )),
        ),
      ],
    );
  }
}

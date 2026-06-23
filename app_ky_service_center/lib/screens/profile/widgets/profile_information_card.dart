import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hugeicons/hugeicons.dart';
import '../../../theme/app_fonts.dart';
import 'profile_colors.dart';

/// Card listing phone number, ID number, rank and location details for the
/// signed-in user, with placeholder prompts for missing fields.
class ProfileInformationCard extends StatelessWidget {
  const ProfileInformationCard({
    super.key,
    required this.phone,
    required this.profileId,
    required this.rank,
    required this.location,
  });

  final String? phone;
  final String? profileId;
  final String rank;
  final String? location;

  @override
  Widget build(BuildContext context) {
    final hasPhone = phone != null && phone!.trim().isNotEmpty;
    final hasId = profileId != null;
    final hasLocation = location != null;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: profileSurface(context),
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Color(0x120F172A),
            blurRadius: 18,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          ProfileDetailRow(
            icon: HugeIcons.strokeRoundedSmartPhone01,
            title: 'Phone Number',
            value: hasPhone ? phone! : '+ Add phone number',
            isEmpty: !hasPhone,
          ),
          const SizedBox(height: 16),
          ProfileDetailRow(
            icon: HugeIcons.strokeRoundedIdVerified,
            title: 'ID Number',
            value: hasId ? profileId! : 'Not assigned yet',
            isEmpty: !hasId,
          ),
          const SizedBox(height: 16),
          ProfileDetailRow(
            icon: HugeIcons.strokeRoundedMedal01,
            title: 'Rank',
            value: rank,
            isEmpty: false,
          ),
          const SizedBox(height: 16),
          ProfileDetailRow(
            icon: HugeIcons.strokeRoundedLocation01,
            title: 'Location',
            value: hasLocation ? location! : '+ Add location',
            isEmpty: !hasLocation,
          ),
        ],
      ),
    );
  }
}

/// A single labeled row used inside [ProfileInformationCard], showing an
/// icon, title and value, with a muted "empty" style when the value is a
/// placeholder prompt.
class ProfileDetailRow extends StatelessWidget {
  const ProfileDetailRow({
    super.key,
    required this.icon,
    required this.title,
    required this.value,
    this.isEmpty = false,
  });

  final IconData icon;
  final String title;
  final String value;
  final bool isEmpty;

  @override
  Widget build(BuildContext context) {
    final textMuted = profileTextMuted(context);
    final textPrimary = profileTextPrimary(context);
    return Row(
      children: [
        Container(
          height: 42,
          width: 42,
          decoration: BoxDecoration(
            color: isEmpty ? const Color(0xFFF0F5FF) : profileSurfaceAlt(context),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            icon,
            color: isEmpty
                ? profileBrandBlue.withValues(alpha: 0.5)
                : profileBrandBlue,
            size: 20,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: kmFont(context, GoogleFonts.inter(
                  color: textMuted,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                )),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: kmFont(context, GoogleFonts.inter(
                  color: isEmpty
                      ? profileBrandBlue.withValues(alpha: 0.7)
                      : textPrimary,
                  fontSize: isEmpty ? 13 : 15,
                  fontWeight: isEmpty ? FontWeight.w500 : FontWeight.w600,
                  fontStyle: isEmpty ? FontStyle.normal : FontStyle.normal,
                )),
              ),
            ],
          ),
        ),
        if (isEmpty)
          Icon(
            HugeIcons.strokeRoundedArrowRight01,
            color: profileBrandBlue.withValues(alpha: 0.4),
            size: 18,
          ),
      ],
    );
  }
}

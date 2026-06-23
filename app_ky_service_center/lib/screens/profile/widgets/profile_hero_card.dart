import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hugeicons/hugeicons.dart';
import '../../../widgets/app_network_image.dart';
import '../../../theme/app_fonts.dart';
import 'profile_colors.dart';

/// Gradient hero card showing the avatar, name, status subtitle and the
/// theme-toggle / edit-profile action buttons at the top of the profile
/// screen.
class ProfileHeroCard extends StatelessWidget {
  const ProfileHeroCard({
    super.key,
    required this.isDarkMode,
    required this.name,
    required this.subtitle,
    required this.initials,
    required this.avatarUrl,
    required this.uploadingAvatar,
    required this.onToggleTheme,
    required this.onEditProfile,
    required this.onChangePhoto,
  });

  final bool isDarkMode;
  final String name;
  final String subtitle;
  final String initials;
  final String? avatarUrl;
  final bool uploadingAvatar;
  final VoidCallback onToggleTheme;
  final VoidCallback onEditProfile;
  final VoidCallback onChangePhoto;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 22),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [profileHeroStart, profileHeroEnd],
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x224A88F7),
            blurRadius: 24,
            offset: Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              _HeaderActionButton(
                icon: isDarkMode
                    ? HugeIcons.strokeRoundedSun01
                    : HugeIcons.strokeRoundedMoon01,
                tooltip: isDarkMode
                    ? 'Switch to Light Mode'
                    : 'Switch to Dark Mode',
                onTap: onToggleTheme,
              ),
              const Spacer(),
              _HeaderActionButton(
                icon: HugeIcons.strokeRoundedEdit02,
                onTap: onEditProfile,
              ),
            ],
          ),
          const SizedBox(height: 14),
          Container(
            height: 96,
            width: 96,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: const [
                BoxShadow(
                  color: Color(0x33000000),
                  blurRadius: 18,
                  offset: Offset(0, 10),
                ),
              ],
            ),
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                _HeroAvatar(initials: initials, avatarUrl: avatarUrl),
                Positioned(
                  right: 2,
                  bottom: 2,
                  child: InkWell(
                    onTap: uploadingAvatar ? null : onChangePhoto,
                    borderRadius: BorderRadius.circular(999),
                    child: Container(
                      height: 28,
                      width: 28,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(999),
                        border: Border.all(color: Colors.white),
                      ),
                      child: uploadingAvatar
                          ? const Padding(
                              padding: EdgeInsets.all(6),
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  profileBrandBlue,
                                ),
                              ),
                            )
                          : const Icon(
                              HugeIcons.strokeRoundedCamera01,
                              size: 15,
                              color: profileBrandBlue,
                            ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Text(
            name,
            textAlign: TextAlign.center,
            style: kmFont(context, GoogleFonts.poppins(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.w700,
            )),
          ),
          const SizedBox(height: 6),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: kmFont(context, GoogleFonts.inter(
              color: Colors.white.withAlpha((0.92 * 255).round()),
              fontSize: 13,
              fontWeight: FontWeight.w500,
            )),
          ),
        ],
      ),
    );
  }
}

class _HeaderActionButton extends StatelessWidget {
  const _HeaderActionButton({
    required this.icon,
    required this.onTap,
    this.tooltip,
  });

  final IconData icon;
  final VoidCallback onTap;
  final String? tooltip;

  @override
  Widget build(BuildContext context) {
    final button = Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(999),
        child: Container(
          height: 40,
          width: 40,
          decoration: BoxDecoration(
            color: Colors.white.withAlpha((0.18 * 255).round()),
            borderRadius: BorderRadius.circular(999),
            border: Border.all(
              color: Colors.white.withAlpha((0.20 * 255).round()),
            ),
          ),
          child: Icon(icon, color: Colors.white, size: 20),
        ),
      ),
    );

    if (tooltip == null || tooltip!.trim().isEmpty) return button;
    return Tooltip(message: tooltip!, child: button);
  }
}

class _HeroAvatar extends StatelessWidget {
  const _HeroAvatar({
    required this.initials,
    required this.avatarUrl,
  });

  final String initials;
  final String? avatarUrl;

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      radius: 48,
      backgroundColor: Colors.white,
      child: ClipOval(
        child: SizedBox.expand(
          child: _AvatarImage(
            avatarUrl: avatarUrl,
            fallback: Container(
              color: Colors.white,
              alignment: Alignment.center,
              child: Text(
                initials,
                style: kmFont(context, GoogleFonts.inter(
                  color: profileBrandBlue,
                  fontSize: 30,
                  fontWeight: FontWeight.w800,
                )),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _AvatarImage extends StatelessWidget {
  const _AvatarImage({
    required this.avatarUrl,
    required this.fallback,
  });

  final String? avatarUrl;
  final Widget fallback;

  @override
  Widget build(BuildContext context) {
    final normalizedUrl = avatarUrl?.trim();
    if (normalizedUrl == null || normalizedUrl.isEmpty) {
      return fallback;
    }

    return AppNetworkImage(
      normalizedUrl,
      fit: BoxFit.cover,
      errorWidget: (context, _, error) => fallback,
    );
  }
}

import 'package:flutter/material.dart';
import '../../models/user_profile.dart';
import 'personal_info_screen.dart';

class EditProfileScreen extends StatelessWidget {
  final UserProfile profile;

  const EditProfileScreen({super.key, required this.profile});

  @override
  Widget build(BuildContext context) {
    const brandBlue = Color(0xFF1E5EFF);
    const brandMint = Color(0xFF00C2A8);
    const brandPeach = Color(0xFFFFB870);
    const canvas = Color(0xFFF6F7FB);

    return Scaffold(
      backgroundColor: canvas,
      appBar: AppBar(
        title: const Text(
          'Edit Profile',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.2,
            color: Colors.black87,
          ),
        ),
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.black87,
        elevation: 0,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFEAF2FF), Color(0xFFFFF2E5)],
          ),
        ),
        child: SafeArea(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
            children: [
              _animatedEntry(
                0,
                _profileCard(
                  profile,
                  brandBlue,
                ),
              ),
              const SizedBox(height: 20),
              _animatedEntry(1, _sectionTitle('Profile')),
              const SizedBox(height: 8),
              _animatedEntry(
                2,
                _item(
                  title: 'Personal Information',
                  subtitle: 'Name, birthday, and gender',
                  icon: Icons.badge_outlined,
                  color: brandBlue,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => PersonalInfoScreen(profile: profile),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 16),
              _animatedEntry(4, _accentRow(brandMint, brandPeach)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _profileCard(UserProfile profile, Color accent) {
    final name = profile.displayName.isNotEmpty ? profile.displayName : 'User';
    final email = profile.email ?? 'No email';
    final avatarUrl = profile.avatarUrl;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: const [
          BoxShadow(color: Color(0x1A1E2A78), blurRadius: 16, offset: Offset(0, 8)),
        ],
      ),
      child: Row(
        children: [
          InkWell(
            borderRadius: BorderRadius.circular(40),
            onTap: () {
              // TODO: image picker later
            },
            child: Container(
              height: 64,
              width: 64,
              decoration: BoxDecoration(
                color: accent.withAlpha((0.12 * 255).round()),
                shape: BoxShape.circle,
              ),
              child: CircleAvatar(
                radius: 30,
                backgroundColor: accent,
                backgroundImage: avatarUrl != null ? NetworkImage(avatarUrl) : null,
                child: avatarUrl == null
                    ? const Icon(Icons.person, size: 30, color: Colors.white)
                    : null,
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(email, style: TextStyle(color: Colors.grey.shade600)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Text(
      title.toUpperCase(),
      style: const TextStyle(
        fontSize: 12,
        letterSpacing: 1.1,
        fontWeight: FontWeight.w700,
        color: Colors.black54,
      ),
    );
  }

  Widget _item({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(color: Color(0x0F1E2A78), blurRadius: 10, offset: Offset(0, 6)),
        ],
      ),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: color.withAlpha((0.12 * 255).round()),
          child: Icon(icon, color: color),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }

  Widget _accentRow(Color mint, Color peach) {
    return Row(
      children: [
        Expanded(
          child: Container(
            height: 6,
            decoration: BoxDecoration(
              color: mint,
              borderRadius: BorderRadius.circular(6),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Container(
            height: 6,
            decoration: BoxDecoration(
              color: peach,
              borderRadius: BorderRadius.circular(6),
            ),
          ),
        ),
      ],
    );
  }

  Widget _animatedEntry(int index, Widget child) {
    final duration = Duration(milliseconds: 280 + (index * 70));
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: duration,
      curve: Curves.easeOutCubic,
      builder: (context, value, widget) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, (1 - value) * 12),
            child: widget,
          ),
        );
      },
      child: child,
    );
  }
}

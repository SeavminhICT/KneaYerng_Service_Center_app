import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../services/api_service.dart';
import '../Auth/login_screen.dart';
import '../../models/user_profile.dart';
import 'edit_profile_screen.dart';



class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late Future<UserProfile?> _profileFuture;

  bool _loggingOut = false;
  bool _uploadingAvatar = false;


  @override
  void initState() {
    super.initState();
    _profileFuture = ApiService.getUserProfile();
  }

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
          "Profile",
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
        actions: [
          IconButton(icon: const Icon(Icons.more_vert), onPressed: () {}),
        ],
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
          child: FutureBuilder<UserProfile?>(
            future: _profileFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState != ConnectionState.done) {
                return const Center(child: CircularProgressIndicator());
              }
              if (!snapshot.hasData) {
                return _emptyState(brandBlue);
              }
              final profile = snapshot.data!;
              return _profileView(profile, brandBlue, brandMint, brandPeach);
            },
          ),
        ),
      ),
    );
  }

  Widget _profileView(
    UserProfile profile,
    Color brandBlue,
    Color brandMint,
    Color brandPeach,
  ) {
    return RefreshIndicator(
      color: brandBlue,
      onRefresh: _refreshProfile,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
        _animatedEntry(
          0,
          _profileHeader(
            profile,
            brandBlue,
            onChangePhoto: () => _handleChangePhoto(profile),
          ),
        ),
          const SizedBox(height: 20),
          _animatedEntry(1, _sectionTitle("Account")),
          _animatedEntry(
            2,
            _profileItem(
              icon: Icons.person_outline,
              title: "Edit Profile",
              subtitle: "Account information",
              color: brandBlue,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => EditProfileScreen(profile: profile),
                  ),
                );
              },
            ),
          ),
          _animatedEntry(
            3,
            _profileItem(
              icon: Icons.location_on_outlined,
              title: "Address Management",
              subtitle: "Manage your addresses",
              color: brandMint,
            ),
          ),
          _animatedEntry(
            4,
            _profileItem(
              icon: Icons.security_outlined,
              title: "Security Settings",
              subtitle: "Password & security",
              color: const Color(0xFFFF6B6B),
            ),
          ),
          const SizedBox(height: 10),
          _animatedEntry(5, _sectionTitle("Orders")),
          _animatedEntry(
            6,
            _profileItem(
              icon: Icons.receipt_long_outlined,
              title: "Order History",
              subtitle: "Your past orders",
              color: const Color(0xFF7C5CFF),
            ),
          ),
          _animatedEntry(
            7,
            _profileItem(
              icon: Icons.report_outlined,
              title: "Report History",
              subtitle: "Service reports",
              color: brandPeach,
            ),
          ),
          const SizedBox(height: 10),
          _animatedEntry(8, _sectionTitle("Settings")),
          _animatedEntry(
            9,
            _profileItem(
              icon: Icons.settings_outlined,
              title: "Language & App Settings",
              subtitle: "Preferences and notifications",
              color: const Color(0xFF00C2C7),
            ),
          ),
          _animatedEntry(
            10,
            _profileItem(
              icon: Icons.logout,
              title: "Logout",
              subtitle: "Sign out of your account",
              color: const Color(0xFFEA5455),
              showChevron: false,
              onTap: _handleLogout,
            ),
          ),
          const SizedBox(height: 16),
          _animatedEntry(11, _accentRow(brandMint, brandPeach)),
        ],
      ),
    );
  }

  Widget _profileHeader(
    UserProfile profile,
    Color accent, {
    required VoidCallback onChangePhoto,
  }) {
    final name = profile.displayName.isNotEmpty ? profile.displayName : "User";
    final email = profile.email ?? "No email";
    final initials = _initialsFrom(name, email);
    final avatarUrl = profile.avatarUrl?.isNotEmpty == true
        ? profile.avatarUrl
        : null;

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
          Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                height: 56,
                width: 56,
                decoration: BoxDecoration(
                  color: accent.withAlpha((0.12 * 255).round()),
                  shape: BoxShape.circle,
                ),
                child: CircleAvatar(
                  radius: 26,
                  backgroundColor: accent,
                  backgroundImage:
                      avatarUrl != null ? NetworkImage(avatarUrl) : null,
                  child: avatarUrl == null
                      ? Text(
                          initials,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        )
                      : null,
                ),
              ),
              Positioned(
                right: -2,
                bottom: -2,
                child: InkWell(
                  onTap: _uploadingAvatar ? null : onChangePhoto,
                  borderRadius: BorderRadius.circular(20),
                  child: Container(
                    height: 22,
                    width: 22,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.black12),
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0x22000000),
                          blurRadius: 4,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: _uploadingAvatar
                        ? const Padding(
                            padding: EdgeInsets.all(4),
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(
                            Icons.edit_rounded,
                            size: 14,
                            color: Colors.black54,
                          ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(width: 12),
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

  Widget _sectionTitle(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Text(
        text.toUpperCase(),
        style: const TextStyle(
          fontSize: 12,
          letterSpacing: 1.1,
          fontWeight: FontWeight.w700,
          color: Colors.black54,
        ),
      ),
    );
  }

  Widget _profileItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    bool showChevron = true,
    VoidCallback? onTap,
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
        trailing: showChevron
            ? const Icon(Icons.chevron_right, color: Colors.grey)
            : null,
        onTap: onTap,
      ),
    );
  }

  Widget _emptyState(Color brandBlue) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              height: 72,
              width: 72,
              decoration: BoxDecoration(
                color: brandBlue.withAlpha((0.12 * 255).round()),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.person_outline, size: 34, color: brandBlue),
            ),
            const SizedBox(height: 12),
            const Text(
              "No profile data found",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 6),
            const Text(
              "Please register or login to see your profile.",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const LoginScreen()),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: brandBlue,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  elevation: 0,
                ),
                child: const Text("Go to Login"),
              ),
            ),
          ],
        ),
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

  String _initialsFrom(String name, String email) {
    final trimmed = name.trim();
    if (trimmed.isNotEmpty && trimmed != 'User') {
      final parts = trimmed.split(RegExp(r'\s+'));
      if (parts.length == 1) {
        return parts.first.substring(0, 1).toUpperCase();
      }
      return (parts.first.substring(0, 1) + parts.last.substring(0, 1))
          .toUpperCase();
    }
    if (email.isNotEmpty) {
      return email.substring(0, 1).toUpperCase();
    }
    return 'U';
  }

  Future<void> _handleLogout() async {
    if (_loggingOut) return;
    setState(() => _loggingOut = true);

    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );

    final error = await ApiService.logout();
    if (!mounted) return;
    Navigator.of(context, rootNavigator: true).pop();
    setState(() => _loggingOut = false);

    if (error == null) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
        (route) => false,
      );
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(error)));
    }
  }

  Future<void> _handleChangePhoto(UserProfile profile) async {
    if (_uploadingAvatar) return;

    final picker = ImagePicker();
    final file = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
    );
    if (file == null) return;

    setState(() => _uploadingAvatar = true);
    try {
      final error = await ApiService.updateProfile(
        firstName: profile.firstName ?? '',
        lastName: profile.lastName ?? '',
        email: profile.email ?? '',
        avatarPath: file.path,
      );
      if (!mounted) return;
      if (error != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(error)),
        );
      } else {
        await _refreshProfile();
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Photo updated')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _uploadingAvatar = false);
      }
    }
  }

  Future<void> _refreshProfile() async {
    setState(() {
      _profileFuture = ApiService.getUserProfile();
    });
    await _profileFuture;
  }
}

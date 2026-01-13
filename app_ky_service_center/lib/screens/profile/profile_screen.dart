import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import '../Auth/login_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late Future<UserProfile?> _profileFuture;
  bool _loggingOut = false;

  @override
  void initState() {
    super.initState();
    _profileFuture = ApiService.getUserProfile();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F7FB),
      appBar: AppBar(
        title: const Text("Profile"),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
        actions: [
          IconButton(icon: const Icon(Icons.more_vert), onPressed: () {}),
        ],
      ),
      body: FutureBuilder<UserProfile?>(
        future: _profileFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          final profile = snapshot.data;
          if (profile == null) {
            return _emptyState();
          }
          return _profileView(profile);
        },
      ),
    );
  }

  Widget _profileView(UserProfile profile) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
      children: [
        _profileHeader(profile),
        const SizedBox(height: 20),
        _sectionTitle("Account"),
        _profileItem(
          icon: Icons.person_outline,
          title: "Edit Profile",
          subtitle: "Account information",
          color: const Color(0xFF5B8DEF),
        ),
        _profileItem(
          icon: Icons.location_on_outlined,
          title: "Address Management",
          subtitle: "Manage your addresses",
          color: const Color(0xFF22B07D),
        ),
        _profileItem(
          icon: Icons.security_outlined,
          title: "Security Settings",
          subtitle: "Password & security",
          color: const Color(0xFFFF6B6B),
        ),
        const SizedBox(height: 10),
        _sectionTitle("Orders"),
        _profileItem(
          icon: Icons.receipt_long_outlined,
          title: "Order History",
          subtitle: "Your past orders",
          color: const Color(0xFF7C5CFF),
        ),
        _profileItem(
          icon: Icons.report_outlined,
          title: "Report History",
          subtitle: "Service reports",
          color: const Color(0xFFFFA552),
        ),
        const SizedBox(height: 10),
        _sectionTitle("Settings"),
        _profileItem(
          icon: Icons.settings_outlined,
          title: "Language & App Settings",
          subtitle: "Preferences and notifications",
          color: const Color(0xFF00C2C7),
        ),
        _profileItem(
          icon: Icons.logout,
          title: "Logout",
          subtitle: "Sign out of your account",
          color: const Color(0xFFEA5455),
          showChevron: false,
          onTap: _handleLogout,
        ),
      ],
    );
  }

  Widget _profileHeader(UserProfile profile) {
    final name = profile.displayName.isNotEmpty ? profile.displayName : "User";
    final email = profile.email ?? "No email";
    final initials = _initialsFrom(name, email);
    final avatarUrl = profile.avatarUrl;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 28,
            backgroundColor: const Color(0xFF00C2C7),
            backgroundImage: avatarUrl != null ? NetworkImage(avatarUrl) : null,
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
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(email, style: TextStyle(color: Colors.grey.shade600)),
              ],
            ),
          ),
          const Icon(Icons.chevron_right, color: Colors.grey),
        ],
      ),
    );
  }

  Widget _sectionTitle(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
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
        borderRadius: BorderRadius.circular(14),
      ),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: color.withOpacity(0.12),
          child: Icon(icon, color: color),
        ),
        title: Text(title),
        subtitle: Text(subtitle),
        trailing: showChevron
            ? const Icon(Icons.chevron_right, color: Colors.grey)
            : null,
        onTap: onTap,
      ),
    );
  }

  Widget _emptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.person_outline, size: 64, color: Colors.grey),
            const SizedBox(height: 12),
            const Text(
              "No profile data found",
              style: TextStyle(fontWeight: FontWeight.bold),
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
                child: const Text("Go to Login"),
              ),
            ),
          ],
        ),
      ),
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
}

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

import '../../models/pickup_ticket.dart';
import '../../models/user_profile.dart';
import '../../services/api_service.dart';
import '../../services/app_notification_service.dart';
import '../Auth/login_screen.dart';
import '../notifications/notification_screen.dart';
import 'edit_profile_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  static const Color _brandBlue = Color(0xFF4A88F7);
  static const Color _brandPeach = Color(0xFFEAF1FF);
  static const Color _canvas = Color(0xFFF5F7FB);
  static const Color _surface = Colors.white;
  static const Color _surfaceAlt = Color(0xFFF6F9FF);
  static const Color _border = Color(0xFFE6ECF5);
  static const Color _textPrimary = Color(0xFF111827);
  static const Color _textMuted = Color(0xFF6B7280);
  static const Color _heroStart = Color(0xFF4A88F7);
  static const Color _heroEnd = Color(0xFF96B5F2);
  static const Color _danger = Color(0xFFE65054);

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
    final theme = Theme.of(context);
    return Theme(
      data: theme.copyWith(
        textTheme: GoogleFonts.interTextTheme(theme.textTheme),
      ),
      child: Scaffold(
        backgroundColor: _canvas,
        body: Stack(
          children: [
            _backgroundDecorations(),
            SafeArea(
              child: FutureBuilder<UserProfile?>(
                future: _profileFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState != ConnectionState.done) {
                    return const Center(
                      child: CircularProgressIndicator(color: _brandBlue),
                    );
                  }

                  if (!snapshot.hasData) {
                    return RefreshIndicator(
                      color: _brandBlue,
                      onRefresh: _refreshProfile,
                      child: ListView(
                        padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
                        physics: const AlwaysScrollableScrollPhysics(),
                        children: [_emptyState()],
                      ),
                    );
                  }

                  return _profileView(snapshot.data!);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _backgroundDecorations() {
    return Container(decoration: const BoxDecoration(color: _canvas));
  }

  Widget _profileView(UserProfile profile) {
    return RefreshIndicator(
      color: _brandBlue,
      onRefresh: _refreshProfile,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(18, 12, 18, 28),
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          _animatedEntry(0, _heroCard(profile)),
          _animatedEntry(
            1,
            Padding(
              padding: const EdgeInsets.only(top: 18),
              child: _informationCard(profile),
            ),
          ),
          _animatedEntry(
            2,
            Padding(
              padding: const EdgeInsets.only(top: 24, bottom: 12),
              child: _sectionHeader(
                title: 'Quick Actions',
                subtitle: 'Shortcuts for your most-used account tools',
              ),
            ),
          ),
          _animatedEntry(3, _quickActions()),
          _animatedEntry(
            4,
            Padding(
              padding: const EdgeInsets.only(top: 24, bottom: 12),
              child: _sectionHeader(
                title: 'Settings',
                subtitle: 'Manage profile preferences and account options',
              ),
            ),
          ),
          _animatedEntry(5, _settingsList(profile)),
          _animatedEntry(
            6,
            Padding(
              padding: const EdgeInsets.only(top: 24),
              child: _logoutCard(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _heroCard(UserProfile profile) {
    final name = profile.displayName.isNotEmpty ? profile.displayName : 'User';
    final subtitle = _profileStatus(profile);
    final email = _displayValue(profile.email, 'No email added');
    final initials = _initialsFrom(name, email);
    final avatarUrl = _hasValue(profile.avatarUrl) ? profile.avatarUrl : null;

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 22),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [_heroStart, _heroEnd],
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
              _headerActionButton(
                icon: Icons.settings_outlined,
                onTap: () => _showFeatureComingSoon('Settings'),
              ),
              const Spacer(),
              _headerActionButton(
                icon: Icons.edit_outlined,
                onTap: () => _openEditProfile(profile),
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
                _buildHeroAvatar(initials: initials, avatarUrl: avatarUrl),
                Positioned(
                  right: 2,
                  bottom: 2,
                  child: InkWell(
                    onTap: _uploadingAvatar
                        ? null
                        : () => _handleChangePhoto(profile),
                    borderRadius: BorderRadius.circular(999),
                    child: Container(
                      height: 28,
                      width: 28,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(999),
                        border: Border.all(color: Colors.white),
                      ),
                      child: _uploadingAvatar
                          ? const Padding(
                              padding: EdgeInsets.all(6),
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  _brandBlue,
                                ),
                              ),
                            )
                          : const Icon(
                              Icons.camera_alt_outlined,
                              size: 15,
                              color: _brandBlue,
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
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              color: Colors.white.withAlpha((0.92 * 255).round()),
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _headerActionButton({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Material(
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
  }

  Widget _informationCard(UserProfile profile) {
    final completion = _completionPercent(profile);
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: _surface,
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
          _detailRow(
            icon: Icons.phone_iphone_outlined,
            title: 'Phone Number',
            value: _displayValue(profile.phone, 'Not available'),
          ),
          const SizedBox(height: 16),
          _detailRow(
            icon: Icons.badge_outlined,
            title: 'ID Number',
            value: _displayValue(_profileId(profile), 'Not available'),
          ),
          const SizedBox(height: 16),
          _detailRow(
            icon: Icons.military_tech_outlined,
            title: 'Rank',
            value: _profileRank(completion),
          ),
          const SizedBox(height: 16),
          _detailRow(
            icon: Icons.location_on_outlined,
            title: 'Location',
            value: _displayValue(_profileLocation(profile), 'Not available'),
          ),
        ],
      ),
    );
  }

  Widget _detailRow({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Row(
      children: [
        Container(
          height: 42,
          width: 42,
          decoration: BoxDecoration(
            color: _surfaceAlt,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: _brandBlue, size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: GoogleFonts.inter(
                  color: _textMuted,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: GoogleFonts.inter(
                  color: _textPrimary,
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _quickActions() {
    final actions = [
      (
        icon: Icons.description_outlined,
        label: 'Documents',
        colors: const [Color(0xFFEAF2FF), Color(0xFFDDEAFF)],
        onTap: () => _showFeatureComingSoon('Documents'),
      ),
      (
        icon: Icons.insights_outlined,
        label: 'Activity',
        colors: const [Color(0xFFEFF7FF), Color(0xFFE5F2FF)],
        onTap: _openOrderHistory,
      ),
      (
        icon: Icons.verified_user_outlined,
        label: 'Security',
        colors: const [Color(0xFFF2F5FF), Color(0xFFE9EEFF)],
        onTap: () => _showFeatureComingSoon('Security'),
      ),
      (
        icon: Icons.account_balance_wallet_outlined,
        label: 'Payment',
        colors: const [Color(0xFFEEF4FF), Color(0xFFE2ECFF)],
        onTap: () => _showFeatureComingSoon('Payment'),
      ),
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: actions.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1.18,
      ),
      itemBuilder: (context, index) {
        final action = actions[index];
        return _quickActionCard(
          icon: action.icon,
          label: action.label,
          colors: action.colors,
          onTap: action.onTap,
        );
      },
    );
  }

  Widget _quickActionCard({
    required IconData icon,
    required String label,
    required List<Color> colors,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Ink(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: colors,
            ),
            borderRadius: BorderRadius.circular(18),
            boxShadow: const [
              BoxShadow(
                color: Color(0x120F172A),
                blurRadius: 14,
                offset: Offset(0, 8),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  height: 44,
                  width: 44,
                  decoration: BoxDecoration(
                    color: Colors.white.withAlpha((0.72 * 255).round()),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(icon, color: _brandBlue, size: 22),
                ),
                const Spacer(),
                Text(
                  label,
                  style: GoogleFonts.poppins(
                    color: _textPrimary,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: const [
                    Text(
                      'Open',
                      style: TextStyle(
                        color: _textMuted,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    SizedBox(width: 6),
                    Icon(
                      Icons.arrow_forward_rounded,
                      size: 14,
                      color: _textMuted,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _sectionHeader({required String title, required String subtitle}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: GoogleFonts.poppins(
            color: _textPrimary,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          subtitle,
          style: GoogleFonts.inter(
            color: _textMuted,
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _settingsList(UserProfile profile) {
    return Container(
      decoration: BoxDecoration(
        color: _surface,
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
          _settingsRow(
            icon: Icons.person_outline_rounded,
            title: 'Edit Profile',
            onTap: () => _openEditProfile(profile),
          ),
          _settingsDivider(),
          _settingsRow(
            icon: Icons.notifications_none_rounded,
            title: 'Notifications',
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const NotificationScreen()),
              );
            },
          ),
          _settingsDivider(),
          _settingsRow(
            icon: Icons.language_rounded,
            title: 'Language',
            onTap: () => _showFeatureComingSoon('Language'),
          ),
          _settingsDivider(),
          _settingsRow(
            icon: Icons.lock_outline_rounded,
            title: 'Privacy',
            onTap: () => _showFeatureComingSoon('Privacy'),
          ),
          _settingsDivider(),
          _settingsRow(
            icon: Icons.help_outline_rounded,
            title: 'Help Center',
            onTap: () => _showFeatureComingSoon('Help Center'),
          ),
        ],
      ),
    );
  }

  Widget _settingsRow({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          child: Row(
            children: [
              Container(
                height: 40,
                width: 40,
                decoration: BoxDecoration(
                  color: _surfaceAlt,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: _brandBlue, size: 20),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  title,
                  style: GoogleFonts.inter(
                    color: _textPrimary,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const Icon(
                Icons.arrow_forward_ios_rounded,
                size: 16,
                color: Color(0xFF99A1AE),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _settingsDivider() {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 16),
      child: Divider(height: 1, color: _border),
    );
  }

  Widget _logoutCard() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: _loggingOut ? null : _handleLogout,
        icon: _loggingOut
            ? const SizedBox(
                height: 18,
                width: 18,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : const Icon(Icons.logout_rounded),
        label: Text(
          _loggingOut ? 'Logging out...' : 'Logout',
          style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w600),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: _danger,
          foregroundColor: Colors.white,
          elevation: 0,
          minimumSize: const Size.fromHeight(56),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
    );
  }

  Widget _emptyState() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: _surface,
        borderRadius: BorderRadius.circular(20),
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
          Container(
            height: 88,
            width: 88,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [_heroStart, _heroEnd],
              ),
              borderRadius: BorderRadius.circular(999),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x224A88F7),
                  blurRadius: 18,
                  offset: Offset(0, 10),
                ),
              ],
            ),
            child: const Icon(
              Icons.person_outline_rounded,
              size: 40,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 18),
          Text(
            'No profile data found',
            style: GoogleFonts.poppins(
              color: _textPrimary,
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Please login or register to view your profile information.',
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              color: _textMuted,
              fontSize: 13,
              fontWeight: FontWeight.w500,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 18),
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
                backgroundColor: _brandBlue,
                foregroundColor: Colors.white,
                elevation: 0,
                minimumSize: const Size.fromHeight(52),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: Text(
                'Go to Login',
                style: GoogleFonts.inter(fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _profileStatus(UserProfile profile) {
    final completion = _completionPercent(profile);
    if (completion >= 85) return 'Verified Account';
    if (completion >= 55) return 'Active Member';
    return 'Profile Setup Pending';
  }

  String? _profileId(UserProfile profile) {
    final digits = (profile.phone ?? '').replaceAll(RegExp(r'\D'), '');
    if (digits.length >= 4) {
      return 'KY-${digits.substring(digits.length - 4)}';
    }
    final email = profile.email?.trim();
    if (email != null && email.isNotEmpty) {
      return 'KY-${email.length.toString().padLeft(4, '0')}';
    }
    return null;
  }

  String _profileRank(int completion) {
    if (completion >= 85) return 'Gold Member';
    if (completion >= 55) return 'Silver Member';
    return 'Starter';
  }

  String? _profileLocation(UserProfile profile) {
    final phone = profile.phone?.trim() ?? '';
    if (phone.startsWith('+855') || phone.startsWith('855')) {
      return 'Cambodia';
    }
    return null;
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

  Future<void> _openEditProfile(UserProfile profile) async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => EditProfileScreen(profile: profile)),
    );
    if (!mounted) return;
    await _refreshProfile();
  }

  Future<void> _openOrderHistory() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const OrderHistoryScreen()),
    );
  }

  void _showFeatureComingSoon(String feature) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('$feature is coming soon.')));
  }

  int _completionPercent(UserProfile profile) {
    const total = 7;
    final filled = [
      profile.firstName,
      profile.lastName,
      profile.email,
      profile.phone,
      profile.birth,
      profile.gender,
      profile.avatarUrl,
    ].where(_hasValue).length;
    return ((filled / total) * 100).round();
  }

  bool _hasValue(String? value) => value != null && value.trim().isNotEmpty;

  String _displayValue(String? value, String fallback) {
    if (!_hasValue(value)) return fallback;
    return value!.trim();
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

  Widget _buildHeroAvatar({
    required String initials,
    required String? avatarUrl,
  }) {
    return CircleAvatar(
      radius: 48,
      backgroundColor: Colors.white,
      child: ClipOval(
        child: SizedBox.expand(
          child: _buildAvatarImage(
            avatarUrl: avatarUrl,
            loadingColor: _brandBlue,
            fallback: Container(
              color: Colors.white,
              alignment: Alignment.center,
              child: Text(
                initials,
                style: GoogleFonts.inter(
                  color: _brandBlue,
                  fontSize: 30,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAvatarImage({
    required String? avatarUrl,
    required Widget fallback,
    required Color loadingColor,
  }) {
    final normalizedUrl = avatarUrl?.trim();
    if (normalizedUrl == null || normalizedUrl.isEmpty) {
      return fallback;
    }

    return Image.network(
      normalizedUrl,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) => fallback,
      loadingBuilder: (context, child, progress) {
        if (progress == null) return child;
        return Container(
          color: Colors.white,
          alignment: Alignment.center,
          child: SizedBox(
            height: 22,
            width: 22,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(loadingColor),
            ),
          ),
        );
      },
    );
  }

  Future<void> _handleLogout() async {
    if (_loggingOut) return;

    final confirmed = await _showLogoutConfirmation();
    if (confirmed != true || !mounted) return;

    setState(() => _loggingOut = true);

    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );

    await AppNotificationService.instance.unregisterDeviceToken();
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

  Future<bool?> _showLogoutConfirmation() {
    return showDialog<bool>(
      context: context,
      barrierDismissible: true,
      builder: (dialogContext) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.symmetric(horizontal: 24),
          child: Container(
            padding: const EdgeInsets.fromLTRB(22, 24, 22, 20),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(28),
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFFF7FAFF), Color(0xFFFFF4EA)],
              ),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x1F1E2A78),
                  blurRadius: 28,
                  offset: Offset(0, 16),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 68,
                  height: 68,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [
                        _brandBlue.withAlpha((0.92 * 255).round()),
                        _brandPeach.withAlpha((0.92 * 255).round()),
                      ],
                    ),
                  ),
                  child: const Icon(
                    Icons.logout_rounded,
                    color: Colors.white,
                    size: 30,
                  ),
                ),
                const SizedBox(height: 18),
                const Text(
                  'Are you sure to logout?',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'You will need to log in again to access your account.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    height: 1.45,
                    color: Colors.black54,
                  ),
                ),
                const SizedBox(height: 22),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.of(dialogContext).pop(false),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.black87,
                          side: BorderSide(
                            color: Colors.black.withAlpha((0.12 * 255).round()),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          backgroundColor: Colors.white.withAlpha(
                            (0.75 * 255).round(),
                          ),
                        ),
                        child: const Text(
                          'Cancel',
                          style: TextStyle(fontWeight: FontWeight.w700),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => Navigator.of(dialogContext).pop(true),
                        style: ElevatedButton.styleFrom(
                          elevation: 0,
                          foregroundColor: Colors.white,
                          backgroundColor: _brandBlue,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: const Text(
                          'Yes',
                          style: TextStyle(fontWeight: FontWeight.w700),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _showSuccessDialog({
    required String title,
    required String message,
  }) {
    return showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (dialogContext) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.symmetric(horizontal: 24),
          child: Container(
            padding: const EdgeInsets.fromLTRB(22, 24, 22, 20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(28),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x1A0F172A),
                  blurRadius: 30,
                  offset: Offset(0, 16),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  height: 68,
                  width: 68,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [_heroStart, _heroEnd],
                    ),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x334A88F7),
                        blurRadius: 18,
                        offset: Offset(0, 10),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.check_rounded,
                    color: Colors.white,
                    size: 34,
                  ),
                ),
                const SizedBox(height: 18),
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: _textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  message,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    height: 1.45,
                    color: _textMuted,
                  ),
                ),
                const SizedBox(height: 22),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Navigator.of(dialogContext).pop(),
                    style: ElevatedButton.styleFrom(
                      elevation: 0,
                      foregroundColor: Colors.white,
                      backgroundColor: _brandBlue,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: Text(
                      'OK',
                      style: GoogleFonts.inter(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
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
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(error)));
      } else {
        await _refreshProfile();
        if (!mounted) return;
        await _showSuccessDialog(
          title: 'Photo Updated',
          message: 'Your profile picture has been updated successfully.',
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

class OrderHistoryScreen extends StatefulWidget {
  const OrderHistoryScreen({super.key});

  @override
  State<OrderHistoryScreen> createState() => _OrderHistoryScreenState();
}

class _OrderHistoryScreenState extends State<OrderHistoryScreen> {
  late Future<List<PickupTicket>> _historyFuture;

  @override
  void initState() {
    super.initState();
    _historyFuture = _loadHistory();
  }

  Future<List<PickupTicket>> _loadHistory() async {
    final tickets = await ApiService.fetchPickupTickets();
    return tickets.where(_isHistoryTicket).toList();
  }

  bool _isHistoryTicket(PickupTicket ticket) {
    if (ticket.pickupVerifiedAt != null) return true;
    final status = (ticket.orderStatus ?? ticket.pickupTicketStatus ?? '')
        .toLowerCase();
    return status == 'completed' || status == 'used' || status == 'expired';
  }

  Future<void> _refresh() async {
    setState(() {
      _historyFuture = _loadHistory();
    });
    await _historyFuture;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F7FB),
      appBar: AppBar(
        title: const Text(
          'Order History',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF111827),
        elevation: 0,
      ),
      body: FutureBuilder<List<PickupTicket>>(
        future: _historyFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return _OrderHistoryEmptyState(
              title: 'Unable to load history',
              subtitle: 'Please try again in a moment.',
              onRetry: _refresh,
            );
          }

          final history = snapshot.data ?? [];
          if (history.isEmpty) {
            return _OrderHistoryEmptyState(
              title: 'No completed orders yet',
              subtitle: 'Verified or expired pickup tickets will appear here.',
              onRetry: _refresh,
            );
          }

          return RefreshIndicator(
            onRefresh: _refresh,
            child: ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: history.length,
              separatorBuilder: (_, _) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final ticket = history[index];
                return _OrderHistoryCard(ticket: ticket);
              },
            ),
          );
        },
      ),
    );
  }
}

class _OrderHistoryCard extends StatelessWidget {
  const _OrderHistoryCard({required this.ticket});

  final PickupTicket ticket;

  @override
  Widget build(BuildContext context) {
    final scannedAt = ticket.pickupVerifiedAt;
    final scanDate = scannedAt != null
        ? DateFormat('MMM dd, yyyy - hh:mm a').format(scannedAt)
        : '--';
    final amount = ticket.totalAmount ?? 0;
    final status = ticket.statusLabel;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE6E9F0)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0F000000),
            blurRadius: 10,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                height: 36,
                width: 36,
                decoration: BoxDecoration(
                  color: const Color(0xFFEFF6FF),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.receipt_long_outlined,
                  color: Color(0xFF2563EB),
                  size: 18,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      ticket.orderNumber ?? 'Order #${ticket.orderId}',
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF111827),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      ticket.pickupTicketId ?? 'Pickup Ticket',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF6B7280),
                      ),
                    ),
                  ],
                ),
              ),
              _OrderHistoryStatusBadge(label: status),
            ],
          ),
          const SizedBox(height: 12),
          _OrderHistoryInfoRow(label: 'Scan Date', value: scanDate),
          _OrderHistoryInfoRow(label: 'Amount', value: _formatAmount(amount)),
        ],
      ),
    );
  }

  String _formatAmount(double amount) {
    return NumberFormat.currency(symbol: '\$').format(amount);
  }
}

class _OrderHistoryInfoRow extends StatelessWidget {
  const _OrderHistoryInfoRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(
            width: 90,
            child: Text(
              label,
              style: const TextStyle(
                color: Color(0xFF6B7280),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                color: Color(0xFF111827),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _OrderHistoryStatusBadge extends StatelessWidget {
  const _OrderHistoryStatusBadge({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final lower = label.toLowerCase();
    Color bg;
    Color fg;
    if (lower == 'active') {
      bg = const Color(0xFFE0EAFF);
      fg = const Color(0xFF1D4ED8);
    } else if (lower == 'used') {
      bg = const Color(0xFFDCFCE7);
      fg = const Color(0xFF15803D);
    } else if (lower == 'expired') {
      bg = const Color(0xFFFEE2E2);
      fg = const Color(0xFFB91C1C);
    } else {
      bg = const Color(0xFFE5E7EB);
      fg = const Color(0xFF6B7280);
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: fg),
      ),
    );
  }
}

class _OrderHistoryEmptyState extends StatelessWidget {
  const _OrderHistoryEmptyState({
    required this.title,
    required this.subtitle,
    required this.onRetry,
  });

  final String title;
  final String subtitle;
  final Future<void> Function() onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              height: 64,
              width: 64,
              decoration: BoxDecoration(
                color: const Color(0xFFEFF6FF),
                borderRadius: BorderRadius.circular(18),
              ),
              child: const Icon(
                Icons.receipt_long_outlined,
                color: Color(0xFF2563EB),
                size: 32,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: Color(0xFF111827),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 6),
            Text(
              subtitle,
              style: const TextStyle(fontSize: 12, color: Color(0xFF6B7280)),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            OutlinedButton(
              onPressed: onRetry,
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 10,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text('Refresh'),
            ),
          ],
        ),
      ),
    );
  }
}

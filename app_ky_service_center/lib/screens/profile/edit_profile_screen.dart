import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../models/user_profile.dart';
import '../../services/api_service.dart';
import 'address_management_screen.dart';
import 'personal_info_screen.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key, required this.profile});

  final UserProfile profile;

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  static const Color _canvas = Color(0xFFF5F7FB);
  static const Color _surface = Colors.white;
  static const Color _primary = Color(0xFF4A88F7);
  static const Color _primarySoft = Color(0xFFEAF1FF);
  static const Color _textPrimary = Color(0xFF111827);
  static const Color _textMuted = Color(0xFF6B7280);
  static const Color _border = Color(0xFFE6ECF5);

  late UserProfile _profile;
  bool _refreshing = false;

  @override
  void initState() {
    super.initState();
    _profile = widget.profile;
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
        appBar: AppBar(
          automaticallyImplyLeading: false,
          toolbarHeight: 72,
          leadingWidth: 72,
          leading: Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 0, 12),
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: _surface,
                shape: BoxShape.circle,
                border: Border.all(color: _border),
              ),
              child: IconButton(
                onPressed: () => Navigator.of(context).maybePop(),
                icon: const Icon(Icons.chevron_left_rounded, size: 22),
                color: _textPrimary,
              ),
            ),
          ),
          backgroundColor: _surface,
          elevation: 0,
          foregroundColor: _textPrimary,
          centerTitle: true,
          title: Text(
            'Edit Profile',
            style: GoogleFonts.sora(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: _textPrimary,
            ),
          ),
          actions: const [SizedBox(width: 72)],
          scrolledUnderElevation: 0,
          surfaceTintColor: Colors.transparent,
        ),
        body: RefreshIndicator(
          color: _primary,
          onRefresh: _refreshProfile,
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
            children: [
              _animatedEntry(
                0,
                Text(
                  'Review your information, then update any part of your account.',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    height: 1.5,
                    color: _textMuted,
                  ),
                ),
              ),
              const SizedBox(height: 18),
              _animatedEntry(1, _profileCard()),
              const SizedBox(height: 24),
              _animatedEntry(
                2,
                _sectionHeader(
                  title: 'Profile Details',
                  subtitle: 'A detailed view of your current personal information',
                ),
              ),
              const SizedBox(height: 12),
              _animatedEntry(3, _detailsCard()),
              const SizedBox(height: 24),
              _animatedEntry(
                4,
                _sectionHeader(
                  title: 'Manage Account',
                  subtitle: 'Update profile details and saved addresses',
                ),
              ),
              const SizedBox(height: 12),
              _animatedEntry(
                5,
                _actionGroup(
                  children: [
                    _actionTile(
                      icon: Icons.person_outline_rounded,
                      title: 'Personal Information',
                      subtitle: 'Name, birth date, gender, and profile photo',
                      onTap: _openPersonalInformation,
                    ),
                    _divider(),
                    _actionTile(
                      icon: Icons.location_on_outlined,
                      title: 'Saved Addresses',
                      subtitle: 'Manage pickup and delivery locations',
                      onTap: _openAddresses,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              _animatedEntry(
                6,
                _sectionHeader(
                  title: 'Account Summary',
                  subtitle: 'A quick status view for your profile setup',
                ),
              ),
              const SizedBox(height: 12),
              _animatedEntry(7, _overviewCard()),
              const SizedBox(height: 24),
              _animatedEntry(
                8,
                SizedBox(
                  height: 54,
                  child: ElevatedButton(
                    onPressed: _openPersonalInformation,
                    style: ElevatedButton.styleFrom(
                      elevation: 0,
                      backgroundColor: _primary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
                      ),
                    ),
                    child: Text(
                      'Edit Personal Information',
                      style: GoogleFonts.inter(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _detailsCard() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: _surface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: _border),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0D0F172A),
            blurRadius: 18,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          _detailItem(
            icon: Icons.badge_outlined,
            label: 'Full Name',
            value: _profile.displayName,
          ),
          _divider(),
          _detailItem(
            icon: Icons.person_outline_rounded,
            label: 'First Name',
            value: _displayValue(_profile.firstName, 'Not set'),
          ),
          _divider(),
          _detailItem(
            icon: Icons.person_2_outlined,
            label: 'Last Name',
            value: _displayValue(_profile.lastName, 'Not set'),
          ),
          _divider(),
          _detailItem(
            icon: Icons.phone_outlined,
            label: 'Phone Number',
            value: _displayValue(_profile.phone, 'Not added'),
          ),
          _divider(),
          _detailItem(
            icon: Icons.mail_outline_rounded,
            label: 'Email Address',
            value: _displayValue(_profile.email, 'Not added'),
          ),
          _divider(),
          _detailItem(
            icon: Icons.calendar_today_outlined,
            label: 'Birth Date',
            value: _displayValue(_profile.birth, 'Not set'),
          ),
          _divider(),
          _detailItem(
            icon: Icons.wc_outlined,
            label: 'Gender',
            value: _displayValue(_profile.gender, 'Not set'),
          ),
        ],
      ),
    );
  }

  Widget _profileCard() {
    final name = _profile.displayName.isNotEmpty ? _profile.displayName : 'User';
    final email = _displayValue(_profile.email, 'No email added');
    final phone = _displayValue(_profile.phone, 'No phone added');
    final initials = _initialsFrom(name, email);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: _border),
        boxShadow: const [
          BoxShadow(
            color: Color(0x100F172A),
            blurRadius: 24,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                decoration: BoxDecoration(
                  color: _primarySoft,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  'Account',
                  style: GoogleFonts.inter(
                    color: _primary,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const Spacer(),
              Text(
                'Profile settings',
                style: GoogleFonts.inter(
                  color: _textMuted,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              Container(
                height: 72,
                width: 72,
                decoration: BoxDecoration(
                  color: _primarySoft,
                  shape: BoxShape.circle,
                ),
                child: CircleAvatar(
                  radius: 34,
                  backgroundColor: _primary,
                  child: ClipOval(
                    child: SizedBox.expand(
                      child: _buildAvatarImage(
                        avatarUrl: _profile.avatarUrl,
                        accent: _primary,
                        fallback: Container(
                          color: _primary,
                          alignment: Alignment.center,
                          child: Text(
                            initials,
                            style: GoogleFonts.poppins(
                              color: Colors.white,
                              fontSize: 26,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: GoogleFonts.poppins(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        color: _textPrimary,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      email,
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        color: _textMuted,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFD),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: _border),
            ),
            child: Row(
              children: [
                Expanded(
                  child: _infoBlock(
                    label: 'Phone',
                    value: phone,
                    alignEnd: false,
                  ),
                ),
                Container(
                  width: 1,
                  height: 38,
                  color: _border,
                ),
                Expanded(
                  child: _infoBlock(
                    label: 'Gender',
                    value: _displayValue(_profile.gender, 'Not set'),
                    alignEnd: true,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoBlock({
    required String label,
    required String value,
    required bool alignEnd,
  }) {
    final alignment =
        alignEnd ? CrossAxisAlignment.end : CrossAxisAlignment.start;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Column(
        crossAxisAlignment: alignment,
        children: [
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 12,
              color: _textMuted,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            textAlign: alignEnd ? TextAlign.end : TextAlign.start,
            style: GoogleFonts.inter(
              fontSize: 14,
              color: _textPrimary,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionHeader({
    required String title,
    required String subtitle,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: _textPrimary,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          subtitle,
          style: GoogleFonts.inter(
            fontSize: 13,
            color: _textMuted,
            height: 1.45,
          ),
        ),
      ],
    );
  }

  Widget _actionGroup({required List<Widget> children}) {
    return Container(
      decoration: BoxDecoration(
        color: _surface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: _border),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0D0F172A),
            blurRadius: 18,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Column(children: children),
    );
  }

  Widget _actionTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(22),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          child: Row(
            children: [
              Container(
                height: 46,
                width: 46,
                decoration: BoxDecoration(
                  color: _primarySoft,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(icon, color: _primary, size: 22),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: GoogleFonts.inter(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: _textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        height: 1.45,
                        color: _textMuted,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Container(
                height: 34,
                width: 34,
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFD),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: _border),
                ),
                child: const Icon(
                  Icons.chevron_right_rounded,
                  size: 20,
                  color: _textMuted,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _divider() {
    return const Divider(height: 1, thickness: 1, color: _border);
  }

  Widget _overviewCard() {
    return Row(
      children: [
        Expanded(
          child: _overviewTile(
            title: 'Birth Date',
            value: _displayValue(_profile.birth, 'Not set'),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _overviewTile(
            title: 'Profile Score',
            value: '${_profileScore()}%',
          ),
        ),
      ],
    );
  }

  Widget _detailItem({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 40,
            width: 40,
            decoration: BoxDecoration(
              color: _primarySoft,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: _primary, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: _textMuted,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: GoogleFonts.inter(
                    fontSize: 15,
                    color: _textPrimary,
                    fontWeight: FontWeight.w700,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _overviewTile({
    required String title,
    required String value,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.inter(
              fontSize: 12,
              color: _textMuted,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: GoogleFonts.inter(
              fontSize: 14,
              color: _textPrimary,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAvatarImage({
    required String? avatarUrl,
    required Color accent,
    required Widget fallback,
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
          color: accent,
          alignment: Alignment.center,
          child: const SizedBox(
            height: 18,
            width: 18,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          ),
        );
      },
    );
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

  int _profileScore() {
    const total = 6;
    final filled = [
      _profile.firstName,
      _profile.lastName,
      _profile.email,
      _profile.phone,
      _profile.birth,
      _profile.gender,
    ].where(_hasValue).length;
    return ((filled / total) * 100).round();
  }

  Future<void> _openPersonalInformation() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PersonalInfoScreen(profile: _profile),
      ),
    );
    if (!mounted) return;
    await _refreshProfile();
  }

  Future<void> _openAddresses() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const AddressManagementScreen()),
    );
  }

  Future<void> _refreshProfile() async {
    if (_refreshing) return;
    setState(() => _refreshing = true);
    try {
      final updated = await ApiService.getUserProfile();
      if (!mounted) return;
      if (updated != null) {
        setState(() => _profile = updated);
      }
    } finally {
      if (mounted) {
        setState(() => _refreshing = false);
      }
    }
  }

  Widget _animatedEntry(int index, Widget child) {
    final duration = Duration(milliseconds: 260 + (index * 70));
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

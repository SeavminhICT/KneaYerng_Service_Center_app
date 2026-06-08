import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/app_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:skeletonizer/skeletonizer.dart';

import '../../models/user_profile.dart';
import '../../l10n/app_localizations.dart';
import '../../services/api_service.dart';
import '../../widgets/app_network_image.dart';
import '../../services/app_notification_service.dart';
import '../../services/language_service.dart';
import '../../services/theme_service.dart';
import '../Auth/login_screen.dart';
import '../notifications/admin_notification_panel_screen.dart';
import '../notifications/notification_screen.dart';
import 'edit_profile_screen.dart';
import 'reviews_preview_screen.dart';
import '../../widgets/auth_guard.dart';
import '../support/support_chat_screen.dart';
import 'help_center_screen.dart';
import 'privacy_screen.dart';
import '../warranty/warranty_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  static const Color _brandBlue = Color(0xFF4A88F7);
  static const Color _brandPeach = Color(0xFFEAF1FF);
  static const Color _surfaceLight = Colors.white;
  static const Color _surfaceDark = Color(0xFF161B22);
  static const Color _surfaceAltLight = Color(0xFFF6F9FF);
  static const Color _surfaceAltDark = Color(0xFF1D2635);
  static const Color _borderLight = Color(0xFFE6ECF5);
  static const Color _borderDark = Color(0xFF2B3442);
  static const Color _textPrimaryLight = Color(0xFF111827);
  static const Color _textPrimaryDark = Color(0xFFE6EDF7);
  static const Color _textMutedLight = Color(0xFF6B7280);
  static const Color _textMutedDark = Color(0xFF97A2B5);
  static const Color _heroStart = Color(0xFF4A88F7);
  static const Color _heroEnd = Color(0xFF96B5F2);
  static const Color _danger = Color(0xFFE65054);

  late Future<UserProfile?> _profileFuture;

  bool _loggingOut = false;
  bool _uploadingAvatar = false;

  bool get _isDarkMode => ThemeService.instance.isDark(context);
  Color get _surface => _isDarkMode ? _surfaceDark : _surfaceLight;
  Color get _surfaceAlt => _isDarkMode ? _surfaceAltDark : _surfaceAltLight;
  Color get _border => _isDarkMode ? _borderDark : _borderLight;
  Color get _textPrimary => _isDarkMode ? _textPrimaryDark : _textPrimaryLight;
  Color get _textMuted => _isDarkMode ? _textMutedDark : _textMutedLight;

  @override
  void initState() {
    super.initState();
    _profileFuture = ApiService.getUserProfile();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = ThemeService.instance.isDark(context);
    return Theme(
      data: theme.copyWith(
        textTheme: GoogleFonts.soraTextTheme(theme.textTheme),
      ),
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        body: Stack(
          children: [
            _backgroundDecorations(isDark: isDark),
            SafeArea(
              child: FutureBuilder<UserProfile?>(
                future: _profileFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState != ConnectionState.done) {
                    return Skeletonizer(
                      enabled: true,
                      child: _profileView(const UserProfile(
                        firstName: 'Loading',
                        lastName: 'User',
                        email: 'loading@example.com',
                        phone: '+1 234 567 8900',
                      )),
                    );
                  }

                  if (!snapshot.hasData) {
                    return _emptyStateView();
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

  Widget _emptyStateView() {
    return RefreshIndicator(
      color: _brandBlue,
      onRefresh: _refreshProfile,
      child: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          SliverFillRemaining(
            hasScrollBody: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 420),
                  child: _emptyState(),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _backgroundDecorations({required bool isDark}) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
      ),
    );
  }

  Widget _profileView(UserProfile profile) {
    final completion = _completionPercent(profile);
    final isNewUser = completion < 40;
    return RefreshIndicator(
      color: _brandBlue,
      onRefresh: _refreshProfile,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(18, 12, 18, 28),
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          _animatedEntry(0, _heroCard(profile)),
          // Setup banner for new/incomplete profiles
          if (isNewUser)
            _animatedEntry(
              1,
              Padding(
                padding: const EdgeInsets.only(top: 14),
                child: _setupBanner(profile),
              ),
            ),
          _animatedEntry(
            isNewUser ? 2 : 1,
            Padding(
              padding: const EdgeInsets.only(top: 18),
              child: _informationCard(profile),
            ),
          ),
          _animatedEntry(
            isNewUser ? 3 : 2,
            Padding(
              padding: const EdgeInsets.only(top: 24, bottom: 12),
              child: _sectionHeader(
                title: 'Quick Actions',
                subtitle: AppLocalizations.of(context).isKhmer
                    ? 'ផ្លូវកាត់សម្រាប់ឧបករណ៍គណនីដែលប្រើញឹកញាប់'
                    : 'Shortcuts for your most-used account tools',
              ),
            ),
          ),
          _animatedEntry(isNewUser ? 4 : 3, _quickActions()),
          _animatedEntry(
            isNewUser ? 5 : 4,
            Padding(
              padding: const EdgeInsets.only(top: 24, bottom: 12),
              child: _sectionHeader(
                title: AppLocalizations.of(context).settings,
                subtitle: AppLocalizations.of(context).isKhmer
                    ? 'គ្រប់គ្រងការកំណត់ប្រវត្តិរូប និងជម្រើសគណនី'
                    : 'Manage profile preferences and account options',
              ),
            ),
          ),
          _animatedEntry(isNewUser ? 6 : 5, _settingsList(profile)),
          _animatedEntry(
            isNewUser ? 7 : 6,
            Padding(
              padding: const EdgeInsets.only(top: 24),
              child: _logoutCard(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _setupBanner(UserProfile profile) {
    final completion = _completionPercent(profile);
    final missing = <String>[];
    if (!_hasValue(profile.phone)) missing.add('Phone');
    if (!_hasValue(profile.avatarUrl)) missing.add('Photo');
    if (!_hasValue(profile.birth)) missing.add('Birthday');
    if (!_hasValue(profile.gender)) missing.add('Gender');

    return GestureDetector(
      onTap: () => _openEditProfile(profile),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF5198F5), Color(0xFF7EB8FF)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(18),
          boxShadow: const [
            BoxShadow(
              color: Color(0x335198F5),
              blurRadius: 18,
              offset: Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Icon(
                Icons.person_add_alt_1_rounded,
                color: Colors.white,
                size: 24,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Complete Your Profile',
                    style: kFont(context, 
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    missing.isNotEmpty
                        ? 'Add ${missing.take(3).join(', ')} to unlock all features'
                        : 'Tap to update your profile details',
                    style: GoogleFonts.inter(
                      color: Colors.white.withValues(alpha: 0.85),
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(99),
                    child: LinearProgressIndicator(
                      value: completion / 100,
                      minHeight: 5,
                      backgroundColor: Colors.white.withValues(alpha: 0.25),
                      valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '$completion% complete',
                    style: GoogleFonts.inter(
                      color: Colors.white.withValues(alpha: 0.8),
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.arrow_forward_ios_rounded,
                color: Colors.white,
                size: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _heroCard(UserProfile profile) {
    final isDark = ThemeService.instance.isDark(context);
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
                icon: isDark
                    ? Icons.light_mode_rounded
                    : Icons.dark_mode_rounded,
                tooltip: isDark
                    ? 'Switch to Light Mode'
                    : 'Switch to Dark Mode',
                onTap: _toggleThemeMode,
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
    String? tooltip,
  }) {
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

    if (tooltip == null || tooltip.trim().isEmpty) return button;
    return Tooltip(message: tooltip, child: button);
  }

  Widget _informationCard(UserProfile profile) {
    final completion = _completionPercent(profile);
    final hasPhone = _hasValue(profile.phone);
    final profileId = _profileId(profile);
    final hasId = profileId != null;
    final location = _profileLocation(profile);
    final hasLocation = location != null;

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
            value: hasPhone ? profile.phone! : '+ Add phone number',
            isEmpty: !hasPhone,
          ),
          const SizedBox(height: 16),
          _detailRow(
            icon: Icons.badge_outlined,
            title: 'ID Number',
            value: hasId ? profileId : 'Not assigned yet',
            isEmpty: !hasId,
          ),
          const SizedBox(height: 16),
          _detailRow(
            icon: Icons.military_tech_outlined,
            title: 'Rank',
            value: _profileRank(completion),
            isEmpty: false,
          ),
          const SizedBox(height: 16),
          _detailRow(
            icon: Icons.location_on_outlined,
            title: 'Location',
            value: hasLocation ? location : '+ Add location',
            isEmpty: !hasLocation,
          ),
        ],
      ),
    );
  }

  Widget _detailRow({
    required IconData icon,
    required String title,
    required String value,
    bool isEmpty = false,
  }) {
    return Row(
      children: [
        Container(
          height: 42,
          width: 42,
          decoration: BoxDecoration(
            color: isEmpty ? const Color(0xFFF0F5FF) : _surfaceAlt,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            icon,
            color: isEmpty ? _brandBlue.withValues(alpha: 0.5) : _brandBlue,
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
                  color: isEmpty ? _brandBlue.withValues(alpha: 0.7) : _textPrimary,
                  fontSize: isEmpty ? 13 : 15,
                  fontWeight: isEmpty ? FontWeight.w500 : FontWeight.w600,
                  fontStyle: isEmpty ? FontStyle.normal : FontStyle.normal,
                ),
              ),
            ],
          ),
        ),
        if (isEmpty)
          Icon(
            Icons.chevron_right_rounded,
            color: _brandBlue.withValues(alpha: 0.4),
            size: 18,
          ),
      ],
    );
  }

  Widget _quickActions() {
    final isDark = ThemeService.instance.isDark(context);
    final actions = [
      (
        icon: Icons.description_outlined,
        label: 'Reviews Preview',
        colors: isDark
            ? const [Color(0xFF24324A), Color(0xFF1F2B42)]
            : const [Color(0xFFEAF2FF), Color(0xFFDDEAFF)],
        onTap: _openReviewsPreviewAction,
      ),
      // (
      //   icon: Icons.insights_outlined,
      //   label: 'Activity',
      //   colors: isDark
      //       ? const [Color(0xFF22324A), Color(0xFF1C2A3F)]
      //       : const [Color(0xFFEFF7FF), Color(0xFFE5F2FF)],
      //   onTap: _openOrderHistory,
      // ),
      (
        icon: Icons.shield_outlined,
        label: 'Warranty',
        colors: isDark
            ? const [Color(0xFF1A3040), Color(0xFF162836)]
            : const [Color(0xFFE8F5E9), Color(0xFFDCEEDD)],
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const WarrantyScreen()),
        ),
      ),
      // (
      //   icon: Icons.verified_user_outlined,
      //   label: 'Security',
      //   colors: isDark
      //       ? const [Color(0xFF2A2F4A), Color(0xFF222741)]
      //       : const [Color(0xFFF2F5FF), Color(0xFFE9EEFF)],
      //   onTap: () => _showFeatureComingSoon('Security'),
      // ),
      // (
      //   icon: Icons.account_balance_wallet_outlined,
      //   label: 'Payment',
      //   colors: isDark
      //       ? const [Color(0xFF22354A), Color(0xFF1C2D40)]
      //       : const [Color(0xFFEEF4FF), Color(0xFFE2ECFF)],
      //   onTap: () => _showFeatureComingSoon('Payment'),
      // ),
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
    final isDark = ThemeService.instance.isDark(context);
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
                    color: isDark
                        ? Colors.white.withAlpha((0.14 * 255).round())
                        : Colors.white.withAlpha((0.72 * 255).round()),
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
                  children: [
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
    final l = AppLocalizations.of(context);
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
            title: l.editProfile,
            onTap: () => _openEditProfile(profile),
          ),
          _settingsDivider(),
          _settingsRow(
            icon: Icons.notifications_none_rounded,
            title: l.notifications,
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const NotificationScreen()),
              );
            },
          ),
          if (profile.isAdmin) ...[
            _settingsDivider(),
            _settingsRow(
              icon: Icons.campaign_rounded,
              title: l.adminPanel,
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => const AdminNotificationPanelScreen(),
                  ),
                );
              },
            ),
          ],
          _settingsDivider(),
          _settingsRow(
            icon: Icons.language_rounded,
            title: l.language,
            subtitle: LanguageService.instance.isKhmer ? 'ខ្មែរ' : 'English',
            onTap: () => _showLanguagePicker(l),
          ),
          _settingsDivider(),
          _settingsRow(
            icon: Icons.lock_outline_rounded,
            title: l.privacy,
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const PrivacyScreen()),
            ),
          ),
          _settingsDivider(),
          _settingsRow(
            icon: Icons.chat_bubble_outline_rounded,
            title: l.supportChat,
            onTap: () async {
              final ok = await ensureLoggedIn(
                context,
                message: l.isKhmer
                    ? 'សូមចូលគណនី ដើម្បីជជែកជំនួយ។'
                    : 'Please login or register to chat with support.',
              );
              if (!ok || !mounted) return;
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const SupportChatScreen()),
              );
            },
          ),
          _settingsDivider(),
          _settingsRow(
            icon: Icons.help_outline_rounded,
            title: l.helpCenter,
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const HelpCenterScreen()),
            ),
          ),
        ],
      ),
    );
  }

  void _showLanguagePicker(AppLocalizations l) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: _surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setSheetState) {
            final current = LanguageService.instance.locale.languageCode;
            return Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 40, height: 4,
                    decoration: BoxDecoration(
                      color: _border,
                      borderRadius: BorderRadius.circular(99),
                    ),
                  ),
                  const SizedBox(height: 18),
                  Text(
                    l.selectLanguage,
                    style: GoogleFonts.poppins(
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                      color: _textPrimary,
                    ),
                  ),
                  const SizedBox(height: 18),
                  _langOption(
                    flag: '🇺🇸',
                    name: l.english,
                    code: 'en',
                    selected: current == 'en',
                    onTap: () async {
                      final nav = Navigator.of(ctx);
                      await LanguageService.instance.setLanguage('en');
                      nav.pop();
                      if (mounted) {
                        setState(() {});
                        final newL = AppLocalizations.of(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(newL.languageSaved)),
                        );
                      }
                    },
                  ),
                  const SizedBox(height: 10),
                  _langOption(
                    flag: '🇰🇭',
                    name: l.khmer,
                    code: 'km',
                    selected: current == 'km',
                    onTap: () async {
                      final nav = Navigator.of(ctx);
                      await LanguageService.instance.setLanguage('km');
                      nav.pop();
                      if (mounted) {
                        setState(() {});
                        final newL = AppLocalizations.of(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(newL.languageSaved)),
                        );
                      }
                    },
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _langOption({
    required String flag,
    required String name,
    required String code,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: selected ? _brandBlue.withValues(alpha: 0.10) : _surfaceAlt,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: selected ? _brandBlue : _border,
            width: selected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Text(flag, style: const TextStyle(fontSize: 24)),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                name,
                style: GoogleFonts.inter(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: _textPrimary,
                ),
              ),
            ),
            if (selected)
              Icon(Icons.check_circle_rounded, color: _brandBlue, size: 22),
          ],
        ),
      ),
    );
  }

  Widget _settingsRow({
    required IconData icon,
    required String title,
    String? subtitle,
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
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: GoogleFonts.inter(
                        color: _textPrimary,
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (subtitle != null)
                      Text(
                        subtitle,
                        style: GoogleFonts.inter(
                          color: _textMuted,
                          fontSize: 12,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios_rounded,
                size: 16,
                color: _textMuted,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _settingsDivider() {
    return Padding(
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
          _loggingOut ? AppLocalizations.of(context).loading : AppLocalizations.of(context).logout,
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

  Future<void> _openReviewsPreviewAction() async {
    final submitted = await Navigator.push<bool>(
      context,
      PageRouteBuilder<bool>(
        transitionDuration: const Duration(milliseconds: 320),
        reverseTransitionDuration: const Duration(milliseconds: 280),
        pageBuilder: (context, animation, secondaryAnimation) =>
            const ReviewsPreviewScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          final curved = CurvedAnimation(
            parent: animation,
            curve: Curves.easeOutCubic,
            reverseCurve: Curves.easeInCubic,
          );
          final slide = Tween<Offset>(
            begin: const Offset(0, 0.08),
            end: Offset.zero,
          ).animate(curved);
          return FadeTransition(
            opacity: curved,
            child: SlideTransition(position: slide, child: child),
          );
        },
      ),
    );

    if (!mounted || submitted != true) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Review submitted successfully.')),
    );
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

    return AppNetworkImage(
      normalizedUrl,
      fit: BoxFit.cover,
      errorWidget: (context, _, error) => fallback,
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
                Builder(
                  builder: (context) {
                    final l = AppLocalizations.of(context);
                    return Text(
                      l.logoutConfirm,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: Colors.black87,
                      ),
                    );
                  },
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
                        child: Builder(builder: (context) {
                          final l = AppLocalizations.of(context);
                          return Text(l.cancel, style: const TextStyle(fontWeight: FontWeight.w700));
                        }),
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
                        child: Builder(builder: (context) {
                          final l = AppLocalizations.of(context);
                          return Text(l.yes, style: const TextStyle(fontWeight: FontWeight.w700));
                        }),
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
                    child: Builder(builder: (context) {
                      final l = AppLocalizations.of(context);
                      return Text(l.ok, style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w700));
                    }),
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

  Future<void> _toggleThemeMode() async {
    await ThemeService.instance.toggleLightDark();
    if (!mounted) return;

    final isDark = ThemeService.instance.isDark(context);
    _showThemeModeToast(isDark: isDark);
  }

  void _showThemeModeToast({required bool isDark}) {
    final messenger = ScaffoldMessenger.of(context);
    final bottomInset = MediaQuery.of(context).padding.bottom;
    final title = isDark ? 'Dark mode enabled' : 'Light mode enabled';
    final subtitle = isDark
        ? 'Smoother for low-light viewing'
        : 'Clean brightness for daytime use';

    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          duration: const Duration(milliseconds: 1600),
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.transparent,
          elevation: 0,
          margin: EdgeInsets.fromLTRB(16, 0, 16, 92 + bottomInset),
          padding: EdgeInsets.zero,
          content: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: isDark
                    ? const [Color(0xFF1D2635), Color(0xFF2B3442)]
                    : const [Color(0xFF4A88F7), Color(0xFF7DA8F7)],
              ),
              boxShadow: [
                BoxShadow(
                  color: (isDark ? const Color(0xFF0D1117) : _brandBlue)
                      .withAlpha((0.32 * 255).round()),
                  blurRadius: 18,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
              child: Row(
                children: [
                  Container(
                    width: 34,
                    height: 34,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withAlpha((0.18 * 255).round()),
                    ),
                    child: Icon(
                      isDark
                          ? Icons.dark_mode_rounded
                          : Icons.light_mode_rounded,
                      color: Colors.white,
                      size: 19,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 1),
                        Text(
                          subtitle,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: Colors.white.withAlpha((0.9 * 255).round()),
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
  }
}



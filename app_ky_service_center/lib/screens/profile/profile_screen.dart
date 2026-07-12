import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:image_picker/image_picker.dart';
import 'package:skeletonizer/skeletonizer.dart';

import '../../models/user_profile.dart';
import '../../l10n/app_localizations.dart';
import '../../services/api_service.dart';
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
import 'widgets/profile_colors.dart';
import 'widgets/profile_empty_state.dart';
import 'widgets/profile_hero_card.dart';
import 'widgets/profile_information_card.dart';
import 'widgets/profile_logout_button.dart';
import 'widgets/profile_logout_confirmation_dialog.dart';
import 'widgets/profile_quick_actions_grid.dart';
import 'widgets/profile_section_header.dart';
import 'widgets/profile_settings_list.dart';
import 'widgets/profile_setup_banner.dart';
import 'widgets/profile_success_dialog.dart';
import 'widgets/profile_theme_toast.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late Future<UserProfile?> _profileFuture;

  bool _loggingOut = false;
  bool _uploadingAvatar = false;

  bool get _isDarkMode => ThemeService.instance.isDark(context);

  @override
  void initState() {
    super.initState();
    _profileFuture = ApiService.refreshUserProfile();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Theme(
      data: theme.copyWith(
        textTheme: GoogleFonts.soraTextTheme(theme.textTheme),
      ),
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        body: Stack(
          children: [
            Container(
              decoration: BoxDecoration(
                color: Theme.of(context).scaffoldBackgroundColor,
              ),
            ),
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
      color: profileBrandBlue,
      onRefresh: _refreshProfile,
      child: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 420),
                  child: ProfileEmptyState(
                    onGoToLogin: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const LoginScreen()),
                      );
                    },
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _profileView(UserProfile profile) {
    final completion = _completionPercent(profile);
    final isNewUser = completion < 40;
    return RefreshIndicator(
      color: profileBrandBlue,
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
              child: ProfileSectionHeader(
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
              child: ProfileSectionHeader(
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
              child: ProfileLogoutButton(
                loading: _loggingOut,
                label: _loggingOut
                    ? AppLocalizations.of(context).loading
                    : AppLocalizations.of(context).logout,
                onPressed: _handleLogout,
              ),
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

    return ProfileSetupBanner(
      completion: completion,
      missingFields: missing,
      onTap: () => _openEditProfile(profile),
    );
  }

  Widget _heroCard(UserProfile profile) {
    final isDark = _isDarkMode;
    final name = profile.displayName.isNotEmpty ? profile.displayName : 'User';
    final subtitle = _profileStatus(profile);
    final email = _displayValue(profile.email, 'No email added');
    final initials = _initialsFrom(name, email);
    final avatarUrl = _hasValue(profile.avatarUrl) ? profile.avatarUrl : null;

    return ProfileHeroCard(
      isDarkMode: isDark,
      name: name,
      subtitle: subtitle,
      initials: initials,
      avatarUrl: avatarUrl,
      uploadingAvatar: _uploadingAvatar,
      onToggleTheme: _toggleThemeMode,
      onEditProfile: () => _openEditProfile(profile),
      onChangePhoto: () => _handleChangePhoto(profile),
    );
  }

  Widget _informationCard(UserProfile profile) {
    final completion = _completionPercent(profile);
    final profileId = _profileId(profile);
    final location = _profileLocation(profile);

    return ProfileInformationCard(
      phone: profile.phone,
      profileId: profileId,
      rank: _profileRank(completion),
      location: location,
    );
  }

  Widget _quickActions() {
    final isDark = _isDarkMode;
    final actions = [
      ProfileQuickAction(
        icon: HugeIcons.strokeRoundedFile01,
        label: 'Reviews Preview',
        colors: isDark
            ? const [Color(0xFF24324A), Color(0xFF1F2B42)]
            : const [Color(0xFFEAF2FF), Color(0xFFDDEAFF)],
        onTap: _openReviewsPreviewAction,
      ),
      ProfileQuickAction(
        icon: HugeIcons.strokeRoundedShield01,
        label: 'Warranty',
        colors: isDark
            ? const [Color(0xFF1A3040), Color(0xFF162836)]
            : const [Color(0xFFE8F5E9), Color(0xFFDCEEDD)],
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const WarrantyScreen()),
        ),
      ),
    ];

    return ProfileQuickActionsGrid(actions: actions);
  }

  Widget _settingsList(UserProfile profile) {
    final l = AppLocalizations.of(context);
    final items = <ProfileSettingsItem>[
      ProfileSettingsItem(
        icon: HugeIcons.strokeRoundedUser,
        title: l.editProfile,
        onTap: () => _openEditProfile(profile),
      ),
      ProfileSettingsItem(
        icon: HugeIcons.strokeRoundedNotification01,
        title: l.notifications,
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const NotificationScreen()),
          );
        },
      ),
      if (profile.isAdmin)
        ProfileSettingsItem(
          icon: HugeIcons.strokeRoundedMegaphone01,
          title: l.adminPanel,
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => const AdminNotificationPanelScreen(),
              ),
            );
          },
        ),
      ProfileSettingsItem(
        icon: HugeIcons.strokeRoundedGlobe02,
        title: l.language,
        subtitle: LanguageService.instance.isKhmer ? 'ខ្មែរ' : 'English',
        onTap: () => _showLanguagePicker(l),
      ),
      ProfileSettingsItem(
        icon: HugeIcons.strokeRoundedSquareLock02,
        title: l.privacy,
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const PrivacyScreen()),
        ),
      ),
      ProfileSettingsItem(
        icon: HugeIcons.strokeRoundedMessage01,
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
      ProfileSettingsItem(
        icon: HugeIcons.strokeRoundedHelpCircle,
        title: l.helpCenter,
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const HelpCenterScreen()),
        ),
      ),
    ];

    return ProfileSettingsList(items: items);
  }

  void _showLanguagePicker(AppLocalizations l) {
    showProfileLanguagePicker(
      context,
      l: l,
      onLanguageChanged: (_) {
        if (!mounted) return;
        setState(() {});
        final newL = AppLocalizations.of(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(newL.languageSaved)),
        );
      },
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

  Future<void> _handleLogout() async {
    if (_loggingOut) return;

    final confirmed = await showProfileLogoutConfirmationDialog(context);
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
        await showProfileSuccessDialog(
          context,
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
      _profileFuture = ApiService.refreshUserProfile();
    });
    await _profileFuture;
  }

  Future<void> _toggleThemeMode() async {
    await ThemeService.instance.toggleLightDark();
    if (!mounted) return;

    final isDark = ThemeService.instance.isDark(context);
    showProfileThemeModeToast(context, isDark: isDark);
  }
}

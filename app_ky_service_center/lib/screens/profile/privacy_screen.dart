import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../l10n/app_localizations.dart';
import '../../services/theme_service.dart';
import '../../theme/app_fonts.dart';

class PrivacyScreen extends StatefulWidget {
  const PrivacyScreen({super.key});

  @override
  State<PrivacyScreen> createState() => _PrivacyScreenState();
}

class _PrivacyScreenState extends State<PrivacyScreen>
    with SingleTickerProviderStateMixin {
  // ── Prefs keys ──────────────────────────────────────────────────────────────
  static const _kPersonalised = 'priv_personalised';
  static const _kMarketing    = 'priv_marketing';
  static const _kAnalytics    = 'priv_analytics';
  static const _kLocation     = 'priv_location';

  bool _personalised = true;
  bool _marketing    = false;
  bool _analytics    = true;
  bool _location     = true;
  bool _loaded       = false;

  int? _expandedPolicy;

  // ── Colors ──────────────────────────────────────────────────────────────────
  static const _blue        = Color(0xFF4A88F7);
  static const _blueDeep    = Color(0xFF1D4ED8);
  static const _green       = Color(0xFF10B981);
  static const _red         = Color(0xFFEF4444);
  static const _amber       = Color(0xFFF59E0B);

  bool   get _isDark      => ThemeService.instance.isDark(context);
  Color  get _bg          => _isDark ? const Color(0xFF0F172A) : const Color(0xFFEEF6FD);
  Color  get _surface     => _isDark ? const Color(0xFF161B22) : Colors.white;
  Color  get _border      => _isDark ? const Color(0xFF2B3442) : const Color(0xFFE6ECF5);
  Color  get _textPrimary => _isDark ? const Color(0xFFE6EDF7) : const Color(0xFF111827);
  Color  get _textMuted   => _isDark ? const Color(0xFF97A2B5) : const Color(0xFF6B7280);

  @override
  void initState() {
    super.initState();
    _loadPrefs();
  }

  Future<void> _loadPrefs() async {
    final p = await SharedPreferences.getInstance();
    if (!mounted) return;
    setState(() {
      _personalised = p.getBool(_kPersonalised) ?? true;
      _marketing    = p.getBool(_kMarketing)    ?? false;
      _analytics    = p.getBool(_kAnalytics)    ?? true;
      _location     = p.getBool(_kLocation)     ?? true;
      _loaded       = true;
    });
  }

  Future<void> _setPref(String key, bool val) async {
    final p = await SharedPreferences.getInstance();
    await p.setBool(key, val);
  }

  // ── Policy sections ─────────────────────────────────────────────────────────
  List<_PolicySection> _policies(bool isKhmer) => [
    _PolicySection(
      icon: Icons.info_outline_rounded,
      color: _blue,
      title: isKhmer ? 'ព័ត៌មានដែលយើងប្រមូល' : 'Information We Collect',
      body: isKhmer
          ? 'យើងប្រមូលព័ត៌មានដែលអ្នកផ្ដល់ដោយផ្ទាល់ ដូចជាឈ្មោះ អ៊ីមែល លេខទូរស័ព្ទ និងអាសយដ្ឋាន នៅពេលអ្នកបង្កើតគណនីឬដាក់ការបញ្ជាទិញ។ យើងក៏ប្រមូលទិន្នន័យប្រើប្រាស់ ព័ត៌មានឧបករណ៍ និងទីតាំង (បើអ្នកអនុញ្ញាត) ដើម្បីកែលម្អបទពិសោធន៍ប្រើប្រាស់របស់អ្នក។'
          : 'We collect information you provide directly — such as name, email, phone number, and address — when you create an account or place an order. We also collect usage data, device information, and location (if you permit) to improve your experience.',
    ),
    _PolicySection(
      icon: Icons.share_outlined,
      color: _amber,
      title: isKhmer ? 'របៀបប្រើព័ត៌មានរបស់អ្នក' : 'How We Use Your Information',
      body: isKhmer
          ? 'ព័ត៌មានរបស់អ្នកត្រូវបានប្រើដើម្បីដំណើរការការបញ្ជាទិញ ផ្ញើការជូនដំណឹង ផ្ដល់ការណែនាំផ្ទាល់ខ្លួន ធ្វើឱ្យប្រសើរឡើងនូវសេវាកម្ម និងគ្រប់គ្រងគណនីរបស់អ្នក។ យើងប្រើទិន្នន័យដែលប្រមូលបានដើម្បីការពារការក្លែងបន្លំ និងធានាភាពស្របច្បាប់'
          : 'Your information is used to process orders, send notifications, provide personalised recommendations, improve our services, and manage your account. We also use collected data to detect fraud and ensure legal compliance.',
    ),
    _PolicySection(
      icon: Icons.people_outline_rounded,
      color: _green,
      title: isKhmer ? 'ការចែករំលែកព័ត៌មាន' : 'Information Sharing',
      body: isKhmer
          ? 'យើងមិនលក់ ជួញ ឬផ្ទេរព័ត៌មានផ្ទាល់ខ្លួនរបស់អ្នកទៅភាគីទីបីឡើយ លើកលែងតែដៃគូផ្ដល់សេវា ដែលប្រើដើម្បីដំណើរការប្រតិបត្តិការ ដឹកជញ្ជូន ឬធ្វើការវិភាគ ហើយដែលព្រមព្រៀងរក្សាព័ត៌មានឱ្យមានសុវត្ថិភាព។'
          : 'We do not sell, trade, or transfer your personal information to third parties except trusted service partners who assist in operating transactions, delivery, or analytics — and who agree to keep this information secure.',
    ),
    _PolicySection(
      icon: Icons.lock_outline_rounded,
      color: const Color(0xFF8B5CF6),
      title: isKhmer ? 'សុវត្ថិភាព' : 'Data Security',
      body: isKhmer
          ? 'យើងអនុវត្តវិធានការសុវត្ថិភាពស្ដង់ដារឧស្សាហកម្ម រួមមាន ការអ៊ីនគ្រីប TLS ការការពារទិន្នន័យ និងការចូលប្រើប្រាស់ដែលបានកំណត់ ដើម្បីការពារព័ត៌មានរបស់អ្នកពីការចូលប្រើ ការផ្លាស់ប្ដូរ ឬការបញ្ចេញដោយគ្មានការអនុញ្ញាត។'
          : 'We implement industry-standard security measures including TLS encryption, firewalls, and restricted access to protect your information from unauthorised access, alteration, or disclosure.',
    ),
    _PolicySection(
      icon: Icons.cookie_outlined,
      color: const Color(0xFFEC4899),
      title: isKhmer ? 'ខូគី និងការតាមដាន' : 'Cookies & Tracking',
      body: isKhmer
          ? 'កម្មវិធីរបស់យើងប្រើការផ្ទុកទិន្នន័យក្នុងឧបករណ៍ ដើម្បីស្វែងចងចាំចូល ការកំណត់ ម ការតាមដានការណ្ដែញ ដើម្បីអ្នកផ្ដល់បទពិសោធន៍ប្រើប្រាស់ល្អជាងមុន។ អ្នកអាចសម្អាតទំណន់ ​ ឬបិទ​ (Tracking) ​ ពីការកំណត់ "ក្រឡា"។'
          : 'Our app uses local storage to remember logins, preferences, and session tracking to deliver a better experience. You can clear stored data or opt out of analytics tracking from the toggles above.',
    ),
    _PolicySection(
      icon: Icons.gavel_rounded,
      color: const Color(0xFF06B6D4),
      title: isKhmer ? 'សិទ្ធិរបស់អ្នក' : 'Your Rights',
      body: isKhmer
          ? 'អ្នកមានសិទ្ធិចូលប្រើ កែ ឬលុបទិន្នន័យរបស់អ្នក ក៏ដូចជាដាក់ Cambodia Personal Data Protection Law (PDPL) ។ ដើម្បីប្រើប្រាស់សិទ្ធិទាំងនេះ ទំនាក់ទំនង support@kyservicecenter.com ។'
          : 'You have the right to access, correct, or delete your data, and to object to processing under applicable law including the Cambodia PDPL. To exercise these rights contact us at support@kyservicecenter.com.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final isKhmer = l.isKhmer;
    final policies = _policies(isKhmer);

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: _bg,
        body: CustomScrollView(
          slivers: [
            _buildAppBar(isKhmer),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(18, 20, 18, 0),
                child: _privacyScoreCard(isKhmer),
              ),
            ),
            SliverToBoxAdapter(child: _sectionLabel(isKhmer ? 'ការគ្រប់គ្រងទិន្នន័យ' : 'Data Controls', topPad: 28)),
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 18),
              sliver: SliverToBoxAdapter(
                child: _loaded ? _controlsCard(isKhmer) : _controlsCardSkeleton(),
              ),
            ),
            SliverToBoxAdapter(child: _sectionLabel(isKhmer ? 'គោលនយោបាយឯកជន' : 'Privacy Policy', topPad: 28)),
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 18),
              sliver: SliverToBoxAdapter(
                child: _policyCard(policies),
              ),
            ),
            SliverToBoxAdapter(child: _sectionLabel(isKhmer ? 'ទិន្នន័យគណនី' : 'Account Data', topPad: 28)),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(18, 0, 18, 40),
              sliver: SliverToBoxAdapter(
                child: _accountDataCard(isKhmer),
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 20)),
          ],
        ),
      ),
    );
  }

  // ── App bar ──────────────────────────────────────────────────────────────────
  Widget _buildAppBar(bool isKhmer) {
    return SliverAppBar(
      expandedHeight: 155,
      collapsedHeight: 60,
      pinned: true,
      backgroundColor: _isDark ? const Color(0xFF0F172A) : _blueDeep,
      systemOverlayStyle: SystemUiOverlayStyle.light,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20),
        onPressed: () => Navigator.of(context).pop(),
      ),
      flexibleSpace: FlexibleSpaceBar(
        collapseMode: CollapseMode.pin,
        titlePadding: const EdgeInsetsDirectional.only(start: 56, bottom: 16),
        title: Text(
          isKhmer ? 'ភាពឯកជន' : 'Privacy',
          style: kFont(context, fontSize: 16, fontWeight: FontWeight.w700, color: Colors.white),
        ),
        background: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF1E3A8A), Color(0xFF3B82F6)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Stack(
            children: [
              Positioned(right: -20, top: -20,
                child: Container(width: 160, height: 160,
                  decoration: BoxDecoration(shape: BoxShape.circle,
                    color: Colors.white.withValues(alpha: 0.06)))),
              Positioned(left: -10, bottom: 10,
                child: Container(width: 100, height: 100,
                  decoration: BoxDecoration(shape: BoxShape.circle,
                    color: Colors.white.withValues(alpha: 0.05)))),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(Icons.shield_outlined, color: Colors.white, size: 20),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            isKhmer ? 'គ្រប់គ្រងទិន្នន័យ និងការអនុញ្ញាតរបស់អ្នក' : 'Control your data & permissions',
                            style: kFont(context, fontSize: 12, color: Colors.white.withValues(alpha: 0.80)),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Privacy score card ───────────────────────────────────────────────────────
  Widget _privacyScoreCard(bool isKhmer) {
    if (!_loaded) return const SizedBox.shrink();
    final enabled = [_personalised, _marketing, _analytics, _location]
        .where((b) => !b).length;
    final score = 40 + (enabled * 15);
    final Color scoreColor = score >= 70
        ? _green
        : score >= 50
            ? _amber
            : _red;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: _surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: scoreColor.withValues(alpha: 0.30)),
        boxShadow: [
          BoxShadow(
            color: scoreColor.withValues(alpha: 0.12),
            blurRadius: 20,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          SizedBox(
            width: 64,
            height: 64,
            child: Stack(
              alignment: Alignment.center,
              children: [
                CircularProgressIndicator(
                  value: score / 100,
                  strokeWidth: 6,
                  backgroundColor: _border,
                  valueColor: AlwaysStoppedAnimation(scoreColor),
                  strokeCap: StrokeCap.round,
                ),
                Text(
                  '$score',
                  style: kFont(context,
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: scoreColor,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isKhmer ? 'ពិន្ទុឯកជនភាព' : 'Privacy Score',
                  style: kFont(context,
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: _textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  score >= 70
                      ? (isKhmer ? 'ការការពារខ្លាំង — ការគ្រប់គ្រងបានល្អ' : 'Strong protection — well managed')
                      : score >= 50
                          ? (isKhmer ? 'ការការពារមធ្យម — អ្នកអាចកែបន្ថែម' : 'Moderate protection — consider tightening')
                          : (isKhmer ? 'ការការពារទន់ — ពិចារណាបិទការចែករំលែក' : 'Low protection — consider disabling sharing'),
                  style: kFont(context,
                    fontSize: 12,
                    color: _textMuted,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
          Icon(Icons.chevron_right_rounded, color: _textMuted),
        ],
      ),
    );
  }

  // ── Data controls ────────────────────────────────────────────────────────────
  Widget _controlsCard(bool isKhmer) {
    final items = [
      _ToggleItem(
        icon: Icons.recommend_outlined,
        color: _blue,
        title: isKhmer ? 'ការណែនាំផ្ទាល់ខ្លួន' : 'Personalised Recommendations',
        subtitle: isKhmer
            ? 'ប្រើប្រវត្តិទិញ ដើម្បីណែនាំផលិតផល'
            : 'Use purchase history to suggest products',
        value: _personalised,
        onChanged: (v) {
          setState(() => _personalised = v);
          _setPref(_kPersonalised, v);
        },
      ),
      _ToggleItem(
        icon: Icons.campaign_outlined,
        color: _amber,
        title: isKhmer ? 'ទីផ្សារ និងការផ្សព្វផ្សាយ' : 'Marketing & Promotions',
        subtitle: isKhmer
            ? 'ទទួលការផ្សព្វផ្សាយ និងការបញ្ចុះតម្លៃ'
            : 'Receive promotional offers and discounts',
        value: _marketing,
        onChanged: (v) {
          setState(() => _marketing = v);
          _setPref(_kMarketing, v);
        },
      ),
      _ToggleItem(
        icon: Icons.bar_chart_rounded,
        color: _green,
        title: isKhmer ? 'ការវិភាគ & ដំណើរការ' : 'Analytics & Performance',
        subtitle: isKhmer
            ? 'ជួយយើងកែលម្អកម្មវិធី (អនាមិក)'
            : 'Help us improve the app (anonymous)',
        value: _analytics,
        onChanged: (v) {
          setState(() => _analytics = v);
          _setPref(_kAnalytics, v);
        },
      ),
      _ToggleItem(
        icon: Icons.location_on_outlined,
        color: const Color(0xFF8B5CF6),
        title: isKhmer ? 'ទីតាំង' : 'Location Services',
        subtitle: isKhmer
            ? 'ប្រើទីតាំងសម្រាប់ការដឹកជញ្ជូន'
            : 'Used for delivery address & tracking',
        value: _location,
        onChanged: (v) {
          setState(() => _location = v);
          _setPref(_kLocation, v);
        },
      ),
    ];

    return Container(
      decoration: BoxDecoration(
        color: _surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: _isDark ? 0.30 : 0.06),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: List.generate(items.length, (i) {
          return Column(
            children: [
              _toggleRow(items[i]),
              if (i < items.length - 1)
                Divider(height: 1, indent: 68, endIndent: 16, color: _border),
            ],
          );
        }),
      ),
    );
  }

  Widget _controlsCardSkeleton() {
    return Container(
      height: 220,
      decoration: BoxDecoration(
        color: _surface,
        borderRadius: BorderRadius.circular(20),
      ),
    );
  }

  Widget _toggleRow(_ToggleItem item) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: item.color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(11),
            ),
            child: Icon(item.icon, color: item.color, size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.title,
                  style: kFont(context,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: _textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  item.subtitle,
                  style: kFont(context,
                    fontSize: 11.5,
                    color: _textMuted,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Switch.adaptive(
            value: item.value,
            onChanged: item.onChanged,
            activeThumbColor: item.color,
            activeTrackColor: item.color.withValues(alpha: 0.40),
            trackOutlineColor: WidgetStateProperty.all(Colors.transparent),
          ),
        ],
      ),
    );
  }

  // ── Policy accordion ─────────────────────────────────────────────────────────
  Widget _policyCard(List<_PolicySection> sections) {
    return Container(
      decoration: BoxDecoration(
        color: _surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: _isDark ? 0.30 : 0.06),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: List.generate(sections.length, (i) {
          final s = sections[i];
          final open = _expandedPolicy == i;
          return Column(
            children: [
              InkWell(
                onTap: () => setState(() => _expandedPolicy = open ? null : i),
                borderRadius: i == 0
                    ? const BorderRadius.vertical(top: Radius.circular(20))
                    : i == sections.length - 1 && !open
                        ? const BorderRadius.vertical(bottom: Radius.circular(20))
                        : BorderRadius.zero,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  child: Row(
                    children: [
                      Container(
                        width: 38,
                        height: 38,
                        decoration: BoxDecoration(
                          color: s.color.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(s.icon, color: s.color, size: 19),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          s.title,
                          style: kFont(context,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: open ? s.color : _textPrimary,
                          ),
                        ),
                      ),
                      AnimatedRotation(
                        turns: open ? 0.5 : 0,
                        duration: const Duration(milliseconds: 220),
                        child: Icon(
                          Icons.keyboard_arrow_down_rounded,
                          color: open ? s.color : _textMuted,
                          size: 22,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              AnimatedCrossFade(
                firstChild: const SizedBox.shrink(),
                secondChild: Column(
                  children: [
                    Divider(height: 1, color: _border),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(66, 10, 16, 16),
                      child: Text(
                        s.body,
                        style: kFont(context,
                          fontSize: 13,
                          color: _textMuted,
                          height: 1.65,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ),
                  ],
                ),
                crossFadeState: open ? CrossFadeState.showSecond : CrossFadeState.showFirst,
                duration: const Duration(milliseconds: 240),
              ),
              if (i < sections.length - 1) Divider(height: 1, indent: 66, endIndent: 16, color: _border),
            ],
          );
        }),
      ),
    );
  }

  // ── Account data card ────────────────────────────────────────────────────────
  Widget _accountDataCard(bool isKhmer) {
    return Container(
      decoration: BoxDecoration(
        color: _surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: _isDark ? 0.30 : 0.06),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          _dataRow(
            icon: Icons.download_outlined,
            color: _blue,
            title: isKhmer ? 'ទាញយកទិន្នន័យរបស់ខ្ញុំ' : 'Download My Data',
            subtitle: isKhmer
                ? 'ទទួលច្បាប់ចម្លងនៃទិន្នន័យដែលស្តុកទុក'
                : 'Get a copy of all your stored data',
            onTap: () => _showDataRequestDialog(isKhmer),
            isDestructive: false,
          ),
          Divider(height: 1, indent: 68, endIndent: 16, color: _border),
          _dataRow(
            icon: Icons.manage_accounts_outlined,
            color: _amber,
            title: isKhmer ? 'គ្រប់គ្រងការអនុញ្ញាត' : 'Manage App Permissions',
            subtitle: isKhmer
                ? 'ពិនិត្យការអនុញ្ញាតក្នុងឧបករណ៍'
                : 'Review permissions in device settings',
            onTap: () => _showPermissionsDialog(isKhmer),
            isDestructive: false,
          ),
          Divider(height: 1, indent: 68, endIndent: 16, color: _border),
          _dataRow(
            icon: Icons.delete_outline_rounded,
            color: _red,
            title: isKhmer ? 'លុបគណនី' : 'Delete Account',
            subtitle: isKhmer
                ? 'លុបទិន្នន័យទាំងអស់ជាអចិន្ត្រៃ — មិនអាចដកហូតបាន'
                : 'Permanently erase all data — irreversible',
            onTap: () => _showDeleteConfirm(isKhmer),
            isDestructive: true,
          ),
        ],
      ),
    );
  }

  Widget _dataRow({
    required IconData icon,
    required Color color,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    required bool isDestructive,
  }) {
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(11),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: kFont(context,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: isDestructive ? _red : _textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: kFont(context,
                        fontSize: 11.5,
                        color: _textMuted,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right_rounded, color: _textMuted, size: 20),
            ],
          ),
        ),
      ),
    );
  }

  // ── Dialogs ──────────────────────────────────────────────────────────────────
  void _showDataRequestDialog(bool isKhmer) {
    _infoDialog(
      icon: Icons.download_outlined,
      iconColor: _blue,
      title: isKhmer ? 'ទាញយកទិន្នន័យ' : 'Request Data Export',
      message: isKhmer
          ? 'ការស្នើសុំរបស់អ្នកនឹងត្រូវបានដំណើរការក្នុងរយៈ ២-៣ ថ្ងៃធ្វើការ។ ទំនាក់ទំនង support@kyservicecenter.com ។'
          : 'Your data export request will be processed within 2–3 business days. You will receive a download link at your registered email. Contact support@kyservicecenter.com for questions.',
      buttonLabel: isKhmer ? 'ស្នើសុំ' : 'Request Export',
      isKhmer: isKhmer,
    );
  }

  void _showPermissionsDialog(bool isKhmer) {
    _infoDialog(
      icon: Icons.settings_outlined,
      iconColor: _amber,
      title: isKhmer ? 'ការអនុញ្ញាត' : 'App Permissions',
      message: isKhmer
          ? 'ដើម្បីគ្រប់គ្រងការអនុញ្ញាតដូចជា ទីតាំង ជូនដំណឹង និងកាមេរ៉ា ចូលទៅ ការកំណត់ (Settings) > កម្មវិធី > KYSC ក្នុងឧបករណ៍របស់អ្នក។'
          : 'To manage permissions such as location, notifications, and camera access, go to your device Settings → Apps → KYSC and adjust individual permissions.',
      buttonLabel: isKhmer ? 'យល់ព្រម' : 'Got It',
      isKhmer: isKhmer,
    );
  }

  void _showDeleteConfirm(bool isKhmer) {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: _surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: _red.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(Icons.warning_amber_rounded, color: _red, size: 22),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                isKhmer ? 'លុបគណនី' : 'Delete Account',
                style: kFont(context, fontSize: 16, fontWeight: FontWeight.w700, color: _red),
              ),
            ),
          ],
        ),
        content: Text(
          isKhmer
              ? 'ការលុបគណនីរបស់អ្នកនឹងលុបទំនិញ ការបញ្ជាទិញ និងប្រវត្តិទិញទំនិញទាំងអស់ជាអចិន្ត្រៃ។ សកម្មភាពនេះមិនអាចដកហូតបានឡើយ។ ចូលទំនាក់ទំនងជំនួយដើម្បីបន្ត។'
              : 'Deleting your account will permanently erase all your orders, favourites, and purchase history. This action is irreversible. Please contact support to proceed with account deletion.',
          style: kFont(context, fontSize: 13, color: _textMuted, height: 1.6),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(
              isKhmer ? 'បោះបង់' : 'Cancel',
              style: kFont(context, fontSize: 14, fontWeight: FontWeight.w600, color: _textMuted),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    isKhmer
                        ? 'ទំនាក់ទំនង support@kyservicecenter.com'
                        : 'Contact support@kyservicecenter.com to delete your account.',
                  ),
                  behavior: SnackBarBehavior.floating,
                  backgroundColor: _red,
                ),
              );
            },
            child: Text(
              isKhmer ? 'ទំនាក់ទំនងជំនួយ' : 'Contact Support',
              style: kFont(context, fontSize: 14, fontWeight: FontWeight.w700, color: _red),
            ),
          ),
        ],
      ),
    );
  }

  void _infoDialog({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String message,
    required String buttonLabel,
    required bool isKhmer,
  }) {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: _surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: iconColor, size: 22),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: kFont(context, fontSize: 15, fontWeight: FontWeight.w700, color: _textPrimary),
              ),
            ),
          ],
        ),
        content: Text(
          message,
          style: kFont(context, fontSize: 13, color: _textMuted, height: 1.6),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(
              isKhmer ? 'បោះបង់' : 'Cancel',
              style: kFont(context, fontSize: 14, color: _textMuted),
            ),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: iconColor,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () {
              Navigator.of(ctx).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(isKhmer ? 'ការស្នើសុំបានទទួល!' : 'Request received!'),
                  behavior: SnackBarBehavior.floating,
                  backgroundColor: iconColor,
                ),
              );
            },
            child: Text(
              buttonLabel,
              style: kFont(context, fontSize: 14, fontWeight: FontWeight.w600, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  // ── Helpers ──────────────────────────────────────────────────────────────────
  Widget _sectionLabel(String text, {double topPad = 0}) {
    return Padding(
      padding: EdgeInsets.fromLTRB(18, topPad, 18, 10),
      child: Text(
        text,
        style: kFont(context,
          fontSize: 15,
          fontWeight: FontWeight.w700,
          color: _textPrimary,
        ),
      ),
    );
  }
}

// ── Data models ──────────────────────────────────────────────────────────────

class _ToggleItem {
  const _ToggleItem({
    required this.icon,
    required this.color,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });
  final IconData icon;
  final Color color;
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;
}

class _PolicySection {
  const _PolicySection({
    required this.icon,
    required this.color,
    required this.title,
    required this.body,
  });
  final IconData icon;
  final Color color;
  final String title;
  final String body;
}

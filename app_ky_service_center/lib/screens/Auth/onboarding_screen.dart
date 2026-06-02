import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/app_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../l10n/app_localizations.dart';
import '../../services/language_service.dart';

import '../main_navigation_screen.dart';
import 'login_screen.dart';

// ── Design tokens ───────────────────────────────────────────────────────────
const _primary   = Color(0xFF5198F5);
const _primaryLight = Color(0xFFEDF3FF);
const _bg        = Color(0xFFF8F9FC);
const _cardWhite = Color(0xFFFFFFFF);
const _textHead  = Color(0xFF1A1D27);
const _textSub   = Color(0xFF6B7280);
const _textMuted = Color(0xFF9CA3AF);
const _accent2   = Color(0xFFFF8A65);
const _accent3   = Color(0xFF34D399);
const _dot       = Color(0xFFD1DCF5);

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen>
    with TickerProviderStateMixin {
  static const _languagePreferenceKey = 'app_language_code';

  final PageController _pageController = PageController();
  int _currentPage = 0;
  String? _selectedLanguageCode;
  bool _savingLanguage = false;

  late final AnimationController _floatController;
  late final Animation<double> _floatAnim;

  // 3 feature pages + 1 language page
  static const int _totalPages = 4; // 3 feature + 1 language
  int get _lastPage => _totalPages - 1;

  @override
  void initState() {
    super.initState();
    _selectedLanguageCode = LanguageService.instance.locale.languageCode;
    _floatController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2400),
    )..repeat(reverse: true);
    _floatAnim = CurvedAnimation(parent: _floatController, curve: Curves.easeInOut);
  }

  @override
  void dispose() {
    _pageController.dispose();
    _floatController.dispose();
    super.dispose();
  }

  void _goNext() {
    if (_currentPage >= _lastPage) return;
    _pageController.nextPage(
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeOutCubic,
    );
  }

  void _goBack() {
    if (_currentPage == 0) return;
    _pageController.previousPage(
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeOutCubic,
    );
  }

  void _skipToLastPage() {
    _pageController.animateToPage(
      _lastPage,
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeOutCubic,
    );
  }

  void _selectLanguage(String code) async {
    setState(() => _selectedLanguageCode = code);
    await LanguageService.instance.setLanguage(code);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_languagePreferenceKey, code);
  }

  Future<void> _persistLanguageSelection() async {
    final code = _selectedLanguageCode ?? 'en';
    await LanguageService.instance.setLanguage(code);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_languagePreferenceKey, code);
  }

  Future<void> _completeOnboarding() async {
    if (_selectedLanguageCode == null || _savingLanguage) return;
    setState(() => _savingLanguage = true);
    try {
      await _persistLanguageSelection();
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
      );
    } finally {
      if (mounted) setState(() => _savingLanguage = false);
    }
  }

  Future<void> _skipToHome() async {
    if (_savingLanguage) return;
    setState(() => _savingLanguage = true);
    try {
      await _persistLanguageSelection();
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const MainNavigationScreen()),
      );
    } finally {
      if (mounted) setState(() => _savingLanguage = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: _bg,
      body: SafeArea(
        child: Column(
          children: [
            // ── Top bar ────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
              child: Row(
                children: [
                  // App name / back
                  if (_currentPage > 0)
                    _IconBtn(
                      icon: Icons.arrow_back_ios_new_rounded,
                      onTap: _goBack,
                    )
                  else
                    Row(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(9),
                          child: Image.asset(
                            'assets/images/Logo_KYSC.png',
                            width: 32,
                            height: 32,
                            fit: BoxFit.cover,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'KY Services',
                          style: kFont(context, 
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: _textHead,
                          ),
                        ),
                      ],
                    ),
                  const Spacer(),
                  if (_currentPage > 0 && _currentPage < _lastPage)
                    TextButton(
                      onPressed: _skipToLastPage,
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 7),
                        backgroundColor: _primaryLight,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(999),
                        ),
                      ),
                      child: Text(
                        l.skip,
                        style: kFont(context, 
                          fontSize: 12.5,
                          fontWeight: FontWeight.w600,
                          color: _primary,
                        ),
                      ),
                    ),
                ],
              ),
            ),

            // ── Pages ──────────────────────────────────────────────────
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: _totalPages,
                onPageChanged: (i) => setState(() => _currentPage = i),
                itemBuilder: (context, index) {
                  if (index == 0) {
                    return _LanguagePage(
                      selectedCode: _selectedLanguageCode,
                      onSelect: _selectLanguage,
                    );
                  }
                  return _FeaturePage(
                    pageIndex: index - 1,
                    floatAnim: _floatAnim,
                  );
                },
              ),
            ),

            // ── Progress dots ──────────────────────────────────────────
            _DotsRow(
              count: _totalPages,
              current: _currentPage,
            ),
            const SizedBox(height: 20),

            // ── CTA buttons ────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 28),
              child: _currentPage == _lastPage
                  ? Column(
                      children: [
                        _PrimaryBtn(
                          label: _savingLanguage ? 'Saving…' : l.getStarted,
                          enabled: _selectedLanguageCode != null && !_savingLanguage,
                          onTap: _completeOnboarding,
                        ),
                        const SizedBox(height: 10),
                        _GhostBtn(
                          label: l.skip,
                          onTap: _savingLanguage ? null : _skipToHome,
                        ),
                      ],
                    )
                  : _PrimaryBtn(
                      label: l.next,
                      onTap: _goNext,
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  Feature pages
// ─────────────────────────────────────────────────────────────────────────────
class _FeaturePage extends StatelessWidget {
  const _FeaturePage({required this.pageIndex, required this.floatAnim});

  final int pageIndex;
  final Animation<double> floatAnim;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);

    final titles = [
      l.welcomeTitle1,
      l.welcomeTitle2,
      l.welcomeTitle3,
    ];

    final subtitles = [
      l.welcomeDesc1,
      l.welcomeDesc2,
      l.welcomeDesc3,
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Illustration
          _buildIllustration(context),
          const SizedBox(height: 36),
          // Text card
          Text(
            titles[pageIndex],
            textAlign: TextAlign.center,
            style: kFont(context, 
              fontSize: 26,
              fontWeight: FontWeight.w700,
              height: 1.25,
              color: _textHead,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            subtitles[pageIndex],
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: FontWeight.w400,
              height: 1.6,
              color: _textSub,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIllustration(BuildContext context) {
    final size = MediaQuery.of(context).size.width * 0.78;
    switch (pageIndex) {
      case 0:
        return _Screen1Illustration(size: size, floatAnim: floatAnim);
      case 1:
        return _Screen2Illustration(size: size);
      case 2:
        return _Screen3Illustration(size: size, floatAnim: floatAnim);
      default:
        return const SizedBox.shrink();
    }
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  Screen 1: Floating product cards
// ─────────────────────────────────────────────────────────────────────────────
class _Screen1Illustration extends StatelessWidget {
  const _Screen1Illustration({required this.size, required this.floatAnim});
  final double size;
  final Animation<double> floatAnim;

  @override
  Widget build(BuildContext context) {
    final h = size * 0.85;
    return SizedBox(
      width: size,
      height: h,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Background circle
          Container(
            width: size * 0.82,
            height: size * 0.82,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: _primaryLight,
            ),
          ),
          // Center logo
          Container(
            width: size * 0.28,
            height: size * 0.28,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: _primary.withValues(alpha: 0.25),
                  blurRadius: 24,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: ClipOval(
              child: Image.asset(
                'assets/images/Logo_KYSC.png',
                fit: BoxFit.cover,
              ),
            ),
          ),
          // Floating card top-left: Phone
          AnimatedBuilder(
            animation: floatAnim,
            builder: (context, child) => Positioned(
              top: h * 0.04 + floatAnim.value * 10,
              left: size * 0.02,
              child: _ProductCard(
                icon: Icons.phone_android_rounded,
                label: 'iPhone 15',
                price: '\$xxx',
                color: const Color(0xFF5198F5),
              ),
            ),
          ),
          // Floating card top-right: Laptop
          AnimatedBuilder(
            animation: floatAnim,
            builder: (context, child) => Positioned(
              top: h * 0.08 - floatAnim.value * 8,
              right: size * 0.0,
              child: _ProductCard(
                icon: Icons.laptop_mac_rounded,
                label: 'MacBook',
                price: '\$x,xxx',
                color: const Color(0xFFFF8A65),
              ),
            ),
          ),
          // Floating card bottom-left: Watch
          AnimatedBuilder(
            animation: floatAnim,
            builder: (context, child) => Positioned(
              bottom: h * 0.04 - floatAnim.value * 8,
              left: size * 0.0,
              child: _ProductCard(
                icon: Icons.watch_rounded,
                label: 'Apple Watch',
                price: '\$xx',
                color: const Color(0xFF34D399),
              ),
            ),
          ),
          // Floating card bottom-right: Headphones
          AnimatedBuilder(
            animation: floatAnim,
            builder: (context, child) => Positioned(
              bottom: h * 0.04 + floatAnim.value * 10,
              right: size * 0.01,
              child: _ProductCard(
                icon: Icons.headphones_rounded,
                label: 'AirPods',
                price: '\$xxx',
                color: const Color(0xFFA78BFA),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ProductCard extends StatelessWidget {
  const _ProductCard({
    required this.icon,
    required this.label,
    required this.price,
    required this.color,
  });

  final IconData icon;
  final String label;
  final String price;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 110,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: _cardWhite,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.18),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 18),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: _textHead,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            price,
            style: kFont(context, 
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  Screen 2: Shop icons grid
// ─────────────────────────────────────────────────────────────────────────────
class _Screen2Illustration extends StatelessWidget {
  const _Screen2Illustration({required this.size});
  final double size;

  @override
  Widget build(BuildContext context) {
    final h = size * 0.82;
    return SizedBox(
      width: size,
      height: h,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Big pastel circle bg
          Container(
            width: size * 0.78,
            height: size * 0.78,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: _primaryLight,
            ),
          ),
          // Central phone mock
          Container(
            width: size * 0.32,
            height: size * 0.44,
            decoration: BoxDecoration(
              color: _cardWhite,
              borderRadius: BorderRadius.circular(22),
              boxShadow: [
                BoxShadow(
                  color: _primary.withValues(alpha: 0.2),
                  blurRadius: 28,
                  offset: const Offset(0, 12),
                ),
              ],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Image.asset(
                    'assets/images/Logo_KYSC.png',
                    width: 40,
                    height: 40,
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'KY Shop',
                  style: kFont(context, 
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: _textHead,
                  ),
                ),
                const SizedBox(height: 4),
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 12),
                  height: 5,
                  decoration: BoxDecoration(
                    color: _primary,
                    borderRadius: BorderRadius.circular(99),
                  ),
                ),
                const SizedBox(height: 3),
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 18),
                  height: 5,
                  decoration: BoxDecoration(
                    color: _primaryLight,
                    borderRadius: BorderRadius.circular(99),
                  ),
                ),
              ],
            ),
          ),
          // Top icon: Cart
          Positioned(
            top: h * 0.04,
            child: _ShopIconBubble(
              icon: Icons.shopping_cart_rounded,
              label: 'Cart',
              color: _primary,
            ),
          ),
          // Left icon: Wishlist
          Positioned(
            left: size * 0.01,
            child: _ShopIconBubble(
              icon: Icons.favorite_rounded,
              label: 'Wishlist',
              color: const Color(0xFFFF6B8B),
            ),
          ),
          // Right icon: Payment
          Positioned(
            right: size * 0.01,
            child: _ShopIconBubble(
              icon: Icons.credit_card_rounded,
              label: 'Payment',
              color: _accent2,
            ),
          ),
          // Bottom icon: Lock
          Positioned(
            bottom: h * 0.04,
            child: _ShopIconBubble(
              icon: Icons.lock_rounded,
              label: 'Secure',
              color: _accent3,
            ),
          ),
          // Connecting lines (decorative arcs)
          Positioned.fill(
            child: CustomPaint(painter: _ConnectionLinePainter()),
          ),
        ],
      ),
    );
  }
}

class _ShopIconBubble extends StatelessWidget {
  const _ShopIconBubble({
    required this.icon,
    required this.label,
    required this.color,
  });

  final IconData icon;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 72,
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
      decoration: BoxDecoration(
        color: _cardWhite,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.2),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: _textSub,
            ),
          ),
        ],
      ),
    );
  }
}

class _ConnectionLinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = _primary.withValues(alpha: 0.12)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final cx = size.width / 2;
    final cy = size.height / 2;

    // Draw subtle dashed lines from center to each icon
    _drawDashedLine(canvas, paint, Offset(cx, cy), Offset(cx, cy * 0.12));
    _drawDashedLine(canvas, paint, Offset(cx, cy), Offset(cx * 0.14, cy));
    _drawDashedLine(canvas, paint, Offset(cx, cy), Offset(size.width - cx * 0.14, cy));
    _drawDashedLine(canvas, paint, Offset(cx, cy), Offset(cx, size.height - cy * 0.12));
  }

  void _drawDashedLine(Canvas canvas, Paint paint, Offset from, Offset to) {
    const dashLength = 5.0;
    const gapLength = 4.0;
    final total = (to - from).distance;
    final dir = (to - from) / total;
    double drawn = 0;
    bool dash = true;
    while (drawn < total) {
      final segLen = math.min(dash ? dashLength : gapLength, total - drawn);
      if (dash) {
        canvas.drawLine(from + dir * drawn, from + dir * (drawn + segLen), paint);
      }
      drawn += segLen;
      dash = !dash;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// ─────────────────────────────────────────────────────────────────────────────
//  Screen 3: Delivery illustration with tracking timeline
// ─────────────────────────────────────────────────────────────────────────────
class _Screen3Illustration extends StatelessWidget {
  const _Screen3Illustration({required this.size, required this.floatAnim});
  final double size;
  final Animation<double> floatAnim;

  @override
  Widget build(BuildContext context) {
    final h = size * 0.85;
    return SizedBox(
      width: size,
      height: h,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Background circle
          Container(
            width: size * 0.82,
            height: size * 0.82,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: _primaryLight,
            ),
          ),

          // Tracking timeline card
          Positioned(
            bottom: h * 0.02,
            left: 0,
            right: 0,
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 4),
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
              decoration: BoxDecoration(
                color: _cardWhite,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: _primary.withValues(alpha: 0.12),
                    blurRadius: 22,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                children: [
                  _TrackingStep(
                    icon: Icons.check_circle_rounded,
                    label: 'Order Confirmed',
                    done: true,
                  ),
                  _TrackingConnector(done: true),
                  _TrackingStep(
                    icon: Icons.inventory_2_rounded,
                    label: 'Package Ready',
                    done: true,
                  ),
                  _TrackingConnector(done: false),
                  _TrackingStep(
                    icon: Icons.electric_moped_rounded,
                    label: 'Out for Delivery',
                    done: false,
                    isCurrent: true,
                  ),
                  _TrackingConnector(done: false),
                  _TrackingStep(
                    icon: Icons.home_rounded,
                    label: 'Delivered',
                    done: false,
                  ),
                ],
              ),
            ),
          ),

          // Delivery scooter card (floating top)
          AnimatedBuilder(
            animation: floatAnim,
            builder: (context, child) => Positioned(
              top: h * 0.04 + floatAnim.value * 8,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: _primary,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: _primary.withValues(alpha: 0.4),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.electric_moped_rounded,
                        color: Colors.white, size: 26),
                    const SizedBox(width: 10),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'On the way!',
                          style: kFont(context, 
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          '~15 min away',
                          style: GoogleFonts.inter(
                            fontSize: 10,
                            color: Colors.white.withValues(alpha: 0.8),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Map pin floating badge
          Positioned(
            top: h * 0.24,
            right: size * 0.04,
            child: _MapPinBadge(),
          ),

          // Package icon badge
          Positioned(
            top: h * 0.22,
            left: size * 0.04,
            child: Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: _cardWhite,
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color: _accent2.withValues(alpha: 0.2),
                    blurRadius: 14,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Icon(Icons.inventory_2_rounded,
                  color: _accent2, size: 24),
            ),
          ),
        ],
      ),
    );
  }
}

class _TrackingStep extends StatelessWidget {
  const _TrackingStep({
    required this.icon,
    required this.label,
    required this.done,
    this.isCurrent = false,
  });

  final IconData icon;
  final String label;
  final bool done;
  final bool isCurrent;

  @override
  Widget build(BuildContext context) {
    final color = done || isCurrent ? _primary : _textMuted;
    final bgColor = done
        ? _primary.withValues(alpha: 0.12)
        : isCurrent
            ? _primary.withValues(alpha: 0.08)
            : const Color(0xFFF1F3F5);

    return Row(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: bgColor,
            shape: BoxShape.circle,
          ),
          child: Icon(icon, size: 16, color: color),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 12,
              fontWeight: isCurrent ? FontWeight.w700 : FontWeight.w500,
              color: done || isCurrent ? _textHead : _textMuted,
            ),
          ),
        ),
        if (done)
          const Icon(Icons.check_rounded, size: 14, color: _primary),
        if (isCurrent)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
            decoration: BoxDecoration(
              color: _primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(99),
            ),
            child: Text(
              'Live',
              style: kFont(context, 
                fontSize: 9,
                fontWeight: FontWeight.w700,
                color: _primary,
              ),
            ),
          ),
      ],
    );
  }
}

class _TrackingConnector extends StatelessWidget {
  const _TrackingConnector({required this.done});
  final bool done;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 15),
      child: Column(
        children: List.generate(3, (i) {
          return Container(
            width: 2,
            height: 4,
            margin: const EdgeInsets.symmetric(vertical: 1),
            decoration: BoxDecoration(
              color:
                  done ? _primary : _primary.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(99),
            ),
          );
        }),
      ),
    );
  }
}

class _MapPinBadge extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: _cardWhite,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFFF6B8B).withValues(alpha: 0.2),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: const Icon(Icons.location_on_rounded,
          color: Color(0xFFFF6B8B), size: 24),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  Language selection page
// ─────────────────────────────────────────────────────────────────────────────
class _LanguagePage extends StatelessWidget {
  const _LanguagePage({required this.selectedCode, required this.onSelect});

  static const _options = [
    _LangOption(code: 'km', label: 'ខ្មែរ', flag: '🇰🇭', name: 'Khmer'),
    _LangOption(code: 'en', label: 'English', flag: '🇺🇸', name: 'English'),
  ];

  final String? selectedCode;
  final ValueChanged<String> onSelect;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);

    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Icon
          Container(
            width: 58,
            height: 58,
            decoration: BoxDecoration(
              color: _primaryLight,
              borderRadius: BorderRadius.circular(18),
            ),
            child: const Icon(Icons.language_rounded,
                color: _primary, size: 30),
          ),
          const SizedBox(height: 20),
          Text(
            l.chooseYourLanguage,
            style: kFont(context, 
              fontSize: 30,
              fontWeight: FontWeight.w700,
              height: 1.2,
              color: _textHead,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            l.languageDesc,
            style: GoogleFonts.inter(
              fontSize: 14,
              color: _textSub,
            ),
          ),
          const SizedBox(height: 28),
          // Language options
          ...List.generate(_options.length, (i) {
            final opt = _options[i];
            final selected = selectedCode == opt.code;
            return GestureDetector(
              onTap: () => onSelect(opt.code),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.symmetric(
                    horizontal: 18, vertical: 16),
                decoration: BoxDecoration(
                  color: selected ? _primaryLight : _cardWhite,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: selected ? _primary : const Color(0xFFE5E7EB),
                    width: selected ? 1.5 : 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: selected
                          ? _primary.withValues(alpha: 0.1)
                          : Colors.black.withValues(alpha: 0.04),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Text(opt.flag,
                        style: const TextStyle(fontSize: 28)),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            opt.label,
                            style: kFont(context, 
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: _textHead,
                            ),
                          ),
                          Text(
                            opt.name,
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              color: _textSub,
                            ),
                          ),
                        ],
                      ),
                    ),
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width: 22,
                      height: 22,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: selected ? _primary : Colors.transparent,
                        border: Border.all(
                          color: selected ? _primary : const Color(0xFFD1D5DB),
                          width: 2,
                        ),
                      ),
                      child: selected
                          ? const Icon(Icons.check_rounded,
                              color: Colors.white, size: 13)
                          : null,
                    ),
                  ],
                ),
              ),
            );
          }),
          const Spacer(),
        ],
      ),
    );
  }
}

class _LangOption {
  const _LangOption({
    required this.code,
    required this.label,
    required this.flag,
    required this.name,
  });
  final String code;
  final String label;
  final String flag;
  final String name;
}

// ─────────────────────────────────────────────────────────────────────────────
//  Shared widgets
// ─────────────────────────────────────────────────────────────────────────────
class _DotsRow extends StatelessWidget {
  const _DotsRow({required this.count, required this.current});
  final int count;
  final int current;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(count, (i) {
        final active = i == current;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 280),
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: active ? 24 : 8,
          height: 8,
          decoration: BoxDecoration(
            color: active ? _primary : _dot,
            borderRadius: BorderRadius.circular(99),
          ),
        );
      }),
    );
  }
}

class _PrimaryBtn extends StatelessWidget {
  const _PrimaryBtn({
    required this.label,
    required this.onTap,
    this.enabled = true,
  });
  final String label;
  final VoidCallback? onTap;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 54,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: enabled ? _primary : _primary.withValues(alpha: 0.45),
          borderRadius: BorderRadius.circular(16),
          boxShadow: enabled
              ? [
                  BoxShadow(
                    color: _primary.withValues(alpha: 0.35),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ]
              : [],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: enabled ? onTap : null,
            child: Center(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    label,
                    style: kFont(context, 
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(width: 6),
                  const Icon(Icons.arrow_forward_rounded,
                      color: Colors.white, size: 16),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _GhostBtn extends StatelessWidget {
  const _GhostBtn({required this.label, required this.onTap});
  final String label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 46,
      child: TextButton(
        onPressed: onTap,
        style: TextButton.styleFrom(
          backgroundColor: _primaryLight,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        child: Text(
          label,
          style: kFont(context, 
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: _primary,
          ),
        ),
      ),
    );
  }
}

class _IconBtn extends StatelessWidget {
  const _IconBtn({required this.icon, required this.onTap});
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 40,
        width: 40,
        decoration: BoxDecoration(
          color: _cardWhite,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFE5E7EB)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Icon(icon, color: _textHead, size: 18),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../main_navigation_screen.dart';
import 'login_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  static const _languagePreferenceKey = 'app_language_code';

  final PageController _controller = PageController();
  int _currentPage = 0;
  String? _selectedLanguageCode;
  bool _savingLanguage = false;

  final List<_OnboardPageData> _pages = const [
    _OnboardPageData.feature(
      title: 'Find the exact tech you want',
      subtitle:
          'Browse curated devices, compare specs, and spot deals in seconds.',
      lottieAsset: 'assets/lottie/shopping.json',
      accent: Color(0xFF0EA5E9),
      glow: Color(0xFF67E8F9),
      gradient: [Color(0xFF0F172A), Color(0xFF164E63)],
    ),
    _OnboardPageData.feature(
      title: 'Save more with smart promotions',
      subtitle:
          'Unlock exclusive offers and seasonal discounts tailored for you.',
      lottieAsset: 'assets/lottie/discount.json',
      accent: Color(0xFFF97316),
      glow: Color(0xFFFBBF24),
      gradient: [Color(0xFF1E293B), Color(0xFF7C2D12)],
    ),
    _OnboardPageData.feature(
      title: 'Checkout with total confidence',
      subtitle: 'Secure payments, trusted gateways, and instant confirmation.',
      lottieAsset: 'assets/lottie/payment.json',
      accent: Color(0xFF22C55E),
      glow: Color(0xFFA7F3D0),
      gradient: [Color(0xFF0F172A), Color(0xFF064E3B)],
    ),
    _OnboardPageData.language(
      title: 'Choose language',
      subtitle: 'You can edit it later in your profile',
      accent: Color(0xFF077CB4),
      glow: Color(0xFF45AEDF),
      gradient: [Color(0xFFF8FCFF), Color(0xFFEEF6FD)],
    ),
  ];

  int get _lastPage => _pages.length - 1;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _goNext() {
    if (_currentPage >= _lastPage) return;

    _controller.nextPage(
      duration: const Duration(milliseconds: 320),
      curve: Curves.easeOutCubic,
    );
  }

  void _goBack() {
    if (_currentPage == 0) return;

    _controller.previousPage(
      duration: const Duration(milliseconds: 320),
      curve: Curves.easeOutCubic,
    );
  }

  void _skipToEnd() {
    _controller.animateToPage(
      _lastPage,
      duration: const Duration(milliseconds: 320),
      curve: Curves.easeOutCubic,
    );
  }

  void _selectLanguage(String code) {
    setState(() => _selectedLanguageCode = code);
  }

  Future<void> _persistLanguageSelection() async {
    final prefs = await SharedPreferences.getInstance();
    final languageCode = _selectedLanguageCode ?? 'en';
    await prefs.setString(_languagePreferenceKey, languageCode);
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
      if (mounted) {
        setState(() => _savingLanguage = false);
      }
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
      if (mounted) {
        setState(() => _savingLanguage = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final page = _pages[_currentPage];
    final isLanguagePage = page.isLanguage;

    return Scaffold(
      body: AnimatedContainer(
        duration: const Duration(milliseconds: 420),
        curve: Curves.easeOutCubic,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: page.gradient,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Stack(
            children: [
              if (isLanguagePage) ...[
                const Positioned(
                  top: -48,
                  right: -36,
                  child: _LanguageBackdropPattern(
                    size: 170,
                    color: Color(0xFFC2D4E9),
                  ),
                ),
                const Positioned(
                  bottom: 130,
                  left: -44,
                  child: _LanguageBackdropPattern(
                    size: 150,
                    color: Color(0xFFD5E2EF),
                    turns: 0.7,
                  ),
                ),
                const Positioned(
                  bottom: -28,
                  right: -24,
                  child: _LanguageBackdropPattern(
                    size: 130,
                    color: Color(0xFFE1D5F0),
                    turns: -0.35,
                  ),
                ),
              ] else ...[
                Positioned(
                  top: -80,
                  right: -60,
                  child: _GlowOrb(color: page.glow, size: 180),
                ),
                Positioned(
                  bottom: -100,
                  left: -40,
                  child: _GlowOrb(color: page.accent, size: 220),
                ),
              ],
              Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                    child: Row(
                      children: [
                        _currentPage > 0
                            ? _RoundIconButton(
                                icon: Icons.arrow_back_rounded,
                                onTap: _goBack,
                                light: isLanguagePage,
                              )
                            : const SizedBox(width: 44),
                        const Spacer(),
                        if (_currentPage != _lastPage)
                          _SkipPill(
                            label: 'Skip',
                            color: page.accent,
                            onTap: _skipToEnd,
                          ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: PageView.builder(
                      controller: _controller,
                      itemCount: _pages.length,
                      onPageChanged: (index) {
                        setState(() => _currentPage = index);
                      },
                      itemBuilder: (context, index) {
                        final item = _pages[index];
                        if (item.isLanguage) {
                          return _LanguageChoicePageView(
                            data: item,
                            selectedLanguageCode: _selectedLanguageCode,
                            onSelect: _selectLanguage,
                          );
                        }

                        return _OnboardPageView(data: item);
                      },
                    ),
                  ),
                  _DotsRow(
                    count: _pages.length,
                    currentIndex: _currentPage,
                    activeColor: page.accent,
                    inactiveColor: isLanguagePage
                        ? const Color(0xFFB7CADB)
                        : Colors.white.withValues(alpha: 0.35),
                  ),
                  const SizedBox(height: 18),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: _currentPage == _lastPage
                        ? Column(
                            children: [
                              _PrimaryButton(
                                text: _savingLanguage
                                    ? 'Saving...'
                                    : 'Continue',
                                gradient: [page.accent, page.glow],
                                onTap:
                                    _selectedLanguageCode == null ||
                                        _savingLanguage
                                    ? null
                                    : _completeOnboarding,
                                trailing: const Icon(
                                  Icons.keyboard_double_arrow_right_rounded,
                                  color: Colors.white,
                                  size: 18,
                                ),
                              ),
                              const SizedBox(height: 10),
                              _SecondaryActionButton(
                                text: 'Skip to Home',
                                onTap: _savingLanguage ? null : _skipToHome,
                              ),
                            ],
                          )
                        : _PrimaryButton(
                            text: 'Next',
                            gradient: [page.accent, page.glow],
                            onTap: _goNext,
                          ),
                  ),
                  const SizedBox(height: 28),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

enum _OnboardPageKind { feature, language }

class _OnboardPageData {
  const _OnboardPageData.feature({
    required this.title,
    required this.subtitle,
    required this.lottieAsset,
    required this.accent,
    required this.glow,
    required this.gradient,
  }) : kind = _OnboardPageKind.feature;

  const _OnboardPageData.language({
    required this.title,
    required this.subtitle,
    required this.accent,
    required this.glow,
    required this.gradient,
  }) : kind = _OnboardPageKind.language,
       lottieAsset = null;

  final _OnboardPageKind kind;
  final String title;
  final String subtitle;
  final String? lottieAsset;
  final Color accent;
  final Color glow;
  final List<Color> gradient;

  bool get isLanguage => kind == _OnboardPageKind.language;
}

class _OnboardPageView extends StatelessWidget {
  const _OnboardPageView({required this.data});

  final _OnboardPageData data;

  @override
  Widget build(BuildContext context) {
    final visualSize = (MediaQuery.of(context).size.width * 0.72)
        .clamp(220.0, 320.0)
        .toDouble();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            height: visualSize,
            width: visualSize,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(28),
              border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
              boxShadow: [
                BoxShadow(
                  color: data.glow.withValues(alpha: 0.35),
                  blurRadius: 40,
                  offset: const Offset(0, 18),
                ),
              ],
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                Positioned(
                  top: 20,
                  right: 18,
                  child: Container(
                    width: 54,
                    height: 54,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: data.accent.withValues(alpha: 0.25),
                    ),
                  ),
                ),
                Lottie.asset(
                  data.lottieAsset!,
                  width: visualSize * 0.68,
                  height: visualSize * 0.68,
                  fit: BoxFit.contain,
                ),
              ],
            ),
          ),
          const SizedBox(height: 26),
          Container(
            padding: const EdgeInsets.fromLTRB(18, 18, 18, 16),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.92),
              borderRadius: BorderRadius.circular(22),
              border: Border.all(color: Colors.white.withValues(alpha: 0.7)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.18),
                  blurRadius: 24,
                  offset: const Offset(0, 14),
                ),
              ],
            ),
            child: Column(
              children: [
                Container(
                  width: 46,
                  height: 4,
                  decoration: BoxDecoration(
                    color: data.accent,
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  data.title,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.sora(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF0F172A),
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  data.subtitle,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.sora(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF64748B),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _LanguageChoicePageView extends StatelessWidget {
  const _LanguageChoicePageView({
    required this.data,
    required this.selectedLanguageCode,
    required this.onSelect,
  });

  static const List<_LanguageOption> _options = [
    _LanguageOption(code: 'km', label: 'ខ្មែរ', flagEmoji: '🇰🇭'),
    _LanguageOption(code: 'en', label: 'English', flagEmoji: '🇺🇸'),
  ];

  final _OnboardPageData data;
  final String? selectedLanguageCode;
  final ValueChanged<String> onSelect;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(26, 26, 26, 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            data.title,
            style: GoogleFonts.sora(
              fontSize: 39,
              height: 1.15,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF1A739E),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            data.subtitle,
            style: GoogleFonts.sora(
              fontSize: 15,
              fontWeight: FontWeight.w500,
              color: const Color(0xFF617285),
            ),
          ),
          const SizedBox(height: 26),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
            decoration: BoxDecoration(
              color: const Color(0xFF007DB3),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF007DB3).withValues(alpha: 0.25),
                  blurRadius: 24,
                  offset: const Offset(0, 14),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Language',
                  style: GoogleFonts.sora(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Colors.white.withValues(alpha: 0.85),
                  ),
                ),
                const SizedBox(height: 8),
                for (int index = 0; index < _options.length; index++) ...[
                  _LanguageTile(
                    option: _options[index],
                    selected: selectedLanguageCode == _options[index].code,
                    onTap: () => onSelect(_options[index].code),
                  ),
                  if (index != _options.length - 1)
                    Divider(
                      color: Colors.white.withValues(alpha: 0.24),
                      thickness: 1,
                      height: 2,
                    ),
                ],
              ],
            ),
          ),
          const Spacer(),
        ],
      ),
    );
  }
}

class _LanguageTile extends StatelessWidget {
  const _LanguageTile({
    required this.option,
    required this.selected,
    required this.onTap,
  });

  final _LanguageOption option;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Row(
            children: [
              Container(
                width: 38,
                height: 38,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.85),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.12),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Text(
                  option.flagEmoji,
                  style: const TextStyle(fontSize: 21),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  option.label,
                  style: GoogleFonts.sora(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Colors.white,
                  ),
                ),
              ),
              _LanguageRadio(selected: selected),
            ],
          ),
        ),
      ),
    );
  }
}

class _LanguageRadio extends StatelessWidget {
  const _LanguageRadio({required this.selected});

  final bool selected;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      width: 25,
      height: 25,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: selected
            ? Colors.white.withValues(alpha: 0.16)
            : Colors.transparent,
        border: Border.all(
          color: Colors.white.withValues(alpha: selected ? 0.95 : 0.78),
          width: 2,
        ),
      ),
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 180),
        opacity: selected ? 1 : 0,
        child: Center(
          child: Container(
            width: 10,
            height: 10,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}

class _LanguageOption {
  const _LanguageOption({
    required this.code,
    required this.label,
    required this.flagEmoji,
  });

  final String code;
  final String label;
  final String flagEmoji;
}

class _DotsRow extends StatelessWidget {
  const _DotsRow({
    required this.count,
    required this.currentIndex,
    required this.activeColor,
    required this.inactiveColor,
  });

  final int count;
  final int currentIndex;
  final Color activeColor;
  final Color inactiveColor;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(count, (index) {
        final active = index == currentIndex;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 260),
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: active ? 20 : 7,
          height: 7,
          decoration: BoxDecoration(
            color: active ? activeColor : inactiveColor,
            borderRadius: BorderRadius.circular(999),
          ),
        );
      }),
    );
  }
}

class _PrimaryButton extends StatelessWidget {
  const _PrimaryButton({
    required this.text,
    required this.gradient,
    required this.onTap,
    this.trailing,
  });

  final String text;
  final List<Color> gradient;
  final VoidCallback? onTap;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final enabled = onTap != null;
    final colors = enabled
        ? gradient
        : const [Color(0xFFAAC3D3), Color(0xFFAAC3D3)];

    return SizedBox(
      height: 52,
      width: double.infinity,
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: colors),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.25),
              blurRadius: 16,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: onTap,
            child: Center(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    text,
                    style: GoogleFonts.sora(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: Colors.white.withValues(alpha: enabled ? 1 : 0.72),
                    ),
                  ),
                  if (trailing != null) ...[
                    const SizedBox(width: 8),
                    trailing!,
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _SecondaryActionButton extends StatelessWidget {
  const _SecondaryActionButton({required this.text, required this.onTap});

  final String text;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 46,
      child: OutlinedButton(
        onPressed: onTap,
        style: OutlinedButton.styleFrom(
          side: BorderSide(
            color: const Color(0xFF007DB3).withValues(alpha: 0.38),
            width: 1.2,
          ),
          backgroundColor: Colors.white.withValues(alpha: 0.76),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        child: Text(
          text,
          style: GoogleFonts.sora(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF0E638A),
          ),
        ),
      ),
    );
  }
}

class _RoundIconButton extends StatelessWidget {
  const _RoundIconButton({
    required this.icon,
    required this.onTap,
    this.light = false,
  });

  final IconData icon;
  final VoidCallback onTap;
  final bool light;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        height: 42,
        width: 42,
        decoration: BoxDecoration(
          color: light ? Colors.white : Colors.white.withValues(alpha: 0.18),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: light
                ? const Color(0xFFD3E4F2)
                : Colors.white.withValues(alpha: 0.4),
          ),
        ),
        child: Icon(
          icon,
          color: light ? const Color(0xFF2A6685) : Colors.white,
        ),
      ),
    );
  }
}

class _SkipPill extends StatelessWidget {
  const _SkipPill({
    required this.label,
    required this.color,
    required this.onTap,
  });

  final String label;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onTap,
      style: TextButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        backgroundColor: Colors.white.withValues(alpha: 0.16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
      ),
      child: Text(
        label,
        style: GoogleFonts.sora(
          fontSize: 12.5,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }
}

class _GlowOrb extends StatelessWidget {
  const _GlowOrb({required this.color, required this.size});

  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color.withValues(alpha: 0.22),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.3),
            blurRadius: 80,
            spreadRadius: 10,
          ),
        ],
      ),
    );
  }
}

class _LanguageBackdropPattern extends StatelessWidget {
  const _LanguageBackdropPattern({
    required this.size,
    required this.color,
    this.turns = 0,
  });

  final double size;
  final Color color;
  final double turns;

  @override
  Widget build(BuildContext context) {
    return Transform.rotate(
      angle: turns,
      child: SizedBox(
        width: size,
        height: size,
        child: CustomPaint(
          painter: _LanguageBackdropPainter(
            color: color.withValues(alpha: 0.55),
          ),
        ),
      ),
    );
  }
}

class _LanguageBackdropPainter extends CustomPainter {
  const _LanguageBackdropPainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final linePaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final nodePaint = Paint()
      ..color = color.withValues(alpha: 0.34)
      ..style = PaintingStyle.fill;

    final width = size.width;
    final height = size.height;
    final networkPath = Path()
      ..moveTo(width * 0.16, height * 0.16)
      ..lineTo(width * 0.16, height * 0.78)
      ..lineTo(width * 0.52, height * 0.78)
      ..lineTo(width * 0.52, height * 0.34)
      ..lineTo(width * 0.84, height * 0.34);

    final boltPath = Path()
      ..moveTo(width * 0.28, height * 0.92)
      ..lineTo(width * 0.44, height * 0.62)
      ..lineTo(width * 0.34, height * 0.62)
      ..lineTo(width * 0.5, height * 0.43);

    canvas.drawPath(networkPath, linePaint);
    canvas.drawCircle(
      Offset(width * 0.16, height * 0.16),
      width * 0.055,
      linePaint,
    );
    canvas.drawCircle(
      Offset(width * 0.52, height * 0.34),
      width * 0.055,
      linePaint,
    );
    canvas.drawCircle(
      Offset(width * 0.84, height * 0.34),
      width * 0.055,
      linePaint,
    );
    canvas.drawCircle(
      Offset(width * 0.52, height * 0.78),
      width * 0.05,
      nodePaint,
    );
    canvas.drawPath(boltPath, linePaint);
  }

  @override
  bool shouldRepaint(covariant _LanguageBackdropPainter oldDelegate) {
    return oldDelegate.color != color;
  }
}

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';
import 'login_screen.dart';
import '../main_navigation_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _controller = PageController();
  int _currentPage = 0;

  final List<_OnboardPageData> _pages = const [
    _OnboardPageData(
      title: 'Find the exact tech you want',
      subtitle:
          'Browse curated devices, compare specs, and spot deals in seconds.',
      lottieAsset: 'assets/lottie/shopping.json',
      accent: Color(0xFF0EA5E9),
      glow: Color(0xFF67E8F9),
      gradient: [Color(0xFF0F172A), Color(0xFF164E63)],
    ),
    _OnboardPageData(
      title: 'Save more with smart promotions',
      subtitle:
          'Unlock exclusive offers and seasonal discounts tailored for you.',
      lottieAsset: 'assets/lottie/discount.json',
      accent: Color(0xFFF97316),
      glow: Color(0xFFFBBF24),
      gradient: [Color(0xFF1E293B), Color(0xFF7C2D12)],
    ),
    _OnboardPageData(
      title: 'Checkout with total confidence',
      subtitle:
          'Secure payments, trusted gateways, and instant confirmation.',
      lottieAsset: 'assets/lottie/payment.json',
      accent: Color(0xFF22C55E),
      glow: Color(0xFFA7F3D0),
      gradient: [Color(0xFF0F172A), Color(0xFF064E3B)],
    ),
  ];

  int get _lastPage => _pages.length - 1;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _goNext() {
    _controller.nextPage(
      duration: const Duration(milliseconds: 320),
      curve: Curves.easeOutCubic,
    );
  }

  void _goBack() {
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

  @override
  Widget build(BuildContext context) {
    final page = _pages[_currentPage];

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
                        return _OnboardPageView(data: _pages[index]);
                      },
                    ),
                  ),
                  _DotsRow(
                    count: _pages.length,
                    currentIndex: _currentPage,
                    activeColor: page.accent,
                  ),
                  const SizedBox(height: 18),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: _currentPage == _lastPage
                        ? Row(
                            children: [
                              Expanded(
                                child: _SecondaryButton(
                                  text: 'Login',
                                  color: page.accent,
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => const LoginScreen(),
                                      ),
                                    );
                                  },
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _PrimaryButton(
                                  text: 'Get Started',
                                  gradient: [page.accent, page.glow],
                                  onTap: () {
                                    Navigator.pushReplacement(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) =>
                                            const MainNavigationScreen(),
                                      ),
                                    );
                                  },
                                ),
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

class _OnboardPageData {
  const _OnboardPageData({
    required this.title,
    required this.subtitle,
    required this.lottieAsset,
    required this.accent,
    required this.glow,
    required this.gradient,
  });

  final String title;
  final String subtitle;
  final String lottieAsset;
  final Color accent;
  final Color glow;
  final List<Color> gradient;
}

class _OnboardPageView extends StatelessWidget {
  const _OnboardPageView({required this.data});

  final _OnboardPageData data;

  @override
  Widget build(BuildContext context) {
    final visualSize =
        (MediaQuery.of(context).size.width * 0.72).clamp(220.0, 320.0).toDouble();

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
                  data.lottieAsset,
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

class _DotsRow extends StatelessWidget {
  const _DotsRow({
    required this.count,
    required this.currentIndex,
    required this.activeColor,
  });

  final int count;
  final int currentIndex;
  final Color activeColor;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        count,
        (index) {
          final active = index == currentIndex;
          return AnimatedContainer(
            duration: const Duration(milliseconds: 260),
            margin: const EdgeInsets.symmetric(horizontal: 4),
            width: active ? 20 : 7,
            height: 7,
            decoration: BoxDecoration(
              color: active
                  ? activeColor
                  : Colors.white.withValues(alpha: 0.35),
              borderRadius: BorderRadius.circular(999),
            ),
          );
        },
      ),
    );
  }
}

class _PrimaryButton extends StatelessWidget {
  const _PrimaryButton({
    required this.text,
    required this.gradient,
    required this.onTap,
  });

  final String text;
  final List<Color> gradient;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 52,
      width: double.infinity,
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: gradient),
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
              child: Text(
                text,
                style: GoogleFonts.sora(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _SecondaryButton extends StatelessWidget {
  const _SecondaryButton({
    required this.text,
    required this.color,
    required this.onTap,
  });

  final String text;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 52,
      child: OutlinedButton(
        onPressed: onTap,
        style: OutlinedButton.styleFrom(
          foregroundColor: Colors.white,
          side: BorderSide(color: Colors.white.withValues(alpha: 0.7), width: 1.2),
          backgroundColor: Colors.white.withValues(alpha: 0.12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
        child: Text(
          text,
          style: GoogleFonts.sora(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: color,
          ),
        ),
      ),
    );
  }
}

class _RoundIconButton extends StatelessWidget {
  const _RoundIconButton({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        height: 42,
        width: 42,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.18),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.white.withValues(alpha: 0.4)),
        ),
        child: Icon(icon, color: Colors.white),
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

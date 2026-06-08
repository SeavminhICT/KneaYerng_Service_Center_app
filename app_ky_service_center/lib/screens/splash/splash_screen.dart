import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

const kSplashDuration = Duration(milliseconds: 3400);

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late final AnimationController _main;
  late final AnimationController _rotate;
  late final AnimationController _float;
  late final AnimationController _pulse;

  // Orb pop-in
  late final Animation<double> _orb1Scale;
  late final Animation<double> _orb1Opacity;
  late final Animation<double> _orb2Scale;
  late final Animation<double> _orb2Opacity;

  // Badge slide from top
  late final Animation<double> _badgeOpacity;
  late final Animation<Offset> _badgeSlide;

  // Logo pop-in
  late final Animation<double> _logoScale;
  late final Animation<double> _logoOpacity;

  // Text
  late final Animation<double> _titleOpacity;
  late final Animation<Offset> _titleSlide;
  late final Animation<double> _taglineOpacity;
  late final Animation<Offset> _taglineSlide;

  // Loading
  late final Animation<double> _loadOpacity;
  late final Animation<double> _progress;

  @override
  void initState() {
    super.initState();
    _main  = AnimationController(duration: kSplashDuration, vsync: this)..forward();
    _rotate = AnimationController(duration: const Duration(seconds: 6), vsync: this)..repeat();
    _float  = AnimationController(duration: const Duration(milliseconds: 2200), vsync: this)..repeat(reverse: true);
    _pulse  = AnimationController(duration: const Duration(milliseconds: 1600), vsync: this)..repeat(reverse: true);

    _orb1Scale = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _main, curve: const Interval(0.00, 0.32, curve: Curves.elasticOut)),
    );
    _orb1Opacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _main, curve: const Interval(0.00, 0.18, curve: Curves.easeOut)),
    );
    _orb2Scale = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _main, curve: const Interval(0.04, 0.38, curve: Curves.elasticOut)),
    );
    _orb2Opacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _main, curve: const Interval(0.04, 0.22, curve: Curves.easeOut)),
    );

    _badgeOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _main, curve: const Interval(0.08, 0.30, curve: Curves.easeOut)),
    );
    _badgeSlide = Tween<Offset>(begin: const Offset(0, -1.8), end: Offset.zero).animate(
      CurvedAnimation(parent: _main, curve: const Interval(0.08, 0.34, curve: Curves.easeOutBack)),
    );

    _logoScale = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _main, curve: const Interval(0.22, 0.62, curve: Curves.elasticOut)),
    );
    _logoOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _main, curve: const Interval(0.22, 0.40, curve: Curves.easeOut)),
    );

    _titleOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _main, curve: const Interval(0.52, 0.74, curve: Curves.easeOutCubic)),
    );
    _titleSlide = Tween<Offset>(begin: const Offset(0, 0.6), end: Offset.zero).animate(
      CurvedAnimation(parent: _main, curve: const Interval(0.52, 0.74, curve: Curves.easeOutCubic)),
    );
    _taglineOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _main, curve: const Interval(0.64, 0.84, curve: Curves.easeOut)),
    );
    _taglineSlide = Tween<Offset>(begin: const Offset(0, 0.6), end: Offset.zero).animate(
      CurvedAnimation(parent: _main, curve: const Interval(0.64, 0.84, curve: Curves.easeOut)),
    );

    _loadOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _main, curve: const Interval(0.76, 0.92, curve: Curves.easeOut)),
    );
    _progress = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _main, curve: const Interval(0.0, 1.0, curve: Curves.easeInOut)),
    );
  }

  @override
  void dispose() {
    _main.dispose();
    _rotate.dispose();
    _float.dispose();
    _pulse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final floatOffset = _float.value * 9.0;

    return Scaffold(
      body: AnimatedBuilder(
        animation: Listenable.merge([_main, _rotate, _float, _pulse]),
        builder: (context, _) => Stack(
          children: [
            // ── Background ───────────────────────────────────────────────
            Positioned.fill(
              child: DecoratedBox(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color(0xFF2233EE),
                      Color(0xFF3B44F2),
                      Color(0xFF5535E8),
                      Color(0xFF7B1FCC),
                    ],
                    stops: [0.0, 0.30, 0.62, 1.0],
                  ),
                ),
              ),
            ),

            // ── Dark concentric orb — top right ──────────────────────────
            Positioned(
              top: size.height * 0.03,
              right: -size.width * 0.08,
              child: Transform.scale(
                scale: _orb1Scale.value.clamp(0, 1),
                alignment: Alignment.topRight,
                child: Opacity(
                  opacity: _orb1Opacity.value,
                  child: SizedBox(
                    width: 130,
                    height: 130,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Container(
                          width: 130,
                          height: 130,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: const Color(0xFF1A1870).withValues(alpha: 0.85),
                          ),
                        ),
                        Container(
                          width: 100,
                          height: 100,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: const Color(0xFF1A1A88).withValues(alpha: 0.7),
                          ),
                        ),
                        Container(
                          width: 68,
                          height: 68,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: const Color(0xFF2222AA).withValues(alpha: 0.6),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            // ── Purple glow orb — bottom left ────────────────────────────
            Positioned(
              bottom: -size.height * 0.05,
              left: -size.width * 0.12,
              child: Opacity(
                opacity: _orb2Opacity.value * 0.7,
                child: Transform.scale(
                  scale: _orb2Scale.value.clamp(0, 1),
                  alignment: Alignment.bottomLeft,
                  child: Container(
                    width: 220,
                    height: 220,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          const Color(0xFF7B1FCC).withValues(alpha: 0.65),
                          const Color(0xFF5530EE).withValues(alpha: 0.15),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),

            // ── Main content ─────────────────────────────────────────────
            SafeArea(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Spacer(flex: 4),

                  // Badge pill
                  FadeTransition(
                    opacity: _badgeOpacity,
                    child: SlideTransition(
                      position: _badgeSlide,
                      child: _BadgePill(),
                    ),
                  ),

                  const SizedBox(height: 36),

                  // Logo — floating
                  Transform.translate(
                    offset: Offset(0, -floatOffset),
                    child: Opacity(
                      opacity: _logoOpacity.value.clamp(0, 1),
                      child: Transform.scale(
                        scale: _logoScale.value.clamp(0, 1.06),
                        child: _LogoCard(
                          rotateValue: _rotate.value,
                          pulseValue: _pulse.value,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 48),

                  // Title
                  FadeTransition(
                    opacity: _titleOpacity,
                    child: SlideTransition(
                      position: _titleSlide,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 28),
                        child: Text(
                          'KneaYerng Service Center',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.spaceGrotesk(
                            fontSize: 30,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.8,
                            height: 1.15,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 10),

                  // Tagline
                  FadeTransition(
                    opacity: _taglineOpacity,
                    child: SlideTransition(
                      position: _taglineSlide,
                      child: Text(
                        'Repair  ·  Shop  ·  Track',
                        style: GoogleFonts.dmSans(
                          fontSize: 13,
                          fontWeight: FontWeight.w400,
                          letterSpacing: 1.6,
                          color: Colors.white.withValues(alpha: 0.55),
                        ),
                      ),
                    ),
                  ),

                  const Spacer(flex: 3),

                  // Loading
                  FadeTransition(
                    opacity: _loadOpacity,
                    child: _LoadBar(progress: _progress.value),
                  ),
                  const SizedBox(height: 50),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Badge pill ────────────────────────────────────────────────────────────────

class _BadgePill extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(999),
        color: Colors.white.withValues(alpha: 0.12),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.30),
          width: 1.2,
        ),
      ),
      child: Text(
        'KY SERVICE CENTER',
        style: GoogleFonts.spaceGrotesk(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          letterSpacing: 3.0,
          color: Colors.white,
        ),
      ),
    );
  }
}

// ── Logo card ─────────────────────────────────────────────────────────────────

class _LogoCard extends StatelessWidget {
  const _LogoCard({required this.rotateValue, required this.pulseValue});
  final double rotateValue;
  final double pulseValue;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 210,
      height: 210,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Outer glow
          Container(
            width: 200 + pulseValue * 10,
            height: 200 + pulseValue * 10,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  Colors.white.withValues(alpha: pulseValue * 0.10 + 0.04),
                  Colors.transparent,
                ],
              ),
            ),
          ),
          // Rotating gradient arc
          Transform.rotate(
            angle: rotateValue * 2 * math.pi,
            child: CustomPaint(
              size: const Size(186, 186),
              painter: _ArcPainter(),
            ),
          ),
          // Glass container (rounded square)
          Container(
            width: 172,
            height: 172,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(40),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.white.withValues(alpha: 0.28),
                  Colors.white.withValues(alpha: 0.10),
                ],
              ),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.28),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF2244FF).withValues(alpha: 0.50),
                  blurRadius: 50,
                  spreadRadius: -6,
                ),
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.15),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            // Inner white circle logo
            child: Center(
              child: Container(
                width: 108,
                height: 108,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.white.withValues(alpha: 0.40),
                      blurRadius: 18,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(14),
                child: Image.asset(
                  'assets/images/Logo_KYSC.png',
                  fit: BoxFit.contain,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Arc painter ───────────────────────────────────────────────────────────────

class _ArcPainter extends CustomPainter {
  const _ArcPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    const segments = 36;
    const sweep = math.pi * 1.7;
    const start = -math.pi / 2;
    const segAngle = sweep / segments;

    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.2
      ..strokeCap = StrokeCap.round;

    final rect = Rect.fromCircle(center: center, radius: radius);
    for (int i = 0; i < segments; i++) {
      final t = i / segments;
      paint.color = Color.lerp(
        Colors.white.withValues(alpha: 0),
        Colors.white.withValues(alpha: 0.80),
        t,
      )!;
      canvas.drawArc(rect, start + i * segAngle, segAngle + 0.02, false, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _ArcPainter old) => false;
}

// ── Load bar ──────────────────────────────────────────────────────────────────

class _LoadBar extends StatelessWidget {
  const _LoadBar({required this.progress});
  final double progress;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(999),
          child: SizedBox(
            width: 110,
            height: 3,
            child: Stack(
              children: [
                Positioned.fill(
                  child: ColoredBox(color: Colors.white.withValues(alpha: 0.15)),
                ),
                FractionallySizedBox(
                  widthFactor: progress.clamp(0.04, 1.0),
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color.fromARGB(255, 245, 101, 101), Color(0xFFCCBBFF)],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.white.withValues(alpha: 0.7),
                          blurRadius: 8,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        Text(
          'LOADING',
          style: GoogleFonts.spaceGrotesk(
            fontSize: 10,
            fontWeight: FontWeight.w600,
            letterSpacing: 3.5,
            color: Colors.white.withValues(alpha: 0.30),
          ),
        ),
      ],
    );
  }
}

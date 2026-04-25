import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

const kSplashDuration = Duration(milliseconds: 2500);

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _badgeOpacity;
  late final Animation<double> _backgroundDrift;
  late final Animation<double> _footerOpacity;
  late final Animation<double> _logoOpacity;
  late final Animation<double> _logoScale;
  late final Animation<double> _orbitRotation;
  late final Animation<double> _taglineOpacity;
  late final Animation<double> _taglineOffset;
  late final Animation<double> _titleOpacity;
  late final Animation<double> _particleProgress;
  late final Animation<double> _glowPulse;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(duration: kSplashDuration, vsync: this)
      ..forward();
    _badgeOpacity = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.18, 0.42, curve: Curves.easeOutCubic),
    );
    _backgroundDrift = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOutSine,
    );
    _footerOpacity = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.72, 0.98, curve: Curves.easeOut),
    );
    _logoOpacity = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.08, 0.3, curve: Curves.easeOut),
    );
    _logoScale = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.12, 0.56, curve: Curves.elasticOut),
      ),
    );
    _orbitRotation = Tween<double>(begin: -0.08, end: 1).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.22, 1, curve: Curves.easeInOutCubic),
      ),
    );
    _taglineOpacity = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.56, 0.9, curve: Curves.easeOutCubic),
    );
    _taglineOffset = Tween<double>(begin: 18, end: 0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.56, 0.9, curve: Curves.easeOutCubic),
      ),
    );
    _titleOpacity = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.24, 0.5, curve: Curves.easeOutCubic),
    );
    _particleProgress = CurvedAnimation(
      parent: _controller,
      curve: Curves.linear,
    );
    _glowPulse = Tween<double>(begin: 0.9, end: 1.08).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.18, 0.72, curve: Curves.easeInOutSine),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          final drift = (_backgroundDrift.value - 0.5) * 2;
          final logoFloat = math.sin(_controller.value * math.pi * 1.35) * 6;
          final orbitScale = 0.92 + (_controller.value * 0.08);

          return DecoratedBox(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFF1E6EFF),
                  Color(0xFF4E5DFF),
                  Color(0xFF7E49FF),
                ],
              ),
            ),
            child: Stack(
              fit: StackFit.expand,
              children: [
                Positioned.fill(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.white.withValues(alpha: 0.06),
                          Colors.transparent,
                          Colors.black.withValues(alpha: 0.05),
                        ],
                        stops: const [0, 0.42, 1],
                      ),
                    ),
                  ),
                ),
                Positioned.fill(
                  child: CustomPaint(
                    painter: _ParticleFieldPainter(
                      progress: _particleProgress.value,
                    ),
                  ),
                ),
                Align(
                  alignment: Alignment(-0.9 + (drift * 0.22), -0.96),
                  child: _AmbientGlow(
                    size: 240,
                    color: Colors.white.withValues(alpha: 0.1),
                    scale: _glowPulse.value * 1.05,
                  ),
                ),
                Align(
                  alignment: Alignment(0.92 - (drift * 0.18), 0.9),
                  child: _AmbientGlow(
                    size: 280,
                    color: const Color(0xFF9AD5FF).withValues(alpha: 0.12),
                    scale: 1.12 - ((_glowPulse.value - 1) * 0.5),
                  ),
                ),
                Align(
                  alignment: Alignment(0.68 + (drift * 0.12), -0.3),
                  child: _AmbientGlow(
                    size: 180,
                    color: const Color(0xFFC9C3FF).withValues(alpha: 0.08),
                    scale: 1 + ((_glowPulse.value - 1) * 0.7),
                  ),
                ),
                SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 24,
                    ),
                    child: Column(
                      children: [
                        const Spacer(flex: 3),
                        Opacity(
                          opacity: _badgeOpacity.value.clamp(0, 1),
                          child: const _SplashBadge(label: 'KY SERVICE CENTER'),
                        ),
                        const SizedBox(height: 22),
                        Opacity(
                          opacity: _logoOpacity.value.clamp(0, 1),
                          child: Transform.translate(
                            offset: Offset(0, logoFloat),
                            child: Transform.scale(
                              scale: _logoScale.value,
                              child: Stack(
                                alignment: Alignment.center,
                                children: [
                                  _OrbitRing(
                                    progress: _orbitRotation.value,
                                    scale: orbitScale,
                                  ),
                                  const _LogoMark(),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 28),
                        Opacity(
                          opacity: _titleOpacity.value.clamp(0, 1),
                          child: Text(
                            'KneaYerng Service Center',
                            textAlign: TextAlign.center,
                            style: GoogleFonts.spaceGrotesk(
                              fontSize: 29,
                              fontWeight: FontWeight.w700,
                              height: 1.02,
                              letterSpacing: -0.9,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Opacity(
                          opacity: _taglineOpacity.value.clamp(0, 1),
                          child: Transform.translate(
                            offset: Offset(0, _taglineOffset.value),
                            child: Text(
                              'Repair, shop, and track with confidence',
                              textAlign: TextAlign.center,
                              style: GoogleFonts.dmSans(
                                fontSize: 14.5,
                                fontWeight: FontWeight.w500,
                                height: 1.45,
                                letterSpacing: 0.2,
                                color: Colors.white.withValues(alpha: 0.84),
                              ),
                            ),
                          ),
                        ),
                        const Spacer(flex: 2),
                        Opacity(
                          opacity: _footerOpacity.value.clamp(0, 1),
                          child: _SplashFooter(progress: _controller.value),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _SplashBadge extends StatelessWidget {
  const _SplashBadge({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: Colors.white.withValues(alpha: 0.16)),
      ),
      child: Text(
        label,
        style: GoogleFonts.dmSans(
          fontSize: 10.5,
          fontWeight: FontWeight.w700,
          letterSpacing: 1.8,
          color: Colors.white.withValues(alpha: 0.84),
        ),
      ),
    );
  }
}

class _OrbitRing extends StatelessWidget {
  const _OrbitRing({required this.progress, required this.scale});

  final double progress;
  final double scale;

  @override
  Widget build(BuildContext context) {
    return Transform.rotate(
      angle: progress * math.pi * 2,
      child: Transform.scale(
        scale: scale,
        child: SizedBox(
          width: 176,
          height: 176,
          child: CustomPaint(painter: _OrbitRingPainter()),
        ),
      ),
    );
  }
}

class _SplashFooter extends StatelessWidget {
  const _SplashFooter({required this.progress});

  final double progress;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'Loading your experience',
          style: GoogleFonts.dmSans(
            fontSize: 12.5,
            fontWeight: FontWeight.w600,
            color: Colors.white.withValues(alpha: 0.72),
          ),
        ),
        const SizedBox(height: 14),
        ClipRRect(
          borderRadius: BorderRadius.circular(999),
          child: SizedBox(
            width: 110,
            height: 4,
            child: Stack(
              children: [
                Positioned.fill(
                  child: ColoredBox(
                    color: Colors.white.withValues(alpha: 0.16),
                  ),
                ),
                FractionallySizedBox(
                  widthFactor: progress.clamp(0.08, 1),
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.white.withValues(alpha: 0.92),
                          const Color(0xFFD6C9FF),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _LogoMark extends StatelessWidget {
  const _LogoMark();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 132,
      height: 132,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(34),
        border: Border.all(color: Colors.white.withValues(alpha: 0.24)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 36,
            offset: const Offset(0, 18),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: Image.asset('assets/images/Logo_KYSC.png', fit: BoxFit.contain),
      ),
    );
  }
}

class _AmbientGlow extends StatelessWidget {
  const _AmbientGlow({
    required this.size,
    required this.color,
    required this.scale,
  });

  final double size;
  final Color color;
  final double scale;

  @override
  Widget build(BuildContext context) {
    return Transform.scale(
      scale: scale,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(colors: [color, color.withValues(alpha: 0)]),
        ),
      ),
    );
  }
}

class _OrbitRingPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final radius = size.width * 0.43;
    final ringRect = Rect.fromCircle(center: center, radius: radius);

    final basePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2
      ..color = Colors.white.withValues(alpha: 0.12);

    final arcPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 2.4
      ..shader = const LinearGradient(
        colors: [Color(0xFFFFFFFF), Color(0xFFCBE0FF), Color(0xFFD7C7FF)],
      ).createShader(ringRect);

    canvas.drawCircle(center, radius, basePaint);
    canvas.drawArc(ringRect, -math.pi * 0.35, math.pi * 0.88, false, arcPaint);

    final dotPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.85)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);
    final accentPaint = Paint()
      ..color = const Color(0xFFD7C7FF).withValues(alpha: 0.9)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);

    final majorDot = Offset(
      center.dx + (radius * math.cos(-math.pi * 0.35)),
      center.dy + (radius * math.sin(-math.pi * 0.35)),
    );
    final minorDot = Offset(
      center.dx + (radius * math.cos(math.pi * 0.53)),
      center.dy + (radius * math.sin(math.pi * 0.53)),
    );

    canvas.drawCircle(majorDot, 5, dotPaint);
    canvas.drawCircle(minorDot, 3.2, accentPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}

class _ParticleFieldPainter extends CustomPainter {
  const _ParticleFieldPainter({required this.progress});

  final double progress;

  static const List<_ParticleSpec> _particles = [
    _ParticleSpec(
      xFactor: 0.14,
      yFactor: 0.82,
      radius: 2.4,
      driftX: 0.03,
      riseFactor: 0.12,
      opacity: 0.28,
      phase: 0.1,
    ),
    _ParticleSpec(
      xFactor: 0.26,
      yFactor: 0.72,
      radius: 3.1,
      driftX: -0.02,
      riseFactor: 0.14,
      opacity: 0.22,
      phase: 0.33,
    ),
    _ParticleSpec(
      xFactor: 0.39,
      yFactor: 0.9,
      radius: 2.0,
      driftX: 0.025,
      riseFactor: 0.17,
      opacity: 0.18,
      phase: 0.56,
    ),
    _ParticleSpec(
      xFactor: 0.52,
      yFactor: 0.76,
      radius: 4.2,
      driftX: 0.018,
      riseFactor: 0.1,
      opacity: 0.14,
      phase: 0.74,
    ),
    _ParticleSpec(
      xFactor: 0.64,
      yFactor: 0.68,
      radius: 2.7,
      driftX: -0.026,
      riseFactor: 0.15,
      opacity: 0.24,
      phase: 0.28,
    ),
    _ParticleSpec(
      xFactor: 0.77,
      yFactor: 0.84,
      radius: 3.6,
      driftX: 0.016,
      riseFactor: 0.13,
      opacity: 0.19,
      phase: 0.48,
    ),
    _ParticleSpec(
      xFactor: 0.86,
      yFactor: 0.62,
      radius: 2.2,
      driftX: -0.022,
      riseFactor: 0.12,
      opacity: 0.2,
      phase: 0.67,
    ),
    _ParticleSpec(
      xFactor: 0.2,
      yFactor: 0.46,
      radius: 3.8,
      driftX: 0.014,
      riseFactor: 0.08,
      opacity: 0.12,
      phase: 0.92,
    ),
    _ParticleSpec(
      xFactor: 0.72,
      yFactor: 0.38,
      radius: 2.9,
      driftX: -0.01,
      riseFactor: 0.09,
      opacity: 0.11,
      phase: 0.15,
    ),
  ];

  @override
  void paint(Canvas canvas, Size size) {
    for (final particle in _particles) {
      final wave = math.sin((progress * math.pi * 2) + (particle.phase * 9));
      final shimmer = ((wave + 1) / 2).clamp(0.2, 1.0);
      final x =
          (size.width * particle.xFactor) +
          (size.width * particle.driftX * wave);
      final y =
          (size.height * particle.yFactor) -
          (size.height * particle.riseFactor * progress) +
          (wave * 8);

      final paint = Paint()
        ..color = Colors.white.withValues(alpha: particle.opacity * shimmer)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);

      canvas.drawCircle(Offset(x, y), particle.radius, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _ParticleFieldPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}

class _ParticleSpec {
  const _ParticleSpec({
    required this.xFactor,
    required this.yFactor,
    required this.radius,
    required this.driftX,
    required this.riseFactor,
    required this.opacity,
    required this.phase,
  });

  final double xFactor;
  final double yFactor;
  final double radius;
  final double driftX;
  final double riseFactor;
  final double opacity;
  final double phase;
}

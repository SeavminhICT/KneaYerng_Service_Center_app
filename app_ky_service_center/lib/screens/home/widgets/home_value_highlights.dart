import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hugeicons/hugeicons.dart';

import '../../../theme/app_fonts.dart';
import 'home_colors.dart';

/// Auto-scrolling marquee of "why choose us" highlight cards shown on the
/// home screen. Owns its own scroll/animation controllers since the
/// marquee state is purely local UI behaviour.
class HomeValueHighlights extends StatefulWidget {
  const HomeValueHighlights({super.key});

  @override
  State<HomeValueHighlights> createState() => _HomeValueHighlightsState();
}

class _HomeValueHighlightsState extends State<HomeValueHighlights>
    with SingleTickerProviderStateMixin {
  static const _items = [
    (
      icon: HugeIcons.strokeRoundedShieldUser,
      title: '100% Original',
      subtitle: 'Genuine Apple products',
    ),
    (
      icon: HugeIcons.strokeRoundedMedal01,
      title: 'Warranty',
      subtitle: 'Official product support',
    ),
    (
      icon: HugeIcons.strokeRoundedTruck,
      title: 'Fast Delivery',
      subtitle: 'Quick and safe shipping',
    ),
    (
      icon: HugeIcons.strokeRoundedHeadset,
      title: 'Expert Support',
      subtitle: 'Service team ready to help',
    ),
    (
      icon: HugeIcons.strokeRoundedTag01,
      title: 'Best Prices',
      subtitle: 'Unbeatable deals daily',
    ),
    (
      icon: HugeIcons.strokeRoundedLock,
      title: 'Secure Pay',
      subtitle: 'Safe & encrypted checkout',
    ),
  ];

  static const int _repeat = 5;
  static const double _cardWidth = 148;
  static const double _gap = 10;
  static const double _scrollPx = 0.55;
  static const Duration _tick = Duration(milliseconds: 16);

  late final ScrollController _scrollCtrl;
  late final AnimationController _dotCtrl;
  late final Animation<double> _dotAnim;
  double _singleSetWidth = 0;

  @override
  void initState() {
    super.initState();
    _scrollCtrl = ScrollController();
    _dotCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);
    _dotAnim = CurvedAnimation(parent: _dotCtrl, curve: Curves.easeInOut);
    WidgetsBinding.instance.addPostFrameCallback((_) => _startMarquee());
  }

  void _startMarquee() {
    if (!mounted) return;
    _singleSetWidth = (_cardWidth + _gap) * _items.length;
    Future.doWhile(() async {
      await Future.delayed(_tick);
      if (!mounted || !_scrollCtrl.hasClients) return false;
      final pos = _scrollCtrl.offset + _scrollPx;
      final maxPos = _scrollCtrl.position.maxScrollExtent;
      if (pos >= _singleSetWidth) {
        _scrollCtrl.jumpTo(pos - _singleSetWidth);
      } else if (pos >= maxPos) {
        _scrollCtrl.jumpTo(0);
      } else {
        _scrollCtrl.jumpTo(pos);
      }
      return true;
    });
  }

  @override
  void dispose() {
    _scrollCtrl.dispose();
    _dotCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = homeIsDark(context);
    final allItems = List.generate(
      _items.length * _repeat,
      (i) => _items[i % _items.length],
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Section header ─────────────────────────────────────────────
        Padding(
          padding: const EdgeInsets.only(left: 2, bottom: 12),
          child: Row(
            children: [
              FadeTransition(
                opacity: _dotAnim,
                child: Container(
                  width: 7,
                  height: 7,
                  decoration: const BoxDecoration(
                    color: homePrimary,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                'Why Choose Us',
                style: kmFont(context, GoogleFonts.manrope(
                  fontSize: 14.5,
                  fontWeight: FontWeight.w700,
                  color: homeTextPrimary(context),
                )),
              ),
            ],
          ),
        ),

        // ── Marquee strip ───────────────────────────────────────────────
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: homeCardBorder(context)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: isDark ? 0.14 : 0.05),
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: ShaderMask(
              shaderCallback: (bounds) => const LinearGradient(
                colors: [
                  Colors.transparent,
                  Colors.white,
                  Colors.white,
                  Colors.transparent,
                ],
                stops: [0.0, 0.07, 0.93, 1.0],
              ).createShader(bounds),
              blendMode: BlendMode.dstIn,
              child: SizedBox(
                height: 142,
                child: ListView.separated(
                  controller: _scrollCtrl,
                  scrollDirection: Axis.horizontal,
                  physics: const NeverScrollableScrollPhysics(),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  itemCount: allItems.length,
                  separatorBuilder: (context, index) => SizedBox(width: _gap),
                  itemBuilder: (context, index) {
                    final item = allItems[index];
                    return SizedBox(
                      width: _cardWidth,
                      child: _HighlightCard(
                        icon: item.icon,
                        title: item.title,
                        subtitle: item.subtitle,
                        isDark: isDark,
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// ── Highlight card – clean minimal ────────────────────────────────────────
class _HighlightCard extends StatelessWidget {
  const _HighlightCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.isDark,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: homeSurfaceAlt(context),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: homeCardBorder(context)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Icon box – single accent tint, no gradient
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: homePrimary.withValues(alpha: isDark ? 0.18 : 0.09),
              borderRadius: BorderRadius.circular(11),
            ),
            child: Icon(icon, size: 20, color: homePrimary),
          ),
          const Spacer(),
          // Title
          Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: kmFont(context, GoogleFonts.manrope(
              fontSize: 12.5,
              fontWeight: FontWeight.w700,
              color: homeTextPrimary(context),
              height: 1.2,
            )),
          ),
          const SizedBox(height: 2),
          // Subtitle
          Text(
            subtitle,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: kmFont(context, GoogleFonts.manrope(
              fontSize: 10.5,
              fontWeight: FontWeight.w500,
              color: homeTextMuted(context),
              height: 1.35,
            )),
          ),
        ],
      ),
    );
  }
}

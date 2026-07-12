import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';

import '../../l10n/app_localizations.dart';
import '../../theme/app_fonts.dart';
import '../../theme/app_palette.dart';
import '../../widgets/page_transitions.dart';
import '../main_navigation_screen.dart';
import 'login_screen.dart';

class RegistrationSuccessScreen extends StatelessWidget {
  const RegistrationSuccessScreen({super.key});

  static const _backgroundTop = Color(0xFFFFF6ED);
  static const _backgroundMid = Color(0xFFF6FAFF);
  static const _backgroundBottom = Color(0xFFEEF6FD);
  static const _surface = AppPalette.surface;
  static const _surfaceWarm = Color(0xFFFFF4EC);
  static const _border = Color(0xFFE5EAF2);
  static const _textPrimary = Color(0xFF111827);
  static const _textSecondary = Color(0xFF667085);
  static const _orange = AppPalette.primary;
  static const _orangeDark = Color(0xFFE86412);
  static const _success = AppPalette.success;

  void _openApp(BuildContext context) {
    Navigator.of(context).pushAndRemoveUntil(
      fadeSlideRoute(const MainNavigationScreen()),
      (_) => false,
    );
  }

  void _openLogin(BuildContext context) {
    Navigator.of(context).pushAndRemoveUntil(
      fadeSlideRoute(const LoginScreen()),
      (_) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);

    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: _backgroundBottom,
        body: DecoratedBox(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [_backgroundTop, _backgroundMid, _backgroundBottom],
              stops: [0, 0.48, 1],
            ),
          ),
          child: SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final compact = constraints.maxHeight < 760;
                final minHeight =
                    (constraints.maxHeight - (compact ? 24.0 : 40.0)).clamp(
                      0.0,
                      double.infinity,
                    );

                return SingleChildScrollView(
                  physics: const ClampingScrollPhysics(),
                  padding: EdgeInsets.fromLTRB(
                    20,
                    compact ? 12 : 20,
                    20,
                    compact ? 12 : 20,
                  ),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(minHeight: minHeight),
                    child: Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 520),
                        child: _SuccessPanel(
                          compact: compact,
                          l: l,
                          onClose: () => _openLogin(context),
                          onContinue: () => _openApp(context),
                          onBack: () => _openLogin(context),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

class _SuccessPanel extends StatelessWidget {
  const _SuccessPanel({
    required this.compact,
    required this.l,
    required this.onClose,
    required this.onContinue,
    required this.onBack,
  });

  final bool compact;
  final AppLocalizations l;
  final VoidCallback onClose;
  final VoidCallback onContinue;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    final horizontalPadding = compact ? 22.0 : 26.0;
    final titleSize = l.isKhmer ? (compact ? 24.0 : 27.0) : 28.0;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(
        horizontalPadding,
        compact ? 20 : 24,
        horizontalPadding,
        compact ? 22 : 26,
      ),
      decoration: BoxDecoration(
        color: RegistrationSuccessScreen._surface,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: RegistrationSuccessScreen._border),
        boxShadow: const [
          BoxShadow(
            color: Color(0x1A0F172A),
            blurRadius: 34,
            offset: Offset(0, 18),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _PanelHeader(tooltip: l.close, onClose: onClose),
          SizedBox(height: compact ? 24 : 32),
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0.72, end: 1),
            duration: const Duration(milliseconds: 560),
            curve: Curves.easeOutBack,
            builder: (context, value, child) {
              return Transform.scale(scale: value, child: child);
            },
            child: const _SuccessMark(),
          ),
          SizedBox(height: compact ? 22 : 28),
          Text(
            l.registrationSuccess,
            textAlign: TextAlign.center,
            style: kFont(
              context,
              fontSize: titleSize,
              fontWeight: FontWeight.w800,
              color: RegistrationSuccessScreen._textPrimary,
              height: l.isKhmer ? 1.35 : 1.18,
              forceColor: true,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            l.registrationSuccessMessage,
            textAlign: TextAlign.center,
            style: kFont(
              context,
              fontSize: l.isKhmer ? 14.5 : 15,
              fontWeight: FontWeight.w500,
              color: RegistrationSuccessScreen._textSecondary,
              height: l.isKhmer ? 1.72 : 1.58,
              forceColor: true,
            ),
          ),
          SizedBox(height: compact ? 24 : 30),
          _ContinueButton(label: l.continueText, onPressed: onContinue),
          const SizedBox(height: 12),
          _BackButton(label: l.back, onPressed: onBack),
        ],
      ),
    );
  }
}

class _PanelHeader extends StatelessWidget {
  const _PanelHeader({required this.tooltip, required this.onClose});

  final String tooltip;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _CloseButton(tooltip: tooltip, onPressed: onClose),
        const SizedBox(width: 14),
        const Expanded(child: _BrandLockup()),
      ],
    );
  }
}

class _BrandLockup extends StatelessWidget {
  const _BrandLockup();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 54,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE8EEF7)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 38,
            height: 38,
            padding: const EdgeInsets.all(5),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFE5EAF2)),
            ),
            child: Image.asset(
              'assets/images/Logo_KYSC.png',
              fit: BoxFit.contain,
            ),
          ),
          const SizedBox(width: 10),
          Flexible(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'KNEAYERNG',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: kFont(
                    context,
                    fontSize: 12.5,
                    fontWeight: FontWeight.w800,
                    color: RegistrationSuccessScreen._textPrimary,
                    height: 1.15,
                    forceColor: true,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Mobile App',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: kFont(
                    context,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: RegistrationSuccessScreen._textSecondary,
                    height: 1.15,
                    forceColor: true,
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

class _CloseButton extends StatelessWidget {
  const _CloseButton({required this.tooltip, required this.onPressed});

  final String tooltip;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: Material(
        color: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: Color(0xFFE0E6EF)),
        ),
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(16),
          child: const SizedBox(
            width: 50,
            height: 50,
            child: Icon(
              HugeIcons.strokeRoundedCancel01,
              color: RegistrationSuccessScreen._textPrimary,
              size: 25,
            ),
          ),
        ),
      ),
    );
  }
}

class _SuccessMark extends StatelessWidget {
  const _SuccessMark();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 124,
      height: 124,
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: RegistrationSuccessScreen._surfaceWarm,
        shape: BoxShape.circle,
        border: Border.all(color: const Color(0xFFFFDCC4)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x1FF27A1A),
            blurRadius: 28,
            offset: Offset(0, 14),
          ),
        ],
      ),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: const BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
        ),
        child: const DecoratedBox(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFFE9FFF1), Color(0xFFD8F8E3)],
            ),
          ),
          child: Center(
            child: Icon(
              HugeIcons.strokeRoundedTick02,
              color: RegistrationSuccessScreen._success,
              size: 54,
            ),
          ),
        ),
      ),
    );
  }
}

class _ContinueButton extends StatelessWidget {
  const _ContinueButton({required this.label, required this.onPressed});

  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 58,
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              RegistrationSuccessScreen._orange,
              RegistrationSuccessScreen._orangeDark,
            ],
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: const [
            BoxShadow(
              color: Color(0x36F27A1A),
              blurRadius: 18,
              offset: Offset(0, 10),
            ),
          ],
        ),
        child: ElevatedButton(
          onPressed: onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            foregroundColor: Colors.white,
            shadowColor: Colors.transparent,
            surfaceTintColor: Colors.transparent,
            padding: const EdgeInsets.symmetric(horizontal: 18),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Flexible(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: kFont(
                    context,
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    height: 1.2,
                    forceColor: true,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              const Icon(Icons.arrow_forward_rounded, size: 21),
            ],
          ),
        ),
      ),
    );
  }
}

class _BackButton extends StatelessWidget {
  const _BackButton({required this.label, required this.onPressed});

  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          foregroundColor: RegistrationSuccessScreen._textPrimary,
          side: const BorderSide(color: RegistrationSuccessScreen._border),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 18),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.arrow_back_rounded, size: 20),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: kFont(
                  context,
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: RegistrationSuccessScreen._textPrimary,
                  height: 1.2,
                  forceColor: true,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

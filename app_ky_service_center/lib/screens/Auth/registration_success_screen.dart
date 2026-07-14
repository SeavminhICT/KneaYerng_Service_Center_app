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

  static const _background = AppPalette.background;
  static const _surface = AppPalette.surface;
  static const _textPrimary = AppPalette.textPrimary;
  static const _textSecondary = AppPalette.textMuted;
  static const _orange = AppPalette.primary;
  static const _success = AppPalette.success;
  static const _successSoft = Color(0xFFE8F7EE);
  static const _neutralFill = Color(0xFFF1F2F5);

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
        backgroundColor: _background,
        body: SafeArea(
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
                      constraints: const BoxConstraints(maxWidth: 480),
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
    final titleSize = l.isKhmer ? (compact ? 22.0 : 25.0) : 26.0;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(
        horizontalPadding,
        compact ? 18 : 22,
        horizontalPadding,
        compact ? 20 : 24,
      ),
      decoration: BoxDecoration(
        color: RegistrationSuccessScreen._surface,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _PanelHeader(tooltip: l.close, onClose: onClose),
          SizedBox(height: compact ? 26 : 34),
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0.8, end: 1),
            duration: const Duration(milliseconds: 420),
            curve: Curves.easeOut,
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
              fontWeight: FontWeight.w700,
              color: RegistrationSuccessScreen._textPrimary,
              height: l.isKhmer ? 1.35 : 1.18,
              forceColor: true,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            l.registrationSuccessMessage,
            textAlign: TextAlign.center,
            style: kFont(
              context,
              fontSize: l.isKhmer ? 14 : 14.5,
              fontWeight: FontWeight.w500,
              color: RegistrationSuccessScreen._textSecondary,
              height: l.isKhmer ? 1.7 : 1.55,
              forceColor: true,
            ),
          ),
          SizedBox(height: compact ? 26 : 32),
          _ContinueButton(label: l.continueText, onPressed: onContinue),
          const SizedBox(height: 10),
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
        const Expanded(child: _BrandLockup()),
        const SizedBox(width: 12),
        _CloseButton(tooltip: tooltip, onPressed: onClose),
      ],
    );
  }
}

class _BrandLockup extends StatelessWidget {
  const _BrandLockup();

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: 32,
          height: 32,
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
                  fontWeight: FontWeight.w500,
                  color: RegistrationSuccessScreen._textSecondary,
                  height: 1.15,
                  forceColor: true,
                ),
              ),
            ],
          ),
        ),
      ],
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
        color: RegistrationSuccessScreen._neutralFill,
        shape: const CircleBorder(),
        child: InkWell(
          onTap: onPressed,
          customBorder: const CircleBorder(),
          child: const SizedBox(
            width: 40,
            height: 40,
            child: Icon(
              HugeIcons.strokeRoundedCancel01,
              color: RegistrationSuccessScreen._textSecondary,
              size: 20,
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
      width: 96,
      height: 96,
      decoration: const BoxDecoration(
        color: RegistrationSuccessScreen._successSoft,
        shape: BoxShape.circle,
      ),
      child: const Center(
        child: Icon(
          HugeIcons.strokeRoundedTick02,
          color: RegistrationSuccessScreen._success,
          size: 42,
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
      height: 54,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: RegistrationSuccessScreen._orange,
          foregroundColor: Colors.white,
          elevation: 0,
          shadowColor: Colors.transparent,
          surfaceTintColor: Colors.transparent,
          padding: const EdgeInsets.symmetric(horizontal: 18),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
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
                  fontSize: 15.5,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                  height: 1.2,
                  forceColor: true,
                ),
              ),
            ),
            const SizedBox(width: 8),
            const Icon(Icons.arrow_forward_rounded, size: 20),
          ],
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
      height: 50,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: RegistrationSuccessScreen._neutralFill,
          foregroundColor: RegistrationSuccessScreen._textPrimary,
          elevation: 0,
          shadowColor: Colors.transparent,
          surfaceTintColor: Colors.transparent,
          padding: const EdgeInsets.symmetric(horizontal: 18),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.arrow_back_rounded, size: 18),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: kFont(
                  context,
                  fontSize: 14.5,
                  fontWeight: FontWeight.w600,
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

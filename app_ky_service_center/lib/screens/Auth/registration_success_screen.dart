import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';

import '../../l10n/app_localizations.dart';
import '../../widgets/page_transitions.dart';
import '../main_navigation_screen.dart';
import 'login_screen.dart';

class RegistrationSuccessScreen extends StatelessWidget {
  const RegistrationSuccessScreen({super.key});

  static const _background = Color(0xFFF3F8FD);
  static const _surface = Colors.white;
  static const _textPrimary = Color(0xFF1D2738);
  static const _textSecondary = Color(0xFF707786);
  static const _orange = Color(0xFFF87916);
  static const _orangeDark = Color(0xFFEF6810);
  static const _success = Color(0xFF16A34A);

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
        body: Stack(
          children: [
            const Positioned(
              top: -120,
              right: -90,
              child: _BackgroundOrb(
                size: 310,
                colors: [Color(0x55FFE4CF), Color(0x00FFE4CF)],
              ),
            ),
            const Positioned(
              left: -150,
              bottom: -120,
              child: _BackgroundOrb(
                size: 390,
                colors: [Color(0x35CFE5FA), Color(0x00CFE5FA)],
              ),
            ),
            Positioned(
              right: -85,
              bottom: 80,
              child: Transform.rotate(
                angle: -0.12,
                child: Container(
                  width: 210,
                  height: 280,
                  decoration: BoxDecoration(
                    color: Colors.white.withAlpha(100),
                    borderRadius: BorderRadius.circular(64),
                  ),
                ),
              ),
            ),
            SafeArea(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final compact = constraints.maxHeight < 820;

                  return SingleChildScrollView(
                    physics: const ClampingScrollPhysics(),
                    padding: EdgeInsets.fromLTRB(
                      24,
                      compact ? 16 : 28,
                      24,
                      compact ? 16 : 28,
                    ),
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        minHeight:
                            (constraints.maxHeight - (compact ? 32 : 56))
                                .clamp(0.0, double.infinity),
                      ),
                      child: Center(
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 520),
                          child: Container(
                            width: double.infinity,
                            padding: EdgeInsets.fromLTRB(
                              compact ? 22 : 28,
                              compact ? 22 : 28,
                              compact ? 22 : 28,
                              compact ? 24 : 30,
                            ),
                            decoration: BoxDecoration(
                              color: _surface,
                              borderRadius: BorderRadius.circular(32),
                              border: Border.all(
                                color: const Color(0xFFE5E9EF),
                              ),
                              boxShadow: const [
                                BoxShadow(
                                  color: Color(0x190D2440),
                                  blurRadius: 36,
                                  offset: Offset(0, 18),
                                ),
                              ],
                            ),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Align(
                                  alignment: Alignment.centerLeft,
                                  child: _CloseButton(
                                    tooltip: l.cancel,
                                    onPressed: () => _openLogin(context),
                                  ),
                                ),
                                SizedBox(height: compact ? 14 : 20),
                                Container(
                                  width: 78,
                                  height: 78,
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: _surface,
                                    borderRadius: BorderRadius.circular(22),
                                    border: Border.all(
                                      color: const Color(0xFFE4E7EC),
                                    ),
                                    boxShadow: const [
                                      BoxShadow(
                                        color: Color(0x100D2440),
                                        blurRadius: 16,
                                        offset: Offset(0, 8),
                                      ),
                                    ],
                                  ),
                                  child: Image.asset(
                                    'assets/images/Logo_KYSC.png',
                                    fit: BoxFit.contain,
                                  ),
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'KNEAYERNG MOBILE APP',
                                  textAlign: TextAlign.center,
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleMedium
                                      ?.copyWith(
                                        color: _textPrimary,
                                        fontSize: 16,
                                        fontWeight: FontWeight.w700,
                                        letterSpacing: 0.8,
                                      ),
                                ),
                                SizedBox(height: compact ? 22 : 30),
                                TweenAnimationBuilder<double>(
                                  tween: Tween(begin: 0.6, end: 1),
                                  duration: const Duration(milliseconds: 620),
                                  curve: Curves.easeOutBack,
                                  builder: (context, value, child) {
                                    return Transform.scale(
                                      scale: value,
                                      child: child,
                                    );
                                  },
                                  child: const _SuccessMark(),
                                ),
                                SizedBox(height: compact ? 22 : 28),
                                Text(
                                  l.registrationSuccess,
                                  textAlign: TextAlign.center,
                                  style: Theme.of(context)
                                      .textTheme
                                      .headlineMedium
                                      ?.copyWith(
                                        color: _textPrimary,
                                        fontSize: 30,
                                        height: 1.15,
                                        fontWeight: FontWeight.w700,
                                        letterSpacing: -0.7,
                                      ),
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  'Your account has been verified and is ready. '
                                  'Continue to explore services and manage your bookings.',
                                  textAlign: TextAlign.center,
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyLarge
                                      ?.copyWith(
                                        color: _textSecondary,
                                        fontSize: 15.5,
                                        height: 1.55,
                                        fontWeight: FontWeight.w500,
                                      ),
                                ),
                                SizedBox(height: compact ? 24 : 30),
                                _ContinueButton(
                                  label: l.continueText,
                                  onPressed: () => _openApp(context),
                                ),
                                const SizedBox(height: 14),
                                TextButton(
                                  onPressed: () => _openLogin(context),
                                  style: TextButton.styleFrom(
                                    foregroundColor: _textSecondary,
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 22,
                                      vertical: 12,
                                    ),
                                  ),
                                  child: Text(
                                    l.back,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BackgroundOrb extends StatelessWidget {
  const _BackgroundOrb({required this.size, required this.colors});

  final double size;
  final List<Color> colors;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(colors: colors),
        ),
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
    return Material(
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: Color(0xFFE0E4E9)),
      ),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(16),
        child: Tooltip(
          message: tooltip,
          child: const SizedBox(
            width: 52,
            height: 52,
            child: Icon(
              HugeIcons.strokeRoundedCancel01,
              color: RegistrationSuccessScreen._textPrimary,
              size: 27,
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
      width: 112,
      height: 112,
      padding: const EdgeInsets.all(10),
      decoration: const BoxDecoration(
        color: Color(0xFFFFF8F1),
        shape: BoxShape.circle,
      ),
      child: Container(
        decoration: const BoxDecoration(
          color: Color(0xFFFFECDD),
          shape: BoxShape.circle,
        ),
        child: const Icon(
          HugeIcons.strokeRoundedTick02,
          color: RegistrationSuccessScreen._success,
          size: 58,
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
      height: 60,
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
          borderRadius: BorderRadius.circular(18),
          boxShadow: const [
            BoxShadow(
              color: Color(0x35F87916),
              blurRadius: 20,
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
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18),
            ),
          ),
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import '../../theme/app_palette.dart';
import '../../widgets/page_transitions.dart';
import '../main_navigation_screen.dart';
import 'login_screen.dart';

class RegistrationSuccessScreen extends StatelessWidget {
  const RegistrationSuccessScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppPalette.background,
      body: SafeArea(
        child: Stack(
          children: [
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      AppPalette.primarySoft,
                      AppPalette.background,
                      AppPalette.background,
                    ],
                    stops: const [0, 0.45, 1],
                  ),
                ),
              ),
            ),
            Positioned(
              top: -90,
              right: -70,
              child: Container(
                width: 220,
                height: 220,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppPalette.primary.withAlpha((0.08 * 255).round()),
                ),
              ),
            ),
            Positioned(
              bottom: -120,
              left: -80,
              child: Container(
                width: 260,
                height: 260,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppPalette.primary.withAlpha((0.06 * 255).round()),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 520),
                  child: Container(
                    padding: const EdgeInsets.fromLTRB(18, 20, 18, 22),
                    decoration: BoxDecoration(
                      color: AppPalette.surface,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: AppPalette.border),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withAlpha((0.05 * 255).round()),
                          blurRadius: 18,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Container(
                            decoration: BoxDecoration(
                              color: AppPalette.surface,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: AppPalette.border),
                            ),
                            child: IconButton(
                              icon: const Icon(Icons.close),
                              tooltip: 'Close',
                              onPressed: () {
                                Navigator.pushReplacement(
                                  context,
                                  fadeSlideRoute(const LoginScreen()),
                                );
                              },
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Container(
                          height: 64,
                          width: 64,
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: AppPalette.surface,
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(color: AppPalette.border),
                          ),
                          child: Image.asset(
                            'assets/images/Logo_KYSC.png',
                            fit: BoxFit.contain,
                          ),
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          'KNEAYERNG MOBILE APP',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: AppPalette.textPrimary,
                            letterSpacing: 0.6,
                          ),
                        ),
                        const SizedBox(height: 22),
                        TweenAnimationBuilder<double>(
                          tween: Tween(begin: 0.75, end: 1.0),
                          duration: const Duration(milliseconds: 520),
                          curve: Curves.easeOutBack,
                          builder: (context, value, child) {
                            return Transform.scale(scale: value, child: child);
                          },
                          child: Container(
                            width: 92,
                            height: 92,
                            decoration: const BoxDecoration(
                              color: AppPalette.primarySoft,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.check_rounded,
                              color: AppPalette.success,
                              size: 52,
                            ),
                          ),
                        ),
                        const SizedBox(height: 18),
                        Text(
                          'Registration successful',
                          textAlign: TextAlign.center,
                          style: Theme.of(context)
                              .textTheme
                              .headlineSmall
                              ?.copyWith(
                                fontWeight: FontWeight.w700,
                                color: AppPalette.textPrimary,
                              ),
                        ),
                        const SizedBox(height: 10),
                        const Text(
                          'Your account is ready. You can now continue to the app and start booking services.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: AppPalette.textMuted,
                            height: 1.4,
                          ),
                        ),
                        const SizedBox(height: 22),
                        SizedBox(
                          width: double.infinity,
                          height: 52,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppPalette.primary,
                              foregroundColor: Colors.white,
                              elevation: 2,
                              shadowColor: AppPalette.primary
                                  .withAlpha((0.25 * 255).round()),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            onPressed: () {
                              Navigator.pushReplacement(
                                context,
                                fadeSlideRoute(const MainNavigationScreen()),
                              );
                            },
                            child: const Text(
                              'Continue',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        TextButton(
                          onPressed: () {
                            Navigator.pushReplacement(
                              context,
                              fadeSlideRoute(const LoginScreen()),
                            );
                          },
                          child: const Text(
                            'Back to login',
                            style: TextStyle(color: AppPalette.textMuted),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

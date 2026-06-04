import 'dart:async';

import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'l10n/app_localizations.dart';
import 'screens/Auth/onboarding_screen.dart';
import 'screens/main_navigation_screen.dart';
import 'screens/splash/splash_screen.dart';
import 'services/api_service.dart';
import 'services/app_notification_service.dart';
import 'services/cart_service.dart';
import 'services/favorite_service.dart';
import 'services/language_service.dart';
import 'services/theme_service.dart';
import 'theme/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await _initializeFirebaseSafely();
  await ApiService.initialize();
  await AppNotificationService.instance.initialize();
  await ThemeService.instance.load();
  await LanguageService.instance.load();
  await FavoriteService.instance.load();

  // When any API call receives 401 mid-session, clear the stored token and
  // return the user to the onboarding screen.
  ApiService.onUnauthorized = () {
    ApiService.onUnauthorized = null; // prevent re-entry
    AppNotificationService.instance.navigatorKey.currentState
        ?.pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const OnboardingScreen()),
      (_) => false,
    );
  };

  runApp(const MyApp());
}

Future<void> _initializeFirebaseSafely() async {
  try {
    await Firebase.initializeApp();
  } on FirebaseException catch (error) {
    debugPrint(
      'Firebase startup skipped (${error.code}): ${error.message ?? "unknown error"}',
    );
    debugPrint(
      'To enable Firebase on iOS, add Runner/GoogleService-Info.plist and rebuild.',
    );
  } catch (error) {
    debugPrint('Firebase startup skipped: $error');
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([ThemeService.instance, LanguageService.instance]),
      builder: (context, _) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          navigatorKey: AppNotificationService.instance.navigatorKey,
          theme: AppTheme.light(locale: LanguageService.instance.locale),
          darkTheme: AppTheme.dark(locale: LanguageService.instance.locale),
          themeMode: ThemeService.instance.themeMode,
          locale: LanguageService.instance.locale,
          supportedLocales: const [Locale('en'), Locale('km')],
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          home: const _StartupGate(),
        );
      },
    );
  }
}

class _StartupGate extends StatefulWidget {
  const _StartupGate();

  @override
  State<_StartupGate> createState() => _StartupGateState();
}

class _StartupGateState extends State<_StartupGate> {
  Widget? _destination;

  @override
  void initState() {
    super.initState();
    _bootstrap();
  }

  Future<void> _bootstrap() async {
    Widget destination = const OnboardingScreen();
    try {
      // Validate the token against the server — this catches stale tokens
      // from a previous database or deployment and prevents the user from
      // landing on the home screen only to see 401 errors everywhere.
      final isAuthenticated = await ApiService.validateToken();
      if (isAuthenticated) {
        unawaited(CartService.instance.loadFromApi());
        final launchTarget = AppNotificationService.instance
            .consumePendingLaunchTarget();
        destination = MainNavigationScreen(
          initialIndex: launchTarget == null ? 0 : 2,
          initialDeliveryOrderId: launchTarget?.orderId,
          initialDeliveryOrderNumber: launchTarget?.orderNumber,
        );
      }
    } catch (_) {
      // Fall back to onboarding if startup restoration fails.
    }

    await Future.delayed(kSplashDuration);

    if (!mounted) return;
    setState(() {
      _destination = destination;
    });
  }

  @override
  Widget build(BuildContext context) {
    return _destination ?? const SplashScreen();
  }
}

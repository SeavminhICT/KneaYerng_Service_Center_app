import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'screens/Auth/onboarding_screen.dart';
import 'screens/main_navigation_screen.dart';
import 'screens/splash/splash_screen.dart';
import 'services/api_service.dart';
import 'services/app_notification_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await ApiService.initialize();
  await AppNotificationService.instance.initialize();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      navigatorKey: AppNotificationService.instance.navigatorKey,
      home: const _StartupGate(),
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
      final results = await Future.wait([
        ApiService.getToken(),
        Future<void>.delayed(kSplashDuration),
      ]);
      final token = results[0] as String?;
      if (token != null && token.isNotEmpty) {
        final launchTarget = AppNotificationService.instance
            .consumePendingLaunchTarget();
        destination = MainNavigationScreen(
          initialIndex: launchTarget == null ? 0 : 3,
          initialDeliveryOrderId: launchTarget?.orderId,
          initialDeliveryOrderNumber: launchTarget?.orderNumber,
        );
      }
    } catch (_) {
      // Fall back to onboarding if startup restoration fails.
    }

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

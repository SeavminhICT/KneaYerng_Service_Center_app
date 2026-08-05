import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';

import '../../services/app_notification_service.dart';
import '../notifications/notification_screen.dart';
import '../profile/profile_screen.dart';
import '../../theme/app_palette.dart';
import 'technician_job_list_screen.dart';

/// Bottom-nav shell for technician accounts — kept entirely separate from
/// [MainNavigationScreen] (the customer shell) so technicians never see the
/// parts-shop/cart/favorites tabs meant for customers.
class TechnicianShellScreen extends StatefulWidget {
  const TechnicianShellScreen({super.key});

  @override
  State<TechnicianShellScreen> createState() => _TechnicianShellScreenState();
}

class _TechnicianShellScreenState extends State<TechnicianShellScreen> {
  int _currentIndex = 0;

  final _screens = const [
    TechnicianJobListScreen(),
    NotificationScreen(),
    ProfileScreen(),
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      AppNotificationService.instance.syncTokenWithBackend();
      AppNotificationService.instance.flushPendingNavigation();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: _screens),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) => setState(() => _currentIndex = index),
        indicatorColor: AppPalette.primarySoft,
        destinations: const [
          NavigationDestination(
            icon: Icon(HugeIcons.strokeRoundedWrench01),
            label: 'Jobs',
          ),
          NavigationDestination(
            icon: Icon(HugeIcons.strokeRoundedNotification01),
            label: 'Alerts',
          ),
          NavigationDestination(
            icon: Icon(HugeIcons.strokeRoundedUser),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}

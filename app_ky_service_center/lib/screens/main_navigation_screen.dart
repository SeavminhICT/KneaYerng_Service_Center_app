import 'dart:async';

import 'package:app_ky_service_center/screens/home/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/pickup_ticket.dart';
import '../services/app_notification_service.dart';
import '../services/api_service.dart';
import 'categories/categories_screen.dart';
import 'repair/repair_screen.dart';
import 'orders/delivery_tracking_screen.dart';
import 'orders/orders_screen.dart';
import 'tickets/tickets_screen.dart';
import 'tickets/ticket_detail_screen.dart';
import 'profile/profile_screen.dart';
import 'support/support_chat_screen.dart';
import '../widgets/auth_guard.dart';
import '../widgets/page_transitions.dart';

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({
    super.key,
    this.initialIndex = 0,
    this.initialPickupTicket,
    this.initialDeliveryOrderId,
    this.initialDeliveryOrderNumber,
    this.initialDeliveryStatus,
    this.initialDeliveryAddress,
    this.initialDeliveryAmount,
    this.initialDeliveryPlacedAt,
  });

  final int initialIndex;
  final PickupTicket? initialPickupTicket;
  final int? initialDeliveryOrderId;
  final String? initialDeliveryOrderNumber;
  final String? initialDeliveryStatus;
  final String? initialDeliveryAddress;
  final double? initialDeliveryAmount;
  final DateTime? initialDeliveryPlacedAt;

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen>
    with SingleTickerProviderStateMixin {
  late int _currentIndex;
  bool _didOpenInitialPickupTicket = false;
  bool _didOpenInitialDeliveryTracking = false;
  int _supportUnreadCount = 0;
  Timer? _supportBadgeTimer;
  late final AnimationController _supportPulseController;

  final List<Widget> _screens = const [
    HomeScreen(),
    CategoriesScreen(),
    RepairScreen(),
    OrdersScreen(),
    TicketsScreen(),
    ProfileScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex.clamp(0, _screens.length - 1);
    _supportPulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    )..repeat(reverse: true);
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await AppNotificationService.instance.syncTokenWithBackend();
      await _openInitialPickupTicketIfNeeded();
      await _openInitialDeliveryTrackingIfNeeded();
      AppNotificationService.instance.flushPendingNavigation();
      await _refreshSupportUnreadCount();
    });
    _supportBadgeTimer = Timer.periodic(
      const Duration(seconds: 15),
      (_) => _refreshSupportUnreadCount(),
    );
  }

  @override
  void dispose() {
    _supportBadgeTimer?.cancel();
    _supportPulseController.dispose();
    super.dispose();
  }

  void _onTabSelected(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  Future<void> _refreshSupportUnreadCount() async {
    final count = await ApiService.fetchSupportUnreadCount();
    if (!mounted) return;
    setState(() {
      _supportUnreadCount = count;
    });
  }

  Future<void> _openSupportChat() async {
    final ok = await ensureLoggedIn(
      context,
      message: 'Please login or register to contact support.',
    );
    if (!ok || !mounted) return;

    await Navigator.of(
      context,
    ).push(fadeSlideRoute(const SupportChatScreen()));

    await _refreshSupportUnreadCount();
  }

  Future<void> _openInitialPickupTicketIfNeeded() async {
    final ticket = widget.initialPickupTicket;
    if (_didOpenInitialPickupTicket || ticket == null || !mounted) return;
    _didOpenInitialPickupTicket = true;
    await Navigator.of(
      context,
    ).push(fadeSlideRoute(TicketDetailScreen(ticket: ticket)));
  }

  Future<void> _openInitialDeliveryTrackingIfNeeded() async {
    final hasOrderRef =
        widget.initialDeliveryOrderId != null ||
        (widget.initialDeliveryOrderNumber?.trim().isNotEmpty ?? false);
    if (_didOpenInitialDeliveryTracking || !hasOrderRef || !mounted) return;

    _didOpenInitialDeliveryTracking = true;
    await Navigator.of(context).push(
      fadeSlideRoute(
        DeliveryTrackingScreen(
          orderId: widget.initialDeliveryOrderId,
          orderNumber: widget.initialDeliveryOrderNumber,
          initialStatus: widget.initialDeliveryStatus,
          initialPlacedAt: widget.initialDeliveryPlacedAt,
          initialDeliveryAddress: widget.initialDeliveryAddress,
          initialTotalAmount: widget.initialDeliveryAmount,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: _screens),
      floatingActionButton: ScaleTransition(
        scale: Tween<double>(
          begin: 1,
          end: 1.04,
        ).animate(CurvedAnimation(
          parent: _supportPulseController,
          curve: Curves.easeInOut,
        )),
        child: _SupportFab(
          unreadCount: _supportUnreadCount,
          onTap: _openSupportChat,
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      bottomNavigationBar: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(28),
              gradient: const LinearGradient(
                colors: [Color(0xFFF3F7FF), Color(0xFFF7F5FF)],
              ),
              border: Border.all(color: Colors.white.withValues(alpha: 0.88)),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x1F20304A),
                  blurRadius: 20,
                  offset: Offset(0, 10),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(28),
              child: Theme(
                data: Theme.of(context).copyWith(
                  textTheme: GoogleFonts.manropeTextTheme(
                    Theme.of(context).textTheme,
                  ),
                ),
                child: NavigationBarTheme(
                  data: NavigationBarThemeData(
                    backgroundColor: Colors.white.withValues(alpha: 0.92),
                    height: 78,
                    indicatorColor: const Color(0xFFE3EBFF),
                    iconTheme: WidgetStateProperty.resolveWith((states) {
                      final selected = states.contains(WidgetState.selected);
                      return IconThemeData(
                        size: 24,
                        color: selected
                            ? const Color(0xFF3D74FF)
                            : const Color(0xFF6C7690),
                      );
                    }),
                    labelTextStyle: WidgetStateProperty.resolveWith((states) {
                      final selected = states.contains(WidgetState.selected);
                      return GoogleFonts.manrope(
                        fontSize: 11.5,
                        fontWeight: selected
                            ? FontWeight.w800
                            : FontWeight.w700,
                        color: selected
                            ? const Color(0xFF22304A)
                            : const Color(0xFF7B849C),
                      );
                    }),
                  ),
                  child: NavigationBar(
                    selectedIndex: _currentIndex,
                    labelBehavior:
                        NavigationDestinationLabelBehavior.alwaysShow,
                    animationDuration: const Duration(milliseconds: 320),
                    onDestinationSelected: _onTabSelected,
                    destinations: const [
                      NavigationDestination(
                        icon: Icon(Icons.home_outlined),
                        selectedIcon: Icon(Icons.home_rounded),
                        label: 'Home',
                      ),
                      NavigationDestination(
                        icon: Icon(Icons.grid_view_outlined),
                        selectedIcon: Icon(Icons.grid_view_rounded),
                        label: 'Categories',
                      ),
                      NavigationDestination(
                        icon: Icon(Icons.build_outlined),
                        selectedIcon: Icon(Icons.build_rounded),
                        label: 'Repair',
                      ),
                      NavigationDestination(
                        icon: Icon(Icons.receipt_long_outlined),
                        selectedIcon: Icon(Icons.receipt_long_rounded),
                        label: 'Orders',
                      ),
                      NavigationDestination(
                        icon: Icon(Icons.confirmation_number_outlined),
                        selectedIcon: Icon(Icons.confirmation_number_rounded),
                        label: 'Tickets',
                      ),
                      NavigationDestination(
                        icon: Icon(Icons.person_outline_rounded),
                        selectedIcon: Icon(Icons.person_rounded),
                        label: 'Profile',
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _SupportFab extends StatelessWidget {
  const _SupportFab({
    required this.unreadCount,
    required this.onTap,
  });

  final int unreadCount;
  final Future<void> Function() onTap;

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        FloatingActionButton.extended(
          onPressed: () {
            onTap();
          },
          backgroundColor: const Color(0xFF0F6BFF),
          foregroundColor: Colors.white,
          elevation: 10,
          icon: const Icon(Icons.support_agent_rounded),
          label: const Text(
            'Chat Support',
            style: TextStyle(fontWeight: FontWeight.w700),
          ),
        ),
        if (unreadCount > 0)
          Positioned(
            right: -2,
            top: -2,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
              constraints: const BoxConstraints(minWidth: 20),
              decoration: BoxDecoration(
                color: const Color(0xFFEF4444),
                borderRadius: BorderRadius.circular(999),
                border: Border.all(color: Colors.white, width: 2),
              ),
              child: Text(
                unreadCount > 99 ? '99+' : '$unreadCount',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 10.5,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
              ),
            ),
          ),
      ],
    );
  }
}

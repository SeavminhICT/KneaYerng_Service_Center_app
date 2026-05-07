import 'dart:async';

import 'package:flutter/material.dart';

import '../models/pickup_ticket.dart';
import '../services/api_service.dart';
import '../services/app_notification_service.dart';
import '../widgets/auth_guard.dart';
import '../widgets/page_transitions.dart';
import 'categories/categories_screen.dart';
import 'home/home_screen.dart';
import 'orders/delivery_tracking_screen.dart';
import 'orders/orders_screen.dart';
import 'profile/profile_screen.dart';
import 'repair/repair_screen.dart';
import 'support/support_chat_screen.dart';
import 'tickets/ticket_detail_screen.dart';
import 'tickets/tickets_screen.dart';

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
    with TickerProviderStateMixin {
  late int _currentIndex;
  int? _previousIndex;
  int? _pressedNavIndex;
  bool _didOpenInitialPickupTicket = false;
  bool _didOpenInitialDeliveryTracking = false;
  int _supportUnreadCount = 0;
  Timer? _supportBadgeTimer;
  late final AnimationController _supportPulseController;
  late final AnimationController _tabTransitionController;
  late final Animation<double> _tabTransition;

  final List<Widget> _screens = const [
    HomeScreen(),
    CategoriesScreen(),
    RepairScreen(),
    OrdersScreen(),
    TicketsScreen(),
    ProfileScreen(),
  ];

  static const List<_NavItemData> _navItems = [
    _NavItemData(
      label: 'Home',
      icon: Icons.home_outlined,
      activeIcon: Icons.home_rounded,
    ),
    _NavItemData(
      label: 'Categories',
      icon: Icons.grid_view_outlined,
      activeIcon: Icons.grid_view_rounded,
    ),
    _NavItemData(
      label: 'Repair',
      icon: Icons.build_outlined,
      activeIcon: Icons.build_rounded,
    ),
    _NavItemData(
      label: 'Orders',
      icon: Icons.receipt_long_outlined,
      activeIcon: Icons.receipt_long_rounded,
    ),
    _NavItemData(
      label: 'Tickets',
      icon: Icons.confirmation_number_outlined,
      activeIcon: Icons.confirmation_number_rounded,
    ),
    _NavItemData(
      label: 'Profile',
      icon: Icons.person_outline_rounded,
      activeIcon: Icons.person_rounded,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex.clamp(0, _screens.length - 1).toInt();
    _supportPulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    )..repeat(reverse: true);
    _tabTransitionController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
      value: 1,
    );
    _tabTransition = CurvedAnimation(
      parent: _tabTransitionController,
      curve: Curves.easeOut,
    );
    _tabTransitionController.addStatusListener((status) {
      if (status != AnimationStatus.completed || !mounted) return;
      setState(() {
        _previousIndex = null;
      });
    });

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
    _tabTransitionController.dispose();
    super.dispose();
  }

  void _onTabSelected(int index) {
    if (index == _currentIndex || index < 0 || index >= _screens.length) {
      return;
    }

    setState(() {
      _previousIndex = _currentIndex;
      _currentIndex = index;
      _pressedNavIndex = null;
    });
    _tabTransitionController
      ..stop()
      ..forward(from: 0);
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
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: AnimatedBuilder(
        animation: _tabTransition,
        builder: (context, _) {
          return _AnimatedTabStack(
            screens: _screens,
            currentIndex: _currentIndex,
            previousIndex: _previousIndex,
            progress: _tabTransition.value,
          );
        },
      ),
      floatingActionButton: ScaleTransition(
        scale: Tween<double>(
          begin: 1,
          end: 1.04,
        ).animate(
          CurvedAnimation(
            parent: _supportPulseController,
            curve: Curves.easeInOut,
          ),
        ),
        child: _SupportFab(
          unreadCount: _supportUnreadCount,
          onTap: _openSupportChat,
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      bottomNavigationBar: _AnimatedBottomNavBar(
        items: _navItems,
        activeIndex: _currentIndex,
        pressedIndex: _pressedNavIndex,
        onTapDown: (index) {
          setState(() {
            _pressedNavIndex = index;
          });
        },
        onTapCancel: () {
          if (_pressedNavIndex == null) return;
          setState(() {
            _pressedNavIndex = null;
          });
        },
        onTap: _onTabSelected,
      ),
    );
  }
}

class _AnimatedTabStack extends StatelessWidget {
  const _AnimatedTabStack({
    required this.screens,
    required this.currentIndex,
    required this.previousIndex,
    required this.progress,
  });

  final List<Widget> screens;
  final int currentIndex;
  final int? previousIndex;
  final double progress;

  @override
  Widget build(BuildContext context) {
    final clampedProgress = progress.clamp(0.0, 1.0);
    final animating = previousIndex != null && clampedProgress < 1;

    final children = <Widget>[];

    for (var index = 0; index < screens.length; index++) {
      if (index == currentIndex || (animating && index == previousIndex)) {
        continue;
      }
      children.add(
        Offstage(
          offstage: true,
          child: TickerMode(
            enabled: false,
            child: screens[index],
          ),
        ),
      );
    }

    if (animating && previousIndex != null) {
      children.add(
        _buildLayer(
          screen: screens[previousIndex!],
          isCurrent: false,
          progress: clampedProgress,
        ),
      );
    }

    children.add(
      _buildLayer(
        screen: screens[currentIndex],
        isCurrent: true,
        progress: clampedProgress,
      ),
    );

    return Stack(fit: StackFit.expand, children: children);
  }

  Widget _buildLayer({
    required Widget screen,
    required bool isCurrent,
    required double progress,
  }) {
    var horizontalShift = 0.0;
    var opacity = 1.0;

    if (previousIndex != null && progress < 1) {
      if (isCurrent) {
        horizontalShift = 0.16 * (1 - progress);
        opacity = progress;
      } else {
        horizontalShift = -0.12 * progress;
        opacity = 1 - progress;
      }
    }

    return IgnorePointer(
      ignoring: !isCurrent,
      child: FractionalTranslation(
        translation: Offset(horizontalShift, 0),
        child: Opacity(
          opacity: opacity.clamp(0.0, 1.0),
          child: TickerMode(
            enabled: true,
            child: screen,
          ),
        ),
      ),
    );
  }
}

class _AnimatedBottomNavBar extends StatelessWidget {
  const _AnimatedBottomNavBar({
    required this.items,
    required this.activeIndex,
    required this.pressedIndex,
    required this.onTapDown,
    required this.onTapCancel,
    required this.onTap,
  });

  final List<_NavItemData> items;
  final int activeIndex;
  final int? pressedIndex;
  final ValueChanged<int> onTapDown;
  final VoidCallback onTapCancel;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    const horizontalPadding = 14.0;
    const verticalPadding = 12.0;

    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
        child: Container(
          height: 88,
          padding: const EdgeInsets.symmetric(
            horizontal: horizontalPadding,
            vertical: verticalPadding,
          ),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF161B22) : Colors.white,
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(20),
              bottom: Radius.circular(24),
            ),
            border: Border.all(
              color: isDark ? const Color(0xFF2B3442) : const Color(0xFFE6EBF3),
            ),
            boxShadow: [
              BoxShadow(
                color: isDark
                    ? const Color(0x55000000)
                    : const Color(0x16000000),
                blurRadius: 22,
                offset: Offset(0, -3),
              ),
            ],
          ),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final itemWidth = constraints.maxWidth / items.length;
              const pillWidth = 50.0;
              const pillHeight = 36.0;
              final pillLeft =
                  itemWidth * activeIndex + (itemWidth - pillWidth) / 2;

              return Stack(
                children: [
                  AnimatedPositioned(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeOut,
                    left: pillLeft,
                    top: 0,
                    width: pillWidth,
                    height: pillHeight,
                    child: Container(
                      decoration: BoxDecoration(
                        color: isDark
                            ? const Color(0xFF213154)
                            : const Color(0xFFEAF0FF),
                        borderRadius: BorderRadius.circular(999),
                      ),
                    ),
                  ),
                  Row(
                    children: List.generate(items.length, (index) {
                      final item = items[index];
                      final active = index == activeIndex;
                      final pressed = index == pressedIndex;
                      return Expanded(
                        child: _BottomNavItem(
                          label: item.label,
                          icon: item.icon,
                          activeIcon: item.activeIcon,
                          active: active,
                          pressed: pressed,
                          onTapDown: () => onTapDown(index),
                          onTapCancel: onTapCancel,
                          onTap: () => onTap(index),
                        ),
                      );
                    }),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

class _BottomNavItem extends StatelessWidget {
  const _BottomNavItem({
    required this.label,
    required this.icon,
    required this.activeIcon,
    required this.active,
    required this.pressed,
    required this.onTapDown,
    required this.onTapCancel,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final IconData activeIcon;
  final bool active;
  final bool pressed;
  final VoidCallback onTapDown;
  final VoidCallback onTapCancel;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final iconColor = active
        ? const Color(0xFF4A6CF7)
        : (isDark ? const Color(0xFF97A2B5) : const Color(0xFF888888));
    final labelColor = active
        ? (isDark ? const Color(0xFFE6EDF7) : const Color(0xFF1A1A1A))
        : (isDark ? const Color(0xFF97A2B5) : const Color(0xFF888888));
    final targetScale = pressed
        ? 0.95
        : active
        ? 1.15
        : 1.0;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: (_) => onTapDown(),
      onTapCancel: onTapCancel,
      onTapUp: (_) => onTapCancel(),
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 2),
          AnimatedSlide(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
            offset: active ? const Offset(0, -0.16) : Offset.zero,
            child: AnimatedScale(
              duration: const Duration(milliseconds: 170),
              curve: Curves.easeOut,
              scale: targetScale,
              child: Icon(
                active ? activeIcon : icon,
                color: iconColor,
                size: active ? 23 : 21,
              ),
            ),
          ),
          const SizedBox(height: 4),
          AnimatedDefaultTextStyle(
            duration: const Duration(milliseconds: 260),
            curve: Curves.easeOut,
            style: TextStyle(
              color: labelColor,
              fontSize: 11.5,
              fontWeight: active ? FontWeight.w700 : FontWeight.w500,
              height: 1.1,
            ),
            child: AnimatedOpacity(
              duration: const Duration(milliseconds: 260),
              curve: Curves.easeOut,
              opacity: active ? 1 : 0.88,
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _NavItemData {
  const _NavItemData({
    required this.label,
    required this.icon,
    required this.activeIcon,
  });

  final String label;
  final IconData icon;
  final IconData activeIcon;
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

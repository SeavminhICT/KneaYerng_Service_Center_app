import 'dart:async';

import 'package:flutter/material.dart';
import '../theme/app_fonts.dart';

import '../l10n/app_localizations.dart';
import '../models/pickup_ticket.dart';
import '../services/app_notification_service.dart';
import '../widgets/page_transitions.dart';
import 'favorites/favorite_screen.dart';
import 'home/home_screen.dart';
import 'orders/delivery_tracking_screen.dart';
import 'orders/orders_screen.dart';
import 'profile/profile_screen.dart';
import 'repair/repair_screen.dart';
import 'support/support_chat_screen.dart';
import 'tickets/ticket_detail_screen.dart';

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
  late final AnimationController _tabTransitionController;
  late final Animation<double> _tabTransition;

  final List<Widget> _screens = const [
    HomeScreen(),
    RepairScreen(),
    OrdersScreen(),
    FavoriteScreen(),
    ProfileScreen(),
  ];

  List<_NavItemData> _navItems(AppLocalizations l) => [
    _NavItemData(label: l.home,      icon: Icons.home_outlined,          activeIcon: Icons.home_rounded),
    _NavItemData(label: l.repair,    icon: Icons.build_outlined,         activeIcon: Icons.build_rounded),
    _NavItemData(label: l.orders,    icon: Icons.receipt_long_outlined,  activeIcon: Icons.receipt_long_rounded),
    _NavItemData(label: l.favorites, icon: Icons.favorite_border_rounded,activeIcon: Icons.favorite_rounded),
    _NavItemData(label: l.profile,   icon: Icons.person_outline_rounded, activeIcon: Icons.person_rounded),
  ];

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex.clamp(0, _screens.length - 1).toInt();
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
      if (!mounted) return;
      await AppNotificationService.instance
          .maybePromptForNotificationPermission(context);
    });
  }

  @override
  void dispose() {
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
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      floatingActionButton: _currentIndex != 4
          ? Padding(
              padding: const EdgeInsets.only(bottom: 82),
              child: FloatingActionButton.extended(
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => const SupportChatScreen(
                      contextType: 'general',
                      subject: 'Customer Support',
                    ),
                  ),
                ),
                backgroundColor: const Color.fromARGB(255, 39, 93, 240),
                foregroundColor: Colors.white,
                elevation: 6,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                icon: const Icon(Icons.headset_mic_rounded, size: 20),
                label: Text(
                  AppLocalizations.of(context).support,
                  style: kFont(context, 
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            )
          : null,
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
      bottomNavigationBar: _AnimatedBottomNavBar(
        items: _navItems(AppLocalizations.of(context)),
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
          child: TickerMode(enabled: false, child: screens[index]),
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
          child: TickerMode(enabled: true, child: screen),
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
    final bottomInset = MediaQuery.of(context).viewPadding.bottom;

    const brandLight = Color(0xFF45AEDF);
    const brandDark = Color(0xFF077CB4);
    final navColor = isDark ? const Color(0xFF1A2230) : Colors.white;
    final shadowColor = isDark
        ? const Color(0xAA000000)
        : const Color(0x223B63FF);
    const activeColor = brandDark;
    final activeBgColor = brandLight.withValues(alpha: isDark ? 0.22 : 0.14);
    final inactiveColor = isDark
        ? const Color(0xFF4A6070)
        : const Color(0xFFB0C4D0);
    const activeLabelColor = Colors.black;
    final inactiveLabelColor = isDark
        ? const Color(0xFF8AA0B0)
        : Colors.black54;

    return Container(
      margin: EdgeInsets.fromLTRB(
        16,
        0,
        16,
        bottomInset > 0 ? bottomInset + 8 : 14,
      ),
      height: 68,
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 0),
      decoration: BoxDecoration(
        color: navColor,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: shadowColor,
            blurRadius: 32,
            spreadRadius: 0,
            offset: const Offset(0, 8),
          ),
          if (!isDark)
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 0,
              spreadRadius: 1,
              offset: Offset.zero,
            ),
        ],
      ),
      child: Row(
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
              activeColor: activeColor,
              activeBgColor: activeBgColor,
              inactiveColor: inactiveColor,
              activeLabelColor: activeLabelColor,
              inactiveLabelColor: inactiveLabelColor,
              onTapDown: () => onTapDown(index),
              onTapCancel: onTapCancel,
              onTap: () => onTap(index),
            ),
          );
        }),
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
    required this.activeColor,
    required this.activeBgColor,
    required this.inactiveColor,
    required this.activeLabelColor,
    required this.inactiveLabelColor,
    required this.onTapDown,
    required this.onTapCancel,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final IconData activeIcon;
  final bool active;
  final bool pressed;
  final Color activeColor;
  final Color activeBgColor;
  final Color inactiveColor;
  final Color activeLabelColor;
  final Color inactiveLabelColor;
  final VoidCallback onTapDown;
  final VoidCallback onTapCancel;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: (_) => onTapDown(),
      onTapCancel: onTapCancel,
      onTapUp: (_) => onTapCancel(),
      onTap: onTap,
      child: AnimatedScale(
        duration: const Duration(milliseconds: 150),
        curve: Curves.easeOut,
        scale: pressed ? 0.88 : 1.0,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              width: active ? 58 : 38,
              height: 36,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: active ? activeBgColor : Colors.transparent,
                borderRadius: BorderRadius.circular(18),
                boxShadow: active
                    ? [
                        BoxShadow(
                          color: activeColor.withValues(alpha: 0.22),
                          blurRadius: 14,
                          spreadRadius: 0,
                          offset: const Offset(0, 4),
                        ),
                      ]
                    : null,
              ),
              child: active
                  ? _BrandIconGradient(
                      child: Icon(activeIcon, size: 22),
                    )
                  : Icon(icon, color: inactiveColor, size: 22),
            ),
            const SizedBox(height: 4),
            AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeOut,
              style: TextStyle(
                color: active ? activeLabelColor : inactiveLabelColor,
                fontSize: active ? 10.5 : 10,
                fontWeight: active ? FontWeight.w800 : FontWeight.w600,
                letterSpacing: active ? 0.3 : 0.1,
                height: 1,
              ),
              child: AnimatedOpacity(
                duration: const Duration(milliseconds: 250),
                opacity: active ? 1.0 : 0.6,
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BrandIconGradient extends StatelessWidget {
  const _BrandIconGradient({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return ShaderMask(
      blendMode: BlendMode.srcIn,
      shaderCallback: (bounds) => const LinearGradient(
        colors: [Color(0xFF45AEDF), Color(0xFF077CB4)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ).createShader(bounds),
      child: child,
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

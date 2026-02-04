import 'package:app_ky_service_center/screens/home/home_screen.dart';
import 'package:flutter/material.dart';
import 'categories/categories_screen.dart';
import 'repair/repair_screen.dart';
import 'cart/cart_screen.dart';
import 'profile/profile_screen.dart';
import '../services/cart_service.dart';

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  static final ValueNotifier<int> tabIndex = ValueNotifier<int>(0);

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  final List<Widget> _screens = const [
    HomeScreen(),
    CategoriesScreen(),
    RepairScreen(),
    CartScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: CartService.instance,
      builder: (context, _) {
        final cartCount = CartService.instance.totalItems;
        return ValueListenableBuilder<int>(
          valueListenable: MainNavigationScreen.tabIndex,
          builder: (context, currentIndex, _) {
            return Scaffold(
              body: _screens[currentIndex],
              bottomNavigationBar: SafeArea(
                top: false,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(28),
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0x1A000000),
                          blurRadius: 20,
                          offset: Offset(0, 8),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(28),
                      child: BottomNavigationBar(
                        currentIndex: currentIndex,
                        type: BottomNavigationBarType.fixed,
                        backgroundColor: Colors.white,
                        elevation: 0,
                        selectedItemColor: const Color(0xFF00B2D8),
                        unselectedItemColor: const Color(0xFF9CA3AF),
                        selectedLabelStyle: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                        unselectedLabelStyle: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                        showUnselectedLabels: true,
                        onTap: (index) {
                          MainNavigationScreen.tabIndex.value = index;
                        },
                        items: [
                          const BottomNavigationBarItem(
                            icon: Icon(Icons.home, size: 24),
                            label: "Home",
                          ),
                          const BottomNavigationBarItem(
                            icon: Icon(Icons.grid_view_rounded, size: 24),
                            label: "Categories",
                          ),
                          const BottomNavigationBarItem(
                            icon: Icon(Icons.build, size: 24),
                            label: "Repair",
                          ),
                          BottomNavigationBarItem(
                            icon: _CartBadge(
                              count: cartCount,
                              child: const Icon(Icons.shopping_cart, size: 24),
                            ),
                            label: "Cart",
                          ),
                          const BottomNavigationBarItem(
                            icon: Icon(Icons.person, size: 24),
                            label: "Profile",
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}

class _CartBadge extends StatelessWidget {
  const _CartBadge({required this.count, required this.child});

  final int count;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    if (count <= 0) return child;
    return Stack(
      clipBehavior: Clip.none,
      children: [
        child,
        Positioned(
          right: -6,
          top: -4,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
            decoration: BoxDecoration(
              color: const Color(0xFFE11D48),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              '$count',
              style: const TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

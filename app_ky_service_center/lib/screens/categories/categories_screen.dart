import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../models/category.dart';
import '../../services/api_service.dart';
import '../orders/orders_screen.dart';
import '../profile/profile_screen.dart';
import '../repair/repair_screen.dart';
import '../tickets/tickets_screen.dart';
import 'category_products_screen.dart';

const _primary = Color(0xFF4A6CF7);
const _background = Color(0xFFF8F9FB);
const _textPrimary = Color(0xFF1A1A1A);
const _textSecondary = Color(0xFF888888);
const _cardShadow = Color(0x14000000);
const _cardPressed = Color(0xFFEAF0FF);
const _cardBorder = Color(0xFFE8EDF5);
const _darkBackground = Color(0xFF0D1117);
const _darkSurface = Color(0xFF161B22);
const _darkSurfaceSoft = Color(0xFF1D2635);
const _darkBorder = Color(0xFF2B3442);
const _darkTextPrimary = Color(0xFFE6EDF7);
const _darkTextSecondary = Color(0xFF97A2B5);

class CategoriesScreen extends StatefulWidget {
  const CategoriesScreen({super.key, this.showBottomNav = false});

  final bool showBottomNav;

  @override
  State<CategoriesScreen> createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends State<CategoriesScreen> {
  bool _isLoading = true;
  String? _errorMessage;
  List<Category> _categories = const [];

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final categories = await ApiService.fetchCategories();
      if (!mounted) return;
      setState(() {
        _categories = categories;
        _isLoading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _errorMessage = 'Unable to load categories. Pull down to refresh.';
      });
    }
  }

  Future<void> _openCategory(Category category) async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => CategoryProductsScreen(
          categoryId: category.id,
          categoryName: category.name,
          title: category.name,
        ),
      ),
    );
  }

  void _onBottomNavTap(int index) {
    if (index == 1) return;

    if (index == 0) {
      if (Navigator.of(context).canPop()) {
        Navigator.of(context).pop();
      }
      return;
    }

    Widget destination;
    switch (index) {
      case 2:
        destination = const RepairScreen();
        break;
      case 3:
        destination = const OrdersScreen();
        break;
      case 4:
        destination = const TicketsScreen();
        break;
      case 5:
        destination = const ProfileScreen();
        break;
      default:
        return;
    }

    Navigator.of(
      context,
    ).pushReplacement(MaterialPageRoute(builder: (_) => destination));
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Theme(
      data: Theme.of(context).copyWith(
        textTheme: GoogleFonts.interTextTheme(Theme.of(context).textTheme),
      ),
      child: Scaffold(
        backgroundColor: isDark ? _darkBackground : _background,
        appBar: AppBar(
          automaticallyImplyLeading: false,
          backgroundColor: isDark ? _darkBackground : _background,
          surfaceTintColor: Colors.transparent,
          elevation: 0,
          centerTitle: false,
          title: Text(
            'Categories',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w700,
              color: isDark ? _darkTextPrimary : _textPrimary,
            ),
          ),
        ),
        body: RefreshIndicator(
          color: _primary,
          onRefresh: _loadCategories,
          child: _buildBody(),
        ),
        bottomNavigationBar: widget.showBottomNav
            ? _BottomNavBar(onTap: _onBottomNavTap)
            : null,
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator(color: _primary));
    }

    if (_errorMessage != null) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(24),
        children: [
          const SizedBox(height: 60),
          _InfoState(
            icon: Icons.wifi_off_rounded,
            title: 'Connection issue',
            message: _errorMessage!,
            actionLabel: 'Try again',
            onTap: _loadCategories,
          ),
        ],
      );
    }

    if (_categories.isEmpty) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(24),
        children: [
          const SizedBox(height: 60),
          _InfoState(
            icon: Icons.grid_view_rounded,
            title: 'No categories yet',
            message: 'Categories will appear here once available.',
            actionLabel: 'Refresh',
            onTap: _loadCategories,
          ),
        ],
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = constraints.maxWidth >= 760 ? 3 : 2;
        return GridView.builder(
          physics: const BouncingScrollPhysics(
            parent: AlwaysScrollableScrollPhysics(),
          ),
          padding: EdgeInsets.fromLTRB(
            16,
            8,
            16,
            widget.showBottomNav ? 108 : 24,
          ),
          itemCount: _categories.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: columns,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 0.84,
          ),
          itemBuilder: (context, index) {
            final category = _categories[index];
            return _CategoryCard(
              category: category,
              onTap: () => _openCategory(category),
            );
          },
        );
      },
    );
  }
}

class _CategoryCard extends StatefulWidget {
  const _CategoryCard({required this.category, required this.onTap});

  final Category category;
  final Future<void> Function() onTap;

  @override
  State<_CategoryCard> createState() => _CategoryCardState();
}

class _CategoryCardState extends State<_CategoryCard> {
  bool _pressed = false;
  bool _busy = false;

  void _setPressed(bool value) {
    if (!mounted) return;
    setState(() => _pressed = value);
  }

  Future<void> _handleTap() async {
    if (_busy) return;
    _busy = true;
    try {
      _setPressed(true);
      await Future<void>.delayed(const Duration(milliseconds: 80));
      _setPressed(false);
      await widget.onTap();
    } finally {
      _busy = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final category = widget.category;
    final imageUrl = category.imageUrl?.trim();

    return AnimatedScale(
      scale: _pressed ? 0.95 : 1,
      duration: const Duration(milliseconds: 140),
      curve: Curves.easeOut,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTapDown: (_) => _setPressed(true),
        onTapCancel: () => _setPressed(false),
        onTapUp: (_) => _setPressed(false),
        onTap: _handleTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          curve: Curves.easeOut,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: _pressed
                ? (isDark ? _darkSurfaceSoft : _cardPressed)
                : (isDark ? _darkSurface : Colors.white),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: isDark ? _darkBorder : _cardBorder),
            boxShadow: [
              BoxShadow(
                color: isDark ? const Color(0x33000000) : _cardShadow,
                blurRadius: 14,
                offset: Offset(0, 6),
              ),
            ],
          ),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final imageBoxSize = (constraints.maxWidth * 0.56).clamp(
                78.0,
                108.0,
              );
              final iconSize = (imageBoxSize * 0.46).clamp(32.0, 48.0);
              final imageRadius = (imageBoxSize * 0.2).clamp(14.0, 22.0);

              return Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: Center(
                      child: Container(
                        width: imageBoxSize,
                        height: imageBoxSize,
                        decoration: BoxDecoration(
                          color: isDark
                              ? const Color(0xFF22304A)
                              : const Color(0xFFEAF0FF),
                          borderRadius: BorderRadius.circular(imageRadius),
                        ),
                        child: imageUrl != null && imageUrl.isNotEmpty
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(
                                  imageRadius,
                                ),
                                child: Image.network(
                                  imageUrl,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return Icon(
                                      _iconForCategory(category.name),
                                      size: iconSize,
                                      color: _primary,
                                    );
                                  },
                                ),
                              )
                            : Icon(
                                _iconForCategory(category.name),
                                size: iconSize,
                                color: _primary,
                              ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    category.name,
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: isDark ? _darkTextPrimary : _textPrimary,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      height: 1.2,
                    ),
                  ),
                  if (category.productsCount != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      '${category.productsCount} items',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: isDark ? _darkTextSecondary : _textSecondary,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

class _BottomNavBar extends StatelessWidget {
  const _BottomNavBar({required this.onTap});

  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      decoration: BoxDecoration(
        color: isDark ? _darkSurface : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        boxShadow: [
          BoxShadow(
            color: isDark ? const Color(0x55000000) : const Color(0x1A0F172A),
            blurRadius: 18,
            offset: Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(10, 10, 10, 12),
          child: Row(
            children: [
              Expanded(
                child: _BottomNavItem(
                  icon: Icons.home_rounded,
                  label: 'Home',
                  isActive: false,
                  onTap: () => onTap(0),
                ),
              ),
              Expanded(
                child: _BottomNavItem(
                  icon: Icons.grid_view_rounded,
                  label: 'Categories',
                  isActive: true,
                  onTap: () => onTap(1),
                ),
              ),
              Expanded(
                child: _BottomNavItem(
                  icon: Icons.build_rounded,
                  label: 'Repair',
                  isActive: false,
                  onTap: () => onTap(2),
                ),
              ),
              Expanded(
                child: _BottomNavItem(
                  icon: Icons.receipt_long_rounded,
                  label: 'Orders',
                  isActive: false,
                  onTap: () => onTap(3),
                ),
              ),
              Expanded(
                child: _BottomNavItem(
                  icon: Icons.confirmation_number_rounded,
                  label: 'Tickets',
                  isActive: false,
                  onTap: () => onTap(4),
                ),
              ),
              Expanded(
                child: _BottomNavItem(
                  icon: Icons.person_rounded,
                  label: 'Profile',
                  isActive: false,
                  onTap: () => onTap(5),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BottomNavItem extends StatefulWidget {
  const _BottomNavItem({
    required this.icon,
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  @override
  State<_BottomNavItem> createState() => _BottomNavItemState();
}

class _BottomNavItemState extends State<_BottomNavItem> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final iconColor = widget.isActive
        ? _primary
        : (isDark ? _darkTextSecondary : const Color(0xFF888888));
    final labelColor = widget.isActive
        ? (isDark ? _darkTextPrimary : _textPrimary)
        : (isDark ? _darkTextSecondary : const Color(0xFF888888));

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: (_) => setState(() => _pressed = true),
      onTapCancel: () => setState(() => _pressed = false),
      onTapUp: (_) => setState(() => _pressed = false),
      onTap: widget.onTap,
      child: AnimatedScale(
        scale: _pressed ? 0.95 : 1,
        duration: const Duration(milliseconds: 120),
        curve: Curves.easeOut,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedSlide(
              offset: widget.isActive
                  ? const Offset(0, -0.08)
                  : const Offset(0, 0),
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeOut,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeOut,
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: widget.isActive
                      ? (isDark
                            ? const Color(0xFF22304A)
                            : const Color(0xFFEAF0FF))
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Icon(
                  widget.icon,
                  size: widget.isActive ? 23 : 21,
                  color: iconColor,
                ),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              widget.label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 11,
                fontWeight: widget.isActive ? FontWeight.w600 : FontWeight.w500,
                color: labelColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoState extends StatelessWidget {
  const _InfoState({
    required this.icon,
    required this.title,
    required this.message,
    required this.actionLabel,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String message;
  final String actionLabel;
  final Future<void> Function() onTap;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? _darkSurface : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isDark ? _darkBorder : _cardBorder),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            size: 36,
            color: isDark ? _darkTextSecondary : _textSecondary,
          ),
          const SizedBox(height: 10),
          Text(
            title,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: isDark ? _darkTextPrimary : _textPrimary,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            message,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: isDark ? _darkTextSecondary : _textSecondary,
            ),
          ),
          const SizedBox(height: 12),
          ElevatedButton(
            onPressed: () {
              onTap();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: _primary,
              foregroundColor: Colors.white,
              elevation: 0,
            ),
            child: Text(actionLabel),
          ),
        ],
      ),
    );
  }
}

IconData _iconForCategory(String name) {
  final value = name.toLowerCase();
  if (value.contains('phone') || value.contains('iphone')) {
    return Icons.phone_iphone_rounded;
  }
  if (value.contains('access')) {
    return Icons.cable_rounded;
  }
  if (value.contains('repair') || value.contains('service')) {
    return Icons.build_rounded;
  }
  if (value.contains('tablet') || value.contains('ipad')) {
    return Icons.tablet_mac_rounded;
  }
  if (value.contains('laptop') || value.contains('macbook')) {
    return Icons.laptop_mac_rounded;
  }
  if (value.contains('watch')) {
    return Icons.watch_rounded;
  }
  return Icons.widgets_rounded;
}

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'category_products_screen.dart';

class CategoriesScreen extends StatelessWidget {
  const CategoriesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final categories = [
      _CategoryItem(
        label: 'iPhone',
        icon: Icons.phone_iphone,
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const CategoryProductsScreen(
                categoryName: 'iPhone',
                title: 'iPhone',
              ),
            ),
          );
        },
      ),
      _CategoryItem(
        label: 'Macbook',
        icon: Icons.laptop_mac,
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const CategoryProductsScreen(
                categoryName: 'Macbook',
                title: 'Macbook',
              ),
            ),
          );
        },
      ),
      _CategoryItem(
        label: 'Samsung',
        icon: Icons.phone_android,
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const CategoryProductsScreen(
                categoryName: 'Samsung',
                title: 'Samsung',
              ),
            ),
          );
        },
      ),
      _CategoryItem(label: 'Audio', icon: Icons.headphones),
      _CategoryItem(label: 'Parts & Accessories', icon: Icons.memory),
      _CategoryItem(label: 'Repair', icon: Icons.build_circle_outlined),
    ];
    final width = MediaQuery.of(context).size.width;
    final isDesktop = width >= 1024;
    final isTablet = width >= 600 && width < 1024;
    final radius = isDesktop ? 10.0 : 14.0;
    final columns = isDesktop ? 6 : (isTablet ? 4 : 2);

    return Scaffold(
      backgroundColor: const Color(0xFFF6F7FB),
      appBar: AppBar(
        title: const Text(
          'Categories',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.2,
            color: Colors.black87,
          ),
        ),
        backgroundColor: const Color(0xFFF6F7FB),
        foregroundColor: Colors.black87,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 20),
        child: GridView.builder(
          itemCount: categories.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: columns,
            crossAxisSpacing: 14,
            mainAxisSpacing: 14,
            childAspectRatio: 1.05,
          ),
          itemBuilder: (context, index) {
            return _CategoryCard(
              item: categories[index],
              radius: radius,
            );
          },
        ),
      ),
    );
  }
}

class _CategoryItem {
  const _CategoryItem({
    required this.label,
    required this.icon,
    this.onTap,
  });

  final String label;
  final IconData icon;
  final VoidCallback? onTap;
}

class _CategoryCard extends StatefulWidget {
  const _CategoryCard({required this.item, required this.radius});

  final _CategoryItem item;
  final double radius;

  @override
  State<_CategoryCard> createState() => _CategoryCardState();
}

class _CategoryCardState extends State<_CategoryCard> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        transform: Matrix4.identity()..translate(0.0, _hovered ? -4.0 : 0.0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(widget.radius + 4),
          border: Border.all(color: const Color(0xFFE6E9F0)),
          boxShadow: [
            BoxShadow(
              color: _hovered
                  ? const Color(0x140F6BFF)
                  : const Color(0x0A000000),
              blurRadius: _hovered ? 16 : 10,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: InkWell(
          onTap: () {
            HapticFeedback.lightImpact();
            widget.item.onTap?.call();
          },
          borderRadius: BorderRadius.circular(widget.radius),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  height: 46,
                  width: 46,
                  decoration: BoxDecoration(
                    color: const Color(0xFFEFF6FF),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(
                    widget.item.icon,
                    color: const Color(0xFF0F6BFF),
                    size: 22,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  widget.item.label,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                    color: Color(0xFF111827),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

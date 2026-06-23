import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../models/category.dart';
import '../../../theme/app_fonts.dart';
import '../../../widgets/app_network_image.dart';
import '../../categories/category_products_screen.dart';
import 'home_colors.dart';

/// Grid of category chips shown on the home screen. Tapping a "repair" or
/// "service" category routes through [onRepairTap] instead of navigating
/// directly to the category products screen.
class HomeCategoryShowcaseStrip extends StatelessWidget {
  const HomeCategoryShowcaseStrip({
    super.key,
    required this.categories,
    required this.iconFor,
    required this.onRepairTap,
  });

  final List<Category> categories;
  final IconData Function(String) iconFor;
  final VoidCallback onRepairTap;

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: EdgeInsets.zero,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        mainAxisSpacing: 12,
        crossAxisSpacing: 8,
        childAspectRatio: 0.82,
      ),
      itemCount: categories.length,
      itemBuilder: (_, i) {
        final category = categories[i];
        final isRepair =
            category.name.toLowerCase().contains('repair') ||
            category.name.toLowerCase().contains('service');
        return _CategoryChip(
          category: category,
          icon: iconFor(category.name),
          onTap: () {
            if (isRepair) {
              onRepairTap();
              return;
            }
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => CategoryProductsScreen(
                  categoryId: category.id,
                  categoryName: category.name,
                  title: category.name,
                ),
              ),
            );
          },
        );
      },
    );
  }
}

class _CategoryChip extends StatefulWidget {
  const _CategoryChip({
    required this.category,
    required this.icon,
    required this.onTap,
  });

  final Category category;
  final IconData icon;
  final VoidCallback onTap;

  @override
  State<_CategoryChip> createState() => _CategoryChipState();
}

class _CategoryChipState extends State<_CategoryChip>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 120),
    );
    _scale = Tween<double>(
      begin: 1.0,
      end: 0.93,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = homeIsDark(context);
    final imageUrl = widget.category.imageUrl;

    return GestureDetector(
      onTapDown: (_) => _ctrl.forward(),
      onTapUp: (_) {
        _ctrl.reverse();
        widget.onTap();
      },
      onTapCancel: () => _ctrl.reverse(),
      child: ScaleTransition(
        scale: _scale,
        child: SizedBox(
          width: 72,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // ── Icon circle ──────────────────────────────────────────
              Container(
                width: 58,
                height: 58,
                decoration: BoxDecoration(
                  color: isDark
                      ? const Color(0xFF1D2635)
                      : const Color(0xFFEEF2FF),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: homePrimary.withValues(alpha: isDark ? 0.10 : 0.08),
                      blurRadius: 10,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: imageUrl != null && imageUrl.isNotEmpty
                    ? Padding(
                        padding: const EdgeInsets.all(10),
                        child: AppNetworkImage(
                          imageUrl,
                          fit: BoxFit.contain,
                          errorWidget: (ctx, url, err) => Icon(
                            widget.icon,
                            color: homePrimary,
                            size: 26,
                          ),
                        ),
                      )
                    : Icon(widget.icon, color: homePrimary, size: 26),
              ),
              const SizedBox(height: 7),
              // ── Label ────────────────────────────────────────────────
              Text(
                widget.category.name,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: kmFont(context, GoogleFonts.manrope(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: homeTextPrimary(context),
                  height: 1.2,
                )),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

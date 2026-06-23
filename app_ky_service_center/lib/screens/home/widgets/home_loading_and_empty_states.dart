import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:skeletonizer/skeletonizer.dart';

import '../../../l10n/app_localizations.dart';
import '../../../models/category.dart';
import '../../../models/product.dart';
import 'home_category_showcase_strip.dart';
import 'home_colors.dart';
import 'home_flash_product_card.dart';
import 'home_section_header.dart';

/// Simple centered icon + message placeholder for empty/error states on
/// the home screen.
class HomeSimpleState extends StatelessWidget {
  const HomeSimpleState({super.key, required this.icon, required this.title});

  final IconData icon;
  final String title;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: homeSurface(context),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: homeCardBorder(context)),
      ),
      child: Column(
        children: [
          Icon(icon, color: homeTextMuted(context)),
          const SizedBox(height: 8),
          Text(title, style: TextStyle(color: homeTextMuted(context))),
        ],
      ),
    );
  }
}

/// Skeleton placeholder for the categories section while it loads.
class HomeCategorySkeleton extends StatelessWidget {
  const HomeCategorySkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Skeletonizer(
      enabled: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          HomeSectionHeader(
            title: l.categories,
            actionLabel: l.viewAll,
            onTap: () {},
          ),
          const SizedBox(height: 14),
          HomeCategoryShowcaseStrip(
            categories: List.generate(
              4,
              (index) => Category(id: index, name: 'Loading', imageUrl: ''),
            ),
            iconFor: (name) => HugeIcons.strokeRoundedSquare01,
            onRepairTap: () {},
          ),
        ],
      ),
    );
  }
}

/// Skeleton placeholder grid for product sections while they load.
class HomeProductsSkeleton extends StatelessWidget {
  const HomeProductsSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Skeletonizer(
      enabled: true,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final columns = constraints.maxWidth >= 720 ? 3 : 2;
          return GridView.builder(
            itemCount: columns == 3 ? 6 : 4,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: columns,
              mainAxisSpacing: 14,
              crossAxisSpacing: 14,
              childAspectRatio: columns == 3 ? 0.72 : 0.64,
            ),
            itemBuilder: (context, index) {
              return HomeFlashProductCard(
                product: Product(
                  id: index,
                  name: 'Loading Product Name',
                  price: 999.0,
                ),
                onOpen: () {},
                onAdd: () {},
              );
            },
          );
        },
      ),
    );
  }
}

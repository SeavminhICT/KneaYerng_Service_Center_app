import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';

import '../../../l10n/app_localizations.dart';
import '../../../widgets/empty_state_view.dart';

/// Empty-state shown when a search query matches no products.
class AllProductsSearchEmptyState extends StatelessWidget {
  const AllProductsSearchEmptyState({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      children: [
        const SizedBox(height: 60),
        const EmptyStateView(
          icon: HugeIcons.strokeRoundedSearchRemove,
          title: 'No products match your search.',
          subtitle: 'Try another keyword, brand, or category.',
        ),
      ],
    );
  }
}

/// Empty-state shown when the catalog has no products at all.
class AllProductsEmptyState extends StatelessWidget {
  const AllProductsEmptyState({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      children: [
        const SizedBox(height: 60),
        const EmptyStateView(
          icon: HugeIcons.strokeRoundedPackage,
          title: 'No products available.',
          subtitle: 'Pull down to refresh after the backend adds products.',
        ),
      ],
    );
  }
}

/// Error-state shown when the product fetch fails.
class AllProductsErrorState extends StatelessWidget {
  const AllProductsErrorState({super.key, required this.onRetry});

  final Future<void> Function() onRetry;

  @override
  Widget build(BuildContext context) {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      children: [
        const SizedBox(height: 60),
        EmptyStateView(
          icon: HugeIcons.strokeRoundedWifiOff01,
          title: 'Unable to load products.',
          subtitle: 'Check the API connection and refresh the catalog again.',
          actionLabel: AppLocalizations.of(context).retry,
          onAction: () {
            onRetry();
          },
        ),
      ],
    );
  }
}

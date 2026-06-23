import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:intl/intl.dart';
import '../../l10n/app_localizations.dart';
import '../../models/product.dart';
import '../../services/favorite_service.dart';
import '../../widgets/app_network_image.dart';
import '../../widgets/empty_state_view.dart';
import '../products/product_detail_screen.dart';

const _surface = Color(0xFFFFFFFF);
const _surfaceAlt = Color(0xFFF1F5F9);
const _border = Color(0xFFE2E8F0);
const _textPrimary = Color(0xFF0F172A);
const _textMuted = Color(0xFF64748B);
const _brandBlue = Color(0xFF0F6BFF);
const _danger = Color(0xFFDC2626);
const _shadow = Color(0x140F172A);

final NumberFormat _currencyFormat = NumberFormat.currency(symbol: '\$');

bool _isDark(BuildContext context) =>
    Theme.of(context).brightness == Brightness.dark;

Color _getBackground(BuildContext context) =>
    _isDark(context) ? const Color(0xFF0D1117) : const Color(0xFFF9FAFD);

Color _getSurface(BuildContext context) =>
    _isDark(context) ? const Color(0xFF161B22) : _surface;

Color _getSurfaceAlt(BuildContext context) =>
    _isDark(context) ? const Color(0xFF1D2635) : _surfaceAlt;

Color _getTextPrimary(BuildContext context) =>
    _isDark(context) ? const Color(0xFFE6EDF7) : _textPrimary;

Color _getTextMuted(BuildContext context) =>
    _isDark(context) ? const Color(0xFF97A2B5) : _textMuted;

Color _getBorder(BuildContext context) =>
    _isDark(context) ? const Color(0xFF2B3442) : _border;

class FavoriteScreen extends StatefulWidget {
  const FavoriteScreen({super.key});

  @override
  State<FavoriteScreen> createState() => _FavoriteScreenState();
}

class _FavoriteScreenState extends State<FavoriteScreen> {
  bool _isGridView = true;

  Future<void> _confirmClearAll(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Clear favorites?'),
        content: const Text(
          'This will remove all items from your favorites list.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: _danger),
            child: const Text('Clear all'),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      FavoriteService.instance.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return AnimatedBuilder(
      animation: FavoriteService.instance,
      builder: (context, _) {
        final items = FavoriteService.instance.items;
        return Scaffold(
          backgroundColor: _getBackground(context),
          body: SafeArea(
            child: items.isEmpty
                ? Column(
                    children: [
                      _Header(
                        title: l.favorites,
                        count: 0,
                        isGridView: _isGridView,
                        onToggleView: null,
                        onClearAll: null,
                      ),
                      const Expanded(child: _EmptyState()),
                    ],
                  )
                : Column(
                    children: [
                      _Header(
                        title: l.favorites,
                        count: items.length,
                        isGridView: _isGridView,
                        onToggleView: () =>
                            setState(() => _isGridView = !_isGridView),
                        onClearAll: () => _confirmClearAll(context),
                      ),
                      Expanded(
                        child: AnimatedSwitcher(
                          duration: const Duration(milliseconds: 250),
                          child: _isGridView
                              ? _buildGridView(context, items)
                              : _buildListView(context, items),
                        ),
                      ),
                    ],
                  ),
          ),
        );
      },
    );
  }

  Widget _buildGridView(BuildContext context, List<Product> items) {
    return GridView.builder(
      key: const ValueKey('grid'),
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 14,
        crossAxisSpacing: 14,
        childAspectRatio: 0.66,
      ),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final product = items[index];
        return _GridProductCard(product: product);
      },
    );
  }

  Widget _buildListView(BuildContext context, List<Product> items) {
    return ListView.separated(
      key: const ValueKey('list'),
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
      itemCount: items.length,
      separatorBuilder: (_, _) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final product = items[index];
        return _ListProductCard(product: product);
      },
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({
    required this.title,
    required this.count,
    required this.isGridView,
    required this.onToggleView,
    required this.onClearAll,
  });

  final String title;
  final int count;
  final bool isGridView;
  final VoidCallback? onToggleView;
  final VoidCallback? onClearAll;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.w800,
                    color: _getTextPrimary(context),
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  count == 0
                      ? 'No saved items yet'
                      : '$count item${count == 1 ? '' : 's'} saved',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: _getTextMuted(context),
                  ),
                ),
              ],
            ),
          ),
          if (onClearAll != null)
            _IconPill(
              icon: HugeIcons.strokeRoundedDelete02,
              tooltip: 'Clear all',
              onTap: onClearAll!,
              foreground: _danger,
            ),
          if (onToggleView != null) ...[
            const SizedBox(width: 8),
            _IconPill(
              icon: isGridView
                  ? HugeIcons.strokeRoundedView
                  : HugeIcons.strokeRoundedGridView,
              tooltip: isGridView ? 'List view' : 'Grid view',
              onTap: onToggleView!,
            ),
          ],
        ],
      ),
    );
  }
}

class _IconPill extends StatelessWidget {
  const _IconPill({
    required this.icon,
    required this.tooltip,
    required this.onTap,
    this.foreground,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback onTap;
  final Color? foreground;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: Material(
        color: _getSurfaceAlt(context),
        shape: const CircleBorder(),
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(11),
            child: Icon(
              icon,
              size: 20,
              color: foreground ?? _getTextPrimary(context),
            ),
          ),
        ),
      ),
    );
  }
}

class _ProductImage extends StatelessWidget {
  const _ProductImage({required this.imageUrl, required this.borderRadius});

  final String? imageUrl;
  final BorderRadius borderRadius;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: borderRadius,
      child: imageUrl == null || imageUrl!.isEmpty
          ? Icon(
              HugeIcons.strokeRoundedImageNotFound02,
              size: 36,
              color: _getBorder(context),
            )
          : AppNetworkImage(
              imageUrl!,
              fit: BoxFit.cover,
              errorWidget: (context, url, error) => Icon(
                HugeIcons.strokeRoundedImageNotFound02,
                size: 36,
                color: _getBorder(context),
              ),
            ),
    );
  }
}

class _SaleBadge extends StatelessWidget {
  const _SaleBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: _danger,
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Text(
        'SALE',
        style: TextStyle(
          color: Colors.white,
          fontSize: 10,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.4,
        ),
      ),
    );
  }
}

class _PriceTag extends StatelessWidget {
  const _PriceTag({required this.product, this.alignStart = true});

  final Product product;
  final bool alignStart;

  @override
  Widget build(BuildContext context) {
    if (!product.hasDiscount) {
      return Text(
        _currencyFormat.format(product.salePrice),
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w800,
          color: _brandBlue,
        ),
      );
    }
    final priceWidgets = [
      Text(
        _currencyFormat.format(product.salePrice),
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w800,
          color: _danger,
        ),
      ),
      Text(
        _currencyFormat.format(product.price),
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w500,
          color: _getTextMuted(context),
          decoration: TextDecoration.lineThrough,
        ),
      ),
    ];
    return alignStart
        ? Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [priceWidgets[1], const SizedBox(height: 2), priceWidgets[0]],
          )
        : Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              priceWidgets[0],
              const SizedBox(width: 8),
              priceWidgets[1],
            ],
          );
  }
}

class _CardChrome extends StatelessWidget {
  const _CardChrome({required this.child, required this.onTap});

  final Widget child;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: _getSurface(context),
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: _getBorder(context), width: 1),
            boxShadow: [
              BoxShadow(
                color: _shadow.withValues(alpha: 0.08),
                blurRadius: 14,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: child,
        ),
      ),
    );
  }
}

class _GridProductCard extends StatelessWidget {
  const _GridProductCard({required this.product});

  final Product product;

  @override
  Widget build(BuildContext context) {
    return _CardChrome(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => ProductDetailScreen(product: product),
          ),
        );
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AspectRatio(
            aspectRatio: 1.15,
            child: Stack(
              fit: StackFit.expand,
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: _getSurfaceAlt(context),
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(18),
                      topRight: Radius.circular(18),
                    ),
                  ),
                  child: _ProductImage(
                    imageUrl: product.imageUrl,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(18),
                      topRight: Radius.circular(18),
                    ),
                  ),
                ),
                if (product.hasDiscount)
                  Positioned(top: 8, left: 8, child: const _SaleBadge()),
                Positioned(
                  top: 6,
                  right: 6,
                  child: _FavoriteButton(product: product, compact: true),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.brand ?? 'Unknown',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: _getTextMuted(context),
                    letterSpacing: 0.2,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  product.name,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: _getTextPrimary(context),
                    height: 1.25,
                  ),
                ),
                const SizedBox(height: 8),
                _PriceTag(product: product),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ListProductCard extends StatelessWidget {
  const _ListProductCard({required this.product});

  final Product product;

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: ValueKey(product.id),
      direction: DismissDirection.endToStart,
      onDismissed: (_) => FavoriteService.instance.remove(product),
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 24),
        decoration: BoxDecoration(
          color: _danger,
          borderRadius: BorderRadius.circular(18),
        ),
        child: const Icon(HugeIcons.strokeRoundedDelete02, color: Colors.white),
      ),
      child: _CardChrome(
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => ProductDetailScreen(product: product),
            ),
          );
        },
        child: Row(
          children: [
            SizedBox(
              height: 104,
              width: 104,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: _getSurfaceAlt(context),
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(18),
                        bottomLeft: Radius.circular(18),
                      ),
                    ),
                    child: _ProductImage(
                      imageUrl: product.imageUrl,
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(18),
                        bottomLeft: Radius.circular(18),
                      ),
                    ),
                  ),
                  if (product.hasDiscount)
                    Positioned(top: 6, left: 6, child: const _SaleBadge()),
                ],
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      product.brand ?? 'Unknown',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: _getTextMuted(context),
                        letterSpacing: 0.2,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      product.name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: _getTextPrimary(context),
                        height: 1.25,
                      ),
                    ),
                    const SizedBox(height: 8),
                    _PriceTag(product: product, alignStart: false),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(right: 10),
              child: _FavoriteButton(product: product, compact: false),
            ),
          ],
        ),
      ),
    );
  }
}

class _FavoriteButton extends StatelessWidget {
  const _FavoriteButton({required this.product, required this.compact});

  final Product product;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: compact ? Colors.white : _danger.withValues(alpha: 0.1),
      shape: const CircleBorder(),
      elevation: compact ? 2 : 0,
      shadowColor: _shadow,
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: () => FavoriteService.instance.remove(product),
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Icon(
            HugeIcons.strokeRoundedFavourite,
            color: _danger,
            size: compact ? 17 : 19,
          ),
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return EmptyStateView(
      icon: HugeIcons.strokeRoundedFavourite,
      title: l.noFavorites,
      subtitle: 'Add items to your favorites to see them here',
      actionLabel: 'Continue Shopping',
      onAction: () => Navigator.of(context).pop(),
    );
  }
}

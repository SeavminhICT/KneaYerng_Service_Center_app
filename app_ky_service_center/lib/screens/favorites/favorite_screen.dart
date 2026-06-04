import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../l10n/app_localizations.dart';
import '../../models/product.dart';
import '../../services/favorite_service.dart';
import '../products/product_detail_screen.dart';
import '../../widgets/app_network_image.dart';


final _currency = NumberFormat.currency(symbol: '\$', decimalDigits: 2);

class FavoriteScreen extends StatefulWidget {
  const FavoriteScreen({super.key});

  @override
  State<FavoriteScreen> createState() => _FavoriteScreenState();
}

class _FavoriteScreenState extends State<FavoriteScreen>
    with SingleTickerProviderStateMixin {
  bool _isGridView = true;
  late AnimationController _fadeCtrl;
  late Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _fadeCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _fadeAnim = CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeOut);
    _fadeCtrl.forward();
  }

  @override
  void dispose() {
    _fadeCtrl.dispose();
    super.dispose();
  }

  void _toggleView() {
    _fadeCtrl.reverse().then((_) {
      setState(() => _isGridView = !_isGridView);
      _fadeCtrl.forward();
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: FavoriteService.instance,
      builder: (context, _) {
        final items = FavoriteService.instance.items;
        final isDark = Theme.of(context).brightness == Brightness.dark;

        return Scaffold(
          backgroundColor:
              isDark ? const Color(0xFF0D1117) : const Color(0xFFF4F6FB),
          body: SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _Header(
                  count: items.length,
                  isGridView: _isGridView,
                  onToggle: items.isEmpty ? null : _toggleView,
                ),
                Expanded(
                  child: items.isEmpty
                      ? const _EmptyState()
                      : FadeTransition(
                          opacity: _fadeAnim,
                          child: _isGridView
                              ? _GridBody(items: items)
                              : _ListBody(items: items),
                        ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

// ─── Header ──────────────────────────────────────────────────────────────────

class _Header extends StatelessWidget {
  const _Header({
    required this.count,
    required this.isGridView,
    required this.onToggle,
  });

  final int count;
  final bool isGridView;
  final VoidCallback? onToggle;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final l = AppLocalizations.of(context);

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 16, 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l.favorites,
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.w800,
                    color: isDark
                        ? const Color(0xFFE6EDF7)
                        : const Color(0xFF0F172A),
                    letterSpacing: -0.5,
                  ),
                ),
                if (count > 0) ...[
                  const SizedBox(height: 4),
                  Text(
                    '$count ${count == 1 ? 'item' : 'items'} saved',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: isDark
                          ? const Color(0xFF7D8FA9)
                          : const Color(0xFF64748B),
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (onToggle != null)
            GestureDetector(
              onTap: onToggle,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: isDark
                      ? const Color(0xFF1D2635)
                      : Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.06),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Icon(
                  isGridView ? Icons.view_list_rounded : Icons.grid_view_rounded,
                  size: 22,
                  color: const Color(0xFF0F6BFF),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// ─── Grid ─────────────────────────────────────────────────────────────────────

class _GridBody extends StatelessWidget {
  const _GridBody({required this.items});
  final List<Product> items;

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 14,
        crossAxisSpacing: 14,
        childAspectRatio: 0.62,
      ),
      itemCount: items.length,
      itemBuilder: (_, i) => _GridCard(product: items[i]),
    );
  }
}

class _GridCard extends StatelessWidget {
  const _GridCard({required this.product});
  final Product product;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final imageUrl = product.imageUrl;
    final hasDiscount = product.hasDiscount;

    return GestureDetector(
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => ProductDetailScreen(product: product)),
      ),
      child: Container(
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF161B22) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.25 : 0.07),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Image ──
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(20),
                  ),
                  child: Container(
                    height: 150,
                    width: double.infinity,
                    color: isDark
                        ? const Color(0xFF1D2635)
                        : const Color(0xFFF0F4FC),
                    child: imageUrl != null && imageUrl.isNotEmpty
                        ? AppNetworkImage(
                            imageUrl,
                            fit: BoxFit.cover,
                            errorWidget: (ctx, url, err) =>
                                const _ImagePlaceholder(),
                          )
                        : const _ImagePlaceholder(),
                  ),
                ),
                // Sale badge
                if (hasDiscount)
                  Positioned(
                    top: 10,
                    left: 10,
                    child: _SaleBadge(
                      percent: product.price > 0
                          ? (product.price - product.salePrice) /
                              product.price *
                              100
                          : null,
                    ),
                  ),
                // Remove favorite button
                Positioned(
                  top: 8,
                  right: 8,
                  child: _FavButton(
                    onTap: () => FavoriteService.instance.remove(product),
                  ),
                ),
              ],
            ),
            // ── Info ──
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Flexible(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (product.brand != null && product.brand!.isNotEmpty)
                            Text(
                              product.brand!,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF0F6BFF),
                                letterSpacing: 0.3,
                              ),
                            ),
                          const SizedBox(height: 3),
                          Text(
                            product.name,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: isDark
                                  ? const Color(0xFFE6EDF7)
                                  : const Color(0xFF0F172A),
                              height: 1.3,
                            ),
                          ),
                        ],
                      ),
                    ),
                    _PriceBlock(
                      product: product,
                      hasDiscount: hasDiscount,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── List ─────────────────────────────────────────────────────────────────────

class _ListBody extends StatelessWidget {
  const _ListBody({required this.items});
  final List<Product> items;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
      itemCount: items.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (_, i) => _ListCard(product: items[i]),
    );
  }
}

class _ListCard extends StatelessWidget {
  const _ListCard({required this.product});
  final Product product;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final imageUrl = product.imageUrl;
    final hasDiscount = product.hasDiscount;

    return GestureDetector(
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => ProductDetailScreen(product: product)),
      ),
      child: Container(
        height: 110,
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF161B22) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.25 : 0.07),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            // ── Image ──
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.horizontal(
                    left: Radius.circular(20),
                  ),
                  child: Container(
                    height: 110,
                    width: 110,
                    color: isDark
                        ? const Color(0xFF1D2635)
                        : const Color(0xFFF0F4FC),
                    child: imageUrl != null && imageUrl.isNotEmpty
                        ? AppNetworkImage(
                            imageUrl,
                            fit: BoxFit.cover,
                            errorWidget: (_, __, ___) =>
                                const _ImagePlaceholder(),
                          )
                        : const _ImagePlaceholder(),
                  ),
                ),
                if (hasDiscount)
                  Positioned(
                    top: 8,
                    left: 8,
                    child: _SaleBadge(
                      percent: product.price > 0
                          ? (product.price - product.salePrice) /
                              product.price *
                              100
                          : null,
                    ),
                  ),
              ],
            ),
            // ── Info ──
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(14, 14, 8, 14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (product.brand != null && product.brand!.isNotEmpty)
                          Text(
                            product.brand!,
                            style: const TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF0F6BFF),
                              letterSpacing: 0.3,
                            ),
                          ),
                        const SizedBox(height: 3),
                        Text(
                          product.name,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: isDark
                                ? const Color(0xFFE6EDF7)
                                : const Color(0xFF0F172A),
                            height: 1.3,
                          ),
                        ),
                      ],
                    ),
                    _PriceBlock(product: product, hasDiscount: hasDiscount),
                  ],
                ),
              ),
            ),
            // ── Remove button ──
            Padding(
              padding: const EdgeInsets.only(right: 12),
              child: _FavButton(
                onTap: () => FavoriteService.instance.remove(product),
                size: 36,
                iconSize: 18,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Shared Widgets ───────────────────────────────────────────────────────────

class _PriceBlock extends StatelessWidget {
  const _PriceBlock({required this.product, required this.hasDiscount});
  final Product product;
  final bool hasDiscount;

  @override
  Widget build(BuildContext context) {
    if (hasDiscount) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _currency.format(product.price),
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: Color(0xFF94A3B8),
              decoration: TextDecoration.lineThrough,
              decorationColor: Color(0xFF94A3B8),
            ),
          ),
          const SizedBox(height: 1),
          Text(
            _currency.format(product.salePrice),
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w800,
              color: Color(0xFFE53935),
            ),
          ),
        ],
      );
    }
    return Text(
      _currency.format(product.salePrice),
      style: const TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.w800,
        color: Color(0xFF0F6BFF),
      ),
    );
  }
}

class _SaleBadge extends StatelessWidget {
  const _SaleBadge({this.percent});
  final double? percent;

  @override
  Widget build(BuildContext context) {
    final label = (percent != null && percent! > 0)
        ? '-${percent!.toStringAsFixed(0)}%'
        : 'Sale';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFFF4040), Color(0xFFFF6B35)],
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 9,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.2,
        ),
      ),
    );
  }
}

class _FavButton extends StatelessWidget {
  const _FavButton({required this.onTap, this.size = 32, this.iconSize = 16});
  final VoidCallback onTap;
  final double size;
  final double iconSize;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: size,
        height: size,
        decoration: const BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Color(0x20000000),
              blurRadius: 8,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Icon(
          Icons.favorite_rounded,
          color: const Color(0xFFE53935),
          size: iconSize,
        ),
      ),
    );
  }
}

class _ImagePlaceholder extends StatelessWidget {
  const _ImagePlaceholder();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Icon(
        Icons.image_not_supported_outlined,
        size: 32,
        color: Colors.grey.shade400,
      ),
    );
  }
}

// ─── Empty State ──────────────────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: isDark
                      ? [const Color(0xFF1D2635), const Color(0xFF252E3D)]
                      : [const Color(0xFFFFE8E8), const Color(0xFFFFF0F0)],
                ),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.favorite_border_rounded,
                size: 52,
                color: Color(0xFFE53935),
              ),
            ),
            const SizedBox(height: 28),
            Text(
              'No Favorites Yet',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: isDark
                    ? const Color(0xFFE6EDF7)
                    : const Color(0xFF0F172A),
                letterSpacing: -0.3,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'Items you heart will appear here.\nStart exploring!',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w400,
                color: isDark
                    ? const Color(0xFF7D8FA9)
                    : const Color(0xFF64748B),
                height: 1.5,
              ),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.of(context).pop(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0F6BFF),
                  foregroundColor: Colors.white,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: const Text(
                  'Explore Products',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../l10n/app_localizations.dart';
import '../../models/product.dart';
import '../../services/api_service.dart';
import '../../services/cart_service.dart';
import '../products/product_detail_screen.dart';
import '../cart/cart_screen.dart';
import 'package:skeletonizer/skeletonizer.dart';

const _surface = Colors.white;
const _surfaceAlt = Color(0xFFF2F5FB);
const _border = Color(0xFFE7ECF5);
const _textPrimary = Color(0xFF1A1A1A);
const _textSecondary = Color(0xFF888888);
const _primary = Color(0xFF4A6CF7);
const _danger = Color(0xFFDC2626);
const _success = Color(0xFF16A34A);
const _shadow = Color(0x140F172A);
const _darkSurface = Color(0xFF161B22);
const _darkSurfaceAlt = Color(0xFF1D2635);
const _darkBorder = Color(0xFF2B3442);
const _darkTextPrimary = Color(0xFFE6EDF7);
const _darkTextSecondary = Color(0xFF97A2B5);

class CategoryProductsScreen extends StatefulWidget {
  const CategoryProductsScreen({
    super.key,
    required this.categoryName,
    this.categoryId,
    this.title,
  });

  final String categoryName;
  final int? categoryId;
  final String? title;

  @override
  State<CategoryProductsScreen> createState() => _CategoryProductsScreenState();
}

Map<String, String>? get _imageHeaders => null;

class _CategoryProductsScreenState extends State<CategoryProductsScreen> {
  late Future<List<Product>> _future;

  @override
  void initState() {
    super.initState();
    _future = _fetch();
  }

  Future<List<Product>> _fetch() {
    return ApiService.fetchProducts(
      categoryId: widget.categoryId,
      categoryName: widget.categoryName,
      perPage: 100,
    );
  }

  Future<void> _refresh() async {
    setState(() => _future = _fetch());
    await _future;
  }

  int _columnsForWidth(double width) {
    if (width >= 1100) return 4;
    if (width >= 760) return 3;
    return 2;
  }

  double _aspectForColumns(int columns) {
    if (columns >= 4) return 0.78;
    if (columns == 3) return 0.72;
    return 0.68;
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final title = widget.title ?? widget.categoryName;

    return Theme(
      data: Theme.of(context).copyWith(
        textTheme: GoogleFonts.soraTextTheme(Theme.of(context).textTheme),
      ),
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        appBar: AppBar(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          surfaceTintColor: Colors.transparent,
          elevation: 0,
          centerTitle: false,
          titleSpacing: 16,
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  color: isDark ? _darkTextPrimary : _textPrimary,
                ),
              ),
              Text(
                'Browse and compare products',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: isDark ? _darkTextSecondary : _textSecondary,
                ),
              ),
            ],
          ),
          actions: [
            _CartIconButton(
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const CartScreen()),
                );
              },
            ),
            IconButton(
              tooltip: l.retry,
              onPressed: _refresh,
              icon: const Icon(Icons.refresh_rounded, color: _primary),
            ),
            const SizedBox(width: 6),
          ],
        ),
        body: RefreshIndicator(
          color: _primary,
          onRefresh: _refresh,
          child: FutureBuilder<List<Product>>(
            future: _future,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return LayoutBuilder(
                  builder: (context, constraints) {
                    final columns = _columnsForWidth(constraints.maxWidth);
                    final aspect = _aspectForColumns(columns);
                    final mockProducts = List.generate(
                      8,
                      (index) => Product(
                        id: index,
                        name: 'Loading Product Name',
                        price: 100.0,
                        salePriceOverride: 100.0,
                        stock: 10,
                      ),
                    );
                    return Skeletonizer(
                      enabled: true,
                      child: ListView(
                        physics: const AlwaysScrollableScrollPhysics(
                          parent: BouncingScrollPhysics(),
                        ),
                        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                        children: [
                          _ResultHeader(count: mockProducts.length),
                          const SizedBox(height: 12),
                          GridView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: mockProducts.length,
                            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: columns,
                              crossAxisSpacing: 12,
                              mainAxisSpacing: 12,
                              childAspectRatio: aspect,
                            ),
                            itemBuilder: (context, index) {
                              return _ProductCard(product: mockProducts[index]);
                            },
                          ),
                        ],
                      ),
                    );
                  },
                );
              }

              if (snapshot.hasError) {
                return ListView(
                  physics: const AlwaysScrollableScrollPhysics(
                    parent: BouncingScrollPhysics(),
                  ),
                  padding: const EdgeInsets.fromLTRB(16, 32, 16, 24),
                  children: [
                    _StateCard(
                      icon: Icons.wifi_off_rounded,
                      title: 'Unable to load products',
                      message: 'Check connection and try refreshing again.',
                      actionLabel: l.retry,
                      onTap: _refresh,
                    ),
                  ],
                );
              }

              final products = snapshot.data ?? const <Product>[];
              if (products.isEmpty) {
                return ListView(
                  physics: const AlwaysScrollableScrollPhysics(
                    parent: BouncingScrollPhysics(),
                  ),
                  padding: const EdgeInsets.fromLTRB(16, 32, 16, 24),
                  children: [
                    _StateCard(
                      icon: Icons.inventory_2_outlined,
                      title: 'No products available',
                      message: 'This category does not have products yet.',
                      actionLabel: l.retry,
                      onTap: _refresh,
                    ),
                  ],
                );
              }

              return LayoutBuilder(
                builder: (context, constraints) {
                  final columns = _columnsForWidth(constraints.maxWidth);
                  final aspect = _aspectForColumns(columns);

                  return ListView(
                    physics: const AlwaysScrollableScrollPhysics(
                      parent: BouncingScrollPhysics(),
                    ),
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                    children: [
                      _ResultHeader(count: products.length),
                      const SizedBox(height: 12),
                      GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: products.length,
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: columns,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                          childAspectRatio: aspect,
                        ),
                        itemBuilder: (context, index) {
                          return _ProductCard(product: products[index]);
                        },
                      ),
                    ],
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }
}

class _ResultHeader extends StatelessWidget {
  const _ResultHeader({required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: isDark ? _darkSurface : _surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: isDark ? _darkBorder : _border),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              l.allProducts,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: isDark ? _darkTextPrimary : _textPrimary,
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: isDark
                  ? const Color(0xFF22304A)
                  : const Color(0xFFEAF0FF),
              borderRadius: BorderRadius.circular(999),
            ),
            child: Text(
              '$count items',
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: _primary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ProductCard extends StatefulWidget {
  const _ProductCard({required this.product});

  final Product product;

  @override
  State<_ProductCard> createState() => _ProductCardState();
}

class _ProductCardState extends State<_ProductCard> {
  bool _pressed = false;

  void _setPressed(bool value) {
    if (!mounted) return;
    setState(() => _pressed = value);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final product = widget.product;
    final imageUrl = product.imageUrl;
    final tag = _formatTag(product.tag);
    final brand = product.brand?.trim();
    final hasBrand = brand != null && brand.isNotEmpty;
    final hasRating = product.rating > 0;
    final hasStock = product.stock != null;

    return AnimatedScale(
      scale: _pressed ? 0.97 : 1,
      duration: const Duration(milliseconds: 120),
      curve: Curves.easeOut,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTapDown: (_) => _setPressed(true),
        onTapCancel: () => _setPressed(false),
        onTapUp: (_) => _setPressed(false),
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => ProductDetailScreen(product: product),
            ),
          );
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          curve: Curves.easeOut,
          decoration: BoxDecoration(
            color: _pressed
                ? (isDark ? const Color(0xFF1D2635) : const Color(0xFFF4F7FF))
                : (isDark ? _darkSurface : _surface),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: isDark ? _darkBorder : _border),
            boxShadow: [
              BoxShadow(
                color: isDark ? const Color(0x44000000) : _shadow,
                blurRadius: 14,
                offset: Offset(0, 7),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Stack(
                  children: [
                    Positioned.fill(
                      child: Container(
                        margin: const EdgeInsets.fromLTRB(10, 10, 10, 0),
                        decoration: BoxDecoration(
                          color: isDark ? _darkSurfaceAlt : _surfaceAlt,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(14),
                          child: imageUrl == null || imageUrl.isEmpty
                              ? const _ImageFallback()
                              : Padding(
                                  padding: const EdgeInsets.all(10),
                                  child: Image.network(
                                    imageUrl,
                                    fit: BoxFit.contain,
                                    alignment: Alignment.center,
                                    cacheWidth: 700,
                                    headers: _imageHeaders,
                                    errorBuilder: (_, _, _) =>
                                        const _ImageFallback(),
                                  ),
                                ),
                        ),
                      ),
                    ),
                    if (tag != null)
                      Positioned(
                        left: 14,
                        top: 14,
                        child: _TagChip(text: tag),
                      ),
                    if (hasStock)
                      Positioned(
                        right: 14,
                        top: 14,
                        child: _StockChip(stock: product.stock!),
                      ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 14,
                        height: 1.2,
                        fontWeight: FontWeight.w700,
                        color: isDark ? _darkTextPrimary : _textPrimary,
                      ),
                    ),
                    if (hasBrand) ...[
                      const SizedBox(height: 5),
                      Text(
                        brand,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w600,
                          color: isDark ? _darkTextSecondary : _textSecondary,
                        ),
                      ),
                    ],
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Text(
                          '\$${product.salePrice.toStringAsFixed(2)}',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                            color: product.hasDiscount ? _danger : _primary,
                          ),
                        ),
                        if (product.hasDiscount) ...[
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              '\$${product.price.toStringAsFixed(2)}',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 11.5,
                                fontWeight: FontWeight.w600,
                                color: isDark
                                    ? _darkTextSecondary
                                    : _textSecondary,
                                decoration: TextDecoration.lineThrough,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    if (hasRating) ...[
                      const SizedBox(height: 7),
                      Row(
                        children: [
                          const Icon(
                            Icons.star_rounded,
                            size: 14,
                            color: Color(0xFFF59E0B),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            product.rating.toStringAsFixed(1),
                            style: TextStyle(
                              fontSize: 11.5,
                              fontWeight: FontWeight.w700,
                              color: isDark ? _darkTextPrimary : _textPrimary,
                            ),
                          ),
                          if (product.ratingCount > 0)
                            Text(
                              ' (${product.ratingCount})',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: isDark
                                    ? _darkTextSecondary
                                    : _textSecondary,
                              ),
                            ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TagChip extends StatelessWidget {
  const _TagChip({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF22304A) : const Color(0xFFEAF0FF),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w700,
          color: _primary,
        ),
      ),
    );
  }
}

class _StockChip extends StatelessWidget {
  const _StockChip({required this.stock});

  final int stock;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final inStock = stock > 0;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: inStock
            ? (isDark ? const Color(0xFF173229) : const Color(0xFFEAF8EF))
            : (isDark ? const Color(0xFF3A1F28) : const Color(0xFFFDECEC)),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        inStock ? '$stock left' : l.outOfStock,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w700,
          color: inStock ? _success : _danger,
        ),
      ),
    );
  }
}

class _StateCard extends StatelessWidget {
  const _StateCard({
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
        color: isDark ? _darkSurface : _surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isDark ? _darkBorder : _border),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            size: 38,
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
          const SizedBox(height: 14),
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

class _ImageFallback extends StatelessWidget {
  const _ImageFallback();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      color: isDark ? const Color(0xFF1D2635) : const Color(0xFFF3F4F6),
      child: Center(
        child: Icon(
          Icons.devices_rounded,
          color: isDark ? const Color(0xFF97A2B5) : const Color(0xFF9CA3AF),
        ),
      ),
    );
  }
}



String? _formatTag(String? raw) {
  if (raw == null || raw.trim().isEmpty) return null;
  return raw
      .trim()
      .replaceAll(RegExp(r'[_-]+'), ' ')
      .split(' ')
      .where((word) => word.isNotEmpty)
      .map(
        (word) => '${word[0].toUpperCase()}${word.substring(1).toLowerCase()}',
      )
      .join(' ');
}

class _CartIconButton extends StatelessWidget {
  const _CartIconButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: CartService.instance,
      builder: (context, _) {
        final count = CartService.instance.totalItems;
        final isDark = Theme.of(context).brightness == Brightness.dark;
        final color = isDark ? _darkTextPrimary : _textPrimary;
        return Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.center,
          children: [
            IconButton(
              icon: Icon(Icons.shopping_cart_outlined, color: color),
              onPressed: onTap,
            ),
            if (count > 0)
              Positioned(
                top: 4,
                right: 4,
                child: IgnorePointer(
                  child: Container(
                    constraints: const BoxConstraints(
                      minWidth: 16,
                      minHeight: 16,
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    decoration: BoxDecoration(
                      color: _primary,
                      borderRadius: BorderRadius.circular(999),
                      border: Border.all(
                        color: Theme.of(context).scaffoldBackgroundColor,
                        width: 1.5,
                      ),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      '$count',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 8,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}

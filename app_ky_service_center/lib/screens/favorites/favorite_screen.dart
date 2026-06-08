import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../l10n/app_localizations.dart';
import '../../models/product.dart';
import '../../services/favorite_service.dart';
import '../products/product_detail_screen.dart';

Map<String, String>? get _imageHeaders => null;

const _surface = Color(0xFFFFFFFF);
const _surfaceAlt = Color(0xFFF1F5F9);
const _border = Color(0xFFE2E8F0);
const _textPrimary = Color(0xFF0F172A);
const _textMuted = Color(0xFF64748B);
const _brandBlue = Color(0xFF0F6BFF);
const _success = Color(0xFF0F9D58);
const _danger = Color(0xFFDC2626);
const _shadow = Color(0x140F172A);

final NumberFormat _currencyFormat = NumberFormat.currency(symbol: '\$');

bool _isDark(BuildContext context) =>
    Theme.of(context).brightness == Brightness.dark;

Color _getSurface(BuildContext context) =>
    _isDark(context) ? const Color(0xFF161B22) : _surface;

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

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return AnimatedBuilder(
      animation: FavoriteService.instance,
      builder: (context, _) {
        final items = FavoriteService.instance.items;
        return Scaffold(
          backgroundColor: _isDark(context)
              ? const Color(0xFF0D1117)
              : const Color(0xFFF9FAFD),
          appBar: AppBar(
            title: Text(
              l.favorites,
              style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 20),
            ),
            backgroundColor: Colors.transparent,
            foregroundColor: _getTextPrimary(context),
            elevation: 0,
            actions: [
              if (items.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: IconButton(
                    tooltip: _isGridView ? 'List view' : 'Grid view',
                    onPressed: () => setState(() => _isGridView = !_isGridView),
                    icon: Icon(
                      _isGridView ? Icons.view_list : Icons.grid_view,
                      size: 24,
                    ),
                  ),
                ),
            ],
          ),
          body: items.isEmpty
              ? const _EmptyState()
              : _isGridView
                  ? _buildGridView(context, items)
                  : _buildListView(context, items),
        );
      },
    );
  }

  Widget _buildGridView(BuildContext context, List<Product> items) {
    return GridView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 0.48,
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
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      itemCount: items.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final product = items[index];
        return _ListProductCard(product: product);
      },
    );
  }
}

class _GridProductCard extends StatelessWidget {
  const _GridProductCard({required this.product});

  final Product product;

  @override
  Widget build(BuildContext context) {
    final imageUrl = product.imageUrl;
    final hasDiscount = product.hasDiscount;

    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => ProductDetailScreen(product: product),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: _getSurface(context),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: _getBorder(context),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: _shadow.withOpacity(0.08),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product Image
            Stack(
              children: [
                Container(
                  height: 140,
                  decoration: BoxDecoration(
                    color: _isDark(context)
                        ? const Color(0xFF1D2635)
                        : const Color(0xFFF1F4FA),
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(16),
                      topRight: Radius.circular(16),
                    ),
                  ),
                  child: ClipRRect(
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(16),
                      topRight: Radius.circular(16),
                    ),
                    child: imageUrl == null || imageUrl.isEmpty
                        ? Icon(
                            Icons.image_not_supported,
                            size: 40,
                            color: _getBorder(context),
                          )
                        : Image.network(
                            imageUrl,
                            fit: BoxFit.cover,
                            headers: _imageHeaders,
                            errorBuilder: (context, error, stackTrace) {
                              return Icon(
                                Icons.image_not_supported,
                                size: 40,
                                color: _getBorder(context),
                              );
                            },
                          ),
                  ),
                ),
                // Discount Badge
                if (hasDiscount)
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: _danger,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        'Sale',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                // Favorite Button
                Positioned(
                  bottom: 8,
                  right: 8,
                  child: GestureDetector(
                    onTap: () =>
                        FavoriteService.instance.remove(product),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: _shadow.withOpacity(0.12),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      padding: const EdgeInsets.all(8),
                      child: const Icon(
                        Icons.favorite,
                        color: _danger,
                        size: 18,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            // Product Info
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Brand
                    Text(
                      product.brand ?? 'Unknown',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        color: _getTextMuted(context),
                      ),
                    ),
                    const SizedBox(height: 4),
                    // Product Name
                    Text(
                      product.name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: _getTextPrimary(context),
                      ),
                    ),
                    const Spacer(),
                    // Price
                    if (hasDiscount)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _currencyFormat.format(product.price),
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                              color: _getTextMuted(context),
                              decoration: TextDecoration.lineThrough,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            _currencyFormat.format(product.salePrice),
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: _danger,
                            ),
                          ),
                        ],
                      )
                    else
                      Text(
                        _currencyFormat.format(product.salePrice),
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: _brandBlue,
                        ),
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

class _ListProductCard extends StatelessWidget {
  const _ListProductCard({required this.product});

  final Product product;

  @override
  Widget build(BuildContext context) {
    final imageUrl = product.imageUrl;
    final hasDiscount = product.hasDiscount;

    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => ProductDetailScreen(product: product),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: _getSurface(context),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: _getBorder(context),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: _shadow.withOpacity(0.08),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            // Product Image
            Stack(
              children: [
                Container(
                  height: 100,
                  width: 100,
                  decoration: BoxDecoration(
                    color: _isDark(context)
                        ? const Color(0xFF1D2635)
                        : const Color(0xFFF1F4FA),
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(16),
                      bottomLeft: Radius.circular(16),
                    ),
                  ),
                  child: ClipRRect(
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(16),
                      bottomLeft: Radius.circular(16),
                    ),
                    child: imageUrl == null || imageUrl.isEmpty
                        ? Icon(
                            Icons.image_not_supported,
                            size: 40,
                            color: _getBorder(context),
                          )
                        : Image.network(
                            imageUrl,
                            fit: BoxFit.cover,
                            headers: _imageHeaders,
                            errorBuilder: (context, error, stackTrace) {
                              return Icon(
                                Icons.image_not_supported,
                                size: 40,
                                color: _getBorder(context),
                              );
                            },
                          ),
                  ),
                ),
                // Discount Badge
                if (hasDiscount)
                  Positioned(
                    top: 4,
                    right: 4,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: _danger,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Text(
                        'Sale',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 9,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            // Product Details
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Brand
                    Text(
                      product.brand ?? 'Unknown',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        color: _getTextMuted(context),
                      ),
                    ),
                    const SizedBox(height: 4),
                    // Product Name
                    Text(
                      product.name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: _getTextPrimary(context),
                      ),
                    ),
                    const SizedBox(height: 6),
                    // Price
                    if (hasDiscount)
                      Row(
                        children: [
                          Text(
                            _currencyFormat.format(product.price),
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                              color: _getTextMuted(context),
                              decoration: TextDecoration.lineThrough,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            _currencyFormat.format(product.salePrice),
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: _danger,
                            ),
                          ),
                        ],
                      )
                    else
                      Text(
                        _currencyFormat.format(product.salePrice),
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: _brandBlue,
                        ),
                      ),
                  ],
                ),
              ),
            ),
            // Favorite Button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: GestureDetector(
                onTap: () => FavoriteService.instance.remove(product),
                child: Container(
                  decoration: BoxDecoration(
                    color: _danger.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  padding: const EdgeInsets.all(8),
                  child: const Icon(
                    Icons.favorite,
                    color: _danger,
                    size: 20,
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

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            height: 96,
            width: 96,
            decoration: BoxDecoration(
              color: _isDark(context)
                  ? const Color(0xFF1D2635)
                  : const Color(0xFFF1F4FA),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.favorite_border,
              size: 48,
              color: _getTextMuted(context),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            l.noFavorites,
            style: TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 16,
              color: _getTextPrimary(context),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Add items to your favorites to see them here',
            style: TextStyle(
              fontWeight: FontWeight.w500,
              fontSize: 13,
              color: _getTextMuted(context),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(),
            style: ElevatedButton.styleFrom(
              backgroundColor: _brandBlue,
              foregroundColor: Colors.white,
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              'Continue Shopping',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

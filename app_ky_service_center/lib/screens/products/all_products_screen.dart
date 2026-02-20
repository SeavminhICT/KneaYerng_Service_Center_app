import 'package:flutter/material.dart';
import '../../models/product.dart';
import '../../services/api_service.dart';
import 'product_detail_screen.dart';

class AllProductsScreen extends StatefulWidget {
  const AllProductsScreen({super.key, this.title});

  final String? title;

  @override
  State<AllProductsScreen> createState() => _AllProductsScreenState();
}

class _AllProductsScreenState extends State<AllProductsScreen> {
  late Future<List<Product>> _future;
  bool _isGrid = true;

  @override
  void initState() {
    super.initState();
    _future = _fetch();
  }

  Future<List<Product>> _fetch() {
    return ApiService.fetchProducts();
  }

  Future<void> _refresh() async {
    setState(() => _future = _fetch());
    await _future;
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final isDesktop = width >= 1024;
    final isTablet = width >= 600 && width < 1024;
    final columns = isDesktop ? 4 : (isTablet ? 3 : 2);
    final radius = isDesktop ? 10.0 : 14.0;

    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FB),
      appBar: AppBar(
        title: Text(
          widget.title ?? 'All Products',
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            fontFamily: 'SF Pro Text',
          ),
        ),
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF111827),
        elevation: 0,
      ),
      body: RefreshIndicator(
        color: const Color(0xFF0F6BFF),
        onRefresh: _refresh,
        child: FutureBuilder<List<Product>>(
          future: _future,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return _ErrorState(onRetry: _refresh);
            }
            final products = snapshot.data ?? [];
            if (products.isEmpty) {
              return const _EmptyState();
            }
            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 10),
                  child: Row(
                    children: [
                      Expanded(
                        child: Container(
                          height: 44,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(14),
                            boxShadow: const [
                              BoxShadow(
                                color: Color(0x0F000000),
                                blurRadius: 10,
                                offset: Offset(0, 6),
                              ),
                            ],
                          ),
                          child: const TextField(
                            decoration: InputDecoration(
                              hintText: 'Search products',
                              prefixIcon: Icon(Icons.search, size: 20),
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.symmetric(vertical: 12),
                            ),
                            style: TextStyle(
                              fontSize: 14,
                              fontFamily: 'SF Pro Text',
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      InkWell(
                        borderRadius: BorderRadius.circular(14),
                        onTap: () {
                          setState(() => _isGrid = !_isGrid);
                        },
                        child: Container(
                          height: 44,
                          padding: const EdgeInsets.symmetric(horizontal: 14),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: const Color(0xFFE5E7EB)),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                _isGrid
                                    ? Icons.view_list_rounded
                                    : Icons.grid_view_rounded,
                                size: 18,
                                color: const Color(0xFF111827),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                _isGrid ? 'List' : 'Grid',
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontFamily: 'SF Pro Text',
                                  color: Color(0xFF111827),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 280),
                    switchInCurve: Curves.easeOut,
                    switchOutCurve: Curves.easeIn,
                    child: _isGrid
                        ? GridView.builder(
                            key: const ValueKey('grid'),
                            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                            itemCount: products.length,
                            gridDelegate:
                                SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: columns,
                              crossAxisSpacing: 12,
                              mainAxisSpacing: 12,
                              childAspectRatio: isDesktop ? 0.85 : 0.78,
                            ),
                            itemBuilder: (context, index) {
                              final product = products[index];
                              return _ProductCard(
                                product: product,
                                radius: radius,
                                isGrid: true,
                              );
                            },
                          )
                        : ListView.separated(
                            key: const ValueKey('list'),
                            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                            itemCount: products.length,
                            separatorBuilder: (context, index) =>
                                const SizedBox(height: 12),
                            itemBuilder: (context, index) {
                              final product = products[index];
                              return _ProductCard(
                                product: product,
                                radius: radius,
                                isGrid: false,
                              );
                            },
                          ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _ProductCard extends StatelessWidget {
  const _ProductCard({
    required this.product,
    required this.radius,
    required this.isGrid,
  });

  final Product product;
  final double radius;
  final bool isGrid;

  @override
  Widget build(BuildContext context) {
    final imageUrl = product.imageUrl;
    final rating = _ratingFor(product.id);
    final tag = _tagFor(product.tag);
    return InkWell(
      borderRadius: BorderRadius.circular(radius),
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => ProductDetailScreen(product: product),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(radius),
          boxShadow: const [
            BoxShadow(
              color: Color(0x14000000),
              blurRadius: 12,
              offset: Offset(0, 8),
            ),
          ],
        ),
        child: isGrid
            ? _GridLayout(
                product: product,
                radius: radius,
                imageUrl: imageUrl,
                rating: rating,
                tag: tag,
              )
            : _ListLayout(
                product: product,
                radius: radius,
                imageUrl: imageUrl,
                rating: rating,
                tag: tag,
              ),
      ),
    );
  }
}

class _GridLayout extends StatelessWidget {
  const _GridLayout({
    required this.product,
    required this.radius,
    required this.imageUrl,
    required this.rating,
    required this.tag,
  });

  final Product product;
  final double radius;
  final String? imageUrl;
  final double rating;
  final String? tag;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.vertical(
                  top: Radius.circular(radius),
                ),
                child: Container(
                  color: const Color(0xFFF9F9F9),
                  child: imageUrl == null || imageUrl!.isEmpty
                      ? const _ImageFallback()
                      : Image.network(
                          imageUrl!,
                          fit: BoxFit.contain,
                          cacheWidth: 700,
                          headers: _imageHeaders,
                          errorBuilder: (_, _, _) => const _ImageFallback(),
                          loadingBuilder: (context, child, progress) {
                            if (progress == null) return child;
                            return const _ImageSkeleton();
                          },
                        ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 12, 12, 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF111827),
                      fontFamily: 'SF Pro Text',
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      _PriceTag(value: product.price),
                      if (tag != null) ...[
                        const SizedBox(width: 8),
                        _Badge(
                          label: tag!,
                          background: const Color(0xFFEFF6FF),
                          foreground: const Color(0xFF2563EB),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 8),
                  _RatingRow(value: rating),
                ],
              ),
            ),
          ],
        ),
        Positioned(
          right: 12,
          bottom: 12,
          child: Container(
            height: 38,
            width: 38,
            decoration: const BoxDecoration(
              color: Color(0xFF0F6BFF),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Color(0x330F6BFF),
                  blurRadius: 10,
                  offset: Offset(0, 6),
                ),
              ],
            ),
            child: const Icon(Icons.add, color: Colors.white),
          ),
        ),
      ],
    );
  }
}

class _ListLayout extends StatelessWidget {
  const _ListLayout({
    required this.product,
    required this.radius,
    required this.imageUrl,
    required this.rating,
    required this.tag,
  });

  final Product product;
  final double radius;
  final String? imageUrl;
  final double rating;
  final String? tag;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(radius),
            child: Container(
              width: 96,
              height: 112,
              color: const Color(0xFFF9F9F9),
              child: imageUrl == null || imageUrl!.isEmpty
                  ? const _ImageFallback()
                  : Image.network(
                      imageUrl!,
                      fit: BoxFit.contain,
                      cacheWidth: 500,
                      headers: _imageHeaders,
                      errorBuilder: (_, _, _) => const _ImageFallback(),
                      loadingBuilder: (context, child, progress) {
                        if (progress == null) return child;
                        return const _ImageSkeleton();
                      },
                    ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.name,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                    color: Color(0xFF111827),
                    fontFamily: 'SF Pro Text',
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    _PriceTag(value: product.price),
                    if (tag != null) ...[
                      const SizedBox(width: 8),
                      _Badge(
                        label: tag!,
                        background: const Color(0xFFF1F5F9),
                        foreground: const Color(0xFF0F172A),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 8),
                _RatingRow(value: rating),
                const SizedBox(height: 10),
                SizedBox(
                  height: 36,
                  child: ElevatedButton.icon(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0F6BFF),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      textStyle: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontFamily: 'SF Pro Text',
                      ),
                    ),
                    icon: const Icon(Icons.add, size: 18),
                    label: const Text('Add to Cart'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PriceTag extends StatelessWidget {
  const _PriceTag({required this.value});

  final double value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFEEF2FF),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        '\$${value.toStringAsFixed(0)}',
        style: const TextStyle(
          fontWeight: FontWeight.w700,
          color: Color(0xFF0F6BFF),
          fontFamily: 'SF Pro Text',
        ),
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  const _Badge({
    required this.label,
    required this.background,
    required this.foreground,
  });

  final String label;
  final Color background;
  final Color foreground;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: foreground,
          fontFamily: 'SF Pro Text',
        ),
      ),
    );
  }
}

class _RatingRow extends StatelessWidget {
  const _RatingRow({required this.value});

  final double value;

  @override
  Widget build(BuildContext context) {
    final fullStars = value.floor();
    final hasHalf = (value - fullStars) >= 0.5;
    return Row(
      children: [
        for (var i = 0; i < 5; i++)
          Icon(
            i < fullStars
                ? Icons.star_rounded
                : hasHalf && i == fullStars
                    ? Icons.star_half_rounded
                    : Icons.star_border_rounded,
            size: 16,
            color: const Color(0xFFF59E0B),
          ),
        const SizedBox(width: 6),
        Text(
          value.toStringAsFixed(1),
          style: const TextStyle(
            fontSize: 12,
            color: Color(0xFF6B7280),
            fontFamily: 'SF Pro Text',
          ),
        ),
      ],
    );
  }
}

double _ratingFor(int id) {
  final seed = (id % 8) + 2;
  return 3.6 + (seed / 10);
}

String? _tagFor(String? raw) {
  if (raw == null || raw.isEmpty) return null;
  return raw.replaceAll('_', ' ').toUpperCase();
}

Map<String, String>? get _imageHeaders => null;

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text(
        'No products yet.',
        style: TextStyle(fontWeight: FontWeight.w600),
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.onRetry});

  final Future<void> Function() onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.wifi_off_outlined, size: 44),
          const SizedBox(height: 12),
          const Text(
            'Unable to load products.',
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          TextButton(
            onPressed: onRetry,
            child: const Text('Try again'),
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
    return Container(
      color: const Color(0xFFF9F9F9),
      child: const Center(
        child: Icon(Icons.devices, color: Color(0xFF9CA3AF)),
      ),
    );
  }
}

class _ImageSkeleton extends StatelessWidget {
  const _ImageSkeleton();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFF1F5F9),
      child: const Center(
        child: SizedBox(
          height: 22,
          width: 22,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      ),
    );
  }
}



import 'dart:async';
import 'package:flutter/material.dart';
import '../../models/banner_item.dart';
import '../../models/category.dart';
import '../../models/product.dart';
import '../../services/api_service.dart';
import '../../services/cart_service.dart';
import '../cart/cart_screen.dart';
import '../categories/category_products_screen.dart';
import '../products/all_products_screen.dart';
import '../products/product_detail_screen.dart';

Map<String, String>? get _imageHeaders => null;

const _homeBg = Color(0xFFF6F7FB);
const _cardBorder = Color(0xFFE7E9EE);
const _primary = Color(0xFFF47B20);
const _textPrimary = Color(0xFF1A1B1E);
const _textMuted = Color(0xFF7C8190);

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final PageController _bannerController = PageController();
  final TextEditingController _searchController = TextEditingController();

  Timer? _bannerTimer;
  int _bannerIndex = 0;
  int _countdownSeconds = 12 * 3600 + 26 * 60 + 27;
  Timer? _countdownTimer;

  bool _isLoadingBanner = false;
  List<BannerItem> _banners = [];
  late Future<List<Category>> _categoriesFuture;
  late Future<List<Product>> _productsFuture;
  @override
  void initState() {
    super.initState();
    _categoriesFuture = ApiService.fetchCategories();
    _productsFuture = ApiService.fetchProducts();
    _loadBanners();
    _startCountdown();
  }

  @override
  void dispose() {
    _bannerTimer?.cancel();
    _countdownTimer?.cancel();
    _bannerController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _refresh() async {
    _loadBanners();
    setState(() {
      _categoriesFuture = ApiService.fetchCategories();
      _productsFuture = ApiService.fetchProducts();
    });
    await Future.wait([_categoriesFuture, _productsFuture]);
  }

  void _startCountdown() {
    _countdownTimer?.cancel();
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      setState(() {
        _countdownSeconds = (_countdownSeconds - 1) % (24 * 3600);
      });
    });
  }

  Future<void> _loadBanners() async {
    setState(() => _isLoadingBanner = true);
    try {
      final loaded = await ApiService.fetchBanners();
      if (!mounted) return;
      setState(() {
        _banners = loaded;
        _isLoadingBanner = false;
        _bannerIndex = 0;
      });
      if (_bannerController.hasClients) {
        _bannerController.jumpToPage(0);
      }
      _startBannerAutoSlide();
    } catch (_) {
      if (!mounted) return;
      setState(() => _isLoadingBanner = false);
    }
  }

  void _startBannerAutoSlide() {
    _bannerTimer?.cancel();
    if (_banners.length <= 1) return;
    _bannerTimer = Timer.periodic(const Duration(seconds: 4), (_) {
      if (!_bannerController.hasClients || _banners.isEmpty) return;
      final next = (_bannerIndex + 1) % _banners.length;
      _bannerController.animateToPage(
        next,
        duration: const Duration(milliseconds: 360),
        curve: Curves.easeOutCubic,
      );
    });
  }

  String _initialsFor(String text) {
    final parts = text.trim().split(RegExp(r'\s+')).where((e) => e.isNotEmpty);
    if (parts.isEmpty) return 'K';
    if (parts.length == 1) return parts.first.substring(0, 1).toUpperCase();
    return (parts.first.substring(0, 1) + parts.last.substring(0, 1))
        .toUpperCase();
  }

  IconData _iconForCategory(String name) {
    final value = name.toLowerCase();
    if (value.contains('phone') || value.contains('iphone')) {
      return Icons.phone_iphone_rounded;
    }
    if (value.contains('mac') || value.contains('laptop')) {
      return Icons.laptop_mac_rounded;
    }
    if (value.contains('audio') || value.contains('headphone')) {
      return Icons.headphones_rounded;
    }
    if (value.contains('repair') || value.contains('service')) {
      return Icons.build_circle_rounded;
    }
    if (value.contains('access')) {
      return Icons.watch_outlined;
    }
    return Icons.category_rounded;
  }

  void _addToCart(Product product) {
    CartService.instance.add(product);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${product.name} added to cart'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: CartService.instance,
      builder: (context, _) {
        final cartCount = CartService.instance.totalItems;
        return Scaffold(
          backgroundColor: _homeBg,
          body: SafeArea(
            child: RefreshIndicator(
              onRefresh: _refresh,
              child: ListView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(16, 10, 16, 24),
                children: [
                  _HomeHeader(
                    logoAsset: 'assets/images/Logo_KYSC.png',
                    title: 'KneaYerng APP',
                    cartCount: cartCount,
                    onCartTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const CartScreen()),
                      );
                    },
                  ),
                  const SizedBox(height: 14),
                  _SearchInput(
                    controller: _searchController,
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const AllProductsScreen(),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 14),
                  _BannerArea(
                    loading: _isLoadingBanner,
                    items: _banners,
                    controller: _bannerController,
                    activeIndex: _bannerIndex,
                    onPageChanged: (index) {
                      setState(() => _bannerIndex = index);
                    },
                  ),
                  const SizedBox(height: 16),
                  FutureBuilder<List<Category>>(
                    future: _categoriesFuture,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const _CategorySkeleton();
                      }
                      final categories = (snapshot.data ?? []).take(10).toList();
                      if (categories.isEmpty) {
                        return const SizedBox.shrink();
                      }
                      return _CategoryRow(
                        categories: categories,
                        iconFor: _iconForCategory,
                      );
                    },
                  ),
                  const SizedBox(height: 18),
                  _FlashSaleHeader(
                    countdown: _formatCountdown(_countdownSeconds),
                    onSeeAll: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const AllProductsScreen(
                            title: 'Flash Sale',
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 12),
                  FutureBuilder<List<Product>>(
                    future: _productsFuture,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const _ProductsSkeleton();
                      }
                      if (snapshot.hasError) {
                        return const _SimpleState(
                          icon: Icons.wifi_off_rounded,
                          title: 'Unable to load products',
                        );
                      }
                      final products = (snapshot.data ?? []).take(8).toList();
                      if (products.isEmpty) {
                        return const _SimpleState(
                          icon: Icons.inventory_2_outlined,
                          title: 'No products available',
                        );
                      }
                      return GridView.builder(
                        itemCount: products.length,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          mainAxisSpacing: 12,
                          crossAxisSpacing: 12,
                          childAspectRatio: 0.56,
                        ),
                        itemBuilder: (context, index) {
                          final product = products[index];
                          return _FlashProductCard(
                            product: product,
                            onOpen: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) =>
                                      ProductDetailScreen(product: product),
                                ),
                              );
                            },
                            onAdd: () => _addToCart(product),
                          );
                        },
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

String _formatCountdown(int seconds) {
  final h = (seconds ~/ 3600).toString().padLeft(2, '0');
  final m = ((seconds % 3600) ~/ 60).toString().padLeft(2, '0');
  final s = (seconds % 60).toString().padLeft(2, '0');
  return '$h:$m:$s';
}

class _HomeHeader extends StatelessWidget {
  const _HomeHeader({
    required this.logoAsset,
    required this.title,
    required this.cartCount,
    required this.onCartTap,
  });

  final String logoAsset;
  final String title;
  final int cartCount;
  final VoidCallback onCartTap;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: _cardBorder),
          ),
          child: Image.asset(
            logoAsset,
            fit: BoxFit.contain,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: _textPrimary,
                ),
              ),
              const SizedBox(height: 2),
              const Text(
                'Welcome back',
                style: TextStyle(fontSize: 11, color: _textMuted),
              ),
            ],
          ),
        ),
        _IconCircleButton(
          icon: Icons.notifications_none_rounded,
          onTap: () {},
        ),
        const SizedBox(width: 8),
        _CartIconButton(
          count: cartCount,
          onTap: onCartTap,
        ),
      ],
    );
  }
}

class _SearchInput extends StatelessWidget {
  const _SearchInput({
    required this.controller,
    required this.onTap,
  });

  final TextEditingController controller;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: onTap,
      child: IgnorePointer(
        child: TextField(
          controller: controller,
          decoration: InputDecoration(
            hintText: 'Find your needs...',
            hintStyle: const TextStyle(color: _textMuted),
            prefixIcon:
                const Icon(Icons.search_rounded, color: Color(0xFFA0A5B2)),
            suffixIcon:
                const Icon(Icons.tune_rounded, color: Color(0xFFA0A5B2)),
            filled: true,
            fillColor: Colors.white,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: _cardBorder),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: _cardBorder),
            ),
          ),
        ),
      ),
    );
  }
}

class _BannerArea extends StatelessWidget {
  const _BannerArea({
    required this.loading,
    required this.items,
    required this.controller,
    required this.activeIndex,
    required this.onPageChanged,
  });

  final bool loading;
  final List<BannerItem> items;
  final PageController controller;
  final int activeIndex;
  final ValueChanged<int> onPageChanged;

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return Container(
        height: 550,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
        ),
        child: const Center(child: CircularProgressIndicator()),
      );
    }

    if (items.isEmpty) {
      return const _LocalBannerCard(
        title: 'ONLINE SHOPPING',
        subtitle: 'Explore latest products and best prices.',
      );
    }

    return Column(
      children: [
        SizedBox(
          height: 200,
          child: PageView.builder(
            controller: controller,
            itemCount: items.length,
            onPageChanged: onPageChanged,
            itemBuilder: (context, index) {
              final item = items[index];
              return _NetworkBannerCard(item: item);
            },
          ),
        ),
        if (items.length > 1) ...[
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              items.length,
              (index) => AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                margin: const EdgeInsets.symmetric(horizontal: 3),
                height: 6,
                width: index == activeIndex ? 16 : 6,
                decoration: BoxDecoration(
                  color: index == activeIndex
                      ? const Color(0xFFDF6421)
                      : const Color(0xFFD1D5DB),
                  borderRadius: BorderRadius.circular(99),
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }
}

class _CategoryRow extends StatelessWidget {
  const _CategoryRow({
    required this.categories,
    required this.iconFor,
  });

  final List<Category> categories;
  final IconData Function(String) iconFor;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      
      height: 86,
      child: ListView.separated(
        //set title 

      
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        separatorBuilder: (context, index) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          final category = categories[index];
          return InkWell(
            borderRadius: BorderRadius.circular(14),
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => CategoryProductsScreen(
                    categoryName: category.name,
                    title: category.name,
                  ),
                ),
              );
            },
            child: SizedBox(
              width: 62,
              child: Column(
                children: [
                  Container(
                    height: 50,
                    width: 50,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: _cardBorder),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(13),
                      child: (category.imageUrl != null &&
                              category.imageUrl!.trim().isNotEmpty)
                          ? Image.network(
                              category.imageUrl!,
                              fit: BoxFit.cover,
                              headers: _imageHeaders,
                              errorBuilder: (context, error, stackTrace) {
                                return Icon(iconFor(category.name),
                                    color: _primary);
                              },
                            )
                          : Icon(iconFor(category.name), color: _primary),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    category.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 11,
                      color: _textPrimary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _FlashSaleHeader extends StatelessWidget {
  const _FlashSaleHeader({
    required this.countdown,
    required this.onSeeAll,
  });

  final String countdown;
  final VoidCallback onSeeAll;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Text(
          'Flash Sale',
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w700,
            color: _textPrimary,
          ),
        ),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: const Color(0xFF101323),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            countdown,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        const Spacer(),
        TextButton(
          onPressed: onSeeAll,
          style: TextButton.styleFrom(
            foregroundColor: _primary,
            padding: EdgeInsets.zero,
            minimumSize: const Size(20, 20),
          ),
          child: const Text(
            'See all',
            style: TextStyle(fontWeight: FontWeight.w700),
          ),
        ),
      ],
    );
  }
}

class _FlashProductCard extends StatelessWidget {
  const _FlashProductCard({
    required this.product,
    required this.onOpen,
    required this.onAdd,
  });

  final Product product;
  final VoidCallback onOpen;
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    final imageUrl = product.imageUrl;
    final tag = _formatTag(product.tag);
    final oldPrice = product.discount != null && product.discount! > 0
        ? product.price + product.discount!
        : null;
    final badge = product.discount != null && product.discount! > 0
        ? '-${(product.discount! / (product.price + 1) * 100).round()}%'
        : '-5%';

    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onOpen,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: _cardBorder),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(16),
                  ),
                  child: Container(
                    height: 130,
                    width: double.infinity,
                    color: const Color(0xFFF9FAFC),
                    child: imageUrl == null || imageUrl.isEmpty
                        ? const Icon(Icons.image_not_supported_outlined,
                            color: _textMuted)
                        : Padding(
                            padding: const EdgeInsets.all(8),
                            child: Center(
                              child: Image.network(
                                imageUrl,
                                fit: BoxFit.contain,
                                alignment: Alignment.center,
                                cacheWidth: 800,
                                headers: _imageHeaders,
                                errorBuilder: (context, error, stackTrace) =>
                                    const Icon(
                                  Icons.broken_image_outlined,
                                  color: _textMuted,
                                ),
                              ),
                            ),
                          ),
                  ),
                ),
                Positioned(
                  top: 8,
                  left: 8,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 7, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFE8DE),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      badge,
                      style: const TextStyle(
                        color: _primary,
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (tag != null) ...[
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 7,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFEFF6FF),
                          borderRadius: BorderRadius.circular(7),
                        ),
                        child: Text(
                          tag,
                          style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF2563EB),
                          ),
                        ),
                      ),
                      const SizedBox(height: 6),
                    ],
                    Text(
                      product.name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 12,
                        height: 1.25,
                        fontWeight: FontWeight.w600,
                        color: _textPrimary,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '\$${product.price.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        color: Color(0xFFDB520F),
                      ),
                    ),
                    if (oldPrice != null)
                      Text(
                        '\$${oldPrice.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontSize: 11,
                          color: _textMuted,
                          decoration: TextDecoration.lineThrough,
                        ),
                      ),
                    const Spacer(),
                    SizedBox(
                      width: double.infinity,
                      height: 32,
                      child: ElevatedButton(
                        onPressed: onAdd,
                        style: ElevatedButton.styleFrom(
                          elevation: 0,
                          backgroundColor: const Color(0xFFFFEEE4),
                          foregroundColor: _primary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(9),
                          ),
                          padding: EdgeInsets.zero,
                        ),
                        child: const Text(
                          'Add to Cart',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
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

String? _formatTag(String? raw) {
  final trimmed = raw?.trim();
  if (trimmed == null || trimmed.isEmpty) return null;
  return trimmed
      .replaceAll(RegExp(r'[_-]+'), ' ')
      .split(' ')
      .where((word) => word.isNotEmpty)
      .map((word) => '${word[0].toUpperCase()}${word.substring(1).toLowerCase()}')
      .join(' ');
}

class _SimpleState extends StatelessWidget {
  const _SimpleState({required this.icon, required this.title});

  final IconData icon;
  final String title;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _cardBorder),
      ),
      child: Column(
        children: [
          Icon(icon, color: _textMuted),
          const SizedBox(height: 8),
          Text(
            title,
            style: const TextStyle(color: _textMuted),
          ),
        ],
      ),
    );
  }
}

class _CategorySkeleton extends StatelessWidget {
  const _CategorySkeleton();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 84,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: 5,
        separatorBuilder: (context, index) => const SizedBox(width: 10),
        itemBuilder: (context, index) {
          return Column(
            children: [
              Container(
                height: 48,
                width: 48,
                decoration: BoxDecoration(
                  color: const Color(0xFFEDEFF4),
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              const SizedBox(height: 8),
              Container(
                width: 50,
                height: 8,
                color: const Color(0xFFEDEFF4),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _ProductsSkeleton extends StatelessWidget {
  const _ProductsSkeleton();

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      itemCount: 4,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 0.56,
      ),
      itemBuilder: (context, index) {
        return Container(
          decoration: BoxDecoration(
            color: const Color(0xFFEDEFF4),
            borderRadius: BorderRadius.circular(16),
          ),
        );
      },
    );
  }
}

class _IconCircleButton extends StatelessWidget {
  const _IconCircleButton({
    required this.icon,
    required this.onTap,
  });

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: onTap,
      child: Container(
        height: 38,
        width: 38,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: _cardBorder),
        ),
        child: Icon(icon, size: 20, color: _textPrimary),
      ),
    );
  }
}

class _CartIconButton extends StatelessWidget {
  const _CartIconButton({
    required this.count,
    required this.onTap,
  });

  final int count;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        _IconCircleButton(
          icon: Icons.shopping_bag_outlined,
          onTap: onTap,
        ),
        if (count > 0)
          Positioned(
            right: -2,
            top: -4,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
              decoration: BoxDecoration(
                color: const Color(0xFFE11D48),
                borderRadius: BorderRadius.circular(9),
              ),
              child: Text(
                '$count',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class _NetworkBannerCard extends StatelessWidget {
  const _NetworkBannerCard({required this.item});

  final BannerItem item;

  @override
  Widget build(BuildContext context) {
    final image = item.imageUrl;
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        gradient: const LinearGradient(
          colors: [Color(0xFFFFA766), Color(0xFFFF7A3C)],
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: Stack(
          fit: StackFit.expand,
          children: [
            if (image != null && image.isNotEmpty)
              Image.network(
                image,
                fit: BoxFit.cover,
                headers: _imageHeaders,
                errorBuilder: (context, error, stackTrace) => const SizedBox.shrink(),
              ),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  colors: [
                    Colors.black.withValues(alpha: 0.48),
                    Colors.black.withValues(alpha: 0.08),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    (item.title?.trim().isNotEmpty ?? false)
                        ? item.title!.trim()
                        : 'ONLINE SHOPPING',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                      fontSize: 18,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    (item.subtitle?.trim().isNotEmpty ?? false)
                        ? item.subtitle!.trim()
                        : 'Explore top products and best deals.',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                    ),
                  ),
                  const Spacer(),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(9),
                    ),
                    child: const Text(
                      'Explore now',
                      style: TextStyle(
                        color: _primary,
                        fontWeight: FontWeight.w700,
                        fontSize: 11,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LocalBannerCard extends StatelessWidget {
  const _LocalBannerCard({
    required this.title,
    required this.subtitle,
  });

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 150,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFFFA766), Color(0xFFFF7A3C)],
        ),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 6),
          SizedBox(
            width: 190,
            child: Text(
              subtitle,
              style: const TextStyle(color: Colors.white, fontSize: 12),
            ),
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(9),
            ),
            child: const Text(
              'Explore now',
              style: TextStyle(
                color: _primary,
                fontWeight: FontWeight.w700,
                fontSize: 11,
              ),
            ),
          ),
        ],
      ),
    );
  }
}



import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../services/api_service.dart';
import '../../models/banner_item.dart';
import '../../models/product.dart';
import '../../services/cart_service.dart';
import '../categories/categories_screen.dart';
import '../categories/category_products_screen.dart';
import '../favorites/favorite_screen.dart';
import '../notifications/notification_screen.dart';
import '../products/all_products_screen.dart';
import '../products/product_detail_screen.dart';
import '../cart/cart_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  static const _primary = Color(0xFF0F6BFF);
  static const _secondary = Color(0xFF12B886);
  static const _accent = Color(0xFFFF8A00);
  static const _canvas = Color(0xFFF6F7FB);
  static const _surface = Color(0xFFFFFFFF);
  static const _textPrimary = Color(0xFF12141A);
  static const _textMuted = Color(0xFF6B7280);
  static const _border = Color(0xFFE6E9F0);
  static const _shadow = Color(0x14000000);

  final _heroController = PageController();
  final _searchFocus = FocusNode();
  final _searchCtrl = TextEditingController();

  Timer? _heroTimer;
  int _heroIndex = 0;
  bool _headerVisible = false;
  bool _searchFocused = false;
  int _cartPulse = 0;
  bool _loadingBanners = false;
  String? _bannerError;
  List<BannerItem> _banners = [];
  late Future<List<Product>> _newArrivalsFuture;

  final _heroItems = const [
    _HeroItem(
      title: 'Same-day device repair',
      subtitle: 'Certified technicians, transparent pricing',
      image:
          'https://images.unsplash.com/photo-1489515217757-5fd1be406fef?auto=format&fit=crop&w=1400&q=80',
    ),
    _HeroItem(
      title: 'Diagnostics in minutes',
      subtitle: 'Free checkups for phones and laptops',
      image:
          'https://images.unsplash.com/photo-1518770660439-4636190af475?auto=format&fit=crop&w=1400&q=80',
    ),
    _HeroItem(
      title: 'KNEA YERNG Service Center',
      subtitle: 'Premium care for every device',
      image:
          'https://images.unsplash.com/photo-1484704849700-f032a568e944?auto=format&fit=crop&w=1400&q=80',
    ),
  ];

  List<_HeroItem> get _activeHeroItems {
    if (_banners.isEmpty) return _heroItems;
    final items = _banners
        .where((banner) => (banner.imageUrl ?? '').isNotEmpty)
        .map(
          (banner) => _HeroItem(
            title: (banner.title ?? '').trim(),
            subtitle: (banner.subtitle ?? '').trim(),
            image: banner.imageUrl!,
          ),
        )
        .toList();
    return items.isEmpty ? _heroItems : items;
  }

  final _quickActions = const [
    _QuickActionItem(
      label: 'Repair',
      icon: Icons.build_circle,
      color: _primary,
    ),
    _QuickActionItem(
      label: 'My Order',
      icon: Icons.local_shipping_outlined,
      color: _secondary,
    ),
    _QuickActionItem(
      label: 'Support',
      icon: Icons.chat_bubble_outline,
      color: _accent,
    ),
    _QuickActionItem(
      label: 'Warranty',
      icon: Icons.verified_outlined,
      color: Color(0xFF7C3AED),
    ),
  ];

  List<_CategoryItem> _buildCategories(BuildContext context) {
    return [
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
  }

  final _newArrivals = const [
    _ProductItem(
      name: 'Pixel Sphere X',
      price: 799,
      image:
          'https://images.unsplash.com/photo-1517336714731-489689fd1ca8?auto=format&fit=crop&w=900&q=80',
    ),
    _ProductItem(
      name: 'AeroBook 14',
      price: 1099,
      image:
          'https://images.unsplash.com/photo-1496181133206-80ce9b88a853?auto=format&fit=crop&w=900&q=80',
    ),
    _ProductItem(
      name: 'Orbit Buds',
      price: 159,
      image:
          'https://images.unsplash.com/photo-1505740420928-5e560c06d30e?auto=format&fit=crop&w=900&q=80',
    ),
    _ProductItem(
      name: 'FusePad 10',
      price: 499,
      image:
          'https://images.unsplash.com/photo-1511707171634-5f897ff02aa9?auto=format&fit=crop&w=900&q=80',
    ),
  ];

  late Future<List<Product>> _flashSaleFuture;

  final _featured = const [
    _ProductItem(
      name: 'Nova Pro Max',
      price: 1299,
      image:
          'https://images.unsplash.com/photo-1511707171634-5f897ff02aa9?auto=format&fit=crop&w=900&q=80',
    ),
    _ProductItem(
      name: 'CoreBook Studio',
      price: 1899,
      image:
          'https://images.unsplash.com/photo-1496181133206-80ce9b88a853?auto=format&fit=crop&w=900&q=80',
    ),
    _ProductItem(
      name: 'Vibe Earset',
      price: 219,
      image:
          'https://images.unsplash.com/photo-1505740420928-5e560c06d30e?auto=format&fit=crop&w=900&q=80',
    ),
    _ProductItem(
      name: 'Touch Panel 7',
      price: 299,
      image:
          'https://images.unsplash.com/photo-1510557880182-3c5d92f3f1f0?auto=format&fit=crop&w=900&q=80',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _searchFocus.addListener(_handleSearchFocus);
    _loadBanners();
    _newArrivalsFuture = ApiService.fetchProducts(status: 'active');
    _flashSaleFuture = ApiService.fetchProducts(status: 'active');
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      setState(() => _headerVisible = true);
      _startHeroAutoPlay();
    });
  }

  @override
  void dispose() {
    _heroTimer?.cancel();
    _heroController.dispose();
    _searchFocus.removeListener(_handleSearchFocus);
    _searchFocus.dispose();
    _searchCtrl.dispose();
    super.dispose();
  }

  void _handleSearchFocus() {
    if (!mounted) return;
    setState(() => _searchFocused = _searchFocus.hasFocus);
  }

  void _startHeroAutoPlay() {
    final reduceMotion = _reduceMotion(context);
    if (reduceMotion) return;
    _heroTimer?.cancel();
    _heroTimer = Timer.periodic(const Duration(seconds: 5), (_) {
      if (!_heroController.hasClients) return;
      final length = _activeHeroItems.length;
      if (length <= 1) return;
      final next = (_heroIndex + 1) % length;
      _heroController.animateToPage(
        next,
        duration: const Duration(milliseconds: 520),
        curve: Curves.easeOutCubic,
      );
    });
  }

  Future<void> _loadBanners() async {
    setState(() {
      _loadingBanners = true;
      _bannerError = null;
    });
    try {
      final banners = await ApiService.fetchBanners();
      if (!mounted) return;
      debugPrint('[HomeScreen] banners loaded: ${banners.length}');
      setState(() {
        _banners = banners;
        _heroIndex = 0;
        _loadingBanners = false;
      });
      if (_heroController.hasClients) {
        _heroController.jumpToPage(0);
      }
      _startHeroAutoPlay();
    } catch (e) {
      debugPrint('[HomeScreen] banner load error: $e');
      if (!mounted) return;
      setState(() {
        _bannerError = e.toString();
        _loadingBanners = false;
      });
    }
  }

  Future<void> _handleRefresh() async {
    await _loadBanners();
    setState(() {
      _newArrivalsFuture = ApiService.fetchProducts(status: 'active');
      _flashSaleFuture = ApiService.fetchProducts(status: 'active');
    });
    await Future<void>.delayed(const Duration(milliseconds: 700));
    if (!mounted) return;
    setState(() {
      _cartPulse = 0;
    });
  }

  void _bumpCart() {
    setState(() => _cartPulse++);
  }

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    final width = media.size.width;
    final isDesktop = width >= 1024;
    final isTablet = width >= 600 && width < 1024;
    final reduceMotion = _reduceMotion(context);
    final radius = isDesktop ? 12.0 : 16.0;

    return Scaffold(
      backgroundColor: _canvas,
      body: RefreshIndicator(
        color: _primary,
        onRefresh: _handleRefresh,
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            SliverAppBar(
              pinned: true,
              automaticallyImplyLeading: false,
              backgroundColor: _canvas,
              surfaceTintColor: _canvas,
              elevation: 0,
              toolbarHeight: isDesktop ? 86 : 64,
              title: AnimatedSlide(
                offset: _headerVisible
                    ? Offset.zero
                    : const Offset(0, -0.15),
                duration: Duration(milliseconds: reduceMotion ? 1 : 420),
                curve: Curves.easeOutCubic,
                child: AnimatedOpacity(
                  opacity: _headerVisible ? 1 : 0,
                  duration: Duration(milliseconds: reduceMotion ? 1 : 420),
                  child: _HeaderTitle(isDesktop: isDesktop),
                ),
              ),
              actions: [
                _HeaderIconButton(
                  tooltip: 'Notifications',
                  icon: Icons.notifications_outlined,
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const NotificationScreen(),
                      ),
                    );
                  },
                ),
                const SizedBox(width: 6),
                _HeaderIconButton(
                  tooltip: 'Favorites',
                  icon: Icons.favorite_border,
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const FavoriteScreen(),
                      ),
                    );
                  },
                ),
                const SizedBox(width: 12),
              ],
              bottom: PreferredSize(
                preferredSize: Size.fromHeight(isDesktop ? 60 : 52),
                child: Padding(
                  padding: EdgeInsets.fromLTRB(16, 0, 16, isDesktop ? 12 : 8),
                  child: _SearchBar(
                    controller: _searchCtrl,
                    focusNode: _searchFocus,
                    isDesktop: isDesktop,
                    isTablet: isTablet,
                    focused: _searchFocused,
                    radius: radius,
                  ),
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                child: _loadingBanners && _banners.isEmpty
                    ? _BannerPlaceholder(radius: radius + 8)
                    : _HeroCarousel(
                        controller: _heroController,
                        items: _activeHeroItems,
                        index: _heroIndex,
                        onIndexChanged: (value) => setState(() {
                          _heroIndex = value;
                        }),
                        reduceMotion: reduceMotion,
                        radius: radius + 8,
                      ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
                child: _QuickActions(
                  actions: _quickActions,
                  radius: radius,
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
                child: _ServiceStatus(
                  radius: radius,
                  isDesktop: isDesktop,
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 24, 16, 0),
                child: _SectionHeader(
                  title: 'Categories',
                  action: 'See all',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const CategoriesScreen(),
                      ),
                    );
                  },
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                child: _CategorySection(
                  categories: _buildCategories(context),
                  isDesktop: isDesktop,
                  isTablet: isTablet,
                  radius: radius,
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 24, 16, 0),
                child: _SectionHeader(
                  title: 'New Arrivals',
                  action: 'View all',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const AllProductsScreen(
                          title: 'New Arrivals',
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                child: FutureBuilder<List<Product>>(
                  future: _newArrivalsFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState != ConnectionState.done) {
                      return const SizedBox(
                        height: 200,
                        child: Center(child: CircularProgressIndicator()),
                      );
                    }
                    if (snapshot.hasError) {
                      return _EmptyState(
                        title: 'Unable to load products',
                        subtitle: 'Pull to refresh to try again.',
                      );
                    }
                    final products = (snapshot.data ?? []).take(4).toList();
                    if (products.isEmpty) {
                      return _EmptyState(
                        title: 'No new arrivals yet',
                        subtitle: 'Check back soon for updates.',
                      );
                    }
                    return _ProductGridApi(
                      products: products,
                      columns: _gridCountForWidth(width, 2, 3, 4),
                      radius: radius,
                    );
                  },
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 24, 16, 0),
                child: _SectionHeader(
                  title: 'Flash Sale',
                  action: 'Ends soon',
                  onTap: () {},
                  trailing: const _CountdownBadge(),
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                child: FutureBuilder<List<Product>>(
                  future: _flashSaleFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState != ConnectionState.done) {
                      return const SizedBox(
                        height: 200,
                        child: Center(child: CircularProgressIndicator()),
                      );
                    }
                    if (snapshot.hasError) {
                      return _EmptyState(
                        title: 'Unable to load flash sale',
                        subtitle: 'Pull to refresh to try again.',
                      );
                    }
                    final products = (snapshot.data ?? []).take(3).toList();
                    if (products.isEmpty) {
                      return _EmptyState(
                        title: 'No flash sale items',
                        subtitle: 'Check back soon for deals.',
                      );
                    }
                    return _FlashSaleSectionApi(
                      products: products,
                      columns: _gridCountForWidth(width, 2, 3, 4),
                      radius: radius,
                      onCartAdded: _bumpCart,
                    );
                  },
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 24, 16, 0),
                child: _SectionHeader(
                  title: 'Featured Products',
                  action: 'Explore',
                  onTap: () {},
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                child: _FeaturedSection(
                  products: _featured,
                  columns: _gridCountForWidth(width, 1, 2, 3),
                  radius: radius,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  bool _reduceMotion(BuildContext context) {
    final media = MediaQuery.of(context);
    return media.disableAnimations || media.accessibleNavigation;
  }

  int _gridCountForWidth(double width, int mobile, int tablet, int desktop) {
    if (width >= 1024) return desktop;
    if (width >= 600) return tablet;
    return mobile;
  }
}

class _HeaderTitle extends StatelessWidget {
  const _HeaderTitle({required this.isDesktop});

  final bool isDesktop;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          height: 46,
          width: 46,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0xFFE6E9F0)),
            boxShadow: const [
              BoxShadow(
                color: Color(0x12000000),
                blurRadius: 8,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.all(4),
              child: Image.asset(
                'assets/images/Logo_KYSC.png',
                fit: BoxFit.contain,
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'KNEA YERNG Service Center',
                style: TextStyle(
                  fontSize: isDesktop ? 20 : 18,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF12141A),
                  fontFamily: 'Manrope',
                  fontFamilyFallback: const [
                    'Inter',
                    'SF Pro Display',
                    'Arial',
                  ],
                ),
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEEF4FF),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: const [
                        Icon(Icons.location_on_outlined,
                            size: 12, color: Color(0xFF4B5563)),
                        SizedBox(width: 4),
                        Text(
                          'Phnom Penh',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF4B5563),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _HeaderIconButton extends StatelessWidget {
  const _HeaderIconButton({
    required this.tooltip,
    required this.icon,
    required this.onPressed,
  });

  final String tooltip;
  final IconData icon;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: InkResponse(
        radius: 26,
        onTap: onPressed,
        child: Container(
          height: 38,
          width: 38,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFE6E9F0)),
            boxShadow: const [
              BoxShadow(
                color: Color(0x12000000),
                blurRadius: 8,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: Icon(icon, color: const Color(0xFF111827), size: 20),
        ),
      ),
    );
  }
}

class _BannerStatusCard extends StatelessWidget {
  const _BannerStatusCard({
    required this.loading,
    required this.error,
    required this.onRetry,
    required this.radius,
  });

  final bool loading;
  final String? error;
  final VoidCallback onRetry;
  final double radius;

  @override
  Widget build(BuildContext context) {
    final hasError = error != null && error!.isNotEmpty;
    final title = hasError ? 'Banner API error' : 'Loading banners...';
    final message = hasError
        ? error!
        : 'Fetching latest banners for the carousel';
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(color: const Color(0xFFE6E9F0)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0F000000),
            blurRadius: 10,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            height: 36,
            width: 36,
            decoration: BoxDecoration(
              color: hasError
                  ? const Color(0xFFFFF3E0)
                  : const Color(0xFFEFF6FF),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              hasError ? Icons.warning_amber_rounded : Icons.cloud_download,
              color: hasError ? const Color(0xFFE8590C) : const Color(0xFF0F6BFF),
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF111827),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  message,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 11,
                    color: Color(0xFF6B7280),
                  ),
                ),
              ],
            ),
          ),
          if (hasError) ...[
            const SizedBox(width: 10),
            TextButton(
              onPressed: onRetry,
              style: TextButton.styleFrom(
                foregroundColor: const Color(0xFF0F6BFF),
                backgroundColor: const Color(0xFFEFF6FF),
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: const Text(
                'Retry',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
          ],
          if (!hasError && loading) ...[
            const SizedBox(width: 10),
            const SizedBox(
              height: 16,
              width: 16,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          ],
        ],
      ),
    );
  }
}

class _BannerPlaceholder extends StatelessWidget {
  const _BannerPlaceholder({required this.radius});

  final double radius;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 230,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(color: const Color(0xFFE6E9F0)),
      ),
    );
  }
}

class _SearchBar extends StatefulWidget {
  const _SearchBar({
    required this.controller,
    required this.focusNode,
    required this.isDesktop,
    required this.isTablet,
    required this.focused,
    required this.radius,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final bool isDesktop;
  final bool isTablet;
  final bool focused;
  final double radius;

  @override
  State<_SearchBar> createState() => _SearchBarState();
}

class _SearchBarState extends State<_SearchBar> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final expand = widget.isDesktop || widget.isTablet || widget.focused;
    final glow = _hovered && widget.isDesktop;

    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 240),
        curve: Curves.easeOutCubic,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(widget.radius + 4),
          boxShadow: [
            BoxShadow(
              color: glow ? const Color(0x260F6BFF) : const Color(0x0F000000),
              blurRadius: glow ? 18 : 10,
              offset: const Offset(0, 8),
            ),
          ],
          border: Border.all(
            color: widget.focused ? const Color(0xFF0F6BFF) : Colors.transparent,
            width: 1.2,
          ),
        ),
        child: AnimatedSize(
          duration: const Duration(milliseconds: 240),
          curve: Curves.easeOutCubic,
          child: SizedBox(
            height: 20,
            child: Row(
              children: [
                const Icon(Icons.search, color: Color(0xFF6B7280)),
                const SizedBox(width: 10),
                Expanded(
                  child: TextField(
                    controller: widget.controller,
                    focusNode: widget.focusNode,
                    decoration: const InputDecoration(
                      hintText: 'Search for parts, repairs, devices...',
                      border: InputBorder.none,
                      isDense: true,
                    ),
                    style: const TextStyle(
                      fontSize: 14,
                      fontFamily: 'Manrope',
                      fontFamilyFallback: [
                        'Inter',
                        'SF Pro Display',
                        'Arial',
                      ],
                    ),
                  ),
                ),
                if (expand) ...[
                  Container(
                    height: 26,
                    width: 1,
                    color: const Color(0xFFE5E7EB),
                  ),
                  const SizedBox(width: 10),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF3F4F6),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.tune, color: Color(0xFF6B7280), size: 16),
                        SizedBox(width: 4),
                        Text(
                          'Filter',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF6B7280),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _HeroCarousel extends StatelessWidget {
  const _HeroCarousel({
    required this.controller,
    required this.items,
    required this.index,
    required this.onIndexChanged,
    required this.reduceMotion,
    required this.radius,
  });

  final PageController controller;
  final List<_HeroItem> items;
  final int index;
  final ValueChanged<int> onIndexChanged;
  final bool reduceMotion;
  final double radius;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 230,
      child: Column(
        children: [
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(radius),
              child: PageView.builder(
                controller: controller,
                physics: const PageScrollPhysics(),
                allowImplicitScrolling: true,
                onPageChanged: onIndexChanged,
                itemCount: items.length,
                itemBuilder: (context, i) {
                  final item = items[i];
                  final hasCopy = item.title.trim().isNotEmpty ||
                      item.subtitle.trim().isNotEmpty;
                  return AnimatedBuilder(
                    animation: controller,
                    builder: (context, child) {
                      double offset = 0;
                      if (controller.position.hasContentDimensions) {
                        offset = (controller.page ?? 0) - i;
                      }
                      final t = (1 - offset.abs()).clamp(0.0, 1.0);
                      final scale = 0.96 + (t * 0.04);
                      return Opacity(
                        opacity: 0.92 + (t * 0.08),
                        child: Transform.scale(
                          scale: scale,
                          child: child,
                        ),
                      );
                    },
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        _NetworkImage(item.image),
                        Container(
                          decoration: const BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.bottomCenter,
                              end: Alignment.topRight,
                              colors: [
                                Color(0x1A000000),
                                Color(0x00000000),
                              ],
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              if (hasCopy) ...[
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: const Color(0x26FFFFFF),
                                    borderRadius: BorderRadius.circular(30),
                                    border: Border.all(
                                      color: const Color(0x33FFFFFF),
                                    ),
                                  ),
                                  child: const Text(
                                    'Trusted • 4.9 rating',
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 10),
                                AnimatedOpacity(
                                  opacity: 1,
                                  duration: Duration(
                                    milliseconds: reduceMotion ? 1 : 300,
                                  ),
                                  child: Text(
                                    item.title,
                                    style: const TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.white,
                                      fontFamily: 'Manrope',
                                      fontFamilyFallback: [
                                        'Inter',
                                        'SF Pro Display',
                                        'Arial',
                                      ],
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  item.subtitle,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Color(0xFFE2E8F0),
                                  ),
                                ),
                                const SizedBox(height: 14),
                                Row(
                                  children: [
                                    ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: const Color(0xFF0F6BFF),
                                        foregroundColor: Colors.white,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(10),
                                        ),
                                        elevation: 0,
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 14,
                                          vertical: 10,
                                        ),
                                      ),
                                      onPressed: () {},
                                      child: const Text(
                                        'Book repair',
                                        style: TextStyle(
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 12,
                                        vertical: 9,
                                      ),
                                      decoration: BoxDecoration(
                                        color: const Color(0x26FFFFFF),
                                        borderRadius: BorderRadius.circular(10),
                                        border: Border.all(
                                          color: const Color(0x33FFFFFF),
                                        ),
                                      ),
                                      child: const Row(
                                        children: [
                                          Icon(Icons.schedule,
                                              color: Colors.white, size: 16),
                                          SizedBox(width: 6),
                                          Text(
                                            'Open 9am - 9pm',
                                            style: TextStyle(
                                              fontSize: 11,
                                              color: Colors.white,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ],
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
                  );
                },
              ),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              items.length,
              (i) => AnimatedContainer(
                duration: const Duration(milliseconds: 240),
                margin: const EdgeInsets.symmetric(horizontal: 4),
                width: i == index ? 18 : 8,
                height: 8,
                decoration: BoxDecoration(
                  color: i == index
                      ? const Color(0xFF0F6BFF)
                      : const Color(0xFFD1D5DB),
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({
    required this.title,
    required this.action,
    required this.onTap,
    this.trailing,
  });

  final String title;
  final String action;
  final VoidCallback onTap;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: Color(0xFF12141A),
              fontFamily: 'Manrope',
              fontFamilyFallback: [
                'Inter',
                'SF Pro Display',
                'Arial',
              ],
            ),
          ),
        ),
        if (trailing != null) ...[
          trailing!,
          const SizedBox(width: 12),
        ],
        TextButton(
          onPressed: onTap,
          style: TextButton.styleFrom(
            foregroundColor: const Color(0xFF0F6BFF),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
              side: const BorderSide(color: Color(0xFFE2E8F0)),
            ),
            backgroundColor: Colors.white,
          ),
          child: Text(
            action,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}

class _QuickActions extends StatelessWidget {
  const _QuickActions({required this.actions, required this.radius});

  final List<_QuickActionItem> actions;
  final double radius;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(
        actions.length,
        (index) => Expanded(
          child: Padding(
            padding: EdgeInsets.only(right: index == actions.length - 1 ? 0 : 12),
            child: _QuickActionCard(
              action: actions[index],
              radius: radius,
            ),
          ),
        ),
      ),
    );
  }
}

class _QuickActionCard extends StatelessWidget {
  const _QuickActionCard({required this.action, required this.radius});

  final _QuickActionItem action;
  final double radius;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(radius),
      onTap: () {},
      child: Container(
        height: 110,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(radius),
          border: Border.all(color: const Color(0xFFE6E9F0)),
          boxShadow: const [
            BoxShadow(
              color: Color(0x12000000),
              blurRadius: 10,
              offset: Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              height: 40,
              width: 40,
              decoration: BoxDecoration(
                color: action.color.withOpacity(0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(action.icon, color: action.color, size: 22),
            ),
            const SizedBox(height: 10),
            Text(
              action.label,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Color(0xFF111827),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ServiceStatus extends StatelessWidget {
  const _ServiceStatus({required this.radius, required this.isDesktop});

  final double radius;
  final bool isDesktop;

  @override
  Widget build(BuildContext context) {
    final gap = isDesktop ? 16.0 : 12.0;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(radius + 2),
        border: Border.all(color: const Color(0xFFE6E9F0)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x12000000),
            blurRadius: 12,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Your service status',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: Color(0xFF111827),
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Live updates for your latest repair orders',
            style: TextStyle(
              fontSize: 12,
              color: Color(0xFF6B7280),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _StatusMetric(
                label: 'In progress',
                value: '2',
                color: const Color(0xFF0F6BFF),
              ),
              SizedBox(width: gap),
              _StatusMetric(
                label: 'Ready today',
                value: '1',
                color: const Color(0xFF12B886),
              ),
              SizedBox(width: gap),
              _StatusMetric(
                label: 'Completed',
                value: '12',
                color: const Color(0xFF111827),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Row(
              children: const [
                Icon(Icons.info_outline, size: 16, color: Color(0xFF0F6BFF)),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Order #KY-2481 is ready for pickup today.',
                    style: TextStyle(
                      fontSize: 12,
                      color: Color(0xFF475569),
                      fontWeight: FontWeight.w600,
                    ),
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

class _StatusMetric extends StatelessWidget {
  const _StatusMetric({
    required this.label,
    required this.value,
    required this.color,
  });

  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
        decoration: BoxDecoration(
          color: color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              value,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: const TextStyle(
                fontSize: 11,
                color: Color(0xFF6B7280),
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CategorySection extends StatelessWidget {
  const _CategorySection({
    required this.categories,
    required this.isDesktop,
    required this.isTablet,
    required this.radius,
  });

  final List<_CategoryItem> categories;
  final bool isDesktop;
  final bool isTablet;
  final double radius;

  @override
  Widget build(BuildContext context) {
    if (isDesktop || isTablet) {
      final columns = isDesktop ? 6 : 4;
      return GridView.builder(
        itemCount: categories.length,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: columns,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 1.2,
        ),
        itemBuilder: (context, index) {
          return _AnimatedEntry(
            index: index,
            child: _CategoryCard(
              item: categories[index],
              radius: radius,
            ),
          );
        },
      );
    }

    return SizedBox(
      height: 110,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          return _AnimatedEntry(
            index: index,
            child: _CategoryCard(
              item: categories[index],
              radius: radius,
            ),
          );
        },
      ),
    );
  }
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
        duration: const Duration(milliseconds: 220),
        transform: Matrix4.identity()..translate(0.0, _hovered ? -4.0 : 0.0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(widget.radius),
          border: Border.all(color: const Color(0xFFE6E9F0)),
          boxShadow: [
            BoxShadow(
              color: _hovered ? const Color(0x180F6BFF) : const Color(0x0F000000),
              blurRadius: _hovered ? 18 : 12,
              offset: const Offset(0, 8),
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
            padding: const EdgeInsets.all(12),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  height: 38,
                  width: 38,
                  decoration: BoxDecoration(
                    color: const Color(0xFFEEF4FF),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(widget.item.icon, color: const Color(0xFF0F6BFF)),
                ),
                const SizedBox(height: 10),
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

class _ProductGrid extends StatelessWidget {
  const _ProductGrid({
    required this.products,
    required this.columns,
    required this.radius,
  });

  final List<_ProductItem> products;
  final int columns;
  final double radius;

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      itemCount: products.length,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: columns,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 0.78,
      ),
      itemBuilder: (context, index) {
        return _AnimatedEntry(
          index: index,
          child: _ProductCard(
            product: products[index],
            radius: radius,
          ),
        );
      },
    );
  }
}

class _ProductGridApi extends StatelessWidget {
  const _ProductGridApi({
    required this.products,
    required this.columns,
    required this.radius,
  });

  final List<Product> products;
  final int columns;
  final double radius;

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      itemCount: products.length,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: columns,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 0.78,
      ),
      itemBuilder: (context, index) {
        final product = products[index];
        return _AnimatedEntry(
          index: index,
          child: _ProductApiCard(
            product: product,
            radius: radius,
          ),
        );
      },
    );
  }
}

class _ProductApiCard extends StatelessWidget {
  const _ProductApiCard({
    required this.product,
    required this.radius,
  });

  final Product product;
  final double radius;

  @override
  Widget build(BuildContext context) {
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
          border: Border.all(color: const Color(0xFFE6E9F0)),
          boxShadow: const [
            BoxShadow(
              color: Color(0x0F000000),
              blurRadius: 12,
              offset: Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.vertical(
                  top: Radius.circular(radius),
                ),
                child: product.imageUrl == null || product.imageUrl!.isEmpty
                    ? const _ImageFallback()
                    : Image.network(
                        product.imageUrl!,
                        fit: BoxFit.cover,
                        headers: const {
                          'User-Agent': 'Mozilla/5.0',
                          'Accept':
                              'image/avif,image/webp,image/apng,image/*,*/*;q=0.8',
                        },
                        errorBuilder: (_, __, ___) =>
                            const _ImageFallback(),
                      ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
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
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '\$${product.price.toStringAsFixed(0)}',
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF0F6BFF),
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

class _ProductCard extends StatefulWidget {
  const _ProductCard({required this.product, required this.radius});

  final _ProductItem product;
  final double radius;

  @override
  State<_ProductCard> createState() => _ProductCardState();
}

class _ProductCardState extends State<_ProductCard> {
  bool _hovered = false;
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTapDown: (_) => setState(() => _pressed = true),
        onTapUp: (_) => setState(() => _pressed = false),
        onTapCancel: () => setState(() => _pressed = false),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          transform: Matrix4.identity()
            ..translate(0.0, _hovered ? -6.0 : 0.0)
            ..scale(_pressed ? 0.98 : 1.0),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(widget.radius),
            border: Border.all(color: const Color(0xFFE6E9F0)),
            boxShadow: [
              BoxShadow(
                color: _hovered ? const Color(0x180F6BFF) : const Color(0x0F000000),
                blurRadius: _hovered ? 18 : 12,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.vertical(
                    top: Radius.circular(widget.radius),
                  ),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      _NetworkImage(widget.product.image),
                      if (_hovered)
                        Container(
                          color: Colors.black.withOpacity(0.08),
                        ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.product.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF111827),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '\$${widget.product.price.toStringAsFixed(0)}',
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF0F6BFF),
                      ),
                    ),
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

class _FlashSaleSection extends StatelessWidget {
  const _FlashSaleSection({
    required this.products,
    required this.columns,
    required this.radius,
    required this.onCartAdded,
  });

  final List<_ProductItem> products;
  final int columns;
  final double radius;
  final VoidCallback onCartAdded;

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      itemCount: products.length,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: columns,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 0.95,
      ),
      itemBuilder: (context, index) {
        return _AnimatedEntry(
          index: index,
          child: _FlashSaleCard(
            product: products[index],
            radius: radius,
            onCartAdded: onCartAdded,
          ),
        );
      },
    );
  }
}

class _FlashSaleSectionApi extends StatelessWidget {
  const _FlashSaleSectionApi({
    required this.products,
    required this.columns,
    required this.radius,
    required this.onCartAdded,
  });

  final List<Product> products;
  final int columns;
  final double radius;
  final VoidCallback onCartAdded;

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      itemCount: products.length,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: columns,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 0.95,
      ),
      itemBuilder: (context, index) {
        final product = products[index];
        return _AnimatedEntry(
          index: index,
          child: _FlashSaleCardApi(
            product: product,
            radius: radius,
            onCartAdded: onCartAdded,
          ),
        );
      },
    );
  }
}

class _FlashSaleCardApi extends StatefulWidget {
  const _FlashSaleCardApi({
    required this.product,
    required this.radius,
    required this.onCartAdded,
  });

  final Product product;
  final double radius;
  final VoidCallback onCartAdded;

  @override
  State<_FlashSaleCardApi> createState() => _FlashSaleCardApiState();
}

class _FlashSaleCardApiState extends State<_FlashSaleCardApi> {
  int _phase = 0;

  Future<void> _addToCart() async {
    if (_phase != 0) return;
    setState(() => _phase = 1);
    await Future<void>.delayed(const Duration(milliseconds: 700));
    if (!mounted) return;
    setState(() => _phase = 2);
    CartService.instance.add(widget.product, quantity: 1);
    widget.onCartAdded();
    await Future<void>.delayed(const Duration(milliseconds: 900));
    if (!mounted) return;
    setState(() => _phase = 0);
    if (!mounted) return;
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => const CartScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final imageUrl = widget.product.imageUrl;
    return InkWell(
      borderRadius: BorderRadius.circular(widget.radius),
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => ProductDetailScreen(product: widget.product),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(widget.radius),
          border: Border.all(color: const Color(0xFFE6E9F0)),
          boxShadow: const [
            BoxShadow(
              color: Color(0x0F000000),
              blurRadius: 14,
              offset: Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.vertical(
                top: Radius.circular(widget.radius),
              ),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  imageUrl == null || imageUrl.isEmpty
                      ? const _ImageFallback()
                      : Image.network(
                          imageUrl,
                          fit: BoxFit.cover,
                          headers: const {
                            'User-Agent': 'Mozilla/5.0',
                            'Accept':
                                'image/avif,image/webp,image/apng,image/*,*/*;q=0.8',
                          },
                          errorBuilder: (_, __, ___) =>
                              const _ImageFallback(),
                        ),
                  const Positioned(
                    top: 12,
                    left: 12,
                    child: _SaleBadge(),
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.product.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Text(
                      '\$${widget.product.price.toStringAsFixed(0)}',
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        color: Color(0xFFE8590C),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '\$${(widget.product.price * 1.2).toStringAsFixed(0)}',
                      style: const TextStyle(
                        color: Color(0xFF9CA3AF),
                        decoration: TextDecoration.lineThrough,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  height: 36,
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 220),
                    child: _phase == 0
                        ? ElevatedButton(
                            key: const ValueKey('add'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFFF8A00),
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              elevation: 0,
                            ),
                            onPressed: _addToCart,
                            child: const Text('Add to cart'),
                          )
                        : _phase == 1
                            ? Container(
                                key: const ValueKey('loading'),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFFFF3E0),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: const Center(
                                  child: SizedBox(
                                    height: 18,
                                    width: 18,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor:
                                          AlwaysStoppedAnimation<Color>(
                                        Color(0xFFFF8A00),
                                      ),
                                    ),
                                  ),
                                ),
                              )
                            : Container(
                                key: const ValueKey('done'),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFE8F5E9),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: const Center(
                                  child: Icon(
                                    Icons.check_circle,
                                    color: Color(0xFF2E7D32),
                                  ),
                                ),
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

class _FlashSaleCard extends StatefulWidget {
  const _FlashSaleCard({
    required this.product,
    required this.radius,
    required this.onCartAdded,
  });

  final _ProductItem product;
  final double radius;
  final VoidCallback onCartAdded;

  @override
  State<_FlashSaleCard> createState() => _FlashSaleCardState();
}

class _FlashSaleCardState extends State<_FlashSaleCard> {
  int _phase = 0;

  Future<void> _addToCart() async {
    if (_phase != 0) return;
    setState(() => _phase = 1);
    await Future<void>.delayed(const Duration(milliseconds: 800));
    if (!mounted) return;
    setState(() => _phase = 2);
    widget.onCartAdded();
    await Future<void>.delayed(const Duration(milliseconds: 900));
    if (!mounted) return;
    setState(() => _phase = 0);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(widget.radius),
        border: Border.all(color: const Color(0xFFE6E9F0)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0F000000),
            blurRadius: 14,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.vertical(
                top: Radius.circular(widget.radius),
              ),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  _NetworkImage(widget.product.image),
                  const Positioned(
                    top: 12,
                    left: 12,
                    child: _SaleBadge(),
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.product.name,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Text(
                      '\$${widget.product.price.toStringAsFixed(0)}',
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        color: Color(0xFFE8590C),
                      ),
                    ),
                    const SizedBox(width: 8),
                    if (widget.product.oldPrice != null)
                      Text(
                        '\$${widget.product.oldPrice!.toStringAsFixed(0)}',
                        style: const TextStyle(
                          color: Color(0xFF9CA3AF),
                          decoration: TextDecoration.lineThrough,
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  height: 36,
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 220),
                          child: _phase == 0
                        ? ElevatedButton(
                            key: const ValueKey('add'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFFF8A00),
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              elevation: 0,
                            ),
                            onPressed: _addToCart,
                            child: const Text('Add to cart'),
                          )
                            : _phase == 1
                                ? Container(
                                    key: const ValueKey('loading'),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFFFF3E0),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: const Center(
                                      child: SizedBox(
                                        height: 18,
                                    width: 18,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          valueColor: AlwaysStoppedAnimation<Color>(
                                            Color(0xFFFF8A00),
                                          ),
                                        ),
                                      ),
                                    ),
                              )
                            : Container(
                                key: const ValueKey('done'),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFE8F5E9),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: const Center(
                                  child: Icon(
                                    Icons.check_circle,
                                    color: Color(0xFF2E7D32),
                                  ),
                                ),
                              ),
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

class _FeaturedSection extends StatelessWidget {
  const _FeaturedSection({
    required this.products,
    required this.columns,
    required this.radius,
  });

  final List<_ProductItem> products;
  final int columns;
  final double radius;

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      itemCount: products.length,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: columns,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: columns == 1 ? 2.7 : 1.6,
      ),
      itemBuilder: (context, index) {
        return _AnimatedEntry(
          index: index,
          child: _FeaturedCard(
            product: products[index],
            radius: radius,
          ),
        );
      },
    );
  }
}

class _FeaturedCard extends StatelessWidget {
  const _FeaturedCard({required this.product, required this.radius});

  final _ProductItem product;
  final double radius;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(color: const Color(0xFFE6E9F0)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0F000000),
            blurRadius: 12,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.horizontal(
              left: Radius.circular(radius),
            ),
            child: _NetworkImage(
              product.image,
              width: 110,
              height: double.infinity,
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    product.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 8),
                  _ShimmerPrice(
                    child: Text(
                      '\$${product.price.toStringAsFixed(0)}',
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF0F6BFF),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
    );
  }
}

class _ShimmerPrice extends StatefulWidget {
  const _ShimmerPrice({required this.child});

  final Widget child;

  @override
  State<_ShimmerPrice> createState() => _ShimmerPriceState();
}

class _ShimmerPriceState extends State<_ShimmerPrice>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final reduce = MediaQuery.of(context).disableAnimations ||
        MediaQuery.of(context).accessibleNavigation;
    if (reduce) {
      if (_controller.isAnimating) {
        _controller.stop();
      }
      return widget.child;
    }
    if (!_controller.isAnimating) {
      _controller.repeat();
    }
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final value = _controller.value;
        return ShaderMask(
          shaderCallback: (rect) {
            return LinearGradient(
              begin: Alignment(-1 + value * 2, 0),
              end: Alignment(1 + value * 2, 0),
              colors: const [
                Color(0xFF0F6BFF),
                Color(0xFFFF8A00),
                Color(0xFF0F6BFF),
              ],
              stops: const [0.2, 0.5, 0.8],
            ).createShader(rect);
          },
          child: child,
        );
      },
      child: widget.child,
    );
  }
}

class _SaleBadge extends StatefulWidget {
  const _SaleBadge();

  @override
  State<_SaleBadge> createState() => _SaleBadgeState();
}

class _SaleBadgeState extends State<_SaleBadge> {
  bool _pulse = false;

  @override
  void initState() {
    super.initState();
    _pulse = true;
  }

  @override
  Widget build(BuildContext context) {
    final reduce = MediaQuery.of(context).disableAnimations ||
        MediaQuery.of(context).accessibleNavigation;
    if (reduce) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: const Color(0xFFE8590C),
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Text(
          'SALE 30%',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w700,
            fontSize: 10,
          ),
        ),
      );
    }
    return AnimatedScale(
      scale: _pulse ? 1.0 : 0.92,
      duration: const Duration(milliseconds: 900),
      curve: Curves.easeInOut,
      onEnd: () => setState(() => _pulse = !_pulse),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: const Color(0xFFE8590C),
          borderRadius: BorderRadius.circular(8),
          boxShadow: const [
            BoxShadow(
              color: Color(0x33E8590C),
              blurRadius: 12,
            ),
          ],
        ),
        child: const Text(
          'SALE 30%',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w700,
            fontSize: 10,
          ),
        ),
      ),
    );
  }
}

class _CountdownBadge extends StatelessWidget {
  const _CountdownBadge();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: const [
        _DigitChip(),
        SizedBox(width: 4),
        _DigitChip(separator: true),
        SizedBox(width: 4),
        _DigitChip(),
        SizedBox(width: 4),
        _DigitChip(separator: true),
        SizedBox(width: 4),
        _DigitChip(),
      ],
    );
  }
}

class _DigitChip extends StatefulWidget {
  const _DigitChip({this.separator = false});

  final bool separator;

  @override
  State<_DigitChip> createState() => _DigitChipState();
}

class _DigitChipState extends State<_DigitChip> {
  late Timer _timer;
  int _value = 59;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      setState(() => _value = (_value - 1) % 60);
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.separator) {
      return const Text(':',
          style: TextStyle(
            fontWeight: FontWeight.w700,
            color: Color(0xFF111827),
          ));
    }
    final display = _value.toString().padLeft(2, '0');
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 260),
      transitionBuilder: (child, animation) {
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0, 0.4),
            end: Offset.zero,
          ).animate(animation),
          child: FadeTransition(opacity: animation, child: child),
        );
      },
      child: Container(
        key: ValueKey(display),
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
        decoration: BoxDecoration(
          color: const Color(0xFFF3F4F6),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Text(
          display,
          style: const TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 12,
            color: Color(0xFF111827),
          ),
        ),
      ),
    );
  }
}

class _NetworkImage extends StatelessWidget {
  const _NetworkImage(this.url, {this.width, this.height});

  final String url;
  final double? width;
  final double? height;

  @override
  Widget build(BuildContext context) {
    return Image.network(
      url,
      width: width,
      height: height,
      headers: const {
        'User-Agent': 'Mozilla/5.0',
        'Accept': 'image/avif,image/webp,image/apng,image/*,*/*;q=0.8',
      },
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) {
        debugPrint('[HomeScreen] image load failed: $url');
        return Container(
          width: width,
          height: height,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFFEAF2FF), Color(0xFFFFF1E6)],
            ),
          ),
          child: const _ImageFallbackArt(),
        );
      },
    );
  }
}

class _ImageFallbackArt extends StatelessWidget {
  const _ImageFallbackArt();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: const [
          Icon(Icons.auto_fix_high, color: Color(0xFF0F6BFF), size: 28),
          SizedBox(height: 6),
          Text(
            'REPAIR READY',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.2,
              color: Color(0xFF111827),
            ),
          ),
          SizedBox(height: 2),
          Text(
            'Image loading',
            style: TextStyle(
              fontSize: 10,
              color: Color(0xFF6B7280),
            ),
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
      color: const Color(0xFFF3F4F6),
      child: const Center(
        child: Icon(Icons.devices, color: Color(0xFF9CA3AF)),
      ),
    );
  }
}

class _AnimatedEntry extends StatelessWidget {
  const _AnimatedEntry({required this.index, required this.child});

  final int index;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final reduce = MediaQuery.of(context).disableAnimations ||
        MediaQuery.of(context).accessibleNavigation;
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: Duration(milliseconds: reduce ? 1 : 320 + index * 40),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, (1 - value) * 12),
            child: child,
          ),
        );
      },
      child: child,
    );
  }
}

class _HeroItem {
  const _HeroItem({
    required this.title,
    required this.subtitle,
    required this.image,
  });

  final String title;
  final String subtitle;
  final String image;
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

class _QuickActionItem {
  const _QuickActionItem({
    required this.label,
    required this.icon,
    required this.color,
  });

  final String label;
  final IconData icon;
  final Color color;
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.title, required this.subtitle});

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE6E9F0)),
      ),
      child: Column(
        children: [
          const Icon(Icons.inventory_2_outlined,
              size: 32, color: Color(0xFF9CA3AF)),
          const SizedBox(height: 8),
          Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.w700,
              color: Color(0xFF111827),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 12,
              color: Color(0xFF6B7280),
            ),
          ),
        ],
      ),
    );
  }
}

class _ProductItem {
  const _ProductItem({
    required this.name,
    required this.price,
    required this.image,
    this.oldPrice,
  });

  final String name;
  final double price;
  final String image;
  final double? oldPrice;
}

import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart' show ScrollDirection;
import 'package:google_fonts/google_fonts.dart';
import '../../models/banner_item.dart';
import '../../models/category.dart';
import '../../models/product.dart';
import '../../models/search_suggestion.dart';
import '../../models/user_profile.dart';
import '../../services/api_service.dart';
import '../../services/cart_service.dart';
import '../../services/favorite_service.dart';
import '../../services/search_history_service.dart';
import '../../widgets/auth_guard.dart';
import '../../widgets/cart_added_bottom_bar.dart';
import '../cart/cart_screen.dart';
import '../categories/categories_screen.dart';
import '../categories/category_products_screen.dart';
import '../notifications/notification_screen.dart';
import '../products/all_products_screen.dart';
import '../products/product_detail_screen.dart';
import '../search/search_results_screen.dart';

Map<String, String>? get _imageHeaders => null;

const _homeBgLight = Color(0xFFF6F7FB);
const _homeBgDark = Color(0xFF0D1117);
const _surfaceLight = Color(0xFFFFFFFF);
const _surfaceDark = Color(0xFF161B22);
const _surfaceAltLight = Color(0xFFF1F4FA);
const _surfaceAltDark = Color(0xFF1D2635);
const _cardBorderLight = Color(0xFFE5EAF2);
const _cardBorderDark = Color(0xFF2B3442);
const _primary = Color(0xFF3B63FF);
const _primarySoft = Color(0xFFEAF0FF);
const _textPrimaryLight = Color(0xFF111827);
const _textPrimaryDark = Color(0xFFE6EDF7);
const _textMutedLight = Color(0xFF667085);
const _textMutedDark = Color(0xFF97A2B5);
const _heroBlue = Color(0xFF5383FF);
const _heroPurple = Color(0xFF7367FF);
const _heroLight = Color(0xFFF1F4FF);
const _success = Color(0xFF16A34A);
const _danger = Color(0xFFDC2626);
const _shadow = Color(0x140F172A);

bool _isDark(BuildContext context) =>
    Theme.of(context).brightness == Brightness.dark;

Color _homeBg(BuildContext context) =>
    _isDark(context) ? _homeBgDark : _homeBgLight;

Color _surface(BuildContext context) =>
    _isDark(context) ? _surfaceDark : _surfaceLight;

Color _surfaceAlt(BuildContext context) =>
    _isDark(context) ? _surfaceAltDark : _surfaceAltLight;

Color _cardBorder(BuildContext context) =>
    _isDark(context) ? _cardBorderDark : _cardBorderLight;

Color _textPrimary(BuildContext context) =>
    _isDark(context) ? _textPrimaryDark : _textPrimaryLight;

Color _textMuted(BuildContext context) =>
    _isDark(context) ? _textMutedDark : _textMutedLight;

List<Color> _homeGradient(BuildContext context) => _isDark(context)
    ? const [Color(0xFF0D1117), Color(0xFF111826), Color(0xFF0D1117)]
    : const [Color(0xFFF9FAFD), Color(0xFFF5F7FB), Color(0xFFF9FAFD)];

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final PageController _bannerController = PageController();
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();

  Timer? _bannerTimer;
  Timer? _searchDebounce;
  int _bannerIndex = 0;
  bool _isBannerAutoAnimating = false;
  bool _isBannerUserInteracting = false;

  bool _isLoadingBanner = false;
  List<BannerItem> _banners = [];
  late Future<List<Category>> _categoriesFuture;
  late Future<List<Product>> _productsFuture;
  Future<UserProfile?> _profileFuture = ApiService.getUserProfile();
  List<SearchSuggestion> _searchSuggestions = [];
  List<String> _recentSearches = const [];
  bool _isLoadingSearchSuggestions = false;

  static const List<String> _popularSearches = [
    'iPhone',
    'Samsung',
    'MacBook repair',
    'screen repair',
    'battery replacement',
  ];

  @override
  void initState() {
    super.initState();
    _categoriesFuture = ApiService.fetchCategories();
    _productsFuture = _loadProducts();
    _loadBanners();
    _loadRecentSearches();
    _searchFocusNode.addListener(() {
      if (mounted) {
        setState(() {});
      }
    });
    ApiService.profileVersionListenable.addListener(_handleProfileUpdated);
  }

  @override
  void dispose() {
    ApiService.profileVersionListenable.removeListener(_handleProfileUpdated);
    _bannerTimer?.cancel();
    _searchDebounce?.cancel();
    _bannerController.dispose();
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  void _handleProfileUpdated() {
    if (!mounted) return;
    setState(() {
      _profileFuture = ApiService.getUserProfile();
    });
  }

  Future<void> _addToCart(Product product) async {
    final ok = await ensureLoggedIn(
      context,
      message: 'Please login or register to add items to your cart.',
    );
    if (!ok || !mounted) return;
    CartService.instance.add(product);
    await showCartAddedBottomBar(context);
  }

  Future<void> _refresh() async {
    await _clearImageCache();
    _loadBanners();
    setState(() {
      _categoriesFuture = ApiService.fetchCategories();
      _productsFuture = _loadProducts();
      _profileFuture = ApiService.getUserProfile();
    });
    await Future.wait([_categoriesFuture, _productsFuture]);
  }

  Future<void> _clearImageCache() async {
    final cache = PaintingBinding.instance.imageCache;
    cache.clear();
    cache.clearLiveImages();
  }

  Future<List<Product>> _loadProducts() async {
    final items = await ApiService.fetchProducts();
    return items;
  }

  Future<void> _loadRecentSearches() async {
    final items = await SearchHistoryService.getRecentSearches();
    if (!mounted) return;
    setState(() => _recentSearches = items);
  }

  void _updateSuggestions([String? raw]) {
    final query = (raw ?? _searchController.text).trim();
    _searchDebounce?.cancel();
    if (query.isEmpty) {
      setState(() {
        _searchSuggestions = [];
        _isLoadingSearchSuggestions = false;
      });
      return;
    }

    setState(() => _isLoadingSearchSuggestions = true);
    _searchDebounce = Timer(const Duration(milliseconds: 250), () async {
      final suggestions = await ApiService.fetchSearchSuggestions(query);
      if (!mounted || _searchController.text.trim() != query) return;
      setState(() {
        _searchSuggestions = suggestions;
        _isLoadingSearchSuggestions = false;
      });
    });
  }

  Future<void> _openSearchResults(String raw) async {
    final query = raw.trim();
    if (query.isEmpty) return;

    await SearchHistoryService.addSearch(query);
    if (mounted) {
      setState(() {
        _recentSearches = [
          query,
          ..._recentSearches.where(
            (item) => item.toLowerCase() != query.toLowerCase(),
          ),
        ].take(8).toList();
      });
    }

    if (!mounted) return;
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => SearchResultsScreen(initialQuery: query),
      ),
    );
    if (!mounted) return;
    _loadRecentSearches();
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
        _isBannerAutoAnimating = false;
        _isBannerUserInteracting = false;
      });
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted || !_bannerController.hasClients || _banners.isEmpty) {
          return;
        }
        _bannerController.jumpToPage(0);
      });
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
      unawaited(_advanceBanner());
    });
  }

  void _pauseBannerAutoSlide() {
    _bannerTimer?.cancel();
  }

  void _handleBannerInteractionStart() {
    _isBannerUserInteracting = true;
    _pauseBannerAutoSlide();
  }

  void _handleBannerInteractionEnd() {
    _isBannerUserInteracting = false;
    _startBannerAutoSlide();
  }

  Future<void> _advanceBanner() async {
    if (!mounted ||
        _isBannerUserInteracting ||
        _isBannerAutoAnimating ||
        _banners.length <= 1 ||
        !_bannerController.hasClients) {
      return;
    }

    final currentPage = (_bannerController.page ?? _bannerIndex.toDouble())
        .round();
    final current = currentPage.clamp(0, _banners.length - 1).toInt();
    final next = (current + 1) % _banners.length;

    _isBannerAutoAnimating = true;
    try {
      await _bannerController.animateToPage(
        next,
        duration: const Duration(milliseconds: 360),
        curve: Curves.easeOutCubic,
      );
      if (!mounted) return;
      setState(() => _bannerIndex = next);
    } catch (_) {
      // The controller can detach during tab changes or refreshes.
    } finally {
      _isBannerAutoAnimating = false;
    }
  }

  Future<void> _goToBanner(int index) async {
    if (!_bannerController.hasClients ||
        index == _bannerIndex ||
        index < 0 ||
        index >= _banners.length) {
      return;
    }

    _handleBannerInteractionStart();
    try {
      await _bannerController.animateToPage(
        index,
        duration: const Duration(milliseconds: 280),
        curve: Curves.easeOutCubic,
      );
      if (!mounted) return;
      setState(() => _bannerIndex = index);
    } catch (_) {
      // Ignore if the page view is temporarily detached.
    } finally {
      _handleBannerInteractionEnd();
    }
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

  void _handleAddToCart(Product product) {
    _addToCart(product);
  }

  @override
  Widget build(BuildContext context) {
    final showSearchDiscovery =
        _searchFocusNode.hasFocus &&
        _searchController.text.trim().isEmpty &&
        (_recentSearches.isNotEmpty || _popularSearches.isNotEmpty);
    final showSearchSuggestions =
        _searchFocusNode.hasFocus && _searchController.text.trim().isNotEmpty;

    return Scaffold(
      backgroundColor: _homeBg(context),
      body: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: _homeGradient(context),
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: RefreshIndicator(
            color: _primary,
            onRefresh: _refresh,
            child: ListView(
              physics: const BouncingScrollPhysics(
                parent: AlwaysScrollableScrollPhysics(),
              ),
              padding: const EdgeInsets.fromLTRB(18, 16, 18, 34),
              children: [
                FutureBuilder<UserProfile?>(
                  future: _profileFuture,
                  builder: (context, snapshot) {
                    final name = snapshot.data?.displayName.trim() ?? 'User';
                    final safeName = name.isNotEmpty ? name : 'User';
                    return _HomeHeader(
                      title: 'Kneayerng',
                      welcomeName: safeName,
                      onMenuTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) =>
                                const CategoriesScreen(showBottomNav: true),
                          ),
                        );
                      },
                      onNotificationTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => const NotificationScreen(),
                          ),
                        );
                      },
                      onCartTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(builder: (_) => const CartScreen()),
                        );
                      },
                    );
                  },
                ),
                const SizedBox(height: 18),
                _SearchInput(
                  controller: _searchController,
                  focusNode: _searchFocusNode,
                  hintText: 'Search MacBook, iPhone, repair...',
                  onChanged: _updateSuggestions,
                  onSubmitted: (value) {
                    _openSearchResults(value);
                  },
                ),
                if (showSearchDiscovery) ...[
                  const SizedBox(height: 10),
                  _SearchDiscoveryList(
                    recentSearches: _recentSearches,
                    popularSearches: _popularSearches,
                    onSelect: (value) {
                      _searchController.text = value;
                      _openSearchResults(value);
                    },
                  ),
                ] else if (showSearchSuggestions) ...[
                  const SizedBox(height: 10),
                  _SearchSuggestionList(
                    items: _searchSuggestions,
                    query: _searchController.text.trim(),
                    isLoading: _isLoadingSearchSuggestions,
                    onSelect: (suggestion) {
                      _searchController.text = suggestion.value;
                      _openSearchResults(suggestion.value);
                    },
                    onSearchQuery: () {
                      _openSearchResults(_searchController.text);
                    },
                  ),
                ],
                const SizedBox(height: 18),
                FutureBuilder<List<Product>>(
                  future: _productsFuture,
                  builder: (context, snapshot) {
                    return _HeroShowcase(
                      loading:
                          _isLoadingBanner &&
                          _banners.isEmpty &&
                          snapshot.connectionState == ConnectionState.waiting &&
                          (snapshot.data == null || snapshot.data!.isEmpty),
                      banners: _banners,
                      controller: _bannerController,
                      activeIndex: _bannerIndex,
                      onPageChanged: (index) {
                        setState(() => _bannerIndex = index);
                      },
                      onInteractionStart: _handleBannerInteractionStart,
                      onInteractionEnd: _handleBannerInteractionEnd,
                      onIndicatorTap: _goToBanner,
                      products: snapshot.data ?? const [],
                      onShopNow: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) =>
                                const AllProductsScreen(title: 'All Products'),
                          ),
                        );
                      },
                    );
                  },
                ),
                const SizedBox(height: 20),
                FutureBuilder<List<Category>>(
                  future: _categoriesFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const _CategorySkeleton();
                    }
                    final categories = _selectHomepageCategories(
                      snapshot.data ?? const [],
                    );
                    if (categories.isEmpty) {
                      return const SizedBox.shrink();
                    }
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _CategoryShowcaseStrip(
                          categories: categories,
                          iconFor: _iconForCategory,
                          onRepairTap: () {
                            _openSearchResults('repair');
                          },
                        ),
                      ],
                    );
                  },
                ),
                const SizedBox(height: 22),
                const _ValueHighlights(),
                const SizedBox(height: 24),
                FutureBuilder<List<Product>>(
                  future: _productsFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _HomeSectionHeader(
                            title: 'Best Sellers',
                            actionLabel: 'View all',
                            onTap: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => const AllProductsScreen(
                                    title: 'All Products',
                                  ),
                                ),
                              );
                            },
                          ),
                          const SizedBox(height: 14),
                          const _ProductsSkeleton(),
                        ],
                      );
                    }
                    if (snapshot.hasError) {
                      return const _SimpleState(
                        icon: Icons.wifi_off_rounded,
                        title: 'Unable to load products',
                      );
                    }
                    final allProducts = snapshot.data ?? const [];
                    if (allProducts.isEmpty) {
                      return const _SimpleState(
                        icon: Icons.inventory_2_outlined,
                        title: 'No products available',
                      );
                    }

                    final bestSellers = allProducts.take(6).toList();

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _HomeSectionHeader(
                          title: 'Best Sellers',
                          actionLabel: 'View all',
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => const AllProductsScreen(
                                  title: 'All Products',
                                ),
                              ),
                            );
                          },
                        ),
                        const SizedBox(height: 14),
                        LayoutBuilder(
                          builder: (context, constraints) {
                            final columns = constraints.maxWidth >= 720 ? 3 : 2;
                            return GridView.builder(
                              itemCount: bestSellers.length,
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              gridDelegate:
                                  SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: columns,
                                    mainAxisSpacing: 14,
                                    crossAxisSpacing: 14,
                                    childAspectRatio: columns == 3
                                        ? 0.72
                                        : 0.64,
                                  ),
                              itemBuilder: (context, index) {
                                final product = bestSellers[index];
                                return _FlashProductCard(
                                  product: product,
                                  onOpen: () {
                                    Navigator.of(context).push(
                                      MaterialPageRoute(
                                        builder: (_) => ProductDetailScreen(
                                          product: product,
                                        ),
                                      ),
                                    );
                                  },
                                  onAdd: () => _handleAddToCart(product),
                                );
                              },
                            );
                          },
                        ),
                      ],
                    );
                  },
                ),
                const SizedBox(height: 24),
                _RepairCallout(
                  onBookRepair: () {
                    _openSearchResults('repair');
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _HomeHeader extends StatelessWidget {
  const _HomeHeader({
    required this.title,
    required this.welcomeName,
    required this.onMenuTap,
    required this.onNotificationTap,
    required this.onCartTap,
  });

  final String title;
  final String welcomeName;
  final VoidCallback onMenuTap;
  final VoidCallback onNotificationTap;
  final VoidCallback onCartTap;

  @override
  Widget build(BuildContext context) {
    final greeting = welcomeName == 'User'
        ? 'Buy. Repair. Trust.'
        : 'Hi, $welcomeName';

    return Row(
      children: [
        _IconCircleButton(icon: Icons.menu_rounded, onTap: onMenuTap),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: 'i',
                      style: GoogleFonts.sora(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        color: _primary,
                      ),
                    ),
                    TextSpan(
                      text: title.substring(1),
                      style: GoogleFonts.sora(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        color: _textPrimary(context),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 2),
              Text(
                greeting,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.manrope(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: _textMuted(context),
                ),
              ),
            ],
          ),
        ),
        _IconCircleButton(
          icon: Icons.notifications_none_rounded,
          onTap: onNotificationTap,
          badgeCount: 1,
        ),
        const SizedBox(width: 8),
        _CartIconButton(onTap: onCartTap),
      ],
    );
  }
}

class _SearchInput extends StatelessWidget {
  const _SearchInput({
    required this.controller,
    required this.focusNode,
    required this.hintText,
    this.onChanged,
    this.onSubmitted,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final String hintText;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: _surface(context),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _cardBorder(context)),
        boxShadow: const [
          BoxShadow(color: _shadow, blurRadius: 10, offset: Offset(0, 4)),
        ],
      ),
      child: TextField(
        controller: controller,
        focusNode: focusNode,
        onChanged: onChanged,
        onSubmitted: onSubmitted,
        onTapOutside: (_) {
          focusNode.unfocus();
        },
        textInputAction: TextInputAction.search,
        maxLength: 80,
        style: GoogleFonts.manrope(
          fontSize: 14.5,
          fontWeight: FontWeight.w700,
          color: _textPrimary(context),
        ),
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: GoogleFonts.manrope(
            color: _textMuted(context),
            fontWeight: FontWeight.w600,
          ),
          counterText: '',
          prefixIcon: Icon(
            Icons.search_rounded,
            color: _textMuted(context),
            size: 28,
          ),
          suffixIcon: controller.text.isEmpty
              ? Icon(Icons.tune_rounded, color: _textMuted(context))
              : IconButton(
                  icon: Icon(Icons.close_rounded, color: _textMuted(context)),
                  onPressed: () {
                    controller.clear();
                    onChanged?.call('');
                  },
                ),
          filled: true,
          fillColor: _surface(context),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 18,
            vertical: 20,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
            borderSide: const BorderSide(color: _primary, width: 1.2),
          ),
        ),
      ),
    );
  }
}

class _HomeSectionHeader extends StatelessWidget {
  const _HomeSectionHeader({
    required this.title,
    required this.actionLabel,
    required this.onTap,
  });

  final String title;
  final String actionLabel;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          title,
          style: GoogleFonts.sora(
            fontSize: 24,
            fontWeight: FontWeight.w700,
            color: _textPrimary(context),
          ),
        ),
        const Spacer(),
        TextButton(
          onPressed: onTap,
          style: TextButton.styleFrom(
            foregroundColor: _primary,
            padding: EdgeInsets.zero,
            minimumSize: const Size(40, 24),
          ),
          child: Text(
            actionLabel,
            style: GoogleFonts.manrope(
              fontSize: 14,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ],
    );
  }
}

class _HeroShowcase extends StatelessWidget {
  const _HeroShowcase({
    required this.loading,
    required this.banners,
    required this.controller,
    required this.activeIndex,
    required this.onPageChanged,
    required this.onInteractionStart,
    required this.onInteractionEnd,
    required this.onIndicatorTap,
    required this.products,
    required this.onShopNow,
  });

  final bool loading;
  final List<BannerItem> banners;
  final PageController controller;
  final int activeIndex;
  final ValueChanged<int> onPageChanged;
  final VoidCallback onInteractionStart;
  final VoidCallback onInteractionEnd;
  final ValueChanged<int> onIndicatorTap;
  final List<Product> products;
  final VoidCallback onShopNow;

  @override
  Widget build(BuildContext context) {
    if (banners.isNotEmpty) {
      return LayoutBuilder(
        builder: (context, constraints) {
          final bannerHeight = (constraints.maxWidth / (16 / 7))
              .clamp(150.0, 190.0)
              .toDouble();

          return Container(
            height: bannerHeight,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              boxShadow: const [
                BoxShadow(color: _shadow, blurRadius: 18, offset: Offset(0, 8)),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: Stack(
                children: [
                  NotificationListener<ScrollNotification>(
                    onNotification: (notification) {
                      if (notification is ScrollStartNotification &&
                          notification.dragDetails != null) {
                        onInteractionStart();
                      } else if (notification is ScrollEndNotification) {
                        onInteractionEnd();
                      } else if (notification is UserScrollNotification &&
                          notification.direction == ScrollDirection.idle) {
                        onInteractionEnd();
                      }
                      return false;
                    },
                    child: PageView.builder(
                      controller: controller,
                      itemCount: banners.length,
                      onPageChanged: onPageChanged,
                      itemBuilder: (context, index) {
                        final banner = banners[index];
                        return _HeroBannerSlide(item: banner, onTap: onShopNow);
                      },
                    ),
                  ),
                  if (banners.length > 1)
                    Positioned(
                      left: 0,
                      right: 0,
                      bottom: 12,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(
                          banners.length,
                          (index) => GestureDetector(
                            behavior: HitTestBehavior.opaque,
                            onTap: () => onIndicatorTap(index),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 220),
                              width: index == activeIndex ? 18 : 8,
                              height: 8,
                              margin: const EdgeInsets.symmetric(
                                horizontal: 4,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color: index == activeIndex
                                    ? Colors.white
                                    : Colors.white.withValues(alpha: 0.48),
                                borderRadius: BorderRadius.circular(999),
                                boxShadow: const [
                                  BoxShadow(
                                    color: Color(0x33000000),
                                    blurRadius: 8,
                                    offset: Offset(0, 2),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          );
        },
      );
    }

    final laptop = _firstProductMatch(products, const [
      'macbook',
      'laptop',
      'mac',
    ]);
    final phone = _firstProductMatch(products, const [
      'iphone',
      'phone',
      'mobile',
    ]);

    return LayoutBuilder(
      builder: (context, constraints) {
        final compact = constraints.maxWidth < 360;
        final heroHeight = compact ? 330.0 : 320.0;
        final textWidth = compact
            ? constraints.maxWidth * 0.72
            : math.min(214.0, constraints.maxWidth * 0.56);
        final laptopWidth = compact ? 150.0 : 188.0;
        final laptopHeight = compact ? 118.0 : 150.0;
        final phoneWidth = compact ? 60.0 : 76.0;
        final phoneHeight = compact ? 88.0 : 112.0;

        return Container(
          height: heroHeight,
          decoration: BoxDecoration(
            color: _heroLight,
            borderRadius: BorderRadius.circular(28),
            border: Border.all(color: _cardBorder(context)),
            boxShadow: const [
              BoxShadow(color: _shadow, blurRadius: 18, offset: Offset(0, 8)),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(28),
            child: Stack(
              clipBehavior: Clip.hardEdge,
              children: [
                Positioned(
                  top: -14,
                  right: -18,
                  child: Container(
                    width: 170,
                    height: 170,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          _primary.withValues(alpha: 0.10),
                          _heroBlue.withValues(alpha: 0),
                        ],
                      ),
                    ),
                  ),
                ),
                Positioned(
                  right: compact ? -18 : -10,
                  bottom: 38,
                  child: IgnorePointer(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        _HeroDeviceImage(
                          product: laptop,
                          width: laptopWidth,
                          height: laptopHeight,
                          icon: Icons.laptop_mac_rounded,
                          frameColor: _primary,
                          surfaceColor: const Color(0xFFE8EEFF),
                        ),
                        Transform.translate(
                          offset: Offset(compact ? -8 : -10, 8),
                          child: _HeroDeviceImage(
                            product: phone,
                            width: phoneWidth,
                            height: phoneHeight,
                            icon: Icons.phone_iphone_rounded,
                            frameColor: _primary,
                            surfaceColor: const Color(0xFFF0F3FF),
                            isPhone: true,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(18, 18, 18, 18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 7,
                        ),
                        decoration: BoxDecoration(
                          color: _heroPurple,
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(
                          'New Arrival',
                          style: GoogleFonts.manrope(
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                            color: _surface(context),
                          ),
                        ),
                      ),
                      const SizedBox(height: 14),
                      SizedBox(
                        width: textWidth,
                        child: Text(
                          'Power.\nPerformance.\nPerfected.',
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.sora(
                            fontSize: compact ? 28 : 31,
                            height: 1.06,
                            fontWeight: FontWeight.w700,
                            color: _textPrimary(context),
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      SizedBox(
                        width: textWidth,
                        child: Text(
                          loading
                              ? 'Loading the latest MacBook and iPhone showcase.'
                              : 'Explore the latest MacBook and iPhone.',
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.manrope(
                            fontSize: 14,
                            height: 1.45,
                            fontWeight: FontWeight.w600,
                            color: _textMuted(context),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      FilledButton(
                        onPressed: onShopNow,
                        style: FilledButton.styleFrom(
                          backgroundColor: _primary,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 18,
                            vertical: 15,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(18),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'Shop Now',
                              style: GoogleFonts.manrope(
                                fontWeight: FontWeight.w800,
                                fontSize: 15,
                              ),
                            ),
                            const SizedBox(width: 8),
                            const Icon(Icons.arrow_forward_rounded, size: 18),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 16,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      3,
                      (index) => Container(
                        width: index == 0 ? 18 : 8,
                        height: 8,
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        decoration: BoxDecoration(
                          color: index == 0 ? _primary : _cardBorder(context),
                          borderRadius: BorderRadius.circular(999),
                        ),
                      ),
                    ),
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

class _HeroBannerSlide extends StatelessWidget {
  const _HeroBannerSlide({required this.item, required this.onTap});

  final BannerItem item;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final title = item.title?.trim() ?? '';
    final subtitle = item.subtitle?.trim() ?? '';
    final badge = item.badgeLabel?.trim() ?? '';
    final cta = (item.ctaLabel?.trim().isNotEmpty ?? false)
        ? item.ctaLabel!.trim()
        : 'Shop Now';
    final imageUrl = item.imageUrl?.trim();
    final hasCopy = title.isNotEmpty || subtitle.isNotEmpty || badge.isNotEmpty;

    return LayoutBuilder(
      builder: (context, constraints) {
        final compact = constraints.maxWidth < 360;
        final textWidth = compact
            ? constraints.maxWidth * 0.72
            : math.min(224.0, constraints.maxWidth * 0.60);
        final ctaTextWidth = math.max(72.0, textWidth - 62);

        return Material(
          color: _heroLight,
          child: InkWell(
            onTap: onTap,
            child: Stack(
              fit: StackFit.expand,
              clipBehavior: Clip.hardEdge,
              children: [
                if (imageUrl != null && imageUrl.isNotEmpty)
                  Image.network(
                    imageUrl,
                    fit: BoxFit.cover,
                    alignment: Alignment.center,
                    headers: _imageHeaders,
                    errorBuilder: (context, error, stackTrace) {
                      return const _BannerImageFallback();
                    },
                  )
                else
                  const _BannerImageFallback(),
                if (hasCopy)
                  DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                        colors: [
                          Colors.black.withValues(alpha: 0.68),
                          Colors.black.withValues(alpha: 0.30),
                          Colors.black.withValues(alpha: 0.02),
                        ],
                      ),
                    ),
                  ),
                if (hasCopy)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(18, 16, 18, 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (badge.isNotEmpty) ...[
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.16),
                              borderRadius: BorderRadius.circular(999),
                              border: Border.all(
                                color: Colors.white.withValues(alpha: 0.28),
                              ),
                            ),
                            child: Text(
                              badge,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.manrope(
                                fontSize: 11,
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                        ],
                        if (title.isNotEmpty)
                          SizedBox(
                            width: textWidth,
                            child: Text(
                              title,
                              maxLines: compact ? 2 : 3,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.sora(
                                fontSize: compact ? 20 : 23,
                                height: 1.08,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        if (subtitle.isNotEmpty) ...[
                          const SizedBox(height: 6),
                          SizedBox(
                            width: textWidth,
                            child: Text(
                              subtitle,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.manrope(
                                fontSize: 12,
                                height: 1.35,
                                fontWeight: FontWeight.w600,
                                color: Colors.white.withValues(alpha: 0.88),
                              ),
                            ),
                          ),
                        ],
                        const Spacer(),
                        SizedBox(
                          height: 38,
                          child: FilledButton(
                            onPressed: onTap,
                            style: FilledButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: _primary,
                              elevation: 0,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                ConstrainedBox(
                                  constraints: BoxConstraints(
                                    maxWidth: ctaTextWidth,
                                  ),
                                  child: Text(
                                    cta,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: GoogleFonts.manrope(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 6),
                                const Icon(
                                  Icons.arrow_forward_rounded,
                                  size: 16,
                                ),
                              ],
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
      },
    );
  }
}

class _BannerImageFallback extends StatelessWidget {
  const _BannerImageFallback();

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF4B78FF), Color(0xFF7367FF)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Align(
        alignment: Alignment.centerRight,
        child: Padding(
          padding: const EdgeInsets.only(right: 26),
          child: Icon(
            Icons.devices_rounded,
            color: Colors.white.withValues(alpha: 0.62),
            size: 70,
          ),
        ),
      ),
    );
  }
}

class _HeroDeviceImage extends StatelessWidget {
  const _HeroDeviceImage({
    required this.product,
    required this.width,
    required this.height,
    required this.icon,
    required this.frameColor,
    required this.surfaceColor,
    this.isPhone = false,
  });

  final Product? product;
  final double width;
  final double height;
  final IconData icon;
  final Color frameColor;
  final Color surfaceColor;
  final bool isPhone;

  @override
  Widget build(BuildContext context) {
    final imageUrl = product?.imageUrl;
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(isPhone ? 22 : 24),
        boxShadow: [
          BoxShadow(color: _shadow, blurRadius: 12, offset: const Offset(0, 8)),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(isPhone ? 22 : 24),
        child: DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [surfaceColor, surfaceColor.withValues(alpha: 0.84)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
            border: Border.all(color: Colors.white),
          ),
          child: imageUrl == null || imageUrl.isEmpty
              ? Center(
                  child: Icon(icon, size: isPhone ? 34 : 58, color: frameColor),
                )
              : Padding(
                  padding: EdgeInsets.all(isPhone ? 10 : 12),
                  child: Image.network(
                    imageUrl,
                    fit: BoxFit.contain,
                    alignment: Alignment.center,
                    headers: _imageHeaders,
                    errorBuilder: (context, error, stackTrace) {
                      return Center(
                        child: Icon(
                          icon,
                          size: isPhone ? 34 : 58,
                          color: frameColor,
                        ),
                      );
                    },
                  ),
                ),
        ),
      ),
    );
  }
}

class _CategoryShowcaseStrip extends StatelessWidget {
  const _CategoryShowcaseStrip({
    required this.categories,
    required this.iconFor,
    required this.onRepairTap,
  });

  final List<Category> categories;
  final IconData Function(String) iconFor;
  final VoidCallback onRepairTap;

  @override
  Widget build(BuildContext context) {
    final cards = categories.take(3).toList();

    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = constraints.maxWidth >= 300 ? 3 : 2;
        return GridView.builder(
          itemCount: cards.length,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: columns,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: columns == 3 ? 0.84 : 1.42,
          ),
          itemBuilder: (context, index) {
            final category = cards[index];
            final isRepair =
                category.name.toLowerCase().contains('repair') ||
                category.name.toLowerCase().contains('service');
            return _CategorySpotlightCard(
              category: category,
              icon: iconFor(category.name),
              accent: index == 0
                  ? const Color(0xFF4B78FF)
                  : index == 1
                  ? const Color(0xFF6D62FF)
                  : const Color(0xFF3B63FF),
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
              ctaLabel: isRepair ? 'Book Now' : 'Shop Now',
            );
          },
        );
      },
    );
  }
}

class _CategorySpotlightCard extends StatelessWidget {
  const _CategorySpotlightCard({
    required this.category,
    required this.icon,
    required this.accent,
    required this.onTap,
    required this.ctaLabel,
  });

  final Category category;
  final IconData icon;
  final Color accent;
  final VoidCallback onTap;
  final String ctaLabel;

  @override
  Widget build(BuildContext context) {
    final imageUrl = category.imageUrl;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(24),
        child: Ink(
          decoration: BoxDecoration(
            color: _surface(context),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: _cardBorder(context)),
            boxShadow: const [
              BoxShadow(color: _shadow, blurRadius: 12, offset: Offset(0, 6)),
            ],
          ),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final compact = constraints.maxWidth < 130;
              final imageSize = compact ? 46.0 : 74.0;
              final iconSize = compact ? 22.0 : 30.0;
              final compactActionLabel = ctaLabel.toLowerCase().contains('book')
                  ? 'Book'
                  : 'Shop';
              final actionLabel = compact ? compactActionLabel : ctaLabel;
              final visual = Container(
                width: imageSize,
                height: imageSize,
                decoration: BoxDecoration(
                  color: _surfaceAlt(context),
                  borderRadius: BorderRadius.circular(compact ? 14 : 16),
                ),
                padding: EdgeInsets.all(compact ? 6 : 8),
                child: imageUrl == null || imageUrl.isEmpty
                    ? Icon(icon, color: accent, size: iconSize)
                    : Image.network(
                        imageUrl,
                        fit: BoxFit.contain,
                        headers: _imageHeaders,
                        errorBuilder: (context, error, stackTrace) {
                          return Icon(icon, color: accent, size: iconSize);
                        },
                      ),
              );

              if (compact) {
                return Padding(
                  padding: const EdgeInsets.all(10),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      visual,
                      const SizedBox(height: 8),
                      Text(
                        category.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.center,
                        style: GoogleFonts.sora(
                          fontSize: 12.5,
                          height: 1.15,
                          fontWeight: FontWeight.w700,
                          color: _textPrimary(context),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Flexible(
                            child: Text(
                              actionLabel,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.manrope(
                                fontSize: 11.5,
                                fontWeight: FontWeight.w800,
                                color: accent,
                              ),
                            ),
                          ),
                          const SizedBox(width: 4),
                          Icon(
                            Icons.arrow_forward_rounded,
                            color: accent,
                            size: 14,
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              }

              return Padding(
                padding: const EdgeInsets.all(14),
                child: Row(
                  children: [
                    visual,
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            category.name,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.sora(
                              fontSize: 14,
                              height: 1.15,
                              fontWeight: FontWeight.w700,
                              color: _textPrimary(context),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Flexible(
                                child: Text(
                                  actionLabel,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: GoogleFonts.manrope(
                                    fontSize: 12.5,
                                    fontWeight: FontWeight.w800,
                                    color: accent,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 6),
                              Icon(
                                Icons.arrow_forward_rounded,
                                color: accent,
                                size: 16,
                              ),
                            ],
                          ),
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
    );
  }
}

class _ValueHighlights extends StatelessWidget {
  const _ValueHighlights();

  @override
  Widget build(BuildContext context) {
    const items = [
      (
        icon: Icons.verified_user_outlined,
        title: '100% Original',
        subtitle: 'Genuine Apple products',
        color: Color(0xFF406BFF),
      ),
      (
        icon: Icons.workspace_premium_outlined,
        title: 'Warranty',
        subtitle: 'Official product support',
        color: Color(0xFF7B52FF),
      ),
      (
        icon: Icons.local_shipping_outlined,
        title: 'Fast Delivery',
        subtitle: 'Quick and safe shipping',
        color: Color(0xFF12A150),
      ),
      (
        icon: Icons.headset_mic_outlined,
        title: 'Expert Support',
        subtitle: 'Service team ready to help',
        color: Color(0xFFFF6A1A),
      ),
    ];

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 18),
      decoration: BoxDecoration(
        color: _surface(context),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: _cardBorder(context)),
        boxShadow: const [
          BoxShadow(color: _shadow, blurRadius: 14, offset: Offset(0, 8)),
        ],
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          if (constraints.maxWidth < 390) {
            return GridView.builder(
              itemCount: items.length,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                childAspectRatio: 1.2,
              ),
              itemBuilder: (context, index) {
                final item = items[index];
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(
                        color: item.color.withValues(alpha: 0.10),
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: Icon(item.icon, color: item.color),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      item.title,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.manrope(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w800,
                        color: _textPrimary(context),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      item.subtitle,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.manrope(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w600,
                        color: _textMuted(context),
                        height: 1.45,
                      ),
                    ),
                  ],
                );
              },
            );
          }

          return Row(
            children: List.generate(items.length * 2 - 1, (index) {
              if (index.isOdd) {
                return Container(
                  width: 1,
                  height: 112,
                  color: _cardBorder(context),
                  margin: const EdgeInsets.symmetric(horizontal: 8),
                );
              }

              final item = items[index ~/ 2];
              return Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(
                        color: item.color.withValues(alpha: 0.10),
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: Icon(item.icon, color: item.color),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      item.title,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.manrope(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w800,
                        color: _textPrimary(context),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      item.subtitle,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.manrope(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w600,
                        color: _textMuted(context),
                        height: 1.45,
                      ),
                    ),
                  ],
                ),
              );
            }),
          );
        },
      ),
    );
  }
}

class _RepairCallout extends StatelessWidget {
  const _RepairCallout({required this.onBookRepair});

  final VoidCallback onBookRepair;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final compact = constraints.maxWidth < 380;
        final textBlock = Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'We Fix. You Relax.',
              style: GoogleFonts.manrope(
                color: _primary,
                fontSize: 15,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Professional Repair\nYou Can Trust.',
              style: GoogleFonts.sora(
                fontSize: 26,
                height: 1.18,
                fontWeight: FontWeight.w700,
                color: _textPrimary(context),
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'From screen replacement to hardware issues, our team is ready to help with fast diagnosis and quality parts.',
              style: GoogleFonts.manrope(
                fontSize: 13.5,
                height: 1.6,
                fontWeight: FontWeight.w600,
                color: _textMuted(context),
              ),
            ),
            const SizedBox(height: 18),
            FilledButton(
              onPressed: onBookRepair,
              style: FilledButton.styleFrom(
                backgroundColor: _primary,
                foregroundColor: Colors.white,
                elevation: 0,
                padding: const EdgeInsets.symmetric(
                  horizontal: 18,
                  vertical: 16,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Book a Repair',
                    style: GoogleFonts.manrope(fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(width: 8),
                  const Icon(Icons.arrow_forward_rounded, size: 18),
                ],
              ),
            ),
          ],
        );

        final artBlock = SizedBox(
          width: compact ? double.infinity : 132,
          child: AspectRatio(
            aspectRatio: compact ? 1.6 : 0.9,
            child: Stack(
              alignment: Alignment.center,
              children: [
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    width: 98,
                    height: 98,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.55),
                      borderRadius: BorderRadius.circular(28),
                    ),
                  ),
                ),
                Positioned(
                  bottom: 18,
                  left: compact ? 30 : 8,
                  child: Transform.rotate(
                    angle: -0.48,
                    child: Container(
                      width: 54,
                      height: 92,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: const [
                          BoxShadow(
                            color: _shadow,
                            blurRadius: 12,
                            offset: Offset(0, 8),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.phone_iphone_rounded,
                        color: _primary,
                        size: 30,
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: 34,
                  right: compact ? 30 : 8,
                  child: Transform.rotate(
                    angle: 0.24,
                    child: Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        color: _primary,
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: _primary.withValues(alpha: 0.24),
                            blurRadius: 16,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.build_rounded,
                        color: Colors.white,
                        size: 28,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );

        return Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(32),
            gradient: const LinearGradient(
              colors: [Color(0xFFEFF4FF), Color(0xFFE6EEFF), Color(0xFFF5F8FF)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            border: Border.all(color: _cardBorder(context)),
          ),
          child: compact
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [textBlock, const SizedBox(height: 16), artBlock],
                )
              : Row(
                  children: [
                    Expanded(child: textBlock),
                    const SizedBox(width: 12),
                    artBlock,
                  ],
                ),
        );
      },
    );
  }
}

class _SearchSuggestionList extends StatelessWidget {
  const _SearchSuggestionList({
    required this.items,
    required this.query,
    required this.onSelect,
    required this.isLoading,
    required this.onSearchQuery,
  });

  final List<SearchSuggestion> items;
  final String query;
  final ValueChanged<SearchSuggestion> onSelect;
  final bool isLoading;
  final VoidCallback onSearchQuery;

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: _surface(context),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: _cardBorder(context)),
        ),
        child: Row(
          children: [
            SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
            SizedBox(width: 12),
            Text(
              'Loading suggestions...',
              style: TextStyle(
                color: _textMuted(context),
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: _surface(context),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _cardBorder(context)),
      ),
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: items.length + 1,
        separatorBuilder: (_, _) =>
            Divider(height: 1, color: _cardBorder(context)),
        itemBuilder: (context, index) {
          if (index == 0) {
            return InkWell(
              onTap: onSearchQuery,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 10,
                ),
                child: Row(
                  children: [
                    const Icon(Icons.search_rounded, color: _primary, size: 20),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Search "$query"',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          color: _textPrimary(context),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          if (items.isEmpty) {
            return Padding(
              padding: const EdgeInsets.all(12),
              child: Text(
                'No suggestions for "$query".',
                style: TextStyle(
                  color: _textMuted(context),
                  fontWeight: FontWeight.w600,
                ),
              ),
            );
          }

          final suggestion = items[index - 1];
          return InkWell(
            onTap: () => onSelect(suggestion),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              child: Row(
                children: [
                  Container(
                    height: 38,
                    width: 38,
                    decoration: BoxDecoration(
                      color: _surfaceAlt(context),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      _searchIconFor(suggestion.type),
                      color: _primary,
                      size: 18,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          suggestion.label,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            color: _textPrimary(context),
                          ),
                        ),
                        if (suggestion.subtitle != null &&
                            suggestion.subtitle!.trim().isNotEmpty) ...[
                          const SizedBox(height: 2),
                          Text(
                            suggestion.subtitle!,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 11.5,
                              color: _textMuted(context),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    _labelForSuggestionType(suggestion.type),
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      color: _primary,
                      fontSize: 11,
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

class _SearchDiscoveryList extends StatelessWidget {
  const _SearchDiscoveryList({
    required this.recentSearches,
    required this.popularSearches,
    required this.onSelect,
  });

  final List<String> recentSearches;
  final List<String> popularSearches;
  final ValueChanged<String> onSelect;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: _surface(context),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _cardBorder(context)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (recentSearches.isNotEmpty) ...[
            Text(
              'Recent searches',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: _textPrimary(context),
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: recentSearches.map((item) {
                return _SearchChip(
                  icon: Icons.history_rounded,
                  label: item,
                  onTap: () => onSelect(item),
                );
              }).toList(),
            ),
            const SizedBox(height: 14),
          ],
          Text(
            'Popular searches',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: _textPrimary(context),
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: popularSearches.map((item) {
              return _SearchChip(
                icon: Icons.trending_up_rounded,
                label: item,
                onTap: () => onSelect(item),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

class _SearchChip extends StatelessWidget {
  const _SearchChip({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(999),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
        decoration: BoxDecoration(
          color: _surfaceAlt(context),
          borderRadius: BorderRadius.circular(999),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14, color: _primary),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: _textPrimary(context),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

IconData _searchIconFor(String type) {
  switch (type.toLowerCase()) {
    case 'product':
      return Icons.inventory_2_outlined;
    case 'accessory':
      return Icons.cable_rounded;
    case 'brand':
      return Icons.sell_outlined;
    case 'category':
      return Icons.category_outlined;
    case 'repair':
      return Icons.build_circle_outlined;
    default:
      return Icons.search_rounded;
  }
}

String _labelForSuggestionType(String type) {
  switch (type.toLowerCase()) {
    case 'product':
      return 'Product';
    case 'accessory':
      return 'Accessory';
    case 'brand':
      return 'Brand';
    case 'category':
      return 'Category';
    case 'repair':
      return 'Repair';
    default:
      return 'Search';
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
    final badge = _productBadgeText(product);
    final hasDiscount = product.hasDiscount;
    final originalPrice = product.price;
    final discountedPrice = product.salePrice;

    return Material(
      color: _surface(context),
      borderRadius: BorderRadius.circular(22),
      child: InkWell(
        borderRadius: BorderRadius.circular(22),
        onTap: onOpen,
        child: Container(
          padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(22),
            color: _surface(context),
            border: Border.all(color: _cardBorder(context)),
            boxShadow: const [
              BoxShadow(color: _shadow, blurRadius: 12, offset: Offset(0, 6)),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  if (badge != null)
                    Expanded(
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: _DiscountBadge(text: badge),
                      ),
                    )
                  else
                    const Spacer(),
                  _FavoriteButton(product: product),
                ],
              ),
              const SizedBox(height: 8),
              Expanded(
                flex: 8,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.transparent,
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: imageUrl == null || imageUrl.isEmpty
                      ? const Icon(
                          Icons.image_outlined,
                          color: _primary,
                          size: 38,
                        )
                      : Image.network(
                          imageUrl,
                          fit: BoxFit.contain,
                          alignment: Alignment.center,
                          cacheWidth: 420,
                          headers: _imageHeaders,
                          errorBuilder: (context, error, stackTrace) => Icon(
                            Icons.broken_image_outlined,
                            color: _textMuted(context),
                            size: 42,
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                product.name,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.sora(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: _textPrimary(context),
                  height: 1.25,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                _homeProductSpecs(product),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.manrope(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w600,
                  color: _textMuted(context),
                ),
              ),
              const SizedBox(height: 10),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '\$${discountedPrice.toStringAsFixed(0)}',
                          style: GoogleFonts.sora(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: hasDiscount
                                ? _danger
                                : _textPrimary(context),
                          ),
                        ),
                        if (hasDiscount && discountedPrice < originalPrice) ...[
                          const SizedBox(height: 2),
                          Text(
                            '\$${originalPrice.toStringAsFixed(2)}',
                            style: GoogleFonts.manrope(
                              fontSize: 11.5,
                              color: _textMuted(context),
                              decoration: TextDecoration.lineThrough,
                            ),
                          ),
                        ] else
                          Text(
                            'In stock',
                            style: GoogleFonts.manrope(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: _success,
                            ),
                          ),
                      ],
                    ),
                  ),
                  _AddCircleButton(onTap: onAdd),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

Product? _firstProductMatch(List<Product> products, List<String> keywords) {
  for (final product in products) {
    final haystack = [
      product.name,
      product.categoryName ?? '',
      product.brand ?? '',
      product.tag ?? '',
    ].join(' ').toLowerCase();
    if (keywords.any(haystack.contains)) {
      return product;
    }
  }
  return products.isEmpty ? null : products.first;
}

List<Category> _selectHomepageCategories(List<Category> categories) {
  final selected = <Category>[];
  final usedIds = <int>{};

  Category? pick(List<String> keywords) {
    for (final category in categories) {
      if (usedIds.contains(category.id)) continue;
      final haystack = [
        category.name,
        category.slug ?? '',
      ].join(' ').toLowerCase();
      if (keywords.any(haystack.contains)) {
        return category;
      }
    }
    return null;
  }

  for (final keywords in const [
    ['mac', 'laptop'],
    ['iphone', 'phone'],
    ['repair', 'service'],
  ]) {
    final match = pick(keywords);
    if (match != null) {
      usedIds.add(match.id);
      selected.add(match);
    }
  }

  for (final category in categories) {
    if (selected.length >= 3) break;
    if (usedIds.add(category.id)) {
      selected.add(category);
    }
  }

  return selected.take(3).toList();
}

String _homeProductSpecs(Product product) {
  final parts = <String>[];

  final firstRam = product.ramOptions.isNotEmpty
      ? product.ramOptions.first.trim()
      : null;
  final storage = product.storageCapacity?.trim();
  final ssd = product.ssd?.trim();
  final brand = product.brand?.trim();

  if (firstRam != null && firstRam.isNotEmpty) parts.add(firstRam);
  if (storage != null && storage.isNotEmpty) {
    parts.add(storage);
  } else if (ssd != null && ssd.isNotEmpty) {
    parts.add(ssd);
  }
  if (brand != null && brand.isNotEmpty) parts.add(brand);

  if (parts.isEmpty) {
    return product.categoryName?.trim().isNotEmpty == true
        ? product.categoryName!.trim()
        : 'Premium device';
  }

  return parts.take(2).join(' | ');
}

String _formatTagLabel(String raw) {
  return raw
      .replaceAll(RegExp(r'[_-]+'), ' ')
      .split(' ')
      .where((part) => part.isNotEmpty)
      .map(
        (part) => '${part[0].toUpperCase()}${part.substring(1).toLowerCase()}',
      )
      .join(' ');
}

String? _discountLabel(Product product) {
  final discount = product.discount;
  if (discount == null || discount <= 0) return null;
  final base = product.price;
  if (base <= 0) return null;
  final percent = (discount / base * 100).round().clamp(1, 90);
  return '$percent% OFF';
}

String? _productBadgeText(Product product) {
  final discount = _discountLabel(product);
  if (discount != null) return discount;

  final tag = product.tag?.trim();
  if (tag != null && tag.isNotEmpty) {
    return _formatTagLabel(tag);
  }

  if (product.createdAt != null &&
      DateTime.now().difference(product.createdAt!).inDays <= 30) {
    return 'New';
  }

  return 'Featured';
}

class _DiscountBadge extends StatelessWidget {
  const _DiscountBadge({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    final lower = text.toLowerCase();
    final foreground = lower.contains('sale')
        ? const Color(0xFFFF7A1A)
        : lower.contains('hot')
        ? const Color(0xFFEF4444)
        : lower.contains('new')
        ? const Color(0xFF22A06B)
        : _primary;
    final background = foreground.withValues(alpha: 0.12);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        text,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: GoogleFonts.manrope(
          color: foreground,
          fontSize: 10,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

class _FavoriteButton extends StatelessWidget {
  const _FavoriteButton({required this.product});

  final Product product;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: FavoriteService.instance,
      builder: (context, _) {
        final isFavorite = FavoriteService.instance.contains(product);
        return InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: () => FavoriteService.instance.toggle(product),
          child: Container(
            height: 34,
            width: 34,
            decoration: BoxDecoration(
              color: _surfaceAlt(context),
              borderRadius: BorderRadius.circular(17),
              border: Border.all(color: _cardBorder(context)),
            ),
            child: Icon(
              isFavorite ? Icons.favorite : Icons.favorite_border,
              size: 18,
              color: isFavorite ? const Color(0xFFE11D48) : _textMuted(context),
            ),
          ),
        );
      },
    );
  }
}

class _AddCircleButton extends StatelessWidget {
  const _AddCircleButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        height: 42,
        width: 42,
        decoration: BoxDecoration(
          color: _primarySoft,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: _primary.withValues(alpha: 0.08)),
          boxShadow: [
            BoxShadow(
              color: _primary.withValues(alpha: 0.12),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: const Icon(
          Icons.shopping_cart_checkout_rounded,
          size: 20,
          color: _primary,
        ),
      ),
    );
  }
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
        color: _surface(context),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _cardBorder(context)),
      ),
      child: Column(
        children: [
          Icon(icon, color: _textMuted(context)),
          const SizedBox(height: 8),
          Text(title, style: TextStyle(color: _textMuted(context))),
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
                  color: _surfaceAlt(context),
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              const SizedBox(height: 8),
              Container(width: 50, height: 8, color: _surfaceAlt(context)),
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
    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = constraints.maxWidth >= 720 ? 3 : 2;
        return GridView.builder(
          itemCount: columns == 3 ? 6 : 4,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: columns,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: columns == 3 ? 0.72 : 0.64,
          ),
          itemBuilder: (context, index) {
            return Container(
              decoration: BoxDecoration(
                color: _surfaceAlt(context),
                borderRadius: BorderRadius.circular(16),
              ),
            );
          },
        );
      },
    );
  }
}

class _IconCircleButton extends StatelessWidget {
  const _IconCircleButton({
    required this.icon,
    required this.onTap,
    this.badgeCount,
  });

  final IconData icon;
  final VoidCallback onTap;
  final int? badgeCount;

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: onTap,
          child: Container(
            height: 46,
            width: 46,
            decoration: BoxDecoration(
              color: _surface(context),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: _cardBorder(context)),
              boxShadow: const [
                BoxShadow(color: _shadow, blurRadius: 12, offset: Offset(0, 6)),
              ],
            ),
            child: Icon(icon, size: 20, color: _textPrimary(context)),
          ),
        ),
        if ((badgeCount ?? 0) > 0)
          Positioned(
            top: -2,
            right: -2,
            child: Container(
              constraints: const BoxConstraints(minWidth: 19, minHeight: 19),
              padding: const EdgeInsets.symmetric(horizontal: 5),
              decoration: BoxDecoration(
                color: _primary,
                borderRadius: BorderRadius.circular(999),
                border: Border.all(color: Colors.white, width: 2),
              ),
              alignment: Alignment.center,
              child: Text(
                '$badgeCount',
                style: GoogleFonts.manrope(
                  color: Colors.white,
                  fontSize: 9,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),
      ],
    );
  }
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
        return Stack(
          clipBehavior: Clip.none,
          children: [
            _IconCircleButton(icon: Icons.shopping_cart_outlined, onTap: onTap),
            if (count > 0)
              Positioned(
                top: -2,
                right: -2,
                child: Container(
                  constraints: const BoxConstraints(
                    minWidth: 19,
                    minHeight: 19,
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 5),
                  decoration: BoxDecoration(
                    color: _primary,
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    '$count',
                    style: GoogleFonts.manrope(
                      color: Colors.white,
                      fontSize: 9,
                      fontWeight: FontWeight.w800,
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

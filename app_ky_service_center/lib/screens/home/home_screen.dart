import 'dart:async';
import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import '../../l10n/app_localizations.dart';
import '../../models/banner_item.dart';
import '../../models/category.dart';
import '../../models/product.dart';
import '../../models/user_profile.dart';
import '../../services/api_service.dart';
import '../../services/cart_service.dart';
import '../../widgets/auth_guard.dart';
import '../../widgets/cart_added_bottom_bar.dart';
import '../cart/cart_screen.dart';
import '../categories/categories_screen.dart';
import '../categories/category_products_screen.dart';
import '../notifications/notification_screen.dart';
import '../products/all_products_screen.dart';
import '../products/product_detail_screen.dart';
import '../search/search_results_screen.dart';
import 'widgets/home_app_header.dart';
import 'widgets/home_category_showcase_strip.dart';
import 'widgets/home_colors.dart';
import 'widgets/home_flash_product_card.dart';
import 'widgets/home_hero_showcase.dart';
import 'widgets/home_loading_and_empty_states.dart';
import 'widgets/home_search_input.dart';
import 'widgets/home_section_header.dart';
import 'widgets/home_value_highlights.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final PageController _bannerController = PageController();

  Timer? _bannerTimer;
  int _bannerIndex = 0;
  bool _isBannerAutoAnimating = false;
  bool _isBannerUserInteracting = false;

  bool _isLoadingBanner = false;
  List<BannerItem> _banners = [];
  late Future<List<Category>> _categoriesFuture;
  late Future<List<Product>> _productsFuture;
  late Future<List<Product>> _hotSaleFuture;
  late Future<List<Product>> _topSellerFuture;
  late Future<List<Product>> _promotionFuture;
  Future<UserProfile?> _profileFuture = ApiService.getUserProfile();

  @override
  void initState() {
    super.initState();
    _categoriesFuture = _loadCategoriesSafe();
    _productsFuture = _loadProductsSafe();
    _hotSaleFuture = _loadTaggedProductsSafe('HOT_SALE');
    _topSellerFuture = _loadTaggedProductsSafe('TOP_SELLER');
    _promotionFuture = _loadTaggedProductsSafe('PROMOTION');
    _loadBanners();
    ApiService.profileVersionListenable.addListener(_handleProfileUpdated);
  }

  @override
  void dispose() {
    ApiService.profileVersionListenable.removeListener(_handleProfileUpdated);
    _bannerTimer?.cancel();
    _bannerController.dispose();
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
      _categoriesFuture = _loadCategoriesSafe(forceRefresh: true);
      _productsFuture = _loadProductsSafe(forceRefresh: true);
      _hotSaleFuture = _loadTaggedProductsSafe('HOT_SALE', forceRefresh: true);
      _topSellerFuture =
          _loadTaggedProductsSafe('TOP_SELLER', forceRefresh: true);
      _promotionFuture =
          _loadTaggedProductsSafe('PROMOTION', forceRefresh: true);
      _profileFuture = ApiService.getUserProfile();
    });
    await Future.wait([
      _categoriesFuture,
      _productsFuture,
      _hotSaleFuture,
      _topSellerFuture,
      _promotionFuture,
    ]);
  }

  Future<void> _clearImageCache() async {
    final cache = PaintingBinding.instance.imageCache;
    cache.clear();
    cache.clearLiveImages();
  }

  Future<List<Category>> _loadCategoriesSafe({bool forceRefresh = false}) async {
    try {
      return await ApiService.fetchCategories(forceRefresh: forceRefresh);
    } catch (error) {
      debugPrint('[HomeScreen] categories load failed: $error');
      return const [];
    }
  }

  Future<List<Product>> _loadProductsSafe({bool forceRefresh = false}) async {
    try {
      return await ApiService.fetchProducts(forceRefresh: forceRefresh);
    } catch (error) {
      debugPrint('[HomeScreen] products load failed: $error');
      rethrow;
    }
  }

  /// Loads products carrying an admin-set tag (HOT_SALE, TOP_SELLER,
  /// PROMOTION) via the server-side tag filter, so tagged products show
  /// even when they are not among the newest items. Falls back to
  /// filtering the general product list if the tag request fails.
  Future<List<Product>> _loadTaggedProductsSafe(
    String tag, {
    bool forceRefresh = false,
  }) async {
    try {
      final products = await ApiService.fetchProducts(
        tag: tag,
        forceRefresh: forceRefresh,
      );
      // Older backends ignore the tag parameter and return every product,
      // so re-filter locally in all cases.
      final matched = products
          .where((product) => (product.tag ?? '').toUpperCase() == tag)
          .toList();
      if (matched.isNotEmpty) return matched;
    } catch (error) {
      debugPrint('[HomeScreen] $tag products load failed: $error');
    }

    try {
      final all = await _productsFuture;
      return all
          .where((product) => (product.tag ?? '').toUpperCase() == tag)
          .toList();
    } catch (_) {
      return const [];
    }
  }

  /// Horizontal carousel for one admin tag (Hot Sale, Top Seller,
  /// Promotion). Hidden entirely when no product carries the tag.
  Widget _buildTagSection({
    required String title,
    required Future<List<Product>> future,
    bool showSkeleton = true,
  }) {
    return FutureBuilder<List<Product>>(
      future: future,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          if (!showSkeleton) return const SizedBox.shrink();
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              HomeSectionHeader(title: title),
              const SizedBox(height: 14),
              const HomeProductsSkeleton(),
              const SizedBox(height: 22),
            ],
          );
        }
        final products = snapshot.data ?? const <Product>[];
        if (products.isEmpty) {
          return const SizedBox.shrink();
        }
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            HomeSectionHeader(title: title),
            const SizedBox(height: 14),
            SizedBox(
              height: 258,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: products.length,
                separatorBuilder: (_, _) => const SizedBox(width: 14),
                itemBuilder: (context, index) {
                  final product = products[index];
                  return SizedBox(
                    width: 165,
                    child: HomeFlashProductCard(
                      product: product,
                      onOpen: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) =>
                                ProductDetailScreen(product: product),
                          ),
                        );
                      },
                      onAdd: () => _handleAddToCart(product),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 22),
          ],
        );
      },
    );
  }

  void _openSearch() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => const SearchResultsScreen(
          initialQuery: '',
          autofocus: true,
        ),
      ),
    );
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
      return HugeIcons.strokeRoundedSmartPhone01;
    }
    if (value.contains('mac') || value.contains('laptop')) {
      return HugeIcons.strokeRoundedLaptop;
    }
    if (value.contains('audio') || value.contains('headphone')) {
      return HugeIcons.strokeRoundedHeadphones;
    }
    if (value.contains('repair') || value.contains('service')) {
      return HugeIcons.strokeRoundedWrench01;
    }
    if (value.contains('access')) {
      return HugeIcons.strokeRoundedWatch01;
    }
    return HugeIcons.strokeRoundedSquare01;
  }

  void _handleAddToCart(Product product) {
    _addToCart(product);
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: homeBg(context),
      body: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: homeGradient(context),
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: RefreshIndicator(
            color: homePrimary,
            backgroundColor: homeSurface(context),
            onRefresh: _refresh,
            child: ListView(
              physics: const BouncingScrollPhysics(
                parent: AlwaysScrollableScrollPhysics(),
              ),
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 34),
              children: [
                FutureBuilder<UserProfile?>(
                  future: _profileFuture,
                  builder: (context, snapshot) {
                    final name = snapshot.data?.displayName.trim() ?? 'User';
                    final safeName = name.isNotEmpty ? name : 'User';
                    return HomeAppHeader(
                      title: 'KY-App',
                      welcomeName: safeName,
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
                const SizedBox(height: 14),
                HomeSearchInput(
                  hintText: l.searchProducts,
                  onTap: _openSearch,
                ),
                const SizedBox(height: 14),
                FutureBuilder<List<Product>>(
                  future: _productsFuture,
                  builder: (context, snapshot) {
                    return HomeHeroShowcase(
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
                                AllProductsScreen(title: l.allProducts),
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
                      return const HomeCategorySkeleton();
                    }
                    final categories = snapshot.data ?? const [];
                    if (categories.isEmpty) {
                      return const SizedBox.shrink();
                    }
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        HomeSectionHeader(
                          title: l.categories,
                          actionLabel: l.viewAll,
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) =>
                                    const CategoriesScreen(),
                              ),
                            );
                          },
                        ),
                        const SizedBox(height: 14),
                        HomeCategoryShowcaseStrip(
                          categories: categories,
                          iconFor: _iconForCategory,
                          onRepairTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => const SearchResultsScreen(
                                  initialQuery: 'repair',
                                ),
                              ),
                            );
                          },
                        ),
                      ],
                    );
                  },
                ),
                const SizedBox(height: 22),
                _buildTagSection(title: l.hotSale, future: _hotSaleFuture),
                _buildTagSection(
                  title: l.topSeller,
                  future: _topSellerFuture,
                  showSkeleton: false,
                ),
                _buildTagSection(
                  title: l.promotion,
                  future: _promotionFuture,
                  showSkeleton: false,
                ),
                const HomeValueHighlights(),
                const SizedBox(height: 24),
                FutureBuilder<List<Category>>(
                  future: _categoriesFuture,
                  builder: (context, categorySnapshot) {
                    if (categorySnapshot.connectionState ==
                        ConnectionState.waiting) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          HomeSectionHeader(title: l.featuredProducts),
                          const SizedBox(height: 14),
                          const HomeProductsSkeleton(),
                        ],
                      );
                    }
                    final categories = categorySnapshot.data ?? const [];
                    if (categories.isEmpty) {
                      return const SizedBox.shrink();
                    }

                    return FutureBuilder<List<Product>>(
                      future: _productsFuture,
                      builder: (context, productSnapshot) {
                        if (productSnapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const HomeProductsSkeleton();
                        }
                        if (productSnapshot.hasError) {
                          return HomeSimpleState(
                            icon: HugeIcons.strokeRoundedWifiOff01,
                            title: l.somethingWentWrong,
                          );
                        }
                        final allProducts = productSnapshot.data ?? const [];

                        final sections = <Widget>[];
                        for (final category in categories) {
                          final items = allProducts
                              .where(
                                (product) => product.categoryId == category.id,
                              )
                              .take(4)
                              .toList();
                          if (items.isEmpty) continue;

                          sections.add(
                            Padding(
                              padding: const EdgeInsets.only(bottom: 24),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  HomeSectionHeader(
                                    title: category.name,
                                    actionLabel: l.viewAll,
                                    onTap: () {
                                      Navigator.of(context).push(
                                        MaterialPageRoute(
                                          builder: (_) => CategoryProductsScreen(
                                            categoryId: category.id,
                                            categoryName: category.name,
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                  const SizedBox(height: 14),
                                  GridView.builder(
                                    itemCount: items.length,
                                    shrinkWrap: true,
                                    physics:
                                        const NeverScrollableScrollPhysics(),
                                    gridDelegate:
                                        const SliverGridDelegateWithFixedCrossAxisCount(
                                          crossAxisCount: 2,
                                          mainAxisSpacing: 14,
                                          crossAxisSpacing: 14,
                                          childAspectRatio: 0.64,
                                        ),
                                    itemBuilder: (context, index) {
                                      final product = items[index];
                                      return HomeFlashProductCard(
                                        product: product,
                                        onOpen: () {
                                          Navigator.of(context).push(
                                            MaterialPageRoute(
                                              builder: (_) =>
                                                  ProductDetailScreen(
                                                product: product,
                                              ),
                                            ),
                                          );
                                        },
                                        onAdd: () => _handleAddToCart(product),
                                      );
                                    },
                                  ),
                                ],
                              ),
                            ),
                          );
                        }

                        if (sections.isEmpty) {
                          return HomeSimpleState(
                            icon: HugeIcons.strokeRoundedPackage,
                            title: l.noData,
                          );
                        }

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: sections,
                        );
                      },
                    );
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

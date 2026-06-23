import 'dart:async';

import 'package:flutter/material.dart';
import 'package:skeletonizer/skeletonizer.dart';

import '../../l10n/app_localizations.dart';
import '../../models/product.dart';
import '../../models/search_suggestion.dart';
import '../../services/api_service.dart';
import '../../services/cart_service.dart';
import '../../services/search_history_service.dart';
import '../../widgets/auth_guard.dart';
import '../../widgets/cart_added_bottom_bar.dart';
import '../cart/cart_screen.dart';
import '../search/search_results_screen.dart';
import 'widgets/all_products_card.dart';
import 'widgets/all_products_cart_icon_button.dart';
import 'widgets/all_products_common.dart';
import 'widgets/all_products_search_field.dart';
import 'widgets/all_products_search_suggestions.dart';
import 'widgets/all_products_states.dart';
import 'widgets/all_products_view_toggle.dart';

class AllProductsScreen extends StatefulWidget {
  const AllProductsScreen({super.key, this.title});

  final String? title;

  @override
  State<AllProductsScreen> createState() => _AllProductsScreenState();
}

class _AllProductsScreenState extends State<AllProductsScreen> {
  late Future<List<Product>> _future;
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  Timer? _searchDebounce;
  bool _isGrid = true;
  bool _isLoadingSearchSuggestions = false;
  List<SearchSuggestion> _searchSuggestions = const [];
  List<String> _recentSearches = const [];

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
    _future = _fetch();
    _searchController.addListener(() => setState(() {}));
    _searchFocusNode.addListener(() {
      if (mounted) {
        setState(() {});
      }
    });
    _loadRecentSearches();
  }

  @override
  void dispose() {
    _searchDebounce?.cancel();
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  Future<List<Product>> _fetch() {
    return ApiService.fetchProducts(status: 'active', perPage: 100);
  }

  Future<void> _refresh() async {
    setState(() => _future = _fetch());
    await _future;
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

    _searchFocusNode.unfocus();
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

  Future<void> _addToCart(Product product) async {
    final ok = await ensureLoggedIn(
      context,
      message: 'Please login or register to add items to your cart.',
    );
    if (!ok || !mounted) return;
    CartService.instance.add(product);
    await showCartAddedBottomBar(context);
  }

  void _handleAddToCart(Product product) {
    _addToCart(product);
  }

  List<Product> _filterProducts(List<Product> products) {
    final query = _searchController.text.trim().toLowerCase();
    if (query.isEmpty) return products;
    return products.where((product) {
      final name = product.name.toLowerCase();
      final brand = (product.brand ?? '').toLowerCase();
      final tag = (product.tag ?? '').toLowerCase();
      final category = (product.categoryName ?? '').toLowerCase();
      final sku = (product.sku ?? '').toLowerCase();
      return name.contains(query) ||
          brand.contains(query) ||
          tag.contains(query) ||
          category.contains(query) ||
          sku.contains(query);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final isDesktop = width >= 1024;
    final isTablet = width >= 600 && width < 1024;
    final columns = isDesktop ? 4 : (isTablet ? 3 : 2);
    final cardRadius = isDesktop ? 18.0 : 16.0;
    final gridItemHeight = isDesktop ? 318.0 : (isTablet ? 302.0 : 286.0);

    final l = AppLocalizations.of(context);
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          widget.title ?? l.allProducts,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w800,
            color: apTextPrimary,
          ),
        ),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        foregroundColor: apTextPrimary,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        actions: [
          AllProductsCartIconButton(
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const CartScreen()),
              );
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: RefreshIndicator(
        color: apBrandBlue,
        onRefresh: _refresh,
        child: FutureBuilder<List<Product>>(
          future: _future,
          builder: (context, snapshot) {
            final isLoading = snapshot.connectionState == ConnectionState.waiting;
            if (snapshot.hasError) {
              return AllProductsErrorState(onRetry: _refresh);
            }

            final products = isLoading
                ? List.generate(8, (index) => Product(id: index, name: 'Loading...', price: 99.99))
                : (snapshot.data ?? []);

            if (!isLoading && products.isEmpty) {
              return const AllProductsEmptyState();
            }

            final filtered = isLoading ? products : _filterProducts(products);
            final compactToggle = width < 380;

            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 14),
                  child: Row(
                    children: [
                      Expanded(
                        child: AllProductsSearchField(
                          controller: _searchController,
                          focusNode: _searchFocusNode,
                          onChanged: _updateSuggestions,
                          onSubmitted: (value) {
                            _openSearchResults(value);
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      AllProductsViewToggleButton(
                        isGrid: _isGrid,
                        compact: compactToggle,
                        onTap: () {
                          setState(() => _isGrid = !_isGrid);
                        },
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child:
                      _searchFocusNode.hasFocus &&
                          _searchController.text.trim().isEmpty &&
                          (_recentSearches.isNotEmpty ||
                              _popularSearches.isNotEmpty)
                      ? AllProductsSearchDiscoveryList(
                          recentSearches: _recentSearches,
                          popularSearches: _popularSearches,
                          onSelect: (value) {
                            _searchController.text = value;
                            _openSearchResults(value);
                          },
                        )
                      : _searchFocusNode.hasFocus &&
                            _searchController.text.trim().isNotEmpty
                      ? AllProductsSearchSuggestionPanel(
                          query: _searchController.text.trim(),
                          items: _searchSuggestions,
                          isLoading: _isLoadingSearchSuggestions,
                          onSearchQuery: () {
                            _openSearchResults(_searchController.text);
                          },
                          onSelect: (suggestion) {
                            _searchController.text = suggestion.value;
                            _openSearchResults(suggestion.value);
                          },
                        )
                      : filtered.isEmpty
                      ? const AllProductsSearchEmptyState()
                      : Skeletonizer(
                          enabled: isLoading,
                          child: AnimatedSwitcher(
                            duration: const Duration(milliseconds: 220),
                            child: _isGrid
                              ? GridView.builder(
                                  key: const ValueKey('grid'),
                                  padding: const EdgeInsets.fromLTRB(
                                    16,
                                    0,
                                    16,
                                    20,
                                  ),
                                  itemCount: filtered.length,
                                  gridDelegate:
                                      SliverGridDelegateWithFixedCrossAxisCount(
                                        crossAxisCount: columns,
                                        crossAxisSpacing: 12,
                                        mainAxisSpacing: 12,
                                        mainAxisExtent: gridItemHeight,
                                      ),
                                  itemBuilder: (context, index) {
                                    final product = filtered[index];
                                    return AllProductsCard(
                                      product: product,
                                      radius: cardRadius,
                                      isGrid: true,
                                      onAdd: () => _handleAddToCart(product),
                                    );
                                  },
                                )
                              : ListView.separated(
                                  key: const ValueKey('list'),
                                  padding: const EdgeInsets.fromLTRB(
                                    16,
                                    0,
                                    16,
                                    20,
                                  ),
                                  itemCount: filtered.length,
                                  separatorBuilder: (_, _) =>
                                      const SizedBox(height: 12),
                                  itemBuilder: (context, index) {
                                    final product = filtered[index];
                                    return AllProductsCard(
                                      product: product,
                                      radius: cardRadius,
                                      isGrid: false,
                                      onAdd: () => _handleAddToCart(product),
                                    );
                                  },
                                ),
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

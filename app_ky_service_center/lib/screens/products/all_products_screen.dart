import 'dart:async';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../models/product.dart';
import '../../models/search_suggestion.dart';
import '../../services/api_service.dart';
import '../../services/cart_service.dart';
import '../../services/search_history_service.dart';
import '../../widgets/auth_guard.dart';
import '../../widgets/cart_added_bottom_bar.dart';
import '../search/search_results_screen.dart';
import 'product_detail_screen.dart';

const _pageBackground = Color(0xFFF5F7FB);
const _surface = Color(0xFFFFFFFF);
const _surfaceAlt = Color(0xFFF1F5F9);
const _border = Color(0xFFE2E8F0);
const _textPrimary = Color(0xFF0F172A);
const _textMuted = Color(0xFF64748B);
const _brandBlue = Color(0xFF0F6BFF);
const _success = Color(0xFF0F9D58);
const _warning = Color(0xFFF59E0B);
const _danger = Color(0xFFDC2626);
const _shadow = Color(0x140F172A);

final NumberFormat _currencyFormat = NumberFormat.currency(symbol: '\$');

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

    return Scaffold(
      backgroundColor: _pageBackground,
      appBar: AppBar(
        title: Text(
          widget.title ?? 'All Products',
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w800,
            color: _textPrimary,
            fontFamily: 'SF Pro Text',
          ),
        ),
        backgroundColor: _pageBackground,
        foregroundColor: _textPrimary,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
      ),
      body: RefreshIndicator(
        color: _brandBlue,
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

            final filtered = _filterProducts(products);
            final compactToggle = width < 380;

            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 14),
                  child: Row(
                    children: [
                      Expanded(
                        child: _SearchField(
                          controller: _searchController,
                          focusNode: _searchFocusNode,
                          onChanged: _updateSuggestions,
                          onSubmitted: (value) {
                            _openSearchResults(value);
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      _ViewToggleButton(
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
                  child: _searchFocusNode.hasFocus &&
                          _searchController.text.trim().isEmpty &&
                          (_recentSearches.isNotEmpty ||
                              _popularSearches.isNotEmpty)
                      ? _SearchDiscoveryList(
                          recentSearches: _recentSearches,
                          popularSearches: _popularSearches,
                          onSelect: (value) {
                            _searchController.text = value;
                            _openSearchResults(value);
                          },
                        )
                      : _searchFocusNode.hasFocus &&
                            _searchController.text.trim().isNotEmpty
                      ? _SearchSuggestionPanel(
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
                      ? const _SearchEmptyState()
                      : AnimatedSwitcher(
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
                                    return _ProductCard(
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
                                    return _ProductCard(
                                      product: product,
                                      radius: cardRadius,
                                      isGrid: false,
                                      onAdd: () => _handleAddToCart(product),
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

class _SearchField extends StatelessWidget {
  const _SearchField({
    required this.controller,
    required this.focusNode,
    this.onChanged,
    this.onSubmitted,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50,
      decoration: BoxDecoration(
        color: _surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: _border),
        boxShadow: const [
          BoxShadow(color: _shadow, blurRadius: 16, offset: Offset(0, 8)),
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
        style: const TextStyle(
          fontSize: 14,
          color: _textPrimary,
          fontFamily: 'SF Pro Text',
        ),
        decoration: InputDecoration(
          hintText: 'Search products, brands, repairs...',
          hintStyle: const TextStyle(
            color: _textMuted,
            fontFamily: 'SF Pro Text',
          ),
          counterText: '',
          prefixIcon: const Icon(Icons.search_rounded, size: 20),
          suffixIcon: controller.text.isEmpty
              ? null
              : IconButton(
                  onPressed: () {
                    controller.clear();
                    onChanged?.call('');
                  },
                  icon: const Icon(Icons.close_rounded, size: 20),
                ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 14),
        ),
      ),
    );
  }
}

class _SearchSuggestionPanel extends StatelessWidget {
  const _SearchSuggestionPanel({
    required this.query,
    required this.items,
    required this.isLoading,
    required this.onSearchQuery,
    required this.onSelect,
  });

  final String query;
  final List<SearchSuggestion> items;
  final bool isLoading;
  final VoidCallback onSearchQuery;
  final ValueChanged<SearchSuggestion> onSelect;

  @override
  Widget build(BuildContext context) {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
      children: [
        Container(
          decoration: BoxDecoration(
            color: _surface,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: _border),
            boxShadow: const [
              BoxShadow(color: _shadow, blurRadius: 18, offset: Offset(0, 10)),
            ],
          ),
          child: Column(
            children: [
              InkWell(
                onTap: onSearchQuery,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(18),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 12,
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.search_rounded,
                        color: _brandBlue,
                        size: 20,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'Search "$query"',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: _textPrimary,
                            fontFamily: 'SF Pro Text',
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const Divider(height: 1, color: _border),
              if (isLoading)
                const Padding(
                  padding: EdgeInsets.all(16),
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
                          color: _textMuted,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                )
              else if (items.isEmpty)
                const Padding(
                  padding: EdgeInsets.all(16),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'No suggestions found.',
                      style: TextStyle(
                        color: _textMuted,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                )
              else
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: items.length,
                  separatorBuilder: (_, _) =>
                      const Divider(height: 1, color: _border),
                  itemBuilder: (context, index) {
                    final suggestion = items[index];
                    return InkWell(
                      onTap: () => onSelect(suggestion),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 12,
                        ),
                        child: Row(
                          children: [
                            Container(
                              height: 38,
                              width: 38,
                              decoration: BoxDecoration(
                                color: _surfaceAlt,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(
                                _iconForSuggestionType(suggestion.type),
                                size: 18,
                                color: _brandBlue,
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
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w700,
                                      color: _textPrimary,
                                    ),
                                  ),
                                  if (suggestion.subtitle != null &&
                                      suggestion.subtitle!.trim().isNotEmpty) ...[
                                    const SizedBox(height: 2),
                                    Text(
                                      suggestion.subtitle!,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        fontSize: 11.5,
                                        color: _textMuted,
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              _labelForSuggestionType(suggestion.type),
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: _brandBlue,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
            ],
          ),
        ),
      ],
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
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
      children: [
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: _surface,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: _border),
            boxShadow: const [
              BoxShadow(color: _shadow, blurRadius: 18, offset: Offset(0, 10)),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (recentSearches.isNotEmpty) ...[
                const Text(
                  'Recent searches',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: _textPrimary,
                    fontFamily: 'SF Pro Text',
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
              const Text(
                'Popular searches',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: _textPrimary,
                  fontFamily: 'SF Pro Text',
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
        ),
      ],
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
      onTap: onTap,
      borderRadius: BorderRadius.circular(999),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
        decoration: BoxDecoration(
          color: _surfaceAlt,
          borderRadius: BorderRadius.circular(999),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14, color: _brandBlue),
            const SizedBox(width: 6),
            Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: _textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

IconData _iconForSuggestionType(String type) {
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

class _ViewToggleButton extends StatelessWidget {
  const _ViewToggleButton({
    required this.isGrid,
    required this.compact,
    required this.onTap,
  });

  final bool isGrid;
  final bool compact;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        height: 50,
        padding: EdgeInsets.symmetric(horizontal: compact ? 14 : 16),
        decoration: BoxDecoration(
          color: _surface,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: _border),
          boxShadow: const [
            BoxShadow(color: _shadow, blurRadius: 16, offset: Offset(0, 8)),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isGrid ? Icons.view_list_rounded : Icons.grid_view_rounded,
              size: 18,
              color: _textPrimary,
            ),
            if (!compact) ...[
              const SizedBox(width: 8),
              Text(
                isGrid ? 'List' : 'Grid',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: _textPrimary,
                  fontFamily: 'SF Pro Text',
                ),
              ),
            ],
          ],
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
    required this.onAdd,
  });

  final Product product;
  final double radius;
  final bool isGrid;
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: _surface,
      borderRadius: BorderRadius.circular(radius),
      child: InkWell(
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
            color: _surface,
            borderRadius: BorderRadius.circular(radius),
            border: Border.all(color: _border),
            boxShadow: const [
              BoxShadow(color: _shadow, blurRadius: 20, offset: Offset(0, 10)),
            ],
          ),
          child: isGrid
              ? _GridProductLayout(product: product, onAdd: onAdd)
              : _ListProductLayout(product: product, onAdd: onAdd),
        ),
      ),
    );
  }
}

class _GridProductLayout extends StatelessWidget {
  const _GridProductLayout({required this.product, required this.onAdd});

  final Product product;
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _CardTopRow(product: product),
          const SizedBox(height: 10),
          Expanded(
            child: _ProductImage(imageUrl: product.imageUrl),
          ),
          const SizedBox(height: 10),
          _ProductMetaLine(product: product),
          const SizedBox(height: 6),
          Text(
            product.name,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w800,
              height: 1.25,
              color: _textPrimary,
              fontFamily: 'SF Pro Text',
            ),
          ),
          const SizedBox(height: 10),
          _PriceRow(product: product, onAdd: onAdd),
        ],
      ),
    );
  }
}

class _ListProductLayout extends StatelessWidget {
  const _ListProductLayout({required this.product, required this.onAdd});

  final Product product;
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          SizedBox(
            width: 110,
            height: 126,
            child: _ProductImage(imageUrl: product.imageUrl),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _CardTopRow(product: product),
                const SizedBox(height: 8),
                _ProductMetaLine(product: product),
                const SizedBox(height: 6),
                Text(
                  product.name,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    height: 1.3,
                    color: _textPrimary,
                    fontFamily: 'SF Pro Text',
                  ),
                ),
                const SizedBox(height: 10),
                _PriceRow(product: product, onAdd: onAdd),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CardTopRow extends StatelessWidget {
  const _CardTopRow({required this.product});

  final Product product;

  @override
  Widget build(BuildContext context) {
    final tag = _tagFor(product.tag);
    final stockLabel = _stockLabel(product.stock);
    final stockColor = _stockColor(product.stock);

    return Row(
      children: [
        if (tag != null)
          _Badge(
            label: tag,
            background: const Color(0xFFFFE7D6),
            foreground: const Color(0xFFF47B20),
          ),
        const Spacer(),
        _Badge(
          label: stockLabel,
          background: stockColor.withAlpha(31),
          foreground: stockColor,
        ),
      ],
    );
  }
}

class _ProductMetaLine extends StatelessWidget {
  const _ProductMetaLine({required this.product});

  final Product product;

  @override
  Widget build(BuildContext context) {
    final primary = _firstValue(product.brand, product.categoryName);
    final secondary = product.sku;
    final text = [if (primary != null) primary, if (secondary != null) secondary]
        .join(' | ');

    if (text.isEmpty) {
      return const SizedBox(height: 0);
    }

    return Text(
      text,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: const TextStyle(
        fontSize: 11.5,
        fontWeight: FontWeight.w600,
        color: _textMuted,
        fontFamily: 'SF Pro Text',
      ),
    );
  }
}

class _PriceRow extends StatelessWidget {
  const _PriceRow({required this.product, required this.onAdd});

  final Product product;
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    final hasDiscount = product.hasDiscount && product.salePrice < product.price;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                _currencyFormat.format(product.salePrice),
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: hasDiscount ? _danger : _textPrimary,
                  fontFamily: 'SF Pro Text',
                ),
              ),
              const SizedBox(height: 2),
              Text(
                hasDiscount
                    ? 'Regular ${_currencyFormat.format(product.price)}'
                    : 'Per unit',
                style: TextStyle(
                  fontSize: 11.5,
                  color: hasDiscount ? _textMuted : _success,
                  fontWeight: FontWeight.w600,
                  fontFamily: 'SF Pro Text',
                  decoration: hasDiscount
                      ? TextDecoration.lineThrough
                      : TextDecoration.none,
                ),
              ),
            ],
          ),
        ),
        _AddCircleButton(onTap: onAdd),
      ],
    );
  }
}

class _ProductImage extends StatelessWidget {
  const _ProductImage({required this.imageUrl});

  final String? imageUrl;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(14),
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: _surfaceAlt,
          borderRadius: BorderRadius.circular(14),
        ),
        child: imageUrl == null || imageUrl!.isEmpty
            ? const _ImageFallback()
            : Padding(
                padding: const EdgeInsets.all(10),
                child: Image.network(
                  imageUrl!,
                  fit: BoxFit.contain,
                  alignment: Alignment.center,
                  cacheWidth: 900,
                  headers: _imageHeaders,
                  errorBuilder: (_, _, _) => const _ImageFallback(),
                  loadingBuilder: (context, child, progress) {
                    if (progress == null) return child;
                    return const _ImageSkeleton();
                  },
                ),
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
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 10.5,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.15,
          color: foreground,
          fontFamily: 'SF Pro Text',
        ),
      ),
    );
  }
}

String? _tagFor(String? raw) {
  if (raw == null || raw.trim().isEmpty) return null;
  return raw
      .trim()
      .replaceAll('_', ' ')
      .split(' ')
      .where((word) => word.trim().isNotEmpty)
      .map((word) => word.toUpperCase())
      .join(' ');
}

String _stockLabel(int? stock) {
  if (stock == null) return 'Available';
  if (stock <= 0) return 'Out of stock';
  if (stock <= 5) return 'Low stock';
  return 'In stock';
}

Color _stockColor(int? stock) {
  if (stock == null) return _brandBlue;
  if (stock <= 0) return _danger;
  if (stock <= 5) return _warning;
  return _success;
}

String? _firstValue(String? first, String? second) {
  if (first != null && first.trim().isNotEmpty) return first.trim();
  if (second != null && second.trim().isNotEmpty) return second.trim();
  return null;
}

Map<String, String>? get _imageHeaders => null;

class _SearchEmptyState extends StatelessWidget {
  const _SearchEmptyState();

  @override
  Widget build(BuildContext context) {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      children: const [
        SizedBox(height: 96),
        Icon(Icons.search_off_rounded, size: 48, color: _textMuted),
        SizedBox(height: 14),
        Center(
          child: Text(
            'No products match your search.',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: _textPrimary,
              fontFamily: 'SF Pro Text',
            ),
          ),
        ),
        SizedBox(height: 8),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 32),
          child: Center(
            child: Text(
              'Try another keyword, brand, or category.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                color: _textMuted,
                fontFamily: 'SF Pro Text',
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      children: const [
        SizedBox(height: 110),
        Icon(Icons.inventory_2_outlined, size: 52, color: _textMuted),
        SizedBox(height: 14),
        Center(
          child: Text(
            'No products available.',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: _textPrimary,
              fontFamily: 'SF Pro Text',
            ),
          ),
        ),
        SizedBox(height: 8),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 30),
          child: Center(
            child: Text(
              'Pull down to refresh after the backend adds products.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                color: _textMuted,
                fontFamily: 'SF Pro Text',
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.onRetry});

  final Future<void> Function() onRetry;

  @override
  Widget build(BuildContext context) {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      children: [
        const SizedBox(height: 110),
        const Icon(Icons.wifi_off_rounded, size: 52, color: _textMuted),
        const SizedBox(height: 14),
        const Center(
          child: Text(
            'Unable to load products.',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: _textPrimary,
              fontFamily: 'SF Pro Text',
            ),
          ),
        ),
        const SizedBox(height: 8),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 30),
          child: Center(
            child: Text(
              'Check the API connection and refresh the catalog again.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                color: _textMuted,
                fontFamily: 'SF Pro Text',
              ),
            ),
          ),
        ),
        const SizedBox(height: 18),
        Center(
          child: FilledButton.icon(
            onPressed: () {
              onRetry();
            },
            icon: const Icon(Icons.refresh_rounded),
            label: const Text('Retry'),
          ),
        ),
      ],
    );
  }
}

class _ImageFallback extends StatelessWidget {
  const _ImageFallback();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFF8FAFC),
      child: const Center(
        child: Icon(
          Icons.inventory_2_outlined,
          size: 34,
          color: Color(0xFF94A3B8),
        ),
      ),
    );
  }
}

class _ImageSkeleton extends StatelessWidget {
  const _ImageSkeleton();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: _surfaceAlt,
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

class _AddCircleButton extends StatelessWidget {
  const _AddCircleButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        height: 36,
        width: 36,
        decoration: BoxDecoration(
          color: _brandBlue,
          borderRadius: BorderRadius.circular(18),
          boxShadow: const [
            BoxShadow(color: _shadow, blurRadius: 10, offset: Offset(0, 6)),
          ],
        ),
        child: const Icon(Icons.add_rounded, size: 18, color: Colors.white),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../models/product.dart';
import '../../models/search_results.dart';
import '../../services/api_service.dart';
import '../../services/cart_service.dart';
import '../../services/search_history_service.dart';
import '../../widgets/auth_guard.dart';
import '../../widgets/cart_added_bottom_bar.dart';
import '../products/product_detail_screen.dart';

const _searchBg = Color(0xFFF5F7FB);
const _searchSurface = Colors.white;
const _searchSurfaceAlt = Color(0xFFF1F5F9);
const _searchBorder = Color(0xFFE2E8F0);
const _searchText = Color(0xFF0F172A);
const _searchMuted = Color(0xFF64748B);
const _searchBlue = Color(0xFF0F6BFF);
const _searchDanger = Color(0xFFDC2626);
const _searchShadow = Color(0x140F172A);

final NumberFormat _searchCurrency = NumberFormat.currency(symbol: '\$');

class SearchResultsScreen extends StatefulWidget {
  const SearchResultsScreen({super.key, required this.initialQuery});

  final String initialQuery;

  @override
  State<SearchResultsScreen> createState() => _SearchResultsScreenState();
}

class _SearchResultsScreenState extends State<SearchResultsScreen> {
  late final TextEditingController _controller;
  late Future<SearchResults> _future;
  bool _isGrid = true;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialQuery);
    _future = _load(widget.initialQuery);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<SearchResults> _load(String query) async {
    final trimmed = query.trim();
    if (trimmed.isNotEmpty) {
      await SearchHistoryService.addSearch(trimmed);
    }
    return ApiService.searchCatalog(trimmed);
  }

  void _submitSearch([String? raw]) {
    final query = (raw ?? _controller.text).trim();
    if (query.isEmpty) return;
    FocusScope.of(context).unfocus();
    setState(() {
      _future = _load(query);
    });
  }

  Future<void> _refresh() async {
    setState(() {
      _future = _load(_controller.text);
    });
    await _future;
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

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final columns = width >= 1024 ? 4 : (width >= 600 ? 3 : 2);

    return Scaffold(
      backgroundColor: _searchBg,
      appBar: AppBar(
        backgroundColor: _searchBg,
        foregroundColor: _searchText,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        title: const Text(
          'Search',
          style: TextStyle(
            fontWeight: FontWeight.w800,
            color: _searchText,
            fontFamily: 'SF Pro Text',
          ),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: _refresh,
        color: _searchBlue,
        child: FutureBuilder<SearchResults>(
          future: _future,
          builder: (context, snapshot) {
            final loading = snapshot.connectionState == ConnectionState.waiting;
            final hasError = snapshot.hasError;
            final results = snapshot.data;

            return ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
              children: [
                _ResultSearchBar(
                  controller: _controller,
                  isGrid: _isGrid,
                  onSubmitted: _submitSearch,
                  onToggleView: () {
                    setState(() => _isGrid = !_isGrid);
                  },
                ),
                const SizedBox(height: 16),
                if (loading)
                  const Padding(
                    padding: EdgeInsets.only(top: 80),
                    child: Center(child: CircularProgressIndicator()),
                  )
                else if (hasError)
                  _ResultMessage(
                    icon: Icons.wifi_off_rounded,
                    title: 'Unable to load search results',
                    message: 'Check the API connection and try your search again.',
                    actionLabel: 'Retry',
                    onTap: () {
                      _submitSearch();
                    },
                  )
                else if (results != null) ...[
                  _ResultHeader(query: results.query, total: _totalItems(results)),
                  const SizedBox(height: 14),
                  if (results.categories.isNotEmpty || results.brands.isNotEmpty)
                    _FilterChips(
                      categories: results.categories.map((item) => item.name).toList(),
                      brands: results.brands,
                      onSelect: (value) {
                        _controller.text = value;
                        _submitSearch(value);
                      },
                    ),
                  if (results.categories.isNotEmpty || results.brands.isNotEmpty)
                    const SizedBox(height: 18),
                  if (results.repairServices.isNotEmpty) ...[
                    const _SectionTitle('Repair Services'),
                    const SizedBox(height: 10),
                    ...results.repairServices.map(
                      (service) => Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: _RepairServiceCard(service: service),
                      ),
                    ),
                    const SizedBox(height: 8),
                  ],
                  if (results.products.isNotEmpty) ...[
                    const _SectionTitle('Products'),
                    const SizedBox(height: 10),
                    _isGrid
                        ? _ProductGrid(
                            columns: columns,
                            products: results.products,
                            onAdd: (product) {
                              _addToCart(product);
                            },
                          )
                        : _ProductList(
                            products: results.products,
                            onAdd: (product) {
                              _addToCart(product);
                            },
                          ),
                    const SizedBox(height: 18),
                  ],
                  if (results.accessories.isNotEmpty) ...[
                    const _SectionTitle('Accessories'),
                    const SizedBox(height: 10),
                    _AccessoryGrid(
                      columns: columns,
                      items: results.accessories,
                    ),
                    const SizedBox(height: 18),
                  ],
                  if (!results.hasAnyResult)
                    _ResultMessage(
                      icon: Icons.search_off_rounded,
                      title: 'No results found',
                      message:
                          'Try a different keyword, or use one of the popular searches below.',
                      popularSearches: results.popularSearches,
                      onSelectPopular: (value) {
                        _controller.text = value;
                        _submitSearch(value);
                      },
                    ),
                ],
              ],
            );
          },
        ),
      ),
    );
  }
}

int _totalItems(SearchResults results) {
  return results.products.length +
      results.accessories.length +
      results.repairServices.length;
}

String _compactSearchText(List<String?> parts) {
  return parts
      .where((item) => item != null && item.trim().isNotEmpty)
      .map((item) => item!.trim())
      .join(' | ');
}

class _ResultSearchBar extends StatelessWidget {
  const _ResultSearchBar({
    required this.controller,
    required this.isGrid,
    required this.onSubmitted,
    required this.onToggleView,
  });

  final TextEditingController controller;
  final bool isGrid;
  final ValueChanged<String> onSubmitted;
  final VoidCallback onToggleView;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              color: _searchSurface,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: _searchBorder),
              boxShadow: const [
                BoxShadow(
                  color: _searchShadow,
                  blurRadius: 16,
                  offset: Offset(0, 8),
                ),
              ],
            ),
            child: TextField(
              controller: controller,
              textInputAction: TextInputAction.search,
              onSubmitted: onSubmitted,
              maxLength: 80,
              decoration: InputDecoration(
                hintText: 'Search products, brands, repairs...',
                hintStyle: const TextStyle(color: _searchMuted),
                counterText: '',
                prefixIcon: const Icon(Icons.search_rounded, color: _searchMuted),
                suffixIcon: controller.text.isEmpty
                    ? null
                    : IconButton(
                        onPressed: () {
                          controller.clear();
                        },
                        icon: const Icon(Icons.close_rounded),
                      ),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(vertical: 14),
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        InkWell(
          onTap: onToggleView,
          borderRadius: BorderRadius.circular(18),
          child: Container(
            height: 52,
            width: 52,
            decoration: BoxDecoration(
              color: _searchSurface,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: _searchBorder),
            ),
            child: Icon(
              isGrid ? Icons.view_list_rounded : Icons.grid_view_rounded,
              color: _searchText,
            ),
          ),
        ),
      ],
    );
  }
}

class _ResultHeader extends StatelessWidget {
  const _ResultHeader({required this.query, required this.total});

  final String query;
  final int total;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Results for "$query"',
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w800,
            color: _searchText,
            fontFamily: 'SF Pro Text',
          ),
        ),
        const SizedBox(height: 4),
        Text(
          '$total matching items',
          style: const TextStyle(
            fontSize: 13,
            color: _searchMuted,
            fontFamily: 'SF Pro Text',
          ),
        ),
      ],
    );
  }
}

class _FilterChips extends StatelessWidget {
  const _FilterChips({
    required this.categories,
    required this.brands,
    required this.onSelect,
  });

  final List<String> categories;
  final List<String> brands;
  final ValueChanged<String> onSelect;

  @override
  Widget build(BuildContext context) {
    final items = <String>[
      ...brands.take(4),
      ...categories.where((item) => !brands.contains(item)).take(4),
    ];

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: items.map((item) {
        return InkWell(
          onTap: () => onSelect(item),
          borderRadius: BorderRadius.circular(999),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: _searchSurface,
              borderRadius: BorderRadius.circular(999),
              border: Border.all(color: _searchBorder),
            ),
            child: Text(
              item,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: _searchText,
                fontFamily: 'SF Pro Text',
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.title);

  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w800,
        color: _searchText,
        fontFamily: 'SF Pro Text',
      ),
    );
  }
}

class _RepairServiceCard extends StatelessWidget {
  const _RepairServiceCard({required this.service});

  final SearchRepairService service;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: _searchSurface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: _searchBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                height: 34,
                width: 34,
                decoration: BoxDecoration(
                  color: _searchBlue.withAlpha(22),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.build_circle_outlined,
                  color: _searchBlue,
                  size: 18,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  service.title,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: _searchText,
                    fontFamily: 'SF Pro Text',
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            service.description,
            style: const TextStyle(
              fontSize: 13,
              height: 1.4,
              color: _searchMuted,
              fontFamily: 'SF Pro Text',
            ),
          ),
          if (service.keywords.isNotEmpty) ...[
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: service.keywords.take(4).map((keyword) {
                return Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: _searchSurfaceAlt,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    keyword,
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: _searchMuted,
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ],
      ),
    );
  }
}

class _ProductGrid extends StatelessWidget {
  const _ProductGrid({
    required this.columns,
    required this.products,
    required this.onAdd,
  });

  final int columns;
  final List<Product> products;
  final ValueChanged<Product> onAdd;

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: products.length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: columns,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        mainAxisExtent: 280,
      ),
      itemBuilder: (context, index) {
        final product = products[index];
        return _ProductCard(product: product, onAdd: () => onAdd(product));
      },
    );
  }
}

class _ProductList extends StatelessWidget {
  const _ProductList({
    required this.products,
    required this.onAdd,
  });

  final List<Product> products;
  final ValueChanged<Product> onAdd;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: products.length,
      separatorBuilder: (_, _) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final product = products[index];
        return _ProductRow(product: product, onAdd: () => onAdd(product));
      },
    );
  }
}

class _AccessoryGrid extends StatelessWidget {
  const _AccessoryGrid({
    required this.columns,
    required this.items,
  });

  final int columns;
  final List<SearchAccessory> items;

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: items.length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: columns,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        mainAxisExtent: 260,
      ),
      itemBuilder: (context, index) {
        return _AccessoryCard(item: items[index]);
      },
    );
  }
}

class _ProductCard extends StatelessWidget {
  const _ProductCard({required this.product, required this.onAdd});

  final Product product;
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: _searchSurface,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => ProductDetailScreen(product: product),
            ),
          );
        },
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: _searchSurface,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: _searchBorder),
            boxShadow: const [
              BoxShadow(
                color: _searchShadow,
                blurRadius: 18,
                offset: Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: _ResultImage(imageUrl: product.imageUrl)),
              const SizedBox(height: 10),
              Text(
                product.name,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: _searchText,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                _compactSearchText([product.brand, product.categoryName]),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 11.5, color: _searchMuted),
              ),
              const SizedBox(height: 6),
              Row(
                children: [
                  const Icon(Icons.star_rounded, size: 14, color: Colors.amber),
                  const SizedBox(width: 4),
                  Text(
                    product.rating.toStringAsFixed(1),
                    style: const TextStyle(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w700,
                      color: _searchText,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              _ProductPrice(product: product, onAdd: onAdd),
            ],
          ),
        ),
      ),
    );
  }
}

class _ProductRow extends StatelessWidget {
  const _ProductRow({required this.product, required this.onAdd});

  final Product product;
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: _searchSurface,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => ProductDetailScreen(product: product),
            ),
          );
        },
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: _searchSurface,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: _searchBorder),
          ),
          child: Row(
            children: [
              SizedBox(
                width: 96,
                height: 110,
                child: _ResultImage(imageUrl: product.imageUrl),
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
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: _searchText,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      _compactSearchText([product.brand, product.categoryName]),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 11.5,
                        color: _searchMuted,
                      ),
                    ),
                    const SizedBox(height: 10),
                    _ProductPrice(product: product, onAdd: onAdd),
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

class _ProductPrice extends StatelessWidget {
  const _ProductPrice({required this.product, required this.onAdd});

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
            children: [
              Text(
                _searchCurrency.format(product.salePrice),
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: hasDiscount ? _searchDanger : _searchText,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                hasDiscount
                    ? 'Regular ${_searchCurrency.format(product.price)}'
                    : 'Per unit',
                style: TextStyle(
                  fontSize: 11.5,
                  color: _searchMuted,
                  decoration: hasDiscount
                      ? TextDecoration.lineThrough
                      : TextDecoration.none,
                ),
              ),
            ],
          ),
        ),
        InkWell(
          onTap: onAdd,
          borderRadius: BorderRadius.circular(18),
          child: Container(
            height: 34,
            width: 34,
            decoration: BoxDecoration(
              color: _searchBlue,
              borderRadius: BorderRadius.circular(17),
            ),
            child: const Icon(Icons.add_rounded, size: 18, color: Colors.white),
          ),
        ),
      ],
    );
  }
}

class _AccessoryCard extends StatelessWidget {
  const _AccessoryCard({required this.item});

  final SearchAccessory item;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: _searchSurface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: _searchBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(child: _ResultImage(imageUrl: item.imageUrl)),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: _searchBlue.withAlpha(22),
              borderRadius: BorderRadius.circular(999),
            ),
            child: const Text(
              'Accessory',
              style: TextStyle(
                fontSize: 10.5,
                fontWeight: FontWeight.w700,
                color: _searchBlue,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            item.name,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w800,
              color: _searchText,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            item.brand ?? 'Accessory item',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 11.5, color: _searchMuted),
          ),
          const SizedBox(height: 8),
          Text(
            _searchCurrency.format(item.finalPrice),
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: item.hasDiscount ? _searchDanger : _searchText,
            ),
          ),
        ],
      ),
    );
  }
}

class _ResultImage extends StatelessWidget {
  const _ResultImage({required this.imageUrl});

  final String? imageUrl;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(14),
      child: Container(
        color: _searchSurfaceAlt,
        child: imageUrl == null || imageUrl!.isEmpty
            ? const Center(
                child: Icon(
                  Icons.inventory_2_outlined,
                  color: _searchMuted,
                  size: 30,
                ),
              )
            : Padding(
                padding: const EdgeInsets.all(10),
                child: Image.network(
                  imageUrl!,
                  fit: BoxFit.contain,
                  errorBuilder: (_, _, _) => const Center(
                    child: Icon(
                      Icons.inventory_2_outlined,
                      color: _searchMuted,
                      size: 30,
                    ),
                  ),
                ),
              ),
      ),
    );
  }
}

class _ResultMessage extends StatelessWidget {
  const _ResultMessage({
    required this.icon,
    required this.title,
    required this.message,
    this.actionLabel,
    this.onTap,
    this.popularSearches = const [],
    this.onSelectPopular,
  });

  final IconData icon;
  final String title;
  final String message;
  final String? actionLabel;
  final VoidCallback? onTap;
  final List<String> popularSearches;
  final ValueChanged<String>? onSelectPopular;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: _searchSurface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: _searchBorder),
      ),
      child: Column(
        children: [
          Icon(icon, size: 42, color: _searchMuted),
          const SizedBox(height: 10),
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: _searchText,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 13, color: _searchMuted),
          ),
          if (actionLabel != null && onTap != null) ...[
            const SizedBox(height: 14),
            FilledButton(onPressed: onTap, child: Text(actionLabel!)),
          ],
          if (popularSearches.isNotEmpty && onSelectPopular != null) ...[
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: popularSearches.map((item) {
                return InkWell(
                  onTap: () => onSelectPopular!(item),
                  borderRadius: BorderRadius.circular(999),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: _searchSurfaceAlt,
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      item,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: _searchText,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ],
      ),
    );
  }
}

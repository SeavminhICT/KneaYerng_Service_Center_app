import 'dart:async';
import 'package:flutter/material.dart';
import '../../models/cart_item.dart';
import '../../models/product.dart';
import '../../services/cart_service.dart';
import '../../services/favorite_service.dart';
import '../../widgets/page_transitions.dart';
import '../cart/cart_screen.dart';
import '../cart/checkout_flow_screen.dart';

Map<String, String>? get _imageHeaders => null;

class ProductDetailScreen extends StatefulWidget {
  const ProductDetailScreen({super.key, required this.product});

  final Product product;

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen>
    with SingleTickerProviderStateMixin {
  int _galleryIndex = 0;
  int _quantity = 1;
  int _storageIndex = 0;
  int _colorIndex = 0;
  int _conditionIndex = 0;
  late final AnimationController _miniCartController;
  late final Animation<Offset> _miniCartSlide;
  Timer? _miniCartTimer;
  bool _showMiniCart = false;

  static const Map<String, Color> _namedColors = {
    'black': Color(0xFF111827),
    'graphite': Color(0xFF1F2937),
    'white': Color(0xFFF9FAFB),
    'silver': Color(0xFFD1D5DB),
    'grey': Color(0xFF9CA3AF),
    'gray': Color(0xFF9CA3AF),
    'blue': Color(0xFF2563EB),
    'green': Color(0xFF22C55E),
    'red': Color(0xFFDC2626),
    'gold': Color(0xFFEAB308),
    'natural titanium': Color(0xFFD6D3D1),
    'white titanium': Color(0xFFE5E7EB),
    'black titanium': Color(0xFF111827),
    'desert titanium': Color(0xFFBFA58A),
  };

  @override
  void initState() {
    super.initState();
    _miniCartController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 360),
    );
    _miniCartSlide = Tween<Offset>(begin: const Offset(0, 1), end: Offset.zero)
        .animate(
          CurvedAnimation(
            parent: _miniCartController,
            curve: Curves.easeOutBack,
            reverseCurve: Curves.easeInCubic,
          ),
        );
  }

  @override
  void dispose() {
    _miniCartTimer?.cancel();
    _miniCartController.dispose();
    super.dispose();
  }

  List<String> _splitOptions(String? raw) {
    if (raw == null) return [];
    final cleaned = raw.trim();
    if (cleaned.isEmpty || cleaned == '[]') return [];
    var normalized = cleaned;
    if (normalized.startsWith('[') && normalized.endsWith(']')) {
      normalized = normalized.substring(1, normalized.length - 1).trim();
    }
    if (normalized.isEmpty) return [];

    return normalized
        .split(RegExp(r'[|,]'))
        .map((item) => item.trim().replaceAll("'", '').replaceAll('"', ''))
        .where((item) => item.isNotEmpty)
        .toList();
  }

  List<String> _buildGallery(Product product) {
    final images = <String>[];
    if (product.thumbnailUrl != null && product.thumbnailUrl!.isNotEmpty) {
      images.add(product.thumbnailUrl!);
    }
    if (product.imageUrl != null && product.imageUrl!.isNotEmpty) {
      if (!images.contains(product.imageUrl!)) {
        images.add(product.imageUrl!);
      }
    }
    for (final url in product.imageGallery) {
      if (url.isNotEmpty && !images.contains(url)) {
        images.add(url);
      }
    }
    return images;
  }

  Color _colorFromName(String name) {
    final key = name.trim().toLowerCase();
    return _namedColors[key] ?? const Color(0xFFD1D5DB);
  }

  String _formatTag(String? value) {
    final raw = value?.trim();
    if (raw == null || raw.isEmpty) return '';
    return raw
        .replaceAll(RegExp(r'[_-]+'), ' ')
        .split(' ')
        .where((w) => w.isNotEmpty)
        .map((w) => '${w[0].toUpperCase()}${w.substring(1).toLowerCase()}')
        .join(' ');
  }

  String _cleanValue(String? raw) {
    if (raw == null) return '';
    var value = raw.trim();
    if (value.isEmpty || value == 'null') return '';
    if (value.startsWith('[') && value.endsWith(']')) {
      value = value.substring(1, value.length - 1).trim();
    }
    value = value.replaceAll("'", '').replaceAll('"', '');
    return value;
  }

  void _showMiniCartBar() {
    _miniCartTimer?.cancel();
    setState(() => _showMiniCart = true);
    _miniCartController.forward();
    _miniCartTimer = Timer(const Duration(seconds: 6), () {
      if (!mounted) return;
      _hideMiniCartBar();
    });
  }

  void _hideMiniCartBar() {
    _miniCartTimer?.cancel();
    _miniCartController.reverse().whenComplete(() {
      if (!mounted) return;
      setState(() => _showMiniCart = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    final product = widget.product;
    final gallery = _buildGallery(product);
    final safeIndex = gallery.isEmpty
        ? 0
        : _galleryIndex.clamp(0, gallery.length - 1);
    final imageUrl = gallery.isEmpty ? null : gallery[safeIndex];

    final storageOptions = _splitOptions(product.storageCapacity);
    final colorOptions = _splitOptions(product.color);
    final conditionOptions = _splitOptions(product.condition);
    if (_storageIndex >= storageOptions.length) _storageIndex = 0;
    if (_colorIndex >= colorOptions.length) _colorIndex = 0;
    if (_conditionIndex >= conditionOptions.length) _conditionIndex = 0;

    final price = product.price;
    final oldPrice = (product.discount ?? 0) > 0
        ? price + product.discount!
        : null;
    final tagText = _formatTag(product.tag);
    final brand = (product.brand?.trim().isNotEmpty ?? false)
        ? product.brand!.trim()
        : 'Apple';
    final sku = (product.sku?.trim().isNotEmpty ?? false)
        ? product.sku!.trim()
        : 'N/A';
    final ramText = product.ramOptions.join(', ');
    final ssdText = _cleanValue(product.ssd);
    final cpuText = _cleanValue(product.cpu);
    final displayText = _cleanValue(product.display);
    final countryText = _cleanValue(product.country);
    final descriptionText = _cleanValue(product.description);

    return AnimatedBuilder(
      animation: FavoriteService.instance,
      builder: (context, _) {
        final isFavorite = FavoriteService.instance.contains(product);

        return Scaffold(
          backgroundColor: const Color(0xFFF7F8FB),
          body: SafeArea(
            child: Stack(
              children: [
                Column(
                  children: [
                    _TopBar(
                      isFavorite: isFavorite,
                      onBack: () => Navigator.of(context).pop(),
                      onFavorite: () =>
                          FavoriteService.instance.toggle(product),
                      onCart: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(builder: (_) => const CartScreen()),
                        );
                      },
                    ),
                    Expanded(
                      child: ListView(
                        padding: const EdgeInsets.fromLTRB(14, 6, 14, 16),
                        children: [
                          _HeroImageCard(imageUrl: imageUrl, tagText: tagText),
                          const SizedBox(height: 12),
                          if (gallery.length > 1)
                            _ThumbStrip(
                              images: gallery,
                              selectedIndex: safeIndex,
                              onSelect: (index) =>
                                  setState(() => _galleryIndex = index),
                            ),
                          const SizedBox(height: 12),
                          Text(
                            product.name,
                            style: const TextStyle(
                              fontSize: 30,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF111827),
                              height: 1.1,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            '$brand  |  SKU: $sku',
                            style: const TextStyle(
                              fontSize: 13,
                              color: Color(0xFF6B7280),
                            ),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text(
                                '\$${price.toStringAsFixed(2)}',
                                style: const TextStyle(
                                  fontSize: 28,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF111827),
                                ),
                              ),
                              if (oldPrice != null) ...[
                                const SizedBox(width: 8),
                                Text(
                                  '\$${oldPrice.toStringAsFixed(2)}',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    color: Color(0xFF9CA3AF),
                                    decoration: TextDecoration.lineThrough,
                                  ),
                                ),
                              ],
                              const Spacer(),
                              _QtyControl(
                                quantity: _quantity,
                                onMinus: () {
                                  if (_quantity <= 1) return;
                                  setState(() => _quantity--);
                                },
                                onPlus: () => setState(() => _quantity++),
                              ),
                            ],
                          ),
                          const SizedBox(height: 14),
                          const Text(
                            'Color',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF111827),
                            ),
                          ),
                          const SizedBox(height: 8),
                          if (colorOptions.isNotEmpty)
                            Wrap(
                              spacing: 10,
                              runSpacing: 10,
                              children: List.generate(colorOptions.length, (
                                index,
                              ) {
                                final name = colorOptions[index];
                                final selected = _colorIndex == index;
                                return InkWell(
                                  onTap: () =>
                                      setState(() => _colorIndex = index),
                                  borderRadius: BorderRadius.circular(20),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 8,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(20),
                                      border: Border.all(
                                        color: selected
                                            ? const Color(0xFF2563EB)
                                            : const Color(0xFFE5E7EB),
                                        width: selected ? 1.5 : 1,
                                      ),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Container(
                                          height: 14,
                                          width: 14,
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            color: _colorFromName(name),
                                            border: Border.all(
                                              color: const Color(0xFFD1D5DB),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          name,
                                          style: TextStyle(
                                            fontSize: 12,
                                            fontWeight: selected
                                                ? FontWeight.w700
                                                : FontWeight.w500,
                                            color: const Color(0xFF374151),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              }),
                            )
                          else
                            const Text(
                              'No color options',
                              style: TextStyle(color: Color(0xFF9CA3AF)),
                            ),
                          const SizedBox(height: 16),
                          const Text(
                            'Storage',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF111827),
                            ),
                          ),
                          const SizedBox(height: 8),
                          if (storageOptions.isNotEmpty)
                            Row(
                              children: List.generate(storageOptions.length, (
                                index,
                              ) {
                                final selected = _storageIndex == index;
                                return Expanded(
                                  child: Padding(
                                    padding: EdgeInsets.only(
                                      right: index == storageOptions.length - 1
                                          ? 0
                                          : 8,
                                    ),
                                    child: InkWell(
                                      onTap: () =>
                                          setState(() => _storageIndex = index),
                                      borderRadius: BorderRadius.circular(18),
                                      child: Container(
                                        height: 38,
                                        alignment: Alignment.center,
                                        decoration: BoxDecoration(
                                          color: selected
                                              ? const Color(0xFFEAF2FF)
                                              : Colors.white,
                                          borderRadius: BorderRadius.circular(
                                            18,
                                          ),
                                          border: Border.all(
                                            color: selected
                                                ? const Color(0xFF2563EB)
                                                : const Color(0xFFE5E7EB),
                                          ),
                                        ),
                                        child: Text(
                                          storageOptions[index],
                                          style: TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w600,
                                            color: selected
                                                ? const Color(0xFF2563EB)
                                                : const Color(0xFF6B7280),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              }),
                            )
                          else
                            const Text(
                              'No storage options',
                              style: TextStyle(color: Color(0xFF9CA3AF)),
                            ),
                          const SizedBox(height: 16),
                          const Text(
                            'Condition',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF111827),
                            ),
                          ),
                          const SizedBox(height: 8),
                          if (conditionOptions.isNotEmpty)
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: List.generate(conditionOptions.length, (
                                index,
                              ) {
                                final selected = _conditionIndex == index;
                                return InkWell(
                                  onTap: () =>
                                      setState(() => _conditionIndex = index),
                                  borderRadius: BorderRadius.circular(16),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 8,
                                    ),
                                    decoration: BoxDecoration(
                                      color: selected
                                          ? const Color(0xFFEAF2FF)
                                          : Colors.white,
                                      borderRadius: BorderRadius.circular(16),
                                      border: Border.all(
                                        color: selected
                                            ? const Color(0xFF2563EB)
                                            : const Color(0xFFE5E7EB),
                                      ),
                                    ),
                                    child: Text(
                                      conditionOptions[index],
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                        color: selected
                                            ? const Color(0xFF2563EB)
                                            : const Color(0xFF6B7280),
                                      ),
                                    ),
                                  ),
                                );
                              }),
                            )
                          else
                            const Text(
                              'No condition options',
                              style: TextStyle(color: Color(0xFF9CA3AF)),
                            ),
                          const SizedBox(height: 16),
                          const Text(
                            'A Snapshot View',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF111827),
                            ),
                          ),
                          const SizedBox(height: 8),
                          _InfoLine(
                            text: displayText.isNotEmpty
                                ? 'Display: $displayText'
                                : 'Display: N/A',
                          ),
                          _InfoLine(
                            text: cpuText.isNotEmpty
                                ? 'CPU: $cpuText'
                                : 'CPU: N/A',
                          ),
                          _InfoLine(
                            text: ramText.isNotEmpty
                                ? 'RAM: $ramText'
                                : 'RAM: N/A',
                          ),
                          _InfoLine(
                            text: ssdText.isNotEmpty
                                ? 'SSD: $ssdText'
                                : 'SSD: N/A',
                          ),
                          _InfoLine(
                            text: countryText.isNotEmpty
                                ? 'Country: $countryText'
                                : 'Country: N/A',
                          ),
                          _InfoLine(
                            text:
                                'Warranty: ${_cleanValue(product.warranty).isNotEmpty ? _cleanValue(product.warranty) : 'N/A'}',
                          ),
                          const SizedBox(height: 14),
                          const Text(
                            'Description',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF111827),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            descriptionText.isNotEmpty
                                ? descriptionText
                                : 'No description available.',
                            style: const TextStyle(
                              fontSize: 13,
                              height: 1.35,
                              color: Color(0xFF4B5563),
                            ),
                          ),
                          const SizedBox(height: 80),
                        ],
                      ),
                    ),
                  ],
                ),
                if (_showMiniCart)
                  Positioned.fill(
                    child: GestureDetector(
                      onTap: _hideMiniCartBar,
                      child: Container(
                        color: Colors.black.withValues(alpha: 0.08),
                      ),
                    ),
                  ),
                if (_showMiniCart)
                  Positioned(
                    left: 0,
                    right: 0,
                    bottom: 0,
                    child: SlideTransition(
                      position: _miniCartSlide,
                      child: SafeArea(
                        top: false,
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(18),
                              border: Border.all(
                                color: const Color(0xFFE5E7EB),
                              ),
                              boxShadow: const [
                                BoxShadow(
                                  color: Color(0x22000000),
                                  blurRadius: 18,
                                  offset: Offset(0, 8),
                                ),
                              ],
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(12),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      const Icon(
                                        Icons.check_circle,
                                        color: Color(0xFF16A34A),
                                        size: 18,
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          '${product.name} added to cart',
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(
                                            fontSize: 13,
                                            fontWeight: FontWeight.w600,
                                            color: Color(0xFF111827),
                                          ),
                                        ),
                                      ),
                                      IconButton(
                                        onPressed: _hideMiniCartBar,
                                        icon: const Icon(Icons.close, size: 18),
                                        visualDensity: VisualDensity.compact,
                                        constraints: const BoxConstraints(),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 10),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: OutlinedButton(
                                          onPressed: () {
                                            _hideMiniCartBar();
                                            Navigator.of(context).push(
                                              MaterialPageRoute(
                                                builder: (_) =>
                                                    const CartScreen(),
                                              ),
                                            );
                                          },
                                          style: OutlinedButton.styleFrom(
                                            side: const BorderSide(
                                              color: Color(0xFF93C5FD),
                                            ),
                                            foregroundColor: const Color(
                                              0xFF2563EB,
                                            ),
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(14),
                                            ),
                                            padding: const EdgeInsets.symmetric(
                                              vertical: 12,
                                            ),
                                          ),
                                          child: const Text(
                                            'View Cart',
                                            style: TextStyle(
                                              fontWeight: FontWeight.w700,
                                            ),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: ElevatedButton(
                                          onPressed: () {
                                            _hideMiniCartBar();
                                            Navigator.of(context).push(
                                              MaterialPageRoute(
                                                builder: (_) =>
                                                    const CartScreen(),
                                              ),
                                            );
                                          },
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: const Color(
                                              0xFF2563EB,
                                            ),
                                            foregroundColor: Colors.white,
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(14),
                                            ),
                                            padding: const EdgeInsets.symmetric(
                                              vertical: 12,
                                            ),
                                          ),
                                          child: const Text(
                                            'Checkout',
                                            style: TextStyle(
                                              fontWeight: FontWeight.w700,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          bottomNavigationBar: SafeArea(
            top: false,
            child: Container(
              padding: const EdgeInsets.fromLTRB(14, 10, 14, 14),
              color: Colors.white,
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        final variant = [
                          if (colorOptions.isNotEmpty)
                            colorOptions[_colorIndex],
                          if (storageOptions.isNotEmpty)
                            storageOptions[_storageIndex],
                          if (conditionOptions.isNotEmpty)
                            conditionOptions[_conditionIndex],
                        ].join(' | ');
                        final checkoutItem = CartItem(
                          product: product,
                          quantity: _quantity,
                          variant: variant.isEmpty ? null : variant,
                        );
                        Navigator.of(context).push(
                          fadeSlideRoute(
                            CheckoutFlowScreen(items: [checkoutItem]),
                          ),
                        );
                      },
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Color(0xFF93C5FD)),
                        foregroundColor: const Color(0xFF2563EB),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      child: const Text(
                        'Buy Now',
                        style: TextStyle(fontWeight: FontWeight.w700),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        final variant = [
                          if (colorOptions.isNotEmpty)
                            colorOptions[_colorIndex],
                          if (storageOptions.isNotEmpty)
                            storageOptions[_storageIndex],
                          if (conditionOptions.isNotEmpty)
                            conditionOptions[_conditionIndex],
                        ].join(' | ');
                        CartService.instance.add(
                          product,
                          quantity: _quantity,
                          variant: variant.isEmpty ? null : variant,
                        );
                        _showMiniCartBar();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2563EB),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      child: Text(
                        'Add to Cart  (\$${(price * _quantity).toStringAsFixed(2)})',
                        style: const TextStyle(fontWeight: FontWeight.w700),
                      ),
                    ),
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

class _TopBar extends StatelessWidget {
  const _TopBar({
    required this.isFavorite,
    required this.onBack,
    required this.onFavorite,
    required this.onCart,
  });

  final bool isFavorite;
  final VoidCallback onBack;
  final VoidCallback onFavorite;
  final VoidCallback onCart;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 6, 14, 6),
      child: Row(
        children: [
          _IconBtn(icon: Icons.arrow_back, onTap: onBack),
          const Spacer(),
          _IconBtn(
            icon: isFavorite ? Icons.favorite : Icons.favorite_border,
            onTap: onFavorite,
            iconColor: isFavorite ? const Color(0xFFE11D48) : null,
          ),
          const SizedBox(width: 8),
          _IconBtn(icon: Icons.shopping_bag_outlined, onTap: onCart),
        ],
      ),
    );
  }
}

class _HeroImageCard extends StatelessWidget {
  const _HeroImageCard({required this.imageUrl, required this.tagText});

  final String? imageUrl;
  final String tagText;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 220,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Stack(
        children: [
          Center(
            child: imageUrl == null || imageUrl!.isEmpty
                ? const _ImageFallback()
                : Padding(
                    padding: const EdgeInsets.all(14),
                    child: Image.network(
                      imageUrl!,
                      fit: BoxFit.contain,
                      alignment: Alignment.center,
                      cacheWidth: 1200,
                      headers: _imageHeaders,
                      errorBuilder: (context, error, stackTrace) {
                        return const _ImageFallback();
                      },
                    ),
                  ),
          ),
          if (tagText.isNotEmpty)
            Positioned(
              right: 12,
              top: 12,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
                decoration: BoxDecoration(
                  color: const Color(0xFFEA580C),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  tagText,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 11,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _ThumbStrip extends StatelessWidget {
  const _ThumbStrip({
    required this.images,
    required this.selectedIndex,
    required this.onSelect,
  });

  final List<String> images;
  final int selectedIndex;
  final ValueChanged<int> onSelect;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 60,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: images.length,
        separatorBuilder: (context, index) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final selected = index == selectedIndex;
          return InkWell(
            onTap: () => onSelect(index),
            borderRadius: BorderRadius.circular(12),
            child: Container(
              width: 60,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: selected
                      ? const Color(0xFF2563EB)
                      : const Color(0xFFE5E7EB),
                  width: selected ? 1.5 : 1,
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(6),
                child: Image.network(
                  images[index],
                  fit: BoxFit.contain,
                  headers: _imageHeaders,
                  errorBuilder: (context, error, stackTrace) {
                    return const _ImageFallback();
                  },
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _QtyControl extends StatelessWidget {
  const _QtyControl({
    required this.quantity,
    required this.onMinus,
    required this.onPlus,
  });

  final int quantity;
  final VoidCallback onMinus;
  final VoidCallback onPlus;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Row(
        children: [
          InkWell(
            onTap: onMinus,
            child: const Padding(
              padding: EdgeInsets.all(4),
              child: Icon(Icons.remove, size: 16),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Text(
              '$quantity',
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
          ),
          InkWell(
            onTap: onPlus,
            child: const Padding(
              padding: EdgeInsets.all(4),
              child: Icon(Icons.add, size: 16),
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoLine extends StatelessWidget {
  const _InfoLine({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    final value = text.trim();
    if (value.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        children: [
          const Icon(
            Icons.check_circle_outline,
            size: 16,
            color: Color(0xFF9CA3AF),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 13, color: Color(0xFF4B5563)),
            ),
          ),
        ],
      ),
    );
  }
}

class _IconBtn extends StatelessWidget {
  const _IconBtn({required this.icon, required this.onTap, this.iconColor});

  final IconData icon;
  final VoidCallback onTap;
  final Color? iconColor;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        height: 36,
        width: 36,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFE5E7EB)),
        ),
        child: Icon(
          icon,
          size: 19,
          color: iconColor ?? const Color(0xFF111827),
        ),
      ),
    );
  }
}

class _ImageFallback extends StatelessWidget {
  const _ImageFallback();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Icon(Icons.image_not_supported_outlined, color: Color(0xFF9CA3AF)),
    );
  }
}

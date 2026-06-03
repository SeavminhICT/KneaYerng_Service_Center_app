import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'dart:convert';
import 'dart:typed_data';

import '../../l10n/app_localizations.dart';
import '../../models/cart_item.dart';
import '../../models/product.dart';
import '../../services/cart_service.dart';
import '../../widgets/app_network_image.dart';
import '../../services/favorite_service.dart';
import '../../widgets/auth_guard.dart';
import '../../widgets/cart_added_bottom_bar.dart';
import '../../widgets/page_transitions.dart';
import '../cart/checkout_flow_screen.dart';
import '../cart/cart_screen.dart';


// ── Design tokens ──────────────────────────────────────────────────────────
const _white        = Color(0xFFFFFFFF);
const _divider      = Color(0xFFEEF0F4);
const _border       = Color(0xFFE2E6EF);
const _textPrimary  = Color(0xFF111827);
const _textSub      = Color(0xFF6B7280);
const _textHint     = Color(0xFF9CA3AF);
const _accent       = Color(0xFF2563EB);
const _accentLight  = Color(0xFFEFF4FF);
const _accentDark   = Color(0xFF1D4ED8);
const _green        = Color(0xFF16A34A);
const _greenLight   = Color(0xFFDCFCE7);
const _red          = Color(0xFFDC2626);
const _redLight     = Color(0xFFFEE2E2);
const _amber        = Color(0xFFF59E0B);
const _shadow       = Color(0x0A000000);

class ProductDetailScreen extends StatefulWidget {
  const ProductDetailScreen({super.key, required this.product});

  final Product product;

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen>
    with SingleTickerProviderStateMixin {
  static const String _reviewsStoragePrefix = 'product_reviews_v1_';

  int _galleryIndex = 0;
  int _quantity     = 1;
  int _storageIndex = 0;
  int _colorIndex   = 0;
  int _conditionIndex = 0;
  bool _descriptionExpanded = false;
  bool _isReviewSheetOpen   = false;
  final List<_ReviewEntry> _reviews = [];

  late final AnimationController _fadeCtrl;
  late final Animation<double> _fadeAnim;

  String get _reviewsStorageKey =>
      '$_reviewsStoragePrefix${widget.product.id}';

  @override
  void initState() {
    super.initState();
    _loadSavedReviews();
    _fadeCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    )..forward();
    _fadeAnim = CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeOut);
  }

  @override
  void dispose() {
    _fadeCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadSavedReviews() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw   = prefs.getString(_reviewsStorageKey);
      if (raw == null || raw.isEmpty) return;
      final decoded = jsonDecode(raw);
      if (decoded is! List) return;
      final loaded = decoded
          .whereType<Map>()
          .map((item) =>
              _ReviewEntry.fromMap(Map<String, dynamic>.from(item)))
          .toList();
      if (!mounted || loaded.isEmpty) return;
      setState(() {
        _reviews
          ..clear()
          ..addAll(loaded);
      });
    } catch (_) {}
  }

  Future<void> _persistReviews() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final payload =
          _reviews.take(60).map((r) => r.toMap()).toList();
      await prefs.setString(_reviewsStorageKey, jsonEncode(payload));
    } catch (_) {}
  }

  static const Map<String, Color> _namedColors = {
    'black':             Color(0xFF111111),
    'graphite':          Color(0xFF23272F),
    'white':             Color(0xFFF8F8F8),
    'silver':            Color(0xFFD1D5DB),
    'grey':              Color(0xFF9CA3AF),
    'gray':              Color(0xFF9CA3AF),
    'blue':              Color(0xFF3B82F6),
    'green':             Color(0xFF22C55E),
    'red':               Color(0xFFEF4444),
    'gold':              Color(0xFFEAB308),
    'natural titanium':  Color(0xFFD6D3D1),
    'white titanium':    Color(0xFFE5E7EB),
    'black titanium':    Color(0xFF111827),
    'desert titanium':   Color(0xFFBFA58A),
  };

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
        .map((s) => s.trim().replaceAll("'", '').replaceAll('"', ''))
        .where((s) => s.isNotEmpty)
        .toList();
  }

  List<String> _buildGallery(Product product, {String? preferredImage}) {
    final images  = <String>[];
    final preferred = preferredImage?.trim();
    if (preferred != null && preferred.isNotEmpty) images.add(preferred);
    if (product.thumbnailUrl?.isNotEmpty == true &&
        !images.contains(product.thumbnailUrl!)) {
      images.add(product.thumbnailUrl!);
    }
    if (product.imageUrl?.isNotEmpty == true &&
        !images.contains(product.imageUrl!)) {
      images.add(product.imageUrl!);
    }
    for (final url in product.imageGallery) {
      if (url.isNotEmpty && !images.contains(url)) images.add(url);
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
    var v = raw.trim();
    if (v.isEmpty || v == 'null') return '';
    if (v.startsWith('[') && v.endsWith(']')) {
      v = v.substring(1, v.length - 1).trim();
    }
    return v.replaceAll("'", '').replaceAll('"', '');
  }

  List<ProductVariant> _activeVariants(Product p) =>
      p.variants.where((v) => v.isActive).toList();

  List<String> _variantValues(
    List<ProductVariant> variants,
    String Function(ProductVariant) sel,
  ) {
    final seen   = <String>{};
    final values = <String>[];
    for (final v in variants) {
      final value = sel(v).trim();
      if (value.isEmpty) continue;
      if (seen.add(value.toLowerCase())) values.add(value);
    }
    return values;
  }

  ProductVariant? _resolveSelectedVariant(
    List<ProductVariant> variants,
    String? storage,
    String? color,
    String? condition,
  ) {
    if (variants.isEmpty) return null;

    bool matches(ProductVariant v,
        {bool s = true, bool c = true, bool cond = true}) {
      if (s && storage != null && v.storageCapacity != storage) return false;
      if (c && color   != null && v.color            != color)   return false;
      if (cond && condition != null && v.condition   != condition) return false;
      return true;
    }

    for (final v in variants) { if (matches(v)) return v; }
    for (final v in variants) { if (matches(v, cond: false)) return v; }
    for (final v in variants) { if (matches(v, c: false, cond: false)) return v; }
    for (final v in variants) { if (matches(v, s: false, cond: false)) return v; }
    return variants.first;
  }

  String _selectedVariantLabel({
    String? storage,
    String? color,
    String? condition,
  }) {
    final parts = [
      if (color     != null && color.isNotEmpty)     color,
      if (storage   != null && storage.isNotEmpty)   storage,
      if (condition != null && condition.isNotEmpty) condition,
    ];
    return parts.join(' / ');
  }

  double _discountPercent(Product p) {
    if (!p.hasDiscount || p.price <= 0) return 0;
    return ((p.discount ?? 0) / p.price) * 100;
  }

  String _economicsBadge(Product p) {
    final cost      = p.price * 0.66;
    final profit    = p.salePrice - cost;
    final margin    = p.salePrice <= 0 ? 0.0 : (profit / p.salePrice) * 100;
    if (margin >= 28) return 'High Margin';
    if (margin >= 18) return 'Good Margin';
    return 'Lean Margin';
  }

  List<String> _featureBullets(Product p) {
    final bullets = <String>[
      if (p.categoryName?.trim().isNotEmpty == true)
        '${p.categoryName!.trim()} product for reliable daily use.',
      if (p.warranty?.trim().isNotEmpty == true)
        'Warranty: ${p.warranty!.trim()}.',
      if (p.country?.trim().isNotEmpty == true)
        'Available for ${p.country!.trim()} market.',
      if (p.condition?.trim().isNotEmpty == true)
        'Condition: ${_cleanValue(p.condition)}.',
    ];
    final desc = _cleanValue(p.description);
    if (desc.isNotEmpty) {
      bullets.addAll(
        desc
            .split(RegExp(r'[\.\n]'))
            .map((s) => s.trim())
            .where((s) => s.isNotEmpty)
            .take(3),
      );
    }
    if (bullets.isEmpty) {
      bullets.addAll([
        'Competitively priced for maximum value.',
        'Transparent pricing with no hidden fees.',
        'Quick checkout and fast delivery.',
      ]);
    }
    return bullets.take(4).toList();
  }

  Future<void> _addToCartWithGuard(
    Product product, {
    required int quantity,
    ProductVariant? variant,
    String? variantLabel,
  }) async {
    final ok = await ensureLoggedIn(context,
        message: 'Please login or register to add items to your cart.');
    if (!ok || !mounted) return;
    CartService.instance.add(
      product,
      quantity:        quantity,
      variant:         variantLabel?.isEmpty ?? true ? null : variantLabel,
      variantId:       variant?.id,
      variantImageUrl: variant?.imageUrl,
      variantStock:    variant?.stock,
      unitPrice:       variant?.price,
    );
    await showCartAddedBottomBar(context);
  }

  Future<void> _buyNowWithGuard(
    Product product, {
    required int quantity,
    ProductVariant? variant,
    String? variantLabel,
  }) async {
    final ok = await ensureLoggedIn(context,
        message: 'Please login or register to buy now.');
    if (!ok || !mounted) return;
    final checkoutItem = CartItem(
      product:         product,
      quantity:        quantity,
      variant:         variantLabel?.isEmpty ?? true ? null : variantLabel,
      variantId:       variant?.id,
      variantImageUrl: variant?.imageUrl,
      variantStock:    variant?.stock,
      unitPrice:       variant?.price,
    );
    Navigator.of(context)
        .push(fadeSlideRoute(CheckoutFlowScreen(items: [checkoutItem])));
  }

  double _displayRating(Product p) {
    final baseCount = p.ratingCount;
    final baseTotal = p.rating * baseCount;
    final localTotal =
        _reviews.fold<double>(0, (sum, r) => sum + r.rating);
    final totalCount = baseCount + _reviews.length;
    if (totalCount == 0) return 0;
    return (baseTotal + localTotal) / totalCount;
  }

  int _displayRatingCount(Product p) => p.ratingCount + _reviews.length;

  // ignore: unused_element
  Future<void> _openReviewSheet(Product product) async {
    if (_isReviewSheetOpen) return;
    final ok = await ensureLoggedIn(context,
        message: 'Please login or register to leave a review.');
    if (!ok || !mounted) return;
    _isReviewSheetOpen = true;
    _ReviewEntry? result;
    try {
      result = await showModalBottomSheet<_ReviewEntry>(
        context:              context,
        isScrollControlled:   true,
        backgroundColor:      Colors.transparent,
        builder: (_) =>
            _ReviewComposerSheet(productName: product.name),
      );
    } finally {
      _isReviewSheetOpen = false;
    }
    final newReview = result;
    if (!mounted || newReview == null) return;
    setState(() => _reviews.insert(0, newReview));
    await _persistReviews();
  }

  // ignore: unused_element
  Future<void> _openAllReviewsSheet(Product product) async {
    await showModalBottomSheet<void>(
      context:            context,
      isScrollControlled: true,
      backgroundColor:    Colors.transparent,
      builder: (_) => _AllReviewsSheet(
        productName:   product.name,
        averageRating: _displayRating(product),
        ratingCount:   _displayRatingCount(product),
        reviews:       _reviews,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l                = AppLocalizations.of(context);
    final product          = widget.product;
    final variantRows      = _activeVariants(product);
    final storageOptions   = variantRows.isNotEmpty
        ? _variantValues(variantRows, (v) => v.storageCapacity)
        : _splitOptions(product.storageCapacity);
    final colorOptions     = variantRows.isNotEmpty
        ? _variantValues(variantRows, (v) => v.color)
        : _splitOptions(product.color);
    final conditionOptions = variantRows.isNotEmpty
        ? _variantValues(variantRows, (v) => v.condition)
        : _splitOptions(product.condition);

    if (_storageIndex   >= storageOptions.length)   _storageIndex   = 0;
    if (_colorIndex     >= colorOptions.length)     _colorIndex     = 0;
    if (_conditionIndex >= conditionOptions.length) _conditionIndex = 0;

    final selectedStorage   = storageOptions.isNotEmpty
        ? storageOptions[_storageIndex]   : null;
    final selectedColor     = colorOptions.isNotEmpty
        ? colorOptions[_colorIndex]       : null;
    final selectedCondition = conditionOptions.isNotEmpty
        ? conditionOptions[_conditionIndex] : null;

    final selectedVariantEntity = variantRows.isNotEmpty
        ? _resolveSelectedVariant(
            variantRows, selectedStorage, selectedColor, selectedCondition)
        : null;
    final selectedVariant = _selectedVariantLabel(
      storage:   selectedVariantEntity?.storageCapacity ?? selectedStorage,
      color:     selectedVariantEntity?.color           ?? selectedColor,
      condition: selectedVariantEntity?.condition       ?? selectedCondition,
    );

    final gallery   = _buildGallery(product,
        preferredImage: selectedVariantEntity?.imageUrl);
    final safeIndex = gallery.isEmpty
        ? 0
        : _galleryIndex.clamp(0, gallery.length - 1);
    final imageUrl  = gallery.isEmpty ? null : gallery[safeIndex];

    final unitPrice  = selectedVariantEntity?.price ?? product.salePrice;
    final oldPrice   = selectedVariantEntity == null &&
            product.hasDiscount &&
            unitPrice < product.price
        ? product.price
        : null;
    final stock      = selectedVariantEntity?.stock ?? product.stock;
    final isOutOfStock = stock != null && stock <= 0;
    final quantity   =
        stock != null && stock > 0 ? _quantity.clamp(1, stock) : _quantity;
    final total      = unitPrice * quantity;
    final discountPct = _discountPercent(product);
    final tagText    = _formatTag(product.tag);
    final statusText = _formatTag(product.status);
    final brand      = product.brand?.trim().isNotEmpty == true
        ? product.brand!.trim()
        : null;
    final categoryText = product.categoryName?.trim().isNotEmpty == true
        ? product.categoryName!.trim()
        : null;
    final descriptionText = _cleanValue(product.description);
    final featureBullets  = _featureBullets(product);
    final economicsBadge  = _economicsBadge(product);
    final rating          = _displayRating(product);
    final ratingCount     = _displayRatingCount(product);

    return AnimatedBuilder(
      animation: FavoriteService.instance,
      builder: (context, _) {
        final isFavorite = FavoriteService.instance.contains(product);

        return Theme(
          data: Theme.of(context).copyWith(
            scaffoldBackgroundColor: Theme.of(context).scaffoldBackgroundColor,
            textTheme:
                GoogleFonts.soraTextTheme(Theme.of(context).textTheme),
          ),
          child: Scaffold(
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            body: FadeTransition(
              opacity: _fadeAnim,
              child: SafeArea(
                bottom: false,
                child: Column(
                  children: [
                    // ── App Bar ──────────────────────────────────────────
                    _AppBar(
                      title:      l.productDetails,
                      isFavorite: isFavorite,
                      onBack:     () => Navigator.of(context).pop(),
                      onFavorite: () =>
                          FavoriteService.instance.toggle(product),
                      onCartTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(builder: (_) => const CartScreen()),
                        );
                      },
                    ),

                    // ── Scrollable body ──────────────────────────────────
                    Expanded(
                      child: SingleChildScrollView(
                        physics: const BouncingScrollPhysics(),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Image gallery
                            _GallerySection(
                              imageUrl:      imageUrl,
                              gallery:       gallery,
                              selectedIndex: safeIndex,
                              stockLabel: isOutOfStock
                                  ? l.outOfStock
                                  : l.inStock,
                              isOutOfStock: isOutOfStock,
                              discountLabel: discountPct > 0
                                  ? '-${discountPct.round()}%'
                                  : null,
                              onSelectIndex: (i) =>
                                  setState(() => _galleryIndex = i),
                            ),

                            // ── Content area ─────────────────────────────
                            Padding(
                              padding:
                                  const EdgeInsets.fromLTRB(16, 0, 16, 100),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const SizedBox(height: 16),

                                  // Tags row
                                  _TagsRow(
                                    category:      categoryText,
                                    brand:         brand,
                                    tag:           tagText.isNotEmpty
                                        ? tagText
                                        : null,
                                    status:        statusText.isNotEmpty
                                        ? statusText
                                        : null,
                                    economicsBadge: economicsBadge,
                                  ),
                                  const SizedBox(height: 10),

                                  // Product name
                                  Text(
                                    product.name,
                                    style: GoogleFonts.inter(
                                      fontSize:   24,
                                      fontWeight: FontWeight.w700,
                                      color:      _textPrimary,
                                      height:     1.2,
                                    ),
                                  ),
                                  const SizedBox(height: 10),

                                  // Rating row
                                  if (ratingCount > 0) ...[
                                    _RatingRow(
                                      rating:      rating,
                                      ratingCount: ratingCount,
                                    ),
                                    const SizedBox(height: 12),
                                  ],

                                  // ── Price + Quantity card ─────────────
                                  _PriceQuantityCard(
                                    unitPrice:   unitPrice,
                                    oldPrice:    oldPrice,
                                    quantity:    quantity,
                                    stock:       stock,
                                    isOutOfStock: isOutOfStock,
                                    total:       total,
                                    onMinus: () {
                                      if (quantity <= 1) return;
                                      setState(() => _quantity = quantity - 1);
                                    },
                                    onPlus: () {
                                      if (isOutOfStock) return;
                                      if (stock != null && quantity >= stock) {
                                        return;
                                      }
                                      setState(() => _quantity = quantity + 1);
                                    },
                                  ),
                                  const SizedBox(height: 16),

                                  // ── Variants section ──────────────────
                                  if (storageOptions.isNotEmpty ||
                                      colorOptions.isNotEmpty ||
                                      conditionOptions.isNotEmpty) ...[
                                    _SectionTitle(title: l.filter),
                                    const SizedBox(height: 12),
                                    _Card(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          if (storageOptions.isNotEmpty) ...[
                                            _VariantRow(
                                              label: 'Size / Model',
                                              selected: storageOptions[
                                                  _storageIndex],
                                            ),
                                            const SizedBox(height: 10),
                                            Wrap(
                                              spacing:    8,
                                              runSpacing: 8,
                                              children: List.generate(
                                                storageOptions.length,
                                                (i) => _ChipButton(
                                                  label:    storageOptions[i],
                                                  selected: _storageIndex == i,
                                                  onTap: () => setState(
                                                      () => _storageIndex = i),
                                                ),
                                              ),
                                            ),
                                            if (colorOptions.isNotEmpty ||
                                                conditionOptions.isNotEmpty) ...[
                                              const SizedBox(height: 16),
                                              const Divider(
                                                  color: _divider, height: 1),
                                              const SizedBox(height: 16),
                                            ],
                                          ],
                                          if (colorOptions.isNotEmpty) ...[
                                            _VariantRow(
                                              label:    'Color',
                                              selected: colorOptions[_colorIndex],
                                            ),
                                            const SizedBox(height: 10),
                                            Wrap(
                                              spacing:    8,
                                              runSpacing: 8,
                                              children: List.generate(
                                                colorOptions.length,
                                                (i) => _ColorChip(
                                                  label:    colorOptions[i],
                                                  color: _colorFromName(
                                                      colorOptions[i]),
                                                  selected: _colorIndex == i,
                                                  onTap: () => setState(
                                                      () => _colorIndex = i),
                                                ),
                                              ),
                                            ),
                                            if (conditionOptions.isNotEmpty) ...[
                                              const SizedBox(height: 16),
                                              const Divider(
                                                  color: _divider, height: 1),
                                              const SizedBox(height: 16),
                                            ],
                                          ],
                                          if (conditionOptions.isNotEmpty) ...[
                                            _VariantRow(
                                              label: 'Condition',
                                              selected: conditionOptions[
                                                  _conditionIndex],
                                            ),
                                            const SizedBox(height: 10),
                                            Wrap(
                                              spacing:    8,
                                              runSpacing: 8,
                                              children: List.generate(
                                                conditionOptions.length,
                                                (i) => _ChipButton(
                                                  label: conditionOptions[i],
                                                  selected:
                                                      _conditionIndex == i,
                                                  onTap: () => setState(
                                                      () => _conditionIndex = i),
                                                ),
                                              ),
                                            ),
                                          ],
                                          if (selectedVariant.isNotEmpty) ...[
                                            const SizedBox(height: 16),
                                            const Divider(
                                                color: _divider, height: 1),
                                            const SizedBox(height: 12),
                                            Row(
                                              children: [
                                                const Icon(
                                                  Icons.tune_rounded,
                                                  size:  15,
                                                  color: _textHint,
                                                ),
                                                const SizedBox(width: 6),
                                                Expanded(
                                                  child: Text(
                                                    'Selected: $selectedVariant',
                                                    style: const TextStyle(
                                                      fontSize:   12.5,
                                                      color:      _textSub,
                                                      fontWeight: FontWeight.w500,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ],
                                      ),
                                    ),
                                    const SizedBox(height: 16),
                                  ],

                                  // ── Trust strip ───────────────────────
                                  _TrustStrip(),
                                  const SizedBox(height: 16),

                                  // ── Description ───────────────────────
                                  _SectionTitle(title: l.description),
                                  const SizedBox(height: 12),
                                  _Card(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        _DescriptionBlock(
                                          text: descriptionText.isNotEmpty
                                              ? descriptionText
                                              : 'No description available.',
                                          expanded: _descriptionExpanded,
                                          onToggle:
                                              descriptionText.length > 180
                                                  ? () => setState(() =>
                                                      _descriptionExpanded =
                                                          !_descriptionExpanded)
                                                  : null,
                                        ),
                                        if (featureBullets.isNotEmpty) ...[
                                          const SizedBox(height: 16),
                                          const Divider(
                                              color: _divider, height: 1),
                                          const SizedBox(height: 16),
                                          _FeatureBulletList(
                                              items: featureBullets),
                                        ],
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // ── Bottom purchase bar ──────────────────────────────
                    SafeArea(
                      top: false,
                      child: _BottomBar(
                        quantity:    quantity,
                        total:       total,
                        canPurchase: !isOutOfStock,
                        onAddToCart: () => _addToCartWithGuard(
                          product,
                          quantity:     quantity,
                          variant:      selectedVariantEntity,
                          variantLabel: selectedVariant,
                        ),
                        onBuyNow: () => _buyNowWithGuard(
                          product,
                          quantity:     quantity,
                          variant:      selectedVariantEntity,
                          variantLabel: selectedVariant,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  App Bar
// ─────────────────────────────────────────────────────────────────────────────
class _AppBar extends StatelessWidget {
  const _AppBar({
    required this.title,
    required this.isFavorite,
    required this.onBack,
    required this.onFavorite,
    required this.onCartTap,
  });

  final String      title;
  final bool        isFavorite;
  final VoidCallback onBack;
  final VoidCallback onFavorite;
  final VoidCallback onCartTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      height:  56,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        color: _white,
        border: Border(
          bottom: BorderSide(color: _border.withAlpha((0.6 * 255).round())),
        ),
      ),
      child: Row(
        children: [
          _IconBtn(
            icon:  Icons.arrow_back_ios_new_rounded,
            onTap: onBack,
          ),
          Expanded(
            child: Text(
              title,
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize:   16,
                fontWeight: FontWeight.w700,
                color:      _textPrimary,
              ),
            ),
          ),
          _IconBtn(
            icon:      isFavorite
                ? Icons.favorite_rounded
                : Icons.favorite_border_rounded,
            iconColor: isFavorite ? _red : _textSub,
            bg:        isFavorite ? _redLight : null,
            onTap:     onFavorite,
          ),
          const SizedBox(width: 4),
          _CartIconBtn(onTap: onCartTap),
        ],
      ),
    );
  }
}

class _CartIconBtn extends StatelessWidget {
  const _CartIconBtn({required this.onTap});

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
            _IconBtn(
              icon: Icons.shopping_cart_outlined,
              onTap: onTap,
            ),
            if (count > 0)
              Positioned(
                top: 4,
                right: 4,
                child: IgnorePointer(
                  child: Container(
                    constraints: const BoxConstraints(
                      minWidth: 16,
                      minHeight: 16,
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    decoration: BoxDecoration(
                      color: _accent,
                      borderRadius: BorderRadius.circular(999),
                      border: Border.all(color: Colors.white, width: 1.5),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      '$count',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 8,
                        fontWeight: FontWeight.w800,
                      ),
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

class _IconBtn extends StatelessWidget {
  const _IconBtn({
    required this.icon,
    required this.onTap,
    this.iconColor = _textPrimary,
    this.bg,
  });

  final IconData    icon;
  final VoidCallback onTap;
  final Color       iconColor;
  final Color?      bg;

  @override
  Widget build(BuildContext context) {
    return Material(
      color:        Colors.transparent,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap:        onTap,
        borderRadius: BorderRadius.circular(12),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          width:  40,
          height: 40,
          decoration: BoxDecoration(
            color:        bg,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, size: 20, color: iconColor),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  Gallery Section
// ─────────────────────────────────────────────────────────────────────────────
class _GallerySection extends StatelessWidget {
  const _GallerySection({
    required this.imageUrl,
    required this.gallery,
    required this.selectedIndex,
    required this.stockLabel,
    required this.isOutOfStock,
    required this.onSelectIndex,
    this.discountLabel,
  });

  final String?             imageUrl;
  final List<String>        gallery;
  final int                 selectedIndex;
  final String              stockLabel;
  final bool                isOutOfStock;
  final String?             discountLabel;
  final ValueChanged<int>   onSelectIndex;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: _white,
      child: Column(
        children: [
          // Main image
          Stack(
            children: [
              Container(
                height: 300,
                width:  double.infinity,
                color:  const Color(0xFFF9FAFB),
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 260),
                  switchInCurve:  Curves.easeOutCubic,
                  switchOutCurve: Curves.easeInCubic,
                  transitionBuilder: (child, anim) => FadeTransition(
                    opacity: anim,
                    child: ScaleTransition(
                      scale: Tween<double>(begin: 0.96, end: 1.0)
                          .animate(anim),
                      child: child,
                    ),
                  ),
                  child: imageUrl == null || imageUrl!.isEmpty
                      ? const _ImageFallback(
                          key: ValueKey('empty'), size: 64)
                      : Padding(
                          padding: const EdgeInsets.all(20),
                          child: AppNetworkImage(
                            imageUrl!,
                            key: ValueKey(imageUrl),
                            fit: BoxFit.contain,
                            errorWidget: (context, url, error) =>
                                const _ImageFallback(
                                    key: ValueKey('err'), size: 64),
                          ),
                        ),
                ),
              ),

              // Top badges
              Positioned(
                top:  12,
                left: 12,
                child: Row(
                  children: [
                    if (discountLabel != null)
                      _Badge(
                        label: discountLabel!,
                        bg:    _red,
                        fg:    Colors.white,
                      ),
                    if (discountLabel != null)
                      const SizedBox(width: 6),
                    _StockBadge(
                      label:       stockLabel,
                      isOutOfStock: isOutOfStock,
                    ),
                  ],
                ),
              ),

              // Photo count
              if (gallery.length > 1)
                Positioned(
                  top:   12,
                  right: 12,
                  child: _Badge(
                    label: '${gallery.length} photos',
                    bg:    _white,
                    fg:    _textSub,
                    border: _border,
                  ),
                ),
            ],
          ),

          // Dot indicators
          if (gallery.length > 1) ...[
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(gallery.length, (i) {
                final sel = i == selectedIndex;
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin:  const EdgeInsets.symmetric(horizontal: 3),
                  width:   sel ? 20 : 6,
                  height:  6,
                  decoration: BoxDecoration(
                    color:        sel ? _accent : _border,
                    borderRadius: BorderRadius.circular(99),
                  ),
                );
              }),
            ),
            const SizedBox(height: 10),
          ],

          // Thumbnail rail
          if (gallery.length > 1) ...[
            const SizedBox(height: 2),
            SizedBox(
              height: 70,
              child: ListView.separated(
                scrollDirection:    Axis.horizontal,
                padding:            const EdgeInsets.symmetric(horizontal: 14),
                separatorBuilder:   (context, index) => const SizedBox(width: 8),
                itemCount:          gallery.length,
                itemBuilder: (context, i) {
                  final sel = i == selectedIndex;
                  return GestureDetector(
                    onTap: () => onSelectIndex(i),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 160),
                      width:  62,
                      padding: const EdgeInsets.all(5),
                      decoration: BoxDecoration(
                        color:        sel ? _accentLight : _white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: sel ? _accent : _border,
                          width: sel ? 1.5 : 1,
                        ),
                      ),
                      child: AppNetworkImage(
                        gallery[i],
                        fit: BoxFit.contain,
                        errorWidget: (context, url, error) =>
                            const _ImageFallback(size: 18),
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 12),
          ],

          // Bottom border
          Container(height: 1, color: _divider),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  Tags Row
// ─────────────────────────────────────────────────────────────────────────────
class _TagsRow extends StatelessWidget {
  const _TagsRow({
    required this.category,
    required this.brand,
    required this.tag,
    required this.status,
    required this.economicsBadge,
  });

  final String? category;
  final String? brand;
  final String? tag;
  final String? status;
  final String  economicsBadge;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing:    6,
      runSpacing: 6,
      children: [
        if (category != null)
          _Pill(label: category!, bg: _accentLight, fg: _accent),
        if (brand != null)
          _Pill(label: brand!, bg: const Color(0xFFF3F4F6), fg: _textSub),
        if (tag != null)
          _Pill(label: tag!, bg: const Color(0xFFFFF7ED), fg: const Color(0xFFEA580C)),
        _Pill(
          label: economicsBadge,
          bg:    const Color(0xFFF0FDF4),
          fg:    _green,
        ),
      ],
    );
  }
}

class _Pill extends StatelessWidget {
  const _Pill({
    required this.label,
    required this.bg,
    required this.fg,
  });

  final String label;
  final Color  bg;
  final Color  fg;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color:        bg,
        borderRadius: BorderRadius.circular(99),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize:   11.5,
          fontWeight: FontWeight.w600,
          color:      fg,
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  Rating Row
// ─────────────────────────────────────────────────────────────────────────────
class _RatingRow extends StatelessWidget {
  const _RatingRow({required this.rating, required this.ratingCount});

  final double rating;
  final int    ratingCount;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(Icons.star_rounded, size: 16, color: _amber),
        const SizedBox(width: 4),
        Text(
          rating.toStringAsFixed(1),
          style: const TextStyle(
            fontSize:   13.5,
            fontWeight: FontWeight.w700,
            color:      _textPrimary,
          ),
        ),
        const SizedBox(width: 4),
        Text(
          '($ratingCount)',
          style: const TextStyle(fontSize: 13, color: _textSub),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  Price + Quantity Card  ← the central focus of the redesign
// ─────────────────────────────────────────────────────────────────────────────
class _PriceQuantityCard extends StatelessWidget {
  const _PriceQuantityCard({
    required this.unitPrice,
    required this.oldPrice,
    required this.quantity,
    required this.stock,
    required this.isOutOfStock,
    required this.total,
    required this.onMinus,
    required this.onPlus,
  });

  final double       unitPrice;
  final double?      oldPrice;
  final int          quantity;
  final int?         stock;
  final bool         isOutOfStock;
  final double       total;
  final VoidCallback onMinus;
  final VoidCallback onPlus;

  @override
  Widget build(BuildContext context) {
    return Container(
      width:   double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color:        _white,
        borderRadius: BorderRadius.circular(16),
        border:       Border.all(color: _border),
        boxShadow: [
          BoxShadow(
            color:      _shadow,
            blurRadius: 8,
            offset:     const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Unit price row ─────────────────────────────────────────────
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'UNIT PRICE',
                      style: TextStyle(
                        fontSize:      10.5,
                        fontWeight:    FontWeight.w700,
                        color:         _textHint,
                        letterSpacing: 0.8,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          '\$${unitPrice.toStringAsFixed(2)}',
                          style: GoogleFonts.inter(
                            fontSize:   30,
                            fontWeight: FontWeight.w800,
                            color:      _accent,
                            height:     1,
                          ),
                        ),
                        const SizedBox(width: 6),
                        if (oldPrice != null) ...[
                          Padding(
                            padding: const EdgeInsets.only(bottom: 3),
                            child: Text(
                              '\$${oldPrice!.toStringAsFixed(2)}',
                              style: const TextStyle(
                                fontSize:   13,
                                color:      _textHint,
                                decoration: TextDecoration.lineThrough,
                              ),
                            ),
                          ),
                        ],
                        Padding(
                          padding: const EdgeInsets.only(bottom: 3, left: 4),
                          child: Text(
                            '/ unit',
                            style: const TextStyle(
                              fontSize:   12,
                              color:      _textSub,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              // Stock badge
              _StockBadge(
                label:        isOutOfStock ? AppLocalizations.of(context).outOfStock : AppLocalizations.of(context).inStock,
                isOutOfStock: isOutOfStock,
              ),
            ],
          ),

          const SizedBox(height: 16),
          Container(height: 1, color: _divider),
          const SizedBox(height: 14),

          // ── Quantity + Total row ───────────────────────────────────────
          Row(
            children: [
              // Left: Quantity control
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'QUANTITY',
                    style: TextStyle(
                      fontSize:      10.5,
                      fontWeight:    FontWeight.w700,
                      color:         _textHint,
                      letterSpacing: 0.8,
                    ),
                  ),
                  const SizedBox(height: 8),
                  _QuantityControl(
                    quantity:  quantity,
                    onMinus:   onMinus,
                    onPlus:    onPlus,
                    disabled:  isOutOfStock,
                  ),
                ],
              ),

              const SizedBox(width: 16),
              Container(width: 1, height: 52, color: _divider),
              const SizedBox(width: 16),

              // Right: Stock info + Total
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (stock != null && !isOutOfStock)
                      Text(
                        '$stock in stock',
                        style: const TextStyle(
                          fontSize:   11.5,
                          color:      _textSub,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    if (isOutOfStock)
                      const Text(
                        'Currently unavailable',
                        style: TextStyle(
                          fontSize:   11.5,
                          color:      _red,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    const SizedBox(height: 4),
                    const Text(
                      'TOTAL',
                      style: TextStyle(
                        fontSize:      10.5,
                        fontWeight:    FontWeight.w700,
                        color:         _textHint,
                        letterSpacing: 0.8,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '\$${total.toStringAsFixed(2)}',
                      style: GoogleFonts.inter(
                        fontSize:   20,
                        fontWeight: FontWeight.w800,
                        color:      _textPrimary,
                        height:     1,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  Quantity Control
// ─────────────────────────────────────────────────────────────────────────────
class _QuantityControl extends StatelessWidget {
  const _QuantityControl({
    required this.quantity,
    required this.onMinus,
    required this.onPlus,
    this.disabled = false,
  });

  final int          quantity;
  final VoidCallback onMinus;
  final VoidCallback onPlus;
  final bool         disabled;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color:        const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(12),
        border:       Border.all(color: _border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _QBtn(
            icon:     Icons.remove_rounded,
            onTap:    onMinus,
            disabled: quantity <= 1 || disabled,
          ),
          Container(
            width:  44,
            alignment: Alignment.center,
            child: Text(
              '$quantity',
              style: const TextStyle(
                fontSize:   16,
                fontWeight: FontWeight.w700,
                color:      _textPrimary,
              ),
            ),
          ),
          _QBtn(
            icon:     Icons.add_rounded,
            onTap:    onPlus,
            disabled: disabled,
          ),
        ],
      ),
    );
  }
}

class _QBtn extends StatelessWidget {
  const _QBtn({
    required this.icon,
    required this.onTap,
    this.disabled = false,
  });

  final IconData    icon;
  final VoidCallback onTap;
  final bool        disabled;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: disabled ? null : onTap,
      child: Container(
        width:  38,
        height: 38,
        alignment: Alignment.center,
        child: Icon(
          icon,
          size:  18,
          color: disabled ? _textHint : _textPrimary,
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  Trust Strip
// ─────────────────────────────────────────────────────────────────────────────
class _TrustStrip extends StatelessWidget {
  const _TrustStrip();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color:        _white,
        borderRadius: BorderRadius.circular(14),
        border:       Border.all(color: _border),
      ),
      child: Row(
        children: const [
          Expanded(
            child: _TrustItem(
              icon:  Icons.verified_user_outlined,
              label: 'Secure\nCheckout',
              color: Color(0xFF2563EB),
            ),
          ),
          _VDivider(),
          Expanded(
            child: _TrustItem(
              icon:  Icons.keyboard_return_rounded,
              label: '30-Day\nReturns',
              color: Color(0xFF16A34A),
            ),
          ),
          _VDivider(),
          Expanded(
            child: _TrustItem(
              icon:  Icons.local_shipping_outlined,
              label: 'Fast\nShipping',
              color: Color(0xFF7C3AED),
            ),
          ),
        ],
      ),
    );
  }
}

class _VDivider extends StatelessWidget {
  const _VDivider();

  @override
  Widget build(BuildContext context) {
    return Container(
      width:  1,
      height: 36,
      color:  _divider,
    );
  }
}

class _TrustItem extends StatelessWidget {
  const _TrustItem({
    required this.icon,
    required this.label,
    required this.color,
  });

  final IconData icon;
  final String   label;
  final Color    color;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width:  34,
          height: 34,
          decoration: BoxDecoration(
            color:        color.withAlpha((0.10 * 255).round()),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, size: 17, color: color),
        ),
        const SizedBox(height: 6),
        Text(
          label,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize:   10.5,
            fontWeight: FontWeight.w600,
            color:      _textSub,
            height:     1.3,
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  Variant helpers
// ─────────────────────────────────────────────────────────────────────────────
class _VariantRow extends StatelessWidget {
  const _VariantRow({required this.label, required this.selected});

  final String label;
  final String selected;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize:   14,
            fontWeight: FontWeight.w600,
            color:      _textPrimary,
          ),
        ),
        const SizedBox(width: 6),
        const Text('·', style: TextStyle(color: _textHint)),
        const SizedBox(width: 6),
        Text(
          selected,
          style: const TextStyle(
            fontSize:   13.5,
            color:      _accent,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

class _ChipButton extends StatelessWidget {
  const _ChipButton({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String       label;
  final bool         selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 140),
        padding:  const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color:        selected ? _accent       : const Color(0xFFF9FAFB),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: selected ? _accent : _border,
            width: selected ? 1.5     : 1,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize:   13,
            fontWeight: FontWeight.w600,
            color:      selected ? Colors.white : _textPrimary,
          ),
        ),
      ),
    );
  }
}

class _ColorChip extends StatelessWidget {
  const _ColorChip({
    required this.label,
    required this.color,
    required this.selected,
    required this.onTap,
  });

  final String       label;
  final Color        color;
  final bool         selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final needsBorder = color.computeLuminance() > 0.85;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 140),
        padding:  const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
        decoration: BoxDecoration(
          color:        selected ? _accentLight : const Color(0xFFF9FAFB),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: selected ? _accent : _border,
            width: selected ? 1.5     : 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width:  20,
              height: 20,
              decoration: BoxDecoration(
                color:  color,
                shape:  BoxShape.circle,
                border: Border.all(
                  color: needsBorder ? _border : Colors.white54,
                ),
              ),
            ),
            const SizedBox(width: 7),
            Text(
              label,
              style: TextStyle(
                fontSize:   12.5,
                fontWeight: FontWeight.w600,
                color:      selected ? _accentDark : _textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  Generic helpers
// ─────────────────────────────────────────────────────────────────────────────
class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: GoogleFonts.inter(
        fontSize:   15,
        fontWeight: FontWeight.w700,
        color:      _textPrimary,
      ),
    );
  }
}

class _Card extends StatelessWidget {
  const _Card({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width:   double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color:        _white,
        borderRadius: BorderRadius.circular(14),
        border:       Border.all(color: _border),
        boxShadow: [
          BoxShadow(
            color:      _shadow,
            blurRadius: 6,
            offset:     const Offset(0, 1),
          ),
        ],
      ),
      child: child,
    );
  }
}

class _Badge extends StatelessWidget {
  const _Badge({
    required this.label,
    required this.bg,
    required this.fg,
    this.border,
  });

  final String label;
  final Color  bg;
  final Color  fg;
  final Color? border;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color:        bg,
        borderRadius: BorderRadius.circular(99),
        border:       border != null ? Border.all(color: border!) : null,
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize:   11.5,
          fontWeight: FontWeight.w700,
          color:      fg,
        ),
      ),
    );
  }
}

class _StockBadge extends StatelessWidget {
  const _StockBadge({
    required this.label,
    required this.isOutOfStock,
  });

  final String label;
  final bool   isOutOfStock;

  @override
  Widget build(BuildContext context) {
    final color = isOutOfStock ? _red   : _green;
    final bg    = isOutOfStock ? _redLight : _greenLight;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color:        bg,
        borderRadius: BorderRadius.circular(99),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width:  6,
            height: 6,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 5),
          Text(
            label,
            style: TextStyle(
              fontSize:   11.5,
              fontWeight: FontWeight.w700,
              color:      color,
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  Description
// ─────────────────────────────────────────────────────────────────────────────
class _DescriptionBlock extends StatelessWidget {
  const _DescriptionBlock({
    required this.text,
    required this.expanded,
    required this.onToggle,
  });

  final String       text;
  final bool         expanded;
  final VoidCallback? onToggle;

  @override
  Widget build(BuildContext context) {
    final shouldCollapse = text.length > 180;
    final visibleText    = !shouldCollapse || expanded
        ? text
        : '${text.substring(0, 180).trimRight()}...';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 160),
          child: Text(
            visibleText,
            key:   ValueKey(visibleText.length),
            style: const TextStyle(
              fontSize: 14,
              height:   1.7,
              color:    _textPrimary,
            ),
          ),
        ),
        if (shouldCollapse && onToggle != null) ...[
          const SizedBox(height: 8),
          GestureDetector(
            onTap: onToggle,
            child: Text(
              expanded ? 'Show less' : 'Read more',
              style: const TextStyle(
                fontSize:   13.5,
                fontWeight: FontWeight.w600,
                color:      _accent,
              ),
            ),
          ),
        ],
      ],
    );
  }
}

class _FeatureBulletList extends StatelessWidget {
  const _FeatureBulletList({required this.items});

  final List<String> items;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Key Features',
          style: TextStyle(
            fontSize:   13.5,
            fontWeight: FontWeight.w700,
            color:      _textPrimary,
          ),
        ),
        const SizedBox(height: 10),
        for (final item in items)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: Container(
                    width:  6,
                    height: 6,
                    decoration: const BoxDecoration(
                      color: _accent,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    item,
                    style: const TextStyle(
                      fontSize: 13.5,
                      height:   1.55,
                      color:    _textSub,
                    ),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  Bottom Bar
// ─────────────────────────────────────────────────────────────────────────────
class _BottomBar extends StatelessWidget {
  const _BottomBar({
    required this.quantity,
    required this.total,
    required this.canPurchase,
    required this.onAddToCart,
    required this.onBuyNow,
  });

  final int          quantity;
  final double       total;
  final bool         canPurchase;
  final VoidCallback onAddToCart;
  final VoidCallback onBuyNow;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 12),
      decoration: BoxDecoration(
        color: _white,
        border: Border(top: BorderSide(color: _border)),
        boxShadow: [
          BoxShadow(
            color:      const Color(0x14000000),
            blurRadius: 16,
            offset:     const Offset(0, -4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // ── Summary row ────────────────────────────────────────────────
          Row(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '$quantity item${quantity == 1 ? '' : 's'} selected',
                    style: const TextStyle(
                      fontSize:   11.5,
                      color:      _textSub,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 1),
                  Text(
                    '\$${total.toStringAsFixed(2)}',
                    style: GoogleFonts.inter(
                      fontSize:   22,
                      fontWeight: FontWeight.w800,
                      color:      _textPrimary,
                      height:     1,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 10),

          // ── Buttons row ────────────────────────────────────────────────
          Row(
            children: [
              // Add to Cart
              Expanded(
                flex: 3,
                child: SizedBox(
                  height: 48,
                  child: ElevatedButton(
                    onPressed: canPurchase ? onAddToCart : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _accent,
                      foregroundColor: Colors.white,
                      elevation:       0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      AppLocalizations.of(context).addToCart,
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize:   14,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),

              // Buy Now
              Expanded(
                flex: 2,
                child: SizedBox(
                  height: 48,
                  child: OutlinedButton(
                    onPressed: canPurchase ? onBuyNow : null,
                    style: OutlinedButton.styleFrom(
                      side:            const BorderSide(color: _accent),
                      foregroundColor: _accent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      AppLocalizations.of(context).buyNow,
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize:   14,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  Image Fallback
// ─────────────────────────────────────────────────────────────────────────────
class _ImageFallback extends StatelessWidget {
  const _ImageFallback({super.key, this.size = 32});

  final double size;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Icon(
        Icons.image_not_supported_outlined,
        size:  size,
        color: _textHint,
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  Star rating row (used in review sheets)
// ─────────────────────────────────────────────────────────────────────────────
class _StarRatingRow extends StatelessWidget {
  const _StarRatingRow({required this.rating, this.iconSize = 18});

  final double rating;
  final double iconSize;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (i) {
        final filled = rating >= i + 1;
        final half   = !filled && rating > i && rating < i + 1;
        return Padding(
          padding: EdgeInsets.only(right: i == 4 ? 0 : 4),
          child: Icon(
            filled ? Icons.star_rounded
                : half ? Icons.star_half_rounded
                : Icons.star_border_rounded,
            size:  iconSize,
            color: _amber,
          ),
        );
      }),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  Review card
// ─────────────────────────────────────────────────────────────────────────────
class _ReviewCard extends StatelessWidget {
  const _ReviewCard({required this.review});

  final _ReviewEntry review;

  @override
  Widget build(BuildContext context) {
    return Container(
      width:   double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color:        _white,
        borderRadius: BorderRadius.circular(14),
        border:       Border.all(color: _border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width:  36,
                height: 36,
                decoration: BoxDecoration(
                  color:        const Color(0xFFF3F4F6),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Center(
                  child: Text(
                    review.author.substring(0, 1).toUpperCase(),
                    style: GoogleFonts.inter(
                      fontSize:   14,
                      fontWeight: FontWeight.w700,
                      color:      _textPrimary,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      review.author,
                      style: const TextStyle(
                        fontSize:   13.5,
                        fontWeight: FontWeight.w600,
                        color:      _textPrimary,
                      ),
                    ),
                    Text(
                      review.formattedDate,
                      style: const TextStyle(fontSize: 11.5, color: _textSub),
                    ),
                  ],
                ),
              ),
              _StarRatingRow(rating: review.rating.toDouble(), iconSize: 14),
            ],
          ),
          if (review.comment.trim().isNotEmpty) ...[
            const SizedBox(height: 10),
            Text(
              review.comment,
              style: const TextStyle(
                fontSize: 13.5,
                height:   1.6,
                color:    _textPrimary,
              ),
            ),
          ],
          if (review.images.isNotEmpty) ...[
            const SizedBox(height: 10),
            Wrap(
              spacing:    6,
              runSpacing: 6,
              children: [
                for (final bytes in review.images)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: SizedBox(
                      width:  80,
                      height: 80,
                      child:  Image.memory(bytes, fit: BoxFit.cover),
                    ),
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  All Reviews Sheet
// ─────────────────────────────────────────────────────────────────────────────
class _AllReviewsSheet extends StatelessWidget {
  const _AllReviewsSheet({
    required this.productName,
    required this.averageRating,
    required this.ratingCount,
    required this.reviews,
  });

  final String            productName;
  final double            averageRating;
  final int               ratingCount;
  final List<_ReviewEntry> reviews;

  @override
  Widget build(BuildContext context) {
    final bottomInset   = MediaQuery.viewInsetsOf(context).bottom;
    final sortedReviews = [...reviews]
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

    return AnimatedPadding(
      duration: const Duration(milliseconds: 180),
      curve:    Curves.easeOut,
      padding:  EdgeInsets.fromLTRB(0, 0, 0, bottomInset),
      child: Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.sizeOf(context).height * 0.88,
        ),
        decoration: BoxDecoration(
          color:        _white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(22)),
        ),
        child: SafeArea(
          top: false,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Handle
              Center(
                child: Container(
                  margin: const EdgeInsets.only(top: 10),
                  width:  40,
                  height: 4,
                  decoration: BoxDecoration(
                    color:        _border,
                    borderRadius: BorderRadius.circular(99),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            'Reviews',
                            style: GoogleFonts.inter(
                              fontSize:   18,
                              fontWeight: FontWeight.w700,
                              color:      _textPrimary,
                            ),
                          ),
                        ),
                        IconButton(
                          onPressed: () => Navigator.of(context).pop(),
                          icon: const Icon(Icons.close_rounded),
                          color: _textSub,
                        ),
                      ],
                    ),
                    Text(
                      productName,
                      maxLines:  1,
                      overflow:  TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 13, color: _textSub),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Text(
                          ratingCount > 0
                              ? averageRating.toStringAsFixed(1)
                              : 'New',
                          style: GoogleFonts.inter(
                            fontSize:   24,
                            fontWeight: FontWeight.w700,
                            color:      _textPrimary,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _StarRatingRow(rating: averageRating),
                        ),
                        Text(
                          ratingCount > 0
                              ? '$ratingCount review${ratingCount == 1 ? '' : 's'}'
                              : 'No reviews',
                          style: const TextStyle(
                              fontSize: 12.5, color: _textSub),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                  ],
                ),
              ),
              const Divider(color: _divider, height: 1),
              Expanded(
                child: sortedReviews.isEmpty
                    ? Center(
                        child: Text(
                          'No reviews yet.',
                          style: TextStyle(color: _textSub),
                        ),
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.all(16),
                        itemCount:        sortedReviews.length,
                        separatorBuilder: (context, index) =>
                            const SizedBox(height: 10),
                        itemBuilder: (context, i) =>
                            _ReviewCard(review: sortedReviews[i]),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  Review Composer Sheet
// ─────────────────────────────────────────────────────────────────────────────
class _ReviewComposerSheet extends StatefulWidget {
  const _ReviewComposerSheet({required this.productName});

  final String productName;

  @override
  State<_ReviewComposerSheet> createState() => _ReviewComposerSheetState();
}

class _ReviewComposerSheetState extends State<_ReviewComposerSheet> {
  static const int _maxImages = 4;

  final ImagePicker _picker = ImagePicker();
  int  _selectedRating  = 5;
  String _comment       = '';
  bool _isPickingImages = false;
  final List<Uint8List> _images = [];

  Future<void> _pickImages() async {
    if (_isPickingImages || _images.length >= _maxImages) return;
    setState(() => _isPickingImages = true);
    try {
      final picked = await _picker.pickMultiImage(
          imageQuality: 85, maxWidth: 1600, maxHeight: 1600);
      if (!mounted || picked.isEmpty) return;
      final slotsLeft = _maxImages - _images.length;
      final selected  = picked.take(slotsLeft).toList();
      final bytesList = <Uint8List>[];
      for (final f in selected) {
        final b = await f.readAsBytes();
        if (b.isNotEmpty) bytesList.add(b);
      }
      if (!mounted || bytesList.isEmpty) return;
      setState(() => _images.addAll(bytesList));
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not pick images.')),
      );
    } finally {
      if (mounted) setState(() => _isPickingImages = false);
    }
  }

  void _removeImageAt(int i) {
    if (i < 0 || i >= _images.length) return;
    setState(() => _images.removeAt(i));
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset  = MediaQuery.viewInsetsOf(context).bottom;
    final trimmed      = _comment.trim();
    final canSubmit    = trimmed.isNotEmpty || _images.isNotEmpty;

    return AnimatedPadding(
      duration: const Duration(milliseconds: 180),
      curve:    Curves.easeOut,
      padding:  EdgeInsets.fromLTRB(0, 0, 0, bottomInset),
      child: Container(
        decoration: BoxDecoration(
          color:        _white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(22)),
        ),
        child: SafeArea(
          top: false,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Handle
                Center(
                  child: Container(
                    width:  40,
                    height: 4,
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color:        _border,
                      borderRadius: BorderRadius.circular(99),
                    ),
                  ),
                ),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Write a Review',
                        style: GoogleFonts.inter(
                          fontSize:   18,
                          fontWeight: FontWeight.w700,
                          color:      _textPrimary,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.close_rounded),
                      color: _textSub,
                    ),
                  ],
                ),
                Text(
                  widget.productName,
                  maxLines:  2,
                  overflow:  TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 12.5, color: _textSub),
                ),
                const SizedBox(height: 20),

                // Star rating
                const Text(
                  'Your Rating',
                  style: TextStyle(
                    fontSize:   13.5,
                    fontWeight: FontWeight.w600,
                    color:      _textPrimary,
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  children: List.generate(5, (i) {
                    final star = i + 1;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: GestureDetector(
                        onTap: () =>
                            setState(() => _selectedRating = star),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 120),
                          width:  42,
                          height: 42,
                          decoration: BoxDecoration(
                            color:        star <= _selectedRating
                                ? const Color(0xFFFFF7ED)
                                : const Color(0xFFF9FAFB),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: star <= _selectedRating
                                  ? _amber
                                  : _border,
                            ),
                          ),
                          child: Icon(
                            star <= _selectedRating
                                ? Icons.star_rounded
                                : Icons.star_border_rounded,
                            color: _amber,
                          ),
                        ),
                      ),
                    );
                  }),
                ),
                const SizedBox(height: 18),

                // Comment
                const Text(
                  'Comment',
                  style: TextStyle(
                    fontSize:   13.5,
                    fontWeight: FontWeight.w600,
                    color:      _textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  maxLines:  5,
                  minLines:  3,
                  onChanged: (v) => setState(() => _comment = v),
                  decoration: InputDecoration(
                    hintText:    'Share your experience…',
                    hintStyle:   const TextStyle(color: _textHint),
                    filled:      true,
                    fillColor:   const Color(0xFFF9FAFB),
                    contentPadding: const EdgeInsets.all(14),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide:   const BorderSide(color: _border),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide:   const BorderSide(color: _border),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide:   const BorderSide(color: _accent),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Photos
                Row(
                  children: [
                    const Expanded(
                      child: Text(
                        'Photos (optional)',
                        style: TextStyle(
                          fontSize:   13.5,
                          fontWeight: FontWeight.w600,
                          color:      _textPrimary,
                        ),
                      ),
                    ),
                    Text(
                      '${_images.length}/$_maxImages',
                      style: const TextStyle(
                          fontSize: 12, color: _textSub),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                OutlinedButton.icon(
                  onPressed:
                      _images.length >= _maxImages || _isPickingImages
                          ? null
                          : _pickImages,
                  icon: _isPickingImages
                      ? const SizedBox(
                          width:  16,
                          height: 16,
                          child:  CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.photo_library_outlined),
                  label: Text(
                    _isPickingImages ? 'Selecting…' : 'Upload Photos'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: _accent,
                    side:            const BorderSide(color: _border),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                if (_images.isNotEmpty) ...[
                  const SizedBox(height: 10),
                  Wrap(
                    spacing:    6,
                    runSpacing: 6,
                    children: List.generate(_images.length, (i) {
                      return Stack(
                        clipBehavior: Clip.none,
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: SizedBox(
                              width:  80,
                              height: 80,
                              child:  Image.memory(
                                  _images[i], fit: BoxFit.cover),
                            ),
                          ),
                          Positioned(
                            top:   -5,
                            right: -5,
                            child: GestureDetector(
                              onTap: () => _removeImageAt(i),
                              child: Container(
                                width:  20,
                                height: 20,
                                decoration: const BoxDecoration(
                                  color: Colors.black87,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.close_rounded,
                                  size:  12,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ],
                      );
                    }),
                  ),
                ],
                const SizedBox(height: 20),

                // Submit
                SizedBox(
                  width:  double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: !canSubmit
                        ? null
                        : () {
                            Navigator.of(context).pop(
                              _ReviewEntry(
                                author:    'You',
                                rating:    _selectedRating,
                                comment:   trimmed,
                                images: List<Uint8List>.unmodifiable(_images),
                                createdAt: DateTime.now(),
                              ),
                            );
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _accent,
                      foregroundColor: Colors.white,
                      elevation:       0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Submit Review',
                      style: TextStyle(
                          fontWeight: FontWeight.w700, fontSize: 14),
                    ),
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

// ─────────────────────────────────────────────────────────────────────────────
//  Data models
// ─────────────────────────────────────────────────────────────────────────────
class _ReviewEntry {
  _ReviewEntry({
    required this.author,
    required this.rating,
    required this.comment,
    this.images = const [],
    required this.createdAt,
  });

  final String          author;
  final int             rating;
  final String          comment;
  final List<Uint8List> images;
  final DateTime        createdAt;

  Map<String, dynamic> toMap() => {
        'author':     author,
        'rating':     rating,
        'comment':    comment,
        'created_at': createdAt.toIso8601String(),
      };

  factory _ReviewEntry.fromMap(Map<String, dynamic> map) {
    final parsedRating = switch (map['rating']) {
      int v    => v,
      num v    => v.toInt(),
      String v => int.tryParse(v) ?? 5,
      _        => 5,
    };
    final rawDate   = map['created_at']?.toString();
    final createdAt = rawDate == null
        ? DateTime.now()
        : DateTime.tryParse(rawDate) ?? DateTime.now();
    return _ReviewEntry(
      author: map['author']?.toString().trim().isNotEmpty == true
          ? map['author'].toString().trim()
          : 'You',
      rating:    parsedRating.clamp(1, 5).toInt(),
      comment:   map['comment']?.toString() ?? '',
      createdAt: createdAt,
    );
  }

  static const List<String> _months = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
  ];

  String get formattedDate {
    final m = _months[createdAt.month - 1];
    return '$m ${createdAt.day}, ${createdAt.year}';
  }
}

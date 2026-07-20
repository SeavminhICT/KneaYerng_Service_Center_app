import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'dart:convert';

import '../../l10n/app_localizations.dart';
import '../../models/cart_item.dart';
import '../../models/product.dart';
import '../../services/cart_service.dart';
import '../../services/favorite_service.dart';
import '../../theme/app_fonts.dart';
import '../../widgets/auth_guard.dart';
import '../../widgets/cart_added_bottom_bar.dart';
import '../../widgets/page_transitions.dart';
import '../cart/checkout_flow_screen.dart';
import '../cart/cart_screen.dart';
import 'widgets/product_all_reviews_sheet.dart';
import 'widgets/product_bottom_bar.dart';
import 'widgets/product_description_section.dart';
import 'widgets/product_detail_app_bar.dart';
import 'widgets/product_detail_common.dart';
import 'widgets/product_detail_tone.dart';
import 'widgets/product_image_gallery.dart';
import 'widgets/product_price_quantity_card.dart';
import 'widgets/product_rating_row.dart';
import 'widgets/product_review_composer_sheet.dart';
import 'widgets/product_review_entry.dart';
import 'widgets/product_trust_strip.dart';
import 'widgets/product_variant_selectors.dart';

/// One selectable/displayable variant attribute (storage, color, RAM, ...).
class _VariantFieldSpec {
  const _VariantFieldSpec(
    this.key,
    this.label,
    this.selector, {
    this.isColor = false,
  });

  final String key;
  final String label;
  final String Function(ProductVariant) selector;
  final bool isColor;
}

class ProductDetailScreen extends StatefulWidget {
  const ProductDetailScreen({
    super.key,
    required this.product,
    this.showCartActions = true,
  });

  final Product product;

  /// When false, hides the cart icon and Add to Cart / Buy Now bottom
  /// bar (e.g. for repair/service parts that are view + favorite only).
  final bool showCartActions;

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen>
    with SingleTickerProviderStateMixin {
  static const String _reviewsStoragePrefix = 'product_reviews_v1_';

  int _galleryIndex = 0;
  int _quantity     = 1;
  final Map<String, int> _variantIndex = {};
  bool _descriptionExpanded = false;
  bool _isReviewSheetOpen   = false;
  final List<ProductReviewEntry> _reviews = [];

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
              ProductReviewEntry.fromMap(Map<String, dynamic>.from(item)))
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

  /// Every variant attribute the app can display/select, ordered by how
  /// they're grouped in the admin product form (spec-y fields first, then
  /// physical attributes). Matching for [_resolveSelectedVariant] uses the
  /// same order, most-defining first, so a Mac's storage/RAM/SSD win over
  /// its color/condition/country when narrowing down an exact variant.
  List<_VariantFieldSpec> _variantFieldSpecs(Product product) => [
        _VariantFieldSpec('display', 'Display', (v) => v.display ?? ''),
        _VariantFieldSpec('cpu', 'CPU', (v) => v.cpu ?? ''),
        _VariantFieldSpec(
          'storage',
          product.productType == 'mac' ? 'Capacity' : 'Size / Model',
          (v) => v.storageCapacity,
        ),
        _VariantFieldSpec('ram', 'RAM', (v) => v.ram ?? ''),
        _VariantFieldSpec('ssd', 'SSD', (v) => v.ssd ?? ''),
        _VariantFieldSpec('color', 'Color', (v) => v.color, isColor: true),
        _VariantFieldSpec('condition', 'Condition', (v) => v.condition),
        _VariantFieldSpec('country', 'Country', (v) => v.country ?? ''),
      ];

  /// Options for each field: from live variant rows when present, otherwise
  /// falling back to the legacy product-level (non-variant) attribute lists.
  List<String> _optionsForField(
    Product product,
    List<ProductVariant> variantRows,
    _VariantFieldSpec spec,
  ) {
    if (variantRows.isNotEmpty) {
      return _variantValues(variantRows, spec.selector);
    }
    switch (spec.key) {
      case 'storage':
        return _splitOptions(product.storageCapacity);
      case 'color':
        return _splitOptions(product.color);
      case 'condition':
        return _splitOptions(product.condition);
      case 'ram':
        return product.ramOptions;
      case 'ssd':
        return _splitOptions(product.ssd);
      case 'cpu':
        return _splitOptions(product.cpu);
      case 'display':
        return _splitOptions(product.display);
      case 'country':
        return _splitOptions(product.country);
    }
    return const [];
  }

  ProductVariant? _resolveSelectedVariant(
    List<ProductVariant> variants,
    List<_VariantFieldSpec> specs,
    Map<String, String?> selected,
  ) {
    if (variants.isEmpty) return null;

    bool matches(ProductVariant v, int considerCount) {
      for (var i = 0; i < considerCount; i++) {
        final spec = specs[i];
        final want = selected[spec.key];
        if (want == null || want.isEmpty) continue;
        if (spec.selector(v).trim() != want) return false;
      }
      return true;
    }

    for (var considerCount = specs.length; considerCount >= 0; considerCount--) {
      for (final v in variants) {
        if (matches(v, considerCount)) return v;
      }
    }
    return variants.first;
  }

  String _selectedVariantLabel(
    List<_VariantFieldSpec> specs,
    Map<String, String?> selected,
  ) {
    final parts = [
      for (final spec in specs)
        if ((selected[spec.key] ?? '').isNotEmpty) selected[spec.key]!,
    ];
    return parts.join(' / ');
  }

  /// Renders a "Label · Selected" row + a chip Wrap for every variant field
  /// that has options, separated by dividers — one block per field so Mac
  /// products can show Display/CPU/Storage/RAM/SSD/Color/Condition/Country
  /// side by side with mobile's simpler Storage/Color/Condition set.
  List<Widget> _buildVariantSectionWidgets(
    ProductDetailTone tone,
    List<_VariantFieldSpec> specs,
    Map<String, List<String>> options,
    Map<String, String?> selected,
  ) {
    final visible = specs
        .where((spec) => (options[spec.key] ?? const []).isNotEmpty)
        .toList();
    final widgets = <Widget>[];

    for (var i = 0; i < visible.length; i++) {
      final spec = visible[i];
      final values = options[spec.key]!;
      final selectedValue = selected[spec.key] ?? values.first;
      final selectedIndex = values.indexOf(selectedValue);

      widgets.add(ProductVariantRow(
        tone: tone,
        label: spec.label,
        selected: selectedValue,
      ));
      widgets.add(const SizedBox(height: 10));
      widgets.add(Wrap(
        spacing: 8,
        runSpacing: 8,
        children: List.generate(values.length, (j) {
          final isSelected = j == selectedIndex;
          if (spec.isColor) {
            return ProductColorChip(
              tone: tone,
              label: values[j],
              color: _colorFromName(values[j]),
              selected: isSelected,
              onTap: () => setState(() => _variantIndex[spec.key] = j),
            );
          }
          return ProductVariantChipButton(
            tone: tone,
            label: values[j],
            selected: isSelected,
            onTap: () => setState(() => _variantIndex[spec.key] = j),
          );
        }),
      ));

      if (i != visible.length - 1) {
        widgets.add(const SizedBox(height: 16));
        widgets.add(Divider(color: tone.divider, height: 1));
        widgets.add(const SizedBox(height: 16));
      }
    }

    return widgets;
  }

  double _discountPercent(Product p) {
    if (!p.hasDiscount || p.price <= 0) return 0;
    return ((p.discount ?? 0) / p.price) * 100;
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
    ProductReviewEntry? result;
    try {
      result = await showModalBottomSheet<ProductReviewEntry>(
        context:              context,
        isScrollControlled:   true,
        backgroundColor:      Colors.transparent,
        builder: (_) =>
            ProductReviewComposerSheet(productName: product.name),
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
      builder: (_) => ProductAllReviewsSheet(
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
    final variantSpecs     = _variantFieldSpecs(product);

    // Options + the currently-selected value for every variant attribute
    // that has at least one option for this product (storage/color/condition
    // for mobile, all eight for Mac, color only for accessories, etc).
    final variantOptions = <String, List<String>>{};
    final selectedByField = <String, String?>{};
    for (final spec in variantSpecs) {
      final options = _optionsForField(product, variantRows, spec);
      variantOptions[spec.key] = options;
      var index = _variantIndex[spec.key] ?? 0;
      if (index >= options.length) {
        index = 0;
        _variantIndex[spec.key] = 0;
      }
      selectedByField[spec.key] = options.isNotEmpty ? options[index] : null;
    }

    final selectedVariantEntity = variantRows.isNotEmpty
        ? _resolveSelectedVariant(variantRows, variantSpecs, selectedByField)
        : null;
    if (selectedVariantEntity != null) {
      for (final spec in variantSpecs) {
        final fromVariant = spec.selector(selectedVariantEntity).trim();
        if (fromVariant.isNotEmpty) {
          selectedByField[spec.key] = fromVariant;
        }
      }
    }
    final selectedVariant = _selectedVariantLabel(variantSpecs, selectedByField);

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
    final descriptionText = _cleanValue(product.description);
    final featureBullets  = _featureBullets(product);
    final rating          = _displayRating(product);
    final ratingCount     = _displayRatingCount(product);

    return AnimatedBuilder(
      animation: FavoriteService.instance,
      builder: (context, _) {
        final isFavorite = FavoriteService.instance.contains(product);
        final tone = ProductDetailTone.of(context);
        final variantSectionWidgets = _buildVariantSectionWidgets(
          tone,
          variantSpecs,
          variantOptions,
          selectedByField,
        );

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
                    ProductDetailAppBar(
                      tone:       tone,
                      title:      l.productDetails,
                      isFavorite: isFavorite,
                      onBack:     () => Navigator.of(context).pop(),
                      onFavorite: () =>
                          FavoriteService.instance.toggle(product),
                      onCartTap: widget.showCartActions
                          ? () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                    builder: (_) => const CartScreen()),
                              );
                            }
                          : null,
                    ),

                    // ── Scrollable body ──────────────────────────────────
                    Expanded(
                      child: SingleChildScrollView(
                        physics: const BouncingScrollPhysics(),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Image gallery
                            ProductImageGallery(
                              tone:          tone,
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
                              padding: EdgeInsets.fromLTRB(
                                  16, 0, 16, widget.showCartActions ? 100 : 24),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const SizedBox(height: 16),
                                  const SizedBox(height: 10),

                                  // Product name
                                  Text(
                                    product.name,
                                    style: kmFont(context, GoogleFonts.inter(
                                      fontSize:   24,
                                      fontWeight: FontWeight.w700,
                                      color:      tone.textPrimary,
                                      height:     1.2,
                                    )),
                                  ),
                                  const SizedBox(height: 10),

                                  // Rating row
                                  if (ratingCount > 0) ...[
                                    ProductRatingRow(
                                      tone:        tone,
                                      rating:      rating,
                                      ratingCount: ratingCount,
                                    ),
                                    const SizedBox(height: 12),
                                  ],

                                  // ── Price + Quantity card ─────────────
                                  ProductPriceQuantityCard(
                                    tone:         tone,
                                    unitPrice:    unitPrice,
                                    oldPrice:     oldPrice,
                                    quantity:     quantity,
                                    stock:        stock,
                                    isOutOfStock: isOutOfStock,
                                    total:        total,
                                    showQuantity: widget.showCartActions,
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
                                  if (variantSectionWidgets.isNotEmpty) ...[
                                    ProductDetailSectionTitle(title: l.filter, tone: tone),
                                    const SizedBox(height: 12),
                                    ProductDetailCard(
                                      tone: tone,
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          ...variantSectionWidgets,
                                          if (selectedVariant.isNotEmpty) ...[
                                            const SizedBox(height: 16),
                                            Divider(
                                                color: tone.divider, height: 1),
                                            const SizedBox(height: 12),
                                            Row(
                                              children: [
                                                Icon(
                                                  HugeIcons.strokeRoundedFilterHorizontal,
                                                  size:  15,
                                                  color: tone.textHint,
                                                ),
                                                const SizedBox(width: 6),
                                                Expanded(
                                                  child: Text(
                                                    'Selected: $selectedVariant',
                                                    style: TextStyle(
                                                      fontSize:   12.5,
                                                      color:      tone.textSub,
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
                                  ProductTrustStrip(tone: tone),
                                  const SizedBox(height: 16),

                                  // ── Description ───────────────────────
                                  ProductDetailSectionTitle(title: l.description, tone: tone),
                                  const SizedBox(height: 12),
                                  ProductDetailCard(
                                    tone: tone,
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        ProductDescriptionBlock(
                                          tone: tone,
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
                                          Divider(
                                              color: tone.divider, height: 1),
                                          const SizedBox(height: 16),
                                          ProductFeatureBulletList(
                                              tone: tone,
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
                    if (widget.showCartActions)
                      SafeArea(
                        top: false,
                        child: ProductBottomBar(
                          tone:        tone,
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

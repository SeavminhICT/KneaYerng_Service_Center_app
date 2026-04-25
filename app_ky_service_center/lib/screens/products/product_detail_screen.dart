import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../models/cart_item.dart';
import '../../models/product.dart';
import '../../services/cart_service.dart';
import '../../services/favorite_service.dart';
import '../../widgets/auth_guard.dart';
import '../../widgets/cart_added_bottom_bar.dart';
import '../../widgets/page_transitions.dart';
import '../cart/cart_screen.dart';
import '../cart/checkout_flow_screen.dart';

Map<String, String>? get _imageHeaders => null;

const _pageBg = Color(0xFFF4F8FC);
const _heroBg = Color(0xFFE8F1FF);
const _heroBgSecondary = Color(0xFFDBF0E8);
const _surface = Color(0xFFFFFFFF);
const _surfaceSoft = Color(0xFFF2F7FC);
const _border = Color(0xFFD9E6F2);
const _textPrimary = Color(0xFF172033);
const _textSecondary = Color(0xFF617186);
const _accent = Color(0xFF1E6BFF);
const _accentDeep = Color(0xFF1550CC);
const _accentSoft = Color(0xFFDDE9FF);
const _success = Color(0xFF1F9D6C);
const _danger = Color(0xFFD95C5C);
const _star = Color(0xFFFFB648);
const _shadow = Color(0x12000000);

class ProductDetailScreen extends StatefulWidget {
  const ProductDetailScreen({super.key, required this.product});

  final Product product;

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  int _galleryIndex = 0;
  int _quantity = 1;
  int _storageIndex = 0;
  int _colorIndex = 0;
  int _conditionIndex = 0;
  bool _descriptionExpanded = false;
  final List<_ReviewEntry> _reviews = [];

  static const Map<String, Color> _namedColors = {
    'black': Color(0xFF111111),
    'graphite': Color(0xFF23272F),
    'white': Color(0xFFF8F8F8),
    'silver': Color(0xFFD1D5DB),
    'grey': Color(0xFF9CA3AF),
    'gray': Color(0xFF9CA3AF),
    'blue': Color(0xFF4B6BFB),
    'green': Color(0xFF22C55E),
    'red': Color(0xFFDC2626),
    'gold': Color(0xFFEAB308),
    'natural titanium': Color(0xFFD6D3D1),
    'white titanium': Color(0xFFE5E7EB),
    'black titanium': Color(0xFF111827),
    'desert titanium': Color(0xFFBFA58A),
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
        .map((item) => item.trim().replaceAll("'", '').replaceAll('"', ''))
        .where((item) => item.isNotEmpty)
        .toList();
  }

  List<String> _buildGallery(Product product) {
    final images = <String>[];
    if (product.thumbnailUrl != null && product.thumbnailUrl!.isNotEmpty) {
      images.add(product.thumbnailUrl!);
    }
    if (product.imageUrl != null &&
        product.imageUrl!.isNotEmpty &&
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
        .where((word) => word.isNotEmpty)
        .map(
          (word) =>
              '${word[0].toUpperCase()}${word.substring(1).toLowerCase()}',
        )
        .join(' ');
  }

  String _cleanValue(String? raw) {
    if (raw == null) return '';
    var value = raw.trim();
    if (value.isEmpty || value == 'null') return '';
    if (value.startsWith('[') && value.endsWith(']')) {
      value = value.substring(1, value.length - 1).trim();
    }
    return value.replaceAll("'", '').replaceAll('"', '');
  }

  String _selectedVariant(
    List<String> storageOptions,
    List<String> colorOptions,
    List<String> conditionOptions,
  ) {
    return [
      if (colorOptions.isNotEmpty) colorOptions[_colorIndex],
      if (storageOptions.isNotEmpty) storageOptions[_storageIndex],
      if (conditionOptions.isNotEmpty) conditionOptions[_conditionIndex],
    ].join('  ·  ');
  }

  String _selectedVariantLabel(
    List<String> storageOptions,
    List<String> colorOptions,
    List<String> conditionOptions,
  ) {
    final parts = [
      if (colorOptions.isNotEmpty) colorOptions[_colorIndex],
      if (storageOptions.isNotEmpty) storageOptions[_storageIndex],
      if (conditionOptions.isNotEmpty) conditionOptions[_conditionIndex],
    ];
    return parts.join(' / ');
  }

  double _discountPercent(Product product) {
    if (!product.hasDiscount || product.price <= 0) return 0;
    return ((product.discount ?? 0) / product.price) * 100;
  }

  double _estimatedCostPrice(Product product) {
    final anchor = product.price > 0 ? product.price : product.salePrice;
    var costRatio = 0.66;
    if ((product.brand?.trim().isNotEmpty ?? false)) costRatio -= 0.03;
    if ((product.stock ?? 0) > 30) costRatio += 0.02;
    if (product.hasDiscount) costRatio += 0.03;
    if (product.rating >= 4.5) costRatio -= 0.02;
    return anchor * costRatio.clamp(0.52, 0.84);
  }

  int _estimatedMonthlyDemand(Product product) {
    final stock = product.stock ?? 18;
    final demand = (product.ratingCount * 3) + stock + (product.rating * 8);
    return demand.round().clamp(12, 260);
  }

  List<String> _featureBullets(Product product) {
    final bullets = <String>[
      if ((product.categoryName?.trim().isNotEmpty ?? false))
        '${product.categoryName!.trim()} product positioned for reliable daily use.',
      if ((product.warranty?.trim().isNotEmpty ?? false))
        'Warranty support: ${product.warranty!.trim()}.',
      if ((product.country?.trim().isNotEmpty ?? false))
        'Sourced for ${product.country!.trim()} market availability.',
      if ((product.condition?.trim().isNotEmpty ?? false))
        'Condition profile: ${_cleanValue(product.condition)}.',
    ];

    final description = _cleanValue(product.description);
    if (description.isNotEmpty) {
      final descriptionBullets = description
          .split(RegExp(r'[\.\n]'))
          .map((item) => item.trim())
          .where((item) => item.isNotEmpty)
          .take(3)
          .toList();
      bullets.addAll(descriptionBullets);
    }

    if (bullets.isEmpty) {
      bullets.addAll([
        'Balanced pricing for customers who compare value before checkout.',
        'Suitable for business-minded buyers tracking margin and demand.',
        'Clear product setup with options, stock, and savings visible upfront.',
      ]);
    }

    return bullets.take(4).toList();
  }

  String _sellingPoint(Product product) {
    final description = _cleanValue(product.description);
    if (description.isNotEmpty) {
      final sentence = description
          .split(RegExp(r'[\.\n]'))
          .map((item) => item.trim())
          .firstWhere(
            (item) => item.isNotEmpty,
            orElse: () => '',
          );
      if (sentence.isNotEmpty) return sentence;
    }

    final category = product.categoryName?.trim();
    if (category != null && category.isNotEmpty) {
      return 'A smart $category choice with clear pricing and solid resale logic.';
    }

    return 'Built for buyers who compare product quality with business value.';
  }

  Future<void> _addToCartWithGuard(Product product, String? variant) async {
    final ok = await ensureLoggedIn(
      context,
      message: 'Please login or register to add items to your cart.',
    );
    if (!ok || !mounted) return;
    CartService.instance.add(
      product,
      quantity: _quantity,
      variant: variant?.isEmpty ?? true ? null : variant,
    );
    await showCartAddedBottomBar(context);
  }

  Future<void> _buyNowWithGuard(Product product, String? variant) async {
    final ok = await ensureLoggedIn(
      context,
      message: 'Please login or register to buy now.',
    );
    if (!ok || !mounted) return;
    final checkoutItem = CartItem(
      product: product,
      quantity: _quantity,
      variant: variant?.isEmpty ?? true ? null : variant,
    );
    Navigator.of(
      context,
    ).push(fadeSlideRoute(CheckoutFlowScreen(items: [checkoutItem])));
  }

  double _displayRating(Product product) {
    final baseCount = product.ratingCount;
    final baseTotal = product.rating * baseCount;
    final localTotal = _reviews.fold<double>(
      0,
      (sum, review) => sum + review.rating,
    );
    final totalCount = baseCount + _reviews.length;
    if (totalCount == 0) return 0;
    return (baseTotal + localTotal) / totalCount;
  }

  int _displayRatingCount(Product product) {
    return product.ratingCount + _reviews.length;
  }

  Future<void> _openReviewSheet(Product product) async {
    final ok = await ensureLoggedIn(
      context,
      message: 'Please login or register to leave a review.',
    );
    if (!ok || !mounted) return;

    final commentController = TextEditingController();
    var selectedRating = 5;

    final result = await showModalBottomSheet<_ReviewEntry>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            final bottomInset = MediaQuery.of(context).viewInsets.bottom;
            final trimmed = commentController.text.trim();
            return Padding(
              padding: EdgeInsets.fromLTRB(16, 0, 16, bottomInset + 16),
              child: _ReviewComposerSheet(
                productName: product.name,
                selectedRating: selectedRating,
                commentController: commentController,
                onRatingChanged: (value) =>
                    setModalState(() => selectedRating = value),
                onSubmit: trimmed.isEmpty
                    ? null
                    : () {
                        Navigator.of(context).pop(
                          _ReviewEntry(
                            author: 'You',
                            rating: selectedRating,
                            comment: trimmed,
                            createdAt: DateTime.now(),
                          ),
                        );
                      },
              ),
            );
          },
        );
      },
    );

    commentController.dispose();
    if (!mounted || result == null) return;
    setState(() => _reviews.insert(0, result));
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

    final price = product.salePrice;
    final oldPrice = product.hasDiscount && price < product.price
        ? product.price
        : null;
    final brand = (product.brand?.trim().isNotEmpty ?? false)
        ? product.brand!.trim()
        : 'Premium Device';
    final tagText = _formatTag(product.tag);
    final statusText = _formatTag(product.status);
    final descriptionText = _cleanValue(product.description);
    final selectedVariant = _selectedVariantLabel(
      storageOptions,
      colorOptions,
      conditionOptions,
    );
    final categoryText = (product.categoryName?.trim().isNotEmpty ?? false)
        ? product.categoryName!.trim()
        : 'General Product';
    final rating = _displayRating(product);
    final ratingCount = _displayRatingCount(product);
    final stock = product.stock;
    final isOutOfStock = stock != null && stock <= 0;
    final availabilityText = stock == null
        ? 'Check availability'
        : isOutOfStock
        ? 'Out of stock'
        : '$stock in stock';
    final savingsAmount = (oldPrice ?? price) - price;
    final discountPercent = _discountPercent(product);
    final costPrice = _estimatedCostPrice(product);
    final profit = price - costPrice;
    final profitMargin = price <= 0 ? 0.0 : (profit / price) * 100;
    final monthlyDemand = _estimatedMonthlyDemand(product);
    final sellingPoint = _sellingPoint(product);
    final featureBullets = _featureBullets(product);
    final economicsBadge = profitMargin >= 28
        ? 'High Margin'
        : profitMargin >= 18
        ? 'Healthy Margin'
        : 'Lean Margin';
    final specs = <_SpecItem>[
      if (_cleanValue(product.display).isNotEmpty)
        _SpecItem(
          label: 'Display',
          value: _cleanValue(product.display),
          icon: Icons.display_settings_outlined,
        ),
      if (_cleanValue(product.cpu).isNotEmpty)
        _SpecItem(
          label: 'CPU',
          value: _cleanValue(product.cpu),
          icon: Icons.memory_outlined,
        ),
      if (product.ramOptions.where((item) => item.trim().isNotEmpty).isNotEmpty)
        _SpecItem(
          label: 'RAM',
          value: product.ramOptions
              .map((item) => item.trim())
              .where((item) => item.isNotEmpty)
              .join(', '),
          icon: Icons.developer_board_outlined,
        ),
      if (_cleanValue(product.ssd).isNotEmpty)
        _SpecItem(
          label: 'SSD',
          value: _cleanValue(product.ssd),
          icon: Icons.storage_outlined,
        ),
    ];

    return AnimatedBuilder(
      animation: FavoriteService.instance,
      builder: (context, _) {
        final isFavorite = FavoriteService.instance.contains(product);

        return Theme(
          data: Theme.of(context).copyWith(
            scaffoldBackgroundColor: _pageBg,
            textTheme: GoogleFonts.interTextTheme(Theme.of(context).textTheme),
          ),
          child: Scaffold(
            backgroundColor: _pageBg,
            body: SafeArea(
              bottom: false,
              child: Column(
                children: [
                  Container(
                    color: _surface,
                    padding: const EdgeInsets.fromLTRB(8, 8, 8, 12),
                    child: Row(
                      children: [
                        IconButton(
                          onPressed: () => Navigator.of(context).pop(),
                          icon: const Icon(
                            Icons.arrow_back_ios_new_rounded,
                            color: _textPrimary,
                          ),
                        ),
                        Expanded(
                          child: Text(
                            'Product Details',
                            textAlign: TextAlign.center,
                            style: GoogleFonts.inter(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: _textPrimary,
                            ),
                          ),
                        ),
                        IconButton(
                          onPressed: () =>
                              FavoriteService.instance.toggle(product),
                          icon: Icon(
                            isFavorite
                                ? Icons.favorite_rounded
                                : Icons.favorite_border_rounded,
                            color: isFavorite ? _danger : _textPrimary,
                          ),
                        ),
                        IconButton(
                          onPressed: () {},
                          icon: const Icon(
                            Icons.ios_share_rounded,
                            color: _textPrimary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
                      child: LayoutBuilder(
                        builder: (context, constraints) {
                          final wideHero = constraints.maxWidth >= 760;
                          final twoColumnSections = constraints.maxWidth >= 720;
                          final wideVariantCard = constraints.maxWidth >= 680;
                          final releaseYear = product.createdAt?.year.toString() ?? '2023';
                          final warrantyText = _cleanValue(product.warranty).isNotEmpty
                              ? _cleanValue(product.warranty)
                              : 'Standard';

                          final mediaPanel = Column(
                            children: [
                              _MediaStage(
                                imageUrl: imageUrl,
                                tagText: tagText,
                                statusText: statusText,
                                galleryCount: gallery.length,
                                selectedIndex: safeIndex,
                                discountLabel: discountPercent > 0
                                    ? '-${discountPercent.round()}%'
                                    : null,
                                stockLabel: isOutOfStock ? 'Out of Stock' : 'In Stock',
                              ),
                              if (gallery.length > 1) ...[
                                const SizedBox(height: 14),
                                _ThumbnailRail(
                                  images: gallery,
                                  selectedIndex: safeIndex,
                                  onSelect: (index) =>
                                      setState(() => _galleryIndex = index),
                                ),
                              ],
                            ],
                          );

                          final summaryPanel = Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(18),
                            decoration: BoxDecoration(
                              color: _surface,
                              borderRadius: BorderRadius.circular(26),
                              border: Border.all(color: _border),
                              boxShadow: [
                                BoxShadow(
                                  color: _accent.withAlpha((0.06 * 255).round()),
                                  blurRadius: 20,
                                  offset: const Offset(0, 10),
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _CommerceSummaryCard(
                                  name: product.name,
                                  category: categoryText,
                                  brand: brand,
                                  rating: rating,
                                  ratingCount: ratingCount,
                                  sellingPoint: sellingPoint,
                                  currentPrice: price,
                                  oldPrice: oldPrice,
                                  savingsAmount: savingsAmount,
                                  economicsBadge: economicsBadge,
                                  profitMarginPercent: profitMargin,
                                ),
                                const SizedBox(height: 18),
                                const _TrustFeatureStrip(),
                              ],
                            ),
                          );

                          final variantCard = _SectionCard(
                            child: LayoutBuilder(
                              builder: (context, innerConstraints) {
                                final sideBySide = wideVariantCard &&
                                    innerConstraints.maxWidth >= 640;

                                final optionBlock = Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    if (storageOptions.isNotEmpty) ...[
                                      _OptionSection(
                                        title: 'Size / Model',
                                        subtitle: storageOptions[_storageIndex],
                                        child: Wrap(
                                          spacing: 10,
                                          runSpacing: 10,
                                          children: List.generate(
                                            storageOptions.length,
                                            (index) => _SegmentChip(
                                              label: storageOptions[index],
                                              selected: _storageIndex == index,
                                              onTap: () =>
                                                  setState(() => _storageIndex = index),
                                            ),
                                          ),
                                        ),
                                      ),
                                      if (colorOptions.isNotEmpty || conditionOptions.isNotEmpty)
                                        const SizedBox(height: 16),
                                    ],
                                    if (colorOptions.isNotEmpty) ...[
                                      _OptionSection(
                                        title: 'Color',
                                        subtitle: colorOptions[_colorIndex],
                                        child: Wrap(
                                          spacing: 10,
                                          runSpacing: 10,
                                          children: List.generate(
                                            colorOptions.length,
                                            (index) => _ColorSwatch(
                                              label: colorOptions[index],
                                              color: _colorFromName(colorOptions[index]),
                                              selected: _colorIndex == index,
                                              onTap: () =>
                                                  setState(() => _colorIndex = index),
                                            ),
                                          ),
                                        ),
                                      ),
                                      if (conditionOptions.isNotEmpty)
                                        const SizedBox(height: 16),
                                    ],
                                    if (conditionOptions.isNotEmpty)
                                      _OptionSection(
                                        title: 'Condition',
                                        subtitle: conditionOptions[_conditionIndex],
                                        child: Wrap(
                                          spacing: 10,
                                          runSpacing: 10,
                                          children: List.generate(
                                            conditionOptions.length,
                                            (index) => _SegmentChip(
                                              label: conditionOptions[index],
                                              selected: _conditionIndex == index,
                                              onTap: () => setState(
                                                () => _conditionIndex = index,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                  ],
                                );

                                final quantityBlock = Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Quantity',
                                      style: GoogleFonts.inter(
                                        fontSize: 20,
                                        fontWeight: FontWeight.w800,
                                        color: _textPrimary,
                                      ),
                                    ),
                                    const SizedBox(height: 14),
                                    Row(
                                      children: [
                                        _QuantityControl(
                                          quantity: _quantity,
                                          onMinus: () {
                                            if (_quantity <= 1) return;
                                            setState(() => _quantity--);
                                          },
                                          onPlus: () => setState(() => _quantity++),
                                        ),
                                        const SizedBox(width: 14),
                                        Expanded(
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 14,
                                              vertical: 12,
                                            ),
                                            decoration: BoxDecoration(
                                              color: _surfaceSoft,
                                              borderRadius: BorderRadius.circular(18),
                                              border: Border.all(color: _border),
                                            ),
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  isOutOfStock ? 'Out of Stock' : 'In Stock',
                                                  style: TextStyle(
                                                    fontSize: 14,
                                                    fontWeight: FontWeight.w700,
                                                    color: isOutOfStock
                                                        ? _danger
                                                        : _success,
                                                  ),
                                                ),
                                                const SizedBox(height: 4),
                                                Text(
                                                  stock == null
                                                      ? 'Availability updates at checkout'
                                                      : '$stock available now',
                                                  style: const TextStyle(
                                                    fontSize: 12.5,
                                                    color: _textSecondary,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    if (selectedVariant.isNotEmpty) ...[
                                      const SizedBox(height: 16),
                                      Container(
                                        width: double.infinity,
                                        padding: const EdgeInsets.all(14),
                                        decoration: BoxDecoration(
                                          color: _surfaceSoft,
                                          borderRadius: BorderRadius.circular(18),
                                          border: Border.all(color: _border),
                                        ),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            const Text(
                                              'Selected configuration',
                                              style: TextStyle(
                                                fontSize: 12,
                                                fontWeight: FontWeight.w600,
                                                color: _textSecondary,
                                              ),
                                            ),
                                            const SizedBox(height: 6),
                                            Text(
                                              selectedVariant,
                                              style: const TextStyle(
                                                fontSize: 14,
                                                fontWeight: FontWeight.w700,
                                                color: _textPrimary,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ],
                                );

                                if (sideBySide) {
                                  return Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Expanded(child: optionBlock),
                                      Container(
                                        width: 1,
                                        margin: const EdgeInsets.symmetric(
                                          horizontal: 18,
                                        ),
                                        height: 220,
                                        color: _border,
                                      ),
                                      Expanded(child: quantityBlock),
                                    ],
                                  );
                                }

                                return Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    optionBlock,
                                    const SizedBox(height: 18),
                                    quantityBlock,
                                  ],
                                );
                              },
                            ),
                          );

                          final descriptionCard = _SectionCard(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const _SectionHeader(
                                  title: 'Description',
                                  subtitle: 'Story, features, and product value',
                                ),
                                const SizedBox(height: 14),
                                _DescriptionBlock(
                                  text: descriptionText.isNotEmpty
                                      ? descriptionText
                                      : 'No description available.',
                                  expanded: _descriptionExpanded,
                                  onToggle: descriptionText.length > 180
                                      ? () => setState(
                                            () => _descriptionExpanded =
                                                !_descriptionExpanded,
                                          )
                                      : null,
                                ),
                                const SizedBox(height: 18),
                                _FeatureBulletList(items: featureBullets),
                              ],
                            ),
                          );

                          final reviewsCard = _SectionCard(
                            child: _ReviewsSection(
                              averageRating: rating,
                              ratingCount: ratingCount,
                              reviews: _reviews,
                              onWriteReview: () => _openReviewSheet(product),
                            ),
                          );

                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (wideHero)
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Expanded(flex: 5, child: mediaPanel),
                                    const SizedBox(width: 14),
                                    Expanded(flex: 4, child: summaryPanel),
                                  ],
                                )
                              else ...[
                                mediaPanel,
                                const SizedBox(height: 14),
                                summaryPanel,
                              ],
                              const SizedBox(height: 14),
                              variantCard,
                              const SizedBox(height: 14),
                              if (twoColumnSections)
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Expanded(child: descriptionCard),
                                    const SizedBox(width: 14),
                                    Expanded(child: reviewsCard),
                                  ],
                                )
                              else ...[
                                descriptionCard,
                                const SizedBox(height: 14),
                                reviewsCard,
                              ],
                              const SizedBox(height: 14),
                              _SectionCard(
                                child: _HighlightsSection(
                                  brand: brand,
                                  condition: conditionOptions.isNotEmpty
                                      ? conditionOptions[_conditionIndex]
                                      : 'New',
                                  category: categoryText,
                                  releaseYear: releaseYear,
                                  warranty: warrantyText,
                                ),
                              ),
                              const SizedBox(height: 14),
                              _SectionCard(
                                child: Column(
                                  children: [
                                    _InfoDisclosureRow(
                                      icon: Icons.receipt_long_outlined,
                                      title: 'Specifications',
                                      subtitle: specs.isNotEmpty
                                          ? '${specs.length} key details available'
                                          : 'Technical details not available',
                                    ),
                                    const Divider(height: 28, color: _border),
                                    _InfoDisclosureRow(
                                      icon: Icons.local_shipping_outlined,
                                      title: 'Shipping & Returns',
                                      subtitle: 'Fast delivery with return coverage',
                                    ),
                                    const Divider(height: 28, color: _border),
                                    _InfoDisclosureRow(
                                      icon: Icons.person_outline_rounded,
                                      title: 'Seller Information',
                                      subtitle: '$brand official listing details',
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 24),
                            ],
                          );
                        },
                      ),
                    ),
                  ),
                  SafeArea(
                    top: false,
                    child: _BottomPurchaseBar(
                      quantity: _quantity,
                      total: price * _quantity,
                      onBuyNow: () => _buyNowWithGuard(product, selectedVariant),
                      onAddToCart: () =>
                          _addToCartWithGuard(product, selectedVariant),
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
    return Row(
      children: [
        _TopBarButton(icon: Icons.arrow_back_ios_new_rounded, onTap: onBack),
        const Spacer(),
        _TopBarButton(
          icon: isFavorite
              ? Icons.favorite_rounded
              : Icons.favorite_border_rounded,
          iconColor: isFavorite ? _danger : _textPrimary,
          onTap: onFavorite,
        ),
        const SizedBox(width: 10),
        _TopBarButton(icon: Icons.shopping_bag_outlined, onTap: onCart),
      ],
    );
  }
}

class _TopBarButton extends StatelessWidget {
  const _TopBarButton({
    required this.icon,
    required this.onTap,
    this.iconColor = _textPrimary,
  });

  final IconData icon;
  final VoidCallback onTap;
  final Color iconColor;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: _surface.withAlpha((0.78 * 255).round()),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: _border),
            boxShadow: [
              BoxShadow(
                color: _accent.withAlpha((0.08 * 255).round()),
                blurRadius: 16,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Icon(icon, size: 18, color: iconColor),
        ),
      ),
    );
  }
}

class _MediaStage extends StatelessWidget {
  const _MediaStage({
    required this.imageUrl,
    required this.tagText,
    required this.statusText,
    required this.galleryCount,
    required this.selectedIndex,
    this.discountLabel,
    this.stockLabel,
  });

  final String? imageUrl;
  final String tagText;
  final String statusText;
  final int galleryCount;
  final int selectedIndex;
  final String? discountLabel;
  final String? stockLabel;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          height: 340,
          width: double.infinity,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFFF7FBFF), _accentSoft],
            ),
            borderRadius: BorderRadius.circular(28),
            border: Border.all(color: _border),
          ),
          child: Stack(
            children: [
              Positioned(
                left: -24,
                top: -28,
                child: Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    color: _accent.withAlpha((0.08 * 255).round()),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
              Positioned(
                right: -32,
                bottom: -40,
                child: Container(
                  width: 140,
                  height: 140,
                  decoration: BoxDecoration(
                    color: _success.withAlpha((0.08 * 255).round()),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(18),
                child: Column(
                  children: [
                    Row(
                      children: [
                        if (discountLabel != null)
                          _StatusBadge(
                            label: discountLabel!,
                            background: _danger,
                            foreground: Colors.white,
                          ),
                        if (discountLabel != null && stockLabel != null)
                          const SizedBox(width: 8),
                        if (stockLabel != null)
                          _StatusBadge(
                            label: stockLabel!,
                            background: _success.withAlpha((0.14 * 255).round()),
                            foreground: _success,
                          ),
                        const Spacer(),
                        if (galleryCount > 0)
                          _MetaPill(
                            label: '$galleryCount images',
                            foreground: _textSecondary,
                          ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 10,
                        ),
                        child: AnimatedSwitcher(
                          duration: const Duration(milliseconds: 260),
                          switchInCurve: Curves.easeOutCubic,
                          switchOutCurve: Curves.easeInCubic,
                          child: imageUrl == null || imageUrl!.isEmpty
                              ? const _ImageFallback(
                                  key: ValueKey('empty-image'),
                                  size: 60,
                                )
                              : Image.network(
                                  imageUrl!,
                                  key: ValueKey(imageUrl),
                                  fit: BoxFit.contain,
                                  cacheWidth: 1400,
                                  headers: _imageHeaders,
                                  errorBuilder: (context, error, stackTrace) {
                                    return const _ImageFallback(
                                      key: ValueKey('error-image'),
                                      size: 60,
                                    );
                                  },
                                ),
                        ),
                      ),
                    ),
                    if (tagText.isNotEmpty || statusText.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        alignment: WrapAlignment.center,
                        children: [
                          if (tagText.isNotEmpty) _MetaPill(label: tagText),
                          if (statusText.isNotEmpty)
                            _MetaPill(
                              label: statusText,
                              foreground: _textSecondary,
                            ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
        if (galleryCount > 1) ...[
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              galleryCount,
              (index) => AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                margin: const EdgeInsets.symmetric(horizontal: 3),
                width: index == selectedIndex ? 22 : 8,
                height: 8,
                decoration: BoxDecoration(
                  color: index == selectedIndex ? _accent : _border,
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({
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
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          color: foreground,
        ),
      ),
    );
  }
}

class _CommerceSummaryCard extends StatelessWidget {
  const _CommerceSummaryCard({
    required this.name,
    required this.category,
    required this.brand,
    required this.rating,
    required this.ratingCount,
    required this.sellingPoint,
    required this.currentPrice,
    required this.oldPrice,
    required this.savingsAmount,
    required this.economicsBadge,
    required this.profitMarginPercent,
  });

  final String name;
  final String category;
  final String brand;
  final double rating;
  final int ratingCount;
  final String sellingPoint;
  final double currentPrice;
  final double? oldPrice;
  final double savingsAmount;
  final String economicsBadge;
  final double profitMarginPercent;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _MetaPill(label: category),
                  _MetaPill(label: brand, foreground: _textSecondary),
                ],
              ),
            ),
            _StatusBadge(
              label: economicsBadge,
              background: _accentSoft,
              foreground: _accentDeep,
            ),
          ],
        ),
        const SizedBox(height: 14),
        Text(
          name,
          style: GoogleFonts.inter(
            fontSize: 28,
            fontWeight: FontWeight.w800,
            color: _textPrimary,
            height: 1.15,
          ),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            const Icon(Icons.star_rounded, size: 18, color: _star),
            const SizedBox(width: 6),
            Text(
              ratingCount > 0
                  ? '${rating.toStringAsFixed(1)} ($ratingCount reviews)'
                  : 'No reviews yet',
              style: const TextStyle(
                fontSize: 13.5,
                fontWeight: FontWeight.w600,
                color: _textSecondary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Text(
          sellingPoint,
          style: const TextStyle(
            fontSize: 14,
            height: 1.55,
            color: _textSecondary,
          ),
        ),
        const SizedBox(height: 18),
        Wrap(
          crossAxisAlignment: WrapCrossAlignment.end,
          spacing: 10,
          runSpacing: 10,
          children: [
            Text(
              '\$${currentPrice.toStringAsFixed(2)}',
              style: GoogleFonts.inter(
                fontSize: 32,
                fontWeight: FontWeight.w800,
                color: _accentDeep,
                height: 1,
              ),
            ),
            if (oldPrice != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Text(
                  '\$${oldPrice!.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontSize: 15,
                    color: _textSecondary,
                    decoration: TextDecoration.lineThrough,
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 14),
        Row(
          children: [
            Expanded(
              child: _MiniMetricTile(
                icon: Icons.savings_outlined,
                label: 'Savings',
                value: '\$${savingsAmount.toStringAsFixed(2)}',
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _MiniMetricTile(
                icon: Icons.insights_outlined,
                label: 'Margin',
                value: '${profitMarginPercent.toStringAsFixed(1)}%',
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _MiniMetricTile extends StatelessWidget {
  const _MiniMetricTile({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: _surfaceSoft,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: _border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: _accentDeep),
          const SizedBox(height: 10),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: _textSecondary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: _textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}

class _ThumbnailRail extends StatelessWidget {
  const _ThumbnailRail({
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
      height: 84,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: images.length,
        separatorBuilder: (context, index) => const SizedBox(width: 10),
        itemBuilder: (context, index) {
          final selected = index == selectedIndex;
          return InkWell(
            onTap: () => onSelect(index),
            borderRadius: BorderRadius.circular(20),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              width: 78,
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: _surface,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: selected ? _accent : _border,
                  width: selected ? 1.4 : 1,
                ),
              ),
              child: Image.network(
                images[index],
                fit: BoxFit.contain,
                headers: _imageHeaders,
                errorBuilder: (context, error, stackTrace) {
                  return const _ImageFallback(size: 22);
                },
              ),
            ),
          );
        },
      ),
    );
  }
}

class _IntroBlock extends StatelessWidget {
  const _IntroBlock({
    required this.name,
    required this.brand,
    required this.tagText,
    required this.rating,
    required this.ratingCount,
    required this.availabilityText,
    required this.isAvailable,
    required this.selectedVariant,
  });

  final String name;
  final String brand;
  final String tagText;
  final double rating;
  final int ratingCount;
  final String availabilityText;
  final bool isAvailable;
  final String selectedVariant;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: _surface.withAlpha((0.76 * 255).round()),
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: _border),
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  brand.toUpperCase(),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.1,
                    color: _textSecondary,
                  ),
                ),
              ),
              if (tagText.isNotEmpty) _MetaPill(label: tagText),
            ],
          ),
        ),
        const SizedBox(height: 14),
        Text(
          name,
          style: GoogleFonts.inter(
            fontSize: 32,
            fontWeight: FontWeight.w800,
            color: _textPrimary,
            height: 1.08,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'Curated details, transparent pricing, and quick checkout.',
          style: TextStyle(
            fontSize: 14.5,
            fontWeight: FontWeight.w500,
            color: _textSecondary,
            height: 1.5,
          ),
        ),
        const SizedBox(height: 18),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: [
            _InfoChip(
              icon: Icons.star_rounded,
              iconColor: _star,
              label: ratingCount > 0
                  ? '${rating.toStringAsFixed(1)} ($ratingCount)'
                  : 'New product',
            ),
            _AvailabilityChip(
              label: availabilityText,
              isAvailable: isAvailable,
            ),
          ],
        ),
        if (selectedVariant.trim().isNotEmpty) ...[
          const SizedBox(height: 18),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: _surface.withAlpha((0.72 * 255).round()),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: _border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Selected configuration',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: _textSecondary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  selectedVariant,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: _textPrimary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}

class _PricePanel extends StatelessWidget {
  const _PricePanel({
    required this.price,
    required this.oldPrice,
    required this.quantity,
    required this.onMinus,
    required this.onPlus,
  });

  final double price;
  final double? oldPrice;
  final int quantity;
  final VoidCallback onMinus;
  final VoidCallback onPlus;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: _surface.withAlpha((0.82 * 255).round()),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: _border),
        boxShadow: [
          BoxShadow(
            color: _accent.withAlpha((0.05 * 255).round()),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final compact = constraints.maxWidth < 390;
          final priceBlock = Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Price',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: _textSecondary,
                ),
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 6,
                crossAxisAlignment: WrapCrossAlignment.end,
                children: [
                  Text(
                    '\$${price.toStringAsFixed(2)}',
                    style: GoogleFonts.inter(
                      fontSize: 30,
                      fontWeight: FontWeight.w800,
                      color: _accentDeep,
                      height: 1,
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.only(bottom: 4),
                    child: Text(
                      'per unit',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: _textSecondary,
                      ),
                    ),
                  ),
                ],
              ),
              if (oldPrice != null) ...[
                const SizedBox(height: 8),
                Text(
                  '\$${oldPrice!.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontSize: 13,
                    color: _textSecondary,
                    decoration: TextDecoration.lineThrough,
                  ),
                ),
              ],
            ],
          );

          final quantityControl = _QuantityControl(
            quantity: quantity,
            onMinus: onMinus,
            onPlus: onPlus,
          );

          if (compact) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                priceBlock,
                const SizedBox(height: 18),
                quantityControl,
              ],
            );
          }

          return Row(
            children: [
              Expanded(child: priceBlock),
              const SizedBox(width: 18),
              quantityControl,
            ],
          );
        },
      ),
    );
  }
}

class _QuantityControl extends StatelessWidget {
  const _QuantityControl({
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
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: _surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: _border),
        boxShadow: [
          BoxShadow(
            color: _accent.withAlpha((0.04 * 255).round()),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _QuantityButton(icon: Icons.remove_rounded, onTap: onMinus),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              '$quantity',
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: _textPrimary,
              ),
            ),
          ),
          _QuantityButton(icon: Icons.add_rounded, onTap: onPlus),
        ],
      ),
    );
  }
}

class _QuantityButton extends StatelessWidget {
  const _QuantityButton({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
        child: Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: _accentSoft,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, size: 16, color: _textPrimary),
      ),
    );
  }
}

class _OptionSection extends StatelessWidget {
  const _OptionSection({
    required this.title,
    required this.subtitle,
    required this.child,
  });

  final String title;
  final String subtitle;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: GoogleFonts.inter(
            fontSize: 19,
            fontWeight: FontWeight.w800,
            color: _textPrimary,
          ),
        ),
        const SizedBox(height: 4),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: _accentSoft,
            borderRadius: BorderRadius.circular(999),
          ),
          child: Text(
            subtitle,
            style: const TextStyle(fontSize: 12.5, color: _textSecondary),
          ),
        ),
        const SizedBox(height: 16),
        child,
      ],
    );
  }
}

class _ColorSwatch extends StatelessWidget {
  const _ColorSwatch({
    required this.label,
    required this.color,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final Color color;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final needsBorder = color.computeLuminance() > 0.85;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(999),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? _surface : Colors.transparent,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: selected ? _accent : _border),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
                border: Border.all(color: needsBorder ? _border : Colors.white),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
                color: _textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SegmentChip extends StatelessWidget {
  const _SegmentChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(999),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 11),
        decoration: BoxDecoration(
          color: selected ? _accent : _surfaceSoft,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: selected ? _accent : _border),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: selected ? Colors.white : _textPrimary,
          ),
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title, required this.subtitle});

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: _accentSoft,
            borderRadius: BorderRadius.circular(999),
          ),
          child: const Text(
            'DETAILS',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.1,
              color: _textSecondary,
            ),
          ),
        ),
        const SizedBox(height: 12),
        Text(
          title,
          style: GoogleFonts.inter(
            fontSize: 22,
            fontWeight: FontWeight.w800,
            color: _textPrimary,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          subtitle,
          style: const TextStyle(fontSize: 13, color: _textSecondary),
        ),
      ],
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: _surface,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: _border),
        boxShadow: [
          BoxShadow(
            color: _accent.withAlpha((0.05 * 255).round()),
            blurRadius: 22,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: child,
    );
  }
}

class _TrustFeatureStrip extends StatelessWidget {
  const _TrustFeatureStrip();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: const [
        Expanded(
          child: _TrustFeatureItem(
            icon: Icons.keyboard_return_rounded,
            label: '30-Day\nReturns',
          ),
        ),
        Expanded(
          child: _TrustFeatureItem(
            icon: Icons.verified_user_outlined,
            label: 'Secure\nCheckout',
          ),
        ),
        Expanded(
          child: _TrustFeatureItem(
            icon: Icons.local_shipping_outlined,
            label: 'Fast\nShipping',
          ),
        ),
      ],
    );
  }
}

class _TrustFeatureItem extends StatelessWidget {
  const _TrustFeatureItem({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 18, color: _textSecondary),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 12.5,
              fontWeight: FontWeight.w600,
              color: _textSecondary,
              height: 1.4,
            ),
          ),
        ),
      ],
    );
  }
}

class _HighlightsSection extends StatelessWidget {
  const _HighlightsSection({
    required this.brand,
    required this.condition,
    required this.category,
    required this.releaseYear,
    required this.warranty,
  });

  final String brand;
  final String condition;
  final String category;
  final String releaseYear;
  final String warranty;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Product Highlights',
          style: GoogleFonts.inter(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: _textPrimary,
          ),
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: [
            _HighlightChip(
              icon: Icons.business_rounded,
              label: 'Brand',
              value: brand,
            ),
            _HighlightChip(
              icon: Icons.tune_rounded,
              label: 'Condition',
              value: condition,
            ),
            _HighlightChip(
              icon: Icons.category_outlined,
              label: 'Category',
              value: category,
            ),
            _HighlightChip(
              icon: Icons.calendar_today_outlined,
              label: 'Release',
              value: releaseYear,
            ),
            _HighlightChip(
              icon: Icons.verified_user_outlined,
              label: 'Warranty',
              value: warranty,
            ),
          ],
        ),
      ],
    );
  }
}

class _HighlightChip extends StatelessWidget {
  const _HighlightChip({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minWidth: 148, maxWidth: 190),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: _surfaceSoft,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: _border),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: _accentSoft,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, size: 18, color: _accentDeep),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w600,
                    color: _textSecondary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w700,
                    color: _textPrimary,
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

class _InfoDisclosureRow extends StatelessWidget {
  const _InfoDisclosureRow({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: _surfaceSoft,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Icon(icon, size: 20, color: _textPrimary),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: _textPrimary,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                subtitle,
                style: const TextStyle(
                  fontSize: 12.5,
                  color: _textSecondary,
                ),
              ),
            ],
          ),
        ),
        const Icon(
          Icons.keyboard_arrow_down_rounded,
          color: _textSecondary,
        ),
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
          'Features',
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: _textPrimary,
          ),
        ),
        const SizedBox(height: 10),
        for (final item in items)
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  margin: const EdgeInsets.only(top: 6),
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: _accent,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    item,
                    style: const TextStyle(
                      fontSize: 14,
                      height: 1.55,
                      color: _textSecondary,
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

class _SpecsGrid extends StatelessWidget {
  const _SpecsGrid({required this.specs});

  final List<_SpecItem> specs;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (var index = 0; index < specs.length; index++) ...[
          _SpecTile(item: specs[index]),
          if (index != specs.length - 1) const SizedBox(height: 10),
        ],
      ],
    );
  }
}

class _SpecTile extends StatelessWidget {
  const _SpecTile({required this.item});

  final _SpecItem item;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: _surfaceSoft,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: _border),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: _surface,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(item.icon, size: 18, color: _textPrimary),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.label,
                  style: const TextStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w600,
                    color: _textSecondary,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  item.value,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: _textPrimary,
                    height: 1.3,
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

class _DescriptionBlock extends StatelessWidget {
  const _DescriptionBlock({
    required this.text,
    required this.expanded,
    required this.onToggle,
  });

  final String text;
  final bool expanded;
  final VoidCallback? onToggle;

  @override
  Widget build(BuildContext context) {
    final shouldCollapse = text.length > 180;
    final visibleText = !shouldCollapse || expanded
        ? text
        : '${text.substring(0, 180).trimRight()}...';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 180),
          child: Text(
            visibleText,
            key: ValueKey(visibleText.length),
            style: const TextStyle(
              fontSize: 14,
              height: 1.75,
              color: _textPrimary,
            ),
          ),
        ),
        if (shouldCollapse && onToggle != null) ...[
          const SizedBox(height: 10),
          TextButton(
            onPressed: onToggle,
            style: TextButton.styleFrom(
              foregroundColor: _accent,
              padding: EdgeInsets.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: Text(expanded ? 'Read less' : 'Read more'),
          ),
        ],
      ],
    );
  }
}

class _ReviewsSection extends StatelessWidget {
  const _ReviewsSection({
    required this.averageRating,
    required this.ratingCount,
    required this.reviews,
    required this.onWriteReview,
  });

  final double averageRating;
  final int ratingCount;
  final List<_ReviewEntry> reviews;
  final VoidCallback onWriteReview;

  @override
  Widget build(BuildContext context) {
    final previewReviews = reviews.take(3).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Expanded(
              child: _SectionHeader(
                title: 'Reviews Preview',
                subtitle: 'Fast social proof before purchase',
              ),
            ),
            TextButton(
              onPressed: onWriteReview,
              child: const Text('See all reviews'),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: _surfaceSoft,
            borderRadius: BorderRadius.circular(22),
          ),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final stacked = constraints.maxWidth < 380;
              final summary = Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    ratingCount > 0 ? averageRating.toStringAsFixed(1) : 'New',
                    style: GoogleFonts.inter(
                      fontSize: 34,
                      fontWeight: FontWeight.w700,
                      color: _textPrimary,
                      height: 1,
                    ),
                  ),
                  const SizedBox(height: 8),
                  _StarRatingRow(rating: averageRating),
                  const SizedBox(height: 8),
                  Text(
                    ratingCount > 0
                        ? '$ratingCount review${ratingCount == 1 ? '' : 's'}'
                        : 'No reviews yet',
                    style: const TextStyle(fontSize: 13, color: _textSecondary),
                  ),
                ],
              );

              final button = SizedBox(
                width: stacked ? double.infinity : 144,
                child: ElevatedButton(
                  onPressed: onWriteReview,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _accent,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: const Text(
                    'Write Review',
                    style: TextStyle(fontWeight: FontWeight.w700),
                  ),
                ),
              );

              if (stacked) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [summary, const SizedBox(height: 14), button],
                );
              }

              return Row(
                children: [
                  Expanded(child: summary),
                  const SizedBox(width: 16),
                  button,
                ],
              );
            },
          ),
        ),
        const SizedBox(height: 16),
        if (previewReviews.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: _surfaceSoft,
              borderRadius: BorderRadius.circular(18),
            ),
            child: const Text(
              'No written feedback yet. Be the first to share your experience.',
              style: TextStyle(
                fontSize: 13.5,
                height: 1.6,
                color: _textSecondary,
              ),
            ),
          )
        else
          Column(
            children: [
              for (var index = 0; index < previewReviews.length; index++)
                Padding(
                  padding: EdgeInsets.only(
                    bottom: index == previewReviews.length - 1 ? 0 : 12,
                  ),
                  child: _ReviewCard(review: previewReviews[index]),
                ),
            ],
          ),
      ],
    );
  }
}

class _ReviewCard extends StatelessWidget {
  const _ReviewCard({required this.review});

  final _ReviewEntry review;

  @override
  Widget build(BuildContext context) {
    final authorDetails = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          review.author,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: _textPrimary,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          review.formattedDate,
          style: const TextStyle(fontSize: 12, color: _textSecondary),
        ),
      ],
    );

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: _border),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final compact = constraints.maxWidth < 380;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (compact) ...[
                Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: _surfaceSoft,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Center(
                        child: Text(
                          review.author.substring(0, 1).toUpperCase(),
                          style: GoogleFonts.inter(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: _textPrimary,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(child: authorDetails),
                  ],
                ),
                const SizedBox(height: 10),
                _StarRatingRow(rating: review.rating.toDouble(), iconSize: 16),
              ] else
                Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: _surfaceSoft,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Center(
                        child: Text(
                          review.author.substring(0, 1).toUpperCase(),
                          style: GoogleFonts.inter(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: _textPrimary,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(child: authorDetails),
                    const SizedBox(width: 12),
                    _StarRatingRow(rating: review.rating.toDouble(), iconSize: 16),
                  ],
                ),
              const SizedBox(height: 12),
              Text(
                review.comment,
                style: const TextStyle(
                  fontSize: 13.5,
                  height: 1.6,
                  color: _textPrimary,
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _StarRatingRow extends StatelessWidget {
  const _StarRatingRow({required this.rating, this.iconSize = 18});

  final double rating;
  final double iconSize;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (index) {
        final filled = rating >= index + 1;
        final halfFilled = !filled && rating > index && rating < index + 1;
        return Padding(
          padding: EdgeInsets.only(right: index == 4 ? 0 : 4),
          child: Icon(
            filled
                ? Icons.star_rounded
                : halfFilled
                ? Icons.star_half_rounded
                : Icons.star_border_rounded,
            size: iconSize,
            color: _star,
          ),
        );
      }),
    );
  }
}

class _BottomPurchaseBar extends StatelessWidget {
  const _BottomPurchaseBar({
    required this.quantity,
    required this.total,
    required this.onBuyNow,
    required this.onAddToCart,
  });

  final int quantity;
  final double total;
  final VoidCallback onBuyNow;
  final VoidCallback onAddToCart;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 14),
      decoration: BoxDecoration(
        color: _surface.withAlpha((0.98 * 255).round()),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        border: const Border(top: BorderSide(color: _border)),
        boxShadow: [
          BoxShadow(
            color: _accent.withAlpha((0.10 * 255).round()),
            blurRadius: 28,
            offset: const Offset(0, -10),
          ),
        ],
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final compact = constraints.maxWidth < 420;
          final narrow = constraints.maxWidth < 340;

          final totalBlock = Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Total selected',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: _textSecondary,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '$quantity item${quantity == 1 ? '' : 's'}',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: _textSecondary,
                ),
              ),
              const SizedBox(height: 6),
              FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: Text(
                  '\$${total.toStringAsFixed(2)}',
                  style: GoogleFonts.inter(
                    fontSize: compact ? 23 : 25,
                    fontWeight: FontWeight.w800,
                    color: _accentDeep,
                    height: 1,
                  ),
                ),
              ),
            ],
          );

          final addToCartButton = SizedBox(
            height: 52,
            child: ElevatedButton(
              onPressed: onAddToCart,
              style: ElevatedButton.styleFrom(
                backgroundColor: _accentDeep,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
              ),
              child: const Text(
                'Add to Cart',
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
            ),
          );

          final buyNowButton = SizedBox(
            height: 52,
            child: OutlinedButton(
              onPressed: onBuyNow,
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: _accentDeep),
                foregroundColor: _accentDeep,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
              ),
              child: const Text(
                'Buy Now',
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
            ),
          );

          if (narrow) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                totalBlock,
                const SizedBox(height: 12),
                addToCartButton,
                const SizedBox(height: 8),
                buyNowButton,
              ],
            );
          }

          if (compact) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                totalBlock,
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(child: addToCartButton),
                    const SizedBox(width: 10),
                    Expanded(child: buyNowButton),
                  ],
                ),
              ],
            );
          }

          return Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(flex: 3, child: totalBlock),
              const SizedBox(width: 12),
              Expanded(flex: 2, child: addToCartButton),
              const SizedBox(width: 10),
              Expanded(flex: 2, child: buyNowButton),
            ],
          );
        },
      ),
    );
  }
}

class _ReviewComposerSheet extends StatelessWidget {
  const _ReviewComposerSheet({
    required this.productName,
    required this.selectedRating,
    required this.commentController,
    required this.onRatingChanged,
    required this.onSubmit,
  });

  final String productName;
  final int selectedRating;
  final TextEditingController commentController;
  final ValueChanged<int> onRatingChanged;
  final VoidCallback? onSubmit;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 18),
      decoration: BoxDecoration(
        color: _surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        boxShadow: const [
          BoxShadow(color: _shadow, blurRadius: 28, offset: Offset(0, 12)),
        ],
      ),
      child: SafeArea(
        top: false,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Write a review',
                      style: GoogleFonts.inter(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: _textPrimary,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close_rounded),
                    color: _textSecondary,
                  ),
                ],
              ),
              Text(
                productName,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 13, color: _textSecondary),
              ),
              const SizedBox(height: 18),
              const Text(
                'Rating',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: _textPrimary,
                ),
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                children: List.generate(5, (index) {
                  final star = index + 1;
                  final selected = star <= selectedRating;
                  return InkWell(
                    onTap: () => onRatingChanged(star),
                    borderRadius: BorderRadius.circular(14),
                    child: Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        color: selected
                            ? const Color(0xFFFFF7E5)
                            : _surfaceSoft,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: selected ? const Color(0xFFF4D082) : _border,
                        ),
                      ),
                      child: Icon(
                        selected
                            ? Icons.star_rounded
                            : Icons.star_border_rounded,
                        color: _star,
                      ),
                    ),
                  );
                }),
              ),
              const SizedBox(height: 18),
              const Text(
                'Comment',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: _textPrimary,
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: commentController,
                maxLines: 5,
                minLines: 4,
                decoration: InputDecoration(
                  hintText: 'Share your experience with this product.',
                  filled: true,
                  fillColor: _surfaceSoft,
                  contentPadding: const EdgeInsets.all(16),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(18),
                    borderSide: const BorderSide(color: _border),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(18),
                    borderSide: const BorderSide(color: _border),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(18),
                    borderSide: const BorderSide(color: _accent),
                  ),
                ),
              ),
              const SizedBox(height: 18),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: onSubmit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _accent,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                  ),
                  child: const Text(
                    'Submit review',
                    style: TextStyle(fontWeight: FontWeight.w700),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MetaPill extends StatelessWidget {
  const _MetaPill({required this.label, this.foreground = _textPrimary});

  final String label;
  final Color foreground;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(maxWidth: 180),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: _accentSoft,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          fontSize: 11.5,
          fontWeight: FontWeight.w600,
          color: foreground,
        ),
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  const _InfoChip({
    required this.icon,
    required this.iconColor,
    required this.label,
  });

  final IconData icon;
  final Color iconColor;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: _surface,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: _border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: iconColor),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12.5,
              fontWeight: FontWeight.w600,
              color: _textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}

class _AvailabilityChip extends StatelessWidget {
  const _AvailabilityChip({required this.label, required this.isAvailable});

  final String label;
  final bool isAvailable;

  @override
  Widget build(BuildContext context) {
    final color = isAvailable ? _success : _danger;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: color.withAlpha((0.14 * 255).round()),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withAlpha((0.24 * 255).round())),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12.5,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }
}

class _ReviewEntry {
  _ReviewEntry({
    required this.author,
    required this.rating,
    required this.comment,
    required this.createdAt,
  });

  final String author;
  final int rating;
  final String comment;
  final DateTime createdAt;

  static const List<String> _months = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];

  String get formattedDate {
    final month = _months[createdAt.month - 1];
    return '$month ${createdAt.day}, ${createdAt.year}';
  }
}

class _SpecItem {
  const _SpecItem({
    required this.label,
    required this.value,
    required this.icon,
  });

  final String label;
  final String value;
  final IconData icon;
}

class _ImageFallback extends StatelessWidget {
  const _ImageFallback({super.key, this.size = 28});

  final double size;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Icon(
        Icons.image_not_supported_outlined,
        size: size,
        color: _textSecondary,
      ),
    );
  }
}

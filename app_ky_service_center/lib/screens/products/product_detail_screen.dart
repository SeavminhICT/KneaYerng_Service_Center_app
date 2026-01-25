import 'package:flutter/material.dart';
import '../../models/product.dart';
import '../../services/cart_service.dart';
import '../../services/favorite_service.dart';
import '../cart/cart_screen.dart';
import '../favorites/favorite_screen.dart';

class ProductDetailScreen extends StatefulWidget {
  const ProductDetailScreen({super.key, required this.product});

  final Product product;

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  int _selectedGallery = 0;
  int _selectedCapacity = 1;
  int _selectedColor = 0;
  int _selectedCondition = 0;
  int _quantity = 1;

  static const _capacities = ['128GB', '256GB', '512GB'];
  static const _colorNames = ['Silver', 'Blue', 'Graphite', 'White'];
  static const _colors = [
    Color(0xFFE2E8F0),
    Color(0xFF1E3A8A),
    Color(0xFF111827),
    Color(0xFFF9FAFB),
  ];
  static const _conditions = ['New', 'Used', 'Refurb'];

  List<String> get _gallery => List<String>.filled(
        5,
        widget.product.imageUrl ?? '',
      );

  @override
  Widget build(BuildContext context) {
    final product = widget.product;
    final price = product.price;
    final comparePrice = (price * 1.18).roundToDouble();
    final imageUrl = product.imageUrl;
    final category = product.categoryName?.toLowerCase() ?? '';
    final isPhone = category.contains('iphone') || category.contains('samsung');
    final selectedCapacity = _capacities[_selectedCapacity];
    final selectedColorName = _colorNames[_selectedColor];
    final selectedCondition = _conditions[_selectedCondition];

    return AnimatedBuilder(
      animation: FavoriteService.instance,
      builder: (context, _) {
        final isFavorite = FavoriteService.instance.contains(product);
        return Scaffold(
          backgroundColor: const Color(0xFFF6F7FB),
          body: SafeArea(
            child: Column(
              children: [
                _DetailAppBar(
                  isFavorite: isFavorite,
                  onBack: () => Navigator.of(context).pop(),
                  onFavorite: () {
                    FavoriteService.instance.toggle(product);
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const FavoriteScreen(),
                      ),
                    );
                  },
                ),
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                    children: [
                      _HeroImage(
                        imageUrl: imageUrl,
                        discount: '-15% OFF',
                      ),
                      const SizedBox(height: 14),
                      _GalleryStrip(
                        images: _gallery,
                        selectedIndex: _selectedGallery,
                        onSelect: (index) =>
                            setState(() => _selectedGallery = index),
                      ),
                      const SizedBox(height: 16),
                      _TitleRow(
                        title: product.name,
                        rating: 4.8,
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Brand: ${product.brand ?? 'Official'}  |  SKU: KY-${product.id.toString().padLeft(4, '0')}',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF6B7280),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Text(
                            '\$${price.toStringAsFixed(0)}',
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF0F6BFF),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '\$${comparePrice.toStringAsFixed(0)}',
                            style: const TextStyle(
                              fontSize: 14,
                              color: Color(0xFF9CA3AF),
                              decoration: TextDecoration.lineThrough,
                            ),
                          ),
                          const Spacer(),
                          const _StockPill(
                            text: 'In Stock (24 units)',
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      const _InstallmentCard(),
                      const SizedBox(height: 16),
                      if (isPhone) ...[
                        _SectionTitle(
                          title: 'Storage Capacity',
                          action: selectedCapacity,
                        ),
                        const SizedBox(height: 8),
                        _ChoiceRow(
                          choices: _capacities,
                          selectedIndex: _selectedCapacity,
                          onSelect: (index) =>
                              setState(() => _selectedCapacity = index),
                        ),
                        const SizedBox(height: 12),
                      ],
                      _SectionTitle(
                        title: 'Color',
                        action: selectedColorName,
                      ),
                      const SizedBox(height: 8),
                      _ColorRow(
                        colors: _colors,
                        selectedIndex: _selectedColor,
                        onSelect: (index) =>
                            setState(() => _selectedColor = index),
                      ),
                      if (isPhone) ...[
                        const SizedBox(height: 12),
                        _SectionTitle(
                          title: 'Condition',
                          action: selectedCondition,
                        ),
                        const SizedBox(height: 8),
                        _ChoiceRow(
                          choices: _conditions,
                          selectedIndex: _selectedCondition,
                          onSelect: (index) =>
                              setState(() => _selectedCondition = index),
                        ),
                      ],
                      const SizedBox(height: 16),
                      const _SectionTitle(
                        title: 'Warranty Plan',
                        action: 'Standard',
                      ),
                      const SizedBox(height: 8),
                      const _WarrantyCard(),
                      const SizedBox(height: 16),
                      const _SectionHeader(
                        title: 'Specifications',
                        action: 'View All',
                      ),
                      const SizedBox(height: 10),
                      const _SpecRow(
                        label: 'Display',
                        value: '6.7" Super Retina XDR',
                      ),
                      const _SpecRow(label: 'Processor', value: 'A17 Pro chip'),
                      const _SpecRow(
                        label: 'Camera',
                        value: '48MP Main + 12MP Ultra',
                      ),
                      const _SpecRow(
                        label: 'Battery',
                        value: 'Up to 29 hours video',
                      ),
                      const _SpecRow(label: '5G', value: 'Yes'),
                      const _SpecRow(label: 'Weight', value: '221 grams'),
                      const SizedBox(height: 8),
                      Center(
                        child: TextButton(
                          onPressed: () {},
                          child: const Text('View All Specifications'),
                        ),
                      ),
                      const SizedBox(height: 8),
                      const _SectionHeader(title: 'Reviews', action: 'See All'),
                      const SizedBox(height: 12),
                      const _ReviewSummary(),
                      const SizedBox(height: 16),
                      const _ReviewCard(
                        name: 'Michael Chen',
                        timeAgo: '2 days ago',
                        content:
                            'Amazing phone! The camera quality is outstanding and the battery lasts all day.',
                      ),
                      const SizedBox(height: 12),
                      const _ReviewCard(
                        name: 'Sarah Johnson',
                        timeAgo: '1 week ago',
                        content:
                            'Great performance and build quality. Only downside is the price.',
                      ),
                      const SizedBox(height: 16),
                      const _PromoCard(),
                      const SizedBox(height: 16),
                      const _SectionTitle(title: 'Quantity', action: ''),
                      const SizedBox(height: 8),
                      _QuantityRow(
                        quantity: _quantity,
                        onChanged: (value) => setState(() => _quantity = value),
                      ),
                    ],
                  ),
                ),
                _BottomBar(
                  isFavorite: isFavorite,
                  price: price,
                  quantity: _quantity,
                  onAdd: () {
                    final variantParts = <String>[];
                    if (isPhone) {
                      variantParts.add(selectedCapacity);
                    }
                    variantParts.add(selectedColorName);
                    if (isPhone) {
                      variantParts.add(selectedCondition);
                    }
                    CartService.instance.add(
                      product,
                      quantity: _quantity,
                      variant: variantParts.join(' | '),
                    );
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    behavior: SnackBarBehavior.floating,
                    backgroundColor: Colors.transparent,
                    elevation: 0,
                    duration: const Duration(seconds: 2),
                    content: _AddToCartToast(
                      message: '${product.name} added to cart',
                    ),
                  ),
                );
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const CartScreen(),
                      ),
                    );
                  },
                  onFavorite: () {
                    FavoriteService.instance.toggle(product);
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const FavoriteScreen(),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _DetailAppBar extends StatelessWidget {
  const _DetailAppBar({
    required this.isFavorite,
    required this.onBack,
    required this.onFavorite,
  });

  final bool isFavorite;
  final VoidCallback onBack;
  final VoidCallback onFavorite;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 6),
      child: Row(
        children: [
          _IconButtonSurface(
            icon: Icons.arrow_back,
            onTap: onBack,
          ),
          const Spacer(),
          _IconButtonSurface(
            icon: isFavorite ? Icons.favorite : Icons.favorite_border,
            onTap: onFavorite,
            iconColor: isFavorite ? const Color(0xFFE11D48) : null,
          ),
        ],
      ),
    );
  }
}

class _IconButtonSurface extends StatelessWidget {
  const _IconButtonSurface({
    required this.icon,
    required this.onTap,
    this.iconColor,
    this.badge,
  });

  final IconData icon;
  final VoidCallback onTap;
  final Color? iconColor;
  final String? badge;

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        InkResponse(
          onTap: onTap,
          radius: 24,
          child: Container(
            height: 40,
            width: 40,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFE6E9F0)),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x0F000000),
                  blurRadius: 8,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: Icon(
              icon,
              color: iconColor ?? const Color(0xFF111827),
              size: 20,
            ),
          ),
        ),
        if (badge != null)
          Positioned(
            right: -4,
            top: -4,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
              decoration: BoxDecoration(
                color: const Color(0xFFE8590C),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                badge!,
                style: const TextStyle(
                  fontSize: 9,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class _HeroImage extends StatelessWidget {
  const _HeroImage({required this.imageUrl, required this.discount});

  final String? imageUrl;
  final String discount;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 240,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE6E9F0)),
      ),
      child: Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: imageUrl == null || imageUrl!.isEmpty
                ? const _ImageFallback()
                : Image.network(
                    imageUrl!,
                    fit: BoxFit.cover,
                    width: double.infinity,
                    headers: const {
                      'User-Agent': 'Mozilla/5.0',
                      'Accept':
                          'image/avif,image/webp,image/apng,image/*,*/*;q=0.8',
                    },
                  ),
          ),
          Positioned(
            right: 12,
            top: 12,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFFE8590C),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                discount,
                style: const TextStyle(
                  fontSize: 11,
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _GalleryStrip extends StatelessWidget {
  const _GalleryStrip({
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
      height: 64,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: images.length,
        separatorBuilder: (_, __) => const SizedBox(width: 10),
        itemBuilder: (context, index) {
          final url = images[index];
          return GestureDetector(
            onTap: () => onSelect(index),
            child: Container(
              width: 64,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: index == selectedIndex
                      ? const Color(0xFF0F6BFF)
                      : const Color(0xFFE6E9F0),
                  width: index == selectedIndex ? 2 : 1,
                ),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: url.isEmpty
                    ? const _ImageFallback()
                    : Image.network(
                        url,
                        fit: BoxFit.cover,
                        headers: const {
                          'User-Agent': 'Mozilla/5.0',
                          'Accept':
                              'image/avif,image/webp,image/apng,image/*,*/*;q=0.8',
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

class _TitleRow extends StatelessWidget {
  const _TitleRow({required this.title, required this.rating});

  final String title;
  final double rating;

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
              color: Color(0xFF111827),
            ),
          ),
        ),
        Row(
          children: [
            const Icon(Icons.star, size: 16, color: Color(0xFFF59E0B)),
            const SizedBox(width: 4),
            Text(
              rating.toStringAsFixed(1),
              style: const TextStyle(
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _StockPill extends StatelessWidget {
  const _StockPill({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFFEAF7EE),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            height: 6,
            width: 6,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Color(0xFF22C55E),
            ),
          ),
          const SizedBox(width: 6),
          Text(
            text,
            style: const TextStyle(
              fontSize: 11,
              color: Color(0xFF16A34A),
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _InstallmentCard extends StatelessWidget {
  const _InstallmentCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F7FF),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFD6E4FF)),
      ),
      child: Row(
        children: const [
          Icon(Icons.credit_card, color: Color(0xFF2563EB)),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              'Installment from \$92/month\n12 months at 0% interest',
              style: TextStyle(
                fontSize: 12,
                color: Color(0xFF1E40AF),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title, required this.action});

  final String title;
  final String action;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: Color(0xFF111827),
            ),
          ),
        ),
        if (action.isNotEmpty)
          Text(
            action,
            style: const TextStyle(
              fontSize: 12,
              color: Color(0xFF0F6BFF),
              fontWeight: FontWeight.w600,
            ),
          ),
      ],
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title, required this.action});

  final String title;
  final String action;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: Color(0xFF111827),
            ),
          ),
        ),
        TextButton(
          onPressed: () {},
          child: Text(action),
        ),
      ],
    );
  }
}

class _ChoiceRow extends StatelessWidget {
  const _ChoiceRow({
    required this.choices,
    required this.selectedIndex,
    required this.onSelect,
  });

  final List<String> choices;
  final int selectedIndex;
  final ValueChanged<int> onSelect;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(
        choices.length,
        (index) => Expanded(
          child: Padding(
            padding: EdgeInsets.only(right: index == choices.length - 1 ? 0 : 8),
            child: InkWell(
              borderRadius: BorderRadius.circular(10),
              onTap: () => onSelect(index),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color:
                      index == selectedIndex ? const Color(0xFFEFF6FF) : Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: index == selectedIndex
                        ? const Color(0xFF0F6BFF)
                        : const Color(0xFFE6E9F0),
                  ),
                ),
                child: Center(
                  child: Text(
                    choices[index],
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: index == selectedIndex
                          ? const Color(0xFF0F6BFF)
                          : const Color(0xFF111827),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ColorRow extends StatelessWidget {
  const _ColorRow({
    required this.colors,
    required this.selectedIndex,
    required this.onSelect,
  });

  final List<Color> colors;
  final int selectedIndex;
  final ValueChanged<int> onSelect;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(
        colors.length,
        (index) => Padding(
          padding: EdgeInsets.only(right: index == colors.length - 1 ? 0 : 10),
          child: GestureDetector(
            onTap: () => onSelect(index),
            child: Container(
              height: 32,
              width: 32,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: colors[index],
                border: Border.all(
                  color: index == selectedIndex
                      ? const Color(0xFF0F6BFF)
                      : const Color(0xFFD1D5DB),
                  width: index == selectedIndex ? 2 : 1,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _WarrantyCard extends StatelessWidget {
  const _WarrantyCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE6E9F0)),
      ),
      child: Row(
        children: const [
          Icon(Icons.verified_outlined, color: Color(0xFF0F6BFF)),
          SizedBox(width: 8),
          Expanded(
            child: Text(
              'Standard 1 Year\nManufacturer warranty',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Text(
            'Free',
            style: TextStyle(
              color: Color(0xFF0F6BFF),
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _SpecRow extends StatelessWidget {
  const _SpecRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                color: Color(0xFF6B7280),
              ),
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              color: Color(0xFF111827),
            ),
          ),
        ],
      ),
    );
  }
}

class _ReviewSummary extends StatelessWidget {
  const _ReviewSummary();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text(
              '4.8',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w700,
              ),
            ),
            SizedBox(height: 4),
            _StarRow(count: 5),
            SizedBox(height: 4),
            Text(
              '2,847 reviews',
              style: TextStyle(fontSize: 12, color: Color(0xFF6B7280)),
            ),
          ],
        ),
        const SizedBox(width: 16),
        const Expanded(child: _RatingBars()),
      ],
    );
  }
}

class _RatingBars extends StatelessWidget {
  const _RatingBars();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: const [
        _RatingBarRow(label: '5', value: 0.78),
        _RatingBarRow(label: '4', value: 0.15),
        _RatingBarRow(label: '3', value: 0.04),
      ],
    );
  }
}

class _RatingBarRow extends StatelessWidget {
  const _RatingBarRow({required this.label, required this.value});

  final String label;
  final double value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: [
          Text(label, style: const TextStyle(fontSize: 11)),
          const SizedBox(width: 6),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: LinearProgressIndicator(
                value: value,
                minHeight: 6,
                backgroundColor: const Color(0xFFE5E7EB),
                valueColor: const AlwaysStoppedAnimation<Color>(
                  Color(0xFFF59E0B),
                ),
              ),
            ),
          ),
          const SizedBox(width: 6),
          Text('${(value * 100).round()}%',
              style: const TextStyle(fontSize: 11, color: Color(0xFF6B7280))),
        ],
      ),
    );
  }
}

class _StarRow extends StatelessWidget {
  const _StarRow({required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(
        count,
        (index) => const Icon(
          Icons.star,
          size: 14,
          color: Color(0xFFF59E0B),
        ),
      ),
    );
  }
}

class _ReviewCard extends StatelessWidget {
  const _ReviewCard({
    required this.name,
    required this.timeAgo,
    required this.content,
  });

  final String name;
  final String timeAgo;
  final String content;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE6E9F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 16,
                backgroundColor: const Color(0xFFEFF6FF),
                child: Text(
                  name.isNotEmpty ? name[0] : 'U',
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF0F6BFF),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  name,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF111827),
                  ),
                ),
              ),
              Text(
                timeAgo,
                style: const TextStyle(
                  fontSize: 11,
                  color: Color(0xFF6B7280),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const _StarRow(count: 5),
          const SizedBox(height: 6),
          Text(
            content,
            style: const TextStyle(
              fontSize: 12,
              color: Color(0xFF4B5563),
            ),
          ),
        ],
      ),
    );
  }
}

class _PromoCard extends StatelessWidget {
  const _PromoCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF7C3AED), Color(0xFFEC4899)],
        ),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          const Expanded(
            child: Text(
              'SPECIAL OFFER\nGet \$50 off with code:\nWELCOME50',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
                fontSize: 12,
              ),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: const Color(0xFF7C3AED),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            onPressed: () {},
            child: const Text('Apply'),
          ),
        ],
      ),
    );
  }
}

class _QuantityRow extends StatelessWidget {
  const _QuantityRow({
    required this.quantity,
    required this.onChanged,
  });

  final int quantity;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _QtyButton(
          icon: Icons.remove,
          onTap: () => onChanged(quantity > 1 ? quantity - 1 : 1),
        ),
        Container(
          width: 48,
          height: 40,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: const Color(0xFFE6E9F0)),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            '$quantity',
            style: const TextStyle(fontWeight: FontWeight.w700),
          ),
        ),
        _QtyButton(
          icon: Icons.add,
          onTap: () => onChanged(quantity + 1),
        ),
        const SizedBox(width: 10),
        const Text(
          '24 available',
          style: TextStyle(fontSize: 12, color: Color(0xFF6B7280)),
        ),
      ],
    );
  }
}

class _QtyButton extends StatelessWidget {
  const _QtyButton({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkResponse(
      onTap: onTap,
      radius: 20,
      child: Container(
        height: 40,
        width: 40,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: const Color(0xFFE6E9F0)),
        ),
        child: Icon(icon, size: 18),
      ),
    );
  }
}

class _BottomBar extends StatelessWidget {
  const _BottomBar({
    required this.isFavorite,
    required this.price,
    required this.quantity,
    required this.onAdd,
    required this.onFavorite,
  });

  final bool isFavorite;
  final double price;
  final int quantity;
  final VoidCallback onAdd;
  final VoidCallback onFavorite;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 18),
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Color(0x14000000),
            blurRadius: 16,
            offset: Offset(0, -6),
          ),
        ],
      ),
      child: Row(
        children: [
          InkResponse(
            onTap: onFavorite,
            radius: 24,
            child: Container(
              height: 46,
              width: 46,
              decoration: BoxDecoration(
                color: const Color(0xFFF3F4F6),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(
                isFavorite ? Icons.favorite : Icons.favorite_border,
                color: isFavorite ? const Color(0xFFE11D48) : null,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: ElevatedButton.icon(
              onPressed: onAdd,
              icon: const Icon(Icons.shopping_bag_outlined, size: 18),
              label: Text(
                'Add to Cart ($quantity) - \$${(price * quantity).toStringAsFixed(0)}',
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0F6BFF),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
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

class _AddToCartToast extends StatelessWidget {
  const _AddToCartToast({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF111827),
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Color(0x33000000),
            blurRadius: 12,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            height: 22,
            width: 22,
            decoration: const BoxDecoration(
              color: Color(0xFF0F6BFF),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.check, size: 14, color: Colors.white),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}






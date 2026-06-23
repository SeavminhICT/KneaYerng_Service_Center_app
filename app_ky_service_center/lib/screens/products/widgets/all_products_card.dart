import 'package:flutter/material.dart';

import '../../../models/product.dart';
import '../../../theme/app_fonts.dart';
import '../../../widgets/app_network_image.dart';
import '../product_detail_screen.dart';
import 'all_products_common.dart';

/// Product card used in both the grid and list layouts of the all-products
/// screen.
class AllProductsCard extends StatelessWidget {
  const AllProductsCard({
    super.key,
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
      color: apSurface,
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
            color: apSurface,
            borderRadius: BorderRadius.circular(radius),
            border: Border.all(color: apBorder),
            boxShadow: const [
              BoxShadow(color: apShadow, blurRadius: 20, offset: Offset(0, 10)),
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
          Expanded(child: _ProductImage(imageUrl: product.imageUrl)),
          const SizedBox(height: 10),
          _ProductMetaLine(product: product),
          const SizedBox(height: 6),
          Text(
            product.name,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: kmFont(context, const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w800,
              height: 1.25,
              color: apTextPrimary,
              fontFamily: 'SF Pro Text',
            )),
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
                  style: kmFont(context, const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    height: 1.3,
                    color: apTextPrimary,
                    fontFamily: 'SF Pro Text',
                  )),
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
    final text = [primary, secondary].whereType<String>().join(' | ');

    if (text.isEmpty) {
      return const SizedBox(height: 0);
    }

    return Text(
      text,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: kmFont(context, const TextStyle(
        fontSize: 11.5,
        fontWeight: FontWeight.w600,
        color: apTextMuted,
        fontFamily: 'SF Pro Text',
      )),
    );
  }
}

class _PriceRow extends StatelessWidget {
  const _PriceRow({required this.product, required this.onAdd});

  final Product product;
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    final hasDiscount =
        product.hasDiscount && product.salePrice < product.price;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                apCurrencyFormat.format(product.salePrice),
                style: kmFont(context, TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: hasDiscount ? apDanger : apTextPrimary,
                  fontFamily: 'SF Pro Text',
                )),
              ),
              const SizedBox(height: 2),
              Text(
                hasDiscount
                    ? 'Regular ${apCurrencyFormat.format(product.price)}'
                    : 'Per unit',
                style: kmFont(context, TextStyle(
                  fontSize: 11.5,
                  color: hasDiscount ? apTextMuted : apSuccess,
                  fontWeight: FontWeight.w600,
                  fontFamily: 'SF Pro Text',
                  decoration: hasDiscount
                      ? TextDecoration.lineThrough
                      : TextDecoration.none,
                )),
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
          color: apSurfaceAlt,
          borderRadius: BorderRadius.circular(14),
        ),
        child: imageUrl == null || imageUrl!.isEmpty
            ? const _ImageFallback()
            : Padding(
                padding: const EdgeInsets.all(10),
                child: AppNetworkImage(
                  imageUrl!,
                  fit: BoxFit.contain,
                  alignment: Alignment.center,
                  errorWidget: (_, _, _) => const _ImageFallback(),
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
        style: kmFont(context, TextStyle(
          fontSize: 10.5,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.15,
          color: foreground,
          fontFamily: 'SF Pro Text',
        )),
      ),
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
          color: apBrandBlue,
          borderRadius: BorderRadius.circular(18),
          boxShadow: const [
            BoxShadow(color: apShadow, blurRadius: 10, offset: Offset(0, 6)),
          ],
        ),
        child: const Icon(Icons.add_rounded, size: 18, color: Colors.white),
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
  if (stock == null) return apBrandBlue;
  if (stock <= 0) return apDanger;
  if (stock <= 5) return apWarning;
  return apSuccess;
}

String? _firstValue(String? first, String? second) {
  if (first != null && first.trim().isNotEmpty) return first.trim();
  if (second != null && second.trim().isNotEmpty) return second.trim();
  return null;
}

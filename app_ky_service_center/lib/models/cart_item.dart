import 'product.dart';

class CartItem {
  CartItem({
    required this.product,
    this.quantity = 1,
    this.variant,
    this.variantId,
    this.variantImageUrl,
    this.variantStock,
    this.unitPrice,
  });

  final Product product;
  int quantity;
  final String? variant;
  final int? variantId;
  final String? variantImageUrl;
  final int? variantStock;
  final double? unitPrice;

  double get effectiveUnitPrice => unitPrice ?? product.salePrice;

  double get subtotal => effectiveUnitPrice * quantity;
}

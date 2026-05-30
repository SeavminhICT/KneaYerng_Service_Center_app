import 'product.dart';

class CartItem {
  CartItem({
    required this.product,
    this.remoteId,
    this.quantity = 1,
    this.variant,
    this.variantId,
    this.variantImageUrl,
    this.variantStock,
    this.unitPrice,
  });

  final Product product;
  final int? remoteId;
  int quantity;
  final String? variant;
  final int? variantId;
  final String? variantImageUrl;
  final int? variantStock;
  final double? unitPrice;

  double get effectiveUnitPrice => unitPrice ?? product.salePrice;

  double get subtotal => effectiveUnitPrice * quantity;

  factory CartItem.fromApi(Map<String, dynamic> json) {
    final productMap = _asMap(json['product']);
    final variantMap =
        _asMap(json['product_variant']) ?? _asMap(json['variant']);
    final parsedVariant = variantMap == null
        ? null
        : ProductVariant.fromJson(variantMap);

    final productPayload = <String, dynamic>{
      if (productMap != null) ...productMap,
      'id': productMap?['id'] ?? json['product_id'] ?? json['item_id'] ?? 0,
      'name':
          productMap?['name'] ?? json['product_name'] ?? json['name'] ?? 'Item',
      'price': productMap?['price'] ?? json['unit_price'] ?? json['price'] ?? 0,
      if (json['unit_price'] != null) 'sale_price': json['unit_price'],
    };

    return CartItem(
      remoteId: _toIntOrNull(json['id'] ?? json['cart_item_id']),
      product: Product.fromJson(productPayload),
      quantity: _toIntOrNull(json['quantity']) ?? 1,
      variant: json['variant_label']?.toString(),
      variantId: _toIntOrNull(json['product_variant_id'] ?? variantMap?['id']),
      variantImageUrl: parsedVariant?.imageUrl,
      variantStock: parsedVariant?.stock,
      unitPrice: _toDoubleOrNull(json['unit_price'] ?? json['price']),
    );
  }

  CartItem copyWith({
    Product? product,
    int? remoteId,
    int? quantity,
    String? variant,
    int? variantId,
    String? variantImageUrl,
    int? variantStock,
    double? unitPrice,
  }) {
    return CartItem(
      product: product ?? this.product,
      remoteId: remoteId ?? this.remoteId,
      quantity: quantity ?? this.quantity,
      variant: variant ?? this.variant,
      variantId: variantId ?? this.variantId,
      variantImageUrl: variantImageUrl ?? this.variantImageUrl,
      variantStock: variantStock ?? this.variantStock,
      unitPrice: unitPrice ?? this.unitPrice,
    );
  }

  static Map<String, dynamic>? _asMap(dynamic value) {
    if (value is Map<String, dynamic>) return value;
    if (value is Map) return Map<String, dynamic>.from(value);
    return null;
  }

  static int? _toIntOrNull(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value.toString());
  }

  static double? _toDoubleOrNull(dynamic value) {
    if (value == null) return null;
    if (value is double) return value;
    if (value is num) return value.toDouble();
    return double.tryParse(value.toString());
  }
}

import 'package:flutter/foundation.dart';
import '../models/cart_item.dart';
import '../models/product.dart';

class CartService extends ChangeNotifier {
  CartService._();

  static final CartService instance = CartService._();

  final List<CartItem> _items = [];

  List<CartItem> get items => List.unmodifiable(_items);

  bool get isEmpty => _items.isEmpty;

  void add(
    Product product, {
    int quantity = 1,
    String? variant,
    int? variantId,
    String? variantImageUrl,
    int? variantStock,
    double? unitPrice,
  }) {
    final normalizedVariant = variant?.trim();
    final existing = _items.indexWhere(
      (item) {
        if (item.product.id != product.id) return false;
        if (variantId != null || item.variantId != null) {
          return item.variantId == variantId;
        }
        return (item.variant ?? '') == (normalizedVariant ?? '');
      },
    );
    if (existing != -1) {
      _items[existing].quantity += quantity;
    } else {
      _items.add(
        CartItem(
          product: product,
          quantity: quantity,
          variant: normalizedVariant?.isEmpty == true ? null : normalizedVariant,
          variantId: variantId,
          variantImageUrl: variantImageUrl,
          variantStock: variantStock,
          unitPrice: unitPrice,
        ),
      );
    }
    notifyListeners();
  }

  void updateQuantity(CartItem item, int quantity) {
    if (quantity <= 0) {
      remove(item);
      return;
    }
    item.quantity = quantity;
    notifyListeners();
  }

  void remove(CartItem item) {
    _items.remove(item);
    notifyListeners();
  }

  double get subtotal =>
      _items.fold(0, (sum, item) => sum + item.subtotal);

  int get totalItems =>
      _items.fold(0, (sum, item) => sum + item.quantity);

  void clear() {
    _items.clear();
    notifyListeners();
  }
}

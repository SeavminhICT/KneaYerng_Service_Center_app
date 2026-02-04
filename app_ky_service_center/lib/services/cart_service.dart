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
  }) {
    final existing = _items.indexWhere(
      (item) => item.product.id == product.id && item.variant == variant,
    );
    if (existing != -1) {
      _items[existing].quantity += quantity;
    } else {
      _items.add(CartItem(product: product, quantity: quantity, variant: variant));
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

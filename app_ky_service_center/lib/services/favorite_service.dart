import 'package:flutter/foundation.dart';
import '../models/product.dart';

class FavoriteService extends ChangeNotifier {
  FavoriteService._();

  static final FavoriteService instance = FavoriteService._();

  final List<Product> _items = [];

  List<Product> get items => List.unmodifiable(_items);

  bool contains(Product product) {
    return _items.any((item) => item.id == product.id);
  }

  void add(Product product) {
    if (contains(product)) return;
    _items.add(product);
    notifyListeners();
  }

  void remove(Product product) {
    _items.removeWhere((item) => item.id == product.id);
    notifyListeners();
  }

  void toggle(Product product) {
    if (contains(product)) {
      remove(product);
    } else {
      add(product);
    }
  }
}

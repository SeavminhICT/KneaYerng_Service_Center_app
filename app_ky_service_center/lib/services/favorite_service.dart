import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/product.dart';

class FavoriteService extends ChangeNotifier {
  FavoriteService._();

  static final FavoriteService instance = FavoriteService._();

  static const String _key = 'favorite_products_v1';

  final List<Product> _items = [];

  List<Product> get items => List.unmodifiable(_items);

  // ── Load saved favorites from disk on app startup ─────────────────────────
  Future<void> load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_key);
      if (raw == null || raw.isEmpty) return;

      final list = jsonDecode(raw) as List<dynamic>;
      _items.clear();
      for (final item in list) {
        try {
          _items.add(
            Product.fromJson(Map<String, dynamic>.from(item as Map)),
          );
        } catch (_) {
          // Skip corrupted entries
        }
      }
      notifyListeners();
    } catch (_) {
      // SharedPreferences unavailable — start with empty list
    }
  }

  bool contains(Product product) =>
      _items.any((item) => item.id == product.id);

  Future<void> add(Product product) async {
    if (contains(product)) return;
    _items.add(product);
    notifyListeners();
    await _persist();
  }

  Future<void> remove(Product product) async {
    _items.removeWhere((item) => item.id == product.id);
    notifyListeners();
    await _persist();
  }

  Future<void> toggle(Product product) async {
    if (contains(product)) {
      await remove(product);
    } else {
      await add(product);
    }
  }

  // ── Save to disk ──────────────────────────────────────────────────────────
  Future<void> _persist() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final encoded = jsonEncode(_items.map((p) => p.toJson()).toList());
      await prefs.setString(_key, encoded);
    } catch (_) {}
  }
}

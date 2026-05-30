import 'dart:async';

import 'package:flutter/foundation.dart';
import '../models/cart_item.dart';
import '../models/product.dart';
import 'api_service.dart';

class CartService extends ChangeNotifier {
  CartService._();

  static final CartService instance = CartService._();

  final List<CartItem> _items = [];
  int _mutationVersion = 0;
  Future<void> _syncQueue = Future<void>.value();

  List<CartItem> get items => List.unmodifiable(_items);

  bool get isEmpty => _items.isEmpty;

  Future<void> loadFromApi() async {
    final version = _mutationVersion;
    final result = await ApiService.fetchCartItems();
    if (!result.isSuccess) return;
    if (version != _mutationVersion) return;
    _replaceWithRemoteItems(result.items, preserveUnsynced: true);
  }

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
    final existing = _items.indexWhere((item) {
      if (item.product.id != product.id) return false;
      if (variantId != null || item.variantId != null) {
        return item.variantId == variantId;
      }
      return (item.variant ?? '') == (normalizedVariant ?? '');
    });
    CartItem changedItem;
    if (existing != -1) {
      _items[existing].quantity += quantity;
      changedItem = _items[existing];
    } else {
      changedItem = CartItem(
        product: product,
        quantity: quantity,
        variant: normalizedVariant?.isEmpty == true ? null : normalizedVariant,
        variantId: variantId,
        variantImageUrl: variantImageUrl,
        variantStock: variantStock,
        unitPrice: unitPrice,
      );
      _items.add(changedItem);
    }
    final version = _markMutated();
    notifyListeners();
    _enqueueItemSync(changedItem, version);
  }

  void updateQuantity(CartItem item, int quantity) {
    if (quantity <= 0) {
      remove(item);
      return;
    }
    item.quantity = quantity;
    final version = _markMutated();
    notifyListeners();
    _enqueueItemSync(item, version);
  }

  void remove(CartItem item) {
    _items.remove(item);
    _markMutated();
    notifyListeners();
    final remoteId = item.remoteId;
    if (remoteId != null) {
      unawaited(ApiService.removeCartItem(cartItemId: remoteId));
    }
  }

  double get subtotal => _items.fold(0, (sum, item) => sum + item.subtotal);

  int get totalItems => _items.fold(0, (sum, item) => sum + item.quantity);

  void clear() {
    final remoteIds = _items
        .map((item) => item.remoteId)
        .whereType<int>()
        .toSet()
        .toList();
    _items.clear();
    _markMutated();
    notifyListeners();
    if (remoteIds.isNotEmpty) {
      unawaited(_removeRemoteItems(remoteIds));
    }
  }

  int _markMutated() {
    _mutationVersion += 1;
    return _mutationVersion;
  }

  void _enqueueItemSync(CartItem item, int version) {
    _syncQueue = _syncQueue
        .then((_) => _syncItemNow(item, version))
        .catchError((_) {});
  }

  Future<void> _syncItemNow(CartItem item, int version) async {
    final current = _findCurrentItem(item);
    if (current == null) return;

    final remoteId = current.remoteId;
    final result = remoteId == null
        ? await ApiService.addCartItem(
            product: current.product,
            quantity: current.quantity,
            variant: current.variant,
            variantId: current.variantId,
          )
        : await ApiService.updateCartItemQuantity(
            cartItemId: remoteId,
            quantity: current.quantity,
          );

    if (!result.isSuccess) return;
    if (version != _mutationVersion) {
      if (!_items.any((local) => _isSameItem(local, item))) {
        final staleRemoteIds = result.items
            .where((remote) => _isSameItem(remote, item))
            .map((remote) => remote.remoteId)
            .whereType<int>()
            .toList();
        if (staleRemoteIds.isNotEmpty) {
          unawaited(_removeRemoteItems(staleRemoteIds));
        }
        return;
      }
      _mergeRemoteIds(result.items);
      return;
    }
    _replaceWithRemoteItems(result.items, preserveUnsynced: true);
  }

  CartItem? _findCurrentItem(CartItem item) {
    if (item.remoteId != null) {
      for (final current in _items) {
        if (current.remoteId == item.remoteId) return current;
      }
    }

    for (final current in _items) {
      if (_isSameItem(current, item)) return current;
    }

    return null;
  }

  void _mergeRemoteIds(List<CartItem> remoteItems) {
    var changed = false;
    for (var index = 0; index < _items.length; index++) {
      final local = _items[index];
      if (local.remoteId != null) continue;

      for (final remote in remoteItems) {
        if (remote.remoteId != null && _isSameItem(remote, local)) {
          _items[index] = local.copyWith(remoteId: remote.remoteId);
          changed = true;
          break;
        }
      }
    }

    if (changed) {
      notifyListeners();
    }
  }

  void _replaceWithRemoteItems(
    List<CartItem> remoteItems, {
    required bool preserveUnsynced,
  }) {
    final unsynced = preserveUnsynced
        ? _items.where((item) => item.remoteId == null).toList()
        : <CartItem>[];

    _items
      ..clear()
      ..addAll(remoteItems);

    for (final item in unsynced) {
      final alreadyPresent = _items.any((remote) => _isSameItem(remote, item));
      if (!alreadyPresent) {
        _items.add(item);
      }
    }

    notifyListeners();
  }

  static bool _isSameItem(CartItem a, CartItem b) {
    if (a.product.id != b.product.id) return false;
    if (a.variantId != null || b.variantId != null) {
      return a.variantId == b.variantId;
    }
    return (a.variant ?? '') == (b.variant ?? '');
  }

  static Future<void> _removeRemoteItems(List<int> remoteIds) async {
    await Future.wait(
      remoteIds.map((id) => ApiService.removeCartItem(cartItemId: id)),
    );
  }
}

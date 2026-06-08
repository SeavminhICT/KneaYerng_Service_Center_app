import 'dart:async';

import 'package:flutter/foundation.dart';
import '../models/cart_item.dart';
import '../models/product.dart';
import 'api_service.dart';

class CartService extends ChangeNotifier {
  CartService._();

  static final CartService instance = CartService._();

  final List<CartItem> _items = [];
  final Set<int> _pendingDeleteIds = {};
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
    if (quantity <= 0) return;
    final normalizedVariant = variant?.trim();
    final existing = _items.indexWhere((item) {
      if (item.product.id != product.id) return false;
      if (variantId != null && item.variantId != null) {
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
    _markMutated();
    notifyListeners();
    _enqueueItemSync(changedItem);
  }

  void updateQuantity(CartItem item, int quantity) {
    if (quantity <= 0) {
      remove(item);
      return;
    }
    item.quantity = quantity;
    _markMutated();
    notifyListeners();
    _enqueueItemSync(item);
  }

  void remove(CartItem item) {
    _items.remove(item);
    _markMutated();
    notifyListeners();
    final remoteId = item.remoteId;
    if (remoteId != null) {
      _scheduleRemoteDelete(remoteId);
    }
  }

  void _scheduleRemoteDelete(int remoteId) {
    _pendingDeleteIds.add(remoteId);
    _syncQueue = _syncQueue
        .then((_) async {
          final result = await ApiService.removeCartItem(cartItemId: remoteId);
          // Only release the guard once the server confirms deletion.
          // On failure, keep the ID in _pendingDeleteIds so loadFromApi()
          // cannot restore the item the user explicitly removed.
          if (result.isSuccess) {
            _pendingDeleteIds.remove(remoteId);
          }
        })
        .catchError((_) {});
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
    for (final id in remoteIds) {
      _scheduleRemoteDelete(id);
    }
  }

  int _markMutated() {
    _mutationVersion += 1;
    return _mutationVersion;
  }

  void _enqueueItemSync(CartItem item) {
    _syncQueue = _syncQueue
        .then((_) => _syncItemNow(item))
        .catchError((_) {});
  }

  Future<void> _syncItemNow(CartItem item) async {
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

    // If the item was removed while the API call was in flight, clean up
    // the newly created server record so it doesn't linger.
    if (_findCurrentItem(item) == null) {
      final staleIds = result.items
          .where((r) => _isSameItem(r, item))
          .map((r) => r.remoteId)
          .whereType<int>()
          .toList();
      for (final id in staleIds) {
        _scheduleRemoteDelete(id);
      }
      return;
    }

    // Only write back the server-assigned remoteId — never replace the full
    // local cart with a single-operation server response, which may be stale
    // (e.g. a delete that hadn't propagated yet would bring old items back).
    _mergeRemoteIds(result.items);
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
      ..addAll(remoteItems.where(
          (item) => !_pendingDeleteIds.contains(item.remoteId)));

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
    if (a.variantId != null && b.variantId != null) {
      return a.variantId == b.variantId;
    }
    return (a.variant ?? '') == (b.variant ?? '');
  }
}

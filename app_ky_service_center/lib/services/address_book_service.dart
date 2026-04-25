import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/saved_address.dart';

class AddressBookService {
  AddressBookService._();

  static const String _storageKey = 'saved_addresses_v1';

  static Future<List<SavedAddress>> load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_storageKey);
    if (raw == null || raw.trim().isEmpty) {
      return [];
    }

    try {
      final decoded = jsonDecode(raw);
      if (decoded is! List) return [];
      return decoded
          .whereType<Map>()
          .map((item) => SavedAddress.fromMap(Map<String, dynamic>.from(item)))
          .toList();
    } catch (_) {
      return [];
    }
  }

  static Future<void> saveAll(List<SavedAddress> addresses) async {
    final prefs = await SharedPreferences.getInstance();
    final payload = addresses.map((item) => item.toMap()).toList();
    await prefs.setString(_storageKey, jsonEncode(payload));
  }

  static Future<List<SavedAddress>> add(SavedAddress address) async {
    final addresses = await load();
    addresses.add(address);
    await saveAll(addresses);
    return addresses;
  }

  static Future<List<SavedAddress>> update(SavedAddress address) async {
    final addresses = await load();
    final index = addresses.indexWhere((item) => item.id == address.id);
    if (index >= 0) {
      addresses[index] = address;
    } else {
      addresses.add(address);
    }
    await saveAll(addresses);
    return addresses;
  }

  static Future<List<SavedAddress>> remove(String id) async {
    final addresses = await load();
    addresses.removeWhere((item) => item.id == id);
    await saveAll(addresses);
    return addresses;
  }
}

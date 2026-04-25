import 'dart:convert';
import '../services/api_service.dart';

class Product {
  const Product({
    required this.id,
    required this.name,
    required this.price,
    this.salePriceOverride,
    this.imageUrl,
    this.thumbnailUrl,
    this.imageGallery = const [],
    this.categoryName,
    this.categoryId,
    this.brand,
    this.description,
    this.sku,
    this.discount,
    this.rating = 0,
    this.ratingCount = 0,
    this.stock,
    this.status,
    this.tag,
    this.warranty,
    this.storageCapacity,
    this.color,
    this.condition,
    this.ramOptions = const [],
    this.ssd,
    this.cpu,
    this.display,
    this.country,
    this.createdAt,
  });

  final int id;
  final String name;
  final double price;
  final double? salePriceOverride;
  final String? imageUrl;
  final String? thumbnailUrl;
  final List<String> imageGallery;
  final String? categoryName;
  final int? categoryId;
  final String? brand;
  final String? description;
  final String? sku;
  final double? discount;
  final double rating;
  final int ratingCount;
  final int? stock;
  final String? status;
  final String? tag;
  final String? warranty;
  final String? storageCapacity;
  final String? color;
  final String? condition;
  final List<String> ramOptions;
  final String? ssd;
  final String? cpu;
  final String? display;
  final String? country;
  final DateTime? createdAt;

  bool get hasDiscount {
    if ((discount ?? 0) > 0) return true;
    if (salePriceOverride != null && salePriceOverride! < price) return true;
    return false;
  }

  double get salePrice {
    final explicitSale = salePriceOverride;
    if (explicitSale != null) {
      return explicitSale < 0 ? 0 : explicitSale;
    }
    final amount = discount ?? 0;
    if (amount <= 0) return price;
    final value = price - amount;
    return value < 0 ? 0 : value;
  }

  factory Product.fromJson(Map<String, dynamic> json) {
    final category = json['category'];
    final resolvedCategoryName = category is Map
        ? category['name']?.toString()
        : json['category_name']?.toString();
    final resolvedCategoryId = category is Map
        ? _toIntOrNull(category['id'])
        : _toIntOrNull(json['category_id']);
    final thumbnailRaw = _pickImageValue(json, const [
      'thumbnail',
      'thumbnail_url',
      'thumbnailUrl',
      'thumb',
    ]);
    final imageRaw = _pickImageValue(json, const [
      'image',
      'image_url',
      'imageUrl',
      'image_path',
      'imagePath',
      'photo',
      'photo_url',
      'picture',
      'picture_url',
    ]);
    final thumbnail = ApiService.normalizeMediaUrl(thumbnailRaw);
    final image = ApiService.normalizeMediaUrl(imageRaw);
    final price =
        _toDoubleOrNull(
          json['price'] ??
              json['regular_price'] ??
              json['original_price'] ??
              json['base_price'],
        ) ??
        0;
    final salePriceOverride = _toDoubleOrNull(
      json['final_price'] ??
          json['sale_price'] ??
          json['selling_price'] ??
          json['finalPrice'] ??
          json['salePrice'],
    );
    return Product(
      id: _toInt(json['id']),
      name: (json['name'] ?? '').toString(),
      price: price,
      salePriceOverride: salePriceOverride,
      imageUrl: image ?? thumbnail,
      thumbnailUrl: thumbnail,
      imageGallery: _normalizeGallery(_toStringList(
        json['image_gallery'] ?? json['gallery'] ?? json['images'],
      )),
      categoryName: resolvedCategoryName,
      categoryId: resolvedCategoryId,
      brand: json['brand']?.toString(),
      description: _toTextValue(json['description']),
      sku: json['sku']?.toString(),
      discount: _toDoubleOrNull(
        json['discount'] ?? json['discount_amount'] ?? json['discount_value'],
      ),
      rating: _toDoubleOrNull(
            json['rating'] ??
                json['average_rating'] ??
                json['avg_rating'] ??
                json['rating_avg'] ??
                json['rating_average'] ??
                json['stars'],
          ) ??
          0,
      ratingCount: _toIntOrNull(
            json['rating_count'] ??
                json['ratings_count'] ??
                json['review_count'] ??
                json['reviews_count'],
          ) ??
          0,
      stock: _toIntOrNull(json['stock'] ?? json['quantity'] ?? json['qty']),
      status: json['status']?.toString(),
      tag: json['tag']?.toString() ?? _firstListValue(json['tags']),
      warranty: json['warranty']?.toString(),
      storageCapacity: _toTextValue(json['storage_capacity']),
      color: _toTextValue(json['color']),
      condition: _toTextValue(json['condition']),
      ramOptions: _toStringList(json['ram']),
      ssd: _toTextValue(json['ssd']),
      cpu: _toTextValue(json['cpu']),
      display: _toTextValue(json['display']),
      country: _toTextValue(json['country']),
      createdAt: _toDateTime(json['created_at']),
    );
  }

  static int _toInt(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }

  static int? _toIntOrNull(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value.toString());
  }

  static double _toDouble(dynamic value) {
    if (value is double) return value;
    if (value is num) return value.toDouble();
    return double.tryParse(value?.toString() ?? '') ?? 0;
  }

  static double? _toDoubleOrNull(dynamic value) {
    if (value == null) return null;
    if (value is double) return value;
    if (value is num) return value.toDouble();
    return double.tryParse(value.toString());
  }

  static List<String> _toStringList(dynamic value) {
    if (value is List) {
      return value
          .map((item) {
            if (item == null) return null;
            if (item is String) return item;
            if (item is Map) {
              final map = Map<String, dynamic>.from(item);
              final candidate =
                  map['image'] ??
                  map['image_url'] ??
                  map['image_path'] ??
                  map['imagePath'] ??
                  map['url'] ??
                  map['path'] ??
                  map['file_path'] ??
                  map['filePath'] ??
                  map['src'];
              return candidate?.toString();
            }
            return item.toString();
          })
          .whereType<String>()
          .where((item) => item.isNotEmpty)
          .toList();
    }
    if (value is String) {
      final trimmed = value.trim();
      if (trimmed.isEmpty) return [];
      if (trimmed.startsWith('[') && trimmed.endsWith(']')) {
        try {
          final decoded = jsonDecode(trimmed);
          if (decoded is List) {
            return _toStringList(decoded);
          }
        } catch (_) {
          final fallback = trimmed.substring(1, trimmed.length - 1);
          return fallback
              .split(RegExp(r'[|,;]'))
              .map(
                (item) => item.trim().replaceAll("'", '').replaceAll('"', ''),
              )
              .where((item) => item.isNotEmpty)
              .toList();
        }
      }
      return [trimmed];
    }
    return [];
  }

  static String? _firstListValue(dynamic value) {
    for (final item in _toStringList(value)) {
      final trimmed = item.trim();
      if (trimmed.isNotEmpty) return trimmed;
    }
    return null;
  }

  static List<String> _normalizeGallery(List<String> raw) {
    return raw
        .map((item) => item.trim())
        .where((item) => item.isNotEmpty)
        .map((item) {
          var cleaned = item;
          if ((cleaned.startsWith('"') && cleaned.endsWith('"')) ||
              (cleaned.startsWith("'") && cleaned.endsWith("'"))) {
            cleaned = cleaned.substring(1, cleaned.length - 1);
          }
          return cleaned.trim();
        })
        .where((item) {
          final lowered = item.toLowerCase();
          return lowered.isNotEmpty &&
              lowered != 'null' &&
              lowered != 'undefined';
        })
        .map(ApiService.normalizeMediaUrl)
        .whereType<String>()
        .where((item) => item.isNotEmpty)
        .toList();
  }

  static String? _pickImageValue(
    Map<String, dynamic> json,
    List<String> keys,
  ) {
    for (final key in keys) {
      final value = json[key];
      if (value is String) {
        final trimmed = value.trim();
        if (trimmed.isEmpty) continue;
        final lowered = trimmed.toLowerCase();
        if (lowered == 'null' || lowered == 'undefined') continue;
        if (trimmed.startsWith('[') && trimmed.endsWith(']')) {
          try {
            final decoded = jsonDecode(trimmed);
            if (decoded is List) {
              final list = _toStringList(decoded);
              if (list.isNotEmpty) return list.first.trim();
            }
          } catch (_) {
            final fallback = trimmed.substring(1, trimmed.length - 1);
            final list = fallback
                .split(RegExp(r'[|,;]'))
                .map(
                  (item) => item.trim().replaceAll("'", '').replaceAll('"', ''),
                )
                .where((item) => item.isNotEmpty)
                .toList();
            if (list.isNotEmpty) return list.first.trim();
          }
        }
        return trimmed;
      }
      if (value is List) {
        final list = _toStringList(value);
        if (list.isNotEmpty) return list.first.trim();
      }
      if (value is Map) {
        final map = Map<String, dynamic>.from(value);
        final candidate =
            map['image'] ??
            map['image_url'] ??
            map['image_path'] ??
            map['imagePath'] ??
            map['url'] ??
            map['path'] ??
            map['file_path'] ??
            map['filePath'] ??
            map['src'];
        if (candidate is String) {
          final trimmed = candidate.trim();
          if (trimmed.isEmpty) continue;
          final lowered = trimmed.toLowerCase();
          if (lowered == 'null' || lowered == 'undefined') continue;
          return trimmed;
        }
      }
    }
    return null;
  }

  static DateTime? _toDateTime(dynamic value) {
    if (value is DateTime) return value;
    if (value is String && value.isNotEmpty) {
      return DateTime.tryParse(value);
    }
    return null;
  }

  static String? _toTextValue(dynamic value) {
    if (value == null) return null;
    if (value is List) {
      final values = value
          .map((item) => item?.toString().trim())
          .whereType<String>()
          .where((item) => item.isNotEmpty)
          .toList();
      if (values.isEmpty) return null;
      return values.join(', ');
    }
    final text = value.toString().trim();
    if (text.isEmpty || text == 'null') return null;
    return text;
  }
}

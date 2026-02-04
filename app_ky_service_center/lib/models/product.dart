import '../services/api_service.dart';

class Product {
  const Product({
    required this.id,
    required this.name,
    required this.price,
    this.imageUrl,
    this.thumbnailUrl,
    this.imageGallery = const [],
    this.categoryName,
    this.categoryId,
    this.brand,
    this.description,
    this.sku,
    this.discount,
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
  final String? imageUrl;
  final String? thumbnailUrl;
  final List<String> imageGallery;
  final String? categoryName;
  final int? categoryId;
  final String? brand;
  final String? description;
  final String? sku;
  final double? discount;
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

  factory Product.fromJson(Map<String, dynamic> json) {
    final category = json['category'];
    final thumbnail = ApiService.normalizeMediaUrl(json['thumbnail']);
    final image = ApiService.normalizeMediaUrl(json['image']);
    return Product(
      id: _toInt(json['id']),
      name: (json['name'] ?? '').toString(),
      price: _toDouble(json['price']),
      imageUrl: image ?? thumbnail,
      thumbnailUrl: thumbnail,
      imageGallery: _toStringList(json['image_gallery']),
      categoryName: category is Map ? category['name']?.toString() : null,
      categoryId: category is Map ? _toIntOrNull(category['id']) : null,
      brand: json['brand']?.toString(),
      description: json['description']?.toString(),
      sku: json['sku']?.toString(),
      discount: _toDoubleOrNull(json['discount']),
      stock: _toIntOrNull(json['stock']),
      status: json['status']?.toString(),
      tag: json['tag']?.toString(),
      warranty: json['warranty']?.toString(),
      storageCapacity: json['storage_capacity']?.toString(),
      color: json['color']?.toString(),
      condition: json['condition']?.toString(),
      ramOptions: _toStringList(json['ram']),
      ssd: json['ssd']?.toString(),
      cpu: json['cpu']?.toString(),
      display: json['display']?.toString(),
      country: json['country']?.toString(),
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
          .map((item) => item?.toString())
          .whereType<String>()
          .where((item) => item.isNotEmpty)
          .toList();
    }
    if (value is String) {
      final trimmed = value.trim();
      return trimmed.isEmpty ? [] : [trimmed];
    }
    return [];
  }

  static DateTime? _toDateTime(dynamic value) {
    if (value is DateTime) return value;
    if (value is String && value.isNotEmpty) {
      return DateTime.tryParse(value);
    }
    return null;
  }
}

import '../services/api_service.dart';

class Product {
  const Product({
    required this.id,
    required this.name,
    required this.price,
    this.imageUrl,
    this.categoryName,
    this.brand,
    this.discount,
    this.stock,
  });

  final int id;
  final String name;
  final double price;
  final String? imageUrl;
  final String? categoryName;
  final String? brand;
  final double? discount;
  final int? stock;

  factory Product.fromJson(Map<String, dynamic> json) {
    final category = json['category'];
    return Product(
      id: _toInt(json['id']),
      name: (json['name'] ?? '').toString(),
      price: _toDouble(json['price']),
      imageUrl: ApiService.normalizeMediaUrl(
        json['thumbnail'] ?? json['image'],
      ),
      categoryName: category is Map ? category['name']?.toString() : null,
      brand: json['brand']?.toString(),
      discount: _toDoubleOrNull(json['discount']),
      stock: _toIntOrNull(json['stock']),
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
}

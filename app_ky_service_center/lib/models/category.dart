import '../services/api_service.dart';

class Category {
  const Category({
    required this.id,
    required this.name,
    this.slug,
    this.imageUrl,
    this.productsCount,
    this.status,
  });

  final int id;
  final String name;
  final String? slug;
  final String? imageUrl;
  final int? productsCount;
  final String? status;

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: _toInt(json['id']),
      name: (json['name'] ?? json['title'] ?? json['category_name'] ?? '')
          .toString(),
      slug: json['slug']?.toString(),
      imageUrl: ApiService.normalizeMediaUrl(
        (json['image'] ??
                json['image_url'] ??
                json['thumbnail'] ??
                json['thumbnail_url'])
            ?.toString(),
      ),
      productsCount: _toIntOrNull(
        json['products_count'] ?? json['product_count'] ?? json['items_count'],
      ),
      status: json['status']?.toString(),
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
}

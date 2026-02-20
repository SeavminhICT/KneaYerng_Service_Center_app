import '../services/api_service.dart';

class Category {
  const Category({
    required this.id,
    required this.name,
    this.imageUrl,
  });

  final int id;
  final String name;
  final String? imageUrl;

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: _toInt(json['id']),
      name: (json['name'] ?? json['title'] ?? json['category_name'] ?? '')
          .toString(),
      imageUrl: ApiService.normalizeMediaUrl(
        (json['image'] ??
                json['image_url'] ??
                json['thumbnail'] ??
                json['thumbnail_url'])
            ?.toString(),
      ),
    );
  }

  static int _toInt(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }
}

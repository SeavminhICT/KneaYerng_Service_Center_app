import 'category.dart';
import 'product.dart';
import '../services/api_service.dart';

class SearchAccessory {
  const SearchAccessory({
    required this.id,
    required this.name,
    required this.price,
    required this.finalPrice,
    this.imageUrl,
    this.brand,
    this.tag,
    this.description,
    this.warranty,
    this.stock,
  });

  final int id;
  final String name;
  final double price;
  final double finalPrice;
  final String? imageUrl;
  final String? brand;
  final String? tag;
  final String? description;
  final String? warranty;
  final int? stock;

  bool get hasDiscount => finalPrice < price;

  factory SearchAccessory.fromJson(Map<String, dynamic> json) {
    return SearchAccessory(
      id: _toInt(json['id']),
      name: (json['name'] ?? '').toString(),
      price: _toDouble(json['price']),
      finalPrice: _toDouble(json['final_price'] ?? json['price']),
      imageUrl: ApiService.normalizeMediaUrl(json['image']),
      brand: json['brand']?.toString(),
      tag: json['tag']?.toString(),
      description: json['description']?.toString(),
      warranty: json['warranty']?.toString(),
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
}

class SearchRepairService {
  const SearchRepairService({
    required this.id,
    required this.title,
    required this.description,
    this.keywords = const [],
  });

  final String id;
  final String title;
  final String description;
  final List<String> keywords;

  factory SearchRepairService.fromJson(Map<String, dynamic> json) {
    final rawKeywords = json['keywords'];
    return SearchRepairService(
      id: (json['id'] ?? '').toString(),
      title: (json['title'] ?? '').toString(),
      description: (json['description'] ?? '').toString(),
      keywords: rawKeywords is List
          ? rawKeywords.map((item) => item.toString()).toList()
          : const [],
    );
  }
}

class SearchResults {
  const SearchResults({
    required this.query,
    this.products = const [],
    this.accessories = const [],
    this.categories = const [],
    this.brands = const [],
    this.repairServices = const [],
    this.popularSearches = const [],
  });

  final String query;
  final List<Product> products;
  final List<SearchAccessory> accessories;
  final List<Category> categories;
  final List<String> brands;
  final List<SearchRepairService> repairServices;
  final List<String> popularSearches;

  bool get hasAnyResult =>
      products.isNotEmpty ||
      accessories.isNotEmpty ||
      categories.isNotEmpty ||
      brands.isNotEmpty ||
      repairServices.isNotEmpty;

  factory SearchResults.fromJson(Map<String, dynamic> json) {
    final rawProducts = json['products'];
    final rawAccessories = json['accessories'];
    final rawCategories = json['categories'];
    final rawBrands = json['brands'];
    final rawServices = json['repair_services'];
    final rawPopular = json['popular_searches'];

    return SearchResults(
      query: (json['query'] ?? '').toString(),
      products: rawProducts is List
          ? rawProducts
                .whereType<Map>()
                .map((item) => Product.fromJson(Map<String, dynamic>.from(item)))
                .toList()
          : const [],
      accessories: rawAccessories is List
          ? rawAccessories
                .whereType<Map>()
                .map(
                  (item) =>
                      SearchAccessory.fromJson(Map<String, dynamic>.from(item)),
                )
                .toList()
          : const [],
      categories: rawCategories is List
          ? rawCategories
                .whereType<Map>()
                .map((item) => Category.fromJson(Map<String, dynamic>.from(item)))
                .toList()
          : const [],
      brands: rawBrands is List
          ? rawBrands
                .map((item) {
                  if (item is Map) {
                    return (item['name'] ?? item['label'] ?? '').toString();
                  }
                  return item.toString();
                })
                .where((item) => item.trim().isNotEmpty)
                .toList()
          : const [],
      repairServices: rawServices is List
          ? rawServices
                .whereType<Map>()
                .map(
                  (item) => SearchRepairService.fromJson(
                    Map<String, dynamic>.from(item),
                  ),
                )
                .toList()
          : const [],
      popularSearches: rawPopular is List
          ? rawPopular
                .map((item) => item.toString())
                .where((item) => item.trim().isNotEmpty)
                .toList()
          : const [],
    );
  }
}

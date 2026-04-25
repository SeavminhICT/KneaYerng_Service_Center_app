import '../services/api_service.dart';

class BannerItem {
  const BannerItem({
    required this.id,
    required this.imageUrl,
    this.badgeLabel,
    this.title,
    this.subtitle,
    this.ctaLabel,
    this.isActive = true,
  });

  final int id;
  final String? imageUrl;
  final String? badgeLabel;
  final String? title;
  final String? subtitle;
  final String? ctaLabel;
  final bool isActive;

  factory BannerItem.fromJson(Map<String, dynamic> json) {
    final rawImage = json['image'] ??
        json['image_url'] ??
        json['banner'] ??
        json['banner_image'] ??
        json['photo'] ??
        json['path'];
    final status = json['status'] ?? json['is_active'] ?? json['active'];
    return BannerItem(
      id: _toInt(json['id']),
      imageUrl: ApiService.normalizeMediaUrl(rawImage),
      badgeLabel:
          json['badge_label']?.toString() ?? json['badge']?.toString(),
      title: json['title']?.toString() ?? json['name']?.toString(),
      subtitle: json['subtitle']?.toString() ??
          json['description']?.toString() ??
          json['caption']?.toString(),
      ctaLabel:
          json['cta_label']?.toString() ??
          json['button_label']?.toString() ??
          json['button_text']?.toString(),
      isActive: _isActive(status),
    );
  }

  static int _toInt(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }

  static bool _isActive(dynamic value) {
    if (value == null) return true;
    if (value is bool) return value;
    if (value is num) return value != 0;
    final raw = value.toString().toLowerCase();
    return raw != '0' && raw != 'false' && raw != 'inactive';
  }
}

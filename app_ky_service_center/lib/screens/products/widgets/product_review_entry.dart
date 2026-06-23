import 'dart:typed_data';

/// A single locally-stored product review (rating, comment, photos).
///
/// Persisted to SharedPreferences by the owning screen; this class only
/// knows how to (de)serialize itself.
class ProductReviewEntry {
  ProductReviewEntry({
    required this.author,
    required this.rating,
    required this.comment,
    this.images = const [],
    required this.createdAt,
  });

  final String          author;
  final int             rating;
  final String          comment;
  final List<Uint8List> images;
  final DateTime        createdAt;

  Map<String, dynamic> toMap() => {
        'author':     author,
        'rating':     rating,
        'comment':    comment,
        'created_at': createdAt.toIso8601String(),
      };

  factory ProductReviewEntry.fromMap(Map<String, dynamic> map) {
    final parsedRating = switch (map['rating']) {
      int v    => v,
      num v    => v.toInt(),
      String v => int.tryParse(v) ?? 5,
      _        => 5,
    };
    final rawDate   = map['created_at']?.toString();
    final createdAt = rawDate == null
        ? DateTime.now()
        : DateTime.tryParse(rawDate) ?? DateTime.now();
    return ProductReviewEntry(
      author: map['author']?.toString().trim().isNotEmpty == true
          ? map['author'].toString().trim()
          : 'You',
      rating:    parsedRating.clamp(1, 5).toInt(),
      comment:   map['comment']?.toString() ?? '',
      createdAt: createdAt,
    );
  }

  static const List<String> _months = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
  ];

  String get formattedDate {
    final m = _months[createdAt.month - 1];
    return '$m ${createdAt.day}, ${createdAt.year}';
  }
}

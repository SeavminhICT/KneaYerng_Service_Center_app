import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';

/// Data model for a single feedback/review history entry shown on the
/// reviews preview screen. Extracted verbatim from reviews_preview_screen.dart
/// so persistence (SharedPreferences JSON) stays byte-for-byte compatible.
class FeedbackEntry {
  const FeedbackEntry({
    required this.id,
    required this.userName,
    required this.rating,
    required this.comment,
    required this.imageBase64,
    required this.createdAt,
  });

  final String id;
  final String userName;
  final int rating;
  final String comment;
  final List<String> imageBase64;
  final DateTime createdAt;

  String get initial {
    final trimmed = userName.trim();
    if (trimmed.isEmpty) return 'U';
    return trimmed.characters.first.toUpperCase();
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'user_name': userName,
      'rating': rating,
      'comment': comment,
      'images': imageBase64,
      'created_at': createdAt.millisecondsSinceEpoch,
    };
  }

  factory FeedbackEntry.fromMap(Map<String, dynamic> map) {
    final nowMs = DateTime.now().millisecondsSinceEpoch;
    final rawRating = map['rating'];
    final parsedRating = switch (rawRating) {
      int value => value,
      double value => value.round(),
      String value => int.tryParse(value) ?? 5,
      _ => 5,
    };
    final createdAtMs = switch (map['created_at']) {
      int value => value,
      double value => value.toInt(),
      String value => int.tryParse(value) ?? nowMs,
      _ => nowMs,
    };

    final rawImages = map['images'];
    final images = switch (rawImages) {
      List<dynamic> value =>
        value
            .map((item) => item.toString())
            .where((item) => item.trim().isNotEmpty)
            .toList(),
      _ => <String>[],
    };

    return FeedbackEntry(
      id: map['id']?.toString() ?? nowMs.toString(),
      userName: map['user_name']?.toString().trim().isNotEmpty == true
          ? map['user_name'].toString().trim()
          : 'Unknown User',
      rating: parsedRating.clamp(1, 5).toInt(),
      comment: map['comment']?.toString().trim() ?? '',
      imageBase64: images,
      createdAt: DateTime.fromMillisecondsSinceEpoch(createdAtMs),
    );
  }

  List<Uint8List> decodeImages() {
    final images = <Uint8List>[];
    for (final encoded in imageBase64) {
      try {
        final bytes = base64Decode(encoded);
        if (bytes.isNotEmpty) {
          images.add(bytes);
        }
      } catch (_) {
        continue;
      }
    }
    return images;
  }
}

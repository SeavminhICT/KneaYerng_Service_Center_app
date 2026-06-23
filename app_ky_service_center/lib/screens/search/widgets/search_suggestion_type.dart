import 'package:flutter/material.dart';

/// Maps a [SearchSuggestion.type] string to its display icon.
IconData searchSuggestionIcon(String type) {
  return switch (type.toLowerCase()) {
    'product'   => Icons.inventory_2_outlined,
    'accessory' => Icons.cable_rounded,
    'brand'     => Icons.sell_outlined,
    'category'  => Icons.category_outlined,
    'repair'    => Icons.build_circle_outlined,
    _           => Icons.search_rounded,
  };
}

/// Maps a [SearchSuggestion.type] string to its display badge label.
String searchSuggestionBadge(String type) {
  return switch (type.toLowerCase()) {
    'product'   => 'Product',
    'accessory' => 'Accessory',
    'brand'     => 'Brand',
    'category'  => 'Category',
    'repair'    => 'Repair',
    _           => '',
  };
}

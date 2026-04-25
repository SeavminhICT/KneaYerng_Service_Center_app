import 'package:shared_preferences/shared_preferences.dart';

class SearchHistoryService {
  static const _historyKey = 'search_recent_queries';
  static const _maxItems = 8;

  static Future<List<String>> getRecentSearches() async {
    final prefs = await SharedPreferences.getInstance();
    final items = prefs.getStringList(_historyKey) ?? const [];
    return items.where((item) => item.trim().isNotEmpty).toList();
  }

  static Future<void> addSearch(String query) async {
    final trimmed = query.trim();
    if (trimmed.isEmpty) return;

    final prefs = await SharedPreferences.getInstance();
    final current = prefs.getStringList(_historyKey) ?? <String>[];
    final updated = <String>[
      trimmed,
      ...current.where(
        (item) => item.trim().toLowerCase() != trimmed.toLowerCase(),
      ),
    ].take(_maxItems).toList();

    await prefs.setStringList(_historyKey, updated);
  }
}

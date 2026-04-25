import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../models/category.dart';
import '../../services/api_service.dart';
import 'category_products_screen.dart';

Map<String, String>? get _imageHeaders => null;

const _pageBg = Color(0xFFF8F9FB);
const _surface = Color(0xFFFFFFFF);
const _surfaceMuted = Color(0xFFF4F6FC);
const _border = Color(0xFFD9E1F2);
const _textPrimary = Color(0xFF172033);
const _textSecondary = Color(0xFF6D7690);
const _badgeFill = Color(0xFFF0F4FF);
const _accentBlue = Color(0xFF3972FF);
const _accentPurple = Color(0xFF7765FF);
const _accentLavender = Color(0xFFE8E5FF);
const _accentSky = Color(0xFFE6F0FF);
const _shadow = Color(0x1A20304A);
const _recentSearchesKey = 'categories_recent_searches';

class CategoriesScreen extends StatefulWidget {
  const CategoriesScreen({super.key});

  @override
  State<CategoriesScreen> createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends State<CategoriesScreen> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();

  Timer? _searchDebounce;
  List<Category> _allCategories = const [];
  List<Category> _visibleCategories = const [];
  List<String> _recentSearches = const [];
  String _activeQuery = '';
  String? _errorMessage;
  bool _isLoading = true;
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_handleSearchChanged);
    _searchFocusNode.addListener(_handleSearchFocusChanged);
    _loadRecentSearches();
    _loadCategories();
  }

  @override
  void dispose() {
    _searchDebounce?.cancel();
    _searchFocusNode
      ..removeListener(_handleSearchFocusChanged)
      ..dispose();
    _searchController
      ..removeListener(_handleSearchChanged)
      ..dispose();
    super.dispose();
  }

  void _handleSearchFocusChanged() {
    if (!mounted) return;
    setState(() {});
  }

  Future<void> _loadRecentSearches() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getStringList(_recentSearchesKey) ?? const <String>[];
    if (!mounted) return;
    setState(() => _recentSearches = saved);
  }

  Future<void> _saveRecentSearch(String query) async {
    final trimmed = query.trim();
    if (trimmed.isEmpty) return;

    final normalized = trimmed.toLowerCase();
    final updated = [
      trimmed,
      ..._recentSearches.where(
        (item) => item.trim().toLowerCase() != normalized,
      ),
    ].take(6).toList();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_recentSearchesKey, updated);
    if (!mounted) return;
    setState(() => _recentSearches = updated);
  }

  Future<void> _clearRecentSearches() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_recentSearchesKey);
    if (!mounted) return;
    setState(() => _recentSearches = const []);
  }

  Future<void> _loadCategories() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final categories = await ApiService.fetchCategories();
      if (!mounted) return;
      _allCategories = categories;
      _applySearch(query: _activeQuery, persistRecent: false);
      setState(() {
        _isLoading = false;
        _errorMessage = null;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _errorMessage =
            'Check the API connection, then pull to refresh or try again.';
      });
    }
  }

  Future<void> _refresh() async {
    await _loadCategories();
  }

  void _handleSearchChanged() {
    _searchDebounce?.cancel();
    final typedQuery = _searchController.text.trim();

    setState(() {
      _isSearching = typedQuery != _activeQuery;
    });

    _searchDebounce = Timer(const Duration(milliseconds: 280), () {
      _applySearch(query: typedQuery);
    });
  }

  void _applySearch({required String query, bool persistRecent = true}) {
    final trimmed = query.trim();
    final filtered = _filterAndSortCategories(_allCategories, trimmed);

    if (!mounted) return;
    setState(() {
      _activeQuery = trimmed;
      _visibleCategories = filtered;
      _isSearching = false;
    });

    if (persistRecent && trimmed.isNotEmpty) {
      unawaited(_saveRecentSearch(trimmed));
    }
  }

  void _clearSearch() {
    _searchDebounce?.cancel();
    _searchController.clear();
    _applySearch(query: '', persistRecent: false);
  }

  void _useRecentSearch(String query) {
    _searchDebounce?.cancel();
    _searchController.value = TextEditingValue(
      text: query,
      selection: TextSelection.collapsed(offset: query.length),
    );
    setState(() => _isSearching = true);
    _applySearch(query: query, persistRecent: false);
  }

  List<Category> _filterAndSortCategories(
    List<Category> categories,
    String query,
  ) {
    if (query.isEmpty) {
      final items = List<Category>.from(categories);
      items.sort(_compareCategories);
      return items;
    }

    final hits = categories
        .map(
          (category) => _CategorySearchHit(
            category: category,
            score: _matchScore(category, query),
          ),
        )
        .where((item) => item.score > 0)
        .toList();

    hits.sort((a, b) {
      final scoreOrder = b.score.compareTo(a.score);
      if (scoreOrder != 0) return scoreOrder;
      return _compareCategories(a.category, b.category);
    });

    return hits.map((item) => item.category).toList();
  }

  int _compareCategories(Category a, Category b) {
    final countCompare = (b.productsCount ?? 0).compareTo(a.productsCount ?? 0);
    if (countCompare != 0) return countCompare;
    return a.name.toLowerCase().compareTo(b.name.toLowerCase());
  }

  int _matchScore(Category category, String query) {
    final normalizedQuery = query.trim().toLowerCase();
    if (normalizedQuery.isEmpty) return 1;

    final values = <String>[
      category.name.trim().toLowerCase(),
      (category.slug ?? '').trim().toLowerCase(),
    ].where((value) => value.isNotEmpty).toList();

    var best = 0;
    for (final value in values) {
      if (value == normalizedQuery) {
        best = math.max(best, 300);
      }
      if (value.startsWith(normalizedQuery)) {
        best = math.max(best, 220);
      }
      if (value.contains(normalizedQuery)) {
        best = math.max(best, 180);
      }

      final tokens = value.split(RegExp(r'[\s\-_]+'));
      for (final token in tokens) {
        if (token.isEmpty) continue;
        if (token.startsWith(normalizedQuery)) {
          best = math.max(best, 160);
        }

        final distance = _levenshtein(token, normalizedQuery);
        final tolerance = normalizedQuery.length <= 4 ? 1 : 2;
        if (distance <= tolerance) {
          best = math.max(best, 140 - (distance * 20));
        }
      }

      final wholeDistance = _levenshtein(value, normalizedQuery);
      if (normalizedQuery.length >= 5 && wholeDistance <= 2) {
        best = math.max(best, 110 - (wholeDistance * 10));
      }
    }

    return best;
  }

  int _levenshtein(String a, String b) {
    if (a == b) return 0;
    if (a.isEmpty) return b.length;
    if (b.isEmpty) return a.length;

    final previous = List<int>.generate(b.length + 1, (index) => index);
    final current = List<int>.filled(b.length + 1, 0);

    for (var i = 1; i <= a.length; i++) {
      current[0] = i;
      for (var j = 1; j <= b.length; j++) {
        final substitutionCost = a[i - 1] == b[j - 1] ? 0 : 1;
        current[j] = math.min(
          math.min(current[j - 1] + 1, previous[j] + 1),
          previous[j - 1] + substitutionCost,
        );
      }
      for (var j = 0; j <= b.length; j++) {
        previous[j] = current[j];
      }
    }

    return previous[b.length];
  }

  List<Category> _suggestedCategories() {
    final items = List<Category>.from(_allCategories);
    items.sort((a, b) {
      final countCompare = (b.productsCount ?? 0).compareTo(
        a.productsCount ?? 0,
      );
      if (countCompare != 0) return countCompare;
      return b.id.compareTo(a.id);
    });
    return items.take(4).toList();
  }

  List<Category> _liveSuggestions() {
    final typedQuery = _searchController.text.trim();
    if (typedQuery.isEmpty) return const [];

    return _filterAndSortCategories(
      _allCategories,
      typedQuery,
    ).take(5).toList();
  }

  void _useSuggestion(Category category) {
    final text = category.name;
    _searchDebounce?.cancel();
    _searchController.value = TextEditingValue(
      text: text,
      selection: TextSelection.collapsed(offset: text.length),
    );
    _applySearch(query: text);
  }

  void _openCategory(Category category) {
    final query = _activeQuery;
    if (query.isNotEmpty) {
      unawaited(_saveRecentSearch(query));
    }
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => CategoryProductsScreen(
          categoryId: category.id,
          categoryName: category.name,
          title: category.name,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final liveSuggestions = _liveSuggestions();
    final showSuggestionDropdown =
        _searchFocusNode.hasFocus &&
        _searchController.text.trim().isNotEmpty &&
        liveSuggestions.isNotEmpty;
    final showRecentDropdown =
        _searchFocusNode.hasFocus &&
        _searchController.text.trim().isEmpty &&
        _recentSearches.isNotEmpty;
    final resultCount = _visibleCategories.length;

    return Theme(
      data: theme.copyWith(
        textTheme: GoogleFonts.manropeTextTheme(theme.textTheme),
        splashFactory: InkRipple.splashFactory,
      ),
      child: Scaffold(
        backgroundColor: _pageBg,
        body: Stack(
          children: [
            const Positioned.fill(child: _AuroraBackground()),
            SafeArea(
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 10),
                    child: Column(
                      children: [
                        _SearchHeader(
                          resultCount: resultCount,
                          searchController: _searchController,
                          searchFocusNode: _searchFocusNode,
                          isSearching: _isSearching,
                          onClearSearch: _clearSearch,
                        ),
                        if (showSuggestionDropdown) ...[
                          const SizedBox(height: 12),
                          _SuggestionPanel(
                            items: liveSuggestions,
                            onSelect: _useSuggestion,
                          ),
                        ],
                        if (showRecentDropdown) ...[
                          const SizedBox(height: 12),
                          _RecentSearchDropdown(
                            items: _recentSearches,
                            onSelect: _useRecentSearch,
                            onClearAll: _clearRecentSearches,
                          ),
                        ],
                      ],
                    ),
                  ),
                  Expanded(
                    child: RefreshIndicator.adaptive(
                      color: _accentBlue,
                      onRefresh: _refresh,
                      child: LayoutBuilder(
                        builder: (context, constraints) {
                          final columns = constraints.maxWidth >= 1080
                              ? 4
                              : constraints.maxWidth >= 760
                              ? 3
                              : 2;
                          final childAspectRatio = constraints.maxWidth >= 760
                              ? 0.90
                              : 0.76;

                          if (_isLoading) {
                            return ListView(
                              physics: const AlwaysScrollableScrollPhysics(
                                parent: BouncingScrollPhysics(),
                              ),
                              padding: const EdgeInsets.fromLTRB(
                                16,
                                8,
                                16,
                                132,
                              ),
                              children: [
                                _LoadingGrid(
                                  columns: columns,
                                  aspectRatio: childAspectRatio,
                                ),
                              ],
                            );
                          }

                          if (_errorMessage != null) {
                            return ListView(
                              physics: const AlwaysScrollableScrollPhysics(
                                parent: BouncingScrollPhysics(),
                              ),
                              padding: const EdgeInsets.fromLTRB(
                                16,
                                8,
                                16,
                                132,
                              ),
                              children: [
                                _StateCard(
                                  icon: Icons.wifi_off_rounded,
                                  title: 'Unable to load categories',
                                  message: _errorMessage!,
                                  actionLabel: 'Refresh',
                                  onTap: _refresh,
                                ),
                              ],
                            );
                          }

                          if (_allCategories.isEmpty) {
                            return ListView(
                              physics: const AlwaysScrollableScrollPhysics(
                                parent: BouncingScrollPhysics(),
                              ),
                              padding: const EdgeInsets.fromLTRB(
                                16,
                                8,
                                16,
                                132,
                              ),
                              children: [
                                _StateCard(
                                  icon: Icons.grid_view_rounded,
                                  title: 'No categories available',
                                  message:
                                      'The catalog is empty right now. Pull down or try reloading.',
                                  actionLabel: 'Reload',
                                  onTap: _refresh,
                                ),
                              ],
                            );
                          }

                          if (_activeQuery.isNotEmpty &&
                              _visibleCategories.isEmpty) {
                            return ListView(
                              physics: const AlwaysScrollableScrollPhysics(
                                parent: BouncingScrollPhysics(),
                              ),
                              padding: const EdgeInsets.fromLTRB(
                                16,
                                8,
                                16,
                                132,
                              ),
                              children: [
                                _SearchEmptyState(
                                  query: _activeQuery,
                                  suggestions: _suggestedCategories(),
                                  onClearSearch: _clearSearch,
                                  onOpenCategory: _openCategory,
                                ),
                              ],
                            );
                          }

                          return ListView(
                            physics: const AlwaysScrollableScrollPhysics(
                              parent: BouncingScrollPhysics(),
                            ),
                            padding: const EdgeInsets.fromLTRB(16, 8, 16, 132),
                            children: [
                              GridView.builder(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: _visibleCategories.length,
                                gridDelegate:
                                    SliverGridDelegateWithFixedCrossAxisCount(
                                      crossAxisCount: columns,
                                      crossAxisSpacing: 14,
                                      mainAxisSpacing: 14,
                                      childAspectRatio: childAspectRatio,
                                    ),
                                itemBuilder: (context, index) {
                                  final category = _visibleCategories[index];
                                  return _CategoryCard(
                                    category: category,
                                    onTap: () => _openCategory(category),
                                  );
                                },
                              ),
                            ],
                          );
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AuroraBackground extends StatelessWidget {
  const _AuroraBackground();

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        color: _pageBg,
        gradient: LinearGradient(
          colors: [Color(0xFFF8F9FB), Color(0xFFF4F7FF), Color(0xFFF8F9FB)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            top: -90,
            left: -70,
            child: _GlowOrb(
              size: 220,
              color: _accentBlue.withValues(alpha: 0.12),
            ),
          ),
          Positioned(
            top: 40,
            right: -40,
            child: _GlowOrb(
              size: 180,
              color: _accentPurple.withValues(alpha: 0.14),
            ),
          ),
          Positioned(
            bottom: 40,
            left: -20,
            child: _GlowOrb(
              size: 160,
              color: _accentLavender.withValues(alpha: 0.55),
            ),
          ),
        ],
      ),
    );
  }
}

class _GlowOrb extends StatelessWidget {
  const _GlowOrb({required this.size, required this.color});

  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(colors: [color, color.withValues(alpha: 0)]),
      ),
    );
  }
}

class _SearchHeader extends StatelessWidget {
  const _SearchHeader({
    required this.resultCount,
    required this.searchController,
    required this.searchFocusNode,
    required this.isSearching,
    required this.onClearSearch,
  });

  final int resultCount;
  final TextEditingController searchController;
  final FocusNode searchFocusNode;
  final bool isSearching;
  final VoidCallback onClearSearch;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Expanded(
              child: Text(
                'Categories',
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w900,
                  color: _textPrimary,
                  height: 1.05,
                ),
              ),
            ),
            // Container(
            //   padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            //   decoration: BoxDecoration(
            //     color: _badgeFill,
            //     borderRadius: BorderRadius.circular(999),
            //     border: Border.all(color: _border.withValues(alpha: 0.8)),
            //   ),
            //   child: Text(
            //     '$resultCount shown',
            //     style: const TextStyle(
            //       fontSize: 12,
            //       fontWeight: FontWeight.w800,
            //       color: _textPrimary,
            //     ),
            //   ),
            // ),
          ],
        ),
        const SizedBox(height: 12),
        // Container(
        //   decoration: BoxDecoration(
        //     color: _surface.withValues(alpha: 0.96),
        //     borderRadius: BorderRadius.circular(20),
        //     border: Border.all(color: _border.withValues(alpha: 0.92)),
        //     boxShadow: const [
        //       BoxShadow(
        //         color: Color(0x140F172A),
        //         blurRadius: 12,
        //         offset: Offset(0, 4),
        //       ),
        //     ],
        //   ),
        //   child: TextField(
        //     controller: searchController,
        //     focusNode: searchFocusNode,
        //     textInputAction: TextInputAction.search,
        //     style: const TextStyle(
        //       fontSize: 15,
        //       fontWeight: FontWeight.w700,
        //       color: _textPrimary,
        //     ),
        //     decoration: InputDecoration(
        //       hintText: 'Search categories...',
        //       hintStyle: const TextStyle(
        //         color: _textSecondary,
        //         fontSize: 14.5,
        //         fontWeight: FontWeight.w600,
        //       ),
        //       prefixIcon: const Icon(
        //         Icons.search_rounded,
        //         color: _textSecondary,
        //         size: 22,
        //       ),
        //       suffixIcon: _SearchFieldTrailing(
        //         showLoader: isSearching,
        //         showClear: searchController.text.trim().isNotEmpty,
        //         onClear: onClearSearch,
        //       ),
        //       filled: true,
        //       fillColor: Colors.transparent,
        //       contentPadding: const EdgeInsets.symmetric(
        //         horizontal: 18,
        //         vertical: 18,
        //       ),
        //       border: OutlineInputBorder(
        //         borderRadius: BorderRadius.circular(20),
        //         borderSide: BorderSide.none,
        //       ),
        //       enabledBorder: OutlineInputBorder(
        //         borderRadius: BorderRadius.circular(20),
        //         borderSide: BorderSide.none,
        //       ),
        //       focusedBorder: OutlineInputBorder(
        //         borderRadius: BorderRadius.circular(20),
        //         borderSide: const BorderSide(color: _accentBlue, width: 1.3),
        //       ),
        //     ),
        //   ),
        // ),
      ],
    );
  }
}

class _SearchFieldTrailing extends StatelessWidget {
  const _SearchFieldTrailing({
    required this.showLoader,
    required this.showClear,
    required this.onClear,
  });

  final bool showLoader;
  final bool showClear;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    if (!showLoader && !showClear) return const SizedBox.shrink();

    return SizedBox(
      width: showLoader && showClear ? 74 : 46,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          if (showLoader)
            const SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: _accentBlue,
              ),
            ),
          if (showLoader && showClear) const SizedBox(width: 6),
          if (showClear)
            IconButton(
              onPressed: onClear,
              splashRadius: 18,
              icon: const Icon(
                Icons.close_rounded,
                color: _textSecondary,
                size: 20,
              ),
            ),
        ],
      ),
    );
  }
}

class _SuggestionPanel extends StatelessWidget {
  const _SuggestionPanel({required this.items, required this.onSelect});

  final List<Category> items;
  final ValueChanged<Category> onSelect;

  @override
  Widget build(BuildContext context) {
    return _DropdownSurface(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: List.generate(items.length, (index) {
          final category = items[index];
          final palette = _paletteFor(category.name);
          final isLast = index == items.length - 1;
          return InkWell(
            onTap: () => onSelect(category),
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(index == 0 ? 24 : 0),
              bottom: Radius.circular(isLast ? 24 : 0),
            ),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                border: isLast
                    ? null
                    : Border(
                        bottom: BorderSide(
                          color: _border.withValues(alpha: 0.85),
                        ),
                      ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          palette.start.withValues(alpha: 0.24),
                          palette.end.withValues(alpha: 0.16),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Icon(
                      _iconForCategory(category.name),
                      size: 18,
                      color: palette.accent,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          category.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 13.5,
                            fontWeight: FontWeight.w800,
                            color: _textPrimary,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          _categoryCountLabel(category),
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: _textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Icon(
                    Icons.north_east_rounded,
                    size: 18,
                    color: _textSecondary,
                  ),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }
}

class _RecentSearchDropdown extends StatelessWidget {
  const _RecentSearchDropdown({
    required this.items,
    required this.onSelect,
    required this.onClearAll,
  });

  final List<String> items;
  final ValueChanged<String> onSelect;
  final Future<void> Function() onClearAll;

  @override
  Widget build(BuildContext context) {
    return _DropdownSurface(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 8, 12),
            child: Row(
              children: [
                const Expanded(
                  child: Text(
                    'Recent Searches',
                    style: TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w800,
                      color: _textPrimary,
                    ),
                  ),
                ),
                TextButton(
                  onPressed: onClearAll,
                  style: TextButton.styleFrom(
                    foregroundColor: _accentBlue,
                    textStyle: const TextStyle(fontWeight: FontWeight.w800),
                  ),
                  child: const Text('Clear'),
                ),
              ],
            ),
          ),
          Divider(height: 1, color: _border.withValues(alpha: 0.85)),
          ...List.generate(items.length, (index) {
            final item = items[index];
            final isLast = index == items.length - 1;
            return InkWell(
              onTap: () => onSelect(item),
              borderRadius: BorderRadius.vertical(
                bottom: Radius.circular(isLast ? 24 : 0),
              ),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
                decoration: BoxDecoration(
                  border: isLast
                      ? null
                      : Border(
                          bottom: BorderSide(
                            color: _border.withValues(alpha: 0.75),
                          ),
                        ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: _surfaceMuted,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.history_rounded,
                        size: 18,
                        color: _textSecondary,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        item,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 13.5,
                          fontWeight: FontWeight.w700,
                          color: _textPrimary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}

class _DropdownSurface extends StatelessWidget {
  const _DropdownSurface({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: _surface.withValues(alpha: 0.94),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withValues(alpha: 0.72)),
        boxShadow: const [
          BoxShadow(color: _shadow, blurRadius: 18, offset: Offset(0, 10)),
        ],
      ),
      child: child,
    );
  }
}

class _CategoryCard extends StatefulWidget {
  const _CategoryCard({required this.category, required this.onTap});

  final Category category;
  final VoidCallback onTap;

  @override
  State<_CategoryCard> createState() => _CategoryCardState();
}

class _CategoryCardState extends State<_CategoryCard> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final category = widget.category;
    final palette = _paletteFor(category.name);
    final count = category.productsCount;

    return AnimatedScale(
      scale: _isPressed ? 0.985 : 1,
      duration: const Duration(milliseconds: 160),
      curve: Curves.easeOutCubic,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(26),
          boxShadow: [
            BoxShadow(
              color: palette.shadow.withValues(alpha: _isPressed ? 0.18 : 0.24),
              blurRadius: _isPressed ? 14 : 22,
              offset: Offset(0, _isPressed ? 8 : 12),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: widget.onTap,
            onHighlightChanged: (value) => setState(() => _isPressed = value),
            borderRadius: BorderRadius.circular(26),
            splashColor: palette.accent.withValues(alpha: 0.16),
            highlightColor: Colors.white.withValues(alpha: 0.06),
            child: Ink(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(26),
                gradient: LinearGradient(
                  colors: [palette.start, palette.end],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                border: Border.all(color: Colors.white.withValues(alpha: 0.54)),
              ),
              child: Stack(
                children: [
                  Positioned(
                    top: -12,
                    right: -10,
                    child: Container(
                      width: 84,
                      height: 84,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withValues(alpha: 0.18),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 56,
                    left: -24,
                    child: Container(
                      width: 72,
                      height: 72,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: palette.accent.withValues(alpha: 0.10),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.76),
                                borderRadius: BorderRadius.circular(14),
                                boxShadow: const [
                                  BoxShadow(
                                    color: Color(0x120F172A),
                                    blurRadius: 10,
                                    offset: Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Icon(
                                _iconForCategory(category.name),
                                size: 20,
                                color: palette.accent,
                              ),
                            ),
                            const Spacer(),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.78),
                                borderRadius: BorderRadius.circular(999),
                              ),
                              child: Text(
                                count == null ? 'Open' : '$count',
                                style: TextStyle(
                                  fontSize: 11.5,
                                  fontWeight: FontWeight.w800,
                                  color: palette.accent,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Expanded(
                          child: _CategoryVisual(
                            imageUrl: category.imageUrl,
                            icon: _iconForCategory(category.name),
                            palette: palette,
                          ),
                        ),
                        const SizedBox(height: 14),
                        Text(
                          category.name,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: _textPrimary,
                            height: 1.2,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          _categoryCountLabel(category),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w600,
                            color: _textSecondary,
                          ),
                        ),
                        const SizedBox(height: 14),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 11,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.74),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  'Browse ->',
                                  style: TextStyle(
                                    fontSize: 12.8,
                                    fontWeight: FontWeight.w800,
                                    color: palette.accent,
                                  ),
                                ),
                              ),
                              Container(
                                width: 30,
                                height: 30,
                                decoration: BoxDecoration(
                                  color: palette.accent,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Icon(
                                  Icons.arrow_forward_rounded,
                                  color: Colors.white,
                                  size: 17,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _CategoryVisual extends StatelessWidget {
  const _CategoryVisual({
    required this.imageUrl,
    required this.icon,
    required this.palette,
  });

  final String? imageUrl;
  final IconData icon;
  final _CategoryPalette palette;

  @override
  Widget build(BuildContext context) {
    final trimmedUrl = imageUrl?.trim();
    if (trimmedUrl != null && trimmedUrl.isNotEmpty) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(22),
        child: Container(
          width: double.infinity,
          height: double.infinity,
          color: Colors.white.withValues(alpha: 0.30),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final imageWidth = math.min(
                constraints.maxWidth,
                math.max(72.0, (constraints.maxWidth - 18) * 1.1),
              );
              final imageHeight = math.min(
                constraints.maxHeight,
                math.max(72.0, (constraints.maxHeight - 12) * 1.1),
              );

              return Center(
                child: SizedBox(
                  width: imageWidth,
                  height: imageHeight,
                  child: Image.network(
                    trimmedUrl,
                    headers: _imageHeaders,
                    fit: BoxFit.contain,
                    alignment: Alignment.center,
                    filterQuality: FilterQuality.medium,
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return Center(
                        child: SizedBox(
                          width: 26,
                          height: 26,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.2,
                            color: palette.accent,
                            value: loadingProgress.expectedTotalBytes == null
                                ? null
                                : loadingProgress.cumulativeBytesLoaded /
                                    loadingProgress.expectedTotalBytes!,
                          ),
                        ),
                      );
                    },
                    errorBuilder: (context, error, stackTrace) {
                      return _CategoryIconArt(icon: icon, palette: palette);
                    },
                  ),
                ),
              );
            },
          ),
        ),
      );
    }

    return _CategoryIconArt(icon: icon, palette: palette);
  }
}

class _CategoryIconArt extends StatelessWidget {
  const _CategoryIconArt({required this.icon, required this.palette});

  final IconData icon;
  final _CategoryPalette palette;

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        Align(
          alignment: Alignment.topLeft,
          child: Container(
            width: 54,
            height: 54,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.32),
              borderRadius: BorderRadius.circular(18),
            ),
          ),
        ),
        Align(
          alignment: Alignment.bottomRight,
          child: Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: palette.accent.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(24),
            ),
          ),
        ),
        Container(
          width: 92,
          height: 92,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.82),
            borderRadius: BorderRadius.circular(28),
            boxShadow: [
              BoxShadow(
                color: palette.shadow.withValues(alpha: 0.18),
                blurRadius: 18,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Icon(icon, size: 38, color: palette.accent),
        ),
      ],
    );
  }
}

class _SearchEmptyState extends StatelessWidget {
  const _SearchEmptyState({
    required this.query,
    required this.suggestions,
    required this.onClearSearch,
    required this.onOpenCategory,
  });

  final String query;
  final List<Category> suggestions;
  final VoidCallback onClearSearch;
  final ValueChanged<Category> onOpenCategory;

  @override
  Widget build(BuildContext context) {
    return _StateCard(
      icon: Icons.search_off_rounded,
      title: 'No matching category',
      message:
          'No category matched "$query". Try a broader keyword or open one of the suggested categories below.',
      actionLabel: 'Clear search',
      onTap: () async => onClearSearch(),
      footer: suggestions.isEmpty
          ? null
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),
                const Text(
                  'Popular Picks',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: _textPrimary,
                  ),
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: suggestions
                      .map(
                        (category) => ActionChip(
                          onPressed: () => onOpenCategory(category),
                          backgroundColor: _surfaceMuted,
                          side: BorderSide(
                            color: _border.withValues(alpha: 0.88),
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(999),
                          ),
                          label: Text(
                            category.name,
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: _textPrimary,
                            ),
                          ),
                        ),
                      )
                      .toList(),
                ),
              ],
            ),
    );
  }
}

class _StateCard extends StatelessWidget {
  const _StateCard({
    required this.icon,
    required this.title,
    required this.message,
    required this.actionLabel,
    required this.onTap,
    this.footer,
  });

  final IconData icon;
  final String title;
  final String message;
  final String actionLabel;
  final Future<void> Function() onTap;
  final Widget? footer;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: _surface.withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: Colors.white.withValues(alpha: 0.72)),
        boxShadow: const [
          BoxShadow(color: _shadow, blurRadius: 16, offset: Offset(0, 8)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  _accentSky.withValues(alpha: 0.90),
                  _accentLavender.withValues(alpha: 0.82),
                ],
              ),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Icon(icon, color: _accentBlue),
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: _textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            message,
            style: const TextStyle(
              fontSize: 13.2,
              height: 1.6,
              color: _textSecondary,
            ),
          ),
          const SizedBox(height: 18),
          FilledButton(
            onPressed: onTap,
            style: FilledButton.styleFrom(
              backgroundColor: _accentBlue,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
            ),
            child: Text(
              actionLabel,
              style: const TextStyle(fontWeight: FontWeight.w800),
            ),
          ),
          if (footer != null) footer!,
        ],
      ),
    );
  }
}

class _LoadingGrid extends StatelessWidget {
  const _LoadingGrid({required this.columns, required this.aspectRatio});

  final int columns;
  final double aspectRatio;

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: columns * 4,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: columns,
        crossAxisSpacing: 14,
        mainAxisSpacing: 14,
        childAspectRatio: aspectRatio,
      ),
      itemBuilder: (context, index) {
        return Container(
          decoration: BoxDecoration(
            color: _surface.withValues(alpha: 0.82),
            borderRadius: BorderRadius.circular(26),
            border: Border.all(color: Colors.white.withValues(alpha: 0.76)),
            boxShadow: const [
              BoxShadow(color: _shadow, blurRadius: 14, offset: Offset(0, 8)),
            ],
          ),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: const [
                  _ShimmerBlock(width: 40, height: 40, radius: 14),
                  Spacer(),
                  _ShimmerBlock(width: 48, height: 24, radius: 999),
                ],
              ),
              const SizedBox(height: 14),
              const Expanded(
                child: Center(
                  child: _ShimmerBlock(width: 96, height: 96, radius: 28),
                ),
              ),
              const SizedBox(height: 12),
              const _ShimmerBlock(
                width: double.infinity,
                height: 16,
                radius: 999,
              ),
              const SizedBox(height: 8),
              const _ShimmerBlock(width: 90, height: 12, radius: 999),
              const SizedBox(height: 14),
              const _ShimmerBlock(
                width: double.infinity,
                height: 46,
                radius: 16,
              ),
            ],
          ),
        );
      },
    );
  }
}

class _ShimmerBlock extends StatelessWidget {
  const _ShimmerBlock({
    required this.width,
    required this.height,
    required this.radius,
  });

  final double width;
  final double height;
  final double radius;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(radius),
        gradient: LinearGradient(
          colors: [_surfaceMuted, Colors.white, _surfaceMuted],
        ),
      ),
    );
  }
}

String _categoryCountLabel(Category category) {
  final count = category.productsCount;
  if (count == null) return 'Browse available products';
  if (count == 1) return '1 product';
  return '$count products';
}

class _CategoryPalette {
  const _CategoryPalette({
    required this.start,
    required this.end,
    required this.accent,
    required this.shadow,
  });

  final Color start;
  final Color end;
  final Color accent;
  final Color shadow;
}

class _CategorySearchHit {
  const _CategorySearchHit({required this.category, required this.score});

  final Category category;
  final int score;
}

_CategoryPalette _paletteFor(String name) {
  const palettes = [
    _CategoryPalette(
      start: Color(0xFFE9F1FF),
      end: Color(0xFFDDE9FF),
      accent: Color(0xFF3972FF),
      shadow: Color(0xFF9BB9FF),
    ),
    _CategoryPalette(
      start: Color(0xFFF0EAFF),
      end: Color(0xFFE4DAFF),
      accent: Color(0xFF7765FF),
      shadow: Color(0xFFB5A5FF),
    ),
    _CategoryPalette(
      start: Color(0xFFFFEEE4),
      end: Color(0xFFFFDCCB),
      accent: Color(0xFFFF8A4C),
      shadow: Color(0xFFFFC3A4),
    ),
    _CategoryPalette(
      start: Color(0xFFE8F8FF),
      end: Color(0xFFD5F3FF),
      accent: Color(0xFF22A8D8),
      shadow: Color(0xFFA6E7FF),
    ),
  ];

  final seed = name.runes.fold<int>(0, (sum, rune) => sum + rune);
  return palettes[seed % palettes.length];
}

IconData _iconForCategory(String name) {
  final value = name.toLowerCase();
  if (value.contains('phone') || value.contains('iphone')) {
    return Icons.phone_iphone_rounded;
  }
  if (value.contains('mac') || value.contains('laptop')) {
    return Icons.laptop_mac_rounded;
  }
  if (value.contains('audio') || value.contains('head')) {
    return Icons.headphones_rounded;
  }
  if (value.contains('repair') || value.contains('service')) {
    return Icons.build_circle_rounded;
  }
  if (value.contains('watch') || value.contains('access')) {
    return Icons.watch_rounded;
  }
  if (value.contains('tablet')) {
    return Icons.tablet_mac_rounded;
  }
  return Icons.widgets_rounded;
}

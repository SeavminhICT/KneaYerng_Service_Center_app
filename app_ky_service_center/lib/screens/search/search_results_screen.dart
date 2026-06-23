import 'dart:async';

import 'package:flutter/material.dart';

import '../../models/product.dart';
import '../../models/search_results.dart';
import '../../models/search_suggestion.dart';
import '../../services/api_service.dart';
import '../../services/cart_service.dart';
import '../../services/search_history_service.dart';
import '../../widgets/auth_guard.dart';
import '../../widgets/cart_added_bottom_bar.dart';
import '../cart/cart_screen.dart';
import 'widgets/search_app_bar.dart';
import 'widgets/search_discovery_panel.dart';
import 'widgets/search_results_sliver.dart';
import 'widgets/search_results_tone.dart';
import 'widgets/search_suggestion_panel.dart';

// ── Screen ────────────────────────────────────────────────────────────────────
class SearchResultsScreen extends StatefulWidget {
  const SearchResultsScreen({
    super.key,
    required this.initialQuery,
    this.autofocus = false,
  });

  final String initialQuery;
  final bool autofocus;

  @override
  State<SearchResultsScreen> createState() => _SearchResultsScreenState();
}

class _SearchResultsScreenState extends State<SearchResultsScreen> {
  late final TextEditingController _controller;
  final FocusNode _focusNode = FocusNode();
  Timer? _debounce;
  Future<SearchResults>? _future;
  bool _isGrid = true;
  List<SearchSuggestion> _suggestions = [];
  List<String> _recentSearches = const [];
  bool _loadingSuggestions = false;

  static const List<String> _popularSearches = [
    'iPhone',
    'Samsung',
    'MacBook repair',
    'screen repair',
    'battery replacement',
  ];

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialQuery);
    _loadRecent();
    _focusNode.addListener(() { if (mounted) setState(() {}); });
    if (widget.initialQuery.trim().isNotEmpty) {
      _future = _load(widget.initialQuery);
    } else if (widget.autofocus) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _focusNode.requestFocus();
      });
    }
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  Future<SearchResults> _load(String query) async {
    final q = query.trim();
    if (q.isNotEmpty) await SearchHistoryService.addSearch(q);
    return ApiService.searchCatalog(q);
  }

  Future<void> _loadRecent() async {
    final items = await SearchHistoryService.getRecentSearches();
    if (!mounted) return;
    setState(() => _recentSearches = items);
  }

  void _updateSuggestions([String? raw]) {
    final query = (raw ?? _controller.text).trim();
    _debounce?.cancel();
    if (query.isEmpty) {
      setState(() { _suggestions = []; _loadingSuggestions = false; });
      return;
    }
    setState(() => _loadingSuggestions = true);
    _debounce = Timer(const Duration(milliseconds: 250), () async {
      final s = await ApiService.fetchSearchSuggestions(query);
      if (!mounted || _controller.text.trim() != query) return;
      setState(() { _suggestions = s; _loadingSuggestions = false; });
    });
  }

  void _submit([String? raw]) {
    final q = (raw ?? _controller.text).trim();
    if (q.isEmpty) return;
    _controller.text = q;
    _focusNode.unfocus();
    setState(() { _future = _load(q); });
    _loadRecent();
  }

  Future<void> _refresh() async {
    if (_future == null) return;
    setState(() { _future = _load(_controller.text); });
    await _future;
  }

  Future<void> _addToCart(Product product) async {
    final ok = await ensureLoggedIn(
      context,
      message: 'Please login to add items to your cart.',
    );
    if (!ok || !mounted) return;
    CartService.instance.add(product);
    await showCartAddedBottomBar(context);
  }

  @override
  Widget build(BuildContext context) {
    final cols = MediaQuery.of(context).size.width >= 600 ? 3 : 2;
    final query = _controller.text.trim();
    final showDiscovery = _focusNode.hasFocus && query.isEmpty;
    final showSuggestions = _focusNode.hasFocus && query.isNotEmpty;

    return Scaffold(
      backgroundColor: searchBg,
      appBar: SearchAppBar(
        controller: _controller,
        focusNode: _focusNode,
        isGrid: _isGrid,
        onChanged: (v) {
          setState(() {});
          _updateSuggestions(v);
        },
        onSubmitted: _submit,
        onToggleView: () => setState(() => _isGrid = !_isGrid),
        onCartTap: () => Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const CartScreen()),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: _refresh,
        color: searchBlue,
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              sliver: SliverToBoxAdapter(
                child: showDiscovery
                    ? SearchDiscoveryPanel(
                        recent: _recentSearches,
                        popular: _popularSearches,
                        onSelect: (v) {
                          _controller.text = v;
                          _submit(v);
                        },
                      )
                    : showSuggestions
                        ? SearchSuggestionPanel(
                            items: _suggestions,
                            query: query,
                            isLoading: _loadingSuggestions,
                            onSelect: (s) {
                              _controller.text = s.value;
                              _submit(s.value);
                            },
                            onSearchQuery: () => _submit(query),
                          )
                        : const SizedBox.shrink(),
              ),
            ),
            if (!showDiscovery && !showSuggestions && _future != null)
              SearchResultsSliver(
                future: _future!,
                isGrid: _isGrid,
                cols: cols,
                onAdd: _addToCart,
                onSubmit: _submit,
              ),
            if (!showDiscovery && !showSuggestions && _future == null)
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                sliver: SliverToBoxAdapter(
                  child: SearchDiscoveryPanel(
                    recent: _recentSearches,
                    popular: _popularSearches,
                    onSelect: (v) {
                      _controller.text = v;
                      _submit(v);
                    },
                  ),
                ),
              ),
            const SliverToBoxAdapter(child: SizedBox(height: 32)),
          ],
        ),
      ),
    );
  }
}

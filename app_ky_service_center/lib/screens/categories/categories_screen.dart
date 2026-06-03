import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:skeletonizer/skeletonizer.dart';

import '../../l10n/app_localizations.dart';
import '../../models/category.dart';
import '../../services/api_service.dart';
import '../../widgets/app_network_image.dart';
import 'category_products_screen.dart';

const _primary = Color(0xFF4A6CF7);
const _textPrimary = Color(0xFF1A1A1A);
const _textSecondary = Color(0xFF888888);
const _cardShadow = Color(0x14000000);
const _cardPressed = Color(0xFFEAF0FF);
const _cardBorder = Color(0xFFE8EDF5);
const _darkSurface = Color(0xFF161B22);
const _darkSurfaceSoft = Color(0xFF1D2635);
const _darkBorder = Color(0xFF2B3442);
const _darkTextPrimary = Color(0xFFE6EDF7);
const _darkTextSecondary = Color(0xFF97A2B5);

class CategoriesScreen extends StatefulWidget {
  const CategoriesScreen({super.key});

  @override
  State<CategoriesScreen> createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends State<CategoriesScreen> {
  bool _isLoading = true;
  String? _errorMessage;
  List<Category> _categories = const [];

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  Future<void> _loadCategories({bool forceRefresh = false}) async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final categories = await ApiService.fetchCategories(forceRefresh: forceRefresh);
      if (!mounted) return;
      setState(() {
        _categories = categories;
        _isLoading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _errorMessage = 'Unable to load categories. Pull down to refresh.';
      });
    }
  }

  Future<void> _openCategory(Category category) async {
    await Navigator.of(context).push(
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
    final l = AppLocalizations.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Theme(
      data: Theme.of(context).copyWith(
        textTheme: GoogleFonts.soraTextTheme(Theme.of(context).textTheme),
      ),
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        appBar: AppBar(
          automaticallyImplyLeading: false,
          leading: Navigator.of(context).canPop()
              ? IconButton(
                  icon: const Icon(Icons.arrow_back_ios_new_rounded),
                  color: isDark ? _darkTextPrimary : _textPrimary,
                  onPressed: () => Navigator.of(context).maybePop(),
                )
              : null,
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          surfaceTintColor: Colors.transparent,
          elevation: 0,
          centerTitle: false,
          title: Text(
            l.categories,
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w700,
              color: isDark ? _darkTextPrimary : _textPrimary,
            ),
          ),
        ),
        body: RefreshIndicator(
          color: _primary,
          onRefresh: () => _loadCategories(forceRefresh: true),
          child: _buildBody(l),
        ),
      ),
    );
  }

  Widget _buildBody(AppLocalizations l) {
    if (_isLoading) {
      final mockCategories = List.generate(
        6,
        (index) => Category(
          id: index,
          name: 'Category $index',
          imageUrl: '',
          productsCount: 0,
        ),
      );
      return Skeletonizer(
        enabled: true,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final columns = constraints.maxWidth >= 760 ? 3 : 2;
            return GridView.builder(
              physics: const NeverScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
              itemCount: mockCategories.length,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: columns,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 0.84,
              ),
              itemBuilder: (context, index) {
                final category = mockCategories[index];
                return _CategoryCard(
                  category: category,
                  onTap: () async {},
                );
              },
            );
          },
        ),
      );
    }

    if (_errorMessage != null) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(24),
        children: [
          const SizedBox(height: 60),
          _InfoState(
            icon: Icons.wifi_off_rounded,
            title: 'Connection issue',
            message: _errorMessage!,
            actionLabel: l.retry,
            onTap: _loadCategories,
          ),
        ],
      );
    }

    if (_categories.isEmpty) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(24),
        children: [
          const SizedBox(height: 60),
          _InfoState(
            icon: Icons.grid_view_rounded,
            title: 'No categories yet',
            message: 'Categories will appear here once available.',
            actionLabel: l.retry,
            onTap: _loadCategories,
          ),
        ],
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = constraints.maxWidth >= 760 ? 3 : 2;
        return GridView.builder(
          physics: const BouncingScrollPhysics(
            parent: AlwaysScrollableScrollPhysics(),
          ),
          padding: const EdgeInsets.fromLTRB(
            16,
            8,
            16,
            24,
          ),
          itemCount: _categories.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: columns,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 0.84,
          ),
          itemBuilder: (context, index) {
            final category = _categories[index];
            return _CategoryCard(
              category: category,
              onTap: () => _openCategory(category),
            );
          },
        );
      },
    );
  }
}

class _CategoryCard extends StatefulWidget {
  const _CategoryCard({required this.category, required this.onTap});

  final Category category;
  final Future<void> Function() onTap;

  @override
  State<_CategoryCard> createState() => _CategoryCardState();
}

class _CategoryCardState extends State<_CategoryCard> {
  bool _pressed = false;
  bool _busy = false;

  void _setPressed(bool value) {
    if (!mounted) return;
    setState(() => _pressed = value);
  }

  Future<void> _handleTap() async {
    if (_busy) return;
    _busy = true;
    try {
      _setPressed(true);
      await Future<void>.delayed(const Duration(milliseconds: 80));
      _setPressed(false);
      await widget.onTap();
    } finally {
      _busy = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final category = widget.category;
    final imageUrl = category.imageUrl?.trim();

    return AnimatedScale(
      scale: _pressed ? 0.95 : 1,
      duration: const Duration(milliseconds: 140),
      curve: Curves.easeOut,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTapDown: (_) => _setPressed(true),
        onTapCancel: () => _setPressed(false),
        onTapUp: (_) => _setPressed(false),
        onTap: _handleTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          curve: Curves.easeOut,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: _pressed
                ? (isDark ? _darkSurfaceSoft : _cardPressed)
                : (isDark ? _darkSurface : Colors.white),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: isDark ? _darkBorder : _cardBorder),
            boxShadow: [
              BoxShadow(
                color: isDark ? const Color(0x33000000) : _cardShadow,
                blurRadius: 14,
                offset: Offset(0, 6),
              ),
            ],
          ),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final imageBoxSize = (constraints.maxWidth * 0.56).clamp(
                78.0,
                108.0,
              );
              final iconSize = (imageBoxSize * 0.46).clamp(32.0, 48.0);
              final imageRadius = (imageBoxSize * 0.2).clamp(14.0, 22.0);

              return Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: Center(
                      child: Container(
                        width: imageBoxSize,
                        height: imageBoxSize,
                        decoration: const BoxDecoration(
                          color: Colors.transparent,
                        ),
                        child: imageUrl != null && imageUrl.isNotEmpty
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(
                                  imageRadius,
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(10),
                                  child: AppNetworkImage(
                                    imageUrl,
                                    fit: BoxFit.contain,
                                    errorWidget: (context, url, error) => Icon(
                                      _iconForCategory(category.name),
                                      size: iconSize,
                                      color: _primary,
                                    ),
                                  ),
                                ),
                              )
                            : Icon(
                                _iconForCategory(category.name),
                                size: iconSize,
                                color: _primary,
                              ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    category.name,
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: isDark ? _darkTextPrimary : _textPrimary,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      height: 1.2,
                    ),
                  ),
                  if (category.productsCount != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      '${category.productsCount} items',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: isDark ? _darkTextSecondary : _textSecondary,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}



class _InfoState extends StatelessWidget {
  const _InfoState({
    required this.icon,
    required this.title,
    required this.message,
    required this.actionLabel,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String message;
  final String actionLabel;
  final Future<void> Function() onTap;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? _darkSurface : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isDark ? _darkBorder : _cardBorder),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            size: 36,
            color: isDark ? _darkTextSecondary : _textSecondary,
          ),
          const SizedBox(height: 10),
          Text(
            title,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: isDark ? _darkTextPrimary : _textPrimary,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            message,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: isDark ? _darkTextSecondary : _textSecondary,
            ),
          ),
          const SizedBox(height: 12),
          ElevatedButton(
            onPressed: () {
              onTap();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: _primary,
              foregroundColor: Colors.white,
              elevation: 0,
            ),
            child: Text(actionLabel),
          ),
        ],
      ),
    );
  }
}

IconData _iconForCategory(String name) {
  final value = name.toLowerCase();
  if (value.contains('phone') || value.contains('iphone')) {
    return Icons.phone_iphone_rounded;
  }
  if (value.contains('access')) {
    return Icons.cable_rounded;
  }
  if (value.contains('repair') || value.contains('service')) {
    return Icons.build_rounded;
  }
  if (value.contains('tablet') || value.contains('ipad')) {
    return Icons.tablet_mac_rounded;
  }
  if (value.contains('laptop') || value.contains('macbook')) {
    return Icons.laptop_mac_rounded;
  }
  if (value.contains('watch')) {
    return Icons.watch_rounded;
  }
  return Icons.widgets_rounded;
}

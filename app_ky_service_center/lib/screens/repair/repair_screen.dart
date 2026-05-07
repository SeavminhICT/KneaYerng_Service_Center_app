import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;

import '../../services/api_service.dart';

class RepairScreen extends StatefulWidget {
  const RepairScreen({super.key});

  @override
  State<RepairScreen> createState() => _RepairScreenState();
}

class _RepairScreenState extends State<RepairScreen> {
  static const _bg = Color(0xFFF2F3F6);
  static const _surface = Colors.white;
  static const _ink = Color(0xFF1E1E1E);
  static const _muted = Color(0xFF8A8A8E);
  static const _line = Color(0xFFE5E5EA);
  static const _blue = Color(0xFF4B6BFF);
  static const _darkBg = Color(0xFF0D1117);
  static const _darkSurface = Color(0xFF161B22);
  static const _darkInk = Color(0xFFE6EDF7);
  static const _darkMuted = Color(0xFF97A2B5);
  static const _darkLine = Color(0xFF2B3442);

  final TextEditingController _searchController = TextEditingController();

  bool _loading = true;
  String? _error;
  List<_RepairAccessory> _items = const [];

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
    _loadAccessories();
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    if (!mounted) return;
    setState(() {});
  }

  Future<void> _openSearchSheet() async {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textController = TextEditingController(text: _searchController.text);

    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        final bottomInset = MediaQuery.of(context).viewInsets.bottom;
        return Padding(
          padding: EdgeInsets.fromLTRB(12, 0, 12, bottomInset + 12),
          child: Container(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
            decoration: BoxDecoration(
              color: isDark ? _darkSurface : _surface,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Search accessories',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: isDark ? _darkInk : _ink,
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: textController,
                  autofocus: true,
                  textInputAction: TextInputAction.search,
                  onSubmitted: (_) {
                    _searchController.text = textController.text.trim();
                    Navigator.of(context).pop();
                  },
                  decoration: InputDecoration(
                    hintText: 'Name, brand, or ID',
                    hintStyle: TextStyle(
                      color: isDark ? _darkMuted : _muted,
                    ),
                    prefixIcon: Icon(
                      Icons.search_rounded,
                      color: isDark ? _darkMuted : _muted,
                    ),
                    suffixIcon: textController.text.isEmpty
                        ? null
                        : IconButton(
                            onPressed: textController.clear,
                            icon: const Icon(Icons.close_rounded),
                            color: isDark ? _darkMuted : _muted,
                          ),
                    filled: true,
                    fillColor: isDark
                        ? const Color(0xFF1D2635)
                        : const Color(0xFFF5F5F7),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {
                          _searchController.clear();
                          Navigator.of(context).pop();
                        },
                        style: OutlinedButton.styleFrom(
                          foregroundColor: isDark ? _darkInk : _ink,
                          side: BorderSide(
                            color: isDark ? _darkLine : _line,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: const Text('Clear'),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          _searchController.text = textController.text.trim();
                          Navigator.of(context).pop();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _blue,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: const Text('Apply'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );

    textController.dispose();
  }

  Future<void> _loadAccessories() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final res = await http.get(
        Uri.parse('${ApiService.baseUrl}/accessories'),
        headers: const {'Accept': 'application/json'},
      );

      if (res.statusCode != 200) {
        throw Exception('Status ${res.statusCode}');
      }

      final decoded = jsonDecode(res.body);
      final raw = decoded is Map<String, dynamic> ? decoded['data'] : null;
      final list = raw is List
          ? raw
                .whereType<Map>()
                .map(
                  (entry) => _RepairAccessory.fromJson(
                    Map<String, dynamic>.from(entry),
                  ),
                )
                .toList()
          : <_RepairAccessory>[];

      if (!mounted) return;
      setState(() {
        _items = list;
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = 'Could not load accessories. Pull down to refresh.';
      });
    }
  }

  List<_RepairAccessory> get _filteredItems {
    final query = _searchController.text.trim().toLowerCase();

    final items = _items.where((item) {
      if (query.isEmpty) return true;
      return item.name.toLowerCase().contains(query) ||
          item.brandLabel.toLowerCase().contains(query) ||
          '#${item.id}'.contains(query);
    }).toList();

    items.sort((a, b) {
      final aDate = a.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
      final bDate = b.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
      return bDate.compareTo(aDate);
    });

    return items;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final items = _filteredItems;

    return Theme(
      data: Theme.of(context).copyWith(
        textTheme: GoogleFonts.interTextTheme(Theme.of(context).textTheme),
      ),
      child: Scaffold(
        backgroundColor: isDark ? _darkBg : _bg,
        appBar: AppBar(
          backgroundColor: isDark ? _darkBg : _bg,
          surfaceTintColor: Colors.transparent,
          elevation: 0,
          centerTitle: true,
          title: Text(
            'Accessories',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w700,
              color: isDark ? _darkInk : _ink,
            ),
          ),
          actions: [
            IconButton(
              tooltip: 'Search',
              onPressed: _openSearchSheet,
              icon: Icon(
                Icons.search_rounded,
                color: isDark ? _darkInk : _ink,
              ),
            ),
          ],
        ),
        body: RefreshIndicator(
          color: _blue,
          onRefresh: _loadAccessories,
          child: ListView(
            physics: const BouncingScrollPhysics(
              parent: AlwaysScrollableScrollPhysics(),
            ),
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            children: [
              if (_searchController.text.trim().isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Text(
                    'Result: ${items.length}',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: isDark ? _darkMuted : _muted,
                    ),
                  ),
                ),
              if (_loading)
                const Padding(
                  padding: EdgeInsets.only(top: 120),
                  child: Center(
                    child: CircularProgressIndicator(color: _blue),
                  ),
                )
              else if (_error != null)
                _MessageCard(
                  title: 'Connection issue',
                  message: _error!,
                  actionLabel: 'Try Again',
                  onTap: _loadAccessories,
                )
              else if (items.isEmpty)
                _MessageCard(
                  title: 'No accessories found',
                  message: _searchController.text.trim().isEmpty
                      ? 'No accessory data available yet.'
                      : 'Try a different keyword.',
                )
              else
                ...items.map(
                  (item) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _AccessoryCard(item: item),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AccessoryCard extends StatelessWidget {
  const _AccessoryCard({required this.item});

  final _RepairAccessory item;

  static const _surface = Colors.white;
  static const _ink = Color(0xFF1E1E1E);
  static const _muted = Color(0xFF8A8A8E);
  static const _line = Color(0xFFE5E5EA);
  static const _green = Color(0xFF11A34B);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF161B22) : _surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? const Color(0xFF2B3442) : _line,
        ),
        boxShadow: [
          BoxShadow(
            color: isDark ? const Color(0x44000000) : const Color(0x0F000000),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _ItemImage(imageUrl: item.imageUrl),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.brandLabel.toUpperCase(),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: isDark
                            ? Color(0xFF97A2B5)
                            : _muted,
                        letterSpacing: 0.3,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      item.name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: isDark ? Color(0xFFE6EDF7) : _ink,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Text(
                          '\$${item.finalPrice.toStringAsFixed(2)}',
                          style: TextStyle(
                            fontSize: 24,
                            height: 1,
                            fontWeight: FontWeight.w800,
                            color: isDark ? Color(0xFFE6EDF7) : _ink,
                          ),
                        ),
                        if (item.hasDiscount) ...[
                          const SizedBox(width: 8),
                          Text(
                            '\$${item.basePrice.toStringAsFixed(2)}',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: isDark
                                  ? Color(0xFF97A2B5)
                                  : _muted,
                              decoration: TextDecoration.lineThrough,
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Expanded(
                          child: Text(
                            item.stockLabel,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: item.stock > 0 ? _green : Colors.red,
                            ),
                          ),
                        ),
                        _WarrantyChip(warranty: item.warranty),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _WarrantyChip extends StatelessWidget {
  const _WarrantyChip({required this.warranty});

  final String? warranty;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final text = (warranty ?? '').trim();
    final hasWarranty = text.isNotEmpty && text.toLowerCase() != 'no warranty';

    final foreground = hasWarranty
        ? Colors.white
        : (isDark ? const Color(0xFF97A2B5) : const Color(0xFF8A8A8E));
    final background = hasWarranty
        ? const Color(0xFF4B6BFF)
        : (isDark ? const Color(0xFF1D2635) : const Color(0xFFF2F2F2));

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        hasWarranty ? text : 'No Warranty',
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: foreground,
        ),
      ),
    );
  }
}

class _ItemImage extends StatelessWidget {
  const _ItemImage({required this.imageUrl});

  final String? imageUrl;

  static const _surfaceSoft = Color(0xFFF4F4F6);
  static const _muted = Color(0xFF8A8A8E);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      width: 68,
      height: 68,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1D2635) : _surfaceSoft,
        borderRadius: BorderRadius.circular(10),
      ),
      child: imageUrl == null || imageUrl!.isEmpty
          ? Icon(
              Icons.image_not_supported_rounded,
              color: isDark ? const Color(0xFF97A2B5) : _muted,
            )
          : Image.network(
              imageUrl!,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Icon(
                Icons.image_not_supported_rounded,
                color: isDark ? const Color(0xFF97A2B5) : _muted,
              ),
            ),
    );
  }
}

class _MessageCard extends StatelessWidget {
  const _MessageCard({
    required this.title,
    required this.message,
    this.actionLabel,
    this.onTap,
  });

  final String title;
  final String message;
  final String? actionLabel;
  final Future<void> Function()? onTap;

  static const _surface = Colors.white;
  static const _ink = Color(0xFF1E1E1E);
  static const _muted = Color(0xFF8A8A8E);
  static const _line = Color(0xFFE5E5EA);
  static const _blue = Color(0xFF4B6BFF);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF161B22) : _surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? const Color(0xFF2B3442) : _line,
        ),
      ),
      child: Column(
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: isDark ? const Color(0xFFE6EDF7) : _ink,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            message,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: isDark ? const Color(0xFF97A2B5) : _muted,
            ),
          ),
          if (actionLabel != null && onTap != null) ...[
            const SizedBox(height: 14),
            ElevatedButton(
              onPressed: onTap,
              style: ElevatedButton.styleFrom(
                backgroundColor: _blue,
                foregroundColor: Colors.white,
                elevation: 0,
              ),
              child: Text(actionLabel!),
            ),
          ],
        ],
      ),
    );
  }
}

class _RepairAccessory {
  const _RepairAccessory({
    required this.id,
    required this.name,
    required this.basePrice,
    required this.finalPrice,
    required this.stock,
    this.brand,
    this.warranty,
    this.createdAt,
    this.imageUrl,
  });

  final int id;
  final String name;
  final double basePrice;
  final double finalPrice;
  final int stock;
  final String? brand;
  final String? warranty;
  final DateTime? createdAt;
  final String? imageUrl;

  bool get hasDiscount => basePrice > 0 && finalPrice < basePrice;

  String get brandLabel {
    final text = (brand ?? '').trim();
    return text.isEmpty ? 'Unknown' : text;
  }

  String get stockLabel {
    if (stock > 0) return 'In Stock: $stock';
    return 'Out of Stock';
  }

  factory _RepairAccessory.fromJson(Map<String, dynamic> json) {
    final image = ApiService.normalizeMediaUrl(
      json['image'] ?? json['thumbnail'] ?? json['photo'] ?? json['image_url'],
    );

    final basePrice = _toDouble(
      json['price'] ?? json['regular_price'] ?? json['original_price'],
    );
    final finalPrice = _toDouble(
      json['final_price'] ?? json['sale_price'] ?? json['selling_price'] ?? basePrice,
    );

    return _RepairAccessory(
      id: _toInt(json['id']),
      name: (json['name'] ?? '').toString(),
      basePrice: basePrice,
      finalPrice: finalPrice,
      stock: _toInt(json['stock']),
      brand: json['brand']?.toString(),
      warranty: json['warranty']?.toString(),
      createdAt: DateTime.tryParse((json['created_at'] ?? '').toString()),
      imageUrl: image,
    );
  }

  static int _toInt(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }

  static double _toDouble(dynamic value) {
    if (value is double) return value;
    if (value is num) return value.toDouble();
    return double.tryParse(value?.toString() ?? '') ?? 0;
  }
}

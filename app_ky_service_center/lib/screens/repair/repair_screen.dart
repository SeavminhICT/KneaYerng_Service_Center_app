import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hugeicons/hugeicons.dart';
import '../../theme/app_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:skeletonizer/skeletonizer.dart';

import '../../l10n/app_localizations.dart';
import '../../models/product.dart';
import '../../services/api_service.dart';
import '../../widgets/app_network_image.dart';
import '../products/product_detail_screen.dart';

// ── Design tokens ─────────────────────────────────────────────────────────────
const _primary = Color(0xFF3B6BFF);
const _primarySoft = Color(0xFFEEF2FF);
const _success = Color(0xFF16A34A);
const _successSoft = Color(0xFFDCFCE7);
const _danger = Color(0xFFDC2626);
const _dangerSoft = Color(0xFFFEE2E2);
const _warning = Color(0xFFD97706);
const _warningSoft = Color(0xFFFEF3C7);

Color _bg(BuildContext ctx) => Theme.of(ctx).brightness == Brightness.dark
    ? const Color(0xFF0D1117)
    : const Color(0xFFF4F6FB);

Color _surface(BuildContext ctx) => Theme.of(ctx).brightness == Brightness.dark
    ? const Color(0xFF161B22)
    : Colors.white;

Color _ink(BuildContext ctx) => Theme.of(ctx).brightness == Brightness.dark
    ? const Color(0xFFE6EDF7)
    : const Color(0xFF111827);

Color _muted(BuildContext ctx) => Theme.of(ctx).brightness == Brightness.dark
    ? const Color(0xFF7D8FA9)
    : const Color(0xFF64748B);

Color _border(BuildContext ctx) => Theme.of(ctx).brightness == Brightness.dark
    ? const Color(0xFF2B3442)
    : const Color(0xFFE5EAF2);

Color _imageBg(BuildContext ctx) => Theme.of(ctx).brightness == Brightness.dark
    ? const Color(0xFF1D2635)
    : const Color(0xFFF0F4FC);

bool _isDark(BuildContext ctx) => Theme.of(ctx).brightness == Brightness.dark;

// ── Screen ────────────────────────────────────────────────────────────────────

class RepairScreen extends StatefulWidget {
  const RepairScreen({super.key});

  @override
  State<RepairScreen> createState() => _RepairScreenState();
}

class _RepairScreenState extends State<RepairScreen> {
  final _searchCtrl = TextEditingController();
  bool _loading = true;
  String? _error;
  List<_RepairAccessory> _items = const [];

  @override
  void initState() {
    super.initState();
    _searchCtrl.addListener(() {
      if (mounted) setState(() {});
    });
    _load();
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final res = await http.get(
        Uri.parse('${ApiService.baseUrl}/accessories'),
        headers: const {'Accept': 'application/json'},
      );
      if (res.statusCode != 200) throw Exception('${res.statusCode}');
      final decoded = jsonDecode(res.body);
      final raw = decoded is Map ? decoded['data'] : null;
      final list = raw is List
          ? raw
                .whereType<Map>()
                .map(
                  (e) =>
                      _RepairAccessory.fromJson(Map<String, dynamic>.from(e)),
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
        _error = 'Could not load. Pull down to retry.';
      });
    }
  }

  List<_RepairAccessory> get _filtered {
    final q = _searchCtrl.text.trim().toLowerCase();
    final list = _items.where((i) {
      if (q.isEmpty) return true;
      return i.name.toLowerCase().contains(q) ||
          i.brandLabel.toLowerCase().contains(q) ||
          '#${i.id}'.contains(q);
    }).toList();
    list.sort((a, b) {
      final ad = a.createdAt ?? DateTime(2000);
      final bd = b.createdAt ?? DateTime(2000);
      return bd.compareTo(ad);
    });
    return list;
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final items = _filtered;

    return Scaffold(
      backgroundColor: _bg(context),
      body: SafeArea(
        child: RefreshIndicator(
          color: _primary,
          onRefresh: _load,
          child: CustomScrollView(
            physics: const BouncingScrollPhysics(
              parent: AlwaysScrollableScrollPhysics(),
            ),
            slivers: [
              // ── Header ────────────────────────────────────────────────
              SliverToBoxAdapter(child: _Header(l: l)),

              // ── Search bar ────────────────────────────────────────────
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
                  child: _SearchBar(controller: _searchCtrl),
                ),
              ),

              // ── Section title ─────────────────────────────────────────
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 20, 16, 12),
                  child: Row(
                    children: [
                      Text(
                        'Parts & Accessories',
                        style: kmFont(context, GoogleFonts.manrope(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: _ink(context),
                        )),
                      ),
                      const Spacer(),
                      if (!_loading && _error == null)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: _primarySoft,
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Text(
                            '${items.length} items',
                            style: kmFont(context, GoogleFonts.manrope(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: _primary,
                            )),
                          ),
                        ),
                    ],
                  ),
                ),
              ),

              // ── Body content ──────────────────────────────────────────
              if (_loading)
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (_, i) => Padding(
                        padding: const EdgeInsets.only(bottom: 14),
                        child: Skeletonizer(
                          enabled: true,
                          child: _AccessoryCard(
                            item: const _RepairAccessory(
                              id: 0,
                              name: 'Loading Accessory Item Name',
                              basePrice: 99,
                              finalPrice: 89,
                              stock: 5,
                              brand: 'Apple',
                              warranty: '1 Year',
                            ),
                          ),
                        ),
                      ),
                      childCount: 4,
                    ),
                  ),
                )
              else if (_error != null)
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  sliver: SliverToBoxAdapter(
                    child: _StateCard(
                      icon: HugeIcons.strokeRoundedWifiOff01,
                      iconColor: _danger,
                      iconBg: _dangerSoft,
                      title: l.somethingWentWrong,
                      subtitle: _error!,
                      buttonLabel: l.retry,
                      onButton: _load,
                    ),
                  ),
                )
              else if (items.isEmpty)
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  sliver: SliverToBoxAdapter(
                    child: _StateCard(
                      icon: HugeIcons.strokeRoundedPackage,
                      iconColor: _muted(context),
                      iconBg: _imageBg(context),
                      title: l.noData,
                      subtitle: _searchCtrl.text.trim().isEmpty
                          ? 'No accessories available yet.'
                          : 'No results for "${_searchCtrl.text.trim()}".',
                    ),
                  ),
                )
              else
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (_, i) => Padding(
                        padding: const EdgeInsets.only(bottom: 14),
                        child: _AccessoryCard(item: items[i]),
                      ),
                      childCount: items.length,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Header ────────────────────────────────────────────────────────────────────

class _Header extends StatelessWidget {
  const _Header({required this.l});
  final AppLocalizations l;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 20),
      child: Row(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l.repairService,
                style: kmFont(context, GoogleFonts.manrope(
                  fontSize: 26,
                  fontWeight: FontWeight.w800,
                  color: _ink(context),
                  letterSpacing: -0.5,
                )),
              ),
              const SizedBox(height: 2),
              Text(
                'Genuine parts & professional repair',
                style: kmFont(context, GoogleFonts.manrope(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: _muted(context),
                )),
              ),
            ],
          ),
          const Spacer(),
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: _primarySoft,
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(
              HugeIcons.strokeRoundedWrench01,
              color: _primary,
              size: 22,
            ),
          ),
        ],
      ),
    );
  }
}


// ── Search Bar ────────────────────────────────────────────────────────────────

class _SearchBar extends StatelessWidget {
  const _SearchBar({required this.controller});
  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: _surface(context),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _border(context)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(
              alpha: _isDark(context) ? 0.2 : 0.05,
            ),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        textInputAction: TextInputAction.search,
        onTapOutside: (_) => FocusScope.of(context).unfocus(),
        style: kmFont(context, GoogleFonts.manrope(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: _ink(context),
        )),
        decoration: InputDecoration(
          hintText: 'Search by name, brand…',
          hintStyle: kmFont(context, GoogleFonts.manrope(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: _muted(context),
          )),
          prefixIcon: Icon(
            HugeIcons.strokeRoundedSearch01,
            color: _muted(context),
            size: 22,
          ),
          suffixIcon: controller.text.isNotEmpty
              ? IconButton(
                  icon: Icon(
                    HugeIcons.strokeRoundedCancel01,
                    color: _muted(context),
                    size: 20,
                  ),
                  onPressed: controller.clear,
                )
              : null,
          counterText: '',
          filled: true,
          fillColor: _surface(context),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 14,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: _primary, width: 1.5),
          ),
        ),
      ),
    );
  }
}

// ── Accessory Card ────────────────────────────────────────────────────────────

class _AccessoryCard extends StatelessWidget {
  const _AccessoryCard({required this.item});
  final _RepairAccessory item;

  @override
  Widget build(BuildContext context) {
    final isDark = _isDark(context);
    final inStock = item.stock > 0;
    final hasDiscount = item.hasDiscount;
    final warranty = (item.warranty ?? '').trim();
    final hasWarranty =
        warranty.isNotEmpty && warranty.toLowerCase() != 'no warranty';

    return Material(
      color: _surface(context),
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => ProductDetailScreen(
                product: Product.fromJson(item.raw),
                showCartActions: false,
              ),
            ),
          );
        },
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: _border(context)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.06),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Image ──────────────────────────────────────────────────
                _ItemImage(imageUrl: item.imageUrl),
                const SizedBox(width: 14),
                // ── Content ────────────────────────────────────────────────
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Brand pill
                      if (item.brandLabel != 'Unknown')
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: _primarySoft,
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Text(
                            item.brandLabel.toUpperCase(),
                            style: kmFont(context, GoogleFonts.manrope(
                              fontSize: 9,
                              fontWeight: FontWeight.w800,
                              color: _primary,
                              letterSpacing: 0.5,
                            )),
                          ),
                        ),
                      const SizedBox(height: 5),
                      // Name
                      Text(
                        item.name,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: kmFont(context, GoogleFonts.manrope(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: _ink(context),
                          height: 1.3,
                        )),
                      ),
                      const SizedBox(height: 8),
                      // Price row
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            '\$${item.finalPrice.toStringAsFixed(2)}',
                            style: kmFont(context, GoogleFonts.manrope(
                              fontSize: 20,
                              fontWeight: FontWeight.w800,
                              color: hasDiscount ? _danger : _primary,
                              height: 1,
                            )),
                          ),
                          if (hasDiscount) ...[
                            const SizedBox(width: 6),
                            Text(
                              '\$${item.basePrice.toStringAsFixed(2)}',
                              style: kmFont(context, GoogleFonts.manrope(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color: _muted(context),
                                decoration: TextDecoration.lineThrough,
                                decorationColor: _muted(context),
                              )),
                            ),
                            const SizedBox(width: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: _dangerSoft,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                '-${(((item.basePrice - item.finalPrice) / item.basePrice) * 100).toStringAsFixed(0)}%',
                                style: kmFont(context, GoogleFonts.manrope(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w800,
                                  color: _danger,
                                )),
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 10),
                      // Bottom row: stock + warranty
                      Row(
                        children: [
                          _StatusChip(
                            label: inStock ? 'In Stock' : 'Out of Stock',
                            color: inStock ? _success : _danger,
                            bg: inStock ? _successSoft : _dangerSoft,
                            icon: inStock
                                ? HugeIcons.strokeRoundedCheckmarkCircle02
                                : HugeIcons.strokeRoundedCancelCircle,
                          ),
                          if (hasWarranty) ...[
                            const SizedBox(width: 6),
                            _StatusChip(
                              label: warranty,
                              color: _warning,
                              bg: _warningSoft,
                              icon: HugeIcons.strokeRoundedShield01,
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ── Status Chip ───────────────────────────────────────────────────────────────

class _StatusChip extends StatelessWidget {
  const _StatusChip({
    required this.label,
    required this.color,
    required this.bg,
    required this.icon,
  });

  final String label;
  final Color color;
  final Color bg;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 11, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: kmFont(context, GoogleFonts.manrope(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: color,
            )),
          ),
        ],
      ),
    );
  }
}

// ── Item Image ────────────────────────────────────────────────────────────────

class _ItemImage extends StatelessWidget {
  const _ItemImage({required this.imageUrl});
  final String? imageUrl;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 82,
      height: 82,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: _imageBg(context),
        borderRadius: BorderRadius.circular(14),
      ),
      child: imageUrl != null && imageUrl!.isNotEmpty
          ? AppNetworkImage(
              imageUrl!,
              fit: BoxFit.cover,
              errorWidget: (ctx, url, err) => const _ImageFallback(),
            )
          : const _ImageFallback(),
    );
  }
}

class _ImageFallback extends StatelessWidget {
  const _ImageFallback();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Icon(
        HugeIcons.strokeRoundedWrench01,
        size: 32,
        color: _muted(context),
      ),
    );
  }
}

// ── State Card (Empty / Error) ────────────────────────────────────────────────

class _StateCard extends StatelessWidget {
  const _StateCard({
    required this.icon,
    required this.iconColor,
    required this.iconBg,
    required this.title,
    required this.subtitle,
    this.buttonLabel,
    this.onButton,
  });

  final IconData icon;
  final Color iconColor;
  final Color iconBg;
  final String title;
  final String subtitle;
  final String? buttonLabel;
  final Future<void> Function()? onButton;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 24),
      decoration: BoxDecoration(
        color: _surface(context),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _border(context)),
      ),
      child: Column(
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(color: iconBg, shape: BoxShape.circle),
            child: Icon(icon, color: iconColor, size: 32),
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: kmFont(context, GoogleFonts.manrope(
              fontSize: 17,
              fontWeight: FontWeight.w800,
              color: _ink(context),
            )),
          ),
          const SizedBox(height: 6),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: kmFont(context, GoogleFonts.manrope(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: _muted(context),
              height: 1.5,
            )),
          ),
          if (buttonLabel != null && onButton != null) ...[
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: onButton,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _primary,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  buttonLabel!,
                  style: kmFont(context, GoogleFonts.manrope(fontWeight: FontWeight.w700)),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// ── Model ─────────────────────────────────────────────────────────────────────

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
    this.raw = const {},
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
  final Map<String, dynamic> raw;

  bool get hasDiscount => basePrice > 0 && finalPrice < basePrice;

  String get brandLabel {
    final t = (brand ?? '').trim();
    return t.isEmpty ? 'Unknown' : t;
  }

  factory _RepairAccessory.fromJson(Map<String, dynamic> json) {
    final image = ApiService.normalizeMediaUrl(
      json['image'] ?? json['thumbnail'] ?? json['photo'] ?? json['image_url'],
    );
    final base = _d(
      json['price'] ?? json['regular_price'] ?? json['original_price'],
    );
    final final_ = _d(
      json['final_price'] ??
          json['sale_price'] ??
          json['selling_price'] ??
          base,
    );

    return _RepairAccessory(
      id: _i(json['id']),
      name: (json['name'] ?? '').toString(),
      basePrice: base,
      finalPrice: final_,
      stock: _i(json['stock']),
      brand: json['brand']?.toString(),
      warranty: json['warranty']?.toString(),
      createdAt: DateTime.tryParse((json['created_at'] ?? '').toString()),
      imageUrl: image,
      raw: json,
    );
  }

  static int _i(dynamic v) {
    if (v is int) return v;
    if (v is num) return v.toInt();
    return int.tryParse(v?.toString() ?? '') ?? 0;
  }

  static double _d(dynamic v) {
    if (v is double) return v;
    if (v is num) return v.toDouble();
    return double.tryParse(v?.toString() ?? '') ?? 0;
  }
}

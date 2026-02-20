import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../../services/api_service.dart';

class RepairScreen extends StatefulWidget {
  const RepairScreen({super.key});

  @override
  State<RepairScreen> createState() => _RepairScreenState();
}

class _RepairScreenState extends State<RepairScreen> {
  static const _bg = Color(0xFFF4F6FB);
  static const _surface = Colors.white;
  static const _text = Color(0xFF1D2433);
  static const _muted = Color(0xFF6E7788);
  static const _border = Color(0xFFE5E8EF);
  static const _primary = Color(0xFF5B61F6);
  static const _chipBg = Color(0xFFEFF1F7);

  final TextEditingController _searchController = TextEditingController();
  final List<String> _dateRanges = const ['Last 7 days', 'Last 30 days', 'Last 90 days', 'All time'];
  final List<String> _statusOptions = const ['All Status', 'In Stock', 'Low Stock', 'Out of Stock'];
  final List<String> _quickBrands = const ['All', 'IPHONE', 'SAMSUNG'];

  String _selectedDateRange = 'Last 30 days';
  String _selectedStatus = 'All Status';
  String _selectedQuickBrand = 'All';

  bool _loading = true;
  String? _error;
  List<_RepairAccessory> _items = const [];

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() => setState(() {}));
    _loadAccessories();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
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
              .map((e) => _RepairAccessory.fromJson(Map<String, dynamic>.from(e)))
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
        _error = 'Could not load repair data. Pull down to refresh.';
      });
    }
  }

  List<_RepairAccessory> get _filteredItems {
    final query = _searchController.text.trim().toLowerCase();
    final cutoff = _cutoffDate(_selectedDateRange);

    return _items.where((item) {
      final status = item.statusLabel;
      final matchesQuery = query.isEmpty ||
          item.name.toLowerCase().contains(query) ||
          (item.brand ?? '').toLowerCase().contains(query) ||
          '#${item.id}'.contains(query);

      final matchesDropdownStatus = _selectedStatus == 'All Status' || status == _selectedStatus;
      final brandUpper = (item.brand ?? '').toUpperCase();
      final matchesQuickBrand = _selectedQuickBrand == 'All' || brandUpper == _selectedQuickBrand;
      final matchesDate = cutoff == null || (item.createdAt != null && item.createdAt!.isAfter(cutoff));

      return matchesQuery && matchesDropdownStatus && matchesQuickBrand && matchesDate;
    }).toList()
      ..sort((a, b) {
        final ad = a.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
        final bd = b.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
        return bd.compareTo(ad);
      });
  }

  DateTime? _cutoffDate(String selected) {
    final now = DateTime.now();
    switch (selected) {
      case 'Last 7 days':
        return now.subtract(const Duration(days: 7));
      case 'Last 30 days':
        return now.subtract(const Duration(days: 30));
      case 'Last 90 days':
        return now.subtract(const Duration(days: 90));
      default:
        return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final items = _filteredItems;

    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        backgroundColor: _surface,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'Repair',
          style: TextStyle(
            color: _text,
            fontSize: 28,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.3,
          ),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: _loadAccessories,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 24),
          children: [
            _buildSearchField(),
            const SizedBox(height: 14),
            _buildTopFilters(),
            const SizedBox(height: 12),
            _buildStatusChips(),
            const SizedBox(height: 14),
            if (_loading)
              const Padding(
                padding: EdgeInsets.only(top: 80),
                child: Center(child: CircularProgressIndicator()),
              )
            else if (_error != null)
              _ErrorState(message: _error!, onRetry: _loadAccessories)
            else if (items.isEmpty)
              const _EmptyState()
            else
              ...items.map((item) => _RepairCard(item: item)),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchField() {
    return TextField(
      controller: _searchController,
      decoration: InputDecoration(
        hintText: 'Search by name, brand, or ID',
        hintStyle: const TextStyle(color: _muted),
        prefixIcon: const Icon(Icons.search_rounded),
        suffixIcon: _searchController.text.isEmpty
            ? null
            : IconButton(
                icon: const Icon(Icons.close_rounded),
                onPressed: () => _searchController.clear(),
              ),
        filled: true,
        fillColor: _surface,
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: _border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: _primary, width: 1.4),
        ),
      ),
    );
  }

  Widget _buildTopFilters() {
    return Row(
      children: [
        Expanded(
          child: _FilterDropDown(
            icon: Icons.calendar_month_rounded,
            value: _selectedDateRange,
            items: _dateRanges,
            onChanged: (value) => setState(() => _selectedDateRange = value),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _FilterDropDown(
            icon: Icons.filter_alt_rounded,
            value: _selectedStatus,
            items: _statusOptions,
            onChanged: (value) => setState(() => _selectedStatus = value),
          ),
        ),
      ],
    );
  }

  Widget _buildStatusChips() {
    return SizedBox(
      height: 38,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: _quickBrands.length,
        separatorBuilder: (context, index) => const SizedBox(width: 8),
        itemBuilder: (context, i) {
          final label = _quickBrands[i];
          final selected = label == _selectedQuickBrand;
          return InkWell(
            borderRadius: BorderRadius.circular(999),
            onTap: () {
              setState(() {
                _selectedQuickBrand = label;
              });
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: selected ? _primary : _chipBg,
                borderRadius: BorderRadius.circular(999),
              ),
              child: Center(
                child: Text(
                  label,
                  style: TextStyle(
                    color: selected ? Colors.white : _text,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _RepairCard extends StatelessWidget {
  const _RepairCard({required this.item});

  final _RepairAccessory item;

  static const _text = Color(0xFF1D2433);
  static const _muted = Color(0xFF6E7788);
  static const _border = Color(0xFFE5E8EF);
  static const _primary = Color(0xFF5B61F6);
  static const _chipBg = Color(0xFFF0F2F8);

  @override
  Widget build(BuildContext context) {
    final badge = _statusBadgeColor(item.statusLabel);
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: _border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: badge.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(999),
            ),
            child: Text(
              item.statusLabel,
              style: TextStyle(
                color: badge,
                fontWeight: FontWeight.w700,
                fontSize: 12,
              ),
            ),
          ),
          const SizedBox(height: 10),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _ItemImage(imageUrl: item.imageUrl),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: _text,
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.4,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      'Brand: ${item.brand ?? '-'}  •  Stock: ${item.stock}',
                      style: const TextStyle(color: _muted, fontWeight: FontWeight.w600),
                    ),
                    if ((item.warranty ?? '').isNotEmpty)
                      Text(
                        'Warranty: ${item.warranty}',
                        style: const TextStyle(color: _muted, fontWeight: FontWeight.w600),
                      ),
                    const SizedBox(height: 4),
                    Text(
                      '\$${item.finalPrice.toStringAsFixed(2)}',
                      style: const TextStyle(
                        color: _text,
                        fontWeight: FontWeight.w900,
                        fontSize: 20,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(height: 1, color: _border),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _ActionButton(
                  icon: Icons.settings_backup_restore_rounded,
                  label: 'Repair',
                  background: _primary,
                  foreground: Colors.white,
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Repair action for ${item.name}')),
                    );
                  },
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _ActionButton(
                  icon: Icons.visibility_rounded,
                  label: 'View',
                  background: _chipBg,
                  foreground: _text,
                  onTap: () {
                    showModalBottomSheet<void>(
                      context: context,
                      backgroundColor: Colors.white,
                      builder: (_) => _RepairDetailSheet(item: item),
                    );
                  },
                ),
              ),
              const SizedBox(width: 10),
            ],
          ),
        ],
      ),
    );
  }

  Color _statusBadgeColor(String status) {
    switch (status) {
      case 'In Stock':
        return const Color(0xFF16A34A);
      case 'Low Stock':
        return const Color(0xFFCA8A04);
      case 'Out of Stock':
        return const Color(0xFFDC2626);
      default:
        return const Color(0xFF64748B);
    }
  }
}

class _RepairDetailSheet extends StatelessWidget {
  const _RepairDetailSheet({required this.item});

  final _RepairAccessory item;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 46,
              height: 4,
              decoration: BoxDecoration(
                color: const Color(0xFFD7DCE7),
                borderRadius: BorderRadius.circular(100),
              ),
            ),
          ),
          const SizedBox(height: 14),
          Text(
            item.name,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 12),
          _InfoRow(label: 'Brand', value: item.brand ?? '-'),
          _InfoRow(label: 'Status', value: item.statusLabel),
          _InfoRow(label: 'Price', value: '\$${item.finalPrice.toStringAsFixed(2)}'),
          _InfoRow(label: 'Stock', value: '${item.stock}'),
          _InfoRow(label: 'Warranty', value: item.warranty ?? '-'),
          const SizedBox(height: 10),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 7),
      child: Row(
        children: [
          SizedBox(
            width: 90,
            child: Text(
              label,
              style: const TextStyle(
                color: Color(0xFF6E7788),
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                color: Color(0xFF1D2433),
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.icon,
    required this.label,
    required this.background,
    required this.foreground,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final Color background;
  final Color foreground;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: onTap,
      child: Container(
        height: 46,
        decoration: BoxDecoration(
          color: background,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: foreground, size: 20),
            if (label.isNotEmpty) const SizedBox(width: 8),
            if (label.isNotEmpty)
              Text(
                label,
                style: TextStyle(
                  color: foreground,
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _ItemImage extends StatelessWidget {
  const _ItemImage({required this.imageUrl});

  final String? imageUrl;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 78,
      height: 78,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: const Color(0xFFF1F4FA),
        borderRadius: BorderRadius.circular(14),
      ),
      child: imageUrl == null || imageUrl!.isEmpty
          ? const Icon(Icons.devices_other_rounded, size: 34, color: Color(0xFF9AA2B1))
          : Image.network(
              imageUrl!,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) =>
                  const Icon(Icons.devices_other_rounded, size: 34, color: Color(0xFF9AA2B1)),
            ),
    );
  }
}

class _FilterDropDown extends StatelessWidget {
  const _FilterDropDown({
    required this.icon,
    required this.value,
    required this.items,
    required this.onChanged,
  });

  final IconData icon;
  final String value;
  final List<String> items;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE5E8EF)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          isExpanded: true,
          borderRadius: BorderRadius.circular(14),
          icon: const Icon(Icons.keyboard_arrow_down_rounded),
          items: items
              .map(
                (e) => DropdownMenuItem<String>(
                  value: e,
                  child: Row(
                    children: [
                      Icon(icon, size: 18, color: const Color(0xFF6E7788)),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          e,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Color(0xFF364152),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              )
              .toList(),
          onChanged: (value) {
            if (value != null) onChanged(value);
          },
        ),
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.message, required this.onRetry});

  final String message;
  final Future<void> Function() onRetry;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 40),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5E8EF)),
      ),
      child: Column(
        children: [
          const Icon(Icons.cloud_off_rounded, size: 44, color: Color(0xFF6E7788)),
          const SizedBox(height: 8),
          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Color(0xFF6E7788),
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          ElevatedButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh_rounded),
            label: const Text('Retry'),
          ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 40),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5E8EF)),
      ),
      child: const Column(
        children: [
          Icon(Icons.inventory_2_outlined, size: 44, color: Color(0xFF6E7788)),
          SizedBox(height: 8),
          Text(
            'No accessories found for the selected filters.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Color(0xFF6E7788), fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}

class _RepairAccessory {
  const _RepairAccessory({
    required this.id,
    required this.name,
    required this.finalPrice,
    required this.stock,
    this.brand,
    this.warranty,
    this.createdAt,
    this.imageUrl,
  });

  final int id;
  final String name;
  final double finalPrice;
  final int stock;
  final String? brand;
  final String? warranty;
  final DateTime? createdAt;
  final String? imageUrl;

  String get statusLabel {
    if (stock <= 0) return 'Out of Stock';
    if (stock < 10) return 'Low Stock';
    return 'In Stock';
  }

  String get createdAtLabel {
    if (createdAt == null) return 'Unknown date';
    final d = createdAt!;
    final month = _monthName(d.month);
    final hour = d.hour > 12 ? d.hour - 12 : (d.hour == 0 ? 12 : d.hour);
    final minute = d.minute.toString().padLeft(2, '0');
    final amPm = d.hour >= 12 ? 'PM' : 'AM';
    return '$month ${d.day}, ${d.year} • $hour:$minute $amPm';
  }

  factory _RepairAccessory.fromJson(Map<String, dynamic> json) {
    final image = ApiService.normalizeMediaUrl(
      json['image'] ?? json['thumbnail'] ?? json['photo'] ?? json['image_url'],
    );
    return _RepairAccessory(
      id: _toInt(json['id']),
      name: (json['name'] ?? '').toString(),
      finalPrice: _toDouble(json['final_price'] ?? json['price']),
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

  static String _monthName(int month) {
    const names = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return names[(month.clamp(1, 12)) - 1];
  }
}

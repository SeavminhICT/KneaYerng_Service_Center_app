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
  static const _bg = Color(0xFFF5F3EF);
  static const _primary = Color(0xFF2C333A);

  final TextEditingController _searchController = TextEditingController();

  final List<String> _dateRanges = const [
    'Last 7 days',
    'Last 30 days',
    'Last 90 days',
    'All time',
  ];
  final List<String> _statusOptions = const [
    'All Status',
    'In Stock',
    'Low Stock',
    'Out of Stock',
  ];

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

  List<String> get _quickBrands {
    final brands =
        _items
            .map((item) => (item.brand ?? '').trim().toUpperCase())
            .where((brand) => brand.isNotEmpty)
            .toSet()
            .toList()
          ..sort();
    return ['All', ...brands.take(5)];
  }

  int get _availableCount => _items.where((item) => item.stock > 0).length;

  int get _lowStockCount =>
      _items.where((item) => item.stock > 0 && item.stock < 10).length;

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
        if (!_quickBrands.contains(_selectedQuickBrand)) {
          _selectedQuickBrand = 'All';
        }
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
      final matchesQuery =
          query.isEmpty ||
          item.name.toLowerCase().contains(query) ||
          (item.brand ?? '').toLowerCase().contains(query) ||
          '#${item.id}'.contains(query);
      final matchesStatus =
          _selectedStatus == 'All Status' ||
          item.statusLabel == _selectedStatus;
      final matchesBrand =
          _selectedQuickBrand == 'All' ||
          (item.brand ?? '').trim().toUpperCase() == _selectedQuickBrand;
      final matchesDate =
          cutoff == null ||
          (item.createdAt != null && item.createdAt!.isAfter(cutoff));

      return matchesQuery && matchesStatus && matchesBrand && matchesDate;
    }).toList()..sort((a, b) {
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

    return Theme(
      data: Theme.of(context).copyWith(
        textTheme: GoogleFonts.interTextTheme(Theme.of(context).textTheme),
      ),
      child: Scaffold(
        backgroundColor: _bg,
        appBar: AppBar(
          backgroundColor: _bg,
          surfaceTintColor: Colors.transparent,
          elevation: 0,
          centerTitle: false,
          titleSpacing: 20,
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Repair Center',
                style: GoogleFonts.inter(
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF1F1F1C),
                ),
              ),
              const Text(
                'Find parts, check stock, and open repair actions',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF6D685F),
                ),
              ),
            ],
          ),
        ),
        body: RefreshIndicator(
          color: _primary,
          onRefresh: _loadAccessories,
          child: ListView(
            physics: const BouncingScrollPhysics(
              parent: AlwaysScrollableScrollPhysics(),
            ),
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
            children: [
              _SummaryCard(
                totalItems: _items.length,
                availableItems: _availableCount,
                lowStockItems: _lowStockCount,
              ),
              const SizedBox(height: 12),
              _FilterPanel(
                searchController: _searchController,
                dateRanges: _dateRanges,
                statusOptions: _statusOptions,
                selectedDateRange: _selectedDateRange,
                selectedStatus: _selectedStatus,
                quickBrands: _quickBrands,
                selectedQuickBrand: _selectedQuickBrand,
                onDateChanged: (value) =>
                    setState(() => _selectedDateRange = value),
                onStatusChanged: (value) =>
                    setState(() => _selectedStatus = value),
                onBrandChanged: (value) =>
                    setState(() => _selectedQuickBrand = value),
              ),
              const SizedBox(height: 16),
              _ResultHeader(
                count: items.length,
                selectedStatus: _selectedStatus,
              ),
              const SizedBox(height: 12),
              if (_loading)
                const Padding(
                  padding: EdgeInsets.only(top: 64),
                  child: Center(child: CircularProgressIndicator()),
                )
              else if (_error != null)
                _MessageCard(
                  icon: Icons.cloud_off_rounded,
                  title: 'Connection issue',
                  message: _error!,
                  actionLabel: 'Try Again',
                  onTap: _loadAccessories,
                )
              else if (items.isEmpty)
                const _MessageCard(
                  icon: Icons.inventory_2_outlined,
                  title: 'No matching accessories',
                  message:
                      'Try a different brand, change the status filter, or clear the search.',
                )
              else
                ...items.map(
                  (item) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _RepairCard(item: item),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({
    required this.totalItems,
    required this.availableItems,
    required this.lowStockItems,
  });

  final int totalItems;
  final int availableItems;
  final int lowStockItems;

  static const _surface = Colors.white;
  static const _surfaceSoft = Color(0xFFF1EEE8);
  static const _ink = Color(0xFF1F1F1C);
  static const _muted = Color(0xFF6D685F);
  static const _border = Color(0xFFE2DDD3);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Today overview',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: _ink,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Simple stock summary for repair parts.',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: _muted,
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: _SummaryItem(
                  label: 'All items',
                  value: '$totalItems',
                  background: _surfaceSoft,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _SummaryItem(
                  label: 'Available',
                  value: '$availableItems',
                  background: _surfaceSoft,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _SummaryItem(
                  label: 'Low stock',
                  value: '$lowStockItems',
                  background: _surfaceSoft,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SummaryItem extends StatelessWidget {
  const _SummaryItem({
    required this.label,
    required this.value,
    required this.background,
  });

  final String label;
  final String value;
  final Color background;

  static const _ink = Color(0xFF1F1F1C);
  static const _muted = Color(0xFF6D685F);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: _ink,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: _muted,
            ),
          ),
        ],
      ),
    );
  }
}

class _FilterPanel extends StatelessWidget {
  const _FilterPanel({
    required this.searchController,
    required this.dateRanges,
    required this.statusOptions,
    required this.selectedDateRange,
    required this.selectedStatus,
    required this.quickBrands,
    required this.selectedQuickBrand,
    required this.onDateChanged,
    required this.onStatusChanged,
    required this.onBrandChanged,
  });

  final TextEditingController searchController;
  final List<String> dateRanges;
  final List<String> statusOptions;
  final String selectedDateRange;
  final String selectedStatus;
  final List<String> quickBrands;
  final String selectedQuickBrand;
  final ValueChanged<String> onDateChanged;
  final ValueChanged<String> onStatusChanged;
  final ValueChanged<String> onBrandChanged;

  static const _surface = Colors.white;
  static const _surfaceSoft = Color(0xFFF1EEE8);
  static const _ink = Color(0xFF1F1F1C);
  static const _muted = Color(0xFF6D685F);
  static const _border = Color(0xFFE2DDD3);
  static const _primary = Color(0xFF2C333A);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            controller: searchController,
            decoration: InputDecoration(
              hintText: 'Search by name, brand, or ID',
              hintStyle: const TextStyle(color: _muted),
              prefixIcon: const Icon(Icons.search_rounded, color: _muted),
              suffixIcon: searchController.text.isEmpty
                  ? null
                  : IconButton(
                      onPressed: searchController.clear,
                      icon: const Icon(Icons.close_rounded),
                      color: _muted,
                    ),
              filled: true,
              fillColor: _surfaceSoft,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(color: _border),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(color: _border),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(color: _primary),
              ),
            ),
          ),
          const SizedBox(height: 12),
          LayoutBuilder(
            builder: (context, constraints) {
              if (constraints.maxWidth < 430) {
                return Column(
                  children: [
                    _FilterDropDown(
                      label: 'Date',
                      value: selectedDateRange,
                      items: dateRanges,
                      onChanged: onDateChanged,
                    ),
                    const SizedBox(height: 10),
                    _FilterDropDown(
                      label: 'Status',
                      value: selectedStatus,
                      items: statusOptions,
                      onChanged: onStatusChanged,
                    ),
                  ],
                );
              }

              return Row(
                children: [
                  Expanded(
                    child: _FilterDropDown(
                      label: 'Date',
                      value: selectedDateRange,
                      items: dateRanges,
                      onChanged: onDateChanged,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _FilterDropDown(
                      label: 'Status',
                      value: selectedStatus,
                      items: statusOptions,
                      onChanged: onStatusChanged,
                    ),
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: 12),
          const Text(
            'Brand',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: _ink,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: quickBrands.map((brand) {
              final selected = brand == selectedQuickBrand;
              return InkWell(
                borderRadius: BorderRadius.circular(999),
                onTap: () => onBrandChanged(brand),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 9,
                  ),
                  decoration: BoxDecoration(
                    color: selected ? _primary : _surfaceSoft,
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(color: selected ? _primary : _border),
                  ),
                  child: Text(
                    brand,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: selected ? Colors.white : _ink,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

class _ResultHeader extends StatelessWidget {
  const _ResultHeader({required this.count, required this.selectedStatus});

  final int count;
  final String selectedStatus;

  static const _ink = Color(0xFF1F1F1C);
  static const _muted = Color(0xFF6D685F);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Results ($count)',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: _ink,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                selectedStatus,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: _muted,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _RepairCard extends StatelessWidget {
  const _RepairCard({required this.item});

  final _RepairAccessory item;

  static const _surface = Colors.white;
  static const _surfaceSoft = Color(0xFFF1EEE8);
  static const _ink = Color(0xFF1F1F1C);
  static const _muted = Color(0xFF6D685F);
  static const _border = Color(0xFFE2DDD3);
  static const _primary = Color(0xFF2C333A);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: _surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: _border),
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
                      item.name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                        color: _ink,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Part ID: #${item.id}',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: _muted,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _MiniChip(label: item.brand ?? 'No brand'),
                        _MiniChip(label: 'Stock ${item.stock}'),
                        _StatusChip(label: item.statusLabel),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: _surfaceSoft,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '\$${item.finalPrice.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          color: _ink,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        item.createdAtLabel,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: _muted,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _ActionButton(
                    label: 'View',
                    foreground: _ink,
                    background: _surface,
                    borderColor: _border,
                    onTap: () {
                      showModalBottomSheet<void>(
                        context: context,
                        isScrollControlled: true,
                        backgroundColor: Colors.transparent,
                        builder: (_) => _RepairDetailSheet(item: item),
                      );
                    },
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _ActionButton(
                    label: 'Repair',
                    foreground: Colors.white,
                    background: _primary,
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Repair action for ${item.name}'),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MiniChip extends StatelessWidget {
  const _MiniChip({required this.label});

  final String label;

  static const _surfaceSoft = Color(0xFFF1EEE8);
  static const _ink = Color(0xFF1F1F1C);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: _surfaceSoft,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: _ink,
        ),
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.label});

  final String label;

  Color get _color {
    switch (label) {
      case 'In Stock':
        return const Color(0xFF2E6A4F);
      case 'Low Stock':
        return const Color(0xFF8E6E2F);
      case 'Out of Stock':
        return const Color(0xFF8D4036);
      default:
        return const Color(0xFF6D685F);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: _color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: _color,
        ),
      ),
    );
  }
}

class _RepairDetailSheet extends StatelessWidget {
  const _RepairDetailSheet({required this.item});

  final _RepairAccessory item;

  static const _surface = Colors.white;
  static const _surfaceSoft = Color(0xFFF1EEE8);
  static const _ink = Color(0xFF1F1F1C);
  static const _border = Color(0xFFE2DDD3);

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewPadding.bottom;

    return Padding(
      padding: EdgeInsets.fromLTRB(12, 24, 12, bottomInset + 12),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: _surface,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: _border),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 48,
                height: 5,
                decoration: BoxDecoration(
                  color: _border,
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              item.name,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: _ink,
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 150,
              width: double.infinity,
              child: _ItemImage(imageUrl: item.imageUrl, expand: true),
            ),
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: _surfaceSoft,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  _InfoRow(label: 'Part ID', value: '#${item.id}'),
                  _InfoRow(label: 'Brand', value: item.brand ?? '-'),
                  _InfoRow(label: 'Status', value: item.statusLabel),
                  _InfoRow(
                    label: 'Price',
                    value: '\$${item.finalPrice.toStringAsFixed(2)}',
                  ),
                  _InfoRow(label: 'Stock', value: '${item.stock}'),
                  _InfoRow(label: 'Warranty', value: item.warranty ?? '-'),
                  _InfoRow(label: 'Created', value: item.createdAtLabel),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value});

  final String label;
  final String value;

  static const _ink = Color(0xFF1F1F1C);
  static const _muted = Color(0xFF6D685F);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: _muted,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: _ink,
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
    required this.label,
    required this.foreground,
    required this.background,
    required this.onTap,
    this.borderColor,
  });

  final String label;
  final Color foreground;
  final Color background;
  final Color? borderColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: onTap,
      child: Container(
        height: 44,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: background,
          borderRadius: BorderRadius.circular(12),
          border: borderColor == null ? null : Border.all(color: borderColor!),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: foreground,
          ),
        ),
      ),
    );
  }
}

class _ItemImage extends StatelessWidget {
  const _ItemImage({required this.imageUrl, this.expand = false});

  final String? imageUrl;
  final bool expand;

  static const _surfaceSoft = Color(0xFFF1EEE8);
  static const _muted = Color(0xFF6D685F);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: expand ? double.infinity : 84,
      height: expand ? double.infinity : 84,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: _surfaceSoft,
        borderRadius: BorderRadius.circular(16),
      ),
      child: imageUrl == null || imageUrl!.isEmpty
          ? const Icon(Icons.devices_other_rounded, size: 34, color: _muted)
          : Image.network(
              imageUrl!,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => const Icon(
                Icons.devices_other_rounded,
                size: 34,
                color: _muted,
              ),
            ),
    );
  }
}

class _FilterDropDown extends StatelessWidget {
  const _FilterDropDown({
    required this.label,
    required this.value,
    required this.items,
    required this.onChanged,
  });

  final String label;
  final String value;
  final List<String> items;
  final ValueChanged<String> onChanged;

  static const _surfaceSoft = Color(0xFFF1EEE8);
  static const _ink = Color(0xFF1F1F1C);
  static const _muted = Color(0xFF6D685F);
  static const _border = Color(0xFFE2DDD3);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: _ink,
          ),
        ),
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: _surfaceSoft,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: _border),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: value,
              isExpanded: true,
              icon: const Icon(
                Icons.keyboard_arrow_down_rounded,
                color: _muted,
              ),
              items: items
                  .map(
                    (entry) => DropdownMenuItem<String>(
                      value: entry,
                      child: Text(
                        entry,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: _ink,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  )
                  .toList(),
              onChanged: (selected) {
                if (selected != null) onChanged(selected);
              },
            ),
          ),
        ),
      ],
    );
  }
}

class _MessageCard extends StatelessWidget {
  const _MessageCard({
    required this.icon,
    required this.title,
    required this.message,
    this.actionLabel,
    this.onTap,
  });

  final IconData icon;
  final String title;
  final String message;
  final String? actionLabel;
  final Future<void> Function()? onTap;

  static const _surface = Colors.white;
  static const _ink = Color(0xFF1F1F1C);
  static const _muted = Color(0xFF6D685F);
  static const _border = Color(0xFFE2DDD3);
  static const _primary = Color(0xFF2C333A);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: _border),
      ),
      child: Column(
        children: [
          Icon(icon, size: 42, color: _muted),
          const SizedBox(height: 10),
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: _ink,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: _muted,
            ),
          ),
          if (actionLabel != null && onTap != null) ...[
            const SizedBox(height: 14),
            ElevatedButton(
              onPressed: onTap,
              style: ElevatedButton.styleFrom(
                backgroundColor: _primary,
                foregroundColor: Colors.white,
                elevation: 0,
              ),
              child: Text(
                actionLabel!,
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
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
    final date = createdAt!;
    final month = _monthName(date.month);
    final hour = date.hour > 12
        ? date.hour - 12
        : (date.hour == 0 ? 12 : date.hour);
    final minute = date.minute.toString().padLeft(2, '0');
    final amPm = date.hour >= 12 ? 'PM' : 'AM';
    return '$month ${date.day}, ${date.year} - $hour:$minute $amPm';
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

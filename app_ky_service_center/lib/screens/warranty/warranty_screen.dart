import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../services/api_service.dart';
import '../../widgets/app_network_image.dart';
import '../../widgets/auth_guard.dart';

// ── Palette ───────────────────────────────────────────────────────────────────
const _kBlue    = Color(0xFF4A88F7);
const _kGreen   = Color(0xFF22C55E);
const _kAmber   = Color(0xFFF59E0B);
const _kRed     = Color(0xFFEF4444);
const _kGrad1   = Color(0xFF3B63FF);
const _kGrad2   = Color(0xFF7C3AED);

// ── Screen ────────────────────────────────────────────────────────────────────

class WarrantyScreen extends StatefulWidget {
  const WarrantyScreen({super.key});

  @override
  State<WarrantyScreen> createState() => _WarrantyScreenState();
}

class _WarrantyScreenState extends State<WarrantyScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabCtrl;
  static const _tabs = ['All', 'Active', 'Expired'];

  bool _loading = true;
  List<Map<String, dynamic>> _all     = [];
  List<Map<String, dynamic>> _active  = [];
  List<Map<String, dynamic>> _expired = [];

  List<Map<String, dynamic>> get _expiringSoon => _active
      .where((w) => ((w['days_remaining'] as num?)?.toInt() ?? 0) <= 30)
      .toList();

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: _tabs.length, vsync: this);
    _load();
  }

  @override
  void dispose() {
    _tabCtrl.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    if (!mounted) return;
    final loggedIn = await ensureLoggedIn(context);
    if (!mounted) return;
    if (!loggedIn) { Navigator.of(context).pop(); return; }

    setState(() => _loading = true);
    final warranties = await ApiService.getWarranties();
    if (!mounted) return;
    setState(() {
      _all     = warranties;
      _active  = warranties.where((w) => w['status'] == 'active').toList();
      _expired = warranties.where((w) => w['status'] == 'expired').toList();
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg     = isDark ? const Color(0xFF0D1117) : const Color(0xFFF4F7FF);

    return Scaffold(
      backgroundColor: bg,
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) => [
          SliverAppBar(
            pinned: true,
            expandedHeight: 200,
            backgroundColor: _kGrad1,
            foregroundColor: Colors.white,
            elevation: innerBoxIsScrolled ? 2 : 0,
            flexibleSpace: FlexibleSpaceBar(
              collapseMode: CollapseMode.pin,
              background: _buildHeader(isDark),
            ),
            title: AnimatedOpacity(
              opacity: innerBoxIsScrolled ? 1 : 0,
              duration: const Duration(milliseconds: 200),
              child: const Text('My Warranties',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
            ),
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(44),
              child: _buildTabBar(),
            ),
          ),
        ],
        body: _loading
            ? _buildSkeleton(isDark)
            : RefreshIndicator(
                onRefresh: _load,
                color: _kBlue,
                child: TabBarView(
                  controller: _tabCtrl,
                  children: [
                    _WarrantyListView(
                        items: _all,
                        isDark: isDark,
                        expiringSoon: _expiringSoon),
                    _WarrantyListView(
                        items: _active,
                        isDark: isDark,
                        expiringSoon: _expiringSoon),
                    _WarrantyListView(
                        items: _expired,
                        isDark: isDark,
                        expiringSoon: const []),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _buildHeader(bool isDark) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [_kGrad1, _kGrad2],
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 10, 20, 52),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Back + title row
              Row(children: [
                GestureDetector(
                  onTap: () => Navigator.of(context).maybePop(),
                  child: Container(
                    width: 36, height: 36,
                    decoration: BoxDecoration(
                        color: Colors.white.withAlpha(30),
                        borderRadius: BorderRadius.circular(10)),
                    child: const Icon(Icons.arrow_back_ios_new_rounded,
                        size: 16, color: Colors.white),
                  ),
                ),
                const SizedBox(width: 12),
                const Text('My Warranties',
                    style: TextStyle(
                        fontSize: 20, fontWeight: FontWeight.w700, color: Colors.white)),
              ]),
              const SizedBox(height: 20),
              // Summary chips
              if (!_loading)
                Row(children: [
                  _SummaryChip(
                    icon: Icons.verified_rounded,
                    label: 'Active',
                    count: _active.length,
                    color: _kGreen,
                  ),
                  const SizedBox(width: 10),
                  _SummaryChip(
                    icon: Icons.warning_amber_rounded,
                    label: 'Expiring Soon',
                    count: _expiringSoon.length,
                    color: _kAmber,
                  ),
                  const SizedBox(width: 10),
                  _SummaryChip(
                    icon: Icons.cancel_outlined,
                    label: 'Expired',
                    count: _expired.length,
                    color: _kRed,
                  ),
                ]),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      color: _kGrad2,
      child: TabBar(
        controller: _tabCtrl,
        labelColor: Colors.white,
        unselectedLabelColor: Colors.white54,
        indicatorColor: Colors.white,
        indicatorWeight: 2.5,
        indicatorSize: TabBarIndicatorSize.label,
        labelStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
        unselectedLabelStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
        tabs: _tabs.map((t) => Tab(text: t)).toList(),
      ),
    );
  }

  Widget _buildSkeleton(bool isDark) {
    final shimmer = isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0);
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
      itemCount: 3,
      separatorBuilder: (context, index) => const SizedBox(height: 14),
      itemBuilder: (context, index) => Container(
        height: 130,
        decoration: BoxDecoration(
          color: shimmer,
          borderRadius: BorderRadius.circular(18),
        ),
      ),
    );
  }
}

// ── Summary chip ──────────────────────────────────────────────────────────────

class _SummaryChip extends StatelessWidget {
  const _SummaryChip({
    required this.icon,
    required this.label,
    required this.count,
    required this.color,
  });

  final IconData icon;
  final String label;
  final int count;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withAlpha(22),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withAlpha(40)),
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(icon, size: 14, color: color),
        const SizedBox(width: 6),
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('$count',
              style: const TextStyle(
                  fontSize: 15, fontWeight: FontWeight.w800, color: Colors.white)),
          Text(label,
              style: TextStyle(
                  fontSize: 9,
                  fontWeight: FontWeight.w600,
                  color: Colors.white.withAlpha(180),
                  letterSpacing: 0.3)),
        ]),
      ]),
    );
  }
}

// ── List view ─────────────────────────────────────────────────────────────────

class _WarrantyListView extends StatelessWidget {
  const _WarrantyListView({
    required this.items,
    required this.isDark,
    required this.expiringSoon,
  });

  final List<Map<String, dynamic>> items;
  final bool isDark;
  final List<Map<String, dynamic>> expiringSoon;

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return _EmptyState(isDark: isDark);
    }

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 40),
      children: [
        // Expiring soon alert (only on All and Active tabs)
        if (expiringSoon.isNotEmpty) ...[
          _ExpiringSoonBanner(items: expiringSoon, isDark: isDark),
          const SizedBox(height: 16),
        ],
        ...items.asMap().entries.map((e) => Padding(
          padding: EdgeInsets.only(bottom: e.key < items.length - 1 ? 14 : 0),
          child: WarrantyCard(item: e.value, isDark: isDark),
        )),
      ],
    );
  }
}

// ── Expiring soon banner ──────────────────────────────────────────────────────

class _ExpiringSoonBanner extends StatelessWidget {
  const _ExpiringSoonBanner({required this.items, required this.isDark});

  final List<Map<String, dynamic>> items;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: _kAmber.withAlpha(isDark ? 25 : 20),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _kAmber.withAlpha(80)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 32, height: 32,
            decoration: BoxDecoration(
                color: _kAmber.withAlpha(30),
                borderRadius: BorderRadius.circular(8)),
            child: const Icon(Icons.warning_amber_rounded, size: 18, color: _kAmber),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${items.length} ${items.length == 1 ? 'warranty' : 'warranties'} expiring soon',
                  style: const TextStyle(
                      fontSize: 13, fontWeight: FontWeight.w700, color: _kAmber),
                ),
                const SizedBox(height: 3),
                Text(
                  items.map((w) {
                    final d = (w['days_remaining'] as num?)?.toInt() ?? 0;
                    final name = (w['product_name'] as String?)?.split(' ').take(3).join(' ') ?? '—';
                    return '$name ($d day${d == 1 ? '' : 's'})';
                  }).join('  ·  '),
                  style: TextStyle(
                      fontSize: 11,
                      color: _kAmber.withAlpha(isDark ? 200 : 180),
                      height: 1.4),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Warranty card ─────────────────────────────────────────────────────────────

class WarrantyCard extends StatelessWidget {
  const WarrantyCard({super.key, required this.item, required this.isDark});

  final Map<String, dynamic> item;
  final bool isDark;

  Color get _cardBg   => isDark ? const Color(0xFF161D2B) : Colors.white;
  Color get _textPri  => isDark ? Colors.white : const Color(0xFF0F172A);
  Color get _textMut  => isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);
  Color get _divider  => isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9);

  @override
  Widget build(BuildContext context) {
    final status      = item['status'] as String? ?? 'unknown';
    final isActive    = status == 'active';
    final isExpired   = status == 'expired';
    final productName = item['product_name']  as String? ?? '—';
    final variant     = item['variant_label'] as String?;
    final periodLabel = item['period_label']  as String? ?? '—';
    final startDate   = _parseDate(item['start_date']);
    final endDate     = _parseDate(item['end_date']);
    final daysLeft    = (item['days_remaining']   as num?)?.toInt() ?? 0;
    final progress    = (item['progress_percent'] as num?)?.toDouble() ?? 0.0;
    final orderNum    = item['order_number'] as String?;
    final thumbnail   = item['product_thumbnail'] as String?;

    final statusColor  = isActive
        ? (daysLeft <= 7 ? _kRed : daysLeft <= 30 ? _kAmber : _kGreen)
        : isExpired ? _kRed : const Color(0xFF94A3B8);
    final progressColor = daysLeft > 30 ? _kGreen : daysLeft > 7 ? _kAmber : _kRed;
    final statusLabel  = isActive
        ? (daysLeft <= 7 ? 'Expiring!' : daysLeft <= 30 ? 'Expiring Soon' : 'Active')
        : status[0].toUpperCase() + status.substring(1);
    final borderColor  = isActive
        ? statusColor.withAlpha(isDark ? 60 : 40)
        : isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0);

    return Container(
      decoration: BoxDecoration(
        color: _cardBg,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: borderColor, width: isActive ? 1.5 : 1),
        boxShadow: [
          BoxShadow(
            color: isActive ? statusColor.withAlpha(isDark ? 15 : 12) : Colors.black.withAlpha(6),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // ── Top: thumbnail + product info + status ───────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildThumb(thumbnail, statusColor, isActive, isExpired),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(productName,
                        maxLines: 2, overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                            fontSize: 15, fontWeight: FontWeight.w700,
                            color: _textPri, height: 1.3)),
                      if (variant != null && variant.isNotEmpty) ...[
                        const SizedBox(height: 3),
                        Text(variant,
                            style: TextStyle(fontSize: 11, color: _textMut)),
                      ],
                      const SizedBox(height: 8),
                      // Warranty period badge
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: _kBlue.withAlpha(isDark ? 30 : 18),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(mainAxisSize: MainAxisSize.min, children: [
                          const Icon(Icons.shield_rounded,
                              size: 12, color: _kBlue),
                          const SizedBox(width: 5),
                          Text(periodLabel,
                              style: const TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  color: _kBlue)),
                        ]),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                // Status badge
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: statusColor.withAlpha(isDark ? 30 : 18),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(statusLabel,
                      style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          color: statusColor,
                          letterSpacing: 0.3)),
                ),
              ],
            ),
          ),

          // ── Divider ──────────────────────────────────────────────────
          Divider(height: 1, color: _divider, indent: 16, endIndent: 16),

          // ── Dates row ────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            child: Row(
              children: [
                _DateBox(
                  label: 'Started',
                  value: startDate != null
                      ? DateFormat('dd MMM yyyy').format(startDate)
                      : '—',
                  icon: Icons.play_circle_outline_rounded,
                  color: _kGreen,
                  isDark: isDark,
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 6),
                    child: Row(
                      children: List.generate(
                        5,
                        (i) => Expanded(
                          child: Container(
                            height: 2,
                            margin: const EdgeInsets.symmetric(horizontal: 2),
                            decoration: BoxDecoration(
                              color: i < (progress / 20).round()
                                  ? progressColor.withAlpha(180)
                                  : isDark
                                      ? const Color(0xFF1E293B)
                                      : const Color(0xFFE2E8F0),
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                _DateBox(
                  label: 'Expires',
                  value: endDate != null
                      ? DateFormat('dd MMM yyyy').format(endDate)
                      : '—',
                  icon: isExpired
                      ? Icons.event_busy_outlined
                      : Icons.event_available_outlined,
                  color: isExpired ? _kRed : _kAmber,
                  isDark: isDark,
                  alignRight: true,
                ),
              ],
            ),
          ),

          // ── Progress section (active only) ───────────────────────────
          if (isActive) ...[
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Coverage used',
                          style: TextStyle(fontSize: 11, color: _textMut)),
                      // Days remaining highlight
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 3),
                        decoration: BoxDecoration(
                          color: progressColor.withAlpha(isDark ? 30 : 18),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          daysLeft == 0
                              ? 'Last day!'
                              : '$daysLeft day${daysLeft == 1 ? '' : 's'} left',
                          style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                              color: progressColor),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 7),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: LinearProgressIndicator(
                      value: (progress / 100).clamp(0.0, 1.0),
                      minHeight: 6,
                      backgroundColor: isDark
                          ? const Color(0xFF1E293B)
                          : const Color(0xFFF1F5F9),
                      valueColor: AlwaysStoppedAnimation<Color>(progressColor),
                    ),
                  ),
                ],
              ),
            ),
          ],

          // ── Footer: order number ─────────────────────────────────────
          if (orderNum != null)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 14),
              child: Row(children: [
                Icon(Icons.receipt_long_outlined, size: 12, color: _textMut),
                const SizedBox(width: 5),
                Text('Order $orderNum',
                    style: TextStyle(fontSize: 11, color: _textMut)),
              ]),
            )
          else
            const SizedBox(height: 14),
        ],
      ),
    );
  }

  Widget _buildThumb(String? url, Color statusColor, bool isActive, bool isExpired) {
    final iconWidget = Container(
      width: 56, height: 56,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [statusColor.withAlpha(30), statusColor.withAlpha(12)],
        ),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Icon(
        isActive ? Icons.verified_rounded
            : isExpired ? Icons.cancel_outlined : Icons.block_outlined,
        color: statusColor, size: 26,
      ),
    );

    if (url == null || url.isEmpty) return iconWidget;
    return ClipRRect(
      borderRadius: BorderRadius.circular(14),
      child: AppNetworkImage(url, width: 56, height: 56, fit: BoxFit.cover,
          errorWidget: (context, _, error) => iconWidget),
    );
  }

  DateTime? _parseDate(dynamic val) {
    if (val == null) return null;
    try { return DateTime.parse(val.toString()); } catch (_) { return null; }
  }
}

// ── Date box ──────────────────────────────────────────────────────────────────

class _DateBox extends StatelessWidget {
  const _DateBox({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
    required this.isDark,
    this.alignRight = false,
  });

  final String label;
  final String value;
  final IconData icon;
  final Color color;
  final bool isDark;
  final bool alignRight;

  @override
  Widget build(BuildContext context) {
    final textMut = isDark ? const Color(0xFF64748B) : const Color(0xFF94A3B8);
    final textPri = isDark ? Colors.white : const Color(0xFF0F172A);
    final cross   = alignRight
        ? CrossAxisAlignment.end
        : CrossAxisAlignment.start;

    return Column(crossAxisAlignment: cross, children: [
      Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(icon, size: 11, color: color),
        const SizedBox(width: 4),
        Text(label,
            style: TextStyle(
                fontSize: 9,
                fontWeight: FontWeight.w600,
                color: textMut,
                letterSpacing: 0.4)),
      ]),
      const SizedBox(height: 3),
      Text(value,
          style: TextStyle(
              fontSize: 12, fontWeight: FontWeight.w700, color: textPri)),
    ]);
  }
}

// ── Empty state ───────────────────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.isDark});
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final textMut = isDark ? const Color(0xFF475569) : const Color(0xFF94A3B8);
    final textSub = isDark ? const Color(0xFF334155) : const Color(0xFFCBD5E1);

    return ListView(children: [
      const SizedBox(height: 60),
      Center(
        child: Column(
          children: [
            Container(
              width: 90, height: 90,
              decoration: BoxDecoration(
                color: _kBlue.withAlpha(isDark ? 20 : 14),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.verified_user_outlined,
                  size: 42, color: _kBlue.withAlpha(isDark ? 120 : 100)),
            ),
            const SizedBox(height: 20),
            Text('No Warranties Yet',
                style: TextStyle(
                    fontSize: 17, fontWeight: FontWeight.w700, color: textMut)),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 44),
              child: Text(
                'Products you purchase that include a warranty will\nappear here once your order is completed.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 13, color: textSub, height: 1.5),
              ),
            ),
          ],
        ),
      ),
    ]);
  }
}

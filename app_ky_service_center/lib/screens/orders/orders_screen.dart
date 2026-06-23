import 'dart:async';

import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:intl/intl.dart';
import 'package:skeletonizer/skeletonizer.dart';

import '../../l10n/app_localizations.dart';
import '../../models/pickup_ticket.dart';
import '../../services/api_service.dart';
import '../../services/app_notification_service.dart';
import '../../widgets/empty_state_view.dart';
import '../../widgets/page_transitions.dart';
import '../tickets/ticket_detail_screen.dart';
import 'delivery_tracking_screen.dart';

bool _isDark(BuildContext context) =>
    Theme.of(context).brightness == Brightness.dark;

Color _screenBg(BuildContext context) =>
    Theme.of(context).scaffoldBackgroundColor;

Color _surface(BuildContext context) =>
    _isDark(context) ? const Color(0xFF161B22) : Colors.white;

Color _surfaceAlt(BuildContext context) =>
    _isDark(context) ? const Color(0xFF1D2635) : const Color(0xFFEFF6FF);

Color _border(BuildContext context) =>
    _isDark(context) ? const Color(0xFF2B3442) : const Color(0xFFE5E7EB);

Color _textPrimary(BuildContext context) =>
    _isDark(context) ? const Color(0xFFE6EDF7) : const Color(0xFF111827);

Color _textMuted(BuildContext context) =>
    _isDark(context) ? const Color(0xFF97A2B5) : const Color(0xFF6B7280);

enum _OrderCardType { delivery, pickup }

class _OrderEntry {
  const _OrderEntry({required this.type, required this.order});

  final _OrderCardType type;
  final PickupTicket order;

  bool get isHistory {
    if (type == _OrderCardType.pickup) {
      return !order.isActive;
    }

    switch ((order.orderStatus ?? '').toLowerCase()) {
      case 'completed':
      case 'cancelled':
      case 'rejected':
        return true;
      default:
        return false;
    }
  }

  DateTime? get placedAt => order.placedAt;
}

class OrdersScreen extends StatefulWidget {
  const OrdersScreen({super.key});

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  static const _autoRefreshInterval = Duration(seconds: 20);

  late Future<List<_OrderEntry>> _ordersFuture;
  StreamSubscription<OrderTrackingRealtimeEvent>? _trackingEventsSub;
  Timer? _autoRefreshTimer;

  @override
  void initState() {
    super.initState();
    _ordersFuture = _loadOrders();
    _subscribeToTrackingEvents();
    _startAutoRefresh();
  }

  @override
  void dispose() {
    _trackingEventsSub?.cancel();
    _autoRefreshTimer?.cancel();
    super.dispose();
  }

  Future<List<_OrderEntry>> _loadOrders() async {
    final results = await Future.wait<List<PickupTicket>>([
      ApiService.fetchUserOrders(orderType: 'delivery'),
      ApiService.fetchPickupTickets(),
    ]);

    final deliveryOrders = results[0]
        .where((order) => (order.orderType ?? '').toLowerCase() == 'delivery')
        .map((order) => _OrderEntry(type: _OrderCardType.delivery, order: order));

    final pickupOrders = results[1]
        .map((order) => _OrderEntry(type: _OrderCardType.pickup, order: order));

    final merged = [...deliveryOrders, ...pickupOrders];
    merged.sort((a, b) {
      final aTime = a.placedAt ?? DateTime.fromMillisecondsSinceEpoch(0);
      final bTime = b.placedAt ?? DateTime.fromMillisecondsSinceEpoch(0);
      return bTime.compareTo(aTime);
    });

    return merged;
  }

  Future<void> _refresh() async {
    setState(() {
      _ordersFuture = _loadOrders();
    });
    await _ordersFuture;
  }

  void _silentRefresh() {
    if (!mounted) {
      return;
    }
    setState(() {
      _ordersFuture = _loadOrders();
    });
  }

  void _subscribeToTrackingEvents() {
    _trackingEventsSub = AppNotificationService.instance.orderTrackingEvents
        .listen((_) {
          _silentRefresh();
        });
  }

  void _startAutoRefresh() {
    _autoRefreshTimer?.cancel();
    _autoRefreshTimer = Timer.periodic(_autoRefreshInterval, (_) {
      _silentRefresh();
    });
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: _screenBg(context),
        appBar: AppBar(
          title: Text(
            l.myOrders,
            style: const TextStyle(fontWeight: FontWeight.w700),
          ),
          backgroundColor: _surface(context),
          foregroundColor: _textPrimary(context),
          elevation: 0,
          bottom: TabBar(
            labelColor: _textPrimary(context),
            unselectedLabelColor: _textMuted(context),
            indicatorColor: const Color(0xFF2563EB),
            tabs: const [
              Tab(text: 'Active'),
              Tab(text: 'History'),
            ],
          ),
        ),
        body: FutureBuilder<List<_OrderEntry>>(
          future: _ordersFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting &&
                !snapshot.hasData) {
              final mockOrders = List.generate(
                3,
                (index) => const _OrderEntry(
                  type: _OrderCardType.delivery,
                  order: PickupTicket(
                    orderId: 0,
                    customerName: 'Loading Name',
                    items: [],
                    orderNumber: 'ORD-XXXX',
                    orderStatus: 'Loading',
                    totalAmount: 100.0,
                  ),
                ),
              );
              return Skeletonizer(
                enabled: true,
                child: TabBarView(
                  children: [
                    _OrderList(
                      orders: mockOrders,
                      emptyTitle: '',
                      emptySubtitle: '',
                      onRefresh: _refresh,
                    ),
                    _OrderList(
                      orders: mockOrders,
                      emptyTitle: '',
                      emptySubtitle: '',
                      onRefresh: _refresh,
                    ),
                  ],
                ),
              );
            }

            if (snapshot.hasError) {
              return _EmptyState(
                title: l.somethingWentWrong,
                subtitle: l.retry,
                onRetry: _refresh,
              );
            }

            final orders = snapshot.data ?? [];
            final activeOrders = orders.where((entry) => !entry.isHistory).toList();
            final historyOrders = orders.where((entry) => entry.isHistory).toList();

            return TabBarView(
              children: [
                _OrderList(
                  orders: activeOrders,
                  emptyTitle: l.noOrders,
                  emptySubtitle:
                      'New pickup and delivery orders will appear here.',
                  onRefresh: _refresh,
                ),
                _OrderList(
                  orders: historyOrders,
                  emptyTitle: l.orderHistory,
                  emptySubtitle:
                      'Completed, cancelled, and used orders will appear here.',
                  onRefresh: _refresh,
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _OrderList extends StatelessWidget {
  const _OrderList({
    required this.orders,
    required this.emptyTitle,
    required this.emptySubtitle,
    required this.onRefresh,
  });

  final List<_OrderEntry> orders;
  final String emptyTitle;
  final String emptySubtitle;
  final Future<void> Function() onRefresh;

  @override
  Widget build(BuildContext context) {
    if (orders.isEmpty) {
      return _EmptyState(
        title: emptyTitle,
        subtitle: emptySubtitle,
        onRetry: onRefresh,
      );
    }

    return RefreshIndicator(
      onRefresh: onRefresh,
      child: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: orders.length,
        separatorBuilder: (context, index) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final entry = orders[index];
          return _OrderCard(entry: entry);
        },
      ),
    );
  }
}

class _OrderCard extends StatelessWidget {
  const _OrderCard({required this.entry});

  final _OrderEntry entry;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final order = entry.order;
    final isDelivery = entry.type == _OrderCardType.delivery;
    final placedAt = order.placedAt;
    final amount = order.totalAmount ?? 0;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: () => _openOrder(context),
        child: Ink(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: _surface(context),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: _border(context)),
            boxShadow: const [
              BoxShadow(
                color: Color(0x0F000000),
                blurRadius: 12,
                offset: Offset(0, 6),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    height: 42,
                    width: 42,
                    decoration: BoxDecoration(
                      color: _surfaceAlt(context),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      isDelivery
                          ? HugeIcons.strokeRoundedDeliveryTruck01
                          : HugeIcons.strokeRoundedQrCode01,
                      color: const Color(0xFF2563EB),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          order.orderNumber ?? 'Order #${order.orderId}',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          placedAt == null
                              ? 'Placed recently'
                              : DateFormat(
                                  'dd MMM yyyy - hh:mm a',
                                ).format(placedAt),
                          style: TextStyle(fontSize: 12, color: _textMuted(context)),
                        ),
                      ],
                    ),
                  ),
                  _StatusBadge(label: order.statusLabel),
                ],
              ),
              const SizedBox(height: 14),
              _InfoLine(
                icon: isDelivery
                    ? HugeIcons.strokeRoundedLocation01
                    : HugeIcons.strokeRoundedStore01,
                text: isDelivery
                    ? (order.deliveryAddress?.trim().isNotEmpty == true
                          ? order.deliveryAddress!.trim()
                          : 'Delivery address not available')
                    : 'Pickup from store counter',
              ),
              const SizedBox(height: 8),
              _InfoLine(
                icon: HugeIcons.strokeRoundedMoney01,
                text: NumberFormat.currency(symbol: '\$').format(amount),
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  _TypeBadge(type: entry.type),
                  const Spacer(),
                  TextButton(
                    onPressed: () => _openOrder(context),
                    child: Text(
                      isDelivery ? l.trackOrder : 'View Ticket',
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _openOrder(BuildContext context) {
    final order = entry.order;
    if (entry.type == _OrderCardType.delivery) {
      Navigator.of(context).push(
        fadeSlideRoute(
          DeliveryTrackingScreen(
            orderId: order.orderId,
            orderNumber: order.orderNumber,
            initialStatus: order.orderStatus,
            initialPlacedAt: order.placedAt,
            initialDeliveryAddress: order.deliveryAddress,
            initialTotalAmount: order.totalAmount,
          ),
        ),
      );
      return;
    }

    Navigator.of(
      context,
    ).push(fadeSlideRoute(TicketDetailScreen(ticket: order)));
  }
}

class _TypeBadge extends StatelessWidget {
  const _TypeBadge({required this.type});

  final _OrderCardType type;

  @override
  Widget build(BuildContext context) {
    final isDelivery = type == _OrderCardType.delivery;
    final bg = isDelivery ? const Color(0xFFDBEAFE) : const Color(0xFFE0E7FF);
    final fg = isDelivery ? const Color(0xFF1D4ED8) : const Color(0xFF4338CA);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(999)),
      child: Text(
        isDelivery ? 'Delivery' : 'Pickup',
        style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: fg),
      ),
    );
  }
}

class _InfoLine extends StatelessWidget {
  const _InfoLine({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: _textMuted(context)),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 13,
              color: _textMuted(context),
              fontWeight: FontWeight.w600,
              height: 1.35,
            ),
          ),
        ),
      ],
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final lower = label.toLowerCase();
    Color bg;
    Color fg;
    if (lower == 'complete') {
      bg = const Color(0xFFDCFCE7);
      fg = const Color(0xFF15803D);
    } else if (lower == 'on the way') {
      bg = const Color(0xFFDBEAFE);
      fg = const Color(0xFF1D4ED8);
    } else if (lower == 'processing') {
      bg = const Color(0xFFFFEDD5);
      fg = const Color(0xFFEA580C);
    } else if (lower == 'approved') {
      bg = const Color(0xFFE0E7FF);
      fg = const Color(0xFF4338CA);
    } else if (lower == 'active') {
      bg = const Color(0xFFE0EAFF);
      fg = const Color(0xFF1D4ED8);
    } else if (lower == 'cancelled' || lower == 'rejected' || lower == 'expired') {
      bg = const Color(0xFFFEE2E2);
      fg = const Color(0xFFB91C1C);
    } else {
      bg = const Color(0xFFFFEDD5);
      fg = const Color(0xFFEA580C);
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: fg),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({
    required this.title,
    required this.subtitle,
    required this.onRetry,
  });

  final String title;
  final String subtitle;
  final Future<void> Function() onRetry;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return EmptyStateView(
      icon: HugeIcons.strokeRoundedInvoice01,
      title: title,
      subtitle: subtitle,
      actionLabel: l.retry,
      onAction: () => onRetry(),
    );
  }
}

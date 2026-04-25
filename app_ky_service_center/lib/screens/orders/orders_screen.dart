import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../models/pickup_ticket.dart';
import '../../services/api_service.dart';
import '../../widgets/page_transitions.dart';
import 'delivery_tracking_screen.dart';

class OrdersScreen extends StatefulWidget {
  const OrdersScreen({super.key});

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  late Future<List<PickupTicket>> _ordersFuture;

  @override
  void initState() {
    super.initState();
    _ordersFuture = _loadOrders();
  }

  Future<List<PickupTicket>> _loadOrders() async {
    final orders = await ApiService.fetchUserOrders(orderType: 'delivery');
    final deliveryOrders = orders.where(_isDeliveryOrder).toList();
    deliveryOrders.sort((a, b) {
      final aTime = a.placedAt ?? DateTime.fromMillisecondsSinceEpoch(0);
      final bTime = b.placedAt ?? DateTime.fromMillisecondsSinceEpoch(0);
      return bTime.compareTo(aTime);
    });
    return deliveryOrders;
  }

  bool _isDeliveryOrder(PickupTicket order) {
    return (order.orderType ?? '').toLowerCase() == 'delivery';
  }

  bool _isHistoryOrder(PickupTicket order) {
    final status = (order.orderStatus ?? '').toLowerCase();
    return status == 'completed' ||
        status == 'cancelled' ||
        status == 'rejected';
  }

  Future<void> _refresh() async {
    setState(() {
      _ordersFuture = _loadOrders();
    });
    await _ordersFuture;
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: const Color(0xFFF6F7FB),
        appBar: AppBar(
          title: const Text(
            'My Orders',
            style: TextStyle(fontWeight: FontWeight.w700),
          ),
          backgroundColor: Colors.white,
          foregroundColor: const Color(0xFF111827),
          elevation: 0,
          bottom: const TabBar(
            labelColor: Color(0xFF1F2937),
            indicatorColor: Color(0xFF2563EB),
            tabs: [
              Tab(text: 'Active'),
              Tab(text: 'History'),
            ],
          ),
        ),
        body: FutureBuilder<List<PickupTicket>>(
          future: _ordersFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return _EmptyState(
                title: 'Unable to load orders',
                subtitle: 'Please try again in a moment.',
                onRetry: _refresh,
              );
            }

            final orders = snapshot.data ?? [];
            final activeOrders = orders
                .where((order) => !_isHistoryOrder(order))
                .toList();
            final historyOrders = orders.where(_isHistoryOrder).toList();

            return TabBarView(
              children: [
                _OrderList(
                  orders: activeOrders,
                  emptyTitle: 'No active delivery orders',
                  emptySubtitle:
                      'Your new delivery orders will appear here for tracking.',
                  onRefresh: _refresh,
                ),
                _OrderList(
                  orders: historyOrders,
                  emptyTitle: 'No delivery history yet',
                  emptySubtitle: 'Completed delivery orders will appear here.',
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

  final List<PickupTicket> orders;
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
          final order = orders[index];
          return _OrderCard(order: order);
        },
      ),
    );
  }
}

class _OrderCard extends StatelessWidget {
  const _OrderCard({required this.order});

  final PickupTicket order;

  @override
  Widget build(BuildContext context) {
    final placedAt = order.placedAt;
    final status = _statusLabel(order.orderStatus);
    final amount = order.totalAmount ?? 0;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: () {
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
        },
        child: Ink(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: const Color(0xFFE5E7EB)),
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
                      color: const Color(0xFFEFF6FF),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.local_shipping_rounded,
                      color: Color(0xFF2563EB),
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
                            color: Color(0xFF111827),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          placedAt == null
                              ? 'Placed recently'
                              : DateFormat(
                                  'dd MMM yyyy • hh:mm a',
                                ).format(placedAt),
                          style: const TextStyle(
                            fontSize: 12,
                            color: Color(0xFF6B7280),
                          ),
                        ),
                      ],
                    ),
                  ),
                  _StatusBadge(label: status),
                ],
              ),
              const SizedBox(height: 14),
              _InfoLine(
                icon: Icons.place_outlined,
                text: order.deliveryAddress?.trim().isNotEmpty == true
                    ? order.deliveryAddress!.trim()
                    : 'Delivery address not available',
              ),
              const SizedBox(height: 8),
              _InfoLine(
                icon: Icons.attach_money_rounded,
                text: NumberFormat.currency(symbol: '\$').format(amount),
              ),
              const SizedBox(height: 14),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () {
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
                  },
                  child: const Text(
                    'View Order',
                    style: TextStyle(fontWeight: FontWeight.w700),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _statusLabel(String? status) {
    switch ((status ?? '').toLowerCase()) {
      case 'ready':
      case 'processing':
      case 'approved':
      case 'pending_approval':
        return 'Pending Approval';
      case 'assigned':
        return 'Assigned';
      case 'in_progress':
        return 'In Progress';
      case 'on_the_way':
        return 'On the Way';
      case 'arrived':
        return 'Arrived';
      case 'completed':
        return 'Completed';
      case 'cancelled':
        return 'Cancelled';
      case 'rejected':
        return 'Rejected';
      case 'created':
        return 'Created';
      default:
        return 'Pending Approval';
    }
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
        Icon(icon, size: 18, color: const Color(0xFF6B7280)),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              fontSize: 13,
              color: Color(0xFF4B5563),
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
    if (lower == 'completed') {
      bg = const Color(0xFFDCFCE7);
      fg = const Color(0xFF15803D);
    } else if (lower == 'on the way' || lower == 'arrived') {
      bg = const Color(0xFFDBEAFE);
      fg = const Color(0xFF1D4ED8);
    } else if (lower == 'in progress' || lower == 'assigned') {
      bg = const Color(0xFFFFEDD5);
      fg = const Color(0xFFEA580C);
    } else if (lower == 'cancelled' || lower == 'rejected') {
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
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.receipt_long_rounded,
              size: 52,
              color: Color(0xFF94A3B8),
            ),
            const SizedBox(height: 16),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: Color(0xFF111827),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Color(0xFF6B7280), height: 1.4),
            ),
            const SizedBox(height: 16),
            OutlinedButton(
              onPressed: () => onRetry(),
              child: const Text(
                'Refresh',
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

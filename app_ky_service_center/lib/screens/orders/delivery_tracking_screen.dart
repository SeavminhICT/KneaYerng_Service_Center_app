import 'dart:async';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../models/pickup_ticket.dart';
import '../../services/api_service.dart';

class DeliveryTrackingScreen extends StatefulWidget {
  const DeliveryTrackingScreen({
    super.key,
    this.orderId,
    this.orderNumber,
    this.initialStatus,
    this.initialPlacedAt,
    this.initialDeliveryAddress,
    this.initialTotalAmount,
  });

  final int? orderId;
  final String? orderNumber;
  final String? initialStatus;
  final DateTime? initialPlacedAt;
  final String? initialDeliveryAddress;
  final double? initialTotalAmount;

  @override
  State<DeliveryTrackingScreen> createState() => _DeliveryTrackingScreenState();
}

class _DeliveryTrackingScreenState extends State<DeliveryTrackingScreen> {
  static const _refreshInterval = Duration(seconds: 12);

  PickupTicket? _order;
  Timer? _refreshTimer;
  bool _isLoading = true;
  bool _isRefreshing = false;
  String? _errorMessage;
  DateTime? _lastSyncedAt;

  @override
  void initState() {
    super.initState();
    _loadOrder();
    _startAutoRefresh();
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
  }

  String get _rawStatus =>
      (_order?.orderStatus ?? widget.initialStatus ?? 'pending_approval')
          .trim()
          .toLowerCase();

  bool get _isTerminal => _order?.isTerminalDeliveryStatus ?? false;

  bool get _isCancelledLike =>
      _rawStatus == 'cancelled' || _rawStatus == 'rejected';

  DateTime? get _placedAt => _order?.placedAt ?? widget.initialPlacedAt;

  String get _orderLabel {
    final orderNumber = _order?.orderNumber ?? widget.orderNumber;
    if (orderNumber != null && orderNumber.trim().isNotEmpty) {
      return orderNumber.trim();
    }
    final orderId = _order?.orderId ?? widget.orderId;
    if (orderId != null) {
      return 'Order #$orderId';
    }
    return 'Delivery Order';
  }

  String get _deliveryAddress {
    final address = _order?.deliveryAddress ?? widget.initialDeliveryAddress;
    if (address != null && address.trim().isNotEmpty) {
      return address.trim();
    }
    return 'Delivery address will appear here after sync.';
  }

  double? get _totalAmount => _order?.totalAmount ?? widget.initialTotalAmount;

  List<TrackingTimelineStep> get _timeline =>
      _order?.trackingTimeline ?? const [];

  List<TrackingHistoryEntry> get _history =>
      _order?.trackingHistory ?? const [];

  void _startAutoRefresh() {
    _refreshTimer?.cancel();
    _refreshTimer = Timer.periodic(_refreshInterval, (_) {
      if (!mounted || _isTerminal || _isRefreshing) return;
      _loadOrder(silent: true);
    });
  }

  Future<void> _loadOrder({bool silent = false}) async {
    if (!silent) {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });
    } else {
      _isRefreshing = true;
    }

    try {
      PickupTicket? matched;
      if (widget.orderId != null) {
        matched = await ApiService.fetchUserOrder(
          orderId: widget.orderId,
          orderNumber: widget.orderNumber,
        );
      }

      matched ??= await _findOrderByOrderNumber();

      if (!mounted) return;

      setState(() {
        if (matched != null) {
          _order = matched;
        }
        _lastSyncedAt = DateTime.now();
        _errorMessage = matched == null
            ? 'Waiting for the latest tracking update from the server.'
            : null;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        if (_order == null) {
          _errorMessage = 'Unable to load delivery tracking right now.';
        }
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _isRefreshing = false;
        });
      }
    }
  }

  Future<PickupTicket?> _findOrderByOrderNumber() async {
    final target = widget.orderNumber?.trim();
    if (target == null || target.isEmpty) {
      return null;
    }

    final orders = await ApiService.fetchUserOrders(orderType: 'delivery');
    for (final order in orders) {
      if ((order.orderNumber ?? '').trim() == target) {
        return order;
      }
    }
    return null;
  }

  Future<void> _handleRefresh() => _loadOrder(silent: false);

  @override
  Widget build(BuildContext context) {
    final amount = _totalAmount;

    return Scaffold(
      backgroundColor: const Color(0xFFF6F7FB),
      appBar: AppBar(
        title: const Text(
          'Delivery Tracking',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF111827),
        elevation: 0,
      ),
      body: _isLoading && _order == null
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _handleRefresh,
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                children: [
                  _HeaderCard(
                    orderLabel: _orderLabel,
                    statusLabel:
                        _order?.statusLabel ?? _formatStatus(_rawStatus),
                    placedAt: _placedAt,
                    isAlert: _isCancelledLike,
                  ),
                  const SizedBox(height: 12),
                  _InfoCard(
                    title: 'Order Details',
                    children: [
                      _InfoRow(label: 'Address', value: _deliveryAddress),
                      _InfoRow(
                        label: 'Payment',
                        value: _paymentLabel(_order?.paymentMethod),
                      ),
                      _InfoRow(
                        label: 'Amount',
                        value: amount == null
                            ? '--'
                            : NumberFormat.currency(
                                symbol: '\$',
                              ).format(amount),
                      ),
                      _InfoRow(
                        label: 'Staff',
                        value:
                            _order?.assignedStaffName?.trim().isNotEmpty == true
                            ? _order!.assignedStaffName!
                            : 'Waiting for staff assignment',
                      ),
                      _InfoRow(
                        label: 'Last Sync',
                        value: _lastSyncedAt == null
                            ? 'Just opened'
                            : DateFormat(
                                'dd MMM yyyy • hh:mm a',
                              ).format(_lastSyncedAt!),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _InfoCard(
                    title: 'Tracking Timeline',
                    children: [
                      Text(
                        _isCancelledLike
                            ? 'This request stopped before completion. Check the history below for the latest admin update.'
                            : 'The current step is highlighted. Completed steps stay marked as finished.',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF6B7280),
                          height: 1.4,
                        ),
                      ),
                      const SizedBox(height: 16),
                      if (_timeline.isEmpty)
                        const Text(
                          'Tracking timeline will appear after the first delivery update.',
                          style: TextStyle(
                            color: Color(0xFF6B7280),
                            fontWeight: FontWeight.w600,
                          ),
                        )
                      else
                        ..._timeline.asMap().entries.map((entry) {
                          return _TimelineStep(
                            step: entry.value,
                            isLast: entry.key == _timeline.length - 1,
                            isAlert: _isCancelledLike,
                          );
                        }),
                    ],
                  ),
                  if (_history.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    _InfoCard(
                      title: 'Status History',
                      children: _history
                          .map((item) => _HistoryRow(entry: item))
                          .toList(),
                    ),
                  ],
                  if (_order?.items.isNotEmpty == true) ...[
                    const SizedBox(height: 12),
                    _InfoCard(
                      title: 'Items',
                      children: _order!.items
                          .map(
                            (item) => Padding(
                              padding: const EdgeInsets.symmetric(vertical: 6),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      item.name,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w600,
                                        color: Color(0xFF111827),
                                      ),
                                    ),
                                  ),
                                  Text(
                                    'x${item.quantity}',
                                    style: const TextStyle(
                                      color: Color(0xFF6B7280),
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          )
                          .toList(),
                    ),
                  ],
                  if (_errorMessage != null) ...[
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFF7ED),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: const Color(0xFFFED7AA)),
                      ),
                      child: Text(
                        _errorMessage!,
                        style: const TextStyle(
                          color: Color(0xFF9A3412),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: _isRefreshing ? null : _handleRefresh,
                          style: OutlinedButton.styleFrom(
                            foregroundColor: const Color(0xFF111827),
                            side: const BorderSide(color: Color(0xFFD1D5DB)),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                          child: Text(
                            _isRefreshing ? 'Refreshing...' : 'Refresh Status',
                            style: const TextStyle(fontWeight: FontWeight.w700),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () => Navigator.of(context).pop(),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF111827),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                          child: const Text(
                            'Back',
                            style: TextStyle(fontWeight: FontWeight.w700),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
    );
  }

  String _paymentLabel(String? paymentMethod) {
    switch ((paymentMethod ?? '').trim().toLowerCase()) {
      case 'aba':
      case 'aba_qr':
      case 'bakong':
        return 'Bakong QR';
      case 'cash':
      case 'cod':
        return 'Cash on Delivery';
      default:
        return (paymentMethod ?? '').trim().isEmpty
            ? 'Processing'
            : (paymentMethod ?? '').toUpperCase();
    }
  }

  String _formatStatus(String status) {
    if (status.trim().isEmpty) return 'Pending';
    return status
        .split('_')
        .map(
          (part) => part.isEmpty
              ? part
              : '${part[0].toUpperCase()}${part.substring(1)}',
        )
        .join(' ');
  }
}

class _HeaderCard extends StatelessWidget {
  const _HeaderCard({
    required this.orderLabel,
    required this.statusLabel,
    required this.placedAt,
    required this.isAlert,
  });

  final String orderLabel;
  final String statusLabel;
  final DateTime? placedAt;
  final bool isAlert;

  @override
  Widget build(BuildContext context) {
    final accentColor = isAlert
        ? const Color(0xFFDC2626)
        : const Color(0xFF2563EB);
    final accentBg = isAlert
        ? const Color(0xFFFEE2E2)
        : const Color(0xFFDBEAFE);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE5E7EB)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0F000000),
            blurRadius: 14,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            height: 52,
            width: 52,
            decoration: BoxDecoration(
              color: accentBg,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(
              Icons.local_shipping_rounded,
              color: accentColor,
              size: 28,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  orderLabel,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF111827),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  placedAt == null
                      ? 'Tracking started'
                      : 'Placed ${DateFormat('dd MMM yyyy • hh:mm a').format(placedAt!)}',
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF6B7280),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          _StatusPill(label: statusLabel, isAlert: isAlert),
        ],
      ),
    );
  }
}

class _StatusPill extends StatelessWidget {
  const _StatusPill({required this.label, required this.isAlert});

  final String label;
  final bool isAlert;

  @override
  Widget build(BuildContext context) {
    final lower = label.toLowerCase();
    Color bg;
    Color fg;
    if (isAlert) {
      bg = const Color(0xFFFEE2E2);
      fg = const Color(0xFFB91C1C);
    } else if (lower == 'completed') {
      bg = const Color(0xFFDCFCE7);
      fg = const Color(0xFF15803D);
    } else if (lower == 'on the way' || lower == 'arrived') {
      bg = const Color(0xFFDBEAFE);
      fg = const Color(0xFF1D4ED8);
    } else {
      bg = const Color(0xFFFFEDD5);
      fg = const Color(0xFFEA580C);
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
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

class _InfoCard extends StatelessWidget {
  const _InfoCard({required this.title, required this.children});

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: Color(0xFF111827),
            ),
          ),
          const SizedBox(height: 12),
          ...children,
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
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 84,
            child: Text(
              label,
              style: const TextStyle(
                color: Color(0xFF6B7280),
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                color: Color(0xFF111827),
                fontWeight: FontWeight.w600,
                height: 1.35,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TimelineStep extends StatelessWidget {
  const _TimelineStep({
    required this.step,
    required this.isLast,
    required this.isAlert,
  });

  final TrackingTimelineStep step;
  final bool isLast;
  final bool isAlert;

  @override
  Widget build(BuildContext context) {
    final isDone = step.done && !step.current;
    final isCurrent = step.current;

    Color markerColor;
    Color lineColor;
    Widget markerChild;

    if (isCurrent && isAlert) {
      markerColor = const Color(0xFFDC2626);
      lineColor = const Color(0xFFFECACA);
      markerChild = const Icon(
        Icons.close_rounded,
        color: Colors.white,
        size: 16,
      );
    } else if (isDone) {
      markerColor = const Color(0xFF2563EB);
      lineColor = const Color(0xFF93C5FD);
      markerChild = const Icon(
        Icons.check_rounded,
        color: Colors.white,
        size: 16,
      );
    } else if (isCurrent) {
      markerColor = const Color(0xFF2563EB);
      lineColor = const Color(0xFF93C5FD);
      markerChild = const Icon(
        Icons.radio_button_checked_rounded,
        color: Colors.white,
        size: 16,
      );
    } else {
      markerColor = const Color(0xFFE5E7EB);
      lineColor = const Color(0xFFE5E7EB);
      markerChild = const Icon(
        Icons.radio_button_unchecked_rounded,
        color: Color(0xFF9CA3AF),
        size: 16,
      );
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 2),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 36,
              child: Column(
                children: [
                  Container(
                    width: 30,
                    height: 30,
                    decoration: BoxDecoration(
                      color: markerColor,
                      shape: BoxShape.circle,
                    ),
                    child: Center(child: markerChild),
                  ),
                  if (!isLast)
                    Expanded(
                      child: Container(
                        width: 3,
                        margin: const EdgeInsets.symmetric(vertical: 6),
                        decoration: BoxDecoration(
                          color: lineColor,
                          borderRadius: BorderRadius.circular(999),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Padding(
                padding: EdgeInsets.only(bottom: isLast ? 0 : 22),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      step.label,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: step.upcoming
                            ? const Color(0xFF9CA3AF)
                            : const Color(0xFF111827),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      step.at == null
                          ? (step.description ?? '')
                          : DateFormat(
                              'dd MMM yyyy • hh:mm a',
                            ).format(step.at!),
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF6B7280),
                        height: 1.4,
                      ),
                    ),
                    if (step.at != null &&
                        step.description != null &&
                        step.description!.trim().isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        step.description!,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF6B7280),
                          height: 1.4,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HistoryRow extends StatelessWidget {
  const _HistoryRow({required this.entry});

  final TrackingHistoryEntry entry;

  @override
  Widget build(BuildContext context) {
    final subtitleParts = <String>[];
    if (entry.changedByName != null && entry.changedByName!.trim().isNotEmpty) {
      subtitleParts.add(entry.changedByName!.trim());
    }
    if (entry.changedByRole != null && entry.changedByRole!.trim().isNotEmpty) {
      subtitleParts.add(entry.changedByRole!.trim());
    }
    if (entry.assignedStaffName != null &&
        entry.assignedStaffName!.trim().isNotEmpty) {
      subtitleParts.add('Staff: ${entry.assignedStaffName!.trim()}');
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _formatStatus(entry.toStatus),
            style: const TextStyle(
              color: Color(0xFF111827),
              fontWeight: FontWeight.w700,
            ),
          ),
          if (entry.createdAt != null) ...[
            const SizedBox(height: 4),
            Text(
              DateFormat('dd MMM yyyy • hh:mm a').format(entry.createdAt!),
              style: const TextStyle(
                color: Color(0xFF6B7280),
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
          if (subtitleParts.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              subtitleParts.join(' • '),
              style: const TextStyle(color: Color(0xFF6B7280), fontSize: 12),
            ),
          ],
          if (entry.note != null && entry.note!.trim().isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(
              entry.note!,
              style: const TextStyle(
                color: Color(0xFF374151),
                fontSize: 12,
                height: 1.4,
              ),
            ),
          ],
        ],
      ),
    );
  }

  String _formatStatus(String status) {
    if (status.trim().isEmpty) return '--';
    return status
        .split('_')
        .map(
          (part) => part.isEmpty
              ? part
              : '${part[0].toUpperCase()}${part.substring(1)}',
        )
        .join(' ');
  }
}

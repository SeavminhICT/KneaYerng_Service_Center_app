import 'dart:async';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../models/pickup_ticket.dart';
import '../../services/api_service.dart';
import '../../services/app_notification_service.dart';

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
  StreamSubscription<OrderTrackingRealtimeEvent>? _trackingEventSub;
  bool _isLoading = true;
  bool _isRefreshing = false;
  String? _errorMessage;
  DateTime? _lastSyncedAt;

  @override
  void initState() {
    super.initState();
    _loadOrder();
    _startAutoRefresh();
    _subscribeToTrackingEvents();
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    _trackingEventSub?.cancel();
    super.dispose();
  }

  String get _rawStatus =>
      (_order?.orderStatus ?? widget.initialStatus ?? 'pending_approval')
          .trim()
          .toLowerCase();

  String get _statusLabel => _order?.statusLabel ?? _formatStatus(_rawStatus);

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

  String? get _deliveryPhone {
    final phone = _order?.deliveryPhone?.trim();
    if (phone == null || phone.isEmpty) {
      return null;
    }
    return phone;
  }

  String? get _deliveryNote {
    final note = _order?.deliveryNote?.trim();
    if (note == null || note.isEmpty) {
      return null;
    }
    return note;
  }

  double? get _totalAmount => _order?.totalAmount ?? widget.initialTotalAmount;

  List<TrackingTimelineStep> get _timeline =>
      _order?.trackingTimeline ?? const [];

  int get _completedStepsCount =>
      _timeline.where((step) => step.done || step.current).length;

  double get _progressRatio {
    if (_timeline.isEmpty) {
      return 0;
    }
    final value = _completedStepsCount / _timeline.length;
    return value.clamp(0.0, 1.0).toDouble();
  }

  String get _activeStageLabel {
    for (final step in _timeline) {
      if (step.current) {
        return step.label;
      }
    }

    for (final step in _timeline.reversed) {
      if (step.done) {
        return step.label;
      }
    }

    if (_isCancelledLike) {
      return 'Delivery stopped';
    }

    return _statusLabel;
  }

  String get _staffLabel {
    if (_order?.assignedStaffName?.trim().isNotEmpty == true) {
      return _order!.assignedStaffName!.trim();
    }
    return 'Waiting assignment';
  }

  String get _syncLabel {
    if (_lastSyncedAt == null) {
      return 'Just opened';
    }

    final diff = DateTime.now().difference(_lastSyncedAt!);
    if (diff.inMinutes <= 0) {
      return 'Just now';
    }
    if (diff.inMinutes == 1) {
      return '1 min ago';
    }
    if (diff.inMinutes < 60) {
      return '${diff.inMinutes} mins ago';
    }

    return _formatDateTime(_lastSyncedAt!);
  }

  void _startAutoRefresh() {
    _refreshTimer?.cancel();
    _refreshTimer = Timer.periodic(_refreshInterval, (_) {
      if (!mounted || _isTerminal || _isRefreshing) {
        return;
      }
      _loadOrder(silent: true);
    });
  }

  void _subscribeToTrackingEvents() {
    _trackingEventSub = AppNotificationService.instance.orderTrackingEvents
        .listen((event) {
          if (!mounted || _isRefreshing) {
            return;
          }

          if (!event.matchesOrder(
            id: _order?.orderId ?? widget.orderId,
            number: _order?.orderNumber ?? widget.orderNumber,
          )) {
            return;
          }

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

      if (!mounted) {
        return;
      }

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
      if (!mounted) {
        return;
      }

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
    final money = NumberFormat.currency(symbol: r'$');
    final totalAmountLabel = _totalAmount == null
        ? '--'
        : money.format(_totalAmount);
    final itemCount = _order?.items.length ?? 0;
    final completedLabel = _timeline.isEmpty
        ? '--'
        : '$_completedStepsCount / ${_timeline.length}';

    return Scaffold(
      backgroundColor: _TrackingUiColors.pageBg,
      appBar: AppBar(
        title: const Text(
          'Delivery Tracking',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
        foregroundColor: _TrackingUiColors.ink,
        backgroundColor: _TrackingUiColors.pageBg,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: _isRefreshing ? null : _handleRefresh,
            icon: _isRefreshing
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.refresh_rounded),
            tooltip: 'Refresh status',
          ),
        ],
      ),
      body: _isLoading && _order == null
          ? const _TrackingLoadingState()
          : RefreshIndicator(
              onRefresh: _handleRefresh,
              color: _TrackingUiColors.primary,
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 14, 16, 24),
                physics: const AlwaysScrollableScrollPhysics(),
                children: [
                  _HeroTrackingCard(
                    orderLabel: _orderLabel,
                    statusLabel: _statusLabel,
                    placedAt: _placedAt,
                    lastSyncedAt: _lastSyncedAt,
                    activeStageLabel: _activeStageLabel,
                    progressRatio: _progressRatio,
                    isAlert: _isCancelledLike,
                    isTerminal: _isTerminal,
                  ),
                  const SizedBox(height: 12),
                  _MetricsGrid(
                    children: [
                      _MetricTile(
                        icon: Icons.flag_circle_rounded,
                        label: 'Current Stage',
                        value: _activeStageLabel,
                      ),
                      _MetricTile(
                        icon: Icons.timeline_rounded,
                        label: 'Progress',
                        value: completedLabel,
                      ),
                      _MetricTile(
                        icon: Icons.payments_rounded,
                        label: 'Amount',
                        value: totalAmountLabel,
                      ),
                      _MetricTile(
                        icon: Icons.support_agent_rounded,
                        label: 'Staff',
                        value: _staffLabel,
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _SectionCard(
                    icon: Icons.local_shipping_rounded,
                    title: 'Delivery Snapshot',
                    subtitle: 'Latest destination and order details.',
                    child: Column(
                      children: [
                        _DetailLine(label: 'Address', value: _deliveryAddress),
                        if (_deliveryPhone != null)
                          _DetailLine(label: 'Phone', value: _deliveryPhone!),
                        if (_deliveryNote != null)
                          _DetailLine(label: 'Note', value: _deliveryNote!),
                        _DetailLine(
                          label: 'Payment',
                          value: _paymentLabel(_order?.paymentMethod),
                        ),
                        _DetailLine(label: 'Last Sync', value: _syncLabel),
                      ],
                    ),
                  ),
                  if (_order != null &&
                      (_order!.subtotal != null ||
                          _order!.deliveryFee != null ||
                          _order!.discountAmount != null)) ...[
                    const SizedBox(height: 12),
                    _SectionCard(
                      icon: Icons.receipt_long_rounded,
                      title: 'Payment Breakdown',
                      subtitle: 'How the final amount was calculated.',
                      child: Column(
                        children: [
                          _PriceLine(
                            label: 'Subtotal',
                            value: _order!.subtotal == null
                                ? '--'
                                : money.format(_order!.subtotal),
                          ),
                          _PriceLine(
                            label: 'Delivery Fee',
                            value: _order!.deliveryFee == null
                                ? '--'
                                : money.format(_order!.deliveryFee),
                          ),
                          _PriceLine(
                            label: 'Discount',
                            value: _order!.discountAmount == null
                                ? '--'
                                : '-${money.format(_order!.discountAmount)}',
                            isAccent: true,
                          ),
                          const SizedBox(height: 8),
                          _PriceLine(
                            label: 'Total',
                            value: totalAmountLabel,
                            isStrong: true,
                          ),
                        ],
                      ),
                    ),
                  ],
                  const SizedBox(height: 12),
                  _SectionCard(
                    icon: Icons.route_rounded,
                    title: 'Progress Timeline',
                    subtitle: _isCancelledLike
                        ? 'Delivery ended before completion. Check status history for details.'
                        : 'Current stage is highlighted and updates automatically.',
                    child: _timeline.isEmpty
                        ? const _EmptyHint(
                            message:
                                'Timeline will appear after the first delivery update.',
                          )
                        : Column(
                            children: _timeline.asMap().entries.map((entry) {
                              return _TimelineStepCard(
                                step: entry.value,
                                isLast: entry.key == _timeline.length - 1,
                                isAlertFlow: _isCancelledLike,
                              );
                            }).toList(),
                          ),
                  ),
                  if (_order?.items.isNotEmpty == true) ...[
                    const SizedBox(height: 12),
                    _SectionCard(
                      icon: Icons.inventory_2_rounded,
                      title: 'Order Items',
                      subtitle: '$itemCount item(s) in this delivery.',
                      child: Column(
                        children: _order!.items
                            .map(
                              (item) =>
                                  _OrderItemCard(item: item, money: money),
                            )
                            .toList(),
                      ),
                    ),
                  ],
                  if (_errorMessage != null) ...[
                    const SizedBox(height: 12),
                    _InlineWarning(message: _errorMessage!),
                  ],
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: FilledButton.tonalIcon(
                          onPressed: _isRefreshing ? null : _handleRefresh,
                          icon: const Icon(Icons.refresh_rounded),
                          label: Text(
                            _isRefreshing ? 'Refreshing...' : 'Refresh Status',
                            style: const TextStyle(fontWeight: FontWeight.w700),
                          ),
                          style: FilledButton.styleFrom(
                            foregroundColor: _TrackingUiColors.ink,
                            backgroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                              side: const BorderSide(
                                color: _TrackingUiColors.panelBorder,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () => Navigator.of(context).pop(),
                          icon: const Icon(Icons.arrow_back_rounded),
                          label: const Text(
                            'Back',
                            style: TextStyle(fontWeight: FontWeight.w700),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _TrackingUiColors.primary,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
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

  String _formatDateTime(DateTime date) {
    return DateFormat('dd MMM yyyy, hh:mm a').format(date);
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
    if (status.trim().isEmpty) {
      return 'Pending';
    }

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

class _TrackingUiColors {
  static const pageBg = Color(0xFFF1F5FF);
  static const panel = Colors.white;
  static const panelBorder = Color(0xFFDDE5FB);
  static const ink = Color(0xFF0F1D3A);
  static const muted = Color(0xFF5F6B8A);
  static const primary = Color(0xFF2C61F5);
  static const primarySoft = Color(0xFFDFE8FF);
  static const danger = Color(0xFFB42318);
  static const dangerSoft = Color(0xFFFEE4E2);
  static const success = Color(0xFF0D8F5A);
}

class _TrackingLoadingState extends StatelessWidget {
  const _TrackingLoadingState();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircularProgressIndicator(),
          SizedBox(height: 14),
          Text(
            'Loading delivery tracking...',
            style: TextStyle(
              color: _TrackingUiColors.muted,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _HeroTrackingCard extends StatelessWidget {
  const _HeroTrackingCard({
    required this.orderLabel,
    required this.statusLabel,
    required this.placedAt,
    required this.lastSyncedAt,
    required this.activeStageLabel,
    required this.progressRatio,
    required this.isAlert,
    required this.isTerminal,
  });

  final String orderLabel;
  final String statusLabel;
  final DateTime? placedAt;
  final DateTime? lastSyncedAt;
  final String activeStageLabel;
  final double progressRatio;
  final bool isAlert;
  final bool isTerminal;

  @override
  Widget build(BuildContext context) {
    final gradientTop = isAlert
        ? const Color(0xFFB42318)
        : const Color(0xFF1E3A8A);
    final gradientBottom = isAlert
        ? const Color(0xFFD92D20)
        : const Color(0xFF2C61F5);
    final dateLabel = placedAt == null
        ? 'Tracking started'
        : DateFormat('dd MMM yyyy, hh:mm a').format(placedAt!);
    final syncLabel = lastSyncedAt == null
        ? 'just now'
        : DateFormat('hh:mm a').format(lastSyncedAt!);
    final percentage = (progressRatio * 100).round();

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [gradientTop, gradientBottom],
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x260F172A),
            blurRadius: 18,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.16),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(
                  Icons.local_shipping_rounded,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      orderLabel,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 19,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Placed: $dateLabel',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.8),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              _HeroStatusBadge(label: statusLabel, isAlert: isAlert),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: Text(
                  activeStageLabel,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                  ),
                ),
              ),
              Text(
                '$percentage%',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(99),
            child: LinearProgressIndicator(
              minHeight: 7,
              value: isTerminal ? 1 : progressRatio,
              backgroundColor: Colors.white.withValues(alpha: 0.26),
              valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'Last synced $syncLabel',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.78),
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _HeroStatusBadge extends StatelessWidget {
  const _HeroStatusBadge({required this.label, required this.isAlert});

  final String label;
  final bool isAlert;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: isAlert
            ? Colors.white.withValues(alpha: 0.16)
            : Colors.white.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 11,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

class _MetricsGrid extends StatelessWidget {
  const _MetricsGrid({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final cardWidth = (width - 42) / 2;

    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: children
          .map((child) => SizedBox(width: cardWidth, child: child))
          .toList(),
    );
  }
}

class _MetricTile extends StatelessWidget {
  const _MetricTile({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: _TrackingUiColors.panel,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _TrackingUiColors.panelBorder),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: _TrackingUiColors.primarySoft,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: _TrackingUiColors.primary, size: 18),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 11,
                    color: _TrackingUiColors.muted,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 13,
                    color: _TrackingUiColors.ink,
                    fontWeight: FontWeight.w800,
                    height: 1.3,
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

class _SectionCard extends StatelessWidget {
  const _SectionCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.child,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _TrackingUiColors.panel,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _TrackingUiColors.panelBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: _TrackingUiColors.primarySoft,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: _TrackingUiColors.primary, size: 18),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        color: _TrackingUiColors.ink,
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        color: _TrackingUiColors.muted,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          child,
        ],
      ),
    );
  }
}

class _DetailLine extends StatelessWidget {
  const _DetailLine({required this.label, required this.value});

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
            width: 82,
            child: Text(
              label,
              style: const TextStyle(
                color: _TrackingUiColors.muted,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                color: _TrackingUiColors.ink,
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

class _PriceLine extends StatelessWidget {
  const _PriceLine({
    required this.label,
    required this.value,
    this.isAccent = false,
    this.isStrong = false,
  });

  final String label;
  final String value;
  final bool isAccent;
  final bool isStrong;

  @override
  Widget build(BuildContext context) {
    Color textColor = _TrackingUiColors.ink;
    if (isAccent) {
      textColor = _TrackingUiColors.success;
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                color: _TrackingUiColors.muted,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              color: textColor,
              fontWeight: isStrong ? FontWeight.w800 : FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyHint extends StatelessWidget {
  const _EmptyHint({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFF),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _TrackingUiColors.panelBorder),
      ),
      child: Text(
        message,
        style: const TextStyle(
          color: _TrackingUiColors.muted,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _TimelineStepCard extends StatelessWidget {
  const _TimelineStepCard({
    required this.step,
    required this.isLast,
    required this.isAlertFlow,
  });

  final TrackingTimelineStep step;
  final bool isLast;
  final bool isAlertFlow;

  @override
  Widget build(BuildContext context) {
    final isDone = step.done && !step.current;
    final isCurrent = step.current;
    final isUpcoming = !isDone && !isCurrent;

    final Color markerColor;
    final Color lineColor;
    final IconData icon;
    final Color cardColor;
    final Color cardBorder;
    final String badgeText;
    final Color badgeColor;
    final Color badgeTextColor;

    if (isCurrent && isAlertFlow) {
      markerColor = _TrackingUiColors.danger;
      lineColor = const Color(0xFFFECACA);
      icon = Icons.close_rounded;
      cardColor = _TrackingUiColors.dangerSoft;
      cardBorder = const Color(0xFFFECACA);
      badgeText = 'Cancelled';
      badgeColor = const Color(0xFFFECDCA);
      badgeTextColor = const Color(0xFFB42318);
    } else if (isDone) {
      markerColor = _TrackingUiColors.primary;
      lineColor = const Color(0xFFBFD1FF);
      icon = Icons.check_rounded;
      cardColor = const Color(0xFFF7F9FF);
      cardBorder = const Color(0xFFD6E1FF);
      badgeText = 'Done';
      badgeColor = _TrackingUiColors.primarySoft;
      badgeTextColor = const Color(0xFF1D4ED8);
    } else if (isCurrent) {
      markerColor = _TrackingUiColors.primary;
      lineColor = const Color(0xFFBFD1FF);
      icon = Icons.near_me_rounded;
      cardColor = const Color(0xFFEFF4FF);
      cardBorder = const Color(0xFFC9D8FF);
      badgeText = 'Current';
      badgeColor = _TrackingUiColors.primarySoft;
      badgeTextColor = const Color(0xFF1D4ED8);
    } else {
      markerColor = const Color(0xFFCBD5E1);
      lineColor = const Color(0xFFE2E8F0);
      icon = Icons.more_horiz_rounded;
      cardColor = Colors.white;
      cardBorder = const Color(0xFFE2E8F0);
      badgeText = 'Upcoming';
      badgeColor = const Color(0xFFF1F5F9);
      badgeTextColor = const Color(0xFF475569);
    }

    final dateText = step.at == null
        ? null
        : DateFormat('dd MMM yyyy, hh:mm a').format(step.at!);

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 32,
            child: Column(
              children: [
                Container(
                  width: 22,
                  height: 22,
                  decoration: BoxDecoration(
                    color: markerColor,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, size: 14, color: Colors.white),
                ),
                if (!isLast)
                  Container(
                    width: 2,
                    height: 62,
                    margin: const EdgeInsets.only(top: 4),
                    color: lineColor,
                  ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: cardColor,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: cardBorder),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          step.label,
                          style: TextStyle(
                            color: isUpcoming
                                ? const Color(0xFF64748B)
                                : _TrackingUiColors.ink,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: badgeColor,
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(
                          badgeText,
                          style: TextStyle(
                            color: badgeTextColor,
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                  if (dateText != null) ...[
                    const SizedBox(height: 5),
                    Text(
                      dateText,
                      style: const TextStyle(
                        color: _TrackingUiColors.muted,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                  if ((step.description ?? '').trim().isNotEmpty) ...[
                    const SizedBox(height: 6),
                    Text(
                      step.description!.trim(),
                      style: const TextStyle(
                        color: _TrackingUiColors.muted,
                        fontSize: 12,
                        height: 1.35,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _OrderItemCard extends StatelessWidget {
  const _OrderItemCard({required this.item, required this.money});

  final PickupTicketItem item;
  final NumberFormat money;

  @override
  Widget build(BuildContext context) {
    final lineTotal = money.format(item.lineTotal);

    return Container(
      margin: const EdgeInsets.only(bottom: 9),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFF),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _TrackingUiColors.panelBorder),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              item.name,
              style: const TextStyle(
                color: _TrackingUiColors.ink,
                fontWeight: FontWeight.w700,
                height: 1.3,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Text(
            'x${item.quantity}',
            style: const TextStyle(
              color: _TrackingUiColors.muted,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(width: 12),
          Text(
            lineTotal,
            style: const TextStyle(
              color: _TrackingUiColors.ink,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class _InlineWarning extends StatelessWidget {
  const _InlineWarning({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: _TrackingUiColors.dangerSoft,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFFECACA)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.warning_rounded, color: _TrackingUiColors.danger),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(
                color: _TrackingUiColors.danger,
                fontWeight: FontWeight.w700,
                height: 1.35,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

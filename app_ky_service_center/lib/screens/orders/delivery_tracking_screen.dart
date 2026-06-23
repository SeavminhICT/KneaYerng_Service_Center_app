import 'dart:async';

import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:intl/intl.dart';
import 'package:skeletonizer/skeletonizer.dart';

import '../../l10n/app_localizations.dart';
import '../../models/pickup_ticket.dart';
import '../../services/api_service.dart';
import '../../services/app_notification_service.dart';
import 'widgets/delivery_tracking_colors.dart';
import 'widgets/delivery_tracking_detail_line.dart';
import 'widgets/delivery_tracking_empty_hint.dart';
import 'widgets/delivery_tracking_hero_card.dart';
import 'widgets/delivery_tracking_inline_warning.dart';
import 'widgets/delivery_tracking_metrics_grid.dart';
import 'widgets/delivery_tracking_order_item_card.dart';
import 'widgets/delivery_tracking_price_line.dart';
import 'widgets/delivery_tracking_section_card.dart';
import 'widgets/delivery_tracking_timeline_step_card.dart';

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
    final l = AppLocalizations.of(context);
    final money = NumberFormat.currency(symbol: r'$');
    final totalAmountLabel = _totalAmount == null
        ? '--'
        : money.format(_totalAmount);
    final itemCount = _order?.items.length ?? 0;
    final completedLabel = _timeline.isEmpty
        ? '--'
        : '$_completedStepsCount / ${_timeline.length}';

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          l.deliveryTracking,
          style: const TextStyle(fontWeight: FontWeight.w800),
        ),
        foregroundColor: TrackingUiColors.ink,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
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
                : const Icon(HugeIcons.strokeRoundedRefresh),
            tooltip: 'Refresh status',
          ),
        ],
      ),
      body: Skeletonizer(
        enabled: _isLoading && _order == null,
        child: RefreshIndicator(
          onRefresh: _handleRefresh,
          color: TrackingUiColors.primary,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 24),
            physics: const AlwaysScrollableScrollPhysics(),
            children: [
              DeliveryTrackingHeroCard(
                orderLabel: (_isLoading && _order == null) ? 'Order #00000000' : _orderLabel,
                statusLabel: (_isLoading && _order == null) ? 'Processing' : _statusLabel,
                placedAt: (_isLoading && _order == null) ? DateTime.now() : _placedAt,
                lastSyncedAt: (_isLoading && _order == null) ? DateTime.now() : _lastSyncedAt,
                activeStageLabel: (_isLoading && _order == null) ? 'Processing stage' : _activeStageLabel,
                progressRatio: (_isLoading && _order == null) ? 0.25 : _progressRatio,
                isAlert: (_isLoading && _order == null) ? false : _isCancelledLike,
                isTerminal: (_isLoading && _order == null) ? false : _isTerminal,
              ),
                  const SizedBox(height: 12),
                  DeliveryTrackingMetricsGrid(
                    children: [
                      DeliveryTrackingMetricTile(
                        icon: HugeIcons.strokeRoundedFlag03,
                        label: 'Current Stage',
                        value: _activeStageLabel,
                      ),
                      DeliveryTrackingMetricTile(
                        icon: HugeIcons.strokeRoundedTimeQuarter,
                        label: 'Progress',
                        value: completedLabel,
                      ),
                      DeliveryTrackingMetricTile(
                        icon: HugeIcons.strokeRoundedMoney02,
                        label: l.payment,
                        value: totalAmountLabel,
                      ),
                      DeliveryTrackingMetricTile(
                        icon: HugeIcons.strokeRoundedCustomerService,
                        label: 'Staff',
                        value: _staffLabel,
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  DeliveryTrackingSectionCard(
                    icon: HugeIcons.strokeRoundedDeliveryTruck01,
                    title: 'Delivery Snapshot',
                    subtitle: 'Latest destination and order details.',
                    child: Column(
                      children: [
                        DeliveryTrackingDetailLine(label: l.deliveryAddress, value: _deliveryAddress),
                        if (_deliveryPhone != null)
                          DeliveryTrackingDetailLine(label: 'Phone', value: _deliveryPhone!),
                        if (_deliveryNote != null)
                          DeliveryTrackingDetailLine(label: 'Note', value: _deliveryNote!),
                        DeliveryTrackingDetailLine(
                          label: l.payment,
                          value: _paymentLabel(_order?.paymentMethod),
                        ),
                        DeliveryTrackingDetailLine(label: 'Last Sync', value: _syncLabel),
                      ],
                    ),
                  ),
                  if (_order != null &&
                      (_order!.subtotal != null ||
                          _order!.deliveryFee != null ||
                          _order!.discountAmount != null)) ...[
                    const SizedBox(height: 12),
                    DeliveryTrackingSectionCard(
                      icon: HugeIcons.strokeRoundedInvoice01,
                      title: 'Payment Breakdown',
                      subtitle: 'How the final amount was calculated.',
                      child: Column(
                        children: [
                          DeliveryTrackingPriceLine(
                            label: l.subtotal,
                            value: _order!.subtotal == null
                                ? '--'
                                : money.format(_order!.subtotal),
                          ),
                          DeliveryTrackingPriceLine(
                            label: l.deliveryFee,
                            value: _order!.deliveryFee == null
                                ? '--'
                                : money.format(_order!.deliveryFee),
                          ),
                          DeliveryTrackingPriceLine(
                            label: 'Discount',
                            value: _order!.discountAmount == null
                                ? '--'
                                : '-${money.format(_order!.discountAmount)}',
                            isAccent: true,
                          ),
                          const SizedBox(height: 8),
                          DeliveryTrackingPriceLine(
                            label: l.total,
                            value: totalAmountLabel,
                            isStrong: true,
                          ),
                        ],
                      ),
                    ),
                  ],
                  const SizedBox(height: 12),
                  DeliveryTrackingSectionCard(
                    icon: HugeIcons.strokeRoundedRoute01,
                    title: 'Progress Timeline',
                    subtitle: _isCancelledLike
                        ? 'Delivery ended before completion. Check status history for details.'
                        : 'Current stage is highlighted and updates automatically.',
                    child: _timeline.isEmpty
                        ? const DeliveryTrackingEmptyHint(
                            message:
                                'Timeline will appear after the first delivery update.',
                          )
                        : Column(
                            children: _timeline.asMap().entries.map((entry) {
                              return DeliveryTrackingTimelineStepCard(
                                step: entry.value,
                                isLast: entry.key == _timeline.length - 1,
                                isAlertFlow: _isCancelledLike,
                              );
                            }).toList(),
                          ),
                  ),
                  if (_order?.items.isNotEmpty == true) ...[
                    const SizedBox(height: 12),
                    DeliveryTrackingSectionCard(
                      icon: HugeIcons.strokeRoundedPackage02,
                      title: 'Order Items',
                      subtitle: '$itemCount item(s) in this delivery.',
                      child: Column(
                        children: _order!.items
                            .map(
                              (item) => DeliveryTrackingOrderItemCard(
                                item: item,
                                money: money,
                              ),
                            )
                            .toList(),
                      ),
                    ),
                  ],
                  if (_errorMessage != null) ...[
                    const SizedBox(height: 12),
                    DeliveryTrackingInlineWarning(message: _errorMessage!),
                  ],
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: FilledButton.tonalIcon(
                          onPressed: _isRefreshing ? null : _handleRefresh,
                          icon: const Icon(HugeIcons.strokeRoundedRefresh),
                          label: Text(
                            _isRefreshing ? 'Refreshing...' : 'Refresh Status',
                            style: const TextStyle(fontWeight: FontWeight.w700),
                          ),
                          style: FilledButton.styleFrom(
                            foregroundColor: TrackingUiColors.ink,
                            backgroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                              side: const BorderSide(
                                color: TrackingUiColors.panelBorder,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () => Navigator.of(context).pop(),
                          icon: const Icon(HugeIcons.strokeRoundedArrowLeft01),
                          label: Text(
                            l.back,
                            style: const TextStyle(fontWeight: FontWeight.w700),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: TrackingUiColors.primary,
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

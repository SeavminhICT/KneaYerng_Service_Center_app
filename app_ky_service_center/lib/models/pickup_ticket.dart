class PickupTicketItem {
  const PickupTicketItem({
    required this.name,
    required this.quantity,
    required this.price,
  });

  final String name;
  final int quantity;
  final double price;

  double get lineTotal => price * quantity;

  factory PickupTicketItem.fromJson(Map<String, dynamic> json) {
    return PickupTicketItem(
      name: json['product_name']?.toString() ?? 'Item',
      quantity: _toInt(json['quantity']) ?? 0,
      price: _toDouble(json['price']) ?? 0,
    );
  }
}

class TrackingTimelineStep {
  const TrackingTimelineStep({
    required this.status,
    required this.label,
    this.description,
    this.done = false,
    this.current = false,
    this.upcoming = false,
    this.at,
  });

  final String status;
  final String label;
  final String? description;
  final bool done;
  final bool current;
  final bool upcoming;
  final DateTime? at;

  factory TrackingTimelineStep.fromJson(Map<String, dynamic> json) {
    return TrackingTimelineStep(
      status: json['status']?.toString() ?? '',
      label: json['label']?.toString() ?? '',
      description: json['description']?.toString(),
      done: json['done'] == true,
      current: json['current'] == true,
      upcoming: json['upcoming'] == true,
      at: _toDate(json['at']),
    );
  }
}

class TrackingHistoryEntry {
  const TrackingHistoryEntry({
    required this.id,
    this.fromStatus,
    required this.toStatus,
    this.changedByRole,
    this.changedByUserId,
    this.changedByName,
    this.assignedStaffId,
    this.assignedStaffName,
    this.overrideUsed = false,
    this.note,
    this.createdAt,
  });

  final int id;
  final String? fromStatus;
  final String toStatus;
  final String? changedByRole;
  final int? changedByUserId;
  final String? changedByName;
  final int? assignedStaffId;
  final String? assignedStaffName;
  final bool overrideUsed;
  final String? note;
  final DateTime? createdAt;

  factory TrackingHistoryEntry.fromJson(Map<String, dynamic> json) {
    return TrackingHistoryEntry(
      id: _toInt(json['id']) ?? 0,
      fromStatus: json['from_status']?.toString(),
      toStatus: json['to_status']?.toString() ?? '',
      changedByRole: json['changed_by_role']?.toString(),
      changedByUserId: _toInt(json['changed_by_user_id']),
      changedByName: json['changed_by_name']?.toString(),
      assignedStaffId: _toInt(json['assigned_staff_id']),
      assignedStaffName: json['assigned_staff_name']?.toString(),
      overrideUsed: json['override_used'] == true,
      note: json['note']?.toString(),
      createdAt: _toDate(json['created_at']),
    );
  }
}

class PickupTicket {
  const PickupTicket({
    required this.orderId,
    required this.customerName,
    required this.items,
    this.orderNumber,
    this.customerEmail,
    this.orderType,
    this.paymentMethod,
    this.paymentStatus,
    this.orderStatus,
    this.deliveryAddress,
    this.deliveryPhone,
    this.deliveryNote,
    this.subtotal,
    this.deliveryFee,
    this.discountAmount,
    this.totalAmount,
    this.placedAt,
    this.currentStatusAt,
    this.approvedAt,
    this.rejectedAt,
    this.rejectedReason,
    this.cancelledAt,
    this.cancelledReason,
    this.assignedStaffId,
    this.assignedStaffName,
    this.pickupQrGeneratedAt,
    this.pickupQrExpiresAt,
    this.pickupVerifiedAt,
    this.pickupQrToken,
    this.pickupTicketId,
    this.pickupTicketStatus,
    this.trackingTimeline = const [],
    this.trackingHistory = const [],
  });

  final int orderId;
  final String? orderNumber;
  final String customerName;
  final String? customerEmail;
  final String? orderType;
  final String? paymentMethod;
  final String? paymentStatus;
  final String? orderStatus;
  final String? deliveryAddress;
  final String? deliveryPhone;
  final String? deliveryNote;
  final double? subtotal;
  final double? deliveryFee;
  final double? discountAmount;
  final double? totalAmount;
  final DateTime? placedAt;
  final DateTime? currentStatusAt;
  final DateTime? approvedAt;
  final DateTime? rejectedAt;
  final String? rejectedReason;
  final DateTime? cancelledAt;
  final String? cancelledReason;
  final int? assignedStaffId;
  final String? assignedStaffName;
  final DateTime? pickupQrGeneratedAt;
  final DateTime? pickupQrExpiresAt;
  final DateTime? pickupVerifiedAt;
  final String? pickupQrToken;
  final String? pickupTicketId;
  final String? pickupTicketStatus;
  final List<PickupTicketItem> items;
  final List<TrackingTimelineStep> trackingTimeline;
  final List<TrackingHistoryEntry> trackingHistory;

  bool get isUsed =>
      pickupVerifiedAt != null ||
      (orderStatus ?? '').toLowerCase() == 'completed';

  bool get isExpired {
    final expiresAt = pickupQrExpiresAt;
    if (expiresAt == null) return false;
    return DateTime.now().isAfter(expiresAt);
  }

  bool get isActive => !isUsed && !isExpired;

  bool get isDeliveryOrder => (orderType ?? '').toLowerCase() == 'delivery';

  bool get isTerminalDeliveryStatus {
    switch ((orderStatus ?? '').toLowerCase()) {
      case 'completed':
      case 'cancelled':
      case 'rejected':
        return true;
      default:
        return false;
    }
  }

  String get statusLabel {
    final raw = (orderStatus ?? pickupTicketStatus ?? '').toLowerCase();
    switch (raw) {
      case 'created':
        return 'Created';
      case 'pending_approval':
        return 'Pending Approval';
      case 'approved':
        return 'Approved';
      case 'assigned':
        return 'Assigned';
      case 'in_progress':
        return 'In Progress';
      case 'on_the_way':
        return 'On the Way';
      case 'arrived':
        return 'Arrived';
      case 'completed':
      case 'used':
        return 'Completed';
      case 'cancelled':
        return 'Cancelled';
      case 'rejected':
        return 'Rejected';
      case 'expired':
        return 'Expired';
      case 'active':
        return 'Active';
      default:
        if (isUsed) return 'Completed';
        if (isExpired) return 'Expired';
        return 'Pending';
    }
  }

  factory PickupTicket.fromJson(Map<String, dynamic> json) {
    final rawItems = json['items'];
    final items = rawItems is List
        ? rawItems
              .whereType<Map>()
              .map(
                (item) =>
                    PickupTicketItem.fromJson(Map<String, dynamic>.from(item)),
              )
              .toList()
        : <PickupTicketItem>[];

    final rawTimeline = json['tracking_timeline'];
    final timeline = rawTimeline is List
        ? rawTimeline
              .whereType<Map>()
              .map(
                (item) => TrackingTimelineStep.fromJson(
                  Map<String, dynamic>.from(item),
                ),
              )
              .toList()
        : <TrackingTimelineStep>[];

    final rawHistory = json['tracking_history'];
    final history = rawHistory is List
        ? rawHistory
              .whereType<Map>()
              .map(
                (item) => TrackingHistoryEntry.fromJson(
                  Map<String, dynamic>.from(item),
                ),
              )
              .toList()
        : <TrackingHistoryEntry>[];

    return PickupTicket(
      orderId: _toInt(json['id']) ?? 0,
      orderNumber: json['order_number']?.toString(),
      customerName: json['customer_name']?.toString() ?? 'Customer',
      customerEmail: json['customer_email']?.toString(),
      orderType: json['order_type']?.toString(),
      paymentMethod: json['payment_method']?.toString(),
      paymentStatus: json['payment_status']?.toString(),
      orderStatus:
          json['status']?.toString() ?? json['order_status']?.toString(),
      deliveryAddress: json['delivery_address']?.toString(),
      deliveryPhone: json['delivery_phone']?.toString(),
      deliveryNote: json['delivery_note']?.toString(),
      subtotal: _toDouble(json['subtotal']),
      deliveryFee: _toDouble(json['delivery_fee']),
      discountAmount: _toDouble(json['discount_amount']),
      totalAmount: _toDouble(json['total_amount']),
      placedAt: _toDate(json['placed_at'] ?? json['created_at']),
      currentStatusAt: _toDate(json['current_status_at']),
      approvedAt: _toDate(json['approved_at']),
      rejectedAt: _toDate(json['rejected_at']),
      rejectedReason: json['rejected_reason']?.toString(),
      cancelledAt: _toDate(json['cancelled_at']),
      cancelledReason: json['cancelled_reason']?.toString(),
      assignedStaffId: _toInt(json['assigned_staff_id']),
      assignedStaffName: json['assigned_staff_name']?.toString(),
      pickupQrGeneratedAt: _toDate(json['pickup_qr_generated_at']),
      pickupQrExpiresAt: _toDate(json['pickup_qr_expires_at']),
      pickupVerifiedAt: _toDate(json['pickup_verified_at']),
      pickupQrToken: json['pickup_qr_token']?.toString(),
      pickupTicketId: json['pickup_ticket_id']?.toString(),
      pickupTicketStatus: json['pickup_ticket_status']?.toString(),
      items: items,
      trackingTimeline: timeline,
      trackingHistory: history,
    );
  }
}

int? _toInt(dynamic value) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  return int.tryParse(value?.toString() ?? '');
}

double? _toDouble(dynamic value) {
  if (value is double) return value;
  if (value is num) return value.toDouble();
  return double.tryParse(value?.toString() ?? '');
}

DateTime? _toDate(dynamic value) {
  if (value == null) return null;
  if (value is DateTime) return value;
  final raw = value.toString().trim();
  if (raw.isEmpty) return null;
  try {
    return DateTime.parse(raw).toLocal();
  } catch (_) {
    return null;
  }
}

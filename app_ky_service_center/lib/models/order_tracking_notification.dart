class OrderTrackingNotificationItem {
  const OrderTrackingNotificationItem({
    required this.id,
    this.orderId,
    this.type,
    required this.title,
    this.body,
    this.payload,
    this.readAt,
    this.createdAt,
  });

  final int id;
  final int? orderId;
  final String? type;
  final String title;
  final String? body;
  final Map<String, dynamic>? payload;
  final DateTime? readAt;
  final DateTime? createdAt;

  bool get isUnread => readAt == null;
  String? get deepLink => payload?['deep_link']?.toString();
  String? get imageUrl => payload?['image_url']?.toString();
  String? get displayType => payload?['display_type']?.toString();

  factory OrderTrackingNotificationItem.fromJson(Map<String, dynamic> json) {
    return OrderTrackingNotificationItem(
      id: _toInt(json['id']) ?? 0,
      orderId: _toInt(json['order_id']),
      type: json['type']?.toString(),
      title: json['title']?.toString() ?? 'Notification',
      body: json['body']?.toString(),
      payload: _toMap(json['payload']),
      readAt: _toDate(json['read_at']),
      createdAt: _toDate(json['created_at']),
    );
  }
}

int? _toInt(dynamic value) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  return int.tryParse(value?.toString() ?? '');
}

DateTime? _toDate(dynamic value) {
  if (value == null) return null;
  final raw = value.toString().trim();
  if (raw.isEmpty) return null;
  try {
    return DateTime.parse(raw).toLocal();
  } catch (_) {
    return null;
  }
}

Map<String, dynamic>? _toMap(dynamic value) {
  if (value is Map<String, dynamic>) {
    return value;
  }
  if (value is Map) {
    return value.map(
      (key, entry) => MapEntry(key.toString(), entry),
    );
  }
  return null;
}

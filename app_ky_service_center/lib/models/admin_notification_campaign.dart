class AdminNotificationCampaignItem {
  const AdminNotificationCampaignItem({
    required this.id,
    required this.type,
    required this.title,
    required this.message,
    required this.audience,
    required this.customUserIds,
    required this.action,
    required this.status,
    this.deepLink,
    this.scheduledFor,
    this.createdAt,
    this.summary = const AdminNotificationSummary(),
  });

  final int id;
  final String type;
  final String title;
  final String message;
  final String audience;
  final List<int> customUserIds;
  final String action;
  final String status;
  final String? deepLink;
  final DateTime? scheduledFor;
  final DateTime? createdAt;
  final AdminNotificationSummary summary;

  factory AdminNotificationCampaignItem.fromJson(Map<String, dynamic> json) {
    return AdminNotificationCampaignItem(
      id: _toInt(json['id']) ?? 0,
      type: json['type']?.toString() ?? 'Announcement',
      title: json['title']?.toString() ?? 'Notification',
      message: json['message']?.toString() ?? '',
      audience: json['audience']?.toString() ?? 'all',
      customUserIds: _toIntList(json['custom_user_ids']),
      action: json['action']?.toString() ?? 'send_now',
      status: json['status']?.toString() ?? 'sent',
      deepLink: json['deep_link']?.toString(),
      scheduledFor: _toDate(json['scheduled_for']),
      createdAt: _toDate(json['created_at']),
      summary: AdminNotificationSummary.fromJson(
        _toMap(json['summary']) ?? const <String, dynamic>{},
      ),
    );
  }
}

class AdminNotificationSummary {
  const AdminNotificationSummary({
    this.targetedUsers = 0,
    this.savedNotifications = 0,
    this.deviceTokens = 0,
    this.delivered = 0,
    this.failed = 0,
    this.removedInvalidTokens = 0,
    this.pushDisabled = false,
    this.pushError,
  });

  final int targetedUsers;
  final int savedNotifications;
  final int deviceTokens;
  final int delivered;
  final int failed;
  final int removedInvalidTokens;
  final bool pushDisabled;
  final String? pushError;

  factory AdminNotificationSummary.fromJson(Map<String, dynamic> json) {
    final pushError = json['push_error']?.toString().trim();
    return AdminNotificationSummary(
      targetedUsers:
          _toInt(json['targeted_users']) ??
          _toInt(json['targeted_recipients']) ??
          _toInt(json['saved_notifications']) ??
          0,
      savedNotifications: _toInt(json['saved_notifications']) ?? 0,
      deviceTokens: _toInt(json['device_tokens']) ?? 0,
      delivered: _toInt(json['delivered']) ?? 0,
      failed: _toInt(json['failed']) ?? 0,
      removedInvalidTokens: _toInt(json['removed_invalid_tokens']) ?? 0,
      pushDisabled:
          json['push_disabled'] == true ||
          json['push_disabled'] == 'true' ||
          json['push_disabled'] == 1 ||
          json['push_disabled'] == '1',
      pushError: pushError == null || pushError.isEmpty ? null : pushError,
    );
  }
}

class AdminNotificationRecipient {
  const AdminNotificationRecipient({
    required this.id,
    required this.name,
    this.email,
    this.phone,
    this.ordersCount = 0,
    this.ordersTotal = 0,
    this.lastActiveAt,
    this.segments = const <String, bool>{},
  });

  final int id;
  final String name;
  final String? email;
  final String? phone;
  final int ordersCount;
  final double ordersTotal;
  final DateTime? lastActiveAt;
  final Map<String, bool> segments;

  factory AdminNotificationRecipient.fromJson(Map<String, dynamic> json) {
    final rawSegments = _toMap(json['segments']) ?? const <String, dynamic>{};
    return AdminNotificationRecipient(
      id: _toInt(json['id']) ?? 0,
      name: json['name']?.toString() ?? 'User',
      email: json['email']?.toString(),
      phone: json['phone']?.toString(),
      ordersCount: _toInt(json['orders_count']) ?? 0,
      ordersTotal: _toDouble(json['orders_total']) ?? 0,
      lastActiveAt: _toDate(json['last_active_at']),
      segments: rawSegments.map(
        (key, value) => MapEntry(key, value == true || value == 'true'),
      ),
    );
  }
}

class AdminNotificationSendResult {
  const AdminNotificationSendResult({
    required this.success,
    required this.message,
    this.summary = const AdminNotificationSummary(),
    this.historyItem,
    this.validationErrors = const <String, List<String>>{},
  });

  final bool success;
  final String message;
  final AdminNotificationSummary summary;
  final AdminNotificationCampaignItem? historyItem;
  final Map<String, List<String>> validationErrors;
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
  final raw = value.toString().trim();
  if (raw.isEmpty) return null;
  try {
    return DateTime.parse(raw).toLocal();
  } catch (_) {
    return null;
  }
}

Map<String, dynamic>? _toMap(dynamic value) {
  if (value is Map<String, dynamic>) return value;
  if (value is Map) {
    return value.map((key, entry) => MapEntry(key.toString(), entry));
  }
  return null;
}

List<int> _toIntList(dynamic value) {
  if (value is! List) return const [];
  final ids = <int>{};
  for (final item in value) {
    final parsed = _toInt(item);
    if (parsed != null && parsed > 0) {
      ids.add(parsed);
    }
  }
  return ids.toList(growable: false);
}

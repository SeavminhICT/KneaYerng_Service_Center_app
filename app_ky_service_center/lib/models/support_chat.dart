class SupportChatParticipant {
  const SupportChatParticipant({
    required this.id,
    required this.name,
    this.email,
    this.phone,
    this.role,
  });

  final int id;
  final String name;
  final String? email;
  final String? phone;
  final String? role;

  factory SupportChatParticipant.fromJson(Map<String, dynamic> json) {
    return SupportChatParticipant(
      id: _toInt(json['id']),
      name: (json['name'] ?? '').toString(),
      email: json['email']?.toString(),
      phone: json['phone']?.toString(),
      role: json['role']?.toString(),
    );
  }
}

class SupportChatMessage {
  const SupportChatMessage({
    required this.id,
    required this.conversationId,
    this.senderUserId,
    required this.senderType,
    required this.messageType,
    this.body,
    this.mediaUrl,
    this.mediaDurationSec,
    required this.deliveryStatus,
    this.seenAt,
    this.createdAt,
  });

  final int id;
  final int conversationId;
  final int? senderUserId;
  final String senderType;
  final String messageType;
  final String? body;
  final String? mediaUrl;
  final int? mediaDurationSec;
  final String deliveryStatus;
  final DateTime? seenAt;
  final DateTime? createdAt;

  bool get isCustomer => senderType == 'customer';
  bool get isSupport => senderType == 'support';
  bool get isVoice => messageType == 'voice';
  bool get hasText => (body ?? '').trim().isNotEmpty;

  factory SupportChatMessage.fromJson(Map<String, dynamic> json) {
    return SupportChatMessage(
      id: _toInt(json['id']),
      conversationId: _toInt(json['conversation_id']),
      senderUserId: _toIntOrNull(json['sender_user_id']),
      senderType: (json['sender_type'] ?? 'support').toString(),
      messageType: (json['message_type'] ?? 'text').toString(),
      body: json['body']?.toString(),
      mediaUrl: json['media_url']?.toString(),
      mediaDurationSec: _toIntOrNull(json['media_duration_sec']),
      deliveryStatus: (json['delivery_status'] ?? 'sent').toString(),
      seenAt: _parseDate(json['seen_at']),
      createdAt: _parseDate(json['created_at']),
    );
  }
}

class SupportConversation {
  const SupportConversation({
    required this.id,
    required this.customerId,
    this.assignedTo,
    required this.status,
    this.contextType,
    this.contextId,
    this.subject,
    this.lastMessageAt,
    this.customerLastReadAt,
    this.supportLastReadAt,
    this.resolvedAt,
    this.unreadForCustomer = 0,
    this.unreadForSupport = 0,
    this.customer,
    this.assignee,
    this.messages = const [],
  });

  final int id;
  final int customerId;
  final int? assignedTo;
  final String status;
  final String? contextType;
  final int? contextId;
  final String? subject;
  final DateTime? lastMessageAt;
  final DateTime? customerLastReadAt;
  final DateTime? supportLastReadAt;
  final DateTime? resolvedAt;
  final int unreadForCustomer;
  final int unreadForSupport;
  final SupportChatParticipant? customer;
  final SupportChatParticipant? assignee;
  final List<SupportChatMessage> messages;

  bool get hasMessages => messages.isNotEmpty;

  factory SupportConversation.fromJson(Map<String, dynamic> json) {
    final rawMessages = json['messages'];
    return SupportConversation(
      id: _toInt(json['id']),
      customerId: _toInt(json['customer_id']),
      assignedTo: _toIntOrNull(json['assigned_to']),
      status: (json['status'] ?? 'open').toString(),
      contextType: json['context_type']?.toString(),
      contextId: _toIntOrNull(json['context_id']),
      subject: json['subject']?.toString(),
      lastMessageAt: _parseDate(json['last_message_at']),
      customerLastReadAt: _parseDate(json['customer_last_read_at']),
      supportLastReadAt: _parseDate(json['support_last_read_at']),
      resolvedAt: _parseDate(json['resolved_at']),
      unreadForCustomer: _toInt(json['unread_for_customer']),
      unreadForSupport: _toInt(json['unread_for_support']),
      customer: json['customer'] is Map
          ? SupportChatParticipant.fromJson(
              Map<String, dynamic>.from(json['customer']),
            )
          : null,
      assignee: json['assignee'] is Map
          ? SupportChatParticipant.fromJson(
              Map<String, dynamic>.from(json['assignee']),
            )
          : null,
      messages: rawMessages is List
          ? rawMessages
                .whereType<Map>()
                .map(
                  (item) => SupportChatMessage.fromJson(
                    Map<String, dynamic>.from(item),
                  ),
                )
                .toList()
          : const [],
    );
  }
}

int _toInt(dynamic value) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  return int.tryParse(value?.toString() ?? '') ?? 0;
}

int? _toIntOrNull(dynamic value) {
  if (value == null) return null;
  if (value is int) return value;
  if (value is num) return value.toInt();
  return int.tryParse(value.toString());
}

DateTime? _parseDate(dynamic value) {
  if (value == null) return null;
  if (value is DateTime) return value;
  return DateTime.tryParse(value.toString());
}

import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';

/// Notification category used to drive icon/color/label presentation.
enum NotificationCategory {
  announcement,
  alert,
  document,
  order,
  message,
  update,
}

enum NotificationTab { all, unread }

enum NotificationFilter { all, alerts, orders, documents, messages, updates }

/// Lightweight view model for a single notification row/detail.
class NotificationItem {
  const NotificationItem({
    required this.id,
    this.notificationId,
    required this.category,
    required this.title,
    required this.preview,
    required this.message,
    required this.timestamp,
    required this.isUnread,
    this.actionLabel,
    this.deepLink,
  });

  final String id;
  final int? notificationId;
  final NotificationCategory category;
  final String title;
  final String preview;
  final String message;
  final DateTime timestamp;
  final bool isUnread;
  final String? actionLabel;
  final String? deepLink;

  NotificationItem copyWith({bool? isUnread}) {
    return NotificationItem(
      id: id,
      notificationId: notificationId,
      category: category,
      title: title,
      preview: preview,
      message: message,
      timestamp: timestamp,
      isUnread: isUnread ?? this.isUnread,
      actionLabel: actionLabel,
      deepLink: deepLink,
    );
  }
}

String formatNotificationTimestamp(DateTime timestamp) {
  final difference = DateTime.now().difference(timestamp);
  if (difference.inMinutes < 1) return 'Just now';
  if (difference.inMinutes < 60) return '${difference.inMinutes} min ago';
  if (difference.inHours < 24) return '${difference.inHours} hr ago';
  if (difference.inDays < 7) return '${difference.inDays} day ago';
  return '${_monthShort(timestamp.month)} ${timestamp.day}';
}

String _monthShort(int month) {
  const months = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];
  return months[month - 1];
}

String filterLabel(NotificationFilter filter) {
  return switch (filter) {
    NotificationFilter.all => 'All types',
    NotificationFilter.alerts => 'Alerts',
    NotificationFilter.orders => 'Orders',
    NotificationFilter.documents => 'Documents',
    NotificationFilter.messages => 'Messages',
    NotificationFilter.updates => 'Updates',
  };
}

String categoryLabel(NotificationCategory category) {
  return switch (category) {
    NotificationCategory.announcement => 'Announcement',
    NotificationCategory.alert => 'Alert',
    NotificationCategory.document => 'Document',
    NotificationCategory.order => 'Order',
    NotificationCategory.message => 'Message',
    NotificationCategory.update => 'Update',
  };
}

IconData categoryIcon(NotificationCategory category) {
  return switch (category) {
    NotificationCategory.announcement => HugeIcons.strokeRoundedMegaphone01,
    NotificationCategory.alert => HugeIcons.strokeRoundedAlert02,
    NotificationCategory.document => HugeIcons.strokeRoundedFile01,
    NotificationCategory.order => HugeIcons.strokeRoundedDeliveryTruck01,
    NotificationCategory.message => HugeIcons.strokeRoundedMessage01,
    NotificationCategory.update => HugeIcons.strokeRoundedSystemUpdate01,
  };
}

Color categoryColor(NotificationCategory category) {
  return switch (category) {
    NotificationCategory.announcement => const Color(0xFF4A88F7),
    NotificationCategory.alert => const Color(0xFFF97316),
    NotificationCategory.document => const Color(0xFF0F766E),
    NotificationCategory.order => const Color(0xFF2563EB),
    NotificationCategory.message => const Color(0xFF7C3AED),
    NotificationCategory.update => const Color(0xFF0891B2),
  };
}

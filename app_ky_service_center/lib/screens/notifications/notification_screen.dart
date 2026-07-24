import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:skeletonizer/skeletonizer.dart';

import '../../l10n/app_localizations.dart';
import '../../models/order_tracking_notification.dart';
import '../../services/api_service.dart';
import '../../services/app_notification_service.dart';
import '../orders/delivery_tracking_screen.dart';
import 'widgets/notification_card.dart';
import 'widgets/notification_detail_screen.dart';
import 'widgets/notification_empty_state.dart';
import 'widgets/notification_filter_sheet.dart';
import 'widgets/notification_icon_button.dart';
import 'widgets/notification_item.dart';
import 'widgets/notification_round_icon_button.dart';
import 'widgets/notification_swipe_action_sheet.dart';
import 'widgets/notification_swipe_background.dart';
import 'widgets/notification_tab_chip.dart';
import 'widgets/notification_tone.dart';

export 'widgets/notification_item.dart'
    show NotificationCategory, NotificationTab, NotificationFilter;

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  List<NotificationItem> _items = const [];
  NotificationTab _activeTab = NotificationTab.all;
  NotificationFilter _activeFilter = NotificationFilter.all;
  bool _isRefreshing = false;
  bool _isLoading = true;
  late final VoidCallback _inboxRevisionListener;

  @override
  void initState() {
    super.initState();
    _inboxRevisionListener = _handleInboxRevisionChanged;
    AppNotificationService.instance.inboxRevision.addListener(
      _inboxRevisionListener,
    );
    _loadNotifications();
  }

  @override
  void dispose() {
    AppNotificationService.instance.inboxRevision.removeListener(
      _inboxRevisionListener,
    );
    super.dispose();
  }

  List<NotificationItem> get _visibleItems {
    return _items.where((item) {
      final matchesTab = _activeTab == NotificationTab.all
          ? true
          : item.isUnread;
      final matchesFilter = switch (_activeFilter) {
        NotificationFilter.all => true,
        NotificationFilter.alerts =>
          item.category == NotificationCategory.alert,
        NotificationFilter.orders =>
          item.category == NotificationCategory.order,
        NotificationFilter.documents =>
          item.category == NotificationCategory.document,
        NotificationFilter.messages =>
          item.category == NotificationCategory.message,
        NotificationFilter.updates =>
          item.category == NotificationCategory.update ||
              item.category == NotificationCategory.announcement,
      };
      return matchesTab && matchesFilter;
    }).toList();
  }

  int get _unreadCount => _items.where((item) => item.isUnread).length;

  void _handleInboxRevisionChanged() {
    if (!mounted || _isLoading || _isRefreshing) return;
    _loadNotifications(showLoader: false);
  }

  Future<void> _refresh() async {
    if (_isRefreshing) return;
    setState(() => _isRefreshing = true);
    await _loadNotifications(showLoader: false);
  }

  void _markAsRead(String id, {int? notificationId}) {
    if (notificationId != null) {
      ApiService.markOrderTrackingNotificationRead(notificationId);
    }
    setState(() {
      _items = _items
          .map((item) => item.id == id ? item.copyWith(isUnread: false) : item)
          .toList();
    });
    AppNotificationService.instance.reportUnreadCount(_unreadCount);
  }

  void _deleteNotification(String id) {
    setState(() {
      _items = _items.where((item) => item.id != id).toList();
    });
    AppNotificationService.instance.reportUnreadCount(_unreadCount);
  }

  Future<void> _openFilterSheet() async {
    final selected = await showModalBottomSheet<NotificationFilter>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => NotificationFilterSheet(selected: _activeFilter),
    );
    if (selected == null || !mounted) return;
    setState(() => _activeFilter = selected);
  }

  Future<void> _openDetail(NotificationItem item) async {
    if (item.isUnread) {
      _markAsRead(item.id, notificationId: item.notificationId);
      item = item.copyWith(isUnread: false);
    }

    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => NotificationDetailScreen(
          item: item,
          onActionTap: () => _handlePrimaryAction(item),
        ),
      ),
    );
  }

  Future<bool> _handleSwipeAction(NotificationItem item) async {
    final action = await showModalBottomSheet<NotificationSwipeAction>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => NotificationSwipeActionSheet(item: item),
    );

    if (!mounted || action == null) return false;

    switch (action) {
      case NotificationSwipeAction.markRead:
        _markAsRead(item.id, notificationId: item.notificationId);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Notification marked as read.')),
        );
        return false;
      case NotificationSwipeAction.delete:
        _deleteNotification(item.id);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Notification deleted.')));
        return false;
    }
  }

  void _handlePrimaryAction(NotificationItem item) {
    final label = item.actionLabel;
    if (label == null) return;

    final deepLink = item.deepLink ?? '';
    if (deepLink.startsWith('/orders/')) {
      final id = int.tryParse(deepLink.split('/').last);
      if (id != null) {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => DeliveryTrackingScreen(orderId: id),
          ),
        );
        return;
      }
    }

    if (deepLink.isNotEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Open this link from the app: $deepLink')),
      );
      return;
    }

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('$label tapped for ${item.title}')));
  }

  Future<void> _loadNotifications({bool showLoader = true}) async {
    if (showLoader) {
      setState(() => _isLoading = true);
    }

    final notifications = await ApiService.fetchOrderTrackingNotifications();
    if (!mounted) return;

    setState(() {
      _items = notifications.map(_mapOrderNotification).toList();
      _isLoading = false;
      _isRefreshing = false;
    });
    AppNotificationService.instance.reportUnreadCount(_unreadCount);
  }

  NotificationItem _mapOrderNotification(OrderTrackingNotificationItem item) {
    final category = _categoryFromNotification(item);
    final body = item.body?.trim();
    final deepLink = item.deepLink?.trim().isNotEmpty == true
        ? item.deepLink!.trim()
        : (item.orderId == null ? null : '/orders/${item.orderId}');
    final preview = (body != null && body.isNotEmpty)
        ? body
        : _defaultMessageForCategory(category);

    return NotificationItem(
      id: 'order-${item.id}',
      notificationId: item.id,
      category: category,
      title: item.title,
      preview: preview,
      message: preview,
      timestamp: item.createdAt ?? DateTime.now(),
      isUnread: item.isUnread,
      actionLabel: _actionLabelForDeepLink(deepLink),
      deepLink: deepLink,
    );
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final visibleItems = _visibleItems;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: RefreshIndicator(
          color: notificationPrimary,
          onRefresh: _refresh,
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(
              parent: BouncingScrollPhysics(),
            ),
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          NotificationIconBtn(
                            icon: HugeIcons.strokeRoundedArrowLeft01,
                            onTap: () => Navigator.of(context).maybePop(),
                            circular: true,
                            iconSize: 18,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  l.notifications,
                                  style: const TextStyle(
                                    fontSize: 28,
                                    fontWeight: FontWeight.w800,
                                    color: notificationTextPrimary,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  _unreadCount > 0
                                      ? '$_unreadCount unread updates waiting'
                                      : 'All caught up',
                                  style: const TextStyle(
                                    fontSize: 13,
                                    color: notificationTextMuted,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          NotificationRoundIconButton(
                            icon: HugeIcons.strokeRoundedSetting07,
                            onTap: _openFilterSheet,
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: NotificationTabChip(
                              label: 'All',
                              count: _items.length,
                              selected: _activeTab == NotificationTab.all,
                              onTap: () {
                                setState(
                                  () => _activeTab = NotificationTab.all,
                                );
                              },
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: NotificationTabChip(
                              label: 'Unread',
                              count: _unreadCount,
                              selected: _activeTab == NotificationTab.unread,
                              onTap: () {
                                setState(
                                  () => _activeTab = NotificationTab.unread,
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          color: notificationSurface,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: notificationBorder),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              HugeIcons.strokeRoundedFilter,
                              size: 18,
                              color: notificationPrimary,
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                '${l.filter}: ${filterLabel(_activeFilter)}',
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: notificationTextPrimary,
                                ),
                              ),
                            ),
                            if (_isRefreshing)
                              const SizedBox(
                                height: 16,
                                width: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    notificationPrimary,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              if (_isLoading)
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
                  sliver: Skeletonizer.sliver(
                    enabled: true,
                    child: SliverList.separated(
                      itemBuilder: (context, index) {
                        return NotificationCard(
                          item: NotificationItem(
                            id: 'skeleton-$index',
                            category: NotificationCategory.order,
                            title: 'Loading Notification Title',
                            preview: 'Loading Notification Preview Text',
                            message: 'Loading Notification Message',
                            timestamp: DateTime.now(),
                            isUnread: false,
                          ),
                          onTap: () {},
                        );
                      },
                      separatorBuilder: (_, _) => const SizedBox(height: 12),
                      itemCount: 5,
                    ),
                  ),
                )
              else if (visibleItems.isEmpty)
                const SliverFillRemaining(
                  hasScrollBody: false,
                  child: NotificationEmptyState(),
                )
              else
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
                  sliver: SliverList.separated(
                    itemBuilder: (context, index) {
                      final item = visibleItems[index];
                      return Dismissible(
                        key: ValueKey(item.id),
                        direction: DismissDirection.endToStart,
                        confirmDismiss: (_) => _handleSwipeAction(item),
                        background: const NotificationSwipeBackground(),
                        child: NotificationCard(
                          item: item,
                          onTap: () => _openDetail(item),
                        ),
                      );
                    },
                    separatorBuilder: (_, _) => const SizedBox(height: 12),
                    itemCount: visibleItems.length,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

NotificationCategory _categoryFromNotification(
  OrderTrackingNotificationItem item,
) {
  final displayType = (item.displayType ?? '').trim().toLowerCase();
  final storedType = (item.type ?? '').trim().toLowerCase();
  final rawType = '$displayType $storedType'.trim();
  if (rawType.contains('alert')) {
    return NotificationCategory.alert;
  }
  if (rawType.contains('document')) {
    return NotificationCategory.document;
  }
  if (rawType.contains('message')) {
    return NotificationCategory.message;
  }
  if (rawType.contains('order')) {
    return NotificationCategory.order;
  }
  if (storedType.contains('admin_')) {
    return NotificationCategory.alert;
  }
  if (rawType.contains('promotion')) {
    return NotificationCategory.announcement;
  }
  if (rawType.contains('announcement')) {
    return NotificationCategory.announcement;
  }
  if (rawType.contains('reminder') || rawType == 'info') {
    return NotificationCategory.update;
  }
  return NotificationCategory.update;
}

String _defaultMessageForCategory(NotificationCategory category) {
  return switch (category) {
    NotificationCategory.announcement =>
      'A new announcement is available for your account.',
    NotificationCategory.alert => 'An important alert needs your attention.',
    NotificationCategory.document =>
      'A new document update is available for review.',
    NotificationCategory.order => 'Your order tracking status was updated.',
    NotificationCategory.message => 'You have a new message.',
    NotificationCategory.update => 'There is a new update for your account.',
  };
}

String? _actionLabelForDeepLink(String? deepLink) {
  final normalized = deepLink?.trim() ?? '';
  if (normalized.isEmpty) {
    return null;
  }
  if (normalized.startsWith('/orders/')) {
    return 'Track Order';
  }
  return 'View Details';
}

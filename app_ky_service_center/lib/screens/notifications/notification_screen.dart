import 'package:flutter/material.dart';

import '../../models/order_tracking_notification.dart';
import '../../services/api_service.dart';
import '../orders/delivery_tracking_screen.dart';

const Color _primary = Color(0xFF4A88F7);
const Color _background = Color(0xFFF5F7FB);
const Color _surface = Colors.white;
const Color _border = Color(0xFFE4EAF4);
const Color _textPrimary = Color(0xFF111827);
const Color _textMuted = Color(0xFF6B7280);
const Color _shadow = Color(0x120F172A);

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

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  List<_NotificationItem> _items = const [];
  NotificationTab _activeTab = NotificationTab.all;
  NotificationFilter _activeFilter = NotificationFilter.all;
  bool _isRefreshing = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadNotifications();
  }

  List<_NotificationItem> get _visibleItems {
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
  }

  void _deleteNotification(String id) {
    setState(() {
      _items = _items.where((item) => item.id != id).toList();
    });
  }

  Future<void> _openFilterSheet() async {
    final selected = await showModalBottomSheet<NotificationFilter>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => _FilterSheet(selected: _activeFilter),
    );
    if (selected == null || !mounted) return;
    setState(() => _activeFilter = selected);
  }

  Future<void> _openDetail(_NotificationItem item) async {
    if (item.isUnread) {
      _markAsRead(item.id, notificationId: item.notificationId);
      item = item.copyWith(isUnread: false);
    }

    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => _NotificationDetailScreen(
          item: item,
          onActionTap: () => _handlePrimaryAction(item),
        ),
      ),
    );
  }

  Future<bool> _handleSwipeAction(_NotificationItem item) async {
    final action = await showModalBottomSheet<_SwipeAction>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => _SwipeActionSheet(item: item),
    );

    if (!mounted || action == null) return false;

    switch (action) {
      case _SwipeAction.markRead:
        _markAsRead(item.id, notificationId: item.notificationId);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Notification marked as read.')),
        );
        return false;
      case _SwipeAction.delete:
        _deleteNotification(item.id);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Notification deleted.')));
        return false;
    }
  }

  void _handlePrimaryAction(_NotificationItem item) {
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
  }

  _NotificationItem _mapOrderNotification(OrderTrackingNotificationItem item) {
    final category = _categoryFromNotification(item);
    final body = item.body?.trim();
    final deepLink =
        item.deepLink?.trim().isNotEmpty == true
            ? item.deepLink!.trim()
            : (item.orderId == null ? null : '/orders/${item.orderId}');
    final preview = (body != null && body.isNotEmpty)
        ? body
        : _defaultMessageForCategory(category);

    return _NotificationItem(
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
    final visibleItems = _visibleItems;

    return Scaffold(
      backgroundColor: _background,
      body: SafeArea(
        child: RefreshIndicator(
          color: _primary,
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
                          _IconBtn(
                            icon: Icons.arrow_back_ios_new_rounded,
                            onTap: () => Navigator.of(context).maybePop(),
                            circular: true,
                            iconSize: 18,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Notifications',
                                  style: TextStyle(
                                    fontSize: 28,
                                    fontWeight: FontWeight.w800,
                                    color: _textPrimary,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  _unreadCount > 0
                                      ? '$_unreadCount unread updates waiting'
                                      : 'All caught up',
                                  style: const TextStyle(
                                    fontSize: 13,
                                    color: _textMuted,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          _RoundIconButton(
                            icon: Icons.tune_rounded,
                            onTap: _openFilterSheet,
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: _TabChip(
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
                            child: _TabChip(
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
                          color: _surface,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: _border),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.filter_list_rounded,
                              size: 18,
                              color: _primary,
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                'Filter: ${_filterLabel(_activeFilter)}',
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: _textPrimary,
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
                                    _primary,
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
                const SliverFillRemaining(
                  hasScrollBody: false,
                  child: Center(child: CircularProgressIndicator()),
                )
              else if (visibleItems.isEmpty)
                const SliverFillRemaining(
                  hasScrollBody: false,
                  child: _EmptyState(),
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
                        background: const _SwipeBackground(),
                        child: _NotificationCard(
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

class _NotificationDetailScreen extends StatelessWidget {
  const _NotificationDetailScreen({required this.item, this.onActionTap});

  final _NotificationItem item;
  final VoidCallback? onActionTap;

  @override
  Widget build(BuildContext context) {
    final accent = _categoryColor(item.category);
    final icon = _categoryIcon(item.category);

    return Scaffold(
      backgroundColor: _background,
      appBar: AppBar(
        backgroundColor: _surface,
        elevation: 0,
        scrolledUnderElevation: 0,
        foregroundColor: _textPrimary,
        titleSpacing: 0,
        title: const Text(
          'Notification',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: _textPrimary,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 12),
            Container(
              width: 104,
              height: 104,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    accent.withValues(alpha: 0.14),
                    accent.withValues(alpha: 0.28),
                  ],
                ),
                boxShadow: [
                  BoxShadow(
                    color: accent.withValues(alpha: 0.18),
                    blurRadius: 28,
                    offset: const Offset(0, 16),
                  ),
                ],
              ),
              child: Icon(icon, color: accent, size: 42),
            ),
            const SizedBox(height: 28),
            Text(
              item.title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w800,
                color: _textPrimary,
                height: 1.2,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              '${_categoryLabel(item.category)} • ${_formatTimestamp(item.timestamp)}',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: _textMuted,
              ),
            ),
            const SizedBox(height: 24),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: _surface,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: _border),
                boxShadow: const [
                  BoxShadow(
                    color: _shadow,
                    blurRadius: 18,
                    offset: Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.message,
                    style: const TextStyle(
                      fontSize: 15,
                      height: 1.6,
                      color: _textPrimary,
                    ),
                  ),
                  if (item.deepLink != null) ...[
                    const SizedBox(height: 18),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF7F9FD),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: _border),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(
                            Icons.link_rounded,
                            size: 18,
                            color: _primary,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              item.deepLink!,
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: _textPrimary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
            if (item.actionLabel != null) ...[
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: onActionTap,
                  style: FilledButton.styleFrom(
                    backgroundColor: _primary,
                    foregroundColor: Colors.white,
                    minimumSize: const Size.fromHeight(54),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: Text(
                    item.actionLabel!,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _NotificationCard extends StatelessWidget {
  const _NotificationCard({required this.item, required this.onTap});

  final _NotificationItem item;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final accent = _categoryColor(item.category);
    final icon = _categoryIcon(item.category);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Ink(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: _surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: _border),
            boxShadow: const [
              BoxShadow(color: _shadow, blurRadius: 16, offset: Offset(0, 10)),
            ],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                height: 48,
                width: 48,
                decoration: BoxDecoration(
                  color: accent.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(icon, color: accent, size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            item.title,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: _textPrimary,
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Text(
                          _formatTimestamp(item.timestamp),
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: _textMuted,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      item.preview,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 13,
                        height: 1.5,
                        color: _textMuted,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 5,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF1F5FD),
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Text(
                            _categoryLabel(item.category),
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: accent,
                            ),
                          ),
                        ),
                        const Spacer(),
                        if (item.isUnread)
                          Container(
                            width: 10,
                            height: 10,
                            decoration: const BoxDecoration(
                              color: _primary,
                              shape: BoxShape.circle,
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TabChip extends StatelessWidget {
  const _TabChip({
    required this.label,
    required this.count,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final int count;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Ink(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          decoration: BoxDecoration(
            color: selected ? _primary : _surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: selected ? _primary : _border),
            boxShadow: selected
                ? const [
                    BoxShadow(
                      color: Color(0x224A88F7),
                      blurRadius: 18,
                      offset: Offset(0, 10),
                    ),
                  ]
                : const [],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: selected ? Colors.white : _textPrimary,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: selected
                      ? Colors.white.withValues(alpha: 0.18)
                      : const Color(0xFFEFF4FF),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  '$count',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: selected ? Colors.white : _primary,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RoundIconButton extends StatelessWidget {
  const _RoundIconButton({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Ink(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: _surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: _border),
            boxShadow: const [
              BoxShadow(color: _shadow, blurRadius: 14, offset: Offset(0, 8)),
            ],
          ),
          child: Icon(icon, size: 20, color: _textPrimary),
        ),
      ),
    );
  }
}

class _IconBtn extends StatelessWidget {
  const _IconBtn({
    required this.icon,
    required this.onTap,
    this.circular = false,
    this.iconSize = 20,
  });

  final IconData icon;
  final VoidCallback onTap;
  final bool circular;
  final double iconSize;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(circular ? 999 : 16),
      child: Container(
        width: circular ? 42 : 44,
        height: circular ? 42 : 44,
        decoration: BoxDecoration(
          color: Colors.white,
          shape: circular ? BoxShape.circle : BoxShape.rectangle,
          borderRadius: circular ? null : BorderRadius.circular(18),
          border: Border.all(color: _border),
          boxShadow: [
            BoxShadow(
              color: circular ? _shadow.withAlpha(14) : _shadow,
              blurRadius: circular ? 6 : 10,
              offset: Offset(0, circular ? 2 : 4),
            ),
          ],
        ),
        child: Icon(icon, size: iconSize, color: _textPrimary),
      ),
    );
  }
}

class _SwipeBackground extends StatelessWidget {
  const _SwipeBackground();

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.centerRight,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: const LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [Color(0xFFEAF1FF), Color(0xFFFEE2E2)],
        ),
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.mark_email_read_rounded, color: _primary, size: 20),
          SizedBox(width: 10),
          Icon(
            Icons.delete_outline_rounded,
            color: Color(0xFFDC2626),
            size: 20,
          ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 84,
              height: 84,
              decoration: BoxDecoration(
                color: const Color(0xFFEAF1FF),
                borderRadius: BorderRadius.circular(28),
              ),
              child: const Icon(
                Icons.notifications_off_outlined,
                size: 38,
                color: _primary,
              ),
            ),
            const SizedBox(height: 18),
            const Text(
              'No notifications found',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: _textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Try switching filters or pull to refresh to sync the latest updates.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, color: _textMuted, height: 1.5),
            ),
          ],
        ),
      ),
    );
  }
}

class _FilterSheet extends StatelessWidget {
  const _FilterSheet({required this.selected});

  final NotificationFilter selected;

  @override
  Widget build(BuildContext context) {
    final filters = NotificationFilter.values;
    return SafeArea(
      top: false,
      child: Container(
        decoration: const BoxDecoration(
          color: _surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        padding: const EdgeInsets.fromLTRB(20, 18, 20, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 46,
                height: 5,
                decoration: BoxDecoration(
                  color: const Color(0xFFD6DCE8),
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
            ),
            const SizedBox(height: 18),
            const Text(
              'Filter notifications',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: _textPrimary,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'Choose which notification types should appear in the list.',
              style: TextStyle(fontSize: 13, color: _textMuted),
            ),
            const SizedBox(height: 18),
            ...filters.map((filter) {
              final isSelected = filter == selected;
              return Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(16),
                    onTap: () => Navigator.of(context).pop(filter),
                    child: Ink(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 14,
                      ),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? const Color(0xFFEFF4FF)
                            : const Color(0xFFF8FAFD),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isSelected ? _primary : _border,
                        ),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              _filterLabel(filter),
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: isSelected ? _primary : _textPrimary,
                              ),
                            ),
                          ),
                          if (isSelected)
                            const Icon(
                              Icons.check_circle_rounded,
                              color: _primary,
                              size: 20,
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}

enum _SwipeAction { markRead, delete }

class _SwipeActionSheet extends StatelessWidget {
  const _SwipeActionSheet({required this.item});

  final _NotificationItem item;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Container(
        decoration: const BoxDecoration(
          color: _surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        padding: const EdgeInsets.fromLTRB(20, 18, 20, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 46,
                height: 5,
                decoration: BoxDecoration(
                  color: const Color(0xFFD6DCE8),
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
            ),
            const SizedBox(height: 18),
            Text(
              item.title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: _textPrimary,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'Choose what to do with this notification.',
              style: TextStyle(fontSize: 13, color: _textMuted),
            ),
            const SizedBox(height: 20),
            _ActionTile(
              icon: Icons.mark_email_read_rounded,
              iconColor: _primary,
              title: 'Mark as read',
              subtitle: 'Keep it in the list and remove the unread badge.',
              onTap: () => Navigator.of(context).pop(_SwipeAction.markRead),
            ),
            const SizedBox(height: 10),
            _ActionTile(
              icon: Icons.delete_outline_rounded,
              iconColor: const Color(0xFFDC2626),
              title: 'Delete notification',
              subtitle: 'Remove it from the inbox permanently.',
              onTap: () => Navigator.of(context).pop(_SwipeAction.delete),
            ),
          ],
        ),
      ),
    );
  }
}

class _ActionTile extends StatelessWidget {
  const _ActionTile({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: Ink(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: const Color(0xFFF8FAFD),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: _border),
          ),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: iconColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(icon, color: iconColor, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: _textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        fontSize: 12,
                        height: 1.5,
                        color: _textMuted,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.arrow_forward_ios_rounded,
                size: 14,
                color: _textMuted,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NotificationItem {
  const _NotificationItem({
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

  _NotificationItem copyWith({bool? isUnread}) {
    return _NotificationItem(
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

NotificationCategory _categoryFromNotification(
  OrderTrackingNotificationItem item,
) {
  final rawType = (item.displayType ?? item.type ?? '').trim().toLowerCase();
  if (rawType.contains('alert')) {
    return NotificationCategory.alert;
  }
  if (rawType.contains('document')) {
    return NotificationCategory.document;
  }
  if (rawType.contains('message')) {
    return NotificationCategory.message;
  }
  if (rawType.contains('announcement')) {
    return NotificationCategory.announcement;
  }
  if (rawType.contains('order')) {
    return NotificationCategory.order;
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

String _formatTimestamp(DateTime timestamp) {
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

String _filterLabel(NotificationFilter filter) {
  return switch (filter) {
    NotificationFilter.all => 'All types',
    NotificationFilter.alerts => 'Alerts',
    NotificationFilter.orders => 'Orders',
    NotificationFilter.documents => 'Documents',
    NotificationFilter.messages => 'Messages',
    NotificationFilter.updates => 'Updates',
  };
}

String _categoryLabel(NotificationCategory category) {
  return switch (category) {
    NotificationCategory.announcement => 'Announcement',
    NotificationCategory.alert => 'Alert',
    NotificationCategory.document => 'Document',
    NotificationCategory.order => 'Order',
    NotificationCategory.message => 'Message',
    NotificationCategory.update => 'Update',
  };
}

IconData _categoryIcon(NotificationCategory category) {
  return switch (category) {
    NotificationCategory.announcement => Icons.campaign_rounded,
    NotificationCategory.alert => Icons.warning_amber_rounded,
    NotificationCategory.document => Icons.description_rounded,
    NotificationCategory.order => Icons.local_shipping_rounded,
    NotificationCategory.message => Icons.chat_bubble_outline_rounded,
    NotificationCategory.update => Icons.system_update_alt_rounded,
  };
}

Color _categoryColor(NotificationCategory category) {
  return switch (category) {
    NotificationCategory.announcement => const Color(0xFF4A88F7),
    NotificationCategory.alert => const Color(0xFFF97316),
    NotificationCategory.document => const Color(0xFF0F766E),
    NotificationCategory.order => const Color(0xFF2563EB),
    NotificationCategory.message => const Color(0xFF7C3AED),
    NotificationCategory.update => const Color(0xFF0891B2),
  };
}

import 'dart:async';
import 'dart:convert';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/order_tracking_notification.dart';
import '../screens/notifications/notification_screen.dart';
import '../screens/orders/delivery_tracking_screen.dart';
import '../screens/support/support_chat_screen.dart';
import 'api_service.dart';

const AndroidNotificationChannel _orderTrackingChannel =
    AndroidNotificationChannel(
      'order_tracking_updates_v2',
      'Order Tracking Updates',
      description: 'Delivery tracking updates for customer orders.',
      importance: Importance.max,
      playSound: true,
      sound: RawResourceAndroidNotificationSound(
        'mixkit_bell_notification_933',
      ),
    );
const String _fallbackNotificationTitle = 'Order Update';
const String _fallbackNotificationBody =
    'Your order tracking status was updated.';
const String _notificationBrandName = 'KY Service Center';
const String _notificationLogoAssetPath = 'assets/images/Logo_KYSC.png';
const String _lastSeenNotificationIdKey =
    'app_notification_last_seen_order_tracking_notification_id';
const String _notificationPrimerShownKey =
    'app_notification_permission_primer_shown_v1';
const String _notificationPermissionRequestedKey =
    'app_notification_permission_requested_v1';
const Duration _storedNotificationPollInterval = Duration(seconds: 25);
const Duration _tokenSyncThrottle = Duration(minutes: 5);

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  if (Firebase.apps.isNotEmpty) return;
  try {
    await Firebase.initializeApp();
  } catch (_) {
    // Firebase is optional during local development without iOS config files.
  }
}

class AppNotificationService {
  AppNotificationService._();

  static final AppNotificationService instance = AppNotificationService._();

  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  /// Live unread-notification count shown as the in-app bell badge.
  /// Updated by FCM pushes, the stored-notification poll, and the
  /// notification center when items are read or deleted.
  final ValueNotifier<int> unreadCount = ValueNotifier<int>(0);
  final ValueNotifier<int> inboxRevision = ValueNotifier<int>(0);

  void reportUnreadCount(int count) {
    final normalized = count < 0 ? 0 : count;
    if (unreadCount.value != normalized) {
      unreadCount.value = normalized;
    }
  }

  void reportInboxChanged() {
    inboxRevision.value = inboxRevision.value + 1;
  }

  FirebaseMessaging get _messaging => FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();
  final StreamController<OrderTrackingRealtimeEvent> _trackingEventsController =
      StreamController<OrderTrackingRealtimeEvent>.broadcast();

  bool _didInitialize = false;
  NotificationLaunchTarget? _pendingLaunchTarget;
  Timer? _storedNotificationPollTimer;
  bool _isPollingStoredNotifications = false;
  int _lastSeenStoredNotificationId = 0;
  bool _didLoadStoredNotificationCursor = false;
  bool _isPresentingPermissionPrimer = false;
  String? _cachedNotificationLogoBase64;
  String? _lastSyncedFcmToken;
  String? _lastSyncedAuthToken;
  DateTime? _lastTokenSyncAt;

  Stream<OrderTrackingRealtimeEvent> get orderTrackingEvents =>
      _trackingEventsController.stream;

  bool get _isSupportedMobilePlatform {
    if (kIsWeb) return false;
    return defaultTargetPlatform == TargetPlatform.android ||
        defaultTargetPlatform == TargetPlatform.iOS;
  }

  Future<void> initialize() async {
    if (_didInitialize || !_isSupportedMobilePlatform) return;
    final hasFirebase = Firebase.apps.isNotEmpty;
    _didInitialize = true;

    await _initializeLocalNotifications();

    if (hasFirebase) {
      try {
        FirebaseMessaging.onBackgroundMessage(
          firebaseMessagingBackgroundHandler,
        );
        await _messaging.setForegroundNotificationPresentationOptions(
          alert: false,
          badge: false,
          sound: false,
        );

        FirebaseMessaging.onMessage.listen(_handleForegroundMessage);
        FirebaseMessaging.onMessageOpenedApp.listen(_handleRemoteMessageTap);
        _messaging.onTokenRefresh.listen((token) {
          syncTokenWithBackend(force: true);
        });

        final initialMessage = await _messaging.getInitialMessage();
        if (initialMessage != null) {
          _queueLaunchTarget(_launchTargetFromRemoteMessage(initialMessage));
        }

        await syncTokenWithBackend(force: true);
      } catch (e) {
        // FCM setup is best-effort: emulators/devices without working Google
        // Play services throw here (e.g. "FCM Registration failed!"). Local
        // notifications and stored-notification polling must still work.
        debugPrint('FCM push setup failed, continuing without it: $e');
      }
    } else {
      debugPrint(
        'Skipping FCM push setup: Firebase is not configured for this build.',
      );
    }

    await _loadStoredNotificationCursor();
    await _pollStoredNotifications(showAlerts: false);
    _startStoredNotificationPolling();
  }

  Future<void> maybePromptForNotificationPermission(
    BuildContext context,
  ) async {
    if (!_isSupportedMobilePlatform || Firebase.apps.isEmpty) return;
    if (_isPresentingPermissionPrimer) return;

    final settings = await _messaging.getNotificationSettings();
    if (_isAuthorized(settings.authorizationStatus)) {
      await syncTokenWithBackend(force: true);
      return;
    }

    final prefs = await SharedPreferences.getInstance();
    final primerShown = prefs.getBool(_notificationPrimerShownKey) ?? false;
    final didRequestBefore =
        prefs.getBool(_notificationPermissionRequestedKey) ?? false;

    final canRequestFromCustomFlow =
        settings.authorizationStatus == AuthorizationStatus.notDetermined ||
        (settings.authorizationStatus == AuthorizationStatus.denied &&
            !didRequestBefore);

    if (!canRequestFromCustomFlow || primerShown || !context.mounted) {
      return;
    }

    _isPresentingPermissionPrimer = true;
    final shouldRequest = await showModalBottomSheet<bool>(
      context: context,
      useSafeArea: true,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withValues(alpha: 0.58),
      builder: (_) => const _NotificationPermissionPrimerSheet(),
    );
    _isPresentingPermissionPrimer = false;

    await prefs.setBool(_notificationPrimerShownKey, true);

    if (shouldRequest != true) {
      return;
    }

    await prefs.setBool(_notificationPermissionRequestedKey, true);
    final nextSettings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
    );

    if (_isAuthorized(nextSettings.authorizationStatus)) {
      await syncTokenWithBackend(force: true);
    }
  }

  Future<void> _initializeLocalNotifications() async {
    const androidSettings = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
      defaultPresentAlert: true,
      defaultPresentBadge: true,
      defaultPresentSound: true,
      defaultPresentBanner: true,
      defaultPresentList: true,
    );
    const settings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _localNotifications.initialize(
      settings,
      onDidReceiveNotificationResponse: (response) {
        final payload = response.payload;
        if (payload == null || payload.isEmpty) return;
        _handleSerializedPayload(payload);
      },
    );

    final androidPlugin = _localNotifications
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();
    await androidPlugin?.createNotificationChannel(_orderTrackingChannel);
  }

  Future<bool> syncTokenWithBackend({bool force = false}) async {
    if (!_isSupportedMobilePlatform || Firebase.apps.isEmpty) return false;
    // A missing auth token is fine: the device is registered as a guest
    // (anonymous) device so broadcasts still reach it.
    final authToken = (await ApiService.getToken())?.trim();

    String? token;
    try {
      token = await _messaging.getToken();
    } catch (e) {
      debugPrint('Failed to obtain FCM token: $e');
      return false;
    }
    final normalizedToken = token?.trim();
    if (normalizedToken == null || normalizedToken.isEmpty) return false;

    final recentlySynced =
        _lastTokenSyncAt != null &&
        DateTime.now().difference(_lastTokenSyncAt!) < _tokenSyncThrottle;
    if (!force &&
        recentlySynced &&
        _lastSyncedFcmToken == normalizedToken &&
        _lastSyncedAuthToken == authToken) {
      return true;
    }

    final synced = await registerTokenWithBackend(normalizedToken);
    if (synced) {
      _lastSyncedFcmToken = normalizedToken;
      _lastSyncedAuthToken = authToken;
      _lastTokenSyncAt = DateTime.now();
    }
    return synced;
  }

  Future<bool> registerTokenWithBackend(String? token) async {
    if (!_isSupportedMobilePlatform || Firebase.apps.isEmpty) return false;
    final normalized = token?.trim();
    if (normalized == null || normalized.isEmpty) return false;

    return ApiService.registerMobileDeviceToken(
      token: normalized,
      platform: _currentPlatform,
    );
  }

  Future<void> unregisterDeviceToken() async {
    if (!_isSupportedMobilePlatform || Firebase.apps.isEmpty) return;
    String? token;
    try {
      token = await _messaging.getToken();
    } catch (e) {
      debugPrint('Failed to obtain FCM token: $e');
      return;
    }
    final normalized = token?.trim();
    if (normalized == null || normalized.isEmpty) return;

    final removed = await ApiService.unregisterMobileDeviceToken(normalized);
    if (!removed) return;

    if (_lastSyncedFcmToken == normalized) {
      _lastSyncedFcmToken = null;
      _lastSyncedAuthToken = null;
      _lastTokenSyncAt = null;
    }
  }

  NotificationLaunchTarget? consumePendingLaunchTarget() {
    final target = _pendingLaunchTarget;
    _pendingLaunchTarget = null;
    return target;
  }

  void flushPendingNavigation() {
    final target = consumePendingLaunchTarget();
    if (target == null) return;
    _openLaunchTarget(target);
  }

  Future<void> _handleForegroundMessage(RemoteMessage message) async {
    _emitTrackingEvent(message);

    final notification = message.notification;
    final badgeCount = _tryParseInt(message.data['badge']) ?? 1;
    reportUnreadCount(badgeCount);
    final notificationId = _tryParseInt(message.data['notification_id']);
    if (notificationId != null) {
      _rememberStoredNotificationId(notificationId);
    }
    reportInboxChanged();

    final title = notification?.title?.trim().isNotEmpty == true
        ? notification!.title!.trim()
        : (message.data['title']?.toString().trim().isNotEmpty == true
              ? message.data['title'].toString().trim()
              : _fallbackNotificationTitle);
    final body = notification?.body?.trim().isNotEmpty == true
        ? notification!.body!.trim()
        : (message.data['body']?.toString().trim().isNotEmpty == true
              ? message.data['body'].toString().trim()
              : _fallbackNotificationBody);

    final target = _launchTargetFromRemoteMessage(message);

    await _showLocalNotification(
      notificationId:
          notificationId ??
          message.messageId?.hashCode ??
          DateTime.now().millisecondsSinceEpoch,
      title: title,
      body: body,
      badgeCount: badgeCount,
      target: target,
    );
  }

  void _handleRemoteMessageTap(RemoteMessage message) {
    _emitTrackingEvent(message);

    final target = _launchTargetFromRemoteMessage(message);
    if (target == null) return;
    _navigateOrQueue(target);
  }

  void _emitTrackingEvent(RemoteMessage message) {
    final event = _trackingEventFromData(
      message.data,
      messageId: message.messageId,
    );
    if (event == null) {
      return;
    }
    _trackingEventsController.add(event);
  }

  Future<void> _showLocalNotification({
    required int notificationId,
    required String title,
    required String body,
    required int badgeCount,
    NotificationLaunchTarget? target,
  }) async {
    final payload = target == null ? null : jsonEncode(target.toJson());
    final largeIcon = await _resolveNotificationLargeIcon();

    await _localNotifications.show(
      notificationId,
      title,
      body,
      NotificationDetails(
        android: AndroidNotificationDetails(
          _orderTrackingChannel.id,
          _orderTrackingChannel.name,
          channelDescription: _orderTrackingChannel.description,
          importance: Importance.max,
          priority: Priority.max,
          playSound: true,
          styleInformation: BigTextStyleInformation(
            body,
            contentTitle: title,
            summaryText: _notificationBrandName,
          ),
          largeIcon: largeIcon,
          sound: const RawResourceAndroidNotificationSound(
            'mixkit_bell_notification_933',
          ),
          enableVibration: true,
          channelShowBadge: true,
          visibility: NotificationVisibility.public,
          subText: _notificationBrandName,
          color: const Color(0xFF2A57CF),
          ticker: 'KY Service Center',
          number: badgeCount,
        ),
        iOS: DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
          presentBanner: true,
          presentList: true,
          interruptionLevel: InterruptionLevel.active,
          sound: 'universfield-new-notification-056-494256.mp3',
          badgeNumber: badgeCount,
        ),
      ),
      payload: payload,
    );
  }

  Future<AndroidBitmap<Object>?> _resolveNotificationLargeIcon() async {
    if (defaultTargetPlatform != TargetPlatform.android) {
      return null;
    }

    final encoded = await _loadNotificationLogoBase64();
    if (encoded == null || encoded.isEmpty) {
      return null;
    }

    return ByteArrayAndroidBitmap.fromBase64String(encoded);
  }

  Future<String?> _loadNotificationLogoBase64() async {
    final cached = _cachedNotificationLogoBase64;
    if (cached != null && cached.isNotEmpty) {
      return cached;
    }

    try {
      final bytes = await rootBundle.load(_notificationLogoAssetPath);
      final encoded = base64Encode(bytes.buffer.asUint8List());
      _cachedNotificationLogoBase64 = encoded;
      return encoded;
    } catch (_) {
      return null;
    }
  }

  Future<void> _loadStoredNotificationCursor() async {
    if (_didLoadStoredNotificationCursor) return;

    try {
      final prefs = await SharedPreferences.getInstance();
      _lastSeenStoredNotificationId =
          prefs.getInt(_lastSeenNotificationIdKey) ?? 0;
    } catch (_) {
      _lastSeenStoredNotificationId = 0;
    } finally {
      _didLoadStoredNotificationCursor = true;
    }
  }

  Future<void> _saveStoredNotificationCursor() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(
        _lastSeenNotificationIdKey,
        _lastSeenStoredNotificationId,
      );
    } catch (_) {}
  }

  void _startStoredNotificationPolling() {
    _storedNotificationPollTimer?.cancel();
    _storedNotificationPollTimer = Timer.periodic(
      _storedNotificationPollInterval,
      (_) => _pollStoredNotifications(),
    );
  }

  Future<void> _pollStoredNotifications({bool showAlerts = true}) async {
    if (_isPollingStoredNotifications) return;

    _isPollingStoredNotifications = true;
    try {
      await syncTokenWithBackend();

      if (!_didLoadStoredNotificationCursor) {
        await _loadStoredNotificationCursor();
      }

      final notifications = await ApiService.fetchOrderTrackingNotifications();
      reportUnreadCount(notifications.where((item) => item.isUnread).length);
      if (notifications.isEmpty) {
        return;
      }

      var newestId = _lastSeenStoredNotificationId;
      final newlyCreatedItems = <OrderTrackingNotificationItem>[];

      for (final item in notifications) {
        if (item.id > newestId) {
          newestId = item.id;
        }
        if (item.id > _lastSeenStoredNotificationId) {
          newlyCreatedItems.add(item);
        }
      }

      if (newestId == _lastSeenStoredNotificationId) {
        return;
      }

      _lastSeenStoredNotificationId = newestId;
      unawaited(_saveStoredNotificationCursor());
      reportInboxChanged();

      if (!showAlerts || newlyCreatedItems.isEmpty) {
        return;
      }

      final unreadCount = notifications
          .where((item) => item.isUnread)
          .length
          .clamp(1, 999);
      newlyCreatedItems.sort((a, b) => a.id.compareTo(b.id));

      for (final item in newlyCreatedItems) {
        final event = _trackingEventFromStoredNotification(item);
        if (event != null) {
          _trackingEventsController.add(event);
        }

        if (!item.isUnread) {
          continue;
        }

        final title = item.title.trim().isNotEmpty
            ? item.title.trim()
            : _fallbackNotificationTitle;
        final body = item.body?.trim().isNotEmpty == true
            ? item.body!.trim()
            : _defaultMessageForType(item.type);

        await _showLocalNotification(
          notificationId: item.id,
          title: title,
          body: body,
          badgeCount: unreadCount,
          target: _launchTargetFromStoredNotification(item),
        );
      }
    } catch (_) {
      // Keep polling resilient: notification API failures should never crash UI.
    } finally {
      _isPollingStoredNotifications = false;
    }
  }

  void _rememberStoredNotificationId(int id) {
    if (id <= _lastSeenStoredNotificationId) {
      return;
    }
    _lastSeenStoredNotificationId = id;
    unawaited(_saveStoredNotificationCursor());
  }

  OrderTrackingRealtimeEvent? _trackingEventFromStoredNotification(
    OrderTrackingNotificationItem item,
  ) {
    final data = <String, dynamic>{
      'type': item.type,
      'order_id': item.orderId,
      if (item.payload != null) ...item.payload!,
    };

    if (!data.containsKey('order_number') && item.payload != null) {
      data['order_number'] = item.payload!['order_number'];
    }

    return _trackingEventFromData(data, messageId: 'stored-${item.id}');
  }

  NotificationLaunchTarget? _launchTargetFromStoredNotification(
    OrderTrackingNotificationItem item,
  ) {
    final deepLink = item.deepLink?.trim();
    final payloadOrderNumber = item.payload?['order_number']?.toString().trim();
    final orderNumber =
        payloadOrderNumber != null && payloadOrderNumber.isNotEmpty
        ? payloadOrderNumber
        : null;

    if (item.orderId == null &&
        orderNumber == null &&
        (deepLink == null || deepLink.isEmpty)) {
      return null;
    }

    return NotificationLaunchTarget(
      orderId: item.orderId,
      orderNumber: orderNumber,
      deepLink: deepLink == null || deepLink.isEmpty ? null : deepLink,
    );
  }

  OrderTrackingRealtimeEvent? _trackingEventFromData(
    Map<String, dynamic> data, {
    String? messageId,
  }) {
    final type = _nullableTrim(data['type'])?.toLowerCase();
    final orderId = _tryParseInt(data['order_id']);
    final orderNumber = _nullableTrim(data['order_number']);
    final fromStatus = _nullableTrim(data['from_status'])?.toLowerCase();
    final toStatus = _nullableTrim(data['to_status'])?.toLowerCase();
    final hasOrderRef =
        orderId != null || (orderNumber != null && orderNumber.isNotEmpty);
    final looksLikeTrackingEvent =
        type == 'order_status_changed' ||
        fromStatus != null ||
        toStatus != null ||
        hasOrderRef;

    if (!looksLikeTrackingEvent || !hasOrderRef) {
      return null;
    }

    return OrderTrackingRealtimeEvent(
      messageId: _nullableTrim(messageId),
      type: type ?? 'order_status_changed',
      orderId: orderId,
      orderNumber: orderNumber,
      fromStatus: fromStatus,
      toStatus: toStatus,
      receivedAt: DateTime.now(),
    );
  }

  void _handleSerializedPayload(String payload) {
    try {
      final decoded = jsonDecode(payload);
      if (decoded is! Map) return;
      final target = NotificationLaunchTarget.fromJson(
        Map<String, dynamic>.from(decoded),
      );
      _navigateOrQueue(target);
    } catch (_) {}
  }

  NotificationLaunchTarget? _launchTargetFromRemoteMessage(
    RemoteMessage message,
  ) {
    final data = message.data;
    final deepLink =
        data['deep_link']?.toString().trim() ??
        data['deeplink']?.toString().trim();

    int? orderId = int.tryParse(data['order_id']?.toString() ?? '');
    if (orderId == null &&
        deepLink != null &&
        deepLink.startsWith('/orders/')) {
      orderId = int.tryParse(deepLink.split('/').last);
    }

    final orderNumber = data['order_number']?.toString().trim();
    if (orderId == null &&
        (orderNumber == null || orderNumber.isEmpty) &&
        (deepLink == null || deepLink.isEmpty)) {
      return null;
    }

    return NotificationLaunchTarget(
      orderId: orderId,
      deepLink: deepLink == null || deepLink.isEmpty ? null : deepLink,
      orderNumber: orderNumber == null || orderNumber.isEmpty
          ? null
          : orderNumber,
    );
  }

  void _navigateOrQueue(NotificationLaunchTarget target) {
    final navigatorState = navigatorKey.currentState;
    final context = navigatorKey.currentContext;
    if (navigatorState == null || context == null) {
      _queueLaunchTarget(target);
      return;
    }

    _openLaunchTarget(target);
  }

  void _queueLaunchTarget(NotificationLaunchTarget? target) {
    if (target == null) return;
    _pendingLaunchTarget = target;
  }

  void _openLaunchTarget(NotificationLaunchTarget target) {
    final navigatorState = navigatorKey.currentState;
    final context = navigatorKey.currentContext;
    if (navigatorState == null || context == null) {
      _queueLaunchTarget(target);
      return;
    }

    final deepLink = target.deepLink?.trim() ?? '';
    if (target.orderId != null ||
        target.orderNumber != null ||
        deepLink.startsWith('/orders/')) {
      navigatorState.push(
        MaterialPageRoute(
          builder: (_) => DeliveryTrackingScreen(
            orderId: target.orderId,
            orderNumber: target.orderNumber,
          ),
        ),
      );
      return;
    }

    if (deepLink.startsWith('/support')) {
      navigatorState.push(
        MaterialPageRoute(builder: (_) => const SupportChatScreen()),
      );
      return;
    }

    navigatorState.push(
      MaterialPageRoute(builder: (_) => const NotificationScreen()),
    );
  }

  String get _currentPlatform {
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return 'android';
      case TargetPlatform.iOS:
        return 'ios';
      default:
        return 'web';
    }
  }
}

String _defaultMessageForType(String? type) {
  final normalized = type?.trim().toLowerCase() ?? '';
  if (normalized.contains('admin')) {
    return 'You have a new message from KY-Service Center.';
  }
  return _fallbackNotificationBody;
}

bool _isAuthorized(AuthorizationStatus status) {
  return status == AuthorizationStatus.authorized ||
      status == AuthorizationStatus.provisional;
}

class _NotificationPermissionPrimerSheet extends StatelessWidget {
  const _NotificationPermissionPrimerSheet();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 16),
      child: Material(
        color: Colors.transparent,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(28),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: isDark
                  ? const [Color(0xFF0E1A2A), Color(0xFF121B2C)]
                  : const [Color(0xFFF4F8FF), Color(0xFFEFF3FF)],
            ),
            boxShadow: const [
              BoxShadow(
                color: Color(0x2A0D1B2A),
                blurRadius: 26,
                offset: Offset(0, 14),
              ),
            ],
            border: Border.all(
              color: isDark ? const Color(0xFF223149) : const Color(0xFFD9E4FF),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 18),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: isDark
                        ? const Color(0xFF1E3556)
                        : const Color(0xFFDDE9FF),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(
                    HugeIcons.strokeRoundedNotification02,
                    color: isDark
                        ? const Color(0xFFAFCBFF)
                        : const Color(0xFF2B5FD9),
                    size: 28,
                  ),
                ),
                const SizedBox(height: 14),
                Text(
                  'Stay Updated Instantly',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    height: 1.15,
                    color: isDark ? Colors.white : const Color(0xFF0F2239),
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  'Turn on notifications to receive new admin messages, order progress, and support replies in real time.',
                  style: TextStyle(
                    fontSize: 14.5,
                    height: 1.38,
                    color: isDark
                        ? const Color(0xFFB9C4D8)
                        : const Color(0xFF425B7A),
                  ),
                ),
                const SizedBox(height: 16),
                _PrimerBenefitRow(
                  icon: HugeIcons.strokeRoundedShoppingBag01,
                  label: 'New order and delivery updates',
                  isDark: isDark,
                ),
                const SizedBox(height: 10),
                _PrimerBenefitRow(
                  icon: HugeIcons.strokeRoundedCustomerService01,
                  label: 'Immediate support responses',
                  isDark: isDark,
                ),
                const SizedBox(height: 18),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.of(context).pop(false),
                        style: OutlinedButton.styleFrom(
                          minimumSize: const Size.fromHeight(48),
                          side: BorderSide(
                            color: isDark
                                ? const Color(0xFF2D415E)
                                : const Color(0xFFBED0F5),
                          ),
                          foregroundColor: isDark
                              ? const Color(0xFFD2DDF2)
                              : const Color(0xFF274870),
                          textStyle: const TextStyle(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        child: const Text('Not Now'),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => Navigator.of(context).pop(true),
                        style: ElevatedButton.styleFrom(
                          minimumSize: const Size.fromHeight(48),
                          backgroundColor: const Color(0xFF2057D6),
                          foregroundColor: Colors.white,
                          elevation: 0,
                          textStyle: const TextStyle(
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        child: const Text('Enable'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _PrimerBenefitRow extends StatelessWidget {
  const _PrimerBenefitRow({
    required this.icon,
    required this.label,
    required this.isDark,
  });

  final IconData icon;
  final String label;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 34,
          height: 34,
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF18273D) : const Color(0xFFE3EDFF),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            icon,
            size: 18,
            color: isDark ? const Color(0xFFAFCBFF) : const Color(0xFF285FCF),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 13.5,
              fontWeight: FontWeight.w600,
              color: isDark ? const Color(0xFFC3CEE2) : const Color(0xFF325173),
            ),
          ),
        ),
      ],
    );
  }
}

class NotificationLaunchTarget {
  const NotificationLaunchTarget({
    this.orderId,
    this.orderNumber,
    this.deepLink,
  });

  final int? orderId;
  final String? orderNumber;
  final String? deepLink;

  Map<String, dynamic> toJson() {
    return {
      'order_id': orderId,
      'order_number': orderNumber,
      'deep_link': deepLink,
    };
  }

  factory NotificationLaunchTarget.fromJson(Map<String, dynamic> json) {
    return NotificationLaunchTarget(
      orderId: _tryParseInt(json['order_id']),
      orderNumber: json['order_number']?.toString(),
      deepLink: json['deep_link']?.toString(),
    );
  }
}

class OrderTrackingRealtimeEvent {
  const OrderTrackingRealtimeEvent({
    required this.type,
    required this.receivedAt,
    this.messageId,
    this.orderId,
    this.orderNumber,
    this.fromStatus,
    this.toStatus,
  });

  final String type;
  final DateTime receivedAt;
  final String? messageId;
  final int? orderId;
  final String? orderNumber;
  final String? fromStatus;
  final String? toStatus;

  bool matchesOrder({int? id, String? number}) {
    final normalizedNumber = number?.trim();
    if (id != null && orderId != null && id == orderId) {
      return true;
    }
    if (normalizedNumber != null &&
        normalizedNumber.isNotEmpty &&
        orderNumber != null &&
        normalizedNumber == orderNumber) {
      return true;
    }
    return false;
  }
}

String? _nullableTrim(dynamic value) {
  final normalized = value?.toString().trim();
  if (normalized == null || normalized.isEmpty) {
    return null;
  }
  return normalized;
}

int? _tryParseInt(dynamic value) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  return int.tryParse(value?.toString() ?? '');
}

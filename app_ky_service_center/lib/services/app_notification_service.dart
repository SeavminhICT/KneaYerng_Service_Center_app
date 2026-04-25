import 'dart:convert';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import '../screens/notifications/notification_screen.dart';
import '../screens/orders/delivery_tracking_screen.dart';
import 'api_service.dart';

const AndroidNotificationChannel _orderTrackingChannel =
    AndroidNotificationChannel(
      'order_tracking_updates',
      'Order Tracking Updates',
      description: 'Delivery tracking updates for customer orders.',
      importance: Importance.max,
    );

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
}

class AppNotificationService {
  AppNotificationService._();

  static final AppNotificationService instance = AppNotificationService._();

  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  bool _didInitialize = false;
  NotificationLaunchTarget? _pendingLaunchTarget;

  bool get _isSupportedMobilePlatform {
    if (kIsWeb) return false;
    return defaultTargetPlatform == TargetPlatform.android ||
        defaultTargetPlatform == TargetPlatform.iOS;
  }

  Future<void> initialize() async {
    if (_didInitialize || !_isSupportedMobilePlatform) return;
    _didInitialize = true;

    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

    await _initializeLocalNotifications();
    await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
    );
    await _messaging.setForegroundNotificationPresentationOptions(
      alert: false,
      badge: false,
      sound: false,
    );

    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);
    FirebaseMessaging.onMessageOpenedApp.listen(_handleRemoteMessageTap);
    _messaging.onTokenRefresh.listen((token) {
      registerTokenWithBackend(token);
    });

    final initialMessage = await _messaging.getInitialMessage();
    if (initialMessage != null) {
      _queueLaunchTarget(_launchTargetFromRemoteMessage(initialMessage));
    }

    await syncTokenWithBackend();
  }

  Future<void> _initializeLocalNotifications() async {
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
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

  Future<void> syncTokenWithBackend() async {
    if (!_isSupportedMobilePlatform) return;
    final token = await _messaging.getToken();
    await registerTokenWithBackend(token);
  }

  Future<void> registerTokenWithBackend(String? token) async {
    if (!_isSupportedMobilePlatform) return;
    final normalized = token?.trim();
    if (normalized == null || normalized.isEmpty) return;

    await ApiService.registerMobileDeviceToken(
      token: normalized,
      platform: _currentPlatform,
    );
  }

  Future<void> unregisterDeviceToken() async {
    if (!_isSupportedMobilePlatform) return;
    final token = await _messaging.getToken();
    final normalized = token?.trim();
    if (normalized == null || normalized.isEmpty) return;

    await ApiService.unregisterMobileDeviceToken(normalized);
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
    final notification = message.notification;
    final badgeCount = _tryParseInt(message.data['badge']) ?? 1;
    final title =
        notification?.title?.trim().isNotEmpty == true
            ? notification!.title!.trim()
            : (message.data['title']?.toString().trim().isNotEmpty == true
                ? message.data['title'].toString().trim()
                : 'Order Update');
    final body =
        notification?.body?.trim().isNotEmpty == true
            ? notification!.body!.trim()
            : (message.data['body']?.toString().trim().isNotEmpty == true
                ? message.data['body'].toString().trim()
                : 'Your order tracking status was updated.');

    final target = _launchTargetFromRemoteMessage(message);
    final payload = target == null ? null : jsonEncode(target.toJson());

    await _localNotifications.show(
      message.messageId?.hashCode ?? DateTime.now().millisecondsSinceEpoch,
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
          enableVibration: true,
          channelShowBadge: true,
          visibility: NotificationVisibility.public,
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
          badgeNumber: badgeCount,
        ),
      ),
      payload: payload,
    );
  }

  void _handleRemoteMessageTap(RemoteMessage message) {
    final target = _launchTargetFromRemoteMessage(message);
    if (target == null) return;
    _navigateOrQueue(target);
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
    if (orderId == null && deepLink != null && deepLink.startsWith('/orders/')) {
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

int? _tryParseInt(dynamic value) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  return int.tryParse(value?.toString() ?? '');
}

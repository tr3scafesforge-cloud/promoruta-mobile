import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:go_router/go_router.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:promoruta/core/utils/logger.dart';
import 'package:promoruta/features/auth/domain/repositories/auth_repository.dart';
import 'package:promoruta/gen/l10n/app_localizations.dart';
import 'package:promoruta/shared/services/notification_channel_service.dart';

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  AppLogger.router.i('Received background push: ${message.messageId}');
}

class PushNotificationService {
  PushNotificationService({
    required AuthRepository authRepository,
    required NotificationChannelService notificationChannelService,
    required GlobalKey<NavigatorState> navigatorKey,
    FirebaseMessaging? messaging,
    FlutterLocalNotificationsPlugin? localNotifications,
  })  : _authRepository = authRepository,
        _notificationChannelService = notificationChannelService,
        _navigatorKey = navigatorKey,
        _messaging = messaging ?? FirebaseMessaging.instance,
        _localNotifications =
            localNotifications ?? FlutterLocalNotificationsPlugin();

  final AuthRepository _authRepository;
  final NotificationChannelService _notificationChannelService;
  final GlobalKey<NavigatorState> _navigatorKey;
  final FirebaseMessaging _messaging;
  final FlutterLocalNotificationsPlugin _localNotifications;

  bool _isInitialized = false;

  Future<void> initialize() async {
    if (_isInitialized) return;
    _isInitialized = true;

    try {
      await _notificationChannelService.initialize(_localNotifications);
      await _requestNotificationPermission();
      await _registerCurrentToken();

      _messaging.onTokenRefresh.listen((token) async {
        await _registerToken(token);
      });

      FirebaseMessaging.onMessage.listen(_handleForegroundMessage);
      FirebaseMessaging.onMessageOpenedApp.listen(_handleNotificationNavigation);

      final initialMessage = await _messaging.getInitialMessage();
      if (initialMessage != null) {
        _handleNotificationNavigation(initialMessage);
      }
    } catch (error, stackTrace) {
      AppLogger.router.e(
        'Push notification initialization failed',
        error: error,
        stackTrace: stackTrace,
      );
    }
  }

  Future<void> registerCurrentToken() async {
    await _registerCurrentToken();
  }

  Future<void> _requestNotificationPermission() async {
    await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
    );

    if (Platform.isAndroid) {
      await Permission.notification.request();
    }
  }

  Future<void> _registerCurrentToken() async {
    final token = await _messaging.getToken();
    await _registerToken(token);
  }

  Future<void> _registerToken(String? token) async {
    if (token == null || token.trim().isEmpty) {
      AppLogger.router.w('Skipping FCM token registration: token is empty');
      return;
    }

    try {
      await _authRepository.registerDeviceToken(token.trim());
    } catch (error, stackTrace) {
      AppLogger.router.w(
        'Unable to register FCM token (user may be logged out)',
        error: error,
        stackTrace: stackTrace,
      );
    }
  }

  Future<void> _handleForegroundMessage(RemoteMessage message) async {
    if (!Platform.isAndroid) return;

    final context = _navigatorKey.currentContext;
    final l10n = context != null ? AppLocalizations.of(context) : null;

    final title = message.notification?.title ??
        l10n?.newCampaignNotificationTitle ??
        'New campaign available';
    final body =
        message.notification?.body ??
        l10n?.newCampaignNotificationBody ??
        'A new campaign is ready for your bid.';

    await _localNotifications.show(
      message.hashCode,
      title,
      body,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          campaignAlertsChannelId,
          campaignAlertsChannelName,
          channelDescription: campaignAlertsChannelDescription,
          importance: Importance.high,
          priority: Priority.high,
        ),
      ),
      payload: message.data['campaignId']?.toString(),
    );
  }

  void _handleNotificationNavigation(RemoteMessage message) {
    final context = _navigatorKey.currentContext;
    if (context == null) return;

    final campaignId = message.data['campaignId']?.toString();
    if (campaignId == null || campaignId.isEmpty) {
      GoRouter.of(context).go('/promoter-home');
      return;
    }

    GoRouter.of(context).go('/promoter-campaign-details/$campaignId');
  }
}

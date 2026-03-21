import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:go_router/go_router.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:promoruta/core/core.dart' as model;
import 'package:promoruta/core/utils/logger.dart';
import 'package:promoruta/firebase_options.dart';
import 'package:promoruta/gen/l10n/app_localizations.dart';
import 'package:promoruta/shared/contracts/user_session_repository.dart';
import 'package:promoruta/shared/services/notification_channel_service.dart';

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  AppLogger.router.i('Received background push: ${message.messageId}');
}

class PushNotificationService {
  PushNotificationService({
    required UserSessionRepository authRepository,
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

  final UserSessionRepository _authRepository;
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
      FirebaseMessaging.onMessageOpenedApp
          .listen(_handleNotificationNavigation);

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

    final user = await _authRepository.getCurrentUser();
    _logIncomingMessage('foreground', message, user?.role);
    if (!_shouldHandleMessageForUser(message, user?.role)) {
      AppLogger.router.i(
        'Skipping push display for user role ${user?.role} with payload ${message.data}',
      );
      return;
    }

    final navigatorState = _navigatorKey.currentState;
    final l10n = navigatorState != null && navigatorState.mounted
        ? AppLocalizations.of(navigatorState.context)
        : null;
    final notificationContent = _notificationContentForMessage(message, l10n);
    final title = message.notification?.title ?? notificationContent.title;
    final body = message.notification?.body ?? notificationContent.body;

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

  Future<void> _handleNotificationNavigation(RemoteMessage message) async {
    final user = await _authRepository.getCurrentUser();
    _logIncomingMessage('navigation', message, user?.role);
    if (!_shouldHandleMessageForUser(message, user?.role)) {
      AppLogger.router.i(
        'Skipping push navigation for user role ${user?.role} with payload ${message.data}',
      );
      return;
    }

    final navigatorState = _navigatorKey.currentState;
    if (navigatorState == null || !navigatorState.mounted) return;

    final campaignId = message.data['campaignId']?.toString();
    final targetRole = _targetRoleForMessage(message) ?? user?.role;
    final router = GoRouter.of(navigatorState.context);

    if (targetRole == model.UserRole.advertiser) {
      if (campaignId == null || campaignId.isEmpty) {
        AppLogger.router.w(
          'Bid notification missing campaignId, falling back to advertiser home',
        );
        router.go('/advertiser-home');
        return;
      }

      router.go('/campaign-details/$campaignId');
      return;
    }

    if (campaignId == null || campaignId.isEmpty) {
      router.go('/promoter-home');
      return;
    }

    router.go('/promoter-campaign-details/$campaignId');
  }

  bool _shouldHandleMessageForUser(
    RemoteMessage message,
    model.UserRole? userRole,
  ) {
    if (userRole == null) return false;

    final targetRole = _targetRoleForMessage(message);
    if (targetRole == null) {
      return true;
    }

    return targetRole == userRole;
  }

  model.UserRole? _targetRoleForMessage(RemoteMessage message) {
    final explicitRole = _parseRole(
      message.data['target_role']?.toString() ??
          message.data['targetRole']?.toString() ??
          message.data['role']?.toString() ??
          message.data['user_role']?.toString(),
    );
    if (explicitRole != null) {
      return explicitRole;
    }

    final type = _normalizedValue(
      message.data['type']?.toString() ??
          message.data['notification_type']?.toString() ??
          message.data['event']?.toString(),
    );

    const promoterTypes = {
      'new_campaign',
      'campaign_created',
      'campaign_available',
      'new_campaign_available',
    };
    if (promoterTypes.contains(type)) {
      return model.UserRole.promoter;
    }

    const advertiserTypes = {
      'new_bid',
      'bid_created',
      'bid_received',
      'promoter_bid',
      'campaign_bid',
      'bid_placed',
      'bid_updated',
      'bid_withdrawn',
    };
    if (advertiserTypes.contains(type)) {
      return model.UserRole.advertiser;
    }

    return null;
  }

  model.UserRole? _parseRole(String? rawRole) {
    final value = _normalizedValue(rawRole);
    switch (value) {
      case 'promoter':
      case 'promotor':
        return model.UserRole.promoter;
      case 'advertiser':
      case 'anunciante':
        return model.UserRole.advertiser;
      default:
        return null;
    }
  }

  String _normalizedValue(String? value) {
    return value?.trim().toLowerCase().replaceAll(' ', '_') ?? '';
  }

  void _logIncomingMessage(
    String source,
    RemoteMessage message,
    model.UserRole? userRole,
  ) {
    final type = _normalizedValue(
      message.data['type']?.toString() ??
          message.data['notification_type']?.toString() ??
          message.data['event']?.toString(),
    );
    final targetRole = _targetRoleForMessage(message);

    AppLogger.router.i(
      'Push $source received: messageId=${message.messageId}, userRole=$userRole, targetRole=$targetRole, type=$type, data=${message.data}',
    );
  }

  _NotificationContent _notificationContentForMessage(
    RemoteMessage message,
    AppLocalizations? l10n,
  ) {
    final type = _normalizedValue(
      message.data['type']?.toString() ??
          message.data['notification_type']?.toString() ??
          message.data['event']?.toString(),
    );

    switch (type) {
      case 'bid_placed':
        return _NotificationContent(
          title: l10n?.bidPlacedNotificationTitle ?? 'New bid on your campaign',
          body: l10n?.bidPlacedNotificationBody ??
              'A promoter submitted a bid on your campaign.',
        );
      case 'bid_updated':
        return _NotificationContent(
          title: l10n?.bidUpdatedNotificationTitle ?? 'Bid updated',
          body: l10n?.bidUpdatedNotificationBody ??
              'A promoter updated their bid on your campaign.',
        );
      case 'bid_withdrawn':
        return _NotificationContent(
          title: l10n?.bidWithdrawnNotificationTitle ?? 'Bid withdrawn',
          body: l10n?.bidWithdrawnNotificationBody ??
              'A promoter withdrew their bid from your campaign.',
        );
      case 'new_bid':
      case 'bid_created':
      case 'bid_received':
      case 'promoter_bid':
      case 'campaign_bid':
        return _NotificationContent(
          title: l10n?.bidPlacedNotificationTitle ?? 'New bid received',
          body: l10n?.bidPlacedNotificationBody ??
              'A promoter submitted a bid for one of your campaigns.',
        );
      case 'bid_accepted':
      case 'campaign_started':
        return const _NotificationContent(
          title: 'Campaign update',
          body: 'Your campaign has a new status update.',
        );
      case 'new_campaign':
      case 'campaign_created':
      case 'campaign_available':
      case 'new_campaign_available':
      default:
        return _NotificationContent(
          title: l10n?.newCampaignNotificationTitle ?? 'New campaign available',
          body: l10n?.newCampaignNotificationBody ??
              'A new campaign is ready for your bid.',
        );
    }
  }
}

class _NotificationContent {
  const _NotificationContent({
    required this.title,
    required this.body,
  });

  final String title;
  final String body;
}

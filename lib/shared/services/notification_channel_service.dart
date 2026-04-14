import 'package:flutter_local_notifications/flutter_local_notifications.dart';

const String campaignAlertsChannelId = 'campaign_alerts';
const String campaignAlertsChannelName = 'Campaign Alerts';
const String campaignAlertsChannelDescription =
    'Notifications for newly available campaigns';
const String authAlertsChannelId = 'auth_alerts';
const String authAlertsChannelName = 'Authentication Alerts';
const String authAlertsChannelDescription =
    'Notifications related to authentication status';

class NotificationChannelService {
  const NotificationChannelService();

  Future<void> initialize(
    FlutterLocalNotificationsPlugin localNotifications,
  ) async {
    const initializationSettings = InitializationSettings(
      android: AndroidInitializationSettings('@mipmap/ic_launcher'),
      iOS: DarwinInitializationSettings(),
    );

    await localNotifications.initialize(initializationSettings);

    final androidImplementation =
        localNotifications.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();

    await androidImplementation?.createNotificationChannel(
      const AndroidNotificationChannel(
        campaignAlertsChannelId,
        campaignAlertsChannelName,
        description: campaignAlertsChannelDescription,
        importance: Importance.high,
      ),
    );

    await androidImplementation?.createNotificationChannel(
      const AndroidNotificationChannel(
        authAlertsChannelId,
        authAlertsChannelName,
        description: authAlertsChannelDescription,
        importance: Importance.high,
      ),
    );
  }
}

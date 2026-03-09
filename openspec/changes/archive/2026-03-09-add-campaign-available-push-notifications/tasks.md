## 1. Dependencies & Firebase Setup
- [x] 1.1 Add `firebase_core`, `firebase_messaging`, and `flutter_local_notifications` to `pubspec.yaml`
- [ ] 1.2 Add `google-services.json` to `android/app/` (obtain from Firebase console)
- [ ] 1.3 Add `GoogleService-Info.plist` to `ios/Runner/` (obtain from Firebase console)
- [x] 1.4 Apply `google-services` Gradle plugin in `android/app/build.gradle.kts` and project-level `build.gradle`
- [ ] 1.5 Enable Push Notifications capability in Xcode for the Runner target
- [x] 1.6 Add `aps-environment` entitlement to `ios/Runner/Runner.entitlements` (value: `production` for release, `development` for debug)

## 2. Android Platform Configuration
- [x] 2.1 Add `POST_NOTIFICATIONS` permission to `AndroidManifest.xml` (required for Android 13+)
- [x] 2.2 Declare the default FCM notification channel metadata in `AndroidManifest.xml`
- [x] 2.3 Add `@pragma('vm:entry-point')` background handler top-level function in `main.dart` (or dedicated file)

## 3. iOS Platform Configuration
- [x] 3.1 Add `UIBackgroundModes` → `remote-notification` to `ios/Runner/Info.plist`
- [x] 3.2 Configure `UNUserNotificationCenter` delegate to present foreground notifications (alert, badge, sound)

## 4. PushNotificationService Implementation
- [x] 4.1 Create `lib/shared/services/push_notification_service.dart`
  - Initialise `firebase_messaging`
  - Request notification permission (iOS; Android 13+ via `permission_handler`)
  - Expose `initialize()` method called from app bootstrap
  - Register token with backend on first call and on `onTokenRefresh`
  - Listen to `onMessage` (foreground) and show local notification on Android
  - Listen to `onMessageOpenedApp` (background tap) and navigate
  - Call `getInitialMessage` (terminated tap) and navigate
- [x] 4.2 Create `lib/shared/services/notification_channel_service.dart` (Android channel setup)
  - Create `campaign_alerts` channel with HIGH importance on init
- [x] 4.3 Register `PushNotificationService` in `lib/shared/providers/providers.dart`

## 5. FCM Token Backend Integration
- [x] 5.1 Add `DeviceTokenRepository` (or extend existing auth repository) with `PUT /users/me/device-token`
- [x] 5.2 Call `pushNotificationService.initialize()` from the app bootstrap in `main.dart` after `ProviderContainer` / `WidgetsFlutterBinding` is ready
- [x] 5.3 Trigger token registration after successful login in the auth flow

## 6. Deep-Link Navigation
- [x] 6.1 Identify / confirm the GoRouter route for campaign details (e.g. `/campaigns/:id`)
- [x] 6.2 Implement navigation helper `_handleNotificationNavigation(RemoteMessage message)` that extracts `campaignId` from `message.data` and pushes the route
- [x] 6.3 Guard against missing `campaignId` — fall back to promoter home

## 7. Localisation
- [x] 7.1 Add `newCampaignNotificationTitle` and `newCampaignNotificationBody` ARB keys to `lib/l10n/app_en.arb`, `app_es.arb`, `app_pt.arb`
- [ ] 7.2 Run `flutter gen-l10n` to regenerate `lib/gen/l10n/` files
- [x] 7.3 Use localised strings in the local notification display (foreground Android path)

## 8. Testing & QA
- [ ] 8.1 Send a test FCM message via Firebase console to a physical Android device and verify notification appears and tapping navigates correctly
- [ ] 8.2 Send a test FCM message to a physical iOS device (or TestFlight build) and verify the same
- [ ] 8.3 Verify foreground notification banner appears on Android while app is open
- [ ] 8.4 Verify terminated-state navigation via `getInitialMessage`
- [ ] 8.5 Verify token refresh scenario (revoke token from Firebase console, reopen app)
- [ ] 8.6 Verify graceful degradation when permission is denied

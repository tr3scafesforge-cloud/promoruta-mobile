# Change: Add Push Notifications for New Campaign Availability

## Why
Promoters currently have no way to know when an advertiser publishes a new campaign unless they
manually open the app. Real-time push notifications will close this gap, increase bid response
rates, and improve the overall marketplace velocity.

## What Changes
- Add `firebase_core` and `firebase_messaging` Flutter packages.
- Implement FCM device token registration: on login the app registers the token with the backend so the server can address individual devices.
- Handle incoming FCM payloads in foreground, background, and terminated states on Android and iOS.
- On notification tap, deep-link the promoter directly to the campaign detail page.
- Extend the existing `NotificationService` abstraction with a `PushNotificationService` that initialises FCM, handles token refresh, and dispatches navigation.
- Add Android and iOS platform configuration (manifest permissions, APNs entitlement, notification channel).
- All notification copy is localised (ES / EN / PT).

## Impact

- Affected specs:
  - `push-notifications` (new — mobile/Flutter side)
  - `push-notifications-backend` (new — Laravel backend side)
- Affected code (mobile):
  - `pubspec.yaml` — add `firebase_core`, `firebase_messaging`, `flutter_local_notifications`
  - `lib/shared/services/` — new `PushNotificationService`
  - `lib/shared/providers/providers.dart` — register `PushNotificationService`
  - `lib/features/auth/` — register / refresh device token after login
  - `android/app/src/main/AndroidManifest.xml` — POST_NOTIFICATIONS permission + default notification channel
  - `ios/Runner/` — APNs entitlement + Info.plist background mode
  - `lib/app/` — initialise FCM in app bootstrap
  - `lib/gen/l10n/` — add notification copy strings
- Affected code (backend — Laravel):
  - `database/migrations/` — add `fcm_token` column to `users` table
  - `app/Http/Controllers/DeviceTokenController.php` — `PUT /users/me/device-token`
  - `routes/api.php` — register device token route
  - `app/Services/CampaignNotificationService.php` — FCM multicast dispatch + stale token cleanup
  - `app/Observers/CampaignObserver.php` — trigger notification on campaign published
  - `config/firebase.php` — service account credentials path
  - `.gitignore` — exclude `firebase-credentials.json`

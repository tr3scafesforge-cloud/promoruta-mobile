# Design: Push Notifications for New Campaign Availability

## Context
The Promoruta mobile app is a Flutter-based marketplace for sound-advertising campaigns.
Advertisers create campaigns; nearby promoters bid on and execute them.
Currently the promoter discovers new campaigns only by opening the app.

Firebase Cloud Messaging (FCM) is the standard cross-platform push solution for Flutter apps.
The existing `NotificationService` interface (overlay toasts + dialogs) needs to be extended,
not replaced.

## Goals / Non-Goals

**Goals**
- Deliver a push notification to every eligible promoter within seconds of a new campaign being published.
- Support Android (API 21+) and iOS (11+).
- Handle notifications in foreground, background, and terminated app states.
- Deep-link directly to the campaign detail on tap.
- Register / refresh device token with the backend automatically.
- Request notification permission at the right moment (after first login).

**Non-Goals**
- Notification preferences / mute controls (future scope).
- Promoter-to-advertiser or in-app messaging (future scope).
- Web push notifications.
- Batching or digest notifications.
- Analytics / open-rate tracking (future scope).

## Decisions

### 1. Firebase Cloud Messaging as the push transport
**Decision:** Use `firebase_messaging` (the official FlutterFire plugin).
**Rationale:** FCM is free, maintained by Google, covers Android natively, and integrates with APNs for iOS through a single server API. The Flutter plugin is mature and aligns with the existing Firebase suite that the backend is expected to use.
**Alternative considered:** OneSignal — adds a third-party intermediary and SDK overhead; ruled out.

### 2. Server-side fan-out (backend sends notifications)
**Decision:** The mobile app only registers its FCM token with the backend. The backend is responsible for resolving which promoters are eligible (proximity, status) and sending the FCM message via the FCM HTTP v1 API.
**Rationale:** Eligibility logic (geo-fence, promoter status) lives on the server. Keeping it there avoids duplicating business rules in the client.

### 3. `flutter_local_notifications` for foreground notifications on Android
**Decision:** Use `flutter_local_notifications` to display a heads-up notification when the app is in the foreground on Android (FCM foreground messages on Android do not show a system notification by default).
**Rationale:** iOS shows foreground notifications natively through `setForegroundNotificationPresentationOptions`; Android needs the local-notification shim.

### 4. Extend `NotificationService`, do not replace it
**Decision:** Create a separate `PushNotificationService` class registered as its own provider. Keep `NotificationService` for UI toasts/dialogs.
**Rationale:** Single-responsibility; existing callers of `NotificationService` are unaffected.

### 5. Token registration tied to auth flow
**Decision:** Register the FCM token immediately after a successful login / session restore. Refresh is handled via `FirebaseMessaging.instance.onTokenRefresh` stream.
**Rationale:** Token must be associated with an authenticated user. Listening to `onTokenRefresh` ensures the backend always has the latest token (tokens rotate after APNs certificate rotation, app restore from backup, etc.).

### 6. Deep-link via GoRouter on notification tap
**Decision:** On `FirebaseMessaging.onMessageOpenedApp` (background tap) and `getInitialMessage` (terminated tap), extract `campaignId` from the FCM data payload and push `/campaigns/:id` using the existing GoRouter instance.
**Rationale:** Consistent with in-app navigation; no custom URL scheme needed.

## Notification Payload Contract (agreed with backend)

```json
{
  "notification": {
    "title": "Nueva campaña disponible",
    "body": "{{campaign.title}} cerca de ti"
  },
  "data": {
    "type": "new_campaign",
    "campaignId": "{{campaign.id}}"
  }
}
```

The `data` fields drive navigation; the `notification` block is shown by the OS.

## Risks / Trade-offs

| Risk | Mitigation |
|------|-----------|
| iOS APNs certificate setup required | Document exact Xcode steps in tasks.md |
| FCM token may be null if device has no Play Services | Guard token registration; no crash |
| User denies notification permission | App continues to function; promoter misses notifications |
| Background isolate limitations on Android | Use `@pragma('vm:entry-point')` on background handler |
| Token refresh not propagated (network failure) | Retry on next app launch |

## Migration Plan

1. Add packages and Firebase configuration files (no behaviour change yet).
2. Bootstrap FCM in `main.dart`; register token on login.
3. Wire up foreground, background, and terminated handlers.
4. Coordinate with backend to start sending `new_campaign` payloads.
5. Release in a standard app update; no migration of existing data required.

## Open Questions
- Will the backend filter eligible promoters by geo-fence radius at send time, or send to all promoters and let the app filter? (Assumed: backend filters by proximity.)
- Does the backend already support FCM token storage per user? (Assumed: endpoint TBD — backend team to provide.)
